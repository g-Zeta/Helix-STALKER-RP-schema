if (SERVER) then
	util.AddNetworkString("ixBagDrop")
end

ITEM.name = "Backpack"
ITEM.description = "Lets you increase weight capacity."
ITEM.model = "models/props_c17/suitcase001a.mdl"
ITEM.category = "Backpacks"
ITEM.width = 2
ITEM.height = 2
ITEM.outfitCategory = "backpack"
ITEM.isBackpack = true
ITEM.equipIcon = Material("materials/vgui/ui/stalker/misc/equip.png")

--Weight buff
ITEM.buff = "weight"
ITEM.buffval = 1

if (CLIENT) then
--[[
	function ITEM:PaintOver(item, w, h)
		if (item:GetData("equip")) then
			surface.SetDrawColor(110, 255, 110, 255)
		else
			surface.SetDrawColor(255, 110, 110, 255)
		end

		surface.SetMaterial(item.equipIcon)
		surface.DrawTexturedRect(w-23,h-23,19,19)
	end
]]
    function ITEM:DisplayBuffValue(tooltip)
        local buffValue = self.buffval or 0
		local isImperial = ix.option.Get("imperial", false)

        if isImperial then
            -- Convert metric to imperial (1 kg = 2.20462 lbs)
            buffValue = buffValue * 2.20462
            tooltip:AppendText("Capacity: " .. math.Round(buffValue, 2) .. " lbs") -- Display in pounds
        else
            tooltip:AppendText("Capacity: " .. math.Round(buffValue, 2) .. " kg") -- Display in kilograms
        end

        -- Use PropertyDesc3 to add the buff value to the tooltip
        ix.util.PropertyDesc3(tooltip, "Capacity: +" .. math.Round(buffValue, 2) .. (isImperial and " lbs" or " kg"), Color(255, 255, 255), Material("vgui/ui/stalker/armorupgrades/carryweightinc.png"), 999)
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
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1")
	end
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
		return client:GetCharacter():HasFlags("N") and !IsValid(item.entity)
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
		return client:GetCharacter():HasFlags("N") and !IsValid(item.entity)
	end
}

function ITEM:OnEquipped()
    if IsValid(self.player) then
        self.player:EmitSound("stalkersound/inv_slot.mp3")
    end
end

function ITEM:OnUnequipped()
    if IsValid(self.player) then
        self.player:EmitSound("stalkersound/inv_slot.mp3")
    end
end

hook.Add("PlayerDeath", "ixStripBackpackOnDeath", function(client)
    local character = client:GetCharacter()
	if not character then return end
    -- Loop through all items in the player's inventory
    for _, item in pairs(character:GetInventory():GetItems()) do
        -- Check if the item is a backpack and equipped
        if item.outfitCategory == "backpack" and item:GetData("equip") then
            -- Unequip the backpack
            item:SetData("equip", nil)
        end
    end
end)