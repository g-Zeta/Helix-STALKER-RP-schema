ITEM.name = "Light Mercenary Suit"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/merc_outfit.mdl"
ITEM.description = "A light mercenary outfit."
ITEM.longdesc = "A lighter version of the Mercenary Suit, issued to new operators or ones that prefer the lighter burden."

ITEM.price = 16000
ITEM.weight = 2

ITEM.flag = "K"

ITEM.res = {
	["Bullet"] = 0.09,
	["Impact"] = 0.06,
	["Slash"] = 0.11,
	["Burn"] = 0.04,
	["Shock"] = 0.06,
	["Chemical"] = 0.06,
	["Radiation"] = 0.06,
	["Psi"] = 0,
}

ITEM.BRC = 18
ITEM.artifactcontainers = {"1"}

ITEM.img = Material("stalker2/ui/armor/suit_merc_light.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/silver/stalker/female_hawk_merc.mdl"
    end;
    return "models/nasca/stalker/male_hawk_merc.mdl"
end