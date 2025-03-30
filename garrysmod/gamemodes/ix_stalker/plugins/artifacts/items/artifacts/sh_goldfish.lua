ITEM.name = "Goldfish"
ITEM.model = "models/stalker/artifacts/goldfish.mdl"
ITEM.description = "A shiny golden artifact."
ITEM.longdesc = "Resulting from the interaction of a large number of gravitational anomalies, this artifact produces its own internally directed gravity field. It renders items within its range nearly weightless, allowing stalkers to carry more equipment.\n\nHowever, the gravitational influences upon the body can compound into health issues over prolonged use, often compared to time spent in low-gravity environments, much to the surprise of scientists given the more powerful gravitational forces of the earth. Continued use most often results in sickness due to the loss of pressure and displacement of fluids in the body. Generally not too dangerous, but stalkers suggest taking breaks from it."

ITEM.price = 18000
ITEM.weight = 0.35

ITEM.res = {
	["Blast"] = 0.00,
	["Bullet"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = 0.00,
	["Chemical"] = 0.00,
	["Shock"] = 0.00,
	["Psi"] = 0.00,
	["Radiation"] = -0.30,
}

ITEM.buff = "weight"
ITEM.buffval = 12

ITEM.debuff = "rads"
ITEM.debuffval = 3

ITEM.img = Material("stalkerCoP/ui/artifacts/goldfish.png")