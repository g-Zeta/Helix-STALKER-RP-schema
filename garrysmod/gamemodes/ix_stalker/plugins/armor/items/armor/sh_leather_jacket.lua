ITEM.name = "Leather Jacket"
ITEM.model = "models/flaymi/anomaly/equipments/novice_suit.mdl"
ITEM.description = "A light, breezy jacket."
ITEM.longdesc = "A cheap leather jacket worn by newcomers to the Zone. May turn lethal wounds into only severely maiming ones, but is often one of the first things upgraded from and promptly abandoned."

ITEM.price = 3500
ITEM.weight = 5

ITEM.flag = "B"

ITEM.res = {
	["Bullet"] = 0.01,
	["Impact"] = 0.01,
	["Slash"] = 0.14,
	["Burn"] = 0.11,
	["Shock"] = 0.04,
	["Chemical"] = 0.04,
	["Radiation"] = 0,
	["Psi"] = 0,
}

ITEM.BRC = 7
ITEM.artifactcontainers = {"1"}

ITEM.img = Material("stalker2/ui/armor/suit_bandit_jacket.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/nasca/stalker/female_anorak.mdl"
    end;
    return "models/nasca/stalker/male_anorak.mdl"
end

ITEM.newSkin = 0