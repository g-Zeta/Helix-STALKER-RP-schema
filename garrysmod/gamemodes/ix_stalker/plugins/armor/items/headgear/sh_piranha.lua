ITEM.name = "\"Piranha\" Combat Helmet"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/helm_exo.mdl"
ITEM.description = "A heavy-duty ballistic helmet."
ITEM.longdesc = "It features a combination of high-quality gas mask, supplemental ear protection and a flame-resistant face shroud. The Piranha is very popular with stalkers serving in assault squads, and is most often seen worn by veteran exoskeleton operators. Provides a high amount of ballistic protection and a modest amount of thermal protection."

ITEM.price = 40000
ITEM.weight = 3.5

ITEM.flag = "3"

ITEM.radProt = 2.0

ITEM.res = {
	["Bullet"] = 0.035,
	["Blast"] = 0.035,
	["Slash"] = 0.035,
	["Fall"] = 0.035,
	["Burn"] = 0.025,
	["Shock"] = 0.015,
	["Chemical"] = 0.015,
	["Psi"] = 0.20,
	["Radiation"] = 0.20,
}

ITEM.ballisticlevels = {"lll+", "lll-a"}

ITEM.img = Material("stalker2/ui/headgear/headgear_helmet_exo.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"

ITEM.isGasmask = true
ITEM.isHelmet = true