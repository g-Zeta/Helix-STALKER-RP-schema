ITEM.name = "Screen Helmet"
ITEM.model = "models/ethprops/suits/dome_mask.mdl"
ITEM.description = "An exotic helmet used by scientists."
ITEM.longdesc = "A light helmet with an airtight visor intended for protection from anomalies. The helmet shares designs used by the Defense Research Institutes responsible for the SEVA bodysuit. It affords a significant boost in anomalous protection for uniforms which may otherwise be lacking in means of defense against the Zone's environment."

ITEM.price = 22000
ITEM.weight = 3

ITEM.flag = "3"

ITEM.radProt = 2.5

ITEM.res = {
	["Bullet"] = 0.13,
	["Impact"] = 0,
	["Slash"] = 0.04,
	["Burn"] = 0.04,
	["Shock"] = 0.01,
	["Chemical"] = 0.20,
	["Radiation"] = 0.49,
	["Psi"] = 0.11,
}

ITEM.BRC = 15

ITEM.img = Material("stalkerCoP/ui/headgear/headgear_helmet_screen.png")
ITEM.overlayPath = "stalker/ui/overlays/hud_sci"

ITEM.isGasmask = true
ITEM.isHelmet = true