ITEM.name = "PSZ-12V Bulat"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/military_outfit.mdl"
ITEM.description = "A heavy armor used by Freedom."
ITEM.longdesc = "After the military rejected the PSZ-12 in favor of the Berill, a large batch of these armored suits was written off and sold as surplus inventory. In the end, almost all of the Bulats were bought by Freedom."

ITEM.price = 50000
ITEM.weight = 9

ITEM.flag = "V"

ITEM.res = {
	["Bullet"] = 0.30,
	["Blast"] = 0.30,
	["Slash"] = 0.30,
	["Fall"] = 0.30,
	["Burn"] = 0.195,
	["Shock"] = 0.14,
	["Chemical"] = 0.16,
	["Psi"] = 0.00,
	["Radiation"] = 0.50,
}

ITEM.ballisticlevels = {"0", "0", "ll", "lll", "ll"}
ITEM.artifactcontainers = {"4"}

ITEM.img = Material("stalker2/ui/armor/suit_psz_12v_bulat.png")

ITEM.replacements = "models/nasca/stalker/male_stingray9_free.mdl"