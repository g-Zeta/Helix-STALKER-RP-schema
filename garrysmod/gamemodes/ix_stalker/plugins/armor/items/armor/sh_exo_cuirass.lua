ITEM.name = "Cuirass Exoskeleton"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/dolg_exo_outfit.mdl"
ITEM.description = "Heavy armored suit used by Duty."
ITEM.longdesc = "National-produced version of an exoskeleton, procured by Duty. Extra sturdy materials ensure a much higher soldier survival chance, even in the most savage mutant encounters."

ITEM.price = 90000
ITEM.weight = 10.5

ITEM.flag = "D"

ITEM.radProt = 6

ITEM.res = {
	["Bullet"] = 0.50,
	["Blast"] = 0.50,
	["Slash"] = 0.50,
	["Fall"] = 0.50,
	["Burn"] = 0.325,
	["Shock"] = 0.325,
	["Chemical"] = 0.36,
	["Psi"] = 0.20,
	["Radiation"] = 0.60,
}

ITEM.ballisticlevels = {"lll+", "lll-a", "lll", "V", "lll"}
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_exo_cuirass.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"

ITEM.isGasmask = true
ITEM.isHelmet = true

ITEM.replacements = "models/nasca/stalker/male_exo_duty.mdl"