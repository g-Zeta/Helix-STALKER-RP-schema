ITEM.name = "SSP-100 Discovery"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/ecolog_suit.mdl"
ITEM.description= "An new-series environmental suit, modified by Spark."
ITEM.longdesc = "Part of a newer series of suits, and modified to be more suited for both exploration and light combat in cooperation with Malachite."

ITEM.price = 80000
ITEM.weight = 7

ITEM.flag = "V"

ITEM.radProt = 3

ITEM.res = {
	["Bullet"] = 0.18,
	["Impact"] = 0.16,
	["Slash"] = 0.18,
	["Burn"] = 0.76,
	["Shock"] = 0.36,
	["Chemical"] = 0.25,
	["Radiation"] = 0.39,
	["Psi"] = 0.38,
}

ITEM.BRC = 36
ITEM.artifactcontainers = {"5"}

ITEM.img = Material("stalker2/ui/armor/suit_ssp100i_survey.png")
ITEM.overlayPath = "vgui/overlays/hud_sci"

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/silver/stalker/female_ssp_eco.mdl"
    end;
    return "models/nasca/stalker/male_ssp_eco.mdl"
end