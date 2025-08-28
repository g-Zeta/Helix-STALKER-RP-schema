ITEM.name = "Shield of Duty Exosuit"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/dolg_exo_outfit.mdl"
ITEM.description = "A first-gen exoskeleton around a PSZ-9 armor."
ITEM.longdesc = "An older model Exoskeleton attached to a PSZ-9 makes a fine heavy weapons platform that can support the weight of one's gear plus some additional armoring, while being more mobile than the heavier third-gen frame. These lighter motors are also not quite as strong, delivering less peformance than a newer set."

ITEM.price = 75000
ITEM.weight = 10.5

ITEM.flag = "D"

ITEM.radProt = 3

ITEM.res = {
	["Bullet"] = 0.41,
	["Impact"] = 0.36,
	["Slash"] = 0.42,
	["Burn"] = 0.34,
	["Shock"] = 0.10,
	["Chemical"] = 0.05,
	["Radiation"] = 0.05,
	["Psi"] = 0,
}

ITEM.BRC = 55
ITEM.artifactcontainers = {"2"}

ITEM.img = Material("stalker2/ui/armor/suit_exo_shield_d.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"
ITEM.replacements = "models/player/stalker_dolg/dolg_bulat_proto/dolg_bulat_proto.mdl"