ITEM.name = "Sunrise"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/stalker_outfit.mdl"
ITEM.description = "A standard stalker outfit."
ITEM.longdesc = "A masterpiece of local craftsmenship, this suit combines two layers of rubberized fabric with a polymer lining and a bulletproof vest effective against pistol bullets. The Sunrise's reasonable price and upgrade potential have solidified its status as a top-selling item."

ITEM.price = 36000
ITEM.weight = 4

ITEM.flag = "1"

ITEM.res = {
	["Bullet"] = 0.20,
	["Blast"] = 0.20,
	["Slash"] = 0.20,
	["Fall"] = 0.20,
	["Burn"] = 0.13,
	["Shock"] = 0.11,
	["Chemical"] = 0.13,
	["Psi"] = 0.00,
	["Radiation"] = 0.30,
}

ITEM.ballisticlevels = {"0", "0", "l", "ll", "l"}
ITEM.artifactcontainers = {"2"}

ITEM.img = Material("stalker2/ui/armor/suit_sunrise.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/nasca/stalker/female_sunrise_lone.mdl"
    end;
    return "models/nasca/stalker/male_sunrise_lone.mdl"
end