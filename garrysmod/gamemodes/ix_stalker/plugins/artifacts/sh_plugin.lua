PLUGIN.name = "Artifacts"
PLUGIN.author = "Lt. Taylor & Zeta"
PLUGIN.desc = "Adds a relatively simple artifact system"

ix.util.Include("cl_plugin.lua")

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
			character:SetData("WeightBuff", 0)
			character:SetData("WeightBuffCur", 0)
		end
	end
	
	local thinkTimer = 1
	local artihealTimer = 1
	local woundhealTimer = 1
	local bleedingTimer = 1
	local radsTimer = 1
	
	function PLUGIN:Think()
		for k, v in ipairs(player.GetAll()) do
			local character = v:GetCharacter()
			
			if not character then continue end

			local maxhealth = v:GetMaxHealth() or 100
			local artiheal = character:GetData("ArtiHealAmt", 0)	-- Healing
			local woundheal = character:GetData("WoundHeal", 0)		-- Wound healing
			local bleeding = character:GetData("Bleeding", 0)		-- Bleeding
			local rads = character:GetData("Rads", 0)				-- Radiation
			local antirads = character:GetData("AntiRads",0)		-- Anti-Radiation
			local accumrad = v:GetNetVar("AccumRads") or 0
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
				if artihealTimer < CurTime() then
					artihealTimer = CurTime() + 2 -- healing every 2 seconds
					if (v:IsValid() and v:Alive()) then
						v:SetHealth(math.Clamp(v:Health() + math.Clamp(artiheal,1,100), 0, maxhealth))
					end
				end
			end

			-- Wound healing
			if woundheal > 0 then
				if woundhealTimer < CurTime() then
					woundhealTimer = CurTime() + 10	-- healing every 10 seconds
					if woundheal >= bleeding then
						character:SetData("Bleeding", 0)
						if (v:IsValid() and v:Alive()) then
							v:SetHealth(math.Clamp(v:Health() + math.Clamp(woundheal,1,100), 0, maxhealth))
						end
					end
				end
			end

			-- Bleeding damage
			if bleeding > 0 and bleedingTimer < CurTime() then
				bleedingTimer = CurTime() + 2	-- bleeding every 2 seconds
				if (v:IsValid() and v:Alive()) then
					local bleedingAmount = math.Clamp(bleeding, 1, 100)
					v:SetHealth(math.Clamp(v:Health() - bleedingAmount, 0, maxhealth))
				end
			end

			-- Radiation
			if rads > 0 or accumrad > 0 then
				if rads > antirads then
					if radsTimer < CurTime() then
						radsTimer = CurTime() + 0.25

						if (v:IsValid() and v:Alive()) then
							if v:Health() <= 0 then
								v:Kill()
							end
							
							local radiation = ((rads - antirads)/10)
							local buildup = accumrad + radiation
							local damage = (buildup/30)
							v:SetNetVar("AccumRads", buildup)
							if v:Alive() == false then
								v:SetNetVar("AccumRads", 0)
							end
							
							if accumrad > 24 then
								v:SetHealth(math.Clamp((v:Health() - damage), 0, maxhealth))
							end
						end
					end
				else
					if radsTimer < CurTime() then
						radsTimer = CurTime() + 0.5

						local antiradcalc = (antirads - rads) or 0		-- antiradiation artis help
						local modifier = 0.1 + antiradcalc				-- the time for radiation to dissipate by itself: 0.1 = 3 rads every 20 seconds
						local radred = (accumrad - modifier)			-- reduce the accumulated radiation value by the modifier
						local damage = (radred/50)						-- determine how much damage the player will receive
						v:SetNetVar("AccumRads", radred)				-- Update the accumulated radiation value
						if radred <= 0 or v:Alive() == false then
							v:SetNetVar("AccumRads", 0)
						end

						if accumrad > 24 then
							v:SetHealth(math.Clamp((v:Health() - damage), 0, maxhealth))
						end
					end
				end
			end
		end
	end
end 

hook.Add("PlayerDeath","ArtiWipe", function(client)
	local character = client:GetChar()
	if not character then return end
	for k,v in pairs(character:GetInv():GetItems()) do
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
	character:SetData("WeightBuff", 0)
	character:SetData("WeightBuffCur", 0)
	
	hook.Run("ArtifactChange", client)
end) 