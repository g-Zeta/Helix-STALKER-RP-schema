ITEM.name = "Mercenary's Light Suit"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/merc_outfit.mdl"
ITEM.description = "A light mercenary outfit."
ITEM.longdesc = "A suit upgraded for the Rostok bar bouncers. High-molecular polyethylene plates reduce weight, along with bullet resistance."

ITEM.price = 19600
ITEM.weight = 2

ITEM.flag = "K"

ITEM.res = {
	["Bullet"] = 0.25,
	["Blast"] = 0.25,
	["Slash"] = 0.25,
	["Fall"] = 0.25,
	["Burn"] = 0.08,
	["Shock"] = 0.10,
	["Chemical"] = 0.10,
	["Psi"] = 0.00,
	["Radiation"] = 0.30,
}

ITEM.ballisticlevels = {"0", "0", "l", "lll-a", "l"}
ITEM.artifactcontainers = {"1"}

ITEM.img = Material("stalker2/ui/armor/suit_merc_light.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/silver/stalker/female_hawk_merc.mdl"
    end;
    return "models/nasca/stalker/male_hawk_merc.mdl"
end