-- On plugin load, ensure our helper table exists in the database.
if (ix.mysql) then
    local query = ix.mysql.Query([[
        CREATE TABLE IF NOT EXISTS `ix_pda_usernames` (
            `username` VARCHAR(64) NOT NULL,
            `character_id` INT(11) UNSIGNED NOT NULL,
            PRIMARY KEY (`username`),
            UNIQUE INDEX `character_id_UNIQUE` (`character_id` ASC)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    query:Execute()
end

-- Helper to get all online character IDs
local function GetAllOnlineCharIDs()
    local onlineIDs = {}
    for _, ply in ipairs(player.GetAll()) do
        local char = ply:GetCharacter()
        if char then
            onlineIDs[char:GetID()] = true
        end
    end
    return onlineIDs
end

-- Helper to send an updated contact list to a player
local function UpdateAndSendContacts(character)
    if not character then return end

    local ply = character:GetPlayer()
    if not IsValid(ply) then return end

    local contacts = character:GetData("pdaContacts", {})
    local onlineIDs = GetAllOnlineCharIDs()

    for _, contactData in ipairs(contacts) do
        contactData.isOnline = onlineIDs[contactData.charID] or false
    end

    net.Start("ixPDAUpdateContacts")
        net.WriteTable(contacts)
    net.Send(ply)
end

-- When a player sends a request to add a contact
net.Receive("ixPDAAddContact", function(len, client)
    local contactName = net.ReadString()
    local senderChar = client:GetCharacter()

    if not senderChar then return end

    -- Local function to process the request
    local function ProcessRequest(targetChar)
        local senderID = senderChar:GetID()
        local targetID = targetChar:GetID()
--[[
        if senderID == targetID then
            client:Notify("You cannot add yourself as a contact.")
            return
        end
]]
        -- Check if they are already a contact or have a pending request
        local senderContacts = senderChar:GetData("pdaContacts", {})
        for _, c in ipairs(senderContacts) do
            if c.charID == targetID then
                if c.is_request then
                    client:Notify("You have a pending request from this person. Please accept it from your contact list.")
                elseif c.pending_approval then
                    client:Notify("You have already sent a request to this person.")
                else
                    client:Notify("This person is already in your contacts.")
                end
                return
            end
        end

        -- Add target to sender's contacts as 'pending'
        table.insert(senderContacts, {
            charID = targetID,
            pdausername = targetChar:GetData("pdausername", targetChar:GetName()),
            pdaavatar = targetChar:GetData("pdaavatar", "stalker/ui/pda/pda_prof_placeholder.png"),
            pending_approval = true
        })
        table.sort(senderContacts, function(a, b) return a.pdausername < b.pdausername end)
        senderChar:SetData("pdaContacts", senderContacts)
        UpdateAndSendContacts(senderChar)
        client:Notify("Contact request sent.")

        -- Add sender to target's contacts as a 'request'
        local targetContacts = targetChar:GetData("pdaContacts", {})
        table.insert(targetContacts, {
            charID = senderID,
            pdausername = senderChar:GetData("pdausername", senderChar:GetName()),
            pdaavatar = senderChar:GetData("pdaavatar", "stalker/ui/pda/pda_prof_placeholder.png"),
            is_request = true
        })
        table.sort(targetContacts, function(a, b) return a.pdausername < b.pdausername end)
        targetChar:SetData("pdaContacts", targetContacts)

        local targetPlayer = targetChar:GetPlayer()
        if (IsValid(targetPlayer)) then
            targetPlayer:Notify(senderChar:GetData("pdausername", senderChar:GetName()).." has sent you a contact request.")
            UpdateAndSendContacts(targetChar)
        end
    end

    -- Find the character being added among ONLINE players first.
    for _, ply in ipairs(player.GetAll()) do
        local plyChar = ply:GetCharacter()
        if plyChar and plyChar:GetData("pdausername", plyChar:GetName()) == contactName then
            ProcessRequest(plyChar)
            return
        end
    end

    -- If not found online, search the database for an OFFLINE character.
    if (not ix.mysql) then
        client:Notify("Could not find an offline user with that PDA name.")
        return
    end

    local query = ix.mysql.Query("SELECT character_id FROM ix_pda_usernames WHERE username = "..ix.mysql.SQLStr(contactName).." LIMIT 1;")
    query:Execute(function(result)
        if (result:HasError()) then
            client:Notify("An error occurred while searching for the contact.")
            ErrorNoHalt("[PDA Contacts] MySQL Error: "..result:GetError().."\n")
            return
        end

        local rows = result:GetRows()
        if (#rows == 0) then
            client:Notify("Could not find a user with that PDA name.")
            return
        end

        local targetCharID = tonumber(rows[1].character_id)
        local targetChar = ix.char.loaded[targetCharID]

        if (targetChar) then
            -- Target is loaded in memory (online or recently disconnected)
            ProcessRequest(targetChar)
        else
            -- Target is offline, handle with direct database modification
            local query = mysql:Select("ix_characters"):Select("name", "data"):Where("id", targetCharID):Limit(1)
            query:Callback(function(charResult)
                if (charResult and #charResult > 0) then
                    local targetRow = charResult[1]
                    local targetData = util.JSONToTable(targetRow.data or "{}")
                    local pdaName = targetData.pdausername or targetRow.name
                    local pdaAvatar = targetData.pdaavatar or "stalker/ui/pda/pda_prof_placeholder.png"

                    -- This is essentially an offline version of ProcessRequest
                    -- Add target to sender's contacts as 'pending'
                    local senderContacts = senderChar:GetData("pdaContacts", {})
                    table.insert(senderContacts, { charID = targetCharID, pdausername = pdaName, pdaavatar = pdaAvatar, pending_approval = true })
                    table.sort(senderContacts, function(a, b) return a.pdausername < b.pdausername end)
                    senderChar:SetData("pdaContacts", senderContacts)
                    UpdateAndSendContacts(senderChar)
                    client:Notify("Contact request sent.")

                    -- Add sender to target's contacts as a 'request'
                    local targetContacts = targetData.pdaContacts or {}
                    table.insert(targetContacts, { charID = senderChar:GetID(), pdausername = senderChar:GetData("pdausername", senderChar:GetName()), pdaavatar = senderChar:GetData("pdaavatar", "stalker/ui/pda/pda_prof_placeholder.png"), is_request = true })
                    targetData.pdaContacts = targetContacts
                    mysql:Update("ix_characters"):Update("data", util.TableToJSON(targetData)):Where("id", targetCharID):Execute()
                else
                    client:Notify("Failed to load target character data.")
                end
            end)
            query:Execute()
        end
    end)
end)

-- When a player loads in, send them their contact list with online statuses.
function PLUGIN:PostPlayerLoadout(client)
    local character = client:GetCharacter()
    if not character then return end

    UpdateAndSendContacts(character)
end

-- When a player spawns in (fully loaded)
function PLUGIN:PlayerInitialSpawn(client)
    -- Update the PDA username table when a player spawns.
    if (ix.mysql) then
        local char = client:GetCharacter()
        if not char then return end
        local pdaName = char:GetData("pdausername", char:GetName())
        ix.mysql.Query("INSERT INTO `ix_pda_usernames` (username, character_id) VALUES ("..ix.mysql.SQLStr(pdaName)..", "..char:GetID()..") ON DUPLICATE KEY UPDATE username="..ix.mysql.SQLStr(pdaName)..";"):Execute()
    end

    local char = client:GetCharacter()
    if not char then return end

    -- Notify all other players that this character is now online.
    net.Start("ixPDAContactStatusUpdate")
        net.WriteUInt(char:GetID(), 32)
        net.WriteBool(true) -- isOnline
    net.Broadcast()
end

-- When a player disconnects
function PLUGIN:PlayerDisconnect(client)
    local char = client:GetCharacter()
    if not char then return end

    -- Notify all other players that this character is now offline.
    net.Start("ixPDAContactStatusUpdate")
        net.WriteUInt(char:GetID(), 32)
        net.WriteBool(false) -- isOnline
    net.Broadcast()
end

-- When a player requests to remove a contact
net.Receive("ixPDARemoveContact", function(len, client)
	local contactCharID = net.ReadUInt(32)
	local removerChar = client:GetCharacter()

	if not removerChar then return end

	-- Function to handle mutual removal
	local function MutualRemove(targetChar)
		local removerID = removerChar:GetID()
		local targetID = targetChar:GetID()

		-- 1. Remove target from remover's list
		local removerContacts = removerChar:GetData("pdaContacts", {})
		for i = #removerContacts, 1, -1 do
			if removerContacts[i].charID == targetID then
				table.remove(removerContacts, i)
				removerChar:SetData("pdaContacts", removerContacts)
				client:Notify("Contact removed.")
				UpdateAndSendContacts(removerChar)
				break
			end
		end

		-- 2. Remove remover from target's list
		local targetContacts = targetChar:GetData("pdaContacts", {})
		for i = #targetContacts, 1, -1 do
			if targetContacts[i].charID == removerID then
				table.remove(targetContacts, i)
				targetChar:SetData("pdaContacts", targetContacts)
				local targetPlayer = targetChar:GetPlayer()
				if IsValid(targetPlayer) then
					targetPlayer:Notify(removerChar:GetData("pdausername", removerChar:GetName()) .. " has removed you from their contacts.")
					UpdateAndSendContacts(targetChar)
				end
				break
			end
		end
	end

	-- Load the target character to perform mutual removal
    local targetChar = ix.char.loaded[contactCharID]
    if (targetChar) then
        MutualRemove(targetChar)
    else
        -- Target is offline, use direct database modification
        if not ix.mysql then return end

        local query = mysql:Select("ix_characters"):Select("data"):Where("id", contactCharID):Limit(1)
        query:Callback(function(result)
            if result and #result > 0 then
                local charData = util.JSONToTable(result[1].data or "{}")
                local contacts = charData.pdaContacts or {}
                for i = #contacts, 1, -1 do
                    if contacts[i].charID == removerChar:GetID() then
                        table.remove(contacts, i)
                        charData.pdaContacts = contacts
                        mysql:Update("ix_characters"):Update("data", util.TableToJSON(charData)):Where("id", contactCharID):Execute()
                        break
                    end
                end
            end
        end)
        query:Execute()
    end
end)

-- When a player accepts a contact request
net.Receive("ixPDAAcceptRequest", function(len, client)
    local requesterID = net.ReadUInt(32)
    local acceptorChar = client:GetCharacter()

    if not acceptorChar then return end

    local acceptorID = acceptorChar:GetID()

    -- Function to finalize the connection
    local function Finalize(requesterChar)
        -- 1. Update acceptor's contact list (remove is_request flag)
        local acceptorContacts = acceptorChar:GetData("pdaContacts", {})
        local found = false
        for _, c in ipairs(acceptorContacts) do
            if c.charID == requesterID and c.is_request then
                c.is_request = nil
                found = true
                break
            end
        end

        if not found then
            client:Notify("Could not find the incoming contact request.")
            return
        end

        acceptorChar:SetData("pdaContacts", acceptorContacts)
        UpdateAndSendContacts(acceptorChar)
        client:Notify("Contact added.")

        -- 2. Update requester's contact list (remove pending_approval flag)
        local requesterContacts = requesterChar:GetData("pdaContacts", {})
        local requesterFound = false
        for _, c in ipairs(requesterContacts) do
            if c.charID == acceptorID and c.pending_approval then
                c.pending_approval = nil
                requesterFound = true
                break
            end
        end

        -- If not found, add acceptor to requester's list (failsafe)
        if not requesterFound then
            table.insert(requesterContacts, {
                charID = acceptorID,
                pdausername = acceptorChar:GetData("pdausername", acceptorChar:GetName()),
                pdaavatar = acceptorChar:GetData("pdaavatar", "stalker/ui/pda/pda_prof_placeholder.png")
            })
            table.sort(requesterContacts, function(a, b) return a.pdausername < b.pdausername end)
        end

        requesterChar:SetData("pdaContacts", requesterContacts)
        local requesterPlayer = requesterChar:GetPlayer()
        if IsValid(requesterPlayer) then
            requesterPlayer:Notify(acceptorChar:GetData("pdausername", acceptorChar:GetName()) .. " has accepted your contact request.")
            UpdateAndSendContacts(requesterChar)
        end
    end

    -- Load requester's character data to modify it
    local requesterChar = ix.char.loaded[requesterID]
    if (requesterChar) then
        Finalize(requesterChar)
    else
        -- Requester is offline, use direct database modification
        if not ix.mysql then return end

        local query = mysql:Select("ix_characters"):Select("data"):Where("id", requesterID):Limit(1)
        query:Callback(function(result)
            if result and #result > 0 then
                local charData = util.JSONToTable(result[1].data or "{}")
                local contacts = charData.pdaContacts or {}
                for i = #contacts, 1, -1 do
                    if contacts[i].charID == acceptorID and contacts[i].pending_approval then
                        contacts[i].pending_approval = nil
                        charData.pdaContacts = contacts
                        mysql:Update("ix_characters"):Update("data", util.TableToJSON(charData)):Where("id", requesterID):Execute()
                        break
                    end
                end
            end
        end)
        query:Execute()
    end
end)

-- When a player declines a contact request
net.Receive("ixPDADeclineRequest", function(len, client)
    local requesterID = net.ReadUInt(32)
    local declinerChar = client:GetCharacter()

    if not declinerChar then return end

    local declinerID = declinerChar:GetID()

    -- 1. Remove requester from decliner's contact list (this is always local)
    local declinerContacts = declinerChar:GetData("pdaContacts", {})
    local foundOnDecliner = false
    for i = #declinerContacts, 1, -1 do
        if declinerContacts[i].charID == requesterID and declinerContacts[i].is_request then
            table.remove(declinerContacts, i)
            foundOnDecliner = true
            break
        end
    end

    if not foundOnDecliner then
        client:Notify("Could not find the incoming contact request to decline.")
        return
    end

    declinerChar:SetData("pdaContacts", declinerContacts)
    UpdateAndSendContacts(declinerChar)
    client:Notify("Contact request declined.")

    -- 2. Remove decliner from requester's contact list (requester may be offline)
    local requesterChar = ix.char.loaded[requesterID]
    if (requesterChar) then -- Requester is loaded in memory (online or recently disconnected)
        local requesterContacts = requesterChar:GetData("pdaContacts", {})
        for i = #requesterContacts, 1, -1 do
            if requesterContacts[i].charID == declinerID and requesterContacts[i].pending_approval then
                table.remove(requesterContacts, i)
                requesterChar:SetData("pdaContacts", requesterContacts)
                local requesterPlayer = requesterChar:GetPlayer()
                if IsValid(requesterPlayer) then
                    requesterPlayer:Notify(declinerChar:GetData("pdausername", declinerChar:GetName()) .. " has declined your contact request.")
                    UpdateAndSendContacts(requesterChar)
                end
                break
            end
        end
    else -- Requester is offline, use direct database modification
        if not ix.mysql then return end

        local query = mysql:Select("ix_characters"):Select("data"):Where("id", requesterID):Limit(1)
        query:Callback(function(result)
            if result and #result > 0 then
                local charData = util.JSONToTable(result[1].data or "{}")
                local contacts = charData.pdaContacts or {}
                for i = #contacts, 1, -1 do
                    if contacts[i].charID == declinerID and contacts[i].pending_approval then
                        table.remove(contacts, i)
                        charData.pdaContacts = contacts
                        mysql:Update("ix_characters"):Update("data", util.TableToJSON(charData)):Where("id", requesterID):Execute()
                        break
                    end
                end
            end
        end)
        query:Execute()
    end
end)