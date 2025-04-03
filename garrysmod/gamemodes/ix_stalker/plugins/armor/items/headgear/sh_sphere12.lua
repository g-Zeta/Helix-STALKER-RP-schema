ITEM.name = "Sphere-M12 Helmet"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/helm_battle.mdl"
ITEM.description = "A helmet used by Spetsnaz squad leaders."
ITEM.longdesc = "An aluminum/titanium helmet with a cloth exterior that comes with a face mask. Sphere-M12 was used as part of a combination that included PSZ series Spetsnaz body armor. Quite popular in the Zone back in 2012."

ITEM.price = 25000
ITEM.weight = 4

ITEM.flag = "3"

ITEM.radProt = 2

ITEM.res = {
	["Bullet"] = 0.03,
	["Blast"] = 0.03,
	["Slash"] = 0.03,
	["Fall"] = 0.03,
	["Burn"] = 0.015,
	["Shock"] = 0.015,
	["Chemical"] = 0.015,
	["Psi"] = 0.30,
	["Radiation"] = 0.10,
}

ITEM.ballisticlevels = {"lll", "ll-a"}

ITEM.img = Material("stalkerCoP/ui/headgear/headgear_helmet_spherem12.png")
ITEM.overlayPath = "vgui/overlays/hud_mil"

ITEM.isGasmask = true
ITEM.isHelmet = true