ITEM.name = "Brummbar Exoskeleton"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/merc_exo_outfit.mdl"
ITEM.description = "Heavy armored suit used by Mercenaries"
ITEM.longdesc = "A limited-production exoskeleton designed to meet the requirements of mercenaries. Certain features were customized for the specific missions carried out by these professionals."

ITEM.price = 63000
ITEM.weight = 10.5

ITEM.flag = "K"

ITEM.radProt = 3

ITEM.res = {
	["Bullet"] = 0.50,
	["Blast"] = 0.50,
	["Slash"] = 0.50,
	["Fall"] = 0.50,
	["Burn"] = 0.305,
	["Shock"] = 0.305,
	["Chemical"] = 0.345,
	["Psi"] = 0.20,
	["Radiation"] = 0.60,
}

ITEM.ballisticlevels = {"lll+", "lll-a", "lll", "V", "lll"}
ITEM.artifactcontainers = {"4"}

ITEM.img = Material("stalker2/ui/armor/suit_exo_brummbar.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"

ITEM.isGasmask = true
ITEM.isHelmet = true

ITEM.replacements = "models/nasca/stalker/male_exo_merc.mdl"