ITEM.name = "Optician Gas Mask"
ITEM.model = "models/shtokerbox/ground_mask_m50.mdl"
ITEM.description = "A civilian-grade gas mask."
ITEM.longdesc = "It features a solid visor and the option to mount a pair of filters. Fairly popular in the Zone."

ITEM.price = 5000
ITEM.weight = 2

ITEM.flag = "1"

ITEM.radProt = 0.5

ITEM.res = {
	["Bullet"] = 0.01,
	["Impact"] = 0,
	["Slash"] = 0.03,
	["Burn"] = 0.01,
	["Shock"] = 0.01,
	["Chemical"] = 0.06,
	["Radiation"] = 0.12,
	["Psi"] = 0.01,
}

ITEM.BRC = 10

ITEM.img = Material("stalker2/ui/headgear/headgear_gasmask_optician_black.png")
ITEM.overlayPath = "stalker/ui/overlays/hud_hard"

ITEM.isGasmask = true
ITEM.isHelmet = true 
