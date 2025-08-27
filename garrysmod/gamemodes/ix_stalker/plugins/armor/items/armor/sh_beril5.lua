ITEM.name = "Beril-5m Armored Suit"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/army_outfit.mdl"
ITEM.description = "A Spetsnaz issue assault armor."
ITEM.longdesc = "A tough armor with decent performance in combat and anomalous settings alike. Once issued to Military Spetsnaz, but in their absence finds its way into all sorts of hands, especially those without a supply of their own assault armor." 

ITEM.price = 55000
ITEM.weight = 10

ITEM.flag = "U"

ITEM.res = {
	["Bullet"] = 0.29,
	["Impact"] = 0.31,
	["Slash"] = 0.35,
	["Burn"] = 0.25,
	["Shock"] = 0.16,
	["Chemical"] = 0.10,
	["Radiation"] = 0.05,
	["Psi"] = 0.05,
}

ITEM.BRC = 39
ITEM.ballisticlevels = {"0", "0", "l", "lll-a", "l"}
ITEM.artifactcontainers = {"2"}

ITEM.img = Material("stalker2/ui/armor/suit_psz_7mili.png")

ITEM.replacements = "models/nasca/stalker/male_berill5m_mili.mdl"