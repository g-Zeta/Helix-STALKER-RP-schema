ITEM.name = "Flame"
ITEM.model = "models/stalker/artifacts/flame.mdl"
ITEM.description = "A flaming round artifact."
ITEM.longdesc = "The ultimate in coagulant artifacts, this is an extremely rare and powerful artifact. Beyond the power of the Mama’s Beads and the Eye, the Flame can close all but the most serious of wounds nearly instantly, but is also the most radioactive of the three. Even so, this artifact is worth a massive amount of rubles to most traders, and with good reason - it forms only in the most dangerous of thermal anomalies.\n\nThose that use the Flame find their skin to become increasingly sensitive, as if the artifact desires the user to become wounded more so that it may be used more. Some stalkers believe the Flame acts as a symbiote, ensuring the user will always have use of it."

ITEM.price = 18000
ITEM.weight = 0.50

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

ITEM.buff = "woundheal"
ITEM.buffval = 4

ITEM.debuff = "rads"
ITEM.debuffval = 3

ITEM.img = Material("stalkerCoP/ui/artifacts/flame.png")