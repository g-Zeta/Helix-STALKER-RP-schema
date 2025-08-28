ITEM.name = "Cuirass Exoskeleton"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/dolg_exo_outfit.mdl"
ITEM.description = "Heavy power armored suit used by Duty."
ITEM.longdesc = "A set of third-generation exo motors overtop a heavy armor suit. It is reinforced and capable of taking on some of the Zone's very worst."

ITEM.price = 90000
ITEM.weight = 10.5

ITEM.flag = "D"

ITEM.radProt = 3

ITEM.res = {
	["Bullet"] = 0.41,
	["Impact"] = 0.42,
	["Slash"] = 0.53,
	["Burn"] = 0.05,
	["Shock"] = 0.05,
	["Chemical"] = 0.02,
	["Radiation"] = 0.23,
	["Psi"] = 0.25,
}

ITEM.BRC = 62
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_exo_cuirass.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"
ITEM.replacements = "models/nasca/stalker/male_exo_duty.mdl"