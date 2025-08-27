ITEM.name = "SSP-99 Ecologist"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/ecolog_suit.mdl"
ITEM.description= "An earlier model environmental suit."
ITEM.longdesc = "The first in the SSP line, suits invented for anomalous exploration by Ecologists. It's been eclipsed by better models by now, but is more than adequate for anomaly diving."

ITEM.price = 39000
ITEM.weight = 3

ITEM.flag = "E"

ITEM.radProt = 3

ITEM.res = {
	["Bullet"] = 0.10,
	["Impact"] = 0.09,
	["Slash"] = 0.12,
	["Burn"] = 0.57,
	["Shock"] = 0.21,
	["Chemical"] = 0.16,
	["Radiation"] = 0.37,
	["Psi"] = 0.23,
}

ITEM.BRC = 7
ITEM.artifactcontainers = {"3"}
ITEM.isGasmask = true
ITEM.isHelmet = true

ITEM.img = Material("stalker2/ui/armor/suit_ssp99.png")
ITEM.overlayPath = "vgui/overlays/hud_sci"

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/silver/stalker/female_ssp_eco.mdl"
    end;
    return "models/nasca/stalker/male_ssp_eco.mdl"
end