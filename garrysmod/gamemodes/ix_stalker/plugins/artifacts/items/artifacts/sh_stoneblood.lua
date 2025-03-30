ITEM.name = "Stone Blood"
ITEM.model = "models/stalker/artifacts/stoneblood.mdl"
ITEM.description = "A chemical artifact composed of pressed and fossilized planet matter, animal debris and soil."
ITEM.longdesc = "Curiously, tests applied to the Stone Blood to date the fossils contained within show that the artifact is made of recent matter, with occasional findings of fossils resembling human bones. This suggests it forms from chemical anomalies that melt matter and apply immense pressure. The artifact redirects deadly chemicals into itself, shielding the user while emitting minor radiation as a side effect.\n\nStalker superstition claims the Stone Blood is made from stalkers who fell into acidic baths, and carrying it means taking their spirits across the Zone. Others believe it traps a stalker’s soul forever. Users notice hard calluses forming on their skin, which pessimistic stalkers interpret as the artifact trying to drag them in, hardening them until they succumb to the same pressure that formed it."

ITEM.price = 2000
ITEM.weight = 0.55

ITEM.res = {
	["Blast"] = 0.00,
	["Bullet"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = 0.00,
	["Chemical"] = 0.20,
	["Shock"] = 0.00,
	["Psi"] = 0.00,
	["Radiation"] = -0.10,
}

ITEM.debuff = "rads"
ITEM.debuffval = 1

ITEM.img = Material("stalkerCoP/ui/artifacts/stoneblood.png")