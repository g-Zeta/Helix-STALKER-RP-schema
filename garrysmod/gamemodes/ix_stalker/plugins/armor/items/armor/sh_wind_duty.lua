ITEM.name = "Recruit Suit" 
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/dolg_outfit.mdl"
ITEM.description = "A lightweight suit made by Duty craftmen." 
ITEM.longdesc = "Standard issue for regular Enlisted of Duty - especially the new members. It serves decently in combat scenarios, isn't ideal for combat scenarios."

ITEM.price = 19100
ITEM.weight = 3

ITEM.flag = "D"

ITEM.res = {
	["Bullet"] = 0.13,
	["Impact"] = 0.16,
	["Slash"] = 0.25,
	["Burn"] = 0.10,
	["Shock"] = 0.02,
	["Chemical"] = 0.02,
	["Radiation"] = 0.02,
	["Psi"] = 0.02,
}

ITEM.BRC = 30
ITEM.artifactcontainers = {"1"}

ITEM.img = Material("stalker2/ui/armor/suit_wind_d_recruit.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/nasca/stalker/female_wind_lone.mdl"
    end;
    return "models/nasca/stalker/male_wind_lone.mdl"
end

ITEM.newSkin = 4