ITEM.name = "PA-10 Gas Mask"
ITEM.model = "models/shtokerbox/ground_mask_pmk3.mdl"
ITEM.description = "A light military gas mask."
ITEM.longdesc = "A newer, cost-effective revision of a military gas mask employing denser materials. The filter can no longer be attached on the opposite side, but the housing has been downsized to offset this limitation."

ITEM.price = 16000
ITEM.weight = 2

ITEM.flag = "2"

ITEM.radProt = 0.25

ITEM.res = {
	["Bullet"] = 0.015,
	["Blast"] = 0.015,
	["Slash"] = 0.015,
	["Fall"] = 0.015,
	["Burn"] = 0.018,
	["Shock"] = 0.02,
	["Chemical"] = 0.019,
	["Psi"] = 0.15,
	["Radiation"] = 0.15,
}

ITEM.ballisticlevels = {"0", "ll-a"}

ITEM.img = Material("stalker2/ui/headgear/headgear_gasmask_pa10_black.png")
ITEM.overlayPath = "vgui/overlays/hud_mil"

ITEM.isGasmask = true