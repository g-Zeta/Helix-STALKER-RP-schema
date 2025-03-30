ITEM.name = "Night Star"
ITEM.model = "models/stalker/artifacts/nightstar.mdl"
ITEM.description = "A glowing yellow spiky artifact."
ITEM.longdesc = "This artifact resembles in many ways an Urchin, but the quills are soft to the touch and offer no pain, instead glowing a bright yellow. Formed in gravitational anomalies and often at night, the Night Star alters gravity in a small manner within a radius, reducing the impact of fast-moving projectiles against the user. Though it is commonly used to reduce the weight of equipment. As a counterside, it emits minor radiation.\n\nPopular among stalkers and sought out by scientists, the Night Star provides an additional benefit; when worn during rest, nightmares do not occur for the user. Prolonged usage has been said to increase the desire to sleep, and some stalkers tell stories of those that became obsessed with the comfort of the sleep provided by this artifact, using it until they never woke up again."

ITEM.price = 6000
ITEM.weight = 0.60

ITEM.res = {
	["Blast"] = 0.10,
	["Bullet"] = 0.10,
	["Slash"] = 0.00,
	["Fall"] = 0.10,
	["Burn"] = 0.00,
	["Chemical"] = 0.00,
	["Shock"] = 0.00,
	["Psi"] = 0.00,
	["Radiation"] = -0.10,
}

ITEM.buff = "weight"
ITEM.buffval = 4

ITEM.debuff = "rads"
ITEM.debuffval = 1

ITEM.img = Material("stalkerCoP/ui/artifacts/nightstar.png")