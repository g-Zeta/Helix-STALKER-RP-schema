ITEM.name = "SEVA-D"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/dolg_scientific_outfit.mdl"
ITEM.description = "A closed cycle suit."
ITEM.longdesc = "Compared to the original SEVA suit, the main distinction of the Duty version lies is its integration with the armored vests of the PSZ-5 series. While significantly lowering production and maintenance expenses, this measure comes with trade-offs in certain performance aspects."

ITEM.price = 46000
ITEM.weight = 8

ITEM.flag = "D"

ITEM.radProt = 0.50

ITEM.res = {
	["Bullet"] = 0.30,
	["Blast"] = 0.30,
	["Slash"] = 0.30,
	["Fall"] = 0.30,
	["Burn"] = 0.21,
	["Shock"] = 0.28,
	["Chemical"] = 0.27,
	["Psi"] = 0.30,
	["Radiation"] = 0.50,
}

ITEM.ballisticlevels = {"ll", "ll", "ll-a", "lll", "ll-a"}
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_seva_d.png")
ITEM.overlayPath = "vgui/overlays/hud_sci"

ITEM.isGasmask = true
ITEM.isHelmet = true

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