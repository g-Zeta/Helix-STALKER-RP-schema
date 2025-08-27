ITEM.name = "PSZ-5d Universal Protection" 
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/dolg_outfit.mdl"
ITEM.description = "A PSZ-5 suit commissioned by Duty." 
ITEM.longdesc = "The typical 'medium' suit used by members of Duty. For their tasks that usually involve hunting bandits and hunting mutants, it's quite good."

ITEM.price = 36500
ITEM.weight = 6

ITEM.flag = "D"

ITEM.res = {
	["Bullet"] = 0.16,
	["Impact"] = 0.19,
	["Slash"] = 0.33,
	["Burn"] = 0.10,
	["Shock"] = 0.02,
	["Chemical"] = 0.02,
	["Radiation"] = 0.02,
	["Psi"] = 0.02,
}

ITEM.ballisticlevels = {"0", "0", "ll-a", "lll-a", "ll-a"}
ITEM.artifactcontainers = {"1"}

ITEM.img = Material("stalker2/ui/armor/suit_psz_5d.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/nasca/stalker/female_psz9d_duty.mdl"
    end;
    return "models/nasca/stalker/male_psz9d_duty.mdl"
end
