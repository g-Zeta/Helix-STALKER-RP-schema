ITEM.name = "Geiger Counter"
ITEM.model = "models/flaymi/anomaly/dynamics/devices/dev_datchik1.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Electronics"
ITEM.price = 1500
ITEM.weight = 0.5
ITEM.isGeiger = true
ITEM.flag = "1"
ITEM.equipIcon = Material("materials/vgui/ui/stalker/misc/equip.png")
ITEM.weaponCategory = "Geiger Counter"
ITEM.img = Material("spawnicons/models/flaymi/anomaly/dynamics/devices/dev_datchik1.png")

function ITEM:GetDescription()
	return "This device detects the radiation levels nearby, alarming you if they increase."
end

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
		local char = client:GetCharacter()
		client.carryWeapons = client.carryWeapons or {}
		
		if item:GetData("equip") then
			client:NotifyLocalized("You are already equipping a gieger counter detector.")

			return false
		end
		
		if client.carryWeapons[item.weaponCategory] then
			client:NotifyLocalized("weaponSlotFilled", item.weaponCategory)
			return false
		end
		
		client.carryWeapons[item.weaponCategory] = item.Name

		item:SetData("equip", true)
		if (data and data.equipSlot) then
			if (char) then
				local inv = char:GetInventory()
				if (inv) then
					for _, v in pairs(inv:GetItems()) do
						if (v.id != item.id and v.isGeiger and v:GetData("equip") and v:GetData("equipSlot") == data.equipSlot) then
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
		item.player:SetNetVar("ixhasgeiger", true)
		item.player:SetData("ixhasgeiger", true)
		item:OnEquipped()

		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true
	end
}

ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/stalker/unequip.png",
	OnRun = function(item)
		local client = item.player
		item:SetData("equip", false)
		item:SetData("equipSlot", nil)
		item.player:SetNetVar("ixhasgeiger", false)
		item.player:SetData("ixhasgeiger", false)
		
		if client.carryWeapons then
			client.carryWeapons[item.weaponCategory] = nil
		end
		
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
    local character = client:GetChar();

    if (item:GetData("equip")) then
		item:SetData("equip", false)
		item:SetData("equipSlot", nil)
		item.player:SetNetVar("ixhasgeiger", false)
		item.player:SetData("ixhasgeiger", false)
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
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1")
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
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1")
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