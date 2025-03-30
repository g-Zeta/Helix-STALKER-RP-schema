ITEM.name = "Mama's Beads"
ITEM.model = "models/stalker/artifacts/mamas_beads.mdl"
ITEM.description = "A helix-shaped, pulsating artifact."
ITEM.longdesc = "A once-mysterious artifact, the Mama’s Beads still holds some secrets to the scientific community. This helix-shaped artifact, found at the center of thermal anomalies, emits a rhythmic pulse traveling from one end to the other. At the beginning of each pulse, it releases radiation. Upon completing a cycle, the artifact accelerates the metabolism of nearby organisms, significantly speeding up the healing and scabbing process of open wounds.\n\nNowadays, this artifact has become more common and better understood, though some enigmas persist. Users notice discoloration of the skin around their wounds. Initially, this discoloration is easily dismissed as a typical response to injury, appearing as a pink or reddish hue. However, with continued use, the skin takes on increasingly unusual colors, and the longer it is utilized, the more prolonged these effects become. Despite this, the full consequences of extended exposure to the artifact remain unclear."

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

ITEM.buff = "woundheal"
ITEM.buffval = 1

ITEM.debuff = "rads"
ITEM.debuffval = 1

ITEM.img = Material("stalkerCoP/ui/artifacts/mamas_beads.png")