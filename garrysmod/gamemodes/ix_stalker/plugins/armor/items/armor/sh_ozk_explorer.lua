ITEM.name = "OZK Explorer's Suit"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/cs_heavy_outfit.mdl"
ITEM.description = "A heavy outfit."
ITEM.longdesc = "This protective suit consisting of rubber overalls is adapted to the Zone's unforgiving conditions, significantly improving the wearer's chance of survival in anomaly-rich and radiation-contaminated areas."

ITEM.price = 21700
ITEM.weight = 6

ITEM.flag = "1"

ITEM.res = {
	["Bullet"] = 0.30,
	["Blast"] = 0.30,
	["Slash"] = 0.30,
	["Fall"] = 0.30,
	["Burn"] = 0.097,
	["Shock"] = 0.13,
	["Chemical"] = 0.16,
	["Psi"] = 0.00,
	["Radiation"] = 0.10,
}

ITEM.ballisticlevels = {"0", "0", "ll-a", "lll", "ll-a"}
ITEM.artifactcontainers = {"2"}

ITEM.img = Material("stalker2/ui/armor/suit_ozk_explorer.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/silver/stalker/female_cs3a_lone.mdl"
    end;
    return "models/nasca/stalker/male_expedition.mdl"
end