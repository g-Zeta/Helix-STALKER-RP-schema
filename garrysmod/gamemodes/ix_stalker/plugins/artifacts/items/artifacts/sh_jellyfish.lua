ITEM.name = "Jellyfish"
ITEM.model = "models/stalker/artifacts/jellyfish.mdl"
ITEM.description = "A strange swirl of glossy tendrils forming a pointed orb."
ITEM.longdesc = "This gravitational artifact attracts and absorbs radioactive particles, reducing the effects of radiation on the body. It is very common in the Zone and is unofficially used outside the Zone for treating acute radiation sickness in exceptional circumstances.\n\nHowever, prolonged usage of the Jellyfish triggers a chemical imbalance in the body, resulting in Jaundice - the yellowing of the eyes. Continued usage has been known to cause visual discoloration, resulting in things appearing more yellow than usual."

ITEM.price = 4000
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
	["Radiation"] = 0.20,
}

ITEM.buff = "antirad"
ITEM.buffval = 2

ITEM.img = Material("stalkerCoP/ui/artifacts/jellyfish.png")