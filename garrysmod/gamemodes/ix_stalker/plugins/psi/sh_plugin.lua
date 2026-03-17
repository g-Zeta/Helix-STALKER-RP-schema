local PLUGIN = PLUGIN
PLUGIN.name = "PsyHealth and Psi-field System"
PLUGIN.author = "gumlefar & Zeta"
PLUGIN.description = "A Psi system akin to the STALKER games."

ix.config.Add("PsyHealthRecoverTime", 10, "How many seconds it takes to restore 1 percent PsyHealth.", nil, {
	data = {min = 1, max = 36},
	category = "Psy"
})
/*
ix.config.Add("MaxHallucinations", 3, "The maximum number of hallucinations a player can have at once.", nil, {
	data = {min = 1, max = 10},
	category = "Psy"
})

ix.config.Add("HallucinationMinDistance", 250, "The minimum distance a hallucination can spawn from the player.", nil, {
	data = {min = 100, max = 2000},
	category = "Psy"
})

ix.config.Add("HallucinationMaxDistance", 350, "The maximum distance a hallucination can spawn from the player.", nil, {
	data = {min = 100, max = 2000},
	category = "Psy"
})

ix.config.Add("HallucinationRemoveDistance", 1000, "The distance at which a hallucination is removed from the player.", nil, {
	data = {min = 500, max = 3000},
	category = "Psy"
})

ix.config.Add("HallucinationMinSpawnTime", 5, "The minimum time in seconds between hallucination spawn attempts.", nil, {
	data = {min = 1, max = 30},
	category = "Psy"
})

ix.config.Add("HallucinationMaxSpawnTime", 15, "The maximum time in seconds between hallucination spawn attempts.", nil, {
	data = {min = 1, max = 60},
	category = "Psy"
})

ix.config.Add("HallucinationSpeed", 80, "The movement speed of hallucinations.", nil, {
	data = {min = 30, max = 200},
	category = "Psy"
})

ix.config.Add("HallucinationWeapon", "none", "The weapon class the hallucination NPC will spawn with.", nil, {
	category = "Psy"
})

ix.config.Add("HallucinationNPCs", "npc_metropolice,npc_combine_s", "The NPC classes that can spawn as hallucinations, separated by commas.", nil, {
	category = "Psy"
})
*/
ix.char.RegisterVar("PsyHP", {
	field = "PsyHP",
	fieldType = ix.type.number,
	default = 100,
	bNoDisplay = true,
})

function ix.util.mapValueToRange(valToMap, origMinRange, origMaxRange, newMinRange, newMaxRange)
	return ((valToMap - origMinRange) * (newMaxRange - newMinRange) / (origMaxRange - origMinRange) + newMinRange);
end

local entityMeta = FindMetaTable("Entity")

if SERVER then
	function PLUGIN:OnCharacterCreated(client, character)
		character:SetPsyHP(100)
	end

	function PLUGIN:PlayerLoadedCharacter(client, character)
		timer.Simple(0.25, function()
			client:SetLocalVar("psyhealth", character:GetPsyHP())
			
		end)

		timer.Simple(1, function()
			client:UpdatePsyHealthState(client)
		end)
	end

	function PLUGIN:CharacterPreSave(character)
		local client = character:GetPlayer()

		if (IsValid(client)) then
			character:SetPsyHP(client:GetLocalVar("psyhealth", 0))
		end
	end

	local playerMeta = FindMetaTable("Player")

	function playerMeta:DamagePsyHealth(amount)
		local char = self:GetCharacter()

		if (char) then
			char:SetPsyHP(char:GetPsyHP() - amount)
			self:SetLocalVar("psyhealth", char:GetPsyHP() - amount)

			if (amount > 0) then
				self:SetNetVar("psyhealthtick", CurTime() + ix.config.Get("PsyHealthRecoverTime", 10))
			end
		end
	end

	function playerMeta:HealPsyHealth(amount)
		self:DamagePsyHealth(-amount)
	end

	function playerMeta:SetPsyHealth(amount)
		local char = self:GetCharacter()

		if (char) then
			char:SetPsyHP(amount)
			self:SetLocalVar("psyhealth", amount)
		end
	end

	function playerMeta:TickPsyHealth(amount)
		local char = self:GetCharacter()

		if (char) then
			char:SetPsyHP(char:GetPsyHP() + amount)
			self:SetLocalVar("psyhealth", char:GetPsyHP() + amount)

			if char:GetPsyHP() > 100 then
				char:SetPsyHP(100)
				self:SetLocalVar("psyhealth", 100)
			end
			self:UpdatePsyHealthState(self)
		end
	end

	local TEMP_CAMSHAKENUM = 0
	local TEMP_CAMSHAKESIDE = -1

	function PLUGIN:RemoveHallucination(npc)
		if (IsValid(npc)) then
			npc:SetNotSolid(true)
			npc:SetMoveType(MOVETYPE_NONE)
			npc:SetRenderMode(RENDERMODE_TRANSCOLOR)

			local alpha = npc:GetColor().a
			local steps = 20
			local interval = 0.05
			local decrement = alpha / steps
			local uniqueID = "ixHallucinationFade" .. npc:EntIndex()

			timer.Create(uniqueID, interval, steps, function()
				if (IsValid(npc)) then
					local color = npc:GetColor()
					color.a = math.max(0, color.a - decrement)
					npc:SetColor(color)

					if (color.a <= 0) then
						npc:Remove()
					end
				else
					timer.Remove(uniqueID)
				end
			end)
		end
	end

	function PLUGIN:KillHallucination(npc)
		if (IsValid(npc)) then
			local effectData = EffectData()
			effectData:SetStart(npc:GetPos())
			effectData:SetOrigin(npc:GetPos() + npc:OBBCenter())
			effectData:SetScale(12)

			if (IsValid(npc.ixHallucinationOwner)) then
				local filter = RecipientFilter()
				filter:AddPlayer(npc.ixHallucinationOwner)
				util.Effect("GlassImpact", effectData, true, filter)

				local deathSounds = {
					"stalker2/psi/psy_phantomdeath1.mp3",
					"stalker2/psi/psy_phantomdeath2.mp3",
					"stalker2/psi/psy_phantomdeath3.mp3"
				}
				local soundToPlay = table.Random(deathSounds)
				npc.ixHallucinationOwner:EmitSound(soundToPlay)
			end

			local wep = npc:GetActiveWeapon()
			if (IsValid(wep)) then
				wep:Remove()
			end
			npc:Remove()
		end
	end
	
	function PLUGIN:SpawnHallucination(client)
		if (!IsValid(client) or !client:Alive()) then return end
		
		client.ixHallucinations = client.ixHallucinations or {}
		
		for i = #client.ixHallucinations, 1, -1 do
			if (!IsValid(client.ixHallucinations[i])) then
				table.remove(client.ixHallucinations, i)
			end
		end

		local count = 1
		if (math.random() < 0.3) then	-- Chance of spawning more than 1 hallucination
			count = 2					-- Number of hallucinations to spawn if above condition is met
		end

		for i = 1, count do
			if (#client.ixHallucinations >= ix.config.Get("MaxHallucinations", 3)) then return end

			local pos = client:GetPos()
			local ang = Angle(0, math.random(0, 360), 0) -- Direction: the angle the hallucination spawns from the player's sight
			local minDist = ix.config.Get("HallucinationMinDistance", 250)
			local maxDist = ix.config.Get("HallucinationMaxDistance", 350)
			local spawnPos = pos + ang:Forward() * math.random(minDist, maxDist) + Vector(0,0,20) -- Distance: how far away the hallucination spawns from the player in Source units

			local tr = util.TraceLine({
				start = pos + Vector(0,0,20),
				endpos = spawnPos,
				filter = client
			})
			
			if (tr.Hit) then spawnPos = tr.HitPos + tr.HitNormal * 32 end

			local npcList = ix.config.Get("HallucinationNPCs", "npc_metropolice,npc_combine_s")
			local npcs = string.Explode(",", npcList)
			local npcClass = string.Trim(table.Random(npcs))

			local npc = ents.Create(npcClass)
			if (IsValid(npc)) then
				npc:SetPos(spawnPos)
				npc:SetAngles(Angle(0, (client:GetPos() - spawnPos):Angle().y, 0))
				npc:Spawn()
				npc:Activate()
				npc:SetBloodColor(DONT_BLEED)
				npc:SetHealth(1)
				npc:SetMaxHealth(1)
				npc:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				npc:SetNPCState(NPC_STATE_SCRIPT)
				npc:SetMoveType(MOVETYPE_NOCLIP)
				npc:DrawShadow(false)
				local weapon = ix.config.Get("HallucinationWeapon", "none")
				npc:Give(weapon)
				npc:SetRenderMode(RENDERMODE_TRANSCOLOR)
				npc:SetColor(Color(255, 255, 255, 200))	-- Set hallucination color and transparency

				local wep = npc:GetActiveWeapon()
				if (IsValid(wep)) then
					wep:SetRenderMode(RENDERMODE_TRANSCOLOR)
					wep:SetColor(Color(255, 255, 255, 200))
				end
				
				npc.ixHallucinationOwner = client
				npc:SetCustomCollisionCheck(true)
				
				for _, v in ipairs(player.GetAll()) do
					if (v != client) then
						npc:SetPreventTransmit(v, true)
						npc:AddEntityRelationship(v, D_NU, 99)
					end
				end
				npc:EmitSound("stalker2/psi/psy_phantomspawn.mp3")	-- Play hallucination sound on spawn
				
				table.insert(client.ixHallucinations, npc)
			end
		end
	end

	function PLUGIN:PlayerTick(ply)
		if ply:GetNetVar("psyhealthtick", 0) <= CurTime() then
			ply:SetNetVar("psyhealthtick", ix.config.Get("PsyHealthRecoverTime", 10) + CurTime())
			ply:TickPsyHealth(1)
		end

		--[[
		local psyHealth = ply:GetPsyHealth() or 100 -- Default to 100 if nil

		if (psyHealth < 85) then
			if (ply.ixHallucinations) then
				for i = #ply.ixHallucinations, 1, -1 do
					local ent = ply.ixHallucinations[i]
					if (IsValid(ent)) then
						local speed = ix.config.Get("HallucinationSpeed", 80)
						local targetPos = ply:GetPos()
						local dir = (targetPos - ent:GetPos()):GetNormalized()

						ent:SetLocalVelocity(dir * speed)
						ent:SetAngles(dir:Angle())

						if (ent:GetPos():DistToSqr(targetPos) < 3600) then
							ply:TakeDamage(10, ent, ent)
							self:KillHallucination(ent)
							table.remove(ply.ixHallucinations, i)
							continue
						end

						local removeDist = ix.config.Get("HallucinationRemoveDistance", 1000)
						if (ent:GetPos():DistToSqr(ply:GetPos()) > (removeDist * removeDist)) then
							self:RemoveHallucination(ent)
							table.remove(ply.ixHallucinations, i)
						end
					else
						table.remove(ply.ixHallucinations, i)
					end
				end
			end

			-- Spawn time check for hallucinations
			ply.ixNextHallucinationCheck = ply.ixNextHallucinationCheck or 0
			if (CurTime() > ply.ixNextHallucinationCheck) then
				local minTime = ix.config.Get("HallucinationMinSpawnTime", 5)
				local maxTime = ix.config.Get("HallucinationMaxSpawnTime", 10)
				ply.ixNextHallucinationCheck = CurTime() + math.random(minTime, maxTime)
				self:SpawnHallucination(ply)
			end
		elseif (ply.ixHallucinations and #ply.ixHallucinations > 0) then
			for k, v in pairs(ply.ixHallucinations) do
				if (IsValid(v)) then
					self:RemoveHallucination(v)
				end
			end
			ply.ixHallucinations = {}
		end
		--]]
	end

	function playerMeta:UpdatePsyHealthState(client)

		if (self:GetNetVar("ix_psysuppressed", false)) then return end --if psysuppressed, we dont do anything
		--Do whatever PsyHealth will do in here
	end
end



local playerMeta = FindMetaTable("Player")

function playerMeta:GetPsyHealth()
	local char = self:GetCharacter()

	if (char) then
		return self:GetLocalVar("psyhealth", 100)
	end
end

function playerMeta:GetPsyResist()
	if (self:HasBuff("buff_psyprotect")) then
		return 100
	end

	local psyBlock = self:GetNetVar("ix_psyblock", 0)

	if (psyBlock >= 100) then
		return 100
	end

	local res = 0
	local char = self:GetCharacter()
	local items = char:GetInventory():GetItems(true)

	for j, i in pairs(items) do
		if (i.psyProt and i:GetData("equip") == true) then
			res = res + i.psyProt
			break
		end
	end

	res = res + psyBlock

	return res
end

function PLUGIN:PreDrawHUD()
	local lp = LocalPlayer()
	local wep = LocalPlayer():GetActiveWeapon()
	local char = lp:GetCharacter()

	if (!lp:GetCharacter() or !lp:Alive() or ix.gui.characterMenu:IsVisible()) then return end

	if (lp:GetNWBool("ix_psysuppressed")) then return end

	local psydmgPre = (100 - lp:GetPsyHealth())

	if(lp:GetNetVar("ix_psysuppressed", false)) then psydmgPre = psydmgPre/2 end

	if psydmgPre > 5 then
		local psydmg = math.Clamp((ix.util.mapValueToRange(psydmgPre,5,100,0,100)/100),0,1)

		local tab = {
			[ "$pp_colour_addr" ] = 0.01*(psydmg*2),
			[ "$pp_colour_addg" ] = 0.02*(psydmg*2),
			[ "$pp_colour_addb" ] = 0.3*(psydmg*2),
			[ "$pp_colour_brightness" ] = -0.33*(psydmg*2),
			[ "$pp_colour_contrast" ] = 1-(0.22*(psydmg*2)),
			[ "$pp_colour_colour" ] = 1-(0.7*(psydmg*2)),
		}

		DrawColorModify( tab )
				
		DrawMotionBlur( 0.3, 0.9*(psydmg*2), 0.001 )

		if psydmgPre > 75 then
			local shakeval = ix.util.mapValueToRange(psydmg,0.75,1,0,1)
			util.ScreenShake( LocalPlayer():GetPos(), shakeval*7, shakeval*2, 0.2, 5 )
		end
				
		local TEMP_BLUR = Material("pp/blurscreen")
		cam.Start2D()
			local psyHealth = lp:GetPsyHealth() or 100
			local maxAlpha = 255
			local minAlpha = 100			
			local heartbeatSpeed
			-- Set heartbeatSpeed based on psyHealth stages
			if psyHealth > 80 then
				heartbeatSpeed = 1.5 -- slower
			elseif psyHealth > 60 then
				heartbeatSpeed = 2
			elseif psyHealth > 40 then
				heartbeatSpeed = 3
			elseif psyHealth > 20 then
				heartbeatSpeed = 4
			elseif psyHealth > 10 then
				heartbeatSpeed = 5
			else
				heartbeatSpeed = 6 -- faster
			end

			local time = CurTime() * heartbeatSpeed
			local alpha = math.abs(math.sin(time)) * (maxAlpha - minAlpha) + minAlpha
			local pulseSize = 1 + (math.abs(math.sin(time)) * 0.015)

			local x, y = 0, 0
			local scrW, scrH = ScrW(), ScrH()
			local x, y = scrW / 2, scrH / 2 -- Center the effect on the screen
			surface.SetDrawColor(255, 255, 255, alpha)
			surface.SetMaterial( TEMP_BLUR )
					
			for i = 1, 3 do
				TEMP_BLUR:SetFloat("$blur", (psydmg*3) * math.abs(math.sin(time)))
				TEMP_BLUR:Recompute()
				render.UpdateScreenEffectTexture()
				--surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
				surface.DrawTexturedRect(x - (scrW * pulseSize / 2), y - (scrH * pulseSize / 2), scrW * pulseSize, scrH * pulseSize)
			end
		cam.End2D()
	end
end

ix.command.Add("CharSetPsyHealth", {
	adminOnly = true,
	arguments = {
		ix.type.string,
		ix.type.number,
	},
	OnRun = function(self, client, target, psyhealth)
		local target = ix.util.FindPlayer(target)
		local psyhealth = tonumber(psyhealth)
		
		if !target then
			client:Notify("Invalid Target!")
			return
		end
		target:SetPsyHealth(psyhealth)

		if client == target then
            client:Notify("You have set your psyhealth to "..psyhealth)
        else
            client:Notify("You have set "..target:Name().."'s psyhealth to "..psyhealth)
            target:Notify(client:Name().." has set your psyhealth to "..psyhealth)
        end
        target:UpdatePsyHealthState(target)
	end
})

function PLUGIN:EntityTakeDamage(entity, dmgInfo)
	--SONIC OVERRIDE
	if ( entity:IsPlayer() and dmgInfo:IsDamageType(DMG_SONIC)) then
		local dmgAmount = dmgInfo:GetDamage()
		local psyResist = entity:GetPsyResist()
		
		entity:DamagePsyHealth(math.Clamp(dmgAmount * ((100 - psyResist) / 100), 0, 100))
		dmgInfo:SetDamage(0)
	end

	local attacker = dmgInfo:GetAttacker()
	if (entity.ixHallucinationOwner) then
		self:KillHallucination(entity)
		dmgInfo:SetDamage(0)
		return true
	end

	if (IsValid(attacker) and attacker.ixHallucinationOwner) then
		if (entity == attacker.ixHallucinationOwner) then
			dmgInfo:SetDamage(0)
			entity:DamagePsyHealth(1)
		else
			dmgInfo:SetDamage(0)
		end
 	end
end

if (SERVER) then
	function PLUGIN:PlayerDeath(client)
		client.resetPsyHealth = true
		
		if (client.ixHallucinations) then
			for k, v in pairs(client.ixHallucinations) do
				if (IsValid(v)) then v:Remove() end
			end
			client.ixHallucinations = {}
		end
	end

	function PLUGIN:PlayerSpawn(client)
		if (client.resetPsyHealth) then
			client:SetPsyHealth(100,client:GetPsyHealth())
			client.resetPsyHealth = nil
		end
	end

	function PLUGIN:OnNPCSpawned(npc)
		-- If the spawned NPC is a hallucination...
		if (npc.ixHallucinationOwner) then
			-- ...make it neutral to all other NPCs.
			for _, otherNPC in ipairs(ents.FindByClass("npc_*")) do
				if (otherNPC != npc) then
					npc:AddEntityRelationship(otherNPC, D_NU, 99)
					otherNPC:AddEntityRelationship(npc, D_NU, 99)
				end
			end
		-- If the spawned NPC is a regular NPC...
		else
			-- ...make it neutral to all existing hallucinations.
			for _, ply in ipairs(player.GetAll()) do
				if (ply.ixHallucinations) then
					for _, hallucination in pairs(ply.ixHallucinations) do
						if (IsValid(hallucination)) then
							npc:AddEntityRelationship(hallucination, D_NU, 99)
							hallucination:AddEntityRelationship(npc, D_NU, 99)
						end
					end
				end
			end
		end
	end

	function PLUGIN:OnNPCKilled(npc, attacker, inflictor)
		if (npc.ixHallucinationOwner) then
			self:KillHallucination(npc)
		end
	end

	function PLUGIN:EntityEmitSound(t)
		if (IsValid(t.Entity) and t.Entity.ixHallucinationOwner) then
			if (!string.find(t.SoundName, "psy_phantomspawn")) then
				return false
			end
		end
	end

	function PLUGIN:ShouldCollide(ent1, ent2)
		if (ent1.ixHallucinationOwner and ent2:IsPlayer() and ent1.ixHallucinationOwner != ent2) then
			return false
		end
		if (ent2.ixHallucinationOwner and ent1:IsPlayer() and ent2.ixHallucinationOwner != ent1) then
			return false
		end
	end

	function PLUGIN:PlayerInitialSpawn(client)
		for _, ply in ipairs(player.GetAll()) do
			if (ply.ixHallucinations) then
				for _, npc in pairs(ply.ixHallucinations) do
					if (IsValid(npc) and ply != client) then
						npc:SetPreventTransmit(client, true)
						npc:AddEntityRelationship(client, D_NU, 99)
					end
				end
			end
		end
	end
end

properties.Add("ixPsiFieldRange", {
	MenuLabel = "Set Range",
	Order = 400,
	MenuIcon = "icon16/arrow_out.png",

	Filter = function(self, ent, ply)
		if (!IsValid(ent)) then return false end
		if (!string.find(ent:GetClass(), "psi_field")) then return false end
		if (!gamemode.Call("CanProperty", ply, "ixPsiFieldRange", ent)) then return false end

		return ply:IsAdmin()
	end,

	Action = function(self, ent)
		Derma_StringRequest("Set Range", "Enter the new range for this psi-field:", ent:GetNWInt("Range", 256), function(text)
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
		ply:Notify("Psi-field range set to " .. range)
	end
})

if CLIENT then
	local psiSound1
	local psiSound2
	local nextWhisperTime = 0
	local whisperSounds = {
		"stalker2/psi/psy_whispers1.mp3",
		"stalker2/psi/psy_whispers2.mp3",
		"stalker2/psi/psy_whispers3.mp3",
		"stalker2/psi/psy_whispers4.mp3"
	}

	function PLUGIN:Think()
		local client = LocalPlayer()
		if not IsValid(client) or not client:Alive() then
			if psiSound1 then psiSound1:Stop() psiSound1 = nil end
			if psiSound2 then psiSound2:Stop() psiSound2 = nil end
			timer.Remove("ixPsiSound1Loop")
			timer.Remove("ixPsiSound2Loop")
			return
		end

		local inField = false
		local maxRange = 0
		local minDist = math.huge
		local pos = client:GetPos()
		local psyHealth = client:GetPsyHealth() or 100

		for _, v in ipairs(ents.FindByClass("psi_field")) do
			local range = v:GetNWInt("Range", 256)
			local dist = pos:Distance(v:GetPos())
			
			if dist <= range then
				inField = true
				if dist < minDist then
					minDist = dist
					maxRange = range
				end
			end
		end

		if inField then
			if psiSound2 then psiSound2:Stop() psiSound2 = nil end
			timer.Remove("ixPsiSound2Loop")

			local vol = math.Clamp((1 - (minDist / maxRange)) * 5, 0, 1)

			if not psiSound1 then
				psiSound1 = CreateSound(client, "stalker2/psi/psy_noise1.mp3")
				psiSound1:PlayEx(vol, 100)
				local duration = SoundDuration("stalker2/psi/psy_noise1.mp3")
				if (duration > 0) then
					timer.Create("ixPsiSound1Loop", duration, 0, function()
						if (psiSound1) then
							psiSound1:Stop()
							psiSound1:PlayEx(0, 100)
						end
					end)
				end
			end
			
			if not timer.Exists("ixPsiSound1Loop") and not psiSound1:IsPlaying() then
				psiSound1:PlayEx(vol, 100)
			end
			psiSound1:ChangeVolume(vol, 0)
		else
			if psiSound1 then psiSound1:Stop() psiSound1 = nil end
			timer.Remove("ixPsiSound1Loop")

			if psyHealth < 90 then
				local vol = math.Clamp(1 - (psyHealth / 100), 0, 1)
				if not psiSound2 then
					psiSound2 = CreateSound(client, "stalker2/psi/psy_noise2.mp3")
					psiSound2:PlayEx(vol, 100)
					local duration = SoundDuration("stalker2/psi/psy_noise2.mp3")
					if (duration > 0) then
						timer.Create("ixPsiSound2Loop", duration, 0, function()
							if (psiSound2) then
								psiSound2:Stop()
								psiSound2:PlayEx(0, 100)
							end
						end)
					end
				end

				if not timer.Exists("ixPsiSound2Loop") and not psiSound2:IsPlaying() then
					psiSound2:PlayEx(vol, 100)
				end
				psiSound2:ChangeVolume(vol, 0)
			else
				if psiSound2 then psiSound2:Stop() psiSound2 = nil end
				timer.Remove("ixPsiSound2Loop")
			end
		end

		if (psyHealth < 80) then
			if (CurTime() >= nextWhisperTime) then
				local sound = table.Random(whisperSounds)
				client:EmitSound(sound, 60, 100, 1, CHAN_AUTO)
				nextWhisperTime = CurTime() + math.random(10, 25)
			end
		else
			nextWhisperTime = CurTime() + 5
		end
	end
end