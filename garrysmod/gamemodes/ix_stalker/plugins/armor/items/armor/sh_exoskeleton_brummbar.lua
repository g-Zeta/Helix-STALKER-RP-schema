ITEM.name = "Brummbar Exoskeleton"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/merc_exo_outfit.mdl"
ITEM.description = "Heavy armored suit used by Mercenaries"
ITEM.longdesc = "A limited-production exoskeleton designed to meet the requirements of mercenaries. Certain features were customized for the specific missions carried out by these professionals."

ITEM.price = 63000
ITEM.weight = 10.5

ITEM.flag = "K"

ITEM.radProt = 3

ITEM.res = {
	["Bullet"] = 0.38,
	["Impact"] = 0.34,
	["Slash"] = 0.48,
	["Burn"] = 0.10,
	["Shock"] = 0.12,
	["Chemical"] = 0.08,
	["Radiation"] = 0.32,
	["Psi"] = 0.33,
}

ITEM.BRC = 60
ITEM.artifactcontainers = {"4"}

ITEM.img = Material("stalker2/ui/armor/suit_exo_brummbar.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"

ITEM.isGasmask = true
ITEM.isHelmet = true

ITEM.replacements = "models/nasca/stalker/male_exo_merc.mdl"