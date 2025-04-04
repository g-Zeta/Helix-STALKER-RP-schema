ITEM.name = "Diamond Exoskeleton"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/monolith_exo_outfit.mdl"
ITEM.description = "An advanced exoskeleton in use by Monolith forces."
ITEM.longdesc = "The question of how this cutting-edge technology ended up in the possession of fanatics remains unanswered, yet the armor is often seen on elite Monolith soldiers."

ITEM.price = 68000
ITEM.weight = 10.5

ITEM.flag = "M"

ITEM.radProt = 5

ITEM.res = {
	["Bullet"] = 0.50,
	["Blast"] = 0.50,
	["Slash"] = 0.50,
	["Fall"] = 0.50,
	["Burn"] = 0.39,
	["Shock"] = 0.39,
	["Chemical"] = 0.39,
	["Psi"] = 0.40,
	["Radiation"] = 0.80,
}

ITEM.ballisticlevels = {"lll+", "lll-a", "lll", "V", "lll"}
ITEM.artifactcontainers = {"5"}

ITEM.img = Material("stalker2/ui/armor/suit_exo_diamond.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"

ITEM.isGasmask = true
ITEM.isHelmet = true

ITEM.replacements = "models/nasca/stalker/male_exo_mono.mdl"

ITEM.newSkin = 1

ITEM.bodyGroups = {
	["Shoulderpads"] = 1,
}