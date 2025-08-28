ITEM.name = "PSZ-21W Schturm Exosuit"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/dolg_exo_outfit.mdl"
ITEM.description = "A first-gen exoskeleton around some heavy assault armor."
ITEM.longdesc = "A lighter version of Exo used by Ward, that helps support the weight of heavier weaponry but still allows a fair amount of mobility."

ITEM.price = 80000
ITEM.weight = 10.5

ITEM.flag = "D"

ITEM.radProt = 3

ITEM.res = {
	["Bullet"] = 0.41,
	["Impact"] = 0.36,
	["Slash"] = 0.42,
	["Burn"] = 0.35,
	["Shock"] = 0.15,
	["Chemical"] = 0.11,
	["Radiation"] = 0.08,
	["Psi"] = 0.05,
}

ITEM.BRC = 55
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_psz_21w_shturm.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"
ITEM.replacements = "models/npc/stalker_isg/isg_bulat_proto/isg_bulat_proto.mdl"