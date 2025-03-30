ITEM.name = "PSZ-9D Duty Armor"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/dolg_heavy_outfit.mdl"
ITEM.description = "A superb armored suit for assault operations."
ITEM.longdesc = "The Duty variant of the PSZ-9 is nearly indistinguishable from the original in terms of performance, although certain materials were substituted with more cost-effective alternatives."

ITEM.price = 46000
ITEM.weight = 9

ITEM.flag = "D"

ITEM.res = {
	["Bullet"] = 0.35,
	["Blast"] = 0.35,
	["Slash"] = 0.35,
	["Fall"] = 0.35,
	["Burn"] = 0.195,
	["Shock"] = 0.14,
	["Chemical"] = 0.16,
	["Psi"] = 0.00,
	["Radiation"] = 0.40,
}

ITEM.ballisticlevels = {"0", "0", "ll", "lll+", "ll"}
ITEM.artifactcontainers = {"2"}

ITEM.img = Material("stalker2/ui/armor/suit_psz_9d.png")

ITEM.replacements = "models/nasca/stalker/male_psz12d_duty.mdl"