ITEM.name = "PSZ-5V Guardian of Freedom"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/freeheavy_outfit.mdl"
ITEM.description = "A Freedom variant of the PSZ-5 series."
ITEM.longdesc = "The Freedom version of one of the Zone's most popular armored suits. This modification prioritizes all-around versatility without any specific focus. It is roughly comparable to the suits used by many stalkers, along with those of their rivals in Duty."

ITEM.price = 36000
ITEM.weight = 7

ITEM.flag = "V"

ITEM.res = {
	["Bullet"] = 0.25,
	["Blast"] = 0.25,
	["Slash"] = 0.25,
	["Fall"] = 0.25,
	["Burn"] = 0.16,
	["Shock"] = 0.13,
	["Chemical"] = 0.17,
	["Psi"] = 0.00,
	["Radiation"] = 0.40,
}

ITEM.ballisticlevels = {"0", "0", "ll-a", "lll-a", "ll-a"}
ITEM.artifactcontainers = {"2"}

ITEM.img = Material("stalker2/ui/armor/suit_psz_5v_guardian.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/nasca/stalker/female_psz9d_free.mdl"
    end;
    return "models/nasca/stalker/male_psz9d_free.mdl"
end