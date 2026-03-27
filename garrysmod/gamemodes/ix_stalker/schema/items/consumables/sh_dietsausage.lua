ITEM.name = "Diet Sausage"
ITEM.description = "A small lump of sausage."
ITEM.longdesc = "For better or worse, this sausage - a mix of chicken and a soy substitute - is often a stalker's breakfast, lunch and dinner in one. \nCan be stored for a long time due to high preservative content."
ITEM.model = "models/flaymi/anomaly/dynamics/devices/dev_sausage.mdl"

ITEM.width = 1
ITEM.height = 1
ITEM.weight = 0.15

ITEM.price = 200

ITEM.hunger = 15
ITEM.thirst = -5

ITEM.isFood = true

ITEM.sound = "stalker/inventory/inv_eat_mutant_food.mp3"
ITEM:Hook("use", function(item)
	item.player:EmitSound(item.sound or "items/battery_pickup.wav")
	ix.chat.Send(item.player, "iteminternal", "eats a bit of their "..item.name..".", false)
end)

ITEM.img = Material("stalker2/ui/consumables/sausage.png")