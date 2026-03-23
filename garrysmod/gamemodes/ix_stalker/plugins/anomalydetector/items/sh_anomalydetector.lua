ITEM.name = "Anomaly Detector"
ITEM.model = "models/flaymi/anomaly/dynamics/devices/dev_decoder.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Electronics"
ITEM.price = 1600
ITEM.weight = 0.5
ITEM.isAnomalydetector = true
ITEM.flag = "1"
ITEM.weaponCategory = "Anomaly Detector"
ITEM.img = Material("stalker2/ui/devices/decoder.png")

function ITEM:GetDescription()
	return "A device that beeps when anomalies are close.\n\nPower: " .. math.floor(self:GetData("durability", 0)) .. "%"
end

ITEM.functions.Equip = {
	name = "Equip",
	tip = "useTip",
	icon = "stalkerCoP/ui/icons/misc/equip.png",
	OnRun = function(item, data)
		local client = item.player
		local character = client:GetCharacter()
		local wepslots = character:GetData("wepSlots",{})

		if (item:GetData("durability", 0) <= 0) then
			client:Notify("This device has no power.")
			return false
		end

		if item:GetData("equip") then
			client:Notify("You already have this detector equipped.")
			return false
		end

		local inventory = character:GetInventory()
		if (inventory) then
			for _, v in pairs(inventory:GetItems()) do
				if (v.id != item.id and v.isAnomalydetector and v:GetData("equip")) then
					client:Notify("You already have an anomaly detector equipped.")
					return false
				end
			end
		end

		if wepslots[item.weaponCategory] then
			client:NotifyLocalized("weaponSlotFilled", item.weaponCategory)
			return false
		end
		
		wepslots[item.weaponCategory] = item.Name
		character:SetData("wepSlots",wepslots)
		item:SetData("equip", true)
		if (data and data.equipSlot) then
			if (character) then
				local inv = character:GetInventory()
				if (inv) then
					for _, v in pairs(inv:GetItems()) do
						if (v.id != item.id and v.isAnomalydetector and v:GetData("equip") and v:GetData("equipSlot") == data.equipSlot) then
							v.player = client
							if (v.functions.EquipUn and v.functions.EquipUn.OnRun) then
								v.functions.EquipUn.OnRun(v)
							else
								v:SetData("equip", false)
								v:SetData("equipSlot", nil)
							end
							v.player = nil
						end
					end
				end
			end
			item:SetData("equipSlot", data.equipSlot)
		end
		item.player:SetData("ixhasanomdetector", true)
		item.player:SetNetVar("ixhasanomdetector", true)
		ix.plugin.list["anomalydetector"]:StartDetectorTimer(client)
		item:OnEquipped()
		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		return !IsValid(item.entity) and IsValid(client) and !item:GetData("equip")
	end
}

ITEM.functions.EquipUn = {
	name = "Unequip",
	tip = "equipTip",
	icon = "stalkerCoP/ui/icons/misc/unequip.png",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local wepslots = character:GetData("wepSlots",{})
		item:SetData("equip", false)
		item:SetData("equipSlot", nil)
		item.player:SetNetVar("ixhasanomdetector", false)
		item.player:SetData("ixhasanomdetector", false)
		ix.plugin.list["anomalydetector"]:StopDetectorTimer(client)
		wepslots[item.weaponCategory] = nil
		character:SetData("wepSlots",wepslots)
		item:OnUnequipped()
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true
	end
}

ITEM:Hook("drop", function(item)
    local client = item.player;
    local character = client:GetChar();

    if (item:GetData("equip")) then
		item:SetData("equip", nil)
		item:SetData("equipSlot", nil)
		item.player:SetNetVar("ixhasanomdetector", false)
		item.player:SetData("ixhasanomdetector", false)
		ix.plugin.list["anomalydetector"]:StopDetectorTimer(client)
    end;
end);

ITEM.functions.Sell = {
	name = "Sell",
	icon = "stalkerCoP/ui/icons/misc/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = math.Round(item.price / 1.32)
		client:Notify("Sold for " .. ix.currency.Get(sellprice) .. ".")
		client:GetCharacter():GiveMoney(sellprice)

	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1") and !item:GetData("equip")
	end
}

ITEM.functions.Value = {
	name = "Value",
	icon = "icon16/help.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = math.Round(item.price / 1.32)
		client:Notify("Item is sellable for " .. ix.currency.Get(sellprice) .. ".")
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1") and !item:GetData("equip")
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
				if (item.functions.EquipUn and item.functions.EquipUn.OnRun) then
					item.functions.EquipUn.OnRun(item)
				end
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

function ITEM:OnInstanced()
	if !self:GetData("durability") then
		self:SetData("durability", 0)
	end
end

function ITEM:OnRemoved()
	if (self:GetData("equip") == true) then
		local inventory = ix.item.inventories[self.invID]
		local owner = inventory and inventory:GetOwner()

		if (IsValid(owner) and owner:IsPlayer()) then
			owner:SetNetVar("ixhasanomdetector", false)
			owner:SetData("ixhasanomdetector", false)
			ix.plugin.list["anomalydetector"]:StopDetectorTimer(owner)
			self:SetData("equip", false)
			self:SetData("equipSlot", nil)
		end
	end
end

function ITEM:OnLoadout()
	if self:GetData("equip") then
		self:SetData("equip", false)
	end
end

function ITEM:OnEquipped()
    if IsValid(self.player) then
        self.player:EmitSound("stalker/inventory/inv_dozimetr.ogg")
    end
end

function ITEM:OnUnequipped()
    if IsValid(self.player) then
        self.player:EmitSound("cw/switch1.wav")
    end
end