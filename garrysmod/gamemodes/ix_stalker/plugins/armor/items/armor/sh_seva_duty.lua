ITEM.name = "SEVA-D"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/dolg_scientific_outfit.mdl"
ITEM.description = "A closed cycle suit modified by Duty."
ITEM.longdesc = "Compared to the original SEVA suit, the main distinction of the Duty version lies is its integration with the armored vests of the PSZ-5 series. While significantly lowering production and maintenance expenses, this measure comes with trade-offs in certain performance aspects."

ITEM.price = 55000
ITEM.weight = 8

ITEM.flag = "D"

ITEM.radProt = 2

ITEM.res = {
	["Bullet"] = 0.16,
	["Impact"] = 0.17,
	["Slash"] = 0.31,
	["Burn"] = 0.12,
	["Shock"] = 0.13,
	["Chemical"] = 0.12,
	["Radiation"] = 0.25,
	["Psi"] = 0.16,
}

ITEM.BRC = 41
ITEM.artifactcontainers = {"2"}

ITEM.img = Material("stalker2/ui/armor/suit_seva_d.png")
ITEM.overlayPath = "vgui/overlays/hud_sci"


ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/silver/stalker/female_seva_duty.mdl"
    end;
    return "models/nasca/stalker/male_seva_duty.mdl"
end

ITEM.bodyGroups = {
	["Screen"] = 0,
}