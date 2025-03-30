ITEM.name = "Stone Flower"
ITEM.model = "models/stalker/artifacts/stoneflower.mdl"
ITEM.description = "A hard stone deformed by the extreme pressures of gravitational anomalies."
ITEM.longdesc = "Composed of a granite-like formation deformed by gravitational forces, the metallic compounds within this artifact form a crystalline structure unexplained by science. With a beautiful luminescence, this artifact is known to have a calming effect that offers minor protection from psi-emissions.\n\nEven though the Stone Flower can save the user from deadly psy radiation, it does not totally dissipate it, and even temporary usage of it can result in mental shifts generally manifesting as onset synesthesia - crossovers of sensory information. This results in sensations such as tasting colors, feeling sounds, and hearing smells. Though generally unharmful, the effects are nonetheless disorienting."

ITEM.price = 3000
ITEM.weight = 0.45

ITEM.res = {
	["Blast"] = 0.00,
	["Bullet"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = 0.00,
	["Chemical"] = 0.00,
	["Shock"] = 0.00,
	["Psi"] = 0.20,
	["Radiation"] = -0.10,
}

ITEM.debuff = "rads"
ITEM.debuffval = 1

ITEM.img = Material("stalkerCoP/ui/artifacts/stoneflower.png")