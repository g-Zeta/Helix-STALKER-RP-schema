ITEM.name = "Screen Helmet"
ITEM.model = "models/ethprops/suits/dome_mask.mdl"
ITEM.description = "An exotic helmet used by scientists."
ITEM.longdesc = "A light helmet with an airtight visor intended for protection from anomalies. The helmet shares designs used by the Defense Research Institutes responsible for the SEVA bodysuit. It affords a significant boost in anomalous protection for uniforms which may otherwise be lacking in means of defense against the Zone's environment."

ITEM.price = 35000
ITEM.weight = 3

ITEM.flag = "3"

ITEM.radProt = 0.45

ITEM.res = {
	["Bullet"] = 0.02,
	["Blast"] = 0.02,
	["Slash"] = 0.02,
	["Fall"] = 0.02,
	["Burn"] = 0.02,
	["Shock"] = 0.03,
	["Chemical"] = 0.03,
	["Psi"] = 0.40,
	["Radiation"] = 0.25,
}

ITEM.ballisticlevels = {"ll", "ll"}

ITEM.img = Material("stalkerCoP/ui/headgear/headgear_helmet_screen.png")
ITEM.overlayPath = "vgui/overlays/hud_sci"

ITEM.isGasmask = true
ITEM.isHelmet = true