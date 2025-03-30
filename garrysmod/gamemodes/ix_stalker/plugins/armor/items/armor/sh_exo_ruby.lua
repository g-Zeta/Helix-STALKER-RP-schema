ITEM.name = "Ruby Exoskeleton"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/monolith_exo_outfit.mdl"
ITEM.description = "Heavy armored suit used by Monolith assault team leaders."
ITEM.longdesc = "An experiment in cost-effective exoskeleton design, the Ruby combines upgraded Corundum components with first-generation servos to offset the armored suit's substantial weight."

ITEM.price = 69000
ITEM.weight = 20

ITEM.flag = "M"

ITEM.radProt = 0.80

ITEM.res = {
	["Bullet"] = 0.40,
	["Blast"] = 0.40,
	["Slash"] = 0.40,
	["Fall"] = 0.40,
	["Burn"] = 0.26,
	["Shock"] = 0.36,
	["Chemical"] = 0.26,
	["Psi"] = 0.20,
	["Radiation"] = 0.80,
}

ITEM.ballisticlevels = {"lll+", "lll-a", "lll", "lV", "lll"}
ITEM.artifactcontainers = {"5"}

ITEM.img = Material("stalker2/ui/armor/suit_exo_ruby.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"

ITEM.isGasmask = true
ITEM.isHelmet = true

ITEM.replacements = "models/nasca/stalker/male_exo_mono.mdl"