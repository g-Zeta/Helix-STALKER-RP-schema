ITEM.name = "PDA base"
ITEM.model = "models/deadbodies/dead_male_civilian_radio.mdl"
ITEM.description = "A PDA used for communicating with other people."
ITEM.width = 1
ITEM.height = 1
ITEM.price = 150
ITEM.category = "Electronics"
ITEM.flag = "1"
ITEM.isPDA = true
ITEM.weaponCategory = "PDA"

ITEM.equipIcon = Material("materials/vgui/ui/stalker/misc/equip.png")

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

function ITEM:CanTransfer(oldInventory, newInventory)
	if (newInventory and self:GetData("equip")) then
		return false
	end

	return true
end

ITEM.functions.Equip = { -- sorry, for name order.
	name = "Equip",
	tip = "useTip",
	icon = "icon16/stalker/equip.png",
	sound = "stalkersound/inv_dozimetr.ogg",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local items = character:GetInventory():GetItems()
		local wepslots = character:GetData("wepSlots",{})

		for _, v in pairs(items) do
			if (v.id ~= item.id) and (v.weaponCategory == item.weaponCategory) and v:GetData("equip") then
				item.player:Notify("You are already equipping a PDA.")
				return false
			end
		end

		wepslots[item.weaponCategory] = item.Name
		character:SetData("wepSlots",wepslots)
		character:SetData("pdaavatar", item:GetData("avatar", "vgui/icons/face_31.png"))
		character:SetData("pdanickname", item:GetData("nickname", item.player:GetName()))
		item:SetData("equip", true)
		character:SetData("pdaequipped", true)

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
	sound = "cw/switch1.wav",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local wepslots = character:GetData("wepSlots",{})
		item:SetData("equip", false)
		character:SetData("pdaequipped", false)
		character:SetData("pdanickname", "NIL")
		wepslots[item.weaponCategory] = nil
		character:SetData("wepSlots",wepslots)
		return false 
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true
	end
}

ITEM.functions.Sell = {
	name = "Sell",
	icon = "icon16/stalker/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item.price
		sellprice = math.Round(sellprice*0.75)
		client:Notify( "Sold for "..(sellprice).." rubles." )
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
		local sellprice = item:GetData("RealPrice") or item.price
		sellprice = math.Round(sellprice*0.75)
		client:Notify( "Item is sellable for "..(sellprice).." rubles." )
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1") and !item:GetData("equip")
	end
}

ITEM.functions.setavatar = {
	name = "Select Avatar",
	tip = "useTip",
	icon = "icon16/stalker/customize.png",
	OnRun = function(item)
		item.player:RequestString("Set Avatar", "What avatar do you want this PDA to use? Select any material path.", function(text)
			if text != "" then
				item:SetData("avatar", text)
				item:GetOwner():GetCharacter():SetData("pdaavatar", text)
			end
		end, item:GetData("avatar", "vgui/icons/face_31.png"))
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client)
	end
}

ITEM.functions.setnickname = {
	name = "Set your PDA username",
	tip = "useTip",
	icon = "icon16/stalker/customize.png",
	OnRun = function(item)
		item.player:RequestString("Set username", "What username do you want to use with this PDA?", function(text)
			item:SetData("nickname", text)
			item:GetOwner():GetCharacter():SetData("pdanickname", text)
		end, item:GetData("nickname", item.player:Name()))
		return false
	end,
}

function ITEM:OnEquipped()
	self.player:GetCharacter():SetData("pdaavatar", self:GetData("avatar", "lutz"))
	self.player:GetCharacter():SetData("pdanickname", self:GetData("nickname", "lutz"))
end

function ITEM:OnUnEquipped()

end

function ITEM:OnInstanced()
	self:SetData("avatar", "vgui/icons/face_31.png")
	self:SetData("nickname", "NEW_USER")
end
