local BASE_W, BASE_H = 1920, 1080
local function UIScale()
  -- uniform scale, using the minimum axis to avoid stretch
  return math.min(ScrW() / BASE_W, ScrH() / BASE_H)
end

local function SW(x) return math.floor(x * UIScale() + 0.5) end
local function SH(y) return math.floor(y * UIScale() + 0.5) end

local activePanel
local gpdaMessages = gpdaMessages or {}
local pdaMessages = pdaMessages or {}
local unreadMessages = unreadMessages or {}
local gradientMat = Material("vgui/gradient-r")

local function SavePDAMessages()
	local client = LocalPlayer()
	if (not IsValid(client)) then return end
	
	local char = client:GetCharacter()
	if (not char) then return end

	local data = {
		pda = pdaMessages,
		unread = unreadMessages
	}

	file.CreateDir("ix_stalker/pda_history")
	file.Write("ix_stalker/pda_history/" .. char:GetID() .. ".json", util.TableToJSON(data))
end

local PANEL = {}

function PANEL:Init()
	activePanel = self
	local client = LocalPlayer()
	local character = client:GetCharacter()
	local DEFAULT_AVATAR = character:GetData("pdaavatar","stalker/ui/avatars/nodata.png")
	self.activeChannel = "global"

	self:SetSize(SW(1165), SH(770)) 	--Size of the whole panel
	self:SetPos(SW(54), SH(86)) 		--Position of the whole panel
	self:SetPaintBackground(false)
	self:SetDrawBackground(false)
	
	-- Main Frame
	local mainFrame = self:Add("DImage")
	mainFrame:Dock(FILL)
	mainFrame:SetPaintBackground(false)
	mainFrame:SetMouseInputEnabled(true)

	-- LEFT FRAME
	local leftFrame = mainFrame:Add("DImage")
	leftFrame:SetSize(SW(750), SH(770))
	leftFrame:SetImage("stalker/ui/pda/rankings/rank_display.png")
	leftFrame:Dock(LEFT)
	leftFrame:SetPaintBackground(false)
	leftFrame:SetMouseInputEnabled(true)

	local entryPanel = leftFrame:Add("DPanel")
	entryPanel:Dock(BOTTOM)
	entryPanel:SetTall(SH(50))
	entryPanel:DockMargin(SW(10), SH(5), SW(10), SH(10))
	entryPanel:SetPaintBackground(false)
	entryPanel:SetMouseInputEnabled(true)

	local entry = entryPanel:Add("DTextEntry")
	entry:Dock(FILL)
	entry:SetFont("stalkerregularsmallfont")
	entry:SetPaintBackground(false)
	entry:SetMouseInputEnabled(true)
	entry:SetTextColor(color_white)
	entry:SetCursorColor(color_white)
	entry:SetPlaceholderText("Type a message here...")
	entry.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 150)
		surface.DrawRect(0, 0, w, h)
		s:DrawTextEntryText(color_white, Color(0, 191, 255), color_white)

		if (s:GetText() == "" and s:GetPlaceholderText()) then
			draw.SimpleText(s:GetPlaceholderText(), s:GetFont(), 3, h / 2, Color(150, 150, 150, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		surface.SetDrawColor(150, 150, 150, 100)
		surface.DrawOutlinedRect(0, 0, w, h)
	end
	entry.OnEnter = function(s)
		local text = s:GetValue()
		if (text and text:Trim() ~= "") then
			if (self.activeChannel == "global") then
				RunConsoleCommand("ix", "gpda", text)
			else
				RunConsoleCommand("ix", "pda", self.activeChannel, text)
			end
			s:SetText("")
			s:KillFocus()
		end
	end

	self.scroll = leftFrame:Add("DScrollPanel")
	self.scroll:Dock(FILL)
	self.scroll:DockMargin(SW(8), SH(8), SW(8), SH(0))
	self.scroll:SetMouseInputEnabled(true)

	local vbar = self.scroll:GetVBar()
	vbar:SetWide(SW(10))
	function vbar:Paint(w, h)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawRect(0, 0, w, h)
	end
	function vbar.btnUp:Paint(w, h) end
	function vbar.btnDown:Paint(w, h) end
	function vbar.btnGrip:Paint(w, h)
		surface.SetDrawColor(180, 180, 180, 150)
		surface.DrawRect(0, 0, w, h)
	end

	self:LoadChannel("global")

	-- TOP RIGHT FRAME
	local rightTopFrame = mainFrame:Add("DImage")
	rightTopFrame:SetSize(SW(410), SH(100))
	rightTopFrame:SetImage("stalker/ui/pda/rankings/rank_list_box.png")
	rightTopFrame:Dock(TOP)
	rightTopFrame:DockMargin(SW(5), 0, 0, 0)
	rightTopFrame:SetPaintBackground(false)
	rightTopFrame:SetMouseInputEnabled(true)

	-- Buttons Panel
	local buttonsPanel = rightTopFrame:Add("DPanel")
	buttonsPanel:Dock(LEFT)
	buttonsPanel:SetWide(SW(190))
	buttonsPanel:DockMargin(SW(7), SH(6), SW(7), SH(6))
	buttonsPanel:SetPaintBackground(false)

	-- Mute Button
	local muteButton = rightTopFrame:Add("DImageButton")
	muteButton:SetWide(SH(60))
	muteButton:Dock(LEFT)
	muteButton:DockMargin(20, SH(20), SW(0), SH(20))
	muteButton:SetKeepAspect(true)
	muteButton:SetTooltip("Mute/unmute Global chat sound")
	
	local function UpdateMuteIcon()
		if (ix.option.Get("GPDAvolume", 1) > 0) then
			muteButton:SetImage("icon32/unmuted.png")
		else
			muteButton:SetImage("icon32/muted.png")
		end
	end
	UpdateMuteIcon()

	muteButton.DoClick = function()
		local vol = ix.option.Get("GPDAvolume", 1)
		if (vol > 0) then
			self.lastVolume = vol
			ix.option.Set("GPDAvolume", 0)
		else
			ix.option.Set("GPDAvolume", self.lastVolume or 1)
		end
		UpdateMuteIcon()
		LocalPlayer():EmitSound("Helix.Press")
	end

	-- Global Chat Button
	self.globalChatButton = buttonsPanel:Add("DImageButton")
	self.globalChatButton:SetText("GLOBAL CHAT")
	self.globalChatButton:SetFont("stalkerregularsmallboldfont")
	self.globalChatButton:Dock(TOP)
	self.globalChatButton:DockMargin(0, SH(16), 0, SH(14))
	self.globalChatButton:SetImage(self.activeChannel == "global" and "stalker/ui/pda/button_selected.png" or "stalker/ui/pda/button.png")

	self.globalChatButton.DoClick = function()
		if (IsValid(self)) then
			self:LoadChannel("global")
		end
	end
	self.globalChatButton.OnMousePressed = function (panel)
		panel:SetImage("stalker/ui/pda/button_selected.png")
		LocalPlayer():EmitSound("Helix.Press")
	end
	self.globalChatButton.OnMouseReleased = function (panel)
		panel:DoClick()
	end

	-- Add contact button
	local addContactButton = buttonsPanel:Add("DImageButton")
	addContactButton:SetText("ADD CONTACT")
	addContactButton:SetFont("stalkerregularsmallboldfont")
	addContactButton:Dock(TOP)
	addContactButton:SetImage("stalker/ui/pda/button.png")
	addContactButton.DoClick = function()
		Derma_StringRequest("Add Contact", "Enter the PDA username of the contact:", "", function(text)
			if (text and text ~= "") then
				netstream.Start("ixPDAContactAdd", text)
				timer.Simple(0.2, function()
					if (IsValid(self)) then
						self:RefreshContacts()
					end
				end)
			end
		end)
	end
	addContactButton.OnMousePressed = function (panel)
		panel:SetImage("stalker/ui/pda/button_selected.png")
		LocalPlayer():EmitSound("Helix.Press")
	end
	addContactButton.OnMouseReleased = function (panel)
		panel:SetImage("stalker/ui/pda/button.png")
		panel:DoClick()
	end

	-- BOTTOM RIGHT FRAME
	local rightBottomFrame = mainFrame:Add("DImage")
	rightBottomFrame:SetSize(SW(410), SH(620))
	rightBottomFrame:SetImage("stalker/ui/pda/rankings/rank_display.png")
	rightBottomFrame:Dock(FILL)
	rightBottomFrame:DockMargin(SW(5), SH(5), 0, 0)
	rightBottomFrame:SetPaintBackground(false)
	rightBottomFrame:SetMouseInputEnabled(true)

	self.contactList = rightBottomFrame:Add("DScrollPanel")
	self.contactList:Dock(FILL)
	self.contactList:DockMargin(SW(7), SH(7), SW(7), SH(7))

	self:RefreshContacts()
end

function PANEL:Think()
	if ((self.nextUpdate or 0) < CurTime()) then
		self.nextUpdate = CurTime() + 1
		self:RefreshContacts()
	end
end

function PANEL:AddMessage(data)
	local minHeight = SH(60)
	
	surface.SetFont("stalkerregularsmallboldfont")
	local nameW, nameH = surface.GetTextSize(data.name .. ":")

	local row = self.scroll:Add("DPanel")
	row:Dock(TOP)
	row:DockMargin(0, 0, 0, SH(5))
	row:SetPaintBackground(false)

	local iconPnl = row:Add("DPanel")
	iconPnl:Dock(LEFT)
	local iconW = minHeight * (123 / 87)
	iconPnl:SetWide(iconW)
	iconPnl:DockMargin(0, 0, SW(5), 0)
	iconPnl:SetPaintBackground(false)

	local icon = iconPnl:Add("DImage")
	icon:Dock(TOP)
	icon:SetTall(minHeight)
	icon:SetImage(data.icon or "stalker/ui/avatars/nodata.png")
	icon:SetKeepAspect(true)

	local content = row:Add("DPanel")
	content:Dock(FILL)
	content:SetPaintBackground(false)

	local timestamp = content:Add("DLabel")
	local timeFormat = ix.option.Get("24hourTime") and "[%H:%M]" or "[%I:%M %p]"
	timestamp:SetText(os.date(timeFormat, data.timestamp or os.time()))
	timestamp:SetFont("stalkerregularsmallboldfont")
	timestamp:SetTextColor(Color(150, 150, 150))
	timestamp:Dock(TOP)
	timestamp:SizeToContents()
	timestamp:SetContentAlignment(4)
	timestamp:DockMargin(0, SH(10), 0, SH(10))

	local name = content:Add("DLabel")
	name:SetText(data.name .. ":")
	name:SetFont("stalkerregularsmallboldfont")
	name:SetTextColor(self.activeChannel == "global" and Color(0, 191, 255) or Color(255, 180, 51))
	name:Dock(LEFT)
	name:SetWide(nameW)
	name:DockMargin(0, 0, SW(5), 0)
	name:SetContentAlignment(7)

	local text = content:Add("DLabel")
	text:SetText(data.text)
	text:SetFont("stalkerregularsmallfont")
	text:SetTextColor(color_white)
	text:Dock(FILL)
	text:SetContentAlignment(7)
	text:SetWrap(true)

	-- Calculate row height based on text
	local scrollW = SW(750) -- Controls the width used for height calculation (same as leftFrame width)
	local scrollBarW = SW(10)
	local availableW = scrollW - (SW(8) * 2) - scrollBarW
	local usedW = iconW + SW(5) + nameW + SW(5)
	local textW = math.max(SW(50), availableW - usedW)

	local safeText = string.Replace(data.text, "&", "&amp;")
	safeText = string.Replace(safeText, "<", "&lt;")
	safeText = string.Replace(safeText, ">", "&gt;")
	local parsed = markup.Parse("<font=stalkerregularsmallfont>" .. safeText .. "</font>", textW - SW(2))
	
	row:SetTall(math.max(minHeight, timestamp:GetTall() + SH(20) + math.max(nameH, parsed:GetHeight()) + SH(5)))
end

function PANEL:ScrollToBottom()
	timer.Simple(0.05, function()
		if (IsValid(self) and IsValid(self.scroll)) then
			local canvas = self.scroll:GetCanvas()
			local children = canvas:GetChildren()
			if (#children > 0) then
				self.scroll:ScrollToChild(children[#children])
			end
		end
	end)
end

function PANEL:LoadChannel(channel)
	self.activeChannel = channel
	self.scroll:Clear()

	if (IsValid(self.globalChatButton)) then
		if (channel == "global") then
			self.globalChatButton:SetImage("stalker/ui/pda/button_selected.png")
		else
			self.globalChatButton:SetImage("stalker/ui/pda/button.png")
		end
	end

	if (unreadMessages[channel]) then
		unreadMessages[channel] = nil
		SavePDAMessages()
	end

	if (IsValid(self.contactList)) then
		for _, child in ipairs(self.contactList:GetCanvas():GetChildren()) do
			if (child.contactName) then
				child:SetColor(color_white)
				if (child.unreadIcon) then
					child.unreadIcon:SetVisible(unreadMessages[child.contactName] == true)
				end
			end
		end
	end

	local messages = (channel == "global") and gpdaMessages or pdaMessages[channel]
	if (messages) then
		for _, v in ipairs(messages) do
			self:AddMessage(v)
		end
	end
	self:ScrollToBottom()
end

function PANEL:RefreshContacts()
	netstream.Start("ixPDAContactsRequest")
end

function PANEL:UpdateContactsList(results)
	local currentScroll = self.contactList:GetVBar():GetScroll()
	local rowsByName = {}
	
	for _, child in ipairs(self.contactList:GetCanvas():GetChildren()) do
		if (child.contactName) then
			rowsByName[child.contactName] = child
		else
			child:Remove()
		end
	end

	local contacts = table.GetKeys(results)
	-- Sort online first, then alphabetically
	table.sort(contacts, function(a, b)
		local dataA = results[a]
		local dataB = results[b]
		local onlineA = dataA and dataA.online or false
		local onlineB = dataB and dataB.online or false

		if (onlineA != onlineB) then
			return onlineA
		end

		return a < b
	end)

	local headcolor = Color(104, 104, 104)
	local onlineColor = Color(0, 255, 0)
	local offlineColor = Color(255, 0, 0)
	local toRemove = table.Copy(rowsByName)

	local client = LocalPlayer()
	local character = client:GetCharacter()
	local faction = ix.faction.indices[character:GetFaction()]
	local playerColor = faction and faction.color or Color(255, 180, 51)

	for _, name in ipairs(contacts) do
		local data = results[name] or {online = false, avatar = "stalker/ui/avatars/nodata.png"}
		local status = data.status or (data.online and "Online" or "Offline")
		local statusColor = (status == "Online") and onlineColor or (status == "Incoming request" and Color(255, 200, 0) or (status == "Request sent" and Color(200, 200, 200) or offlineColor))
		local avatar = data.avatar
		local contactColor = playerColor
		local row = rowsByName[name]

		if (IsValid(row)) then
			toRemove[name] = nil
			row.contactColor = contactColor
			
			row:SetColor(color_white)

			if (row.avatarImage and row.avatarImage:GetImage() ~= avatar) then
				row.avatarImage:SetImage(avatar)
			end

			if (row.statusLabel) then
				row.statusLabel:SetText(status)
				row.statusLabel:SetTextColor(statusColor)
			end

			if (row.acceptBtn) then
				row.acceptBtn:SetVisible(status == "Incoming request")
			end

			if (row.denyBtn) then
				row.denyBtn:SetVisible(status == "Incoming request")
			end

			if (row.removeBtn) then
				row.removeBtn:SetVisible(status == "Request sent" or status == "Online" or status == "Offline")
			end

			if (unreadMessages[name]) then
				if (not row.unreadIcon) then
					local unreadIcon = row:Add("DImage")
					unreadIcon:SetSize(SH(16), SH(16))
					unreadIcon:SetImage("icon16/email.png")
					unreadIcon:Dock(RIGHT)
					unreadIcon:DockMargin(SW(5), SH(38), SW(5), SH(38))
					row.unreadIcon = unreadIcon
				end
				row.unreadIcon:SetVisible(true)
			elseif (row.unreadIcon) then
				row.unreadIcon:SetVisible(false)
			end

			row:MoveToBack()
		else
			row = self.contactList:Add("DImageButton")
			row.contactName = name
			row.contactColor = contactColor
			row:SetHeight(SH(92))
			row:Dock(TOP)
			row:DockMargin(0, 0, 0, 0)
			row:SetImage("stalker/ui/pda/rankings/rank_list_box.png")
			row:SetColor(color_white)

			local oldPaint = row.Paint
			row.Paint = function(s, w, h)
				oldPaint(s, w, h)
				if (self.activeChannel == s.contactName) then
					surface.SetDrawColor(s.contactColor.r, s.contactColor.g, s.contactColor.b, 50)
					surface.SetMaterial(gradientMat)
					surface.DrawTexturedRect(0, 0, w, h)
				end
			end

			row:SetMouseInputEnabled(true)
			row.DoClick = function()
				LocalPlayer():EmitSound("Helix.Press")
				self:LoadChannel(name)
			end

			local avatarPanel = row:Add("DPanel")
			avatarPanel:Dock(LEFT)
			avatarPanel:SetWide(SW(110))
			avatarPanel:SetPaintBackground(false)
			avatarPanel:DockMargin(SW(6), SH(6), 0, SH(6))
			avatarPanel:SetMouseInputEnabled(false)

			local avatarDisplay = avatarPanel:Add("DImage")
			avatarDisplay:SetImage(avatar)
			avatarDisplay:Dock(FILL)
			avatarDisplay:SetPaintBackground(false)
			row.avatarImage = avatarDisplay

			local infoContainer = row:Add("DPanel")
			infoContainer:Dock(LEFT)
			infoContainer:SetWidth(SW(280))
			infoContainer:SetPaintBackground(false)
			infoContainer:SetMouseInputEnabled(false)

			local function AddLabel(parent, text, color, topMargin)
				local label = parent:Add("DLabel")
				label:SetText(text)
				label:SetTextColor(color)
				label:SetFont("stalkerregularsmallboldfont")
				label:Dock(TOP)
				label:DockMargin(0, topMargin, 0, 0)
				label:SizeToContents()
				return label
			end

			local dataPanel = infoContainer:Add("DPanel")
			dataPanel:SetWide(SW(200))
			dataPanel:SetPaintBackground(false)

			AddLabel(dataPanel, name, color_white, SH(4))
			row.statusLabel = AddLabel(dataPanel, status, statusColor, SH(12))

			dataPanel:InvalidateLayout(true)
			dataPanel:SizeToChildren(false, true)
			dataPanel:SetPos(SW(4), (SH(92) - dataPanel:GetTall()) / 2)

			if (status == "Incoming request") then
				local denyBtn = row:Add("DImageButton")
				denyBtn:SetSize(SH(25), SH(25))
				denyBtn:Dock(RIGHT)
				denyBtn:DockMargin(SW(10), SH(34), SW(10), SH(34))
				denyBtn:SetImage("icon16/cross.png")
				denyBtn.DoClick = function()
					LocalPlayer():EmitSound("Helix.Press")
					netstream.Start("ixPDAContactResponse", name, false)
				end
				row.denyBtn = denyBtn

				local acceptBtn = row:Add("DImageButton")
				acceptBtn:SetSize(SH(25), SH(25))
				acceptBtn:Dock(RIGHT)
				acceptBtn:DockMargin(0, SH(34), SW(5), SH(34))
				acceptBtn:SetImage("icon16/tick.png")
				acceptBtn.DoClick = function()
					LocalPlayer():EmitSound("Helix.Press")
					netstream.Start("ixPDAContactResponse", name, true)
				end
				row.acceptBtn = acceptBtn

			elseif (status == "Request sent" or status == "Online" or status == "Offline") then
				local removeBtn = row:Add("DImageButton")
				removeBtn:SetSize(SH(25), SH(25))
				removeBtn:Dock(RIGHT)
				removeBtn:DockMargin(SW(10), SH(34), SW(10), SH(34))
				removeBtn:SetImage("icon16/status_busy.png")
				removeBtn.DoClick = function()
					LocalPlayer():EmitSound("Helix.Press")
					Derma_Query("Are you sure you want to remove this contact?", "Remove Contact", "Yes", function()
						netstream.Start("ixPDAContactRemove", name)
						timer.Simple(0.2, function()
							if (IsValid(self)) then
								self:RefreshContacts()
							end
						end)
					end, "No")
				end
				row.removeBtn = removeBtn
			end

			local unreadIcon = row:Add("DImage")
			unreadIcon:SetSize(SH(25), SH(25))
			unreadIcon:SetImage("icon16/email.png")
			unreadIcon:Dock(RIGHT)
			unreadIcon:DockMargin(0, SH(34), SW(5), SH(34))
			unreadIcon:SetVisible(unreadMessages[name] == true)
			row.unreadIcon = unreadIcon
		end
	end

	for name, row in pairs(toRemove) do
		row:Remove()
	end

	self.contactList:GetVBar():SetScroll(currentScroll)
end

netstream.Hook("ixPDAContactsReply", function(results)
	if (IsValid(activePanel)) then
		activePanel:UpdateContactsList(results)
	end
end)

netstream.Hook("ixPDAContactRequest", function(requester, name)
	if (IsValid(activePanel)) then
		activePanel:RefreshContacts()
	end
end)

function PANEL:OnRemove()
	if (activePanel == self) then
		activePanel = nil
	end
end
	
vgui.Register("ixChatPanel", PANEL, "DPanel")

hook.Add("OnGPDAMessage", "ixPDAChatListener", function(name, text, icon)
	local data = {name = name, text = text, icon = icon, timestamp = os.time()}
	table.insert(gpdaMessages, data)

	if (IsValid(activePanel) and activePanel.activeChannel == "global") then
		activePanel:AddMessage(data)
		activePanel:ScrollToBottom()
	end
end)

hook.Add("OnPDAMessage", "ixPDAPrivateListener", function(sender, text, icon, target, isSender)
	local other = isSender and target or sender
	if (not other) then return end

	local data = {name = sender, text = text, icon = icon, timestamp = os.time()}
	pdaMessages[other] = pdaMessages[other] or {}
	table.insert(pdaMessages[other], data)
	SavePDAMessages()

	if (not isSender) then
		if (not IsValid(activePanel) or activePanel.activeChannel != other) then
			unreadMessages[other] = true
			if (IsValid(activePanel)) then
				activePanel:RefreshContacts()
			end
		end
	end

	if (IsValid(activePanel) and activePanel.activeChannel == other) then
		activePanel:AddMessage(data)
		activePanel:ScrollToBottom()
	end
end)

hook.Add("CreateMenuButtons", "ixChat", function(tabs)
	local character = LocalPlayer():GetCharacter()
	if (character and character:GetData("pdaequipped", false)) then
		tabs["Chat"] = function(container)
			container:Add("ixChatPanel")
		end
	end
end)

hook.Add("CharacterLoaded", "ixPDAMessagesLoad", function()
	local client = LocalPlayer()
	local char = client:GetCharacter()
	if (not char) then return end

	local path = "ix_stalker/pda_history/" .. char:GetID() .. ".json"
	if (file.Exists(path, "DATA")) then
		local data = util.JSONToTable(file.Read(path, "DATA"))
		if (data) then
			pdaMessages = data.pda or {}
			unreadMessages = data.unread or {}
		else
			pdaMessages = {}
			unreadMessages = {}
		end
	else
		pdaMessages = {}
		unreadMessages = {}
	end
end)