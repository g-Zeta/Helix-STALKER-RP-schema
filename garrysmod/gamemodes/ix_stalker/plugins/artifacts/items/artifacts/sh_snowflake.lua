ITEM.name = "Snowflake"
ITEM.model = "models/stalker/artifacts/snowflake.mdl"
ITEM.description = "A blue spikey artifact."
ITEM.longdesc = "An immensely bright artifact sometimes confused as a Kolobok (or perhaps a derivative of one that found its way into an electro anomaly), the Snowflake increases the speed of those who use it, at the cost of periodically discharging ionizing radiation. It is also known to have an electrostimulative effect which significantly improves the user's vitality and muscle tone.\n\nThough the name Snowflake would seem to imply a cold-based artifact, the Snowflake is only mildly cold to the touch. According to some stalker researchers, the Snowflake actually increases the cellular processes relating to energy generation of an organism to achieve its increase in energy. Stalker legend would tell you that, were you to use the Snowflake for an indefinite amount of time, your body would noticeably age until you died of old age, but this may merely stem from the fatigue stalkers experience due to a lack of eating when using the artifact for prolonged amounts of time."

ITEM.price = 18000
ITEM.weight = 0.30

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
ITEM.buffval = 6

ITEM.debuff = "rads"
ITEM.debuffval = 2

ITEM.img = Material("stalkerCoP/ui/artifacts/snowflake.png")