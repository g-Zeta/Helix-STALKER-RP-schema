ITEM.name = "PAC Outfit"
ITEM.description = "A PAC Outfit Base."
ITEM.longdesc = "No Longer Description Available."
ITEM.model = "models/Gibs/HGIBS.mdl"

ITEM.goggleType = nil

ITEM.price = 1
ITEM.flag = nil

ITEM.weight = 1

ITEM.width = 2
ITEM.height = 2

ITEM.img = Material("placeholders/slot_nvg.png")

ITEM.category = "Electronics"
ITEM.isNVG = true

ITEM.equipIcon = Material("stalkerCoP/ui/icons/misc/equip.png")

function ITEM:GetDescription()
	local quant = self:GetData("quantity", 1)
	local str = self.description
	if self.longdesc then
		str = str.."\n\n"..(self.longdesc or "")
	end

	local customData = self:GetData("custom", {})
	if(customData.desc) then
		str = customData.desc
	end

	-- Power is handled by an internal, replaceable battery.
	return str .. "\n\nPower: " .. math.floor(self:GetData("durability", 100)) .. "%"
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

function ITEM:OnInstanced()
	if !self:GetData("durability") then
		self:SetData("durability", 0)
	end
end

function ITEM:RemovePart(client)
	local char = client:GetCharacter()

	self:SetData("equip", false)
	client:RemovePart(self.uniqueID)

	if self.isNVG then
		self.player:SetNWInt("nvg", 0)
	end 
end

function ITEM:TogglePart(client)
	local char = client:GetCharacter()
	client:RemovePart(self.uniqueID)
end

ITEM:Hook("drop", function(item)
	if (item:GetData("equip")) then
		item:RemovePart(item.player)
	end
end)

ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "stalkerCoP/ui/icons/misc/unequip.png",
	OnRun = function(item)
		item:RemovePart(item.player)
		item:OnUnequipped()

		if item.isNVG then
			item.player:SetNWInt("nvg", 0)
		end 

		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true and
		hook.Run("CanPlayerUnequipItem", client, item) != false and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}

-- On player eqipped the item, Gives a weapon to player and load the ammo data from the item.
ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip", 
	icon = "stalkerCoP/ui/icons/misc/equip.png",
	OnRun = function(item)
		local char = item.player:GetCharacter()
		local items = char:GetInventory():GetItems()

		for _, v in pairs(items) do
			if (v.id != item.id) then
				local itemTable = ix.item.instances[v.id]

				if (v.isNVG == true and item.isNVG == true and itemTable:GetData("equip")) then
					item.player:Notify("You are already equipping a set of NVGs!")

					return false
				end
			end
		end

		item:SetData("equip", true)
		item.player:AddPart(item.uniqueID, item)

		if (item.attribBoosts) then
			for k, v in pairs(item.attribBoosts) do
				char:AddBoost(item.uniqueID, k, v)
			end
		end


		if item.isNVG then
			ArcticNVGs_SetPlayerGoggles(item.player, item.goggleType)
		end 

		item:OnEquipped()
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

	return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and
			hook.Run("CanPlayerEquipItem", client, item) != false and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}

function ITEM:CanTransfer(oldInventory, newInventory)
	if (newInventory and self:GetData("equip")) then
		return false
	end

	return true
end

function ITEM:OnRemoved()
	local inventory = ix.item.inventories[self.invID]
	local owner = inventory.GetOwner and inventory:GetOwner()

	if (IsValid(owner) and owner:IsPlayer()) then
		if (self:GetData("equip")) then
			self:RemovePart(owner)
		end
	end
end

ITEM.functions.Sell = {
	name = "Sell",
	icon = "stalkerCoP/ui/icons/misc/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item:GetData("RealPrice") or item.price
		sellprice = math.Round(sellprice*0.60)
		client:Notify( "Sold for ".. ix.currency.Get(sellprice).."." )
		client:GetCharacter():GiveMoney(sellprice)
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item.player:GetCharacter():HasFlags("1") and !item:GetData("equip")
	end
}

ITEM.functions.Value = {
	name = "Value",
	icon = "icon16/help.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item:GetData("RealPrice") or item.price
		sellprice = math.Round(sellprice*0.60)
		client:Notify( "Item is sellable for ".. ix.currency.Get(sellprice).."." )
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item.player:GetCharacter():HasFlags("1") and !item:GetData("equip")
	end
}

ITEM.functions.RemoveBattery = {
	name = "Remove Battery",
	tip = "Remove the battery from this device.",
	icon = "icon16/delete.png",
	sound = "cw/holster4.wav",
	OnRun = function(item)
		local client = item.player
		local charge = item:GetData("durability", 0)

		if (charge <= 0) then
			client:Notify("This device has no battery to remove.")
			return false
		end

		local inventory = client:GetCharacter():GetInventory()
		local x, y = inventory:FindEmptySlot(1, 1)

		if (x and y) then
			inventory:Add("9vbattery", 1, {power = charge})
			item:SetData("durability", 0)
			client:Notify("You removed the battery.")

			if (item:GetData("equip")) then
				if (client:GetNWBool("nvg_on", false)) then
					client:ConCommand("arc_vm_nvg")
				end
				client:SetNWBool("nvg_on", false)
			end
		else
			client:Notify("You do not have enough inventory space.")
		end

		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetData("durability", 0) > 0
	end
}

function ITEM:OnEquipped()
    if IsValid(self.player) then
        self.player:EmitSound("stalker/inventory/inv_slot.mp3")
    end
end

function ITEM:OnUnequipped()
    if IsValid(self.player) then
        self.player:EmitSound("stalker/inventory/inv_slot.mp3")
    end
end