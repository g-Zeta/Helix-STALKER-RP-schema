ITEM.name = "Mask-1 Helmet"
ITEM.model = "models/shtokerbox/ground_headgear_pracs.mdl"
ITEM.description = "A helmet used by Spetsnaz."
ITEM.longdesc = "A heavy-duty assault helmet equipped with ballistic goggles and an aramid-reinforced respirator."

ITEM.price = 32500
ITEM.weight = 3

ITEM.flag = "3"

ITEM.radProt = 1.5

ITEM.res = {
	["Bullet"] = 0.035,
	["Blast"] = 0.035,
	["Slash"] = 0.035,
	["Fall"] = 0.035,
	["Burn"] = 0.0175,
	["Shock"] = 0.019,
	["Chemical"] = 0.019,
	["Psi"] = 0.30,
	["Radiation"] = 0.15,
}

ITEM.ballisticlevels = {"lll+", "ll"}

ITEM.img = Material("stalker2/ui/headgear/headgear_helmet_mask1.png")
ITEM.overlayPath = "vgui/overlays/hud_prot"

ITEM.isGasmask = true
ITEM.isHelmet = true

ITEM.newSkin = 1