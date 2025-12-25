ITEM.name = "PG-4 'Facehugger' Gas Mask"
ITEM.model = "models/shtokerbox/ground_mask_xm40.mdl"
ITEM.description = "An older civilian-grade gas mask."
ITEM.longdesc = "It features a solid visor and a single front-facing filter. So named because it slightly squeezes your face when worn."

ITEM.price = 16000
ITEM.weight = 2

ITEM.flag = "1"

ITEM.radProt = 0.5

ITEM.res = {
	["Bullet"] = 0.03,
	["Impact"] = 0,
	["Slash"] = 0.02,
	["Burn"] = 0.01,
	["Shock"] = 0.01,
	["Chemical"] = 0.05,
	["Radiation"] = 0.35,
	["Psi"] = 0.02,
}

ITEM.BRC = 10

ITEM.img = Material("stalker2/ui/headgear/headgear_gasmask_pg4.png")
ITEM.overlayPath = "stalker/ui/overlays/hud_hard"

ITEM.isGasmask = true
ITEM.isHelmet = true 
