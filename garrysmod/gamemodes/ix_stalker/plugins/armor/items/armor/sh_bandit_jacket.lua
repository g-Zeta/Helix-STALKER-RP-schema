ITEM.name = "Bandit Jacket"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/bandit_outfit.mdl"
ITEM.description = "A dark jacket."
ITEM.longdesc = "An inexpensive dark jacket worn by thugs everywhere. It won't actually protect you, but it makes you look dope as hell."

ITEM.price = 17500
ITEM.weight = 5

ITEM.flag = "B"

ITEM.res = {
	["Bullet"] = 0.15,
	["Blast"] = 0.15,
	["Slash"] = 0.15,
	["Fall"] = 0.15,
	["Burn"] = 0.105,
	["Shock"] = 0.10,
	["Chemical"] = 0.105,
	["Psi"] = 0.00,
	["Radiation"] = 0.20,
}

ITEM.ballisticlevels = {"0", "0", "l", "ll-a", "l"}
ITEM.artifactcontainers = {"1"}

ITEM.img = Material("stalker2/ui/armor/suit_bandit_jacket.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/nasca/stalker/female_anorak.mdl"
    end;
    return "models/nasca/stalker/male_anorak.mdl"
end

ITEM.newSkin = 1