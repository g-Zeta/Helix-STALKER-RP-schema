ITEM.name = "Marauder Suit"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/bandit_outfit.mdl"
ITEM.description = "A makeshift ballistic armor."
ITEM.longdesc = "An armor vest and pads cobbled together by all sorts of bad dudes, primarily meant for surviving encounters with stalkers who fight back when you stick a gun in their face. "

ITEM.price = 12000
ITEM.weight = 5

ITEM.flag = "B"

ITEM.res = {
	["Bullet"] = 0.16,
	["Impact"] = 0.11,
	["Slash"] = 0.24,
	["Burn"] = 0.12,
	["Shock"] = 0.03,
	["Chemical"] = 0.02,
	["Radiation"] = 0.03,
	["Psi"] = 0,
}

ITEM.BRC = 28
ITEM.artifactcontainers = {"2"}

ITEM.img = Material("stalker2/ui/armor/suit_bandit_marauder.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/silver/stalker/female_hawk_bandit.mdl"
    end;
    return "models/nasca/stalker/male_hawk_bandit.mdl"
end