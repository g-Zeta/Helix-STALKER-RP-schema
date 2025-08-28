ITEM.name = "OZK Explorer's Suit"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/cs_heavy_outfit.mdl"
ITEM.description = "A heavy outfit."
ITEM.longdesc = "This protective suit consisting of rubber overalls is adapted to the Zone's unforgiving conditions, significantly improving the wearer's chance of survival in anomaly-rich and radiation-contaminated areas."

ITEM.price = 21700
ITEM.weight = 6

ITEM.flag = "1"

ITEM.res = {
	["Bullet"] = 0.09,
	["Impact"] = 0.14,
	["Slash"] = 0.21,
	["Burn"] = 0.15,
	["Shock"] = 0.07,
	["Chemical"] = 0.06,
	["Radiation"] = 0.07,
	["Psi"] = 0.06,
}

ITEM.BRC = 26
ITEM.artifactcontainers = {"2"}

ITEM.img = Material("stalker2/ui/armor/suit_ozk_explorer.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/nasca/stalker/female_expedition.mdl"
    end;
    return "models/nasca/stalker/male_expedition.mdl"
end