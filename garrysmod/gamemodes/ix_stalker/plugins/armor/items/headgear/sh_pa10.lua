ITEM.name = "PA-10 Gas Mask"
ITEM.model = "models/shtokerbox/ground_mask_pmk3.mdl"
ITEM.description = "A light military gas mask."
ITEM.longdesc = "A newer, cost-effective revision of a military gas mask employing denser materials. The filter can no longer be attached on the opposite side, but the housing has been downsized to offset this limitation."

ITEM.price = 10500
ITEM.weight = 2

ITEM.flag = "2"

ITEM.radProt = 1.5

ITEM.res = {
	["Bullet"] = 0.01,
	["Impact"] = 0,
	["Slash"] = 0.03,
	["Burn"] = 0.01,
	["Shock"] = 0.01,
	["Chemical"] = 0.06,
	["Radiation"] = 0.23,
	["Psi"] = 0.02,
}

ITEM.BRC = 10

ITEM.img = Material("stalker2/ui/headgear/headgear_gasmask_pa10_black.png")
ITEM.overlayPath = "stalker/ui/overlays/hud_mil"

ITEM.isGasmask = true