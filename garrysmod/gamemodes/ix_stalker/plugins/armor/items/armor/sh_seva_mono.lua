ITEM.name = "Wanderer Suit"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/monolith_scientific_outfit.mdl"
ITEM.description = "A modified SEVA suit."
ITEM.longdesc = "This suit features the Monolith's signature bulletproof vest, providing greater protection in combat. It offers excellent all-around protection against the Zone's myriad threats. These suits are afforded to the Monolith's more experienced defenders, as well as those charged with defending or exploring underground laboratories."

ITEM.price = 750000
ITEM.weight = 7

ITEM.flag = "M"

ITEM.radProt = 3

ITEM.res = {
	["Bullet"] = 0.16,
	["Impact"] = 0.17,
	["Slash"] = 0.31,
	["Burn"] = 0.20,
	["Shock"] = 0.24,
	["Chemical"] = 0.20,
	["Radiation"] = 0.36,
	["Psi"] = 0.25,
}

ITEM.BRC = 41
ITEM.artifactcontainers = {"4"}

ITEM.img = Material("stalker2/ui/armor/suit_seva_wanderer.png")
ITEM.overlayPath = "vgui/overlays/hud_sci"

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/silver/stalker/female_seva_mono.mdl"
    end;
    return "models/nasca/stalker/male_seva_mono.mdl"
end

ITEM.bodyGroups = {
	["Screen"] = 0,
}