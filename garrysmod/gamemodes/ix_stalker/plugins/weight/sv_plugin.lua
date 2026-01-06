function ix.weight.CalculateWeight(character) -- Calculates the total weight of all items a character is carrying.
    local inventory = character:GetInventory()
    local weight = 0

    for i, v in pairs(inventory:GetItems()) do
		local itemWeight = 0
		if (v:GetData("weight")) then
			itemWeight = v:GetData("weight")
		elseif (v.GetWeight) then
			itemWeight = v:GetWeight() or 0
		else
			itemWeight = v.weight or 0
		end

		local quantity = v:GetData("quantity", 1)
		if (v.isAmmo) then
			quantity = 1
		end

		weight = weight + (itemWeight * quantity)
    end

    return weight
end

-- Define a function to update the character's movement speeds based on their weight condition
local function UpdateCharacterSpeeds(character)
    local client = character:GetPlayer()
    if client then
        if character:HeavilyOverweight() then
            client:SetWalkSpeed(ix.config.Get("walkSpeed") * 0.5)
            client:SetRunSpeed(ix.config.Get("runSpeed") * 0.4)
        elseif character:Overweight() then
            client:SetWalkSpeed(ix.config.Get("walkSpeed") * 0.8)
            client:SetRunSpeed(ix.config.Get("runSpeed") * 0.7)
        else
            client:SetWalkSpeed(ix.config.Get("walkSpeed"))
            client:SetRunSpeed(ix.config.Get("runSpeed"))
        end
    end
end

-- Hook into the player loadout event to ensure speeds are updated
function PLUGIN:PostPlayerLoadout(client)
    local character = client:GetCharacter()
    if character then
        UpdateCharacterSpeeds(character)
    end
end

-- Update the existing function to use the new UpdateCharacterSpeeds function
function ix.weight.Update(character)
    local weight = ix.weight.CalculateWeight(character)
    character:SetData("carry", weight)
    character:SetData("Weight", weight)

    local carrybuff = character:GetData("WeightBuffCur") or 0
    local maxweight = ix.config.Get("maxWeight", 30) + ix.config.Get("maxOverWeight", 20) + carrybuff
    character:SetData("MaxWeight", maxweight)

    local carryInc = 0
    for _, v in pairs(character:GetInventory():GetItems()) do
        if (v:GetData("equip") and v.GetCarryInc) then
            carryInc = carryInc + (v:GetCarryInc() or 0)
        end
    end
    character:SetData("carryInc", carryInc)

    UpdateCharacterSpeeds(character)
end

function PLUGIN:CharacterLoaded(character) -- This is just a safety net to make sure the carry weight data is up-to-date.
	ix.weight.Update(character)
end

function PLUGIN:AmmoCheck(client) -- updates weight after each reload, do we keep this?
	ix.weight.Update(client:GetCharacter())
end

function PLUGIN:CanTransferItem(item, old, inv) -- When a player attempts to take an item out of a container.
	if (inv.owner and item:GetWeight() and (old and old.owner != inv.owner)) then
		local character = ix.char.loaded[inv.owner]

		if (!character:CanCarry(item)) then
			character:GetPlayer():NotifyLocalized("You are extremely overencumbered and cannot take that.")
			return false
		end
	end

	if(old.owner and item:GetCarryInc() and item:GetData("equip", nil) == true and (inv and inv.owner != old.owner)) then
		local character = ix.char.loaded[old.owner]

		if (!character:CanRemoveCarry(item)) then
			character:GetPlayer():NotifyLocalized("You would be too overencumbered without that.")
			return false
		end
	end
end

function PLUGIN:OnItemTransferred(item, old, new)
	if (item:GetWeight()) then
		if (old.owner and !new.owner) then -- Removing item from inventory.
			ix.weight.Update(ix.char.loaded[old.owner])
		elseif (!old.owner and new.owner) then -- Adding item to inventory.
			ix.weight.Update(ix.char.loaded[new.owner])
		end
	end
end

function PLUGIN:InventoryItemAdded(old, new, item)
	if (item:GetWeight()) then
		if (!old and new.owner) then -- When an item is directly created in their inventory.
			ix.weight.Update(ix.char.loaded[new.owner])
		end
	end
end

function PLUGIN:CanPlayerTradeWithVendor(client, entity, uniqueID, selling)
	if (!selling) then
		local item = ix.item.list[uniqueID]

		if (item:GetWeight() and !client:GetCharacter():CanCarry(item)) then
			client:NotifyLocalized("You are carrying too much weight to buy that.")
			return false
		end
	end
end

function PLUGIN:CharacterVendorTraded(client, entity, uniqueID, selling)
    -- Ensure that weight is updated after selling an item
    local character = client:GetCharacter()
    if selling then
        ix.weight.Update(character) -- Update the weight after selling
    end
end
