local PLUGIN = PLUGIN
PLUGIN.name = "Radiation"
PLUGIN.author = "Lt. Taylor & Zeta, refactor by Ghost."
PLUGIN.desc = "Radiation System"

ix.config.Add("radDamageLight", 0.5, "Damage per tick for light radiation zones.", nil, {
	category = "Radiation",
	type = ix.type.number,
	data = {min = 0, max = 20, decimals = 2}
})

ix.config.Add("radDamageModerate", 1, "Damage per tick for moderate radiation zones.", nil, {
	category = "Radiation",
	type = ix.type.number,
	data = {min = 0, max = 20, decimals = 2}
})

ix.config.Add("radDamageHeavy", 2.5, "Damage per tick for heavy radiation zones.", nil, {
	category = "Radiation",
	type = ix.type.number,
	data = {min = 0, max = 20, decimals = 2}
})

ix.config.Add("radNaturalDecay", 0.25, "Radiation removed per second naturally when outside radiation zones. Set to 0 to disable.", nil, {
	category = "Radiation",
	type = ix.type.number,
	data = {min = 0, max = 5, decimals = 2}
})

ix.config.Add("radDecayScaling", 33, "Decay scaling divisor. Lower = faster decay at high radiation. Only applies above 25 rads. Set to 0 to disable scaling.", nil, {
	category = "Radiation",
	type = ix.type.number,
	data = {min = 0, max = 100, decimals = 0}
})

local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")

function playerMeta:getRadiation()
	return (self:GetNetVar("AccumRads")) or 0
end

function playerMeta:getRadiationPercent()
	return math.Clamp(self:getRadiation()/100, 0, 1)
end

function playerMeta:addRadiation(amount)
	local curRadiation = self:getRadiation()
	self:SetNetVar("AccumRads",	math.Clamp(math.min(curRadiation) + amount, 0, 100))
end

function playerMeta:setRadiation(amount)
	self:SetNetVar("AccumRads", math.Clamp(amount, 0, 100))
end

function playerMeta:hasGeiger()
	return self:GetNetVar("ixhasgeiger", false)
end

function playerMeta:getRadProtection()
	local protection = 0

	if ix.plugin.list["buffs"] then
		protection = protection + self:GetNetVar("ix_radprot", 0)
	end

	return protection
end

function PLUGIN:EntityTakeDamage(entity, dmgInfo)
    -- RADIATION OVERRIDE
    if (entity:IsPlayer() and dmgInfo:IsDamageType(DMG_RADIATION)) then
        local radDamage = dmgInfo:GetDamage()
        local inflictor = dmgInfo:GetInflictor()

        -- Calculate total radiation resistance from equipped items and artifacts
        local char = entity:GetCharacter()
        local items = char:GetInventory():GetItems(true)
        local totalRadResist = 0
        local hasGasmask = false
        
        for _, item in pairs(items) do
            if (item.isArmor or item.isGasmask or item.isHelmet or item.isArtefact) and item:GetData("equip") then
                totalRadResist = totalRadResist + (item.res and item.res["Radiation"] or 0)
                if (item.isGasmask) then
                    hasGasmask = true
                end
            end
        end

        -- Add buff resistance
        totalRadResist = totalRadResist + (entity:GetNetVar("ix_radprot", 0) / 100)

        -- Clamp totalRadResist to ensure it does not exceed 1
        totalRadResist = math.Clamp(totalRadResist, 0, 1)

        -- Apply radiation resistance to radDamage
        local effectiveRadDamage = radDamage * (1 - totalRadResist) * 10
        
        -- Armor Durability Reduction
        if ix.config.Get("Armor Durability") then
            for _, item in pairs(items) do
                if (item.isArmor or item.isGasmask or item.isHelmet) and item:GetData("equip") then
                    local curDura = item:GetData("durability", 10000)
                    local duraDamage = effectiveRadDamage
                    local newDura = math.Clamp(curDura - duraDamage, 0, 10000) -- Clamp to maximum durability
                    item:SetData("durability", newDura)
                end
            end
        end

        local bApplyRadiation = true

        if (IsValid(inflictor)) then
            local class = inflictor:GetClass()

            if (string.find(class, "rad_light")) then
                if (hasGasmask and totalRadResist >= 0.4) then
                    bApplyRadiation = false
                end
            elseif (string.find(class, "rad_moderate")) then
                if (hasGasmask and totalRadResist >= 0.7) then
                    bApplyRadiation = false
                end
            elseif (string.find(class, "rad_heavy")) then
                if (hasGasmask and totalRadResist >= 2.0) then
                    bApplyRadiation = false
                end
            end
        end

        if (bApplyRadiation) then
            entity:addRadiation(math.Clamp(radDamage * (1 - totalRadResist), 0, 100))	-- Accumulated radiation the player gets
        end

        dmgInfo:SetDamage(0)
    end
