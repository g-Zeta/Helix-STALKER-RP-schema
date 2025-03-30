ITEM.name = "Firefly"
ITEM.model = "models/stalker/artifacts/firefly.mdl"
ITEM.description = "Beautiful shiny artifact."
ITEM.longdesc = "One of the rarest artifacts in the Zone, the Firefly is the ultimate in healing ability. Through matters totally unknown to science, it increases and augments metabolism of anyone wounded to restore them, even from the brink of death. Though it emits a great amount of radiation.\n\nFew have ever seen a Firefly in person, and legend persists that the artifact could even revive the recently deceased - a belief that even the most pessimistic and realist stalkers secretly hope to be true. Perhaps it is true, but rarely does the Zone give without taking, too."

ITEM.price = 18000
ITEM.weight = 0.50

ITEM.res = {
	["Blast"] = 0.00,
	["Bullet"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = 0.00,
	["Chemical"] = 0.00,
	["Shock"] = 0.00,
	["Psi"] = 0.00,
	["Radiation"] = -0.30,
}

ITEM.buff = "heal"
ITEM.buffval = 4

ITEM.debuff = "rads"
ITEM.debuffval = 3

ITEM.img = Material("stalkerCoP/ui/artifacts/firefly.png")