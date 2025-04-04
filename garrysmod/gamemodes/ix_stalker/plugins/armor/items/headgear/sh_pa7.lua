ITEM.name = "PA-7 Gas Mask"
ITEM.model = "models/shtokerbox/ground_mask_m40.mdl"
ITEM.description = "A military adaptation of a civilian gas mask."
ITEM.longdesc = "Equipped with anti-glare lenses and a flexible filter mount that can be attached on either side, simplifying weapon use for left-handed wearers."

ITEM.price = 19800
ITEM.weight = 2

ITEM.flag = "2"

ITEM.radProt = 1.5

ITEM.res = {
	["Bullet"] = 0.015,
	["Blast"] = 0.015,
	["Slash"] = 0.015,
	["Fall"] = 0.015,
	["Burn"] = 0.0175,
	["Shock"] = 0.022,
	["Chemical"] = 0.0175,
	["Psi"] = 0.20,
	["Radiation"] = 0.15,
}

ITEM.ballisticlevels = {"0", "ll-a"}

ITEM.img = Material("stalker2/ui/headgear/headgear_gasmask_pa7.png")
ITEM.overlayPath = "vgui/overlays/hud_tact"

ITEM.isGasmask = true