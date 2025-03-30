ITEM.name = "Gravi"
ITEM.model = "models/stalker/artifacts/gravi.mdl"
ITEM.description = "A lumpy artifact."
ITEM.longdesc = "This artifact forms from metallic substances exposed to gravitational anomalies for prolonged periods. This makes it capable of sustaining an antigravitational field, and many stalkers use it to reduce the weight of their backpacks. The Gravi can only be cut into pieces using plasma tools. This artifact exhibits a density and hardness surpassing that of diamond.\n\nMany stalkers also report several odd side effects of wearing the Gravi; the fluctuations in force the artifact generates often upsets the equilibrium of the inner ear canal, leading to feelings of nausea, dizziness and lightheadedness."

ITEM.price = 12000
ITEM.weight = 0.65

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

ITEM.buff = "weight"
ITEM.buffval = 8

ITEM.debuff = "rads"
ITEM.debuffval = 2

ITEM.img = Material("stalkerCoP/ui/artifacts/gravi.png")