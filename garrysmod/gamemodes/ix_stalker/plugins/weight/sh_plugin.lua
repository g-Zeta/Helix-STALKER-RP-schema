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
end

if (SERVER) then
	function PLUGIN:CharacterLoaded(char) 
		if char == nil then return end
		local character = char
		local carrybuff = character:GetData("WeightBuffCur") or 0
		local inventory = character:GetInv()
		local weight = 0
		local totweight = 0
		local maxweight = ix.config.Get("maxWeight", 30) + ix.config.Get("maxOverWeight", 20) + carrybuff

		for x, y in pairs(inventory:GetItems()) do
			if y.weight == nil then continue end
			
			local quantity = y:GetData("quantity", 1)
			
			if y:GetData("weight") ~= nil then
				weight = y:GetData("weight", 0)
			elseif y.weight ~= nil then
				weight = y.weight
			end
			
			if y.isCW then
				if weight ~= (y.weight + y:GetData("weight", 0)) then
					weight = y.weight + y:GetData("weight", 0)
				end
			end
			
			totweight = ((quantity * weight) + totweight)
		end

		character:SetData("Weight", totweight)
		character:SetData("MaxWeight", maxweight)  -- Max weight already includes carrybuff
	end
end

function ix.weight.CanCarry(weight, carry, character) -- Calculate if you are able to carry something.
    local max = ix.weight.BaseWeight(character) + ix.config.Get("maxOverWeight", 20) + (character:GetData("WeightBuffCur") or 0)
    return (weight + carry) <= max
end

function PLUGIN:CanPlayerTakeItem(client, itemEnt)
	local character = client:GetChar()
	local carrybuff = character:GetData("WeightBuffCur") or 0
    local inventory = character:GetInv()
	local item = ix.item.list[itemEnt:GetItemID()]
	local itemWeight = item.weight
    local weight = 0
    local totweight = 0
    local maxweight = ix.config.Get("maxWeight", 30) + ix.config.Get("maxOverWeight", 20) + carrybuff

    -- Calculate current total weight in inventory	
	for x, y in pairs(inventory:GetItems()) do
		if y.weight == nil then continue end
		local quantity = y:GetData("quantity",1)
        local weight = y:GetData("weight") or y.weight
        totweight = totweight + (quantity * weight)
    end
	
    -- Include the weight of the item being taken
    if itemWeight ~= nil then
        local quantity = item:GetData("quantity", 1)
        totweight = totweight + (quantity * itemWeight)
    end
	
    -- Check if the total weight exceeds max weight allowed
    if totweight > (maxweight + ix.config.Get("maxOverWeight", 20)) then
        client:NotifyLocalized("You are carrying too much weight to pick that up.")
        return false
    end

    return true
end

function PLUGIN:PlayerInteractItem(client, action, item)
    local character = client:GetChar()
    local carrybuff = character:GetData("WeightBuffCur") or 0
    local inventory = character:GetInv()
    local totalWeight = ix.weight.CalculateWeight(character) -- Calculate current total weight

    local itemWeight = item:GetWeight() or 0
    local quantity = item:GetData("quantity", 1)

    if action == "take" then
        totalWeight = totalWeight + (quantity * itemWeight)
    elseif action == "drop" or action == "Sell" then
        totalWeight = totalWeight - (quantity * itemWeight)
    end

    -- Update character weight and check if they can carry the new total weight
    character:SetData("Weight", totalWeight)
    character:SetData("MaxWeight", ix.config.Get("maxWeight", 30) + carrybuff) -- Include carrybuff in max weight check
end