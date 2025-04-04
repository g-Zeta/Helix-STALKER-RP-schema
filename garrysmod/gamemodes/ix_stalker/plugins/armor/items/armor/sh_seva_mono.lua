ITEM.name = "Wanderer"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/monolith_scientific_outfit.mdl"
ITEM.description = "A modified SEVA suit."
ITEM.longdesc = "This suit features the Monolith's signature bulletproof vest, providing greater protection in combat. It offers excellent all-around protection against the Zone's myriad threats. These suits are afforded to the Monolith's more experienced defenders, as well as those charged with defending or exploring underground laboratories."

ITEM.price = 237500
ITEM.weight = 7

ITEM.flag = "M"

ITEM.radProt = 6

ITEM.res = {
	["Bullet"] = 0.35,
	["Blast"] = 0.35,
	["Slash"] = 0.35,
	["Fall"] = 0.35,
	["Burn"] = 0.28,
	["Shock"] = 0.46,
	["Chemical"] = 0.46,
	["Psi"] = 0.36,
	["Radiation"] = 0.65,
}

ITEM.ballisticlevels = {"lll-a", "lll-a", "ll-a", "lll+", "ll-a"}
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_seva_wanderer.png")
ITEM.overlayPath = "vgui/overlays/hud_sci"

ITEM.isGasmask = true
ITEM.isHelmet = true

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