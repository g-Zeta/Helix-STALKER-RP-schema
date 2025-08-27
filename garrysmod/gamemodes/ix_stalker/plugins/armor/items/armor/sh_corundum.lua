ITEM.name = "Corundum"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/monolith_rad_outfit.mdl"
ITEM.description = "Heavy armored suit used by Monolith assault teams."
ITEM.longdesc = "The manufacturer clearly valued functionality more than comfort, so a normal person won't be able to wear this monstrosity for more than two hours."

ITEM.price = 85000
ITEM.weight = 10

ITEM.flag = "M"

ITEM.radProt = 2

ITEM.res = {
	["Bullet"] = 0.34,
	["Impact"] = 0.36,
	["Slash"] = 0.35,
	["Burn"] = 0.39,
	["Shock"] = 0.18,
	["Chemical"] = 0.12,
	["Radiation"] = 0.12,
	["Psi"] = 0.05,
}

ITEM.BRC = 50
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_corundum.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"

ITEM.replacements = "models/nasca/stalker/male_exo_mono.mdl"

ITEM.bodyGroups = {
	["Servomotors"] = 1,
}