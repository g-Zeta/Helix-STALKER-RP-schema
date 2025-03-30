ITEM.name = "SEVA"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/scientific_outfit.mdl"
ITEM.description = "A closed cycle suit."
ITEM.longdesc = "A top-notch suit manufactured by one of Kiev's defense research institutes that represents an excellent alternative to hand-made stalker suits. It combines a closed cycle breathing system and an integrated system of anomalous field suppression with an adequate ballistic vest. This suit is widely regarded as a good choice for overall protection. Still, it is expensive, and those who prefer pitched battle over careful anomaly investigation are advised to look elsewhere."

ITEM.price = 48000
ITEM.weight = 8

ITEM.flag = "3"

ITEM.radProt = 0.60

ITEM.res = {
	["Bullet"] = 0.25,
	["Blast"] = 0.25,
	["Slash"] = 0.25,
	["Fall"] = 0.25,
	["Burn"] = 0.24,
	["Shock"] = 0.32,
	["Chemical"] = 0.32,
	["Psi"] = 0.40,
	["Radiation"] = 0.60,
}

ITEM.ballisticlevels = {"ll", "ll", "ll-a", "lll-a", "ll-a"}
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_seva.png")
ITEM.overlayPath = "vgui/overlays/hud_sci"

ITEM.isGasmask = true
ITEM.isHelmet = true

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/silver/stalker/female_seva_lone.mdl"
    end;
    return "models/nasca/stalker/male_seva_lone.mdl"
end

ITEM.bodyGroups = {
	["Screen"] = 0,
}