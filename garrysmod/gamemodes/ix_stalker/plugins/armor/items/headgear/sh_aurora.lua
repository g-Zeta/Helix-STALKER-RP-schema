ITEM.name = "Aurora Gas Mask"
ITEM.model = "models/ethprops/suits/respirator.mdl"
ITEM.description = "An ordinary civil defense gas mask."
ITEM.longdesc = "It features a simple rubber mask and a modern, yet fairly basic filtration system. It is widely used by rookies and veterans of all factions due to its universal functionality."

ITEM.price = 2500
ITEM.weight = 2

ITEM.flag = "1"

ITEM.radProt = 0.5

ITEM.res = {
	["Bullet"] = 0.01,
	["Impact"] = 0,
	["Slash"] = 0.03,
	["Burn"] = 0.01,
	["Shock"] = 0.01,
	["Chemical"] = 0.03,
	["Radiation"] = 0.09,
	["Psi"] = 0.01,
}

ITEM.BRC = 5

ITEM.img = Material("stalker2/ui/headgear/headgear_gasmask_aurora.png")
ITEM.overlayPath = "vgui/overlays/hud_gas"

ITEM.isGasmask = true
ITEM.isHelmet = true 