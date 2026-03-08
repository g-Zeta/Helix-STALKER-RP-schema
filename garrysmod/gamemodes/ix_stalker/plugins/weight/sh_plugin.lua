PLUGIN.name = "Weight"
PLUGIN.author = "Vex & Zeta"
PLUGIN.description = "Allows for weight to be added to items."

ix.weight = ix.weight or {}

ix.config.Add("maxWeight", 30, "The maximum weight in Kilograms someone can carry in their inventory.", nil, {
	data = {min = 1, max = 100},
	category = "Weight"
})

ix.config.Add("maxOverWeight", 20, "The maximum amount of weight in Kilograms they can go over their weight limit, this should be less than maxWeight to prevent issues.", nil, {
	data = {min = 1, max = 100},
	category = "Weight"
})

ix.util.Include("sh_meta.lua")
ix.util.Include("sv_plugin.lua")

function ix.weight.WeightString(weight, imperial)
    if weight == nil or type(weight) ~= "number" then
        return "Invalid weight" -- Ensure weight is a number
    end

    if imperial then
        if weight < 0.453592 then -- Convert to ounces if less than 1 pound
            return math.Round(weight * 35.274, 2) .. " oz"
        else
            return math.Round(weight * 2.20462, 2) .. " lbs"
        end
    else
        if weight < 1 then -- Convert to grams if less than 1 kilogram
            return math.Round(weight * 1000, 2) .. " g"
        else
            return math.Round(weight, 2) .. " kg"
        end
    end
end

function ix.weight.BaseWeight(character) -- gets total carry cap, not the base carry cap
	local base = ix.config.Get("maxWeight", 30)
	local carryinc = character:GetTotalExtraCarry()
	
	return base + carryinc
end

if (CLIENT) then
	ix.option.Add("imperial", ix.type.bool, false, {
		category = "STALKER Settings"
	})

	function PLUGIN:PopulateItemTooltip(tooltip, item)
		local weight = item:GetWeight()
		local carryinc = item:GetCarryInc()

		if !item.entity then
			if (carryinc) then
				ix.util.PropertyDesc2(tooltip, "Carry Capacity Increase: "..ix.weight.WeightString(carryinc, ix.option.Get("imperial", false)), Color(255, 255, 255), Material("vgui/ui/stalker/armorupgrades/carryweightinc.png"))
			end
		end
		
		if (weight) then
			ix.util.PropertyDesc3(tooltip, "Weight: "..ix.weight.WeightString(weight, ix.option.Get("imperial", false)), Color(255, 255, 255), Material("vgui/ui/stalker/weaponupgrades/weight.png"), 999)
		end
	end

	local nextBreath = 0
	local wasOverweight = false

	function PLUGIN:Think()
		local client = LocalPlayer()
		if (!IsValid(client) or !client:Alive()) then return end

		local character = client:GetCharacter()
		if (!character) then return end

		local max = ix.weight.BaseWeight(character) + ix.config.Get("maxOverWeight", 20) + (character:GetData("WeightBuffCur") or 0)
		local isOverweight = character:GetData("carry", 0) > max

		if (isOverweight) then
			if (!wasOverweight) then
				client:NotifyLocalized("You are overencumbered!")
			end

			if (CurTime() >= nextBreath) then
				if (client:KeyDown(IN_FORWARD) or client:KeyDown(IN_BACK) or client:KeyDown(IN_MOVELEFT) or client:KeyDown(IN_MOVERIGHT) or client:KeyDown(IN_JUMP) or !wasOverweight) then
					local gender = "male"
					local model = client:GetModel():lower()

					if (model:find("female") or model:find("alyx") or model:find("mossman")) then
						gender = "female"
					end

					local sound = gender == "female" and "stalker/player/breath_female.wav" or "stalker/player/breath.wav"
					local duration = SoundDuration(sound)

					client:EmitSound(sound, 45, 100, 1, CHAN_VOICE)
					nextBreath = CurTime() + (duration > 0 and duration or 2.5)
				end
			end
		else
			nextBreath = 0
		end

		wasOverweight = isOverweight
	end
end

if (SERVER) then
	function PLUGIN:CharacterLoaded(char) 
		if char == nil then return end
		ix.weight.Update(char)
	end
end

function ix.weight.CanCarry(weight, carry, character) -- Calculate if you are able to carry something.
    local max = ix.weight.BaseWeight(character) + ix.config.Get("maxOverWeight", 20) + (character:GetData("WeightBuffCur") or 0)
    return (weight + carry) <= max
end

function PLUGIN:CanPlayerTakeItem(client, itemEnt)
	local character = client:GetCharacter()
	if (!character) then return false end

	local item = itemEnt:GetItemTable()
	if (!item) then return false end

    return true
end

function PLUGIN:AdjustStaminaOffset(client, offset)
	local character = client:GetCharacter()

	if (character and offset < 0) then
		if (character:HeavilyOverweight()) then
			return offset * 4
		elseif (character:Overweight()) then
			return offset * 2
		end
	end
end