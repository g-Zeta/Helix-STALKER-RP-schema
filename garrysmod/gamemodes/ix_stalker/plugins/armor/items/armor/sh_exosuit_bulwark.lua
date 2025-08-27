ITEM.name = "Bulwark Exosuit"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/freedom_exo_outfit.mdl"
ITEM.description = "A first-gen exoskeleton around a PSZ-12V Bulat armor."
ITEM.longdesc = "An older model Exoskeleton attached to a PSZ-9 makes a fine heavy weapons platform that can support the weight of one's gear plus some additional armoring, while being more mobile than the heavier third-gen frame. These lighter motors are also not quite as strong, delivering less peformance than a newer set."

ITEM.price = 70000
ITEM.weight = 10.5

ITEM.flag = "V"

ITEM.radProt = 5

ITEM.res = {
	["Bullet"] = 0.27,
	["Impact"] = 0.28,
	["Slash"] = 0.36,
	["Burn"] = 0.39,
	["Shock"] = 0.18,
	["Chemical"] = 0.12,
	["Radiation"] = 0.12,
	["Psi"] = 0.05,
}

ITEM.BRC = 45
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_exoheavy_bulwark.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"
ITEM.replacements = "models/player/stalker_freedom/freedom_bulat_proto/freedom_bulat_proto.mdl"