local PLUGIN = PLUGIN
PLUGIN.name = "Anomaly Detector"
PLUGIN.author = "some faggot, verne"
PLUGIN.desc = "Beeps when anomalies are nearby when you have an anomaly detector."

local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")

function playerMeta:hasAnomdetector()
	local char = self:GetCharacter()
	if not char then
		return false
	end

	local inventory = char:GetInventory()
	if not inventory then
		return false
	end

	for _, item in pairs(inventory:GetItems(true)) do
		if item.isAnomalydetector and item:GetData("equip") and item:GetData("durability", 0) > 0 then
			return true
		end
	end

	return false
end

function PLUGIN:PostPlayerLoadout(client)
	if client:GetData("ixhasanomdetector", false) then
		client:SetNetVar("ixhasanomdetector", true)
	end
end

local thinktime = 0

function PLUGIN:Think()
	if thinktime > CurTime() then return end
	thinktime = CurTime()
	
	for k,v in pairs(player.GetAll()) do
		if v.LastBeep == nil then 
			v.LastBeep = 0 
		end

		if IsValid(v) then
			if v:hasAnomdetector() then
				local anoms = {}
				local dist = 1000
				for j,b in pairs(ents.FindInSphere(v:GetPos(), 425)) do
					if string.sub(b:GetClass(),1,4) == "anom" or string.sub(b:GetClass(),1,6) == "kometa" then
						table.insert(anoms, b)
					end
				end

				for j,b in pairs(anoms) do
					if v:GetPos():Distance(b:GetPos()) < dist then
						dist = v:GetPos():Distance(b:GetPos())
					end
				end

				if dist < 900 then
					if v.LastBeep + dist/800 - CurTime() <= 0 then
						v.LastBeep = CurTime()
						local randomsound = "stalkerdetectors/anom_prox.wav"
						v:EmitSound(randomsound)
					end
				end
			end
		end
	end
end