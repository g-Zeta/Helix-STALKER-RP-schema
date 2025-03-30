ITEM.name = "PSZ-7 Military Body Armor"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/army_outfit.mdl"
ITEM.description = "A standard military suit."
ITEM.longdesc = "Standard-issue vest for the enlisted and NCOs. For this low a price, its main purpose is to protect you from other people. While not as efficient for protection from everything else, it's still a lot better than nothing."

ITEM.price = 14000
ITEM.weight = 7

ITEM.flag = "U"

ITEM.res = {
	["Bullet"] = 0.25,
	["Blast"] = 0.25,
	["Slash"] = 0.25,
	["Fall"] = 0.25,
	["Burn"] = 0.07,
	["Shock"] = 0.085,
	["Chemical"] = 0.105,
	["Psi"] = 0.00,
	["Radiation"] = 0.30,
}

ITEM.ballisticlevels = {"0", "0", "l", "lll-a", "l"}
ITEM.artifactcontainers = {"2"}

ITEM.img = Material("stalker2/ui/armor/suit_psz_7mili.png")

ITEM.replacements = "models/nasca/stalker/male_berill5m_mili.mdl"

ITEM.newSkin = 1