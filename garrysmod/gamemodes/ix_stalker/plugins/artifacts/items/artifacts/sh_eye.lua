ITEM.name = "Eye"
ITEM.model = "models/stalker/artifacts/eye.mdl"
ITEM.description = "A rarer artifact in the shape of a glowing human eye."
ITEM.longdesc = "This artifact vastly increases the body’s metabolism, boosting the body’s ability to clot wounds considerably. It incurs a larger radioactive cost, however.\n\nThe Eye has been a good-luck charm for Stalkers since the early days, believed by the Veterans to bring goodwill to any who keep it close. While possibly true, an equally likely reason is that the Eye boosts Endorphin production in addition to its other effects, which can be addicting for some. Even if the effect of luck is placebo, the bounty for selling an Eye could be considered fortune enough."

ITEM.price = 12000
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

ITEM.buff = "woundheal"
ITEM.buffval = 2

ITEM.debuff = "rads"
ITEM.debuffval = 2

ITEM.img = Material("stalkerCoP/ui/artifacts/eye.png")