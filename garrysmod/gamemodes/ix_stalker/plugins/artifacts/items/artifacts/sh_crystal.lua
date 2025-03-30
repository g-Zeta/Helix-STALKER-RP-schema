ITEM.name = "Crystal"
ITEM.model = "models/stalker/artifacts/crystal.mdl"
ITEM.description = "A bright red crystalline structure, with an apparent flame encased within."
ITEM.longdesc = "Primarily formed within thermal anomalies, scientists believe the Crystal is made up of heavy metals which have been flash-heated by anomalies into a unique structure. When held, the Crystal is noticeably cool and pools any excessive heat into itself, expelling radiation as a result.\n\nThough short term use of it elicits almost no reaction to the user beyond increased radiation. Long term use or multiple Crystals being used can result in minor aches in the extremities, likely a result of pulling natural body heat away."

ITEM.price = 2000
ITEM.weight = 0.65

ITEM.res = {
	["Blast"] = 0.00,
	["Bullet"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = 0.20,
	["Chemical"] = 0.00,
	["Shock"] = 0.00,
	["Psi"] = 0.00,
	["Radiation"] = -0.10,
}

ITEM.debuff = "rads"
ITEM.debuffval = 1

ITEM.img = Material("stalkerCoP/ui/artifacts/crystal.png")