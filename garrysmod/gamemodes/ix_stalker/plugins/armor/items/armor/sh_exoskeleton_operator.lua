ITEM.name = "Operator Exoskeleton"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/dolg_exo_outfit.mdl"
ITEM.description = "Heavy power armored suit used by Ward."
ITEM.longdesc = "A set of third-generation exo motors overtop a heavy armor suit. It is used by Ward specialists made to tank."

ITEM.price = 95000
ITEM.weight = 10.5

ITEM.flag = "D"

ITEM.radProt = 3

ITEM.res = {
	["Bullet"] = 0.41,
	["Impact"] = 0.42,
	["Slash"] = 0.53,
	["Burn"] = 0.08,
	["Shock"] = 0.08,
	["Chemical"] = 0.05,
	["Radiation"] = 0.29,
	["Psi"] = 0.31,
}

ITEM.BRC = 62
ITEM.artifactcontainers = {"4"}

ITEM.img = Material("stalker2/ui/armor/suit_exoheavy_operator.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"
ITEM.replacements = "models/npc/stalker_isg/isg_exo/isg_exo.mdl"