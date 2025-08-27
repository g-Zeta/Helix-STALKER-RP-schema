ITEM.name = "Mercenary Suit"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/merc_sun_outfit.mdl"
ITEM.description = "A mercenary outfit."
ITEM.longdesc = "Mercenary-designed suit, based on special forces gear. High molecular polyethylene plates and aramid padding not only sound futuristic, but provide excellent protection from high-corrosion Zone weapons."

ITEM.price = 37000
ITEM.weight = 5

ITEM.flag = "K"

ITEM.res = {
	["Bullet"] = 0.15,
	["Impact"] = 0.15,
	["Slash"] = 0.31,
	["Burn"] = 0.17,
	["Shock"] = 0.10,
	["Chemical"] = 0.10,
	["Radiation"] = 0.12,
	["Psi"] = 0.08,
}

ITEM.BRC = 36
ITEM.artifactcontainers = {"2"}

ITEM.img = Material("stalker2/ui/armor/suit_merc.png")

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/silver/stalker/female_eagle_merc.mdl"
    end;
    return "models/nasca/stalker/male_eagle_merc.mdl"
end