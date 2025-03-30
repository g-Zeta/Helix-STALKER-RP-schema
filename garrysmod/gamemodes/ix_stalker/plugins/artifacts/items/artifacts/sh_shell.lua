ITEM.name = "Shell"
ITEM.model = "models/stalker/artifacts/shell.mdl"
ITEM.description = "A blue, semit-ransparent artifact."
ITEM.longdesc = "Formerly considered to be useless, this artifact was discovered to stimulate the nervous system when kept in constant contact with the body. It helps to replenish the energy of its user. This effect generates radiation as a side effect.\n\nThis artifact is known amongst stalkers as a high-value artifact, netting a handsome sum and a highly valued boost in energy. However, long-form studies have shown that the Shell increases activity of the nervous system with no limit. Senses are heightened, reaction times are increased and movements operate with lower and lower limits. Though rare, those who push beyond this are likely to succumb to painful seizures and spasms, their bodies no longer able to handle the increased thresholds."

ITEM.price = 12000
ITEM.weight = 0.45

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

ITEM.buff = "endbuff"
ITEM.buffval = 2

ITEM.debuff = "rads"
ITEM.debuffval = 2

ITEM.img = Material("stalkerCoP/ui/artifacts/shell.png")