ITEM.name = "SSP-100 Discovery"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/ecolog_suit.mdl"
ITEM.description= "An new-series environmental suit."
ITEM.longdesc = "Part of a newer series of suits that not only resembles a space suit, but incorporates many design elements from one. Offers superior protection to physical and environmental hazards than the older SSP-99 series. "

ITEM.price = 65000
ITEM.weight = 6

ITEM.flag = "E"

ITEM.radProt = 3

ITEM.res = {
	["Bullet"] = 0.14,
	["Impact"] = 0.12,
	["Slash"] = 0.12,
	["Burn"] = 0.67,
	["Shock"] = 0.21,
	["Chemical"] = 0.18,
	["Radiation"] = 0.37,
	["Psi"] = 0.23,
}

ITEM.BRC = 14
ITEM.artifactcontainers = {"4"}

ITEM.img = Material("stalker2/ui/armor/suit_ssp100_discovery.png")
ITEM.overlayPath = "vgui/overlays/hud_sci"

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/silver/stalker/female_ssp_eco.mdl"
    end;
    return "models/nasca/stalker/male_ssp_eco.mdl"
end