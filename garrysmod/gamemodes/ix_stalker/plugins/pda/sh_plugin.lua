PLUGIN.name = "PDA chatting system"
PLUGIN.author = "Verne & Taylor"
PLUGIN.description = "PDA chatting system, supporting avatars and usernames."

ix.util.Include("cl_plugin.lua")

ix.option.Add("PDAvolume", ix.type.number, 1, {
	category = "PDA",
	min = 0,
	max = 1,
	decimals = 2
})

ix.option.Add("GPDAvolume", ix.type.number, 1, {
	category = "PDA",
	min = 0,
	max = 1,
	decimals = 2
})

ix.option.Add("PDAInChat", ix.type.bool, true, {
	category = "PDA"
})

ix.lang.AddTable("english", {
	optPDAvolume = "PDA volume",
	optdPDAvolume = "Adjusts the volume of the PDA notification sounds.",
	optPDAvolume = "PDA volume",
	optdPDAvolume = "Adjusts the volume of the private PDA notification sounds.",
	optGPDAvolume = "Global PDA volume",
	optdGPDAvolume = "Adjusts the volume of the global PDA notification sounds.",
	optPDAInChat = "PDA in chatbox",
	optdPDAInChat = "Toggles whether PDA messages appear in the chatbox."
})

ix.chat.Register("gpda", {
	CanSay = function(self, speaker, text)
		local pda = speaker:GetCharacter():GetData("pdaequipped", false)
		return pda
	end,
	OnChatAdd = function(self, speaker, text, bAnonymous, data)
		if (ix.option.Get("PDAInChat", true)) then
			chat.AddText(Color(0,191,255), Material(data[2]), "[GPDA-"..data[1].."]", color_white, ": "..text)
		end
		local volume = ix.option.Get("GPDAvolume", 1)
		LocalPlayer():EmitSound("stalker/pda/pda_beep_1.ogg", 50, 100, volume, CHAN_AUTO)
		hook.Run("OnGPDAMessage", data[1], text, data[2])
	end,
	CanHear = function(self, speaker, listener)
		local pda = listener:GetCharacter():GetData("pdaequipped", false)
		if pda then
			return true
		else
			return false
		end
	end,
})

ix.chat.Register("pda", {
	CanSay = function(self, speaker, text)
		local pda = speaker:GetCharacter():GetData("pdaequipped", false)
		return pda
	end,
	OnChatAdd = function(self, speaker, text, bAnonymous, data)
		if (ix.option.Get("PDAInChat", true)) then
			chat.AddText(Color(255, 180, 51), Material(data[2]), "[PDA-"..data[1].."]", color_white, ": "..text)
		end
		local volume = ix.option.Get("PDAvolume", 1)
		if (speaker != LocalPlayer()) then
			LocalPlayer():EmitSound( "stalker/pda/pda_tip.wav", 50, 100, volume, CHAN_AUTO )
		else
			LocalPlayer():EmitSound( "stalker/pda/pda_open.wav", 50, 100, volume, CHAN_AUTO )
		end
		hook.Run("OnPDAMessage", data[1], text, data[2], data[3], speaker == LocalPlayer())
	end,
	CanHear = function(self, speaker, listener)
		local pda = listener:GetCharacter():GetData("pdaequipped", false)
		return pda
	end,
})

ix.command.Add("gpda", {
	description = "Sends a message on the global PDA network.",
	arguments = ix.type.text,
	OnRun = function(self, client, text)
		ix.chat.Send(client, "gpda", text, nil, nil, {
			client:GetCharacter():GetData("pdausername") or client:GetCharacter():GetName(), client:GetCharacter():GetData("pdaavatar") or "stalker/ui/avatars/nodata.png"
		})
	end
})

ix.command.Add("pda", {
	description = "Sends a message to a specific user on the network.",
	arguments = {
		ix.type.string,
		ix.type.text
	},
	OnRun = function(self, client, target, text)
		local targetplayer = ix.util.FindPlayer(target)
		
		if not targetplayer then
			for k,v in pairs(player.GetAll()) do
				if ix.util.StringMatches(v:GetCharacter():GetData("pdausername",""),target) then
					targetplayer = v
				end
			end
		end

		if (targetplayer) then
			if (targetplayer == client) then
				return "You cannot send a message to yourself."
			end

			if (not targetplayer:GetCharacter() or not targetplayer:GetCharacter():GetData("pdaequipped", false)) then
				return "This user is offline."
			end
		else
			return "This user is offline."
		end
		
		local targetName = targetplayer:GetCharacter():GetData("pdausername") or targetplayer:GetCharacter():GetName()
		local char = client:GetCharacter()
		local contacts = char:GetData("pdaContacts", {})
		local targetID = targetplayer:GetCharacter():GetID()
		local bFound = false

		for _, v in ipairs(contacts) do
			if (type(v) == "table") then
				-- Check if ID or Name matches, and ensure status is nil (meaning request accepted/established)
				if ((v.id == targetID or v.name == targetName) and v.status == nil) then
					bFound = true
					break
				end
			elseif (v == targetName) then
				bFound = true
				break
			end
		end

		if (!bFound) then
			return "You must have this person in your contacts to message them."
		end

		ix.chat.Send(client, "pda", text, nil, {client, targetplayer}, {
			client:GetCharacter():GetData("pdausername") or client:GetCharacter():GetName(), client:GetCharacter():GetData("pdaavatar") or "stalker/ui/avatars/nodata.png", targetName
		})
	end
})

if (SERVER) then
	netstream.Hook("ixPDAContactAdd", function(client, name)
		local char = client:GetCharacter()
		if (char) then
			local contacts = char:GetData("pdaContacts", {})
			local targetChar
			
			for _, v in ipairs(player.GetAll()) do
				local c = v:GetCharacter()
				if (c) then
					local pdaName = c:GetData("pdausername") or c:GetName()
					if (pdaName == name) then
						targetChar = c
						break
					end
				end
			end

			if (targetChar) then
				if (targetChar == char) then
					client:Notify("You cannot add yourself.")
					return
				end

				local exists = false
				for _, v in ipairs(contacts) do
					if (type(v) == "table") then
						if (v.name == name or v.id == targetChar:GetID()) then
							exists = true
							break
						end
					elseif (v == name) then
						exists = true
						break
					end
				end

				if (not exists) then
					local myName = char:GetData("pdausername") or char:GetName()
					
					-- Add to sender as 'sent'
					table.insert(contacts, {id = targetChar:GetID(), name = name, status = "sent"})
					char:SetData("pdaContacts", contacts)

					-- Add to receiver as 'received'
					local targetContacts = targetChar:GetData("pdaContacts", {})
					table.insert(targetContacts, {id = char:GetID(), name = myName, status = "received"})
					targetChar:SetData("pdaContacts", targetContacts)

					netstream.Start(targetChar:GetPlayer(), "ixPDAContactRequest", client, myName)
					client:Notify("Friend request sent.")
				else
					client:Notify("Contact already exists.")
				end
			else
				client:Notify("PDA username not found.")
			end
		end
	end)

	netstream.Hook("ixPDAContactResponse", function(client, targetName, accepted)
		local char = client:GetCharacter()
		if (char) then
			local contacts = char:GetData("pdaContacts", {})
			local targetEntry, targetIndex
			
			for k, v in ipairs(contacts) do
				if (type(v) == "table" and v.name == targetName) then
					targetEntry = v
					targetIndex = k
					break
				end
			end

			if (targetEntry and targetEntry.status == "received") then
				-- Find the other player to update their list
				local targetChar
				for _, v in ipairs(player.GetAll()) do
					local c = v:GetCharacter()
					if (c and c:GetID() == targetEntry.id) then
						targetChar = c
						break
					end
				end

				if (accepted) then
					-- Update self
					targetEntry.status = nil
					char:SetData("pdaContacts", contacts)
					client:Notify("Contact added.")

					if (targetChar) then
						-- Update target
						local targetContacts = targetChar:GetData("pdaContacts", {})
						local myName = char:GetData("pdausername") or char:GetName()
						for _, v in ipairs(targetContacts) do
							if (type(v) == "table" and (v.id == char:GetID() or v.name == myName)) then
								v.status = nil
								break
							end
						end
						targetChar:SetData("pdaContacts", targetContacts)

						targetChar:GetPlayer():Notify("Contact request accepted by " .. (char:GetData("pdausername") or char:GetName()))
					end
				else
					-- Deny: Remove from self
					table.remove(contacts, targetIndex)
					char:SetData("pdaContacts", contacts)

					-- Remove from target if online
					if (targetChar) then
						local targetContacts = targetChar:GetData("pdaContacts", {})
						local myName = char:GetData("pdausername") or char:GetName()
						for k, v in ipairs(targetContacts) do
							if (type(v) == "table" and (v.id == char:GetID() or v.name == myName)) then
								table.remove(targetContacts, k)
								break
							end
						end
						targetChar:SetData("pdaContacts", targetContacts)
						targetChar:GetPlayer():Notify("Contact request denied.")
					end
				end
			end
		end
	end)

	netstream.Hook("ixPDAContactRemove", function(client, name)
		local char = client:GetCharacter()
		if (char) then
			local contacts = char:GetData("pdaContacts", {})
			local toRemove
			local targetId
			
			for k, v in ipairs(contacts) do
				if (type(v) == "table" and v.name == name) then
					toRemove = k
					targetId = v.id
					break
				elseif (v == name) then
					toRemove = k
					break
				end
			end

			if (toRemove) then
				table.remove(contacts, toRemove)
				char:SetData("pdaContacts", contacts)

				local targetChar
				if (targetId) then
					targetChar = ix.char.loaded[targetId]
				else
					for _, v in ipairs(player.GetAll()) do
						local c = v:GetCharacter()
						if (c and (c:GetData("pdausername") or c:GetName()) == name) then
							targetChar = c
							break
						end
					end
				end

				if (targetChar) then
					local targetContacts = targetChar:GetData("pdaContacts", {})
					local myName = char:GetData("pdausername") or char:GetName()
					local myId = char:GetID()
					local targetToRemove

					for k, v in ipairs(targetContacts) do
						if (type(v) == "table" and (v.id == myId or v.name == myName)) then
							targetToRemove = k
							break
						elseif (v == myName) then
							targetToRemove = k
							break
						end
					end

					if (targetToRemove) then
						table.remove(targetContacts, targetToRemove)
						targetChar:SetData("pdaContacts", targetContacts)
						
						local targetPly = targetChar:GetPlayer()
						if (IsValid(targetPly)) then
							targetPly:Notify(myName .. " has removed you from their contacts.")
						end
					end
				end
			end
		end
	end)

	netstream.Hook("ixPDAContactsRequest", function(client)
		local char = client:GetCharacter()
		if (not char) then return end

		local contacts = char:GetData("pdaContacts", {})
		local results = {}
		local bDirty = false

		-- Sync pass
		for k = #contacts, 1, -1 do
			local v = contacts[k]
			if (type(v) == "table" and v.status == "sent") then
				local targetChar = ix.char.loaded[v.id]
				local ply = targetChar and targetChar:GetPlayer()
				if (targetChar and IsValid(ply) and ply:GetCharacter() == targetChar) then
					local targetContacts = targetChar:GetData("pdaContacts", {})
					local foundEntry = nil
					for _, tc in ipairs(targetContacts) do
						if (type(tc) == "table" and tc.id == char:GetID()) then
							foundEntry = tc
							break
						end
					end

					if (foundEntry) then
						if (foundEntry.status == nil) then
							v.status = nil
							bDirty = true
						end
					else
						table.remove(contacts, k)
						bDirty = true
					end
				end
			end
		end

		for k, v in ipairs(contacts) do
			if (type(v) == "table") then
				if (v.status == "sent") then
					results[v.name] = {
						status = "Request sent",
						online = false,
						avatar = "stalker/ui/avatars/nodata.png"
					}
				elseif (v.status == "received") then
					results[v.name] = {
						status = "Incoming request",
						online = false,
						avatar = "stalker/ui/avatars/nodata.png"
					}
				else
					local targetChar = ix.char.loaded[v.id]
					local ply = targetChar and targetChar:GetPlayer()
					
					if (targetChar and IsValid(ply) and ply:GetCharacter() == targetChar and targetChar:GetData("pdaequipped", false)) then
						local currentName = targetChar:GetData("pdausername") or targetChar:GetName()
						local faction = ix.faction.indices[targetChar:GetFaction()]
						local color = faction and faction.color or Color(255, 255, 255)
						
						if (v.name != currentName) then
							v.name = currentName
							bDirty = true
						end

						results[currentName] = {
							online = true,
							avatar = targetChar:GetData("pdaavatar", "stalker/ui/avatars/nodata.png"),
							color = color
						}
					else
						results[v.name] = {
							online = false,
							avatar = "stalker/ui/avatars/nodata.png"
						}
					end
				end
			else
				local found = false
				for _, ply in ipairs(player.GetAll()) do
					local c = ply:GetCharacter()
					if (c) then
						local pdaName = c:GetData("pdausername") or c:GetName()
						if (pdaName == v) then
							contacts[k] = {id = c:GetID(), name = pdaName}
							bDirty = true
							
							local faction = ix.faction.indices[c:GetFaction()]
							local color = faction and faction.color or Color(255, 255, 255)
							
							if (c:GetData("pdaequipped", false)) then
								results[pdaName] = {
									online = true,
									avatar = c:GetData("pdaavatar", "stalker/ui/avatars/nodata.png"),
									color = color
								}
							else
								results[pdaName] = {
									online = false,
									avatar = "stalker/ui/avatars/nodata.png",
									color = color
								}
							end
							found = true
							break
						end
					end
				end

				if (not found) then
					results[v] = {
						online = false,
						avatar = "stalker/ui/avatars/nodata.png"
					}
				end
			end
		end

		if (bDirty) then
			char:SetData("pdaContacts", contacts)
		end

		netstream.Start(client, "ixPDAContactsReply", results)
	end)
end