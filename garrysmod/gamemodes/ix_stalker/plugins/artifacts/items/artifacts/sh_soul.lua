ITEM.name = "Soul"
ITEM.model = "models/stalker/artifacts/soul.mdl"
ITEM.description = "A spherical artifact with a galaxy-like pattern in the interior."
ITEM.longdesc = "A rare artifact seemingly formed of organic materials, which nonetheless has a striking appearance. The Soul increases the body's overall recovery rate from any sort of damage through unknown means, but does not accelerate the accumulation of toxins. Despite its apparent fragility, this artifact remains impervious to destruction via mechanical, thermal, or chemical means.\n\nThe healing effect of the Soul lends itself to being used by even healthy stalkers, as if one isn’t wounded it eliminates aches and pains, an easy desire of any stalker in the field. However, the Ecologists recommend against prolonged use of this artifact for fear of addiction. In fact, many stalkers have been called ‘excessively paranoid’ after using the Soul for periods longer than a week."

ITEM.price = 6000
ITEM.weight = 0.40

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
ITEM.buffval = 2

ITEM.debuff = "rads"
ITEM.debuffval = 2

ITEM.img = Material("stalkerCoP/ui/artifacts/soul.png")