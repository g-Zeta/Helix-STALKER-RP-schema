ITEM.name = "Bandit Jacket"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/bandit_outfit.mdl"
ITEM.description = "A dark jacket."
ITEM.longdesc = "An inexpensive dark jacket worn by thugs everywhere. It won't actually protect you, but it makes you look dope as hell."

ITEM.price = 3000
ITEM.weight = 5

ITEM.flag = "B"

ITEM.res = {
	["Bullet"] = 0.02,
	["Impact"] = 0.01,
	["Slash"] = 0.10,
	["Thermal"] = 0.13,
	["Electrical"] = 0.02,
	["Chemical"] = 0.02,
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

ITEM.newSkin = 1