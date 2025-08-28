ITEM.name = "Armored Bandit Jacket"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/bandit_outfit.mdl"
ITEM.description = "A dark jacket with some extra padding."
ITEM.longdesc = "An inexpensive dark jacket with some chainmail and kevlar sewn in, making it a tad more suited for sticking up ignorant rubes."

ITEM.price = 6000
ITEM.weight = 5

ITEM.flag = "B"

ITEM.res = {
	["Bullet"] = 0.11,
	["Impact"] = 0.01,
	["Slash"] = 0.12,
	["Burn"] = 0.11,
	["Shock"] = 0.03,
	["Chemical"] = 0.02,
	["Radiation"] = 0.03,
	["Psi"] = 0,
}

ITEM.BRC = 12
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

ITEM.bodyGroups = {
	["vest"] = 1,
}