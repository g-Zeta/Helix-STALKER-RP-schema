ITEM.name = "Steel Helmet"
ITEM.model = "models/ethprops/suits/hardhat.mdl"
ITEM.description = "A helmet made of steel."
ITEM.longdesc = "Formerly used by soldiers of the USSR, it provides no protection against anomalies or radiation, but is still useful in battle. It is rarely used but some still favor it for its protective qualities against psi and ballistic threats."

ITEM.price = 18500
ITEM.weight = 2.5

ITEM.flag = "2"

ITEM.res = {
	["Bullet"] = 0.02,
	["Blast"] = 0.02,
	["Slash"] = 0.02,
	["Fall"] = 0.02,
	["Burn"] = 0.0,
	["Shock"] = 0.0,
	["Chemical"] = 0.0,
	["Psi"] = 0.25,
	["Radiation"] = 0.0,
}

ITEM.ballisticlevels = {"ll", "0"}

ITEM.img = Material("stalkerCoP/ui/headgear/headgear_helmet_steel.png")

ITEM.isHelmet = true