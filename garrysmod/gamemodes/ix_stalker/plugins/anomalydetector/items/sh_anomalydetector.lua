ITEM.name = "Anomaly Detector"
ITEM.model = "models/flaymi/anomaly/dynamics/devices/dev_decoder.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Electronics"
ITEM.price = 1600
ITEM.weight = 0.5
ITEM.description = "A device that beeps when anomalies are close."
ITEM.isAnomalydetector = true
ITEM.flag = "1"
ITEM.equipIcon = Material("materials/vgui/ui/stalker/misc/equip.png")
ITEM.weaponCategory = "Anomaly Detector"
ITEM.img = Material("spawnicons/models/flaymi/anomaly/dynamics/devices/dev_decoder.png")

--[[
if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		if (item:GetData("equip")) then
			surface.SetDrawColor(110, 255, 110, 255)
		else
			surface.SetDrawColor(255, 110, 110, 255)
		end

		surface.SetMaterial(item.equipIcon)
		surface.DrawTexturedRect(w-23,h-23,19,19)
	end
end
]]
ITEM.functions.Equip = { -- sorry, for name order.
	name = "Equip",
	tip = "useTip",
	icon = "icon16/stalker/equip.png",
	OnRun = function(item, data)
		local client = item.player
		local character = client:GetCharacter()
		local wepslots = character:GetData("wepSlots",{})

		if item:GetData("equip") then
			client:NotifyLocalized("You are already equipping this PDA.")
			return false
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
		item:OnEquipped()
		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		return !IsValid(item.entity) and IsValid(client) and !item:GetData("equip")
	end
}

ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/stalker/unequip.png",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local wepslots = character:GetData("wepSlots",{})
		item:SetData("equip", false)
		item:SetData("equipSlot", nil)
		item.player:SetNetVar("ixhasanomdetector", false)
		item.player:SetData("ixhasanomdetector", false)
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
    end;
end);

ITEM.functions.Sell = {
	name = "Sell",
	icon = "icon16/stalker/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		client:Notify( "Sold for "..(item.price).." rubles." )
		client:GetCharacter():GiveMoney(item.price)
		
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
		client:Notify( "Item is sellable for "..(item.price).." rubles." )
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1") and !item:GetData("equip")
	end
}

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