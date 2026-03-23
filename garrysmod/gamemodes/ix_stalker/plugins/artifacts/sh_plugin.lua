PLUGIN.name = "Artifacts"
PLUGIN.author = "Lt. Taylor & Zeta"
PLUGIN.desc = "Adds a relatively simple artifact system"

ix.config.Add("PsyDamageThreshold", 80, "The PsyHealth threshold at which players start taking damage.", nil, {
	data = {min = 1, max = 99},
	category = "Psy"
})

if SERVER then
	function PLUGIN:CharacterLoaded(character)
		if character then
			character:SetData("ArtiHealAmt", 0)
			character:SetData("ArtiHealCur",0)
			character:SetData("Rads", 0)
			character:SetData("RadsCur", 0)
			character:SetData("AccumRads", 0)
			character:SetData("AntiRads", 0)
			character:SetData("AntiRadsCur", 0)
			character:SetData("WoundHeal", 0)
			character:SetData("WoundHealCur", 0)
			character:SetData("Bleeding", 0)
			character:SetData("BleedingCur", 0)
			character:SetData("PsyRegen", 0)
			character:SetData("WeightBuff", 0)
			character:SetData("WeightBuffCur", 0)
		end
	end
	
	function PLUGIN:Think()
		for k, v in ipairs(player.GetAll()) do
			local character = v:GetCharacter()
			
			if not character then continue end
			if v:HasGodMode() then continue end

			local maxhealth = v:GetMaxHealth() or 100
			local artiheal = character:GetData("ArtiHealAmt", 0)	-- Healing
			local woundheal = character:GetData("WoundHeal", 0)		-- Wound healing
			local bleeding = character:GetData("Bleeding", 0)		-- Bleeding
			local rads = character:GetData("Rads", 0)				-- Radiation
			local antirads = character:GetData("AntiRads",0)		-- Anti-Radiation
			local accumrad = v:GetNetVar("AccumRads") or 0
			local psyhealth = v:GetPsyHealth() or 100				-- Psy Health
			local psyRegen = character:GetData("PsyRegen", 0)		-- Psy Regeneration
			local maxweight = character:GetData("MaxWeight", 50)	-- Weight
			local weightbuff = character:GetData("WeightBuff", 0)
			local weightprev = character:GetData("WeightBuffCur", 0)
				
			if weightbuff ~= weightprev then
				local newweight = ((maxweight + weightbuff) - weightprev)
				character:SetData("MaxWeight",newweight)
				character:SetData("WeightBuffCur",weightbuff)
			end
			
			-- Healing
			if artiheal > 0 then
				if (v.nextArtiHeal or 0) < CurTime() then
					v.nextArtiHeal = CurTime() + 2 -- healing every 2 seconds/ticks
					if (v:IsValid() and v:Alive()) then
						v:SetHealth(math.Clamp(v:Health() + math.Clamp(artiheal,1,100), 0, maxhealth))
					end
				end
			end

			-- Wound healing
			if woundheal > 0 then
				if (v.nextWoundHeal or 0) < CurTime() then
					v.nextWoundHeal = CurTime() + 10	-- healing every 10 seconds/ticks
					if woundheal >= bleeding then
						character:SetData("Bleeding", 0)
						if (v:IsValid() and v:Alive()) then
							v:SetHealth(math.Clamp(v:Health() + math.Clamp(woundheal,1,100), 0, maxhealth))
						end
					end
				end
			end

			-- Bleeding damage
			if bleeding > 0 and (v.nextBleeding or 0) < CurTime() then
				v.nextBleeding = CurTime() + 2	-- bleeding every 2 seconds/ticks
				if (v:IsValid() and v:Alive()) then
					local bleedingAmount = math.Clamp(bleeding, 1, 100)
					v:SetHealth(math.Clamp(v:Health() - bleedingAmount, 0, maxhealth))

					if (v:Health() <= 0) then
						v:Kill()
					end
				end
			end

			-- Psy damage
			if psyhealth <= ix.config.Get("PsyDamageThreshold", 40) and (v:IsValid() and v:Alive()) then
				if (v.nextPsyDamage or 0) < CurTime() then
					-- Damage frequency increases with psi accumulation
					local psiAccumulation = 100 - psyhealth
					local delay = 20 / psiAccumulation
					v.nextPsyDamage = CurTime() + delay

					v:SetHealth(math.Clamp(v:Health() - 1, 0, maxhealth))

					if (v:Health() <= 0) then
						v:Kill()
					end
				end
			end

			-- PsyHealth regeneration
			if psyRegen > 0 and (v.nextPsyRegen or 0) < CurTime() then
				v.nextPsyRegen = CurTime() + 1 -- regeneration per second/tick
				if (v:IsValid() and v:Alive()) then
					v:SetPsyHealth(math.Clamp(v:GetPsyHealth() + psyRegen, 0, 100))
				end
			end

			-- Radiation
			if rads > 0 or accumrad > 0 then
				if rads > antirads then
					if (v.nextRads or 0) < CurTime() then
						v.nextRads = CurTime() + 1

						if (v:IsValid() and v:Alive()) then
							if v:Health() <= 0 then
								v:Kill()
							end
							
							local radiation = rads - antirads
							local buildup = accumrad + radiation
							v:SetNetVar("AccumRads", buildup)
							
							if v:Alive() == false then
								v:SetNetVar("AccumRads", 0)
							end
						end
					end
				elseif (v.nextRads or 0) < CurTime() then
					v.nextRads = CurTime() + 1

					local antiradcalc = (antirads - rads) or 0		-- antiradiation artis help
					local radred = (accumrad - antiradcalc)			-- reduce the accumulated radiation
					v:SetNetVar("AccumRads", radred)				-- Update the accumulated radiation value

					if radred <= 0 or v:Alive() == false then
						v:SetNetVar("AccumRads", 0)
					end
				end

				-- Radiation Damage
				if accumrad > 10 and (v:IsValid() and v:Alive()) then
					if (v.nextRadDamage or 0) < CurTime() then
						-- Damage frequency increases with radiation accumulation
						local delay = 10 / accumrad
						v.nextRadDamage = CurTime() + delay

						v:SetHealth(math.Clamp((v:Health() - 1), 0, maxhealth))

						if (v:Health() <= 0) then
							v:Kill()
						end
					end
				end
			end
		end
	end
end 

hook.Add("PlayerDeath","ArtiWipe", function(client)	-- Reset on death
	if not IsValid(client) then return end
	local character = client:GetChar()
	if not character then return end
	local inv = character:GetInventory()
	if not inv then return end
	for k,v in pairs(inv:GetItems()) do
		if v.isArtefact then
			v:SetData("equip",nil)
		end
	end

	character:SetData("ArtiHealAmt", 0)
    character:SetData("ArtiHealCur", 0)
	 client:SetNetVar("AccumRads", 0)
	character:SetData("radiation", 0)
    character:SetData("Rads", 0)
    character:SetData("RadsCur", 0)
    character:SetData("AntiRads", 0)
    character:SetData("AntiRadsCur", 0)
    character:SetData("WoundHeal", 0)
    character:SetData("WoundHealCur", 0)
    character:SetData("Bleeding", 0)
    character:SetData("BleedingCur", 0)
	character:SetData("PsyRegen", 0)
	character:SetData("WeightBuff", 0)
	character:SetData("WeightBuffCur", 0)
	
	hook.Run("ArtifactChange", client)
end) 