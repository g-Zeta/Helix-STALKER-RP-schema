ITEM.name = "Meat Chunk"
ITEM.model = "models/stalker/artifacts/meatchunk.mdl"
ITEM.description = "A wet artifact composed of animal tissue."
ITEM.longdesc = "The Meat Chunk is in essence a disembodied tumor, dragging exotic chemicals into itself and producing radioactive discharges with the excess energy. This process can save a user from many chemical anomalies, but stalkers recommend careful use.\n\nWhile Stalkers believe the Stone Blood is the crystalized soul of the dead, few ascribe such philosophy to the Meat Chunk. Most stalkers merely grit their teeth and wear it when necessary, throwing it away in their pack the second danger is gone. It doesn’t help that the Meat Chunk causes an excess in the development of secondary fluids in the user. Increased mucus generation in all forms is common, alongside an increased amount of tears and saliva generating after prolonged usage."

ITEM.price = 4000
ITEM.weight = 0.4

ITEM.res = {
	["Blast"] = 0.00,
	["Bullet"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = 0.00,
	["Chemical"] = 0.30,
	["Shock"] = 0.00,
	["Psi"] = 0.00,
	["Radiation"] = -0.20,
}

ITEM.debuff = "rads"
ITEM.debuffval = 2

ITEM.img = Material("stalkerCoP/ui/artifacts/meatchunk.png")