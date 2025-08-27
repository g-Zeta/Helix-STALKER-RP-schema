ITEM.name = "SSP-100 SIRCAA"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/ecolog_suit.mdl"
ITEM.description= "A next gen mixed-use suit developed exclusively for SIRCAA."
ITEM.longdesc = "A heavy, modified SSP-100 model used by certain SIRCAA field staff. Rarely finds its way into Stalker's hands, because the eggheads keep their things under wraps and few are brave enough to take on the heavily armed escorts they have to steal it."

ITEM.price = 100000
ITEM.weight = 8

ITEM.flag = "E"

ITEM.radProt = 3

ITEM.res = {
	["Bullet"] = 0.34,
	["Impact"] = 0.20,
	["Slash"] = 0.29,
	["Burn"] = 0.76,
	["Shock"] = 0.51,
	["Chemical"] = 0.33,
	["Radiation"] = 0.64,
	["Psi"] = 0.55,
}

ITEM.BRC = 40
ITEM.artifactcontainers = {"4"}

ITEM.img = Material("stalker2/ui/armor/suit_ssp100m_sircaa.png")
ITEM.overlayPath = "vgui/overlays/hud_sci"

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/silver/stalker/female_ssp_eco.mdl"
    end;
    return "models/nasca/stalker/male_ssp_eco.mdl"
end