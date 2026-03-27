ITEM.name = "Water"
ITEM.description = "A bottle containing water."
ITEM.longdesc = "A bottle containing water which has been cleansed inside the zone. The result is a radiation-free product, albeit it still has a sour taste."
ITEM.model = "models/flaymi/anomaly/dynamics/devices/dev_mineral_water.mdl"

ITEM.width = 1
ITEM.height = 1
ITEM.weight = 0.35

ITEM.price = 300

ITEM.thirst = 45

ITEM.isDrink = true

ITEM.sound = "stalker/inventory/inv_drink_large.mp3"
ITEM:Hook("use", function(item)
	item.player:EmitSound(item.sound or "items/battery_pickup.wav")
	ix.chat.Send(item.player, "iteminternal", "opens a bottle of "..item.name.." and drinks it.", false)
end)

ITEM.img = Material("stalker2/ui/consumables/water.png")