ITEM.name = "SSP-99 Ecologist"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/ecolog_suit.mdl"
ITEM.description= "An advanced environmental suit."
ITEM.longdesc = "Designed to endure the challenges of the Zone, the SSP-99 anomalous protection suit, featuring built-in air filtration and conditioning systems, is a common choice for scientific expeditions. Not intended for combat operations."

ITEM.price = 39000
ITEM.weight = 3

ITEM.flag = "E"

ITEM.radProt = 0.60

ITEM.res = {
	["Bullet"] = 0.15,
	["Blast"] = 0.15,
	["Slash"] = 0.15,
	["Fall"] = 0.15,
	["Burn"] = 0.23,
	["Shock"] = 0.30,
	["Chemical"] = 0.36,
	["Psi"] = 0.25,
	["Radiation"] = 0.60,
}

ITEM.ballisticlevels = {"ll-a", "ll-a", "l", "ll-a", "l"}
ITEM.artifactcontainers = {"2"}

ITEM.img = Material("stalker2/ui/armor/suit_ssp99.png")
ITEM.overlayPath = "vgui/overlays/hud_sci"

ITEM.isGasmask = true
ITEM.isHelmet = true

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/silver/stalker/female_ssp_eco.mdl"
    end;
    return "models/nasca/stalker/male_ssp_eco.mdl"
end