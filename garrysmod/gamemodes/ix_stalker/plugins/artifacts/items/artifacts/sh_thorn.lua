ITEM.name = "Thorn"
ITEM.model = "models/stalker/artifacts/thorn.mdl"
ITEM.description = "A black orb covered in long, sharp spines."
ITEM.longdesc = "Formed as the result of a Burnt Fuzz reacting with a Stalker who failed to escape its tendrils, this artifact is impossible to handle without being stabbed as it pokes the body of its owner, no matter what. However, any radionucliodes present in the bloodstream are removed in turn, making this artifact somewhat useful. Occasionally also found in other rare, organic anomalies.\n\nSome stalkers believe that prolonged use of the Thorn induces a change in their blood, and that the bleeding caused by the artifact is making room for whatever the artifact is adding to their bodies. Science is inconclusive due to few Stalkers using a Thorn for long enough time to test against, but some long-term users have reported their blood becoming significantly brighter then it should be."

ITEM.price = 2500
ITEM.weight = 0.35

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

ITEM.debuff = "bleeding"
ITEM.debuffval = 1

ITEM.img = Material("stalkerSHoC/ui/artifacts/thorn.png")