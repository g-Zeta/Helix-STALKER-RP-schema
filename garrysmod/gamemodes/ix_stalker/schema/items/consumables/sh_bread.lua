ITEM.name = "Bread"
ITEM.description = "A loaf of bread."
ITEM.longdesc = "No bakers have ever been identified in the Zone, but this bread is neither contaminated nor radioactive, being fresh and quite edible. \nAt least no complaints have been reported thus far."
ITEM.model = "models/flaymi/anomaly/dynamics/devices/dev_bred.mdl"

ITEM.width = 1
ITEM.height = 1
ITEM.weight = 0.1

ITEM.price = 100

ITEM.hunger = 10
ITEM.thirst = -5

ITEM.isFood = true

ITEM.sound = "stalker/inventory/inv_eat_bread.mp3"
ITEM:Hook("use", function(item)
	item.player:EmitSound(item.sound or "items/battery_pickup.wav")
	ix.chat.Send(item.player, "iteminternal", "eats a bit of their "..item.name..".", false)
end)

ITEM.img = Material("stalker2/ui/consumables/bread.png")