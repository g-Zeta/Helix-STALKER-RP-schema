ITEM.name = "Wind of Freedom" 
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/svoboda_light_outfit.mdl"
ITEM.description = "A lightweight suit made by Freedom craftmen." 
ITEM.longdesc = "Usually worn by rookies, but also loved by veterans for its sporty comfort. The suit's fabric is treated with Horizon, a special solution developed by the faction by trial and error, to increase resistance to anomalies. It is standard among members of Freedom, who enjoy its light weight and anomaly protection to move through the Zone with ease."

ITEM.price = 17100
ITEM.weight = 3

ITEM.flag = "V"

ITEM.res = {
	["Bullet"] = 0.07,
	["Impact"] = 0.04,
	["Slash"] = 0.15,
	["Burn"] = 0.20,
	["Shock"] = 0.14,
	["Chemical"] = 0.10,
	["Radiation"] = 0.12,
	["Psi"] = 0.08,
}

ITEM.BRC = 21
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_wind_v.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/nasca/stalker/female_wind_free.mdl"
    end;
    return "models/nasca/stalker/male_wind_free.mdl"
end