ITEM.name = "Sparkler"
ITEM.model = "models/stalker/artifacts/sparkler.mdl"
ITEM.description = "A silky-looking artifact."
ITEM.longdesc = "A wavy artifact resembling lightning frozen in a moment, the Sparkler is a common but still prized representative of artifacts formed by electrical anomalies. It relaxes fluctuations in electrical fields, resulting in a lessened effect of shocks applied to the user. However, the artifact naturally emits radiation as part of its internal composition.\n\nWhile the process of the Sparklers function isn’t totally understood, it is known that excess fluctuations of electricity are stored inside the artifact, which it naturally exudes in safe amounts. Those that use it often find themselves generating static electricity at a constant rate, and Sparklers placed in or near small electronics that require minimal electricity will actually power the device. Many stalkers keep Sparklers in the event of their flashlight or PDA dying."

ITEM.price = 2000
ITEM.weight = 0.40

ITEM.res = {
	["Blast"] = 0.00,
	["Bullet"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = 0.00,
	["Chemical"] = 0.00,
	["Shock"] = 0.20,
	["Psi"] = 0.00,
	["Radiation"] = -0.10,
}

ITEM.debuff = "rads"
ITEM.debuffval = 1

ITEM.img = Material("stalkerCoP/ui/artifacts/sparkler.png")