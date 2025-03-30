ITEM.name = "SSP-99M"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/ecolog_outfit_green.mdl"
ITEM.description= "An advanced environmental suit."
ITEM.longdesc = "High quality modified SSP-99 suit. It provides increased body protection from ballistic damage. It is designed for the guards working with scientific expeditions. It provides good protection from radiation and biological anomalies. It is resistant to chemically aggressive environments and other effects dangerous to the body."

ITEM.price = 62000
ITEM.weight = 7

ITEM.flag = "E"

ITEM.radProt = 0.80

ITEM.res = {
	["Bullet"] = 0.25,
	["Blast"] = 0.25,
	["Slash"] = 0.25,
	["Fall"] = 0.25,
	["Burn"] = 0.30,
	["Shock"] = 0.35,
	["Chemical"] = 0.40,
	["Psi"] = 0.40,
	["Radiation"] = 0.80,
}

ITEM.ballisticlevels = {"ll", "ll", "l", "lll-a", "l"}
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_ssp99m.png")
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

ITEM.newSkin = 1