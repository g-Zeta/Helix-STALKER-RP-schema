ITEM.name = "Zircon Suit"
ITEM.model = "models/stalkertnb/outfits/psz9d_monolith.mdl"
ITEM.description = "A Monolith stalker suit, manufacturer unknown."
ITEM.longdesc = "A mysterious outfit worn as standard by members of the Monolith faction, and their Noontide break-offs. This advanced design consists of an environmental bodysuit that provides more than radiological protection, underneath a bulletproof vest. The very sight of this suit used to frighten any Zone dweller. Even now, just looking at it gives you the heebie-jeebies."

ITEM.price = 51000
ITEM.weight = 9

ITEM.flag = "M"

ITEM.res = {
	["Bullet"] = 0.16,
	["Impact"] = 0.17,
	["Slash"] = 0.30,
	["Burn"] = 0.20,
	["Shock"] = 0.14,
	["Chemical"] = 0.12,
	["Radiation"] = 0.12,
	["Psi"] = 0.08,
}

ITEM.BRC = 39
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_sunrise_zircon.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/nasca/stalker/female_sunrise_mono.mdl"
    end;
    return "models/nasca/stalker/male_sunrise_mono.mdl"
end