ITEM.name = "Recruit" 
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/dolg_outfit.mdl"
ITEM.description = "A lightweight suit made by Duty craftmen." 
ITEM.longdesc = "Standard-issue attire for rank-and-file Duty members, this suit has been maliciously dubbed the “body bag” due to its perceived inadequacy for mutant hunting — the faction's main pursuit."

ITEM.price = 19100
ITEM.weight = 3

ITEM.flag = "D"

ITEM.res = {
	["Bullet"] = 0.15,
	["Blast"] = 0.15,
	["Slash"] = 0.15,
	["Fall"] = 0.15,
	["Burn"] = 0.085,
	["Shock"] = 0.085,
	["Chemical"] = 0.085,
	["Psi"] = 0.00,
	["Radiation"] = 0.20,
}

ITEM.ballisticlevels = {"0", "0", "l", "ll-a", "l"}
ITEM.artifactcontainers = {"2"}

ITEM.img = Material("stalker2/ui/armor/suit_wind_d_recruit.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/nasca/stalker/female_wind_lone.mdl"
    end;
    return "models/nasca/stalker/male_wind_lone.mdl"
end

ITEM.newSkin = 4