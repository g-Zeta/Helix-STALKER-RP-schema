ITEM.name = "Crystal Thorn"
ITEM.model = "models/stalker/artifacts/crystal_thorn.mdl"
ITEM.description = "A spikey crystalline artifact."
ITEM.longdesc = "Much like the Thorn, the Crystal Thorn is a dark orb covered in spikes, varying in thickness from 0.3 millimeters to just a few molecules. However, the effects and downsides are more pronounced, as the thorns undulate in and out of the artifact, causing larger wounds to form. For some this is a worthwhile tradeoff, as the Crystal Thorn reduces radiation by a greater amount than its smaller cousin.\n\nThis artifact triggers visible crystalline formations in the user’s blood - a distinctive shine is present in light, and samples of tested blood show rounded fractal structures formed out of red blood cells of those that use the artifact. Despite the belief this should cause large amounts of pain, most users report only mild discomfort."

ITEM.price = 5000
ITEM.weight = 0.5

ITEM.res = {
	["Blast"] = 0.00,
	["Bullet"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = 0.00,
	["Chemical"] = 0.00,
	["Shock"] = 0.00,
	["Psi"] = 0.00,
	["Radiation"] = 0.30,
}

ITEM.buff = "antirad"
ITEM.buffval = 3

ITEM.debuff = "bleeding"
ITEM.debuffval = 1

ITEM.img = Material("stalkerSHoC/ui/artifacts/crystal_thorn.png")