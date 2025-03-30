ITEM.name = "Urchin"
ITEM.model = "models/stalker/artifacts/urchin.mdl"
ITEM.description = "A brown spikey artifact."
ITEM.longdesc = "The Urchin is the rarest of the Thorn family of artifacts, and easily the most potent. It reduces radiation by an extreme amount, but in turn provides the greatest blood loss. Ecologists are known to coat their suits in processed Urchins, leading to the perfection of radioactive protection of the SSP suits.\n\nWhile the Thorn and Crystal Thorn seem to cause bleeding unintentionally, the Urchin behaves almost as an organism, feeding on the user’s blood and slightly growing with prolonged usage. Further, the consistency of the user’s blood becomes increasingly thin, leading to clotting issues, frequent bruises and slower healing. Some stalkers believe that, as Thorns and Crystal Thorns are formed from the bodies of stalkers who fall to organic anomalies, that the line of artifacts are actually a distinct, anomalous organism, and that each artifact is a different stage of life that starts with a corpse and ends with an Urchin. Ecologists have been unable to test the theory."

ITEM.price = 12000
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
	["Radiation"] = 0.40,
}

ITEM.buff = "antirad"
ITEM.buffval = 4

ITEM.debuff = "bleeding"
ITEM.debuffval = 3

ITEM.img = Material("stalkerSHoC/ui/artifacts/urchin.png")