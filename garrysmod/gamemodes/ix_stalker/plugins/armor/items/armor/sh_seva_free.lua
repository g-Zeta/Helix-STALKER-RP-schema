ITEM.name = "SEVA-V"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/svoboda_scientific_outfit.mdl"
ITEM.description = "A closed cycle suit."
ITEM.longdesc = "The famous and legendary SEVA, exquisitely upgraded by the Freedom craftsman Screw. Some of the solutions are quite surprising, but none of them made it less comfortable to wear."

ITEM.price = 53000
ITEM.weight = 8

ITEM.flag = "V"

ITEM.radProt = 4

ITEM.res = {
	["Bullet"] = 0.10,
	["Impact"] = 0.12,
	["Slash"] = 0.23,
	["Burn"] = 0.20,
	["Shock"] = 0.24,
	["Chemical"] = 0.20,
	["Radiation"] = 0.36,
	["Psi"] = 0.25,
}

ITEM.BRC = 31
ITEM.artifactcontainers = {"4"}

ITEM.img = Material("stalker2/ui/armor/suit_seva_v.png")
ITEM.overlayPath = "vgui/overlays/hud_sci"

ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "models/silver/stalker/female_seva_free.mdl"
    end;
    return "models/nasca/stalker/male_seva_free.mdl"
end

ITEM.bodyGroups = {
	["Screen"] = 0,
}