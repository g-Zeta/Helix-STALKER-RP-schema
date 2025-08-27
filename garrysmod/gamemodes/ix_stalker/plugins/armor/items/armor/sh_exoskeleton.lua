ITEM.name = "Exoskeleton"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/exo_outfit.mdl"
ITEM.description = "An sample of a military exoskeleton."
ITEM.longdesc = "A relatively common exoskeleton. Its ability to handle heavy loads has enabled the integration of a more sophisticated armored suit capable of facing the Zone's myriad challenges. The primary downside lies in the elevated price tag."

ITEM.price = 750000
ITEM.weight = 15

ITEM.flag = "A"

ITEM.radProt = 3

ITEM.res = {
	["Bullet"] = 0.34,
	["Impact"] = 0.31,
	["Slash"] = 0.45,
	["Burn"] = 0.08,
	["Shock"] = 0.08,
	["Chemical"] = 0.05,
	["Radiation"] = 0.29,
	["Psi"] = 0.31,
}

ITEM.BRC = 55
ITEM.artifactcontainers = {"4"}

ITEM.img = Material("stalker2/ui/armor/suit_exo_loner.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"

ITEM.replacements = "models/nasca/stalker/male_exo_lone.mdl"