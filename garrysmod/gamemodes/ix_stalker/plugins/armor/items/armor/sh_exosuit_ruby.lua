ITEM.name = "Ruby Exosuit"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/monolith_exo_outfit.mdl"
ITEM.description = "Heavy armored suit used by Monolith assault team leaders."
ITEM.longdesc = "An experiment in cost-effective exoskeleton design, the Ruby combines upgraded Corundum components with first-generation servos to offset the armored suit's substantial weight."

ITEM.price = 95000
ITEM.weight = 20

ITEM.flag = "M"

ITEM.radProt = 5

ITEM.res = {
	["Bullet"] = 0.41,
	["Impact"] = 0.36,
	["Slash"] = 0.42,
	["Burn"] = 0.39,
	["Shock"] = 0.18,
	["Chemical"] = 0.12,
	["Radiation"] = 0.12,
	["Psi"] = 0.05,
}

ITEM.BRC = 55
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_exo_ruby.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"

ITEM.replacements = "models/nasca/stalker/male_exo_mono.mdl"