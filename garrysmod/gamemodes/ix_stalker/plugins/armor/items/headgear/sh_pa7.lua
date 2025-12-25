ITEM.name = "PA-7 Gas Mask"
ITEM.model = "models/shtokerbox/ground_mask_m40.mdl"
ITEM.description = "A military adaptation of a civilian gas mask."
ITEM.longdesc = "Equipped with anti-glare lenses and a flexible filter mount that can be attached on either side, simplifying weapon use for left-handed wearers."

ITEM.price = 17250
ITEM.weight = 2

ITEM.flag = "2"

ITEM.radProt = 1.5

ITEM.res = {
	["Bullet"] = 0.03,
	["Impact"] = 0,
	["Slash"] = 0.05,
	["Burn"] = 0.02,
	["Shock"] = 0.01,
	["Chemical"] = 0.09,
	["Radiation"] = 0.29,
	["Psi"] = 0.05,
}

ITEM.BRC = 10

ITEM.img = Material("stalker2/ui/headgear/headgear_gasmask_pa7.png")
ITEM.overlayPath = "stalker/ui/overlays/hud_tact"

ITEM.isGasmask = true