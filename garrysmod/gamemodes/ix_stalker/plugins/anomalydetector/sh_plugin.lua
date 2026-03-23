local PLUGIN = PLUGIN
PLUGIN.name = "Anomaly Detector"
PLUGIN.author = "some faggot, verne"
PLUGIN.desc = "Beeps when anomalies are nearby when you have an anomaly detector."

local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")

function playerMeta:hasAnomdetector()
	return self:GetNetVar("ixhasanomdetector", false)
end

function PLUGIN:StartDetectorTimer(client)
	if (!IsValid(client)) then return end

	local timerID = "ixAnom_" .. client:SteamID64()

	timer.Create(timerID, 0.5, 0, function()
		if (!IsValid(client) or !client:Alive()) then
			timer.Remove(timerID)
			return
		end

		local pos = client:GetPos()
		local closestDist = 1000

		for _, ent in pairs(ents.FindInSphere(pos, 425)) do
			local class = ent:GetClass()
			if (string.sub(class, 1, 4) == "anom" or string.sub(class, 1, 6) == "kometa") then
				local dist = pos:Distance(ent:GetPos())
				if (dist < closestDist) then
					closestDist = dist
				end
			end
		end

		if (closestDist < 900) then
			client:EmitSound("stalkerdetectors/anom_prox.wav")
			timer.Adjust(timerID, closestDist / 800, 0)
		else
			timer.Adjust(timerID, 0.5, 0)
		end
	end)
end

function PLUGIN:StopDetectorTimer(client)
	if (!IsValid(client)) then return end

	timer.Remove("ixAnom_" .. client:SteamID64())
end

function PLUGIN:PostPlayerLoadout(client)
	self:StopDetectorTimer(client)
	client:SetNetVar("ixhasanomdetector", false)
	client:SetData("ixhasanomdetector", false)

	timer.Simple(0, function()
		if (!IsValid(client)) then return end

		local character = client:GetCharacter()
		if (!character) then return end

		local inventory = character:GetInventory()
		if (!inventory) then return end

		local hasEquipped = false
		for _, item in pairs(inventory:GetItems()) do
			if (item.isAnomalydetector and item:GetData("equip")) then
				hasEquipped = true
				break
			end
		end

		client:SetNetVar("ixhasanomdetector", hasEquipped)
		client:SetData("ixhasanomdetector", hasEquipped)

		if (hasEquipped) then
			self:StartDetectorTimer(client)
		end
	end)
end

function PLUGIN:PlayerDeath(client)
	self:StopDetectorTimer(client)
	client:SetNetVar("ixhasanomdetector", false)
	client:SetData("ixhasanomdetector", false)
end

function PLUGIN:CharacterLoaded(character)
	local client = character:GetPlayer()
	if (!IsValid(client)) then return end

	self:StopDetectorTimer(client)

	if (client.SetNetVar) then
		client:SetNetVar("ixhasanomdetector", false)
	end
	if (client.SetData) then
		client:SetData("ixhasanomdetector", false)
	end
end

function PLUGIN:PlayerDisconnected(client)
	self:StopDetectorTimer(client)
end