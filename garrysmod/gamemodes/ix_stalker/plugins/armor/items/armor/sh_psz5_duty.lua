ITEM.name = "PSZ-5D Universal Protection" 
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/dolg_outfit.mdl"
ITEM.description = "A PSZ-5 suit commissioned by Duty." 
ITEM.longdesc = "This bodysuit was produced by one of Kiev's defense research institutes and was primarily commissioned by the Duty faction, who issue it as their standard uniform. Its use of cutting-edge materials provides decent protection against low-calibre firearms. Meanwhile, it provides adequate protection against anomalies, making it a well-rounded suit."

ITEM.price = 36500
ITEM.weight = 7

ITEM.flag = "D"

ITEM.res = {
	["Bullet"] = 0.25,
	["Blast"] = 0.25,
	["Slash"] = 0.25,
	["Fall"] = 0.25,
	["Burn"] = 0.11,
	["Shock"] = 0.13,
	["Chemical"] = 0.13,
	["Psi"] = 0.00,
	["Radiation"] = 0.30,
}

ITEM.ballisticlevels = {"0", "0", "ll-a", "lll-a", "ll-a"}
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_psz_5d.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/nasca/stalker/female_psz9d_duty.mdl"
    end;
    return "models/nasca/stalker/male_psz9d_duty.mdl"
end
