ITEM.name = "Corundum"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/monolith_rad_outfit.mdl"
ITEM.description = "Heavy armored suit used by Monolith assault teams."
ITEM.longdesc = "The manufacturer clearly valued functionality more than comfort, so a normal person won't be able to wear this monstrosity for more than two hours."

ITEM.price = 57500
ITEM.weight = 10

ITEM.flag = "M"

ITEM.radProt = 4

ITEM.res = {
	["Bullet"] = 0.40,
	["Blast"] = 0.40,
	["Slash"] = 0.40,
	["Fall"] = 0.40,
	["Burn"] = 0.195,
	["Shock"] = 0.175,
	["Chemical"] = 0.16,
	["Psi"] = 0.20,
	["Radiation"] = 0.50,
}

ITEM.ballisticlevels = {"lll+", "lll-a", "lll", "lV", "lll"}
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_corundum.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"

ITEM.isGasmask = true
ITEM.isHelmet = true

ITEM.replacements = "models/nasca/stalker/male_exo_mono.mdl"

ITEM.bodyGroups = {
	["Servomotors"] = 1,
}