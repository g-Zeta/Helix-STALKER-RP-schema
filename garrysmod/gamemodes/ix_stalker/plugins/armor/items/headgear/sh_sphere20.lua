ITEM.name = "Sphere-M20 Helmet"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/helm_battle.mdl"
ITEM.description = "A reinforced helmet used by Spetsnaz."
ITEM.longdesc = "A modern titanium helmet with aramid reinforcement, complemented by a high-quality gas mask equipped with photochromic lenses."

ITEM.price = 28000
ITEM.weight = 3

ITEM.flag = "3"

ITEM.radProt = 0.25

ITEM.res = {
	["Bullet"] = 0.03,
	["Blast"] = 0.03,
	["Slash"] = 0.03,
	["Fall"] = 0.03,
	["Burn"] = 0.0155,
	["Shock"] = 0.0175,
	["Chemical"] = 0.0175,
	["Psi"] = 0.35,
	["Radiation"] = 0.15,
}

ITEM.ballisticlevels = {"lll", "ll"}

ITEM.img = Material("stalker2/ui/headgear/headgear_helmet_spherem20.png")
ITEM.overlayPath = "vgui/overlays/hud_mil"

ITEM.isGasmask = true
ITEM.isHelmet = true