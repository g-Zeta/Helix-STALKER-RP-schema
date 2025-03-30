ITEM.name = "Debut"
ITEM.model = "models/flaymi/anomaly/equipments/novice_suit.mdl"
ITEM.description = "A reinforced jacket."
ITEM.longdesc = "Basically a jacket reinforced with aramid fibers and nylon thread, complemented with a basic load-bearing system. It serves as the bare minimum for survival. This suit doesn't protect against anomalies and won't stop a bullet, but its simplicity and cost-effectiveness make it a practical choice."

ITEM.price = 13500
ITEM.weight = 3

ITEM.flag = "1"

ITEM.res = {
	["Bullet"] = 0.15,
	["Blast"] = 0.15,
	["Slash"] = 0.15,
	["Fall"] = 0.15,
	["Burn"] = 0.08,
	["Shock"] = 0.07,
	["Chemical"] = 0.085,
	["Psi"] = 0.00,
	["Radiation"] = 0.10,
}

ITEM.ballisticlevels = {"0", "0", "l", "ll-a", "l"}
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