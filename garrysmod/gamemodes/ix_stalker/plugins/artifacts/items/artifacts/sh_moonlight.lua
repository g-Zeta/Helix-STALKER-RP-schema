ITEM.name = "Moonlight"
ITEM.model = "models/stalker/artifacts/moonlight.mdl"
ITEM.description = "A glowing spherical artifact."
ITEM.longdesc = "This unique and rare artifact resonates under the influence of psy-waves. Though potentially dangerous, the Moonlight can be attuned with the user, thereby counter-resonating against sources of psy radiation. In this way, the Moonlight can significantly or totally neutralize their effects on the user’s mind, at the cost of high radioactive excess.\n\nThe Moonlight has several side effects relating to mental health, not unlike the Stone Flower. However, while the Stone Flower’s effects are generally manageable and easier to adapt to, the Moonlight can trigger various mental disorders. Though its effects are not permanent, prolonged use can cause significant harm. The Ecologists have documented several of these effects, which include narcolepsy, episodes of mania and depression, anxiety, insomnia, and, in rare cases, suicidal ideation. Recognizing that the artifact can be a matter of life and death, Ecologists strongly advise limiting its use to situations of absolute necessity."

ITEM.price = 6000
ITEM.weight = 0.55

ITEM.res = {
	["Blast"] = 0.00,
	["Bullet"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = 0.00,
	["Chemical"] = 0.00,
	["Shock"] = 0.00,
	["Psi"] = 0.30,
	["Radiation"] = -0.20,
}

ITEM.buff = "psi"
ITEM.buffval = 3

ITEM.debuff = "rads"
ITEM.debuffval = 2

ITEM.img = Material("stalkerCoP/ui/artifacts/moonlight.png")