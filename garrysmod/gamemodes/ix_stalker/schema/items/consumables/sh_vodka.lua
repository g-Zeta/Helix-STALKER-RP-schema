ITEM.name = "Vodka"
ITEM.description = "A bottle with a clear substance inside."
ITEM.longdesc = "A clear distilled liquor composed of water and ethyl alcohol. Vodka is made from a fermented substance of either grain, rye, wheat, potatoes, or sugar beet molasses. Its alcoholic concentration usually ranges between 35 to 70 per cent by volume."
ITEM.model = "models/flaymi/anomaly/dynamics/devices/dev_vodka.mdl"

ITEM.width = 1
ITEM.height = 1
ITEM.weight = 0.45

ITEM.price = 500

ITEM.hunger = -10
ITEM.thirst = -5

ITEM.duration = 10
ITEM.radrem = 1

ITEM.isDrink = true

ITEM.sound = "stalker/inventory/inv_drink_vodka.mp3"
ITEM:Hook("use", function(item)
	item.player:EmitSound(item.sound or "items/battery_pickup.wav")
	ix.chat.Send(item.player, "iteminternal", "takes a swig of their "..item.name..".", false)
end)

ITEM.img = Material("stalker2/ui/consumables/vodka.png")