ITEM.name = "Kolobok"
ITEM.model = "models/stalker/artifacts/kolobok.mdl"
ITEM.description = "A very spikey artifact."
ITEM.longdesc = "A rare artifact, the Kolobok is sought across the zone for its above-average ability to heal wounds of all kinds that the user may incur, at the cost of being highly radioactive. Scientists say that the Kolobok alters the bearer's genetic code, and those that use it often find this to be true.\n\nStalkers that use the Kolobok find their skin hardening, first with only a stiffness and further becoming almost stone-like. Sensitivity drops to the point where the user feels constantly numb, and prolonged usage can result in loss of motor function. Curiously, these effects are often compared to the armored flesh of some Mutants across the zone, begging the question of the connection between the two."

ITEM.price = 12000
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
	["Radiation"] = -0.20,
}

ITEM.buff = "heal"
ITEM.buffval = 3

ITEM.debuff = "rads"
ITEM.debuffval = 2

ITEM.img = Material("stalkerCoP/ui/artifacts/kolobok.png")