ITEM.name = "Fireball"
ITEM.model = "models/stalker/artifacts/fireball.mdl"
ITEM.description = "A flame-based artifact."
ITEM.longdesc = "A favorite among stalkers, this artifact dissipates heat via an equalization process unknown to science. Despite appearing as a crystalized orb of fire, the Fireball maintains a temperature of 75° Fahrenheit in a radius around itself, which stalkers can use to lessen the ambient heat around them. However, it emits radiation during the cooling process.\n\nUnlike its weaker cousin, the Fireball does not endlessly take heat into itself, and so many stalkers utilize it as a makeshift campfire in the wild. Some utilize the Fireball for exceptional amounts of time, describing the feeling as reminding them of being home by the fire on a winter’s eve. The less superstitious believe the Fireball induces a placebo intoxication when used too long."

ITEM.price = 4000
ITEM.weight = 0.50

ITEM.res = {
	["Blast"] = 0.00,
	["Bullet"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = 0.30,
	["Chemical"] = 0.00,
	["Shock"] = 0.00,
	["Psi"] = 0.00,
	["Radiation"] = -0.20,
}

ITEM.debuff = "rads"
ITEM.debuffval = 2

ITEM.img = Material("stalkerCoP/ui/artifacts/fireball.png")