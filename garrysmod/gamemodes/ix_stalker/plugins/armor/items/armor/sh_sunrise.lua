ITEM.name = "Sunrise Suit"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/stalker_outfit.mdl"
ITEM.description = "A standard stalker outfit."
ITEM.longdesc = "A masterpiece of local craftsmenship, this suit combines two layers of rubberized fabric with a polymer lining and a bulletproof vest effective against most conventional pistol or intermediate rifle rounds. It's suitable for most tasks that aren't too intense into either combat or anomaly diving."

ITEM.price = 36000
ITEM.weight = 4

ITEM.flag = "1"

ITEM.res = {
	["Bullet"] = 0.13,
	["Impact"] = 0.14,
	["Slash"] = 0.30,
	["Burn"] = 0.15,
	["Shock"] = 0.7,
	["Chemical"] = 0.06,
	["Radiation"] = 0.06,
	["Psi"] = 0.06,
}

ITEM.BRC = 34
ITEM.artifactcontainers = {"2"}

ITEM.img = Material("stalker2/ui/armor/suit_sunrise.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/nasca/stalker/female_sunrise_lone.mdl"
    end;
    return "models/nasca/stalker/male_sunrise_lone.mdl"
end