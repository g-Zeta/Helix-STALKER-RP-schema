ITEM.name = "Ballistic Helmet"
ITEM.model = "models/ethprops/suits/hardhat.mdl"
ITEM.description = "An outdated metal ballistic helmet."
ITEM.longdesc = "A conventional, if quite outdated, combat helmet that's more than capable of stopping handgun rounds and reflecting psi waves, but with almost no protection against anomalies or radiation."

ITEM.price = 12500
ITEM.weight = 2.5

ITEM.flag = "2"

ITEM.res = {
	["Bullet"] = 0.17,
	["Impact"] = 0,
	["Slash"] = 0.03,
	["Burn"] = 0.01,
	["Shock"] = 0.01,
	["Chemical"] = 0.01,
	["Radiation"] = 0.01,
	["Psi"] = 0.12,
}

ITEM.BRC = 25

ITEM.img = Material("stalkerCoP/ui/headgear/headgear_helmet_steel.png")

ITEM.isHelmet = true