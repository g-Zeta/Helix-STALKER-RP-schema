ITEM.name = "Aurora Gas Mask"
ITEM.model = "models/ethprops/suits/respirator.mdl"
ITEM.description = "An ordinary civil defense gas mask."
ITEM.longdesc = "It features a simple rubber mask and a modern, yet fairly basic filtration system. It is widely used by rookies and veterans of all factions due to its universal functionality."

ITEM.price = 12500
ITEM.weight = 2

ITEM.flag = "1"

ITEM.radProt = 0.10

ITEM.res = {
	["Bullet"] = 0.015,
	["Blast"] = 0.015,
	["Slash"] = 0.015,
	["Fall"] = 0.015,
	["Burn"] = 0.018,
	["Shock"] = 0.02,
	["Chemical"] = 0.019,
	["Psi"] = 0.10,
	["Radiation"] = 0.05,
}

ITEM.ballisticlevels = {"l", "ll-a"}

ITEM.img = Material("stalker2/ui/headgear/headgear_gasmask_aurora.png")
ITEM.overlayPath = "vgui/overlays/hud_gas"

ITEM.isGasmask = true