ITEM.name = "Tourist's Delight"
ITEM.description = "A can with something edible inside."
ITEM.longdesc = "Canned meat with jello, seems to be up to standards. Eaten cold, hot, mixed with other food or on it's own, it's a great source of long-lasting meat. Make sure the seal isn't broken before opening."
ITEM.model = "models/flaymi/anomaly/dynamics/devices/dev_conserv.mdl"

ITEM.width = 1
ITEM.height = 1
ITEM.weight = 0.2

ITEM.price = 400

ITEM.hunger = 45
ITEM.thirst = -5

ITEM.isFood = true

ITEM.sound = "stalker/inventory/inv_eat_gum.mp3"
ITEM:Hook("use", function(item)
	item.player:EmitSound(item.sound or "items/battery_pickup.wav")
	ix.chat.Send(item.player, "iteminternal", "opens a can of "..item.name.." and eats its content.", false)
end)

ITEM.img = Material("stalker2/ui/consumables/canned_food.png")