end

ix.option.Add("RadScreenNoise", ix.type.bool, true, {
	category = "STALKER Settings"
})

ix.lang.AddTable("english", {
	optRadScreenNoise = "Radiation screen noise",
	optdRadScreenNoise = "Enable or disable screen noise caused by radiation."
})

-- Register HUD Bars.
if (CLIENT) then
	local color = Color(39, 174, 96)
	local vignette = Material("helix/gui/vignette.png")
	local noiseTextures = {
		"stalkerAnomaly/ui/screen_noise/screen_noise1.png",
		"stalkerAnomaly/ui/screen_noise/screen_noise2.png",
		"stalkerAnomaly/ui/screen_noise/screen_noise3.png",
		"stalkerAnomaly/ui/screen_noise/screen_noise4.png",
		"stalkerAnomaly/ui/screen_noise/screen_noise5.png",
		"stalkerAnomaly/ui/screen_noise/screen_noise6.png"
	}

	function PLUGIN:RenderScreenspaceEffects()
		local client = LocalPlayer()
		if (!IsValid(client)) then return end

		if (client:getRadiation() > 45 and client:getRadiation() < 75) then
			DrawMotionBlur(0.05, 0.15, 0.001)
		elseif(client:getRadiation() > 75) then
			DrawMotionBlur(0.1, 0.3, 0.001)
		end

		if (ix.option.Get("RadScreenNoise", true)) then
			local maxIntensity = 0
			local clientPos = client:GetPos()

			for _, v in ipairs(ents.FindByClass("rad_*")) do
				local range = v:GetNWInt("Range", 256)
				local dist = clientPos:Distance(v:GetPos())

				if (dist < range) then
					local tr = util.TraceLine({
						start = v:GetPos() + Vector(0, 0, 10),
						endpos = client:WorldSpaceCenter(),
						filter = {v, client},
						mask = MASK_SOLID_BRUSHONLY
					})

					if (tr.Hit) then continue end

					local intensity = 1 - (dist / range)
					if (intensity > maxIntensity) then
						maxIntensity = intensity
					end
				end
			end

			if (maxIntensity > 0) then
				local frame = math.floor(RealTime() * 15) % #noiseTextures + 1
				local material = Material(noiseTextures[frame])
				cam.Start2D()
					surface.SetDrawColor(200, 180, 0, maxIntensity * 255)
					surface.SetMaterial(material)
					surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

					surface.SetDrawColor(120, 100, 0, maxIntensity * 200)
					surface.SetMaterial(vignette)
					surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
				cam.End2D()
			end
		end
    end
else
	local PLUGIN = PLUGIN
	local nextDecayTick = 0

	function PLUGIN:Think()
		if nextDecayTick > CurTime() then return end
		nextDecayTick = CurTime() + 1

		local decayRate = ix.config.Get("radNaturalDecay", 0.25)
		if decayRate <= 0 then return end

		for _, v in ipairs(player.GetAll()) do
			if not v:Alive() or not v:GetCharacter() then continue end

			local rads = v:getRadiation()
			if rads <= 0 then continue end

			local inZone = false
			for _, ent in ipairs(ents.FindInSphere(v:GetPos(), 4096)) do
				if string.sub(ent:GetClass(), 1, 4) == "rad_" then
					local range = ent:GetNWInt("Range", 256)
					if v:GetPos():Distance(ent:GetPos()) <= range then
						inZone = true
						break
					end
				end
			end

			if not inZone then
				local scaleDivisor = ix.config.Get("radDecayScaling", 33)
				local scale = (scaleDivisor > 0 and rads > 25) and (1 + (rads / scaleDivisor)) or 1
				v:addRadiation(-decayRate * scale)
			end
		end
	end

	function PLUGIN:CharacterPreSave(character)
		local savedRads = math.Clamp(character.player:getRadiation(), 0, 100)
		character:SetData("radiation", savedRads)
	end

	function PLUGIN:PostPlayerLoadout(client)
		local character = client:GetCharacter()
		if (!character) then return end

		if (character:GetData("radiation")) then
			client:SetNetVar("AccumRads", character:GetData("radiation"))
		else
			client:SetNetVar("AccumRads", 0)
		end

		local inventory = character:GetInventory()
		if (inventory) then
			local hasGeiger = false
			for _, item in pairs(inventory:GetItems()) do
				if (item.isGeiger and item:GetData("equip")) then
					hasGeiger = true
					break
				end
			end

			client:SetNetVar("ixhasgeiger", hasGeiger)
			client:SetData("ixhasgeiger", hasGeiger)
		end
	end

	function PLUGIN:PlayerDeath(client)
		client.resetRads = true
		client:SetNetVar("ixhasgeiger", false)
		client:SetData("ixhasgeiger", false)
	end

	function PLUGIN:CharacterLoaded(character)
		local client = character:GetPlayer()
		if (!IsValid(client)) then return end

		client:SetNetVar("ixhasgeiger", false)
		client:SetData("ixhasgeiger", false)
	end

	function PLUGIN:PlayerSpawn(client)
		if (client.resetRads) then
			client:SetNetVar("AccumRads", 0)
			client.resetRads = false
		end
	end
end

ix.command.Add("charsetradiation", {
	adminOnly = true,
	arguments = {
		ix.type.player,
		ix.type.number,
	},
	OnRun = function(self, client, target, radiation)
		local radiation = tonumber(radiation)
		target:setRadiation(radiation)

		if client == target then
            client:Notify("You have set your radiation to "..radiation)
        else
            client:Notify("You have set "..target:Name().."'s radiation to "..radiation)
            target:Notify(client:Name().." has set your radiation to "..radiation)
        end
	end
})

properties.Add("ixRadRange", {
	MenuLabel = "Set Range",
	Order = 400,
	MenuIcon = "icon16/arrow_out.png",

	Filter = function(self, ent, ply)
		if (!IsValid(ent)) then return false end
		if (!string.find(ent:GetClass(), "rad_")) then return false end
		if (!gamemode.Call("CanProperty", ply, "ixRadRange", ent)) then return false end

		return ply:IsAdmin()
	end,

	Action = function(self, ent)
		Derma_StringRequest("Set Range", "Enter the new range for this radiation zone:", ent:GetNWInt("Range", 256), function(text)
			self:MsgStart()
				net.WriteEntity(ent)
				net.WriteFloat(tonumber(text) or 256)
			self:MsgEnd()
		end)
	end,

	Receive = function(self, length, ply)
		local ent = net.ReadEntity()
		local range = net.ReadFloat()

		if (!IsValid(ent)) then return end
		if (!self:Filter(ent, ply)) then return end

		ent:SetNWInt("Range", range)
		ply:Notify("Radiation range set to " .. range)
	end
})