ITEM.name = "Aeroprotection Gas Mask"
ITEM.model = "models/shtokerbox/ground_mask_m40.mdl"
ITEM.description = "A newer gas mask given to Ward soldiers."
ITEM.longdesc = "One is issued to every Ward soldier as standard defense against anomalies and light attacks; the group sometimes sells off extras to people they like as well."

ITEM.price = 19800
ITEM.weight = 2

ITEM.flag = "2"

ITEM.radProt = 2

ITEM.res = {
	["Bullet"] = 0.03,
	["Impact"] = 0,
	["Slash"] = 0.03,
	["Burn"] = 0.01,
	["Shock"] = 0.01,
	["Chemical"] = 0.19,
	["Radiation"] = 0.33,
	["Psi"] = 0.12,
}

ITEM.BRC = 15

ITEM.img = Material("stalker2/ui/headgear/headgear_gasmask_aeroprotection.png")
ITEM.overlayPath = "vgui/overlays/hud_tact"

ITEM.isGasmask = true