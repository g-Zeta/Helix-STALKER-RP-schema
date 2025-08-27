ITEM.name = "PSZ-5I Hawk Suit 
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/stalker_outfit.mdl"
ITEM.description = "A PSZ-5 suit modified by Spark." 
ITEM.longdesc = "Made in cooperation with the folks at Malachite, Spark's standard issue is quite apt at exploration."

ITEM.price = 40000
ITEM.weight = 6

ITEM.flag = "D"

ITEM.res = {
	["Bullet"] = 0.13,
	["Impact"] = 0.14,
	["Slash"] = 0.30,
	["Burn"] = 0.20,
	["Shock"] = 0.14,
	["Chemical"] = 0.12,
	["Radiation"] = 0.12,
	["Psi"] = 0.08,
}

ITEM.BRC = 34
ITEM.artifactcontainers = {"3"}

ITEM.img = Material("stalker2/ui/armor/suit_psz_5i_hawk.png")

ITEM.OnGetReplacement = function(self, player)
    return "models/arty/s.t.a.l.k.e.r 2/characters/faction/iskra/light/grunt_pm.mdl"
end
