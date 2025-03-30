ITEM.name = "Battery"
ITEM.model = "models/stalker/artifacts/battery.mdl"
ITEM.description = "An electric artifact."
ITEM.longdesc = "The composition of this artifact includes electrostatic elements, though the conditions of its formation remain unidentified by science. The high-frequency alternating current glowing within does not cause burns upon contact. It is observed to make its user feel energized, though prolonged use causes growing fatigue, tiredness, and in some cases pain.\n\nIt is believed the Battery disables natural limits to energy consumption organisms usually utilize to not overextend themselves, offering increased physical ability at the cost of harming the user by way of numbing tiredness itself. Sometimes it can also trigger insomnia and anxiety."

ITEM.price = 6000
ITEM.weight = 0.4

ITEM.res = {
	["Blast"] = 0.00,
	["Bullet"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = 0.00,
	["Chemical"] = 0.00,
	["Shock"] = 0.00,
	["Psi"] = 0.00,
	["Radiation"] = -0.10,
}

ITEM.buff = "endbuff"
ITEM.buffval = 1

ITEM.debuff = "rads"
ITEM.debuffval = 1

ITEM.img = Material("stalkerCoP/ui/artifacts/battery.png")