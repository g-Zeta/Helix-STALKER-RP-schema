ITEM.name = "Exoskeleton"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/exo_outfit.mdl"
ITEM.description = "An experimental sample of a military exoskeleton."
ITEM.longdesc = "A relatively common exoskeleton. Its ability to handle heavy loads has enabled the integration of a more sophisticated armored suit capable of facing the Zone's myriad challenges. The primary downside lies in the elevated price tag."

ITEM.price = 65500
ITEM.weight = 15

ITEM.flag = "A"

ITEM.radProt = 0.60

ITEM.res = {
	["Bullet"] = 0.35,
	["Blast"] = 0.35,
	["Slash"] = 0.35,
	["Fall"] = 0.35,
	["Burn"] = 0.23,
	["Shock"] = 0.325,
	["Chemical"] = 0.325,
	["Psi"] = 0.50,
	["Radiation"] = 0.60,
}

ITEM.ballisticlevels = {"lV", "lll-a", "lll", "lll+", "lll"}
ITEM.artifactcontainers = {"4"}

ITEM.img = Material("stalker2/ui/armor/suit_exo_loner.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"

ITEM.isGasmask = true
ITEM.isHelmet = true

ITEM.replacements = "models/nasca/stalker/male_exo_lone.mdl"