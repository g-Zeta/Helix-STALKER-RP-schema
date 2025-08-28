ITEM.name = "PSZ-5V Guardian of Freedom"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/freeheavy_outfit.mdl"
ITEM.description = "A Freedom variant of the PSZ-5 series."
ITEM.longdesc = "The Freedom version of one of the Zone's most popular armored suits. This modification prioritizes comfort and environmental protection, but holds up in a gunfight. "

ITEM.price = 36000
ITEM.weight = 5

ITEM.flag = "V"

ITEM.res = {
	["Bullet"] = 0.10,
	["Impact"] = 0.12,
	["Slash"] = 0.23,
	["Burn"] = 0.20,
	["Shock"] = 0.14,
	["Chemical"] = 0.14,
	["Radiation"] = 0.12,
	["Psi"] = 0.08,
}

ITEM.BRC = 29
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_psz_5v_guardian.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/nasca/stalker/female_psz9d_free.mdl"
    end;
    return "models/nasca/stalker/male_psz9d_free.mdl"
end