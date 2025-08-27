ITEM.name = "Debut Suit"
ITEM.model = "models/flaymi/anomaly/equipments/novice_suit.mdl"
ITEM.description = "A reinforced jacket."
ITEM.longdesc = "Basically a jacket reinforced with aramid fibers and nylon thread, complemented with a basic load-bearing system. It serves as the bare minimum for survival. This suit doesn't protect against anomalies and won't stop a bullet, but its simplicity and cost-effectiveness make it a practical choice."

ITEM.price = 7500
ITEM.weight = 3

ITEM.flag = "1"

ITEM.res = {
	["Bullet"] = 0.07,
	["Impact"] = 0.01,
	["Slash"] = 0.14,
	["Burn"] = 0.15,
	["Shock"] = 0.06,
	["Chemical"] = 0.04,
	["Radiation"] = 0.02,
	["Psi"] = 0,
}

ITEM.BRC = 15
ITEM.artifactcontainers = {"1"}

ITEM.img = Material("stalker2/ui/armor/suit_debut.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/nasca/stalker/female_anorak.mdl"
    end;
    return "models/nasca/stalker/male_anorak.mdl"
end

ITEM.bodyGroups = {
	["vest"] = 1,
}