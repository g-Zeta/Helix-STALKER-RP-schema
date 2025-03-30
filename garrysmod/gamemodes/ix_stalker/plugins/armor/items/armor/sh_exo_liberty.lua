ITEM.name = "Liberty Exoskeleton"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/freedom_exo_outfit.mdl"
ITEM.description = "Heavy armored suit used by Freedom."
ITEM.longdesc = "Developed exclusively for Freedom, this suit stands as the pinnacle of exoskeleton design. Unfortunately, great performance comes at a great price — literally."

ITEM.price = 95000
ITEM.weight = 10.5

ITEM.flag = "V"

ITEM.radProt = 0.80

ITEM.res = {
	["Bullet"] = 0.50,
	["Blast"] = 0.50,
	["Slash"] = 0.50,
	["Fall"] = 0.50,
	["Burn"] = 0.36,
	["Shock"] = 0.36,
	["Chemical"] = 0.325,
	["Psi"] = 0.40,
	["Radiation"] = 0.80,
}

ITEM.ballisticlevels = {"lll+", "lll-a", "lll", "V", "lll"}
ITEM.artifactcontainers = {"5"}

ITEM.img = Material("stalker2/ui/armor/suit_exo_liberty.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"

ITEM.isGasmask = true
ITEM.isHelmet = true

ITEM.replacements = "models/nasca/stalker/male_exo_free.mdl"