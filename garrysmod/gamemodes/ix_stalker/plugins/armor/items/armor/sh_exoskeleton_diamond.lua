ITEM.name = "Diamond Exoskeleton"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/monolith_exo_outfit.mdl"
ITEM.description = "An advanced exoskeleton in use by Monolith forces."
ITEM.longdesc = "The question of how this cutting-edge technology ended up in the possession of fanatics remains unanswered, yet the armor is often seen on elite Monolith soldiers."

ITEM.price = 125000
ITEM.weight = 10.5

ITEM.flag = "M"

ITEM.radProt = 5

ITEM.res = {
	["Bullet"] = 0.41,
	["Impact"] = 0.42,
	["Slash"] = 0.53,
	["Burn"] = 0.14,
	["Shock"] = 0.14,
	["Chemical"] = 0.10,
	["Radiation"] = 0.35,
	["Psi"] = 0.35,
}

ITEM.BRC = 55
ITEM.artifactcontainers = {"5"}

ITEM.img = Material("stalker2/ui/armor/suit_exo_diamond.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"

ITEM.replacements = "models/nasca/stalker/male_exo_mono.mdl"

ITEM.newSkin = 1

ITEM.bodyGroups = {
	["Shoulderpads"] = 1,
}