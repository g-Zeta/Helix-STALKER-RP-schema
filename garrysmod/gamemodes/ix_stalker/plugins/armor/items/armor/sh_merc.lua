ITEM.name = "Mercenary Suit"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/merc_sun_outfit.mdl"
ITEM.description = "A mercenary outfit."
ITEM.longdesc = "Mercenary-designed suit, based on special forces gear. High molecular polyethylene plates and aramid padding not only sound futuristic, but provide excellent protection from high-corrosion Zone weapons."

ITEM.price = 20200
ITEM.weight = 3

ITEM.flag = "K"

ITEM.res = {
	["Bullet"] = 0.30,
	["Blast"] = 0.30,
	["Slash"] = 0.30,
	["Fall"] = 0.30,
	["Burn"] = 0.08,
	["Shock"] = 0.10,
	["Chemical"] = 0.10,
	["Psi"] = 0.00,
	["Radiation"] = 0.30,
}

ITEM.ballisticlevels = {"0", "0", "l", "lll", "l"}
ITEM.artifactcontainers = {"1"}

ITEM.img = Material("stalker2/ui/armor/suit_merc.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/silver/stalker/female_eagle_merc.mdl"
    end;
    return "models/nasca/stalker/male_eagle_merc.mdl"
end