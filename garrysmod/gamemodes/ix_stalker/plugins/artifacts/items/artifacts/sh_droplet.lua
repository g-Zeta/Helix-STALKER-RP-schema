ITEM.name = "Droplet"
ITEM.model = "models/stalker/artifacts/droplet.mdl"
ITEM.description = "A droopy, teardrop artifact formed in extreme heat."
ITEM.longdesc = "The texture is most similar to glass, but the artifact has a bit of weight to it and feels solid. The surface is broken up by cracks, which naturally pull various known and unknown radiation and energies into itself - resulting in tiring the user during use.\n\nDespite the commonality of the Droplet, scientists are unsure of the full capabilities of the Droplet - Despite the amount of radiation the artifact consumes being minor, the fact remains that the Droplet also takes the energy of the user. Small uses result in common tiredness, but long-term users of the artifact have reported minor but increased feelings of apathy or melancholy. Some stalkers maintain a superstition that the Droplet takes happiness itself, and refuse to use it."

ITEM.price = 2000
ITEM.weight = 0.45

ITEM.res = {
	["Blast"] = 0.00,
	["Bullet"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = 0.00,
	["Chemical"] = 0.00,
	["Shock"] = 0.00,
	["Psi"] = 0.00,
	["Radiation"] = 0.10,
}

ITEM.buff = "antirad"
ITEM.buffval = 1

ITEM.debuff = "endred"
ITEM.debuffval = 2

ITEM.img = Material("stalkerSHoC/ui/artifacts/droplet.png")