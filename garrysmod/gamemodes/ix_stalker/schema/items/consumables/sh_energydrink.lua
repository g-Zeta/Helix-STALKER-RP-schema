ITEM.name = "Energy Drink"
ITEM.description = "An aluminium can with energy drink inside."
ITEM.longdesc = "This energy drink is one of the best on the market, and provides long-lasting energy for stalkers who need to stay clear-headed, and light-footed for a while."
ITEM.model = "models/flaymi/anomaly/dynamics/devices/dev_drink_stalker.mdl"

ITEM.width = 1
ITEM.height = 1
ITEM.weight = 0.275

ITEM.price = 450

ITEM.hunger = 5
ITEM.thirst = 15

ITEM.duration = 150
ITEM.stamBuff = 1

ITEM.isDrink = true

ITEM.sound = "stalker/inventory/inv_drink_can.mp3"
ITEM:Hook("use", function(item)
	item.player:EmitSound(item.sound or "items/battery_pickup.wav")
	ix.chat.Send(item.player, "iteminternal", "pops up a can of "..item.name.." and drinks it.", false)
end)

ITEM.img = Material("stalker2/ui/consumables/energy_drink.png")