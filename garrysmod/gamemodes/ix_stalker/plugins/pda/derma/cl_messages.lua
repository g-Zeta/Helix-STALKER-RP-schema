
if CLIENT then
    ix.pda = ix.pda or {}
    -- Client-side state like muted status or unread messages will now be stored on the character.
    ix.pda.muted = ix.pda.muted or false
    local pdaMessageQueue = {}
    ix.pda.contacts = ix.pda.contacts or {}

    -- This function is called when the server sends us the message history
    net.Receive("ixPDAReceiveHistory", function()
        local messageHistory = net.ReadTable()
        ix.pda.messages = messageHistory

        -- Tell any open PDA chat panels to refresh their content.
        hook.Run("ixPDARefreshMessages")
    end)

    -- This function is called when a new message is broadcasted by the server
    net.Receive("ixPDAReceiveMessage", function()
        -- We just add the message to a queue. A Think hook will process it
        -- to avoid race conditions during character loading.
        local msgData = net.ReadTable()

        -- For debugging: Print the received message details to the client console.
        if (LocalPlayer():IsAdmin()) then
            if (msgData.is_global) then
                print(string.format("[%s][GPDA] '%s': %s", msgData.formatted_time, msgData.sender_name, msgData.message))
            else
                print(string.format("[%s][PDA] '%s' to '%s': %s", msgData.formatted_time, msgData.sender_name, msgData.recipient_char_name, msgData.message))
            end
        end

        table.insert(pdaMessageQueue, msgData)
    end)

    -- This function is called when the server sends us our contact list
    net.Receive("ixPDAUpdateContacts", function()
        local contacts = net.ReadTable()
        ix.pda.contacts = contacts
        -- Tell any open PDA chat panels to update their contact list
        hook.Run("ixPDAUpdateContactsDisplay")
    end)

    -- This function is called when the server sends a status update for a single contact
    net.Receive("ixPDAContactStatusUpdate", function()
        local charID = net.ReadUInt(32)
        local isOnline = net.ReadBool()

        if not ix.pda.contacts then return end

        -- Find the contact and update their status
        for _, contactData in ipairs(ix.pda.contacts) do
            if contactData.charID == charID then
                contactData.isOnline = isOnline
                hook.Run("ixPDAUpdateContactsDisplay")
                return -- Found and updated, no need to continue loop
            end
        end
    end)

    -- This hook resets the PDA's local state when a new character is loaded,
    -- ensuring settings don't carry over between characters.
    hook.Add("PostPlayerLoadout", "ixPDAResetState", function(client)
        if (client == LocalPlayer()) then
            ix.pda.muted = false
        end
    end)

    -- This timer processes the message queue, ensuring the character is fully loaded.
    -- It's more efficient and reliable than using a Think hook for this task.
    timer.Create("ixPDAMessageQueueTimer", 0.1, 0, function()
        if (#pdaMessageQueue > 0) then
            -- Process all messages currently in the queue.
            for _, msgData in ipairs(pdaMessageQueue) do
                -- Add to our local cache
                if (not ix.pda.messages) then
                    ix.pda.messages = {}
                end
                table.insert(ix.pda.messages, msgData)
 
                -- Play a notification sound for the new message if not muted.
                if (not ix.pda.muted) then
                    local pdaVolume = ix.option.Get("pdaVolume", 0.4)
 
                    if (pdaVolume > 0) then
                        local soundFile = msgData.is_global and "stalker/pda/pda_beep_1.ogg" or "stalker/pda/pda_news.wav"
                        -- CreateSound is better than sound.Play for UI as it's not positional.
                        -- PlayEx allows us to specify volume dynamically from the ix.option.
                        local soundEmitter = CreateSound(LocalPlayer(), soundFile)
                        soundEmitter:SetSoundLevel(80) -- Standard UI sound level
                        soundEmitter:PlayEx(pdaVolume, 100)
                    end
                end
 
                -- Tell any open PDA chat panels to display the new message.
                hook.Run("ixPDANewMessage", msgData)
            end
 
            -- Clear the queue now that it's been processed.
            pdaMessageQueue = {}
        end
    end)
 
    -- Scaling functions to adapt UI to different screen resolutions, similar to the rankings plugin.
    local BASE_W, BASE_H = 1920, 1080
    local function UIScale()
      return math.min(ScrW() / BASE_W, ScrH() / BASE_H)
    end

    local function SW(x) return math.floor(x * UIScale() + 0.5) end
    local function SH(y) return math.floor(y * UIScale() + 0.5) end

    local PANEL = {}

    -- A helper function to determine if a message should be displayed in the current view
    local function ShouldShowMessage(msgData, privateChatTarget)
        local localChar = LocalPlayer():GetCharacter()
        if not localChar then return false end

        if (privateChatTarget) then -- Private chat view
            if (msgData.is_global) then return false end -- Don't show global messages in private chat

            local localCharName = localChar:GetData("pdausername", localChar:GetName())
            local targetCharName = privateChatTarget.pdausername

            return (msgData.sender_name == localCharName and msgData.recipient_char_name == targetCharName) or
                   (msgData.sender_name == targetCharName and msgData.recipient_char_name == localCharName)
        else -- Global chat view
            return msgData.is_global or false
        end

        return false
    end

    -- A function to add a message to the history panel
    local function AddMessageToHistory(historyPanel, msgData)
        -- We add the panel directly to the DListLayout
        local msgLine = historyPanel:Add("DPanel")
        msgLine:Dock(TOP)
        msgLine:DockMargin(0, 0, 0, SH(5)) -- Use margin for spacing

        msgLine.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 150))
        end

        local sender_margin_l, sender_margin_t, sender_margin_r, sender_margin_b = SW(5), SH(5), SW(5), 0

        -- Timestamp Label
        local timestampLabel = msgLine:Add("DLabel")
        timestampLabel:SetFont("stalkerregularsmallboldfont")
        local timeString = os.date("[%H:%M]", msgData.time or os.time())
        timestampLabel:SetText(timeString .. " ")
        timestampLabel:SetColor(Color(180, 180, 180, 255))
        timestampLabel:SizeToContents()

        -- Avatar
        local avatar = msgLine:Add("DImage")
        avatar:SetMaterial(Material(msgData.sender_avatar or "stalker/ui/pda/avatars/nodata.png"))

        -- Sender Label
        local senderLabel = msgLine:Add("DLabel")
        senderLabel:SetFont("stalkerregularsmallboldfont")
        senderLabel:SetText(msgData.sender_name .. ": ")
        senderLabel:SetColor(Color(255, 200, 0, 255)) -- Amber color
        senderLabel:SizeToContents()

        local message_margin_l, message_margin_t, message_margin_r, message_margin_b = SW(5), 0, SW(5), SH(5)
        local messageLabel = msgLine:Add("DLabel")
        messageLabel:SetFont("stalkerregularsmallfont")
        messageLabel:SetText(msgData.message)
        messageLabel:SetTextColor(Color(255, 255, 255, 255))
        messageLabel:SetWrap(true)

        -- Manually calculate the height of the panel to work around the broken VGUI functions.
        msgLine.PerformLayout = function(self, w, h)
            -- Manually position all labels to appear on one line, with the message wrapping.
            local x_cursor = 0
            local y_pos = sender_margin_t
            local avatar_margin = SW(4)
            avatar:SetSize(SW(60), SH(42))
            local avatar_h = avatar:GetTall()

            -- Position timestampLabel
            x_cursor = sender_margin_l
            timestampLabel:SetPos(x_cursor, y_pos + (avatar_h - timestampLabel:GetTall()) * 0.5)
            x_cursor = x_cursor + timestampLabel:GetWide()

            -- Position avatar
            x_cursor = x_cursor + avatar_margin
            avatar:SetPos(x_cursor, y_pos)
            x_cursor = x_cursor + avatar:GetWide()

            -- Position senderLabel
            x_cursor = x_cursor + avatar_margin
            senderLabel:SetPos(x_cursor, y_pos + (avatar_h - senderLabel:GetTall()) * 0.5)
            x_cursor = x_cursor + senderLabel:GetWide()

            -- Position messageLabel
            local message_y = y_pos + (avatar_h - senderLabel:GetTall()) * 0.5
            messageLabel:SetPos(x_cursor, message_y)
            messageLabel:SetWide(w - x_cursor - message_margin_r)
            messageLabel:SizeToContentsY() -- Calculate wrapped height based on the new width.

            -- Set the parent panel's height to fit all content.
            local requiredHeight = math.max(message_y + messageLabel:GetTall(), y_pos + avatar_h) + message_margin_b

            if self:GetTall() ~= requiredHeight then
                self:SetTall(requiredHeight)
            end
        end

        -- No need to return anything
    end

    function PANEL:Init()
        -- When the chat is opened, mark messages as read and hide the HUD icon.
        -- Create a local alias for 'self' to prevent scope confusion in closures.
        local ChatFrame = self

        self.privateChatTarget = nil
        self.placeholderText = "Type your message here..."

        -- Set size and position similar to the Rankings panel
        self:SetSize(SW(1165), SH(770))
        self:SetPos(SW(54), SH(86))
        self:SetDrawBackground(false)
        self:SetPaintBackground(false)

		local msgPanel = self:Add("Panel")
		msgPanel:Dock(FILL)

        -- We use a DPanel with a custom paint function instead of DImage
        -- to ensure child elements like the text entry can receive input.
        local msgchat = msgPanel:Add("DPanel")
        msgchat:Dock(LEFT)
        msgchat:SetWidth(SW(800))
        msgchat.Paint = function(s, w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(Material("stalker/ui/pda/rankings/rank_display.png"))
            surface.DrawTexturedRect(0, 0, w, h)
        end

        -- Revert to DScrollPanel and DListLayout to avoid broken DPanelList methods.
        local msgscroll = msgchat:Add("DScrollPanel")
        msgscroll:Dock(FILL)
        msgscroll:DockMargin(SW(10), SH(10), SW(10), SH(5))

        -- Make the scrollbar more visible against the dark background.
        -- We use a timer because the VBar and its components are not created immediately.
        timer.Simple(0, function()
            if (IsValid(msgscroll) and IsValid(msgscroll.VBar)) then
                local vbar = msgscroll.VBar
                vbar:SetWide(SW(20)) -- Make it a bit wider and easier to click

                -- Paint for the scrollbar track
                vbar.Paint = function(s, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60, 180))
                end

                -- Paint for the draggable grip
                -- The skin overrides .Grip to be a getter method, so we must call it with a colon.
                local grip = vbar:Grip()
                if (IsValid(grip)) then
                    grip.Paint = function(s, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, Color(210, 210, 210, 230))
                    end
                end

                -- Hide the up/down arrow buttons as they can look out of place
                local btnUp = vbar.btnUp
                if (IsValid(btnUp)) then
                    btnUp:SetVisible(false)
                end

                local btnDown = vbar.btnDown
                if (IsValid(btnDown)) then
                    btnDown:SetVisible(false)
                end
            end
        end)

        local msghistory = msgscroll:Add("DListLayout")
        -- We must manually set the width of the DListLayout to match its parent DScrollPanel.
        -- We do not use Dock(FILL) as that would constrain its height, preventing it from growing
        -- to accommodate new messages. The height will be managed automatically by DListLayout.
        msgscroll.PerformLayout = function(s, w, h)
            local vbar_w = 0
            if (IsValid(s.VBar) and s.VBar:IsVisible()) then
                vbar_w = s.VBar:GetWide()
            end
            msghistory:SetWide(w - vbar_w)

            -- Manual implementation of UpdateScrollBars since it's broken by the skin.
            -- This calculates the total content height and configures the scrollbar.
            if (IsValid(msghistory) and IsValid(s.VBar)) then
                local contentH = 0
                local spacing = SH(5) -- The bottom margin set on each message panel.
                for _, child in ipairs(msghistory:GetChildren()) do
                    contentH = contentH + child:GetTall() + spacing
                end
                if #msghistory:GetChildren() > 0 then
                    contentH = contentH - spacing
                end

                local panelH = s:GetTall()
                local needed = contentH > panelH
                s.VBar:SetVisible(needed)

                if needed then
                    -- This allows SetScroll to work.
                    s.VBar.CanvasSize = contentH
                    s.VBar.VisibleSize = panelH
                end
            end
        end
        -- Spacing is handled by DockMargin in AddMessageToHistory.
 
        -- The schema's skin breaks ScrollToBottom(), so we must manually calculate and set the scroll position.
        local function ScrollToBottom()
            timer.Simple(0, function()
                if (IsValid(msgscroll) and IsValid(msgscroll.VBar)) then
                    -- Force a layout update to ensure the scrollbar's maximum value is correct.
                    msgscroll:InvalidateLayout(true)

                    -- Set the scroll to a very large number; the scrollbar will automatically clamp it to the maximum value.
                    -- This is a more reliable method than manually calculating the content height.
                    msgscroll.VBar:SetScroll(9999999)
                end
            end)
        end

        -- Function to populate all messages
        self.PopulateMessages = function()
            self.msghistory:Clear()

            if (ix.pda and ix.pda.messages) then
                for _, msgData in ipairs(ix.pda.messages) do
                    if (ShouldShowMessage(msgData, self.privateChatTarget)) then
                        AddMessageToHistory(self.msghistory, msgData)
                    end
                end
            end

            self.ScrollToBottom()
        end
        self.msghistory = msghistory
        self.ScrollToBottom = ScrollToBottom

        -- Populate existing messages when the panel is created
        self.PopulateMessages()

        -- Hook to add new messages as they arrive
        self.OnNewMessage = function(panel, msgData)
            if (ShouldShowMessage(msgData, self.privateChatTarget)) then
                AddMessageToHistory(self.msghistory, msgData)
                self.ScrollToBottom()
            end
        end
        hook.Add("ixPDANewMessage", self, self.OnNewMessage)

        -- Hook to refresh all messages from the history
        self.OnRefreshMessages = function(panel)
            self.PopulateMessages()
        end
        hook.Add("ixPDARefreshMessages", self, self.OnRefreshMessages)

        local placeholderColor = Color(100, 100, 100, 200)

        ChatFrame.msgbox = msgchat:Add("DTextEntry")
        ChatFrame.msgbox:Dock(BOTTOM)
        ChatFrame.msgbox:SetHeight(SH(40))
        ChatFrame.msgbox:DockMargin(SW(10), SH(0), SW(10), SH(10))
        ChatFrame.msgbox:RequestFocus()
        ChatFrame.msgbox:SetFont("stalkerregularsmallfont")
        ChatFrame.msgbox.Paint = function(msgbox_panel, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 150))

            if (msgbox_panel:GetValue() == "" and not msgbox_panel:HasFocus()) then
                draw.SimpleText(ChatFrame.placeholderText, msgbox_panel:GetFont(), 5, h / 2, placeholderColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            msgbox_panel:DrawTextEntryText(Color(0, 0, 0, 255), Color(50, 150, 255, 200), Color(0, 0, 0, 255))
        end

        -- This function is called when the user presses Enter
        ChatFrame.msgbox.OnEnter = function(msgbox_panel)
            local message = msgbox_panel:GetValue()

            -- Don't send empty messages
            if (string.Trim(message) == "") then return end

            -- The server will handle saving and broadcasting the message.
            -- It will be sent back to us and all other clients.
            net.Start("ixPDASendMessage")
                net.WriteString(message)

                if (ChatFrame.privateChatTarget) then
                    net.WriteBool(false) -- isGlobal
                    net.WriteString(ChatFrame.privateChatTarget.pdausername)
                else
                    net.WriteBool(true) -- isGlobal
                end

            net.SendToServer()

            msgbox_panel:SetText("")
            msgbox_panel:RequestFocus()
        end

        local optionsPanel = self:Add("Panel")
        optionsPanel:Dock(RIGHT)
        optionsPanel:SetSize(SW(360), SH(770))
        
        local chatoptPanel = optionsPanel:Add("DPanel")
        chatoptPanel:Dock(TOP)
        chatoptPanel:SetSize(SW(360), SH(74))
        chatoptPanel.Paint = function(s, w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(Material("stalker/ui/pda/rankings/rank_list_box.png"))
            surface.DrawTexturedRect(0, 0, w, h)
        end

        local chatopts = chatoptPanel:Add("DPanel")
        chatopts:Dock(LEFT)
        chatopts:SetWide(SW(190))
        chatopts:SetPaintBackground(false)
                
        self.chatglobal = chatopts:Add("DImageButton")
        self.chatglobal:SetText("GLOBAL CHAT")
        self.chatglobal:SetFont("stalkerregularsmallboldfont")
        self.chatglobal:SetImage("stalker/ui/pda/button.png")
        self.chatglobal:Dock(TOP)
        self.chatglobal:SetTall(SH(22))
        self.chatglobal:DockMargin(SW(5), SH(10), 0, 0)
        self.chatglobal.DoClick = function()
            -- Only do something if we are in a private chat
            if (self.privateChatTarget) then
                self.privateChatTarget = nil
                self:UpdateChatView()
            end
            LocalPlayer():EmitSound("Helix.Press")
        end

        local addcontact = chatopts:Add("DImageButton")
        addcontact:SetText("ADD CONTACT")
        addcontact:SetFont("stalkerregularsmallboldfont")
        addcontact:SetImage("stalker/ui/pda/button.png")
        addcontact:Dock(TOP)
        addcontact:SetTall(SH(22))
        addcontact:DockMargin(SW(5), SH(10), 0, 0)
        addcontact.DoClick = function()
            Derma_StringRequest(
                "Add Contact", -- Title
                "Enter the exact PDA username of the contact you wish to add.", -- Text
                "", -- Default value
                function(text) -- OnEnter
                    if (string.Trim(text) == "") then return end
                    net.Start("ixPDAAddContact")
                        net.WriteString(text)
                    net.SendToServer()
                end,
                nil, -- OnCancel
                "Add", -- OK button text
                "Cancel" -- Cancel button text
            )
        end

        addcontact.OnMousePressed = function(panel)
            panel:SetImage("stalker/ui/pda/button_selected.png")
            LocalPlayer():EmitSound("Helix.Press")
        end

        addcontact.OnMouseReleased = function(panel)
            -- Revert the image back to the normal state when the mouse button is released.
            panel:SetImage("stalker/ui/pda/button.png")
            panel:DoClick()
        end

        local chatopts2 = chatoptPanel:Add("DPanel")
        chatopts2:Dock(LEFT)
        chatopts2:SetWide(SW(100))
        chatopts2:DockMargin(SW(30), SH(16), SW(0), SH(16))
        chatopts2:SetPaintBackground(false)
        
        local clearchat = chatopts2:Add("DImageButton")
        clearchat:SetImage("icon16/bin_empty.png")
        clearchat:SetSize(SW(40), SH(40))
        clearchat.DoClick = function()
            Derma_Query("Are you sure you want to clear the chat history?\n\nThis cannot be undone.", "Confirm Clear Chat", "Yes", function()
                if (msghistory and IsValid(msghistory)) then
                    msghistory:Clear()
                end
                if (ix.pda and ix.pda.messages) then
                    ix.pda.messages = {}
                end
            end, "No")
            LocalPlayer():EmitSound("Helix.Press")
        end

        local mutechat = chatopts2:Add("DImageButton")
        mutechat:SetSize(SW(40), SH(40))
        mutechat:SetPos(SW(60), 0)

        local function UpdateMuteIcon()
            if (ix.pda.muted) then
                mutechat:SetImage("icon32/muted.png")
            else
                mutechat:SetImage("icon32/unmuted.png")
            end
        end
        UpdateMuteIcon()

        mutechat.DoClick = function()
            ix.pda.muted = not ix.pda.muted
            UpdateMuteIcon()
            LocalPlayer():EmitSound("Helix.Press")
        end

        local contactsPanel = optionsPanel:Add("DPanel")
        contactsPanel:Dock(BOTTOM)
        contactsPanel:SetSize(SW(360), SH(690))
        contactsPanel.Paint = function(s, w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(Material("stalker/ui/pda/rankings/rank_list.png"))
            surface.DrawTexturedRect(0, 0, w, h)
        end

        local contactslist = contactsPanel:Add("DScrollPanel")
        contactslist:Dock(FILL)
        contactslist:DockMargin(SW(7), SH(8), SW(7), SH(8))
        contactslist:SetName("ContactsList")
        contactslist:SetMouseInputEnabled(true)
        contactslist:SetPaintBackground(false)

        local function PopulateContacts()
            contactslist:GetCanvas():Clear()

            if (not ix.pda.contacts or #ix.pda.contacts == 0) then
                local noContactsLabel = contactslist:GetCanvas():Add("DLabel")
                noContactsLabel:SetText("No contacts added.")
                noContactsLabel:SetFont("stalkerregularsmallfont")
                noContactsLabel:SetTextColor(Color(150, 150, 150))
                noContactsLabel:Dock(TOP)
                noContactsLabel:SetContentAlignment(5) -- Center
                noContactsLabel:DockMargin(0, SH(20), 0, 0)
                return
            end

            for _, contactData in ipairs(ix.pda.contacts) do
                local contactbox = contactslist:GetCanvas():Add("DImageButton")
                contactbox:Dock(TOP)
                contactbox:SetTall(SH(80))
                contactbox:SetImage("stalker/ui/pda/rankings/rank_list_box.png")
                contactbox:DockMargin(0, 0, 0, SH(5))

                local avatar = contactbox:Add("DImage")
                avatar:SetMaterial(Material(contactData.pdaavatar or "stalker/ui/pda/avatars/nodata.png"))
                avatar:Dock(LEFT)
                avatar:SetWide(SW(100))
                avatar:DockMargin(SW(5), SH(5), 0, SH(5))

                local contactboxlabels = contactbox:Add("DPanel")
                contactboxlabels:Dock(LEFT)
                contactboxlabels:SetWide(SW(210))
                contactboxlabels:DockMargin(SW(5), SH(15), 0, SH(15))
                --contactboxlabels:SetPaintBackground(false)

                local nameLabel = contactboxlabels:Add("DLabel")
                nameLabel:SetText(contactData.pdausername)
                nameLabel:SetFont("stalkerregularsmallboldfont")
                nameLabel:SetColor(Color(255, 255, 255))
                nameLabel:Dock(TOP)

                local statusLabel = contactboxlabels:Add("DLabel")
                statusLabel:SetFont("stalkerregularsmallfont")
                statusLabel:Dock(BOTTOM)

                if contactData.is_request then
                    statusLabel:SetText("Incoming Request")
                    statusLabel:SetColor(Color(255, 200, 0)) -- Amber
                    nameLabel:SetColor(Color(200, 200, 200))
                elseif contactData.pending_approval then
                    statusLabel:SetText("Request Sent")
                    statusLabel:SetColor(Color(150, 150, 150)) -- Grey
                    nameLabel:SetColor(Color(200, 200, 200))
                elseif contactData.isOnline then
                    statusLabel:SetText("Online")
                    statusLabel:SetColor(Color(100, 255, 100)) -- Green
                else
                    statusLabel:SetText("Offline")
                    statusLabel:SetColor(Color(180, 0, 0)) -- Red
                end

                statusLabel:SizeToContents()

                if not contactData.is_request and not contactData.pending_approval then
                    contactbox.DoClick = function()
                        self.privateChatTarget = contactData
                        LocalPlayer():EmitSound("Helix.Press")
                        self:UpdateChatView()
                    end
                end

                if contactData.is_request then
                    -- Add "Decline" button for incoming requests
                    local declinecontact = contactbox:Add("DImageButton")
                    declinecontact:SetImage("icon16/cancel.png")
                    declinecontact:Dock(RIGHT)
                    declinecontact:SetWide(SW(30))
                    declinecontact:DockMargin(SW(0), SH(25), SW(5), SH(25))
                    declinecontact.DoClick = function()
                        net.Start("ixPDADeclineRequest")
                            net.WriteUInt(contactData.charID, 32)
                        net.SendToServer()
                        LocalPlayer():EmitSound("Helix.Press")
                    end

                    -- Add "Accept" button for incoming requests
                    local addcontact = contactbox:Add("DImageButton")
                    addcontact:SetImage("icon16/accept.png")
                    addcontact:Dock(RIGHT)
                    addcontact:SetWide(SW(30))
                    addcontact:DockMargin(SW(0), SH(25), SW(5), SH(25))
                    addcontact.DoClick = function()
                        net.Start("ixPDAAcceptRequest")
                            net.WriteUInt(contactData.charID, 32)
                        net.SendToServer()
                        LocalPlayer():EmitSound("Helix.Press")
                    end
                else
                    -- Add "Remove" button for confirmed contacts or sent requests
                    local removecontact = contactbox:Add("DImageButton")
                    removecontact:SetImage("icon16/delete.png")
                    removecontact:Dock(RIGHT)
                    removecontact:SetWide(SW(30))
                    removecontact:DockMargin(SW(0), SH(25), SW(5), SH(25))
                    removecontact.DoClick = function()
                        local confirmText = contactData.pending_approval and "Are you sure you want to cancel this contact request?" or string.format("Are you sure you want to remove \"%s\" from your contacts?", contactData.pdausername)
                        Derma_Query(
                            confirmText,
                            "Confirm Action",
                            "Yes",
                            function() -- OnYes
                                net.Start("ixPDARemoveContact")
                                    net.WriteUInt(contactData.charID, 32)
                                net.SendToServer()
                            end,
                            "No"
                        )
                        LocalPlayer():EmitSound("Helix.Press")
                    end
                end
            end
        end

        self.PopulateContacts = PopulateContacts
        self.PopulateContacts()

        self.OnUpdateContacts = function() self.PopulateContacts() end
        hook.Add("ixPDAUpdateContactsDisplay", self, self.OnUpdateContacts)

        self:UpdateChatView()
    end

    function PANEL:UpdateChatView()
        if (self.privateChatTarget) then
            self.chatglobal:SetText("GLOBAL CHAT")
            self.chatglobal:SetImage("stalker/ui/pda/button.png")
            self.placeholderText = "Send a message to " .. self.privateChatTarget.pdausername .. "..."
        else
            self.chatglobal:SetText("GLOBAL CHAT")
            self.chatglobal:SetImage("stalker/ui/pda/button_selected.png")
            self.placeholderText = "Type your message here..."
        end

        self.PopulateMessages()
    self.msgbox:InvalidateLayout(true) -- Force a repaint to update the placeholder text
    end

    function PANEL:OnRemove()
        hook.Remove("ixPDAUpdateContactsDisplay", self)
        hook.Remove("ixPDANewMessage", self)
        hook.Remove("ixPDARefreshMessages", self)
    end

    vgui.Register("ChatFrame", PANEL, "DPanel")

    -- This hook adds the "Chat" tab to the menu
    hook.Add("CreateMenuButtons", "ixPDAChat", function(tabs)
        tabs["Chat"] = function(container)
            container:Add("ChatFrame")
        end
    end)
end