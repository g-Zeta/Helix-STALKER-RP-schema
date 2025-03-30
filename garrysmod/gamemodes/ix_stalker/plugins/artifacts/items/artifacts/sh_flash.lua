ITEM.name = "Flash"
ITEM.model = "models/stalker/artifacts/flash.mdl"
ITEM.description = "A round artifact that emits a lot of light."
ITEM.longdesc = "Cousin to the Sparkler, the Flash is an orb of laten electrical charges and discharges, constantly shifting electrical currents inside it. Any electric discharges in the vicinity are drawn into the artifact, charging it to approximately 5,000 volts. Once it is fully charged, it will start to ‘leak’ the energy in small amounts, usually felt to the user as small static reactions. Additionally, it emits radiation naturally.\n\nLong-term users of this artifact describe ‘phantom pains’ across their body whenever it is charging. Further, those that are wearing it when it discharges will notice lichtenberg figures crawling across their skin; the scars left behind by lightning strikes. Ecologists believe the Flash is still using the wearer as a conduit for its charging, with the pains being related to the charging and the scars appearing where the electricity traveled. These scars eventually disappear within a few months."

ITEM.price = 4000
ITEM.weight = 0.30

ITEM.res = {
	["Blast"] = 0.00,
	["Bullet"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = 0.00,
	["Chemical"] = 0.00,
	["Shock"] = 0.30,
	["Psi"] = 0.00,
	["Radiation"] = -0.20,
}

ITEM.debuff = "rads"
ITEM.debuffval = 2

ITEM.img = Material("stalkerCoP/ui/artifacts/flash.png")