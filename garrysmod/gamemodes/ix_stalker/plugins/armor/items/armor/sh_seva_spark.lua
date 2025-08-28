ITEM.name = "SEVA-I Suit"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/svoboda_scientific_outfit.mdl"
ITEM.description = "A closed cycle suit used by Spark."
ITEM.longdesc = "The famous and legendary SEVA, exquisitely upgraded by skilled techs working for Spark. It's environmental protection is improved, without sacrificing armor."

ITEM.price = 60000
ITEM.weight = 8

ITEM.flag = "V"

ITEM.radProt = 4

ITEM.res = {
	["Bullet"] = 0.13,
	["Impact"] = 0.12,
	["Slash"] = 0.26,
	["Burn"] = 0.20,
	["Shock"] = 0.24,
	["Chemical"] = 0.20,
	["Radiation"] = 0.36,
	["Psi"] = 0.25,
}

ITEM.BRC = 36
ITEM.artifactcontainers = {"4"}

ITEM.img = Material("stalker2/ui/armor/suit_seva_i.png")
ITEM.overlayPath = "vgui/overlays/hud_sci"

ITEM.OnGetReplacement = function(self, player)
    return "models/player/stalker_nebo/nebo_seva/nebo_seva.mdl"
end
