ITEM.name = "Headlamp"
ITEM.model = "models/kek1ch/dev_torch_light.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A standard headmounted flashlight that can be toggled."
ITEM.category = "Electronics"
ITEM.flag = "1"
ITEM.price = 2000
ITEM.repairCost = ITEM.price/100*1
ITEM.weight = 0.25
ITEM.isFlashlight = true

ITEM:Hook("drop", function(item)
	if (item:GetData("equip")) then
		item:SetData("equip", false)
	end
	item.player:Flashlight(false)
end)

ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/stalker/equip.png",
	OnRun = function(item)
		item:SetData("equip", true)
		item.player:EmitSound("stalkersound/inv_slot.mp3")
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetData("equip") != true
	end
}

ITEM.functions.EquipUn = {
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/stalker/unequip.png",
	OnRun = function(item)
		item:SetData("equip", false)
		item.player:EmitSound("stalkersound/inv_slot.mp3")
		item.player:Flashlight(false)
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetData("equip") == true
	end
}

ITEM.functions.Sell = {
	name = "Sell",
	icon = "icon16/stalker/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item.price/2
		sellprice = math.Round(sellprice)
		client:Notify( "Sold for "..(sellprice).." rubles." )
		client:GetCharacter():GiveMoney(sellprice)
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
		local sellprice = item.price/2
		sellprice = math.Round(sellprice)
		client:Notify( "Item is sellable for "..(sellprice).." rubles." )
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1")
	end
}
