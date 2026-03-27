if (SERVER) then
	util.AddNetworkString("ixBagDrop")
end

ITEM.name = "Backpack"
ITEM.description = "Lets you increase weight capacity."
ITEM.model = "models/props_c17/suitcase001a.mdl"
ITEM.category = "Backpacks"
ITEM.width = 2
ITEM.height = 2
ITEM.weight = 0
ITEM.outfitCategory = "backpack"
ITEM.isBackpack = true
ITEM.img = Material("placeholders/slot_backpack.png")

--Weight buff
ITEM.buff = "weight"
ITEM.buffval = 1

if (CLIENT) then
    function ITEM:DisplayBuffValue(tooltip)
        local buffValue = self.buffval or 0
		local isImperial = ix.option.Get("imperial", false)

		if (buffValue > 0) then
			ix.util.PropertyDesc4(tooltip, "Weight carried: ", Color(255, 255, 255), "+" .. ix.weight.WeightString(buffValue, isImperial), Color(0, 135, 0), "materials/stalkerCoP/ui/icons/armorupgrades/carryweightinc.png")
		end
    end

    function ITEM:PopulateTooltip(tooltip)
        self:DisplayBuffValue(tooltip)
    end
end

ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/stalker/equip.png",
	OnRun = function(item)
		local char = item.player:GetCharacter()
		local items = char:GetInventory():GetItems()

		for _, v in pairs(items) do
			if (v.id ~= item.id) and (v.outfitCategory == item.outfitCategory) and v:GetData("equip") then
				item.player:Notify("You're already equipping a backpack.")
				return false
			end
		end

		if item.buff == "weight" then
           local curweight = char:GetData("WeightBuff") or 0
		   curweight = math.Clamp(curweight,0,1000)
           local newweight = (curweight + item.buffval)
           char:SetData("WeightBuff",newweight)
        end

		item:SetData("equip", true)
		item:OnEquipped()

		if (ix.weight) then
			ix.weight.Update(char)
		end

		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and
			hook.Run("CanPlayerUnequipItem", client, item) != false and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}

ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/stalker/unequip.png",
	OnRun = function(item)
        local client = item.player
		local char = client:GetCharacter()

        if item.buff == "weight" then
           local curweight = char:GetData("WeightBuff") or 0
           local newweight = (curweight - item.buffval)
           char:SetData("WeightBuff",newweight)
        end
		
		item:SetData("equip", false)
		item:OnUnequipped()
		
		if (ix.weight) then
			ix.weight.Update(char)
		end

		return false
	end,

	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true and
			hook.Run("CanPlayerUnequipItem", client, item) != false and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}

ITEM:Hook("drop", function(item)
    local client = item.player;
    local character = client:GetCharacter();

    if (item:GetData("equip")) then

       if item.buff == "weight" then
           local curweight = character:GetData("WeightBuff") or 0
           local newweight = (curweight - item.buffval)
           character:SetData("WeightBuff",newweight)
        end
        
        item:SetData("equip", nil);

		if (ix.weight) then
			ix.weight.Update(character)
		end
    end;
end);

ITEM.functions.Sell = {
	name = "Sell",
	icon = "icon16/stalker/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item.price/1.32
		local character = client:GetCharacter()		
		
		sellprice = math.Round(sellprice)
		client:Notify( "Sold for "..(sellprice).." rubles." )
		client:GetCharacter():GiveMoney(sellprice)
		
        if (item:GetData("equip")) then
			if item.buff == "weight" then
			   local curweight = character:GetData("WeightBuff") or 0
			   local newweight = (curweight - item.buffval)
			   character:SetData("WeightBuff",newweight)
			end
			
			item:SetData("equip", nil);		
		end;

		if (ix.weight) then	ix.weight.Update(character)	end
	end,
	OnCanRun = function(item)	-- made it multiple if's just because it was getting too long
		if (!IsValid(item.entity) and item:GetData("equip",false) == false) then
			return true
		end
		
		return false
	end
}

ITEM.functions.Value = {
	name = "Value",
	icon = "icon16/help.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = (item.price/1.32)
		sellprice = math.Round(sellprice)
		client:Notify( "Item is sellable for "..(sellprice).." rubles." )
		return false
	end,
	OnCanRun = function(item)
		local owner = item:GetOwner()
		return !IsValid(item.entity) and owner and owner:GetCharacter() and owner:GetCharacter():HasFlags("1")
	end
}

ITEM.functions.SetDurability = {
	name = "Set Durability",
	tip = "Dura",
	icon = "icon16/wrench.png",
	
	OnCanRun = function(item)
		local char = item.player:GetChar()
		if char:HasFlags("N") then
			return true
		else
			return false
		end
	end,
	
	OnRun = function(item)
		netstream.Start(item.player, "armordurabilityAdjust", item:GetData("durability", 10000), item.id)
		return false
	end,
}

function ITEM:GetDescription()
	local str = self.description
	if self.longdesc and !IsValid(self.entity) then
		str = str.."\n"..(self.longdesc or "")
	end

	local customData = self:GetData("custom", {})
	if(customData.desc) then
		str = customData.desc
	end
	
	if (customData.longdesc) and !IsValid(self.entity) then
		str = str.."\n"..customData.longdesc or ""
	end

    return (str)
end

function ITEM:GetName()
	local name = self.name
	
	local customData = self:GetData("custom", {})
	if(customData.name) then
		name = customData.name
	end
	
	return name
end

ITEM.functions.Custom = {
	name = "Customize",
	tip = "Customize this item",
	icon = "icon16/wrench.png",
	OnRun = function(item)		
		ix.plugin.list["customization"]:startCustom(item.player, item)
		
		return false
	end,
	
	OnCanRun = function(item)
		local client = item.player
		local char = client:GetCharacter()
		return char and char:HasFlags("N") and !IsValid(item.entity)
	end
}

ITEM.functions.Clone = {
	name = "Clone",
	tip = "Clone this item",
	icon = "icon16/wrench.png",
	OnRun = function(item)
		local client = item.player	
	
		client:requestQuery("Are you sure you want to clone this item?", "Clone", function(text)
			if text then
				local inventory = client:GetCharacter():GetInventory()
				
				if(!inventory:Add(item.uniqueID, 1, item.data)) then
					client:Notify("Inventory is full")
				end
			end
		end)
		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		local char = client:GetCharacter()
		return char and char:HasFlags("N") and !IsValid(item.entity)
	end
}

function ITEM:OnInstanced(invID, x, y)
	if !self:GetData("durability") then
		self:SetData("durability", 10000)
	end
end

function ITEM:OnEquipped()
    if IsValid(self.player) then
        self.player:EmitSound("stalker/inventory/inv_bag_open.wav")
    end
end

function ITEM:OnUnequipped()
    if IsValid(self.player) then
        self.player:EmitSound("stalker/inventory/inv_bag_close.wav")
    end
end

hook.Add("PlayerDeath", "ixStripBackpackOnDeath", function(client)
    local character = client:GetCharacter()
	if not character then return end
    -- Loop through all items in the player's inventory
    for _, item in pairs(character:GetInventory():GetItems()) do
        -- Check if the item is a backpack and equipped
        if item.outfitCategory == "backpack" and item:GetData("equip") then
            -- Remove the weight buff if applicable
            if item.buff == "weight" then
                local curweight = character:GetData("WeightBuff") or 0
                local newweight = (curweight - item.buffval)
                character:SetData("WeightBuff", newweight)
            end
            -- Unequip the backpack
            item:SetData("equip", nil)
        end
    end
end)