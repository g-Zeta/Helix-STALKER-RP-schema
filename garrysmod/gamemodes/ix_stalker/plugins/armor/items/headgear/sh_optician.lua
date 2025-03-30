ITEM.name = "Optician Gas Mask"
ITEM.model = "models/shtokerbox/ground_mask_m50.mdl"
ITEM.description = "A civilian-grade gas mask."
ITEM.longdesc = "It features a solid visor and the option to mount a pair of filters. Fairly popular in the Zone."

ITEM.price = 10500
ITEM.weight = 2

ITEM.flag = "1"

ITEM.radProt = 0.10

ITEM.res = {
	["Bullet"] = 0.015,
	["Blast"] = 0.015,
	["Slash"] = 0.015,
	["Fall"] = 0.015,
	["Burn"] = 0.014,
	["Shock"] = 0.014,
	["Chemical"] = 0.02,
	["Psi"] = 0.05,
	["Radiation"] = 0.05,
}

ITEM.ballisticlevels = {"0", "ll-a"}

ITEM.img = Material("stalker2/ui/headgear/headgear_gasmask_optician_black.png")
ITEM.overlayPath = "vgui/overlays/hud_hard"

ITEM.isGasmask = true