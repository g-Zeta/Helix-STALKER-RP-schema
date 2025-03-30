ITEM.name = "Slime"
ITEM.model = "models/stalker/artifacts/slime.mdl"
ITEM.description = "An amorphous mucus-like artifact."
ITEM.longdesc = "This artifact has the consistency of jelly - though its connection to itself renders attempts to separate it into parts nearly impossible. Even so, it is difficult to keep in one shape, so many stalkers place it into a thin container. The Slime acts as a coagulant, covering and sealing wounds as they appear. However, as it generates its formations over the body, it renders the user susceptible to dangerous chemicals and burns.\n\nThe Slime gradually covers the user, spreading and growing with every wound. Though few stalkers have allowed it to totally cover their body, most users cannot stand prolonged use as the slime creates a constant feeling of humidity and disgust."

ITEM.price = 2500
ITEM.weight = 0.25

ITEM.res = {
	["Blast"] = 0.00,
	["Bullet"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = -0.20,
	["Chemical"] = -0.20,
	["Shock"] = 0.00,
	["Psi"] = 0.00,
	["Radiation"] = 0.00,
}

ITEM.buff = "woundheal"
ITEM.buffval = 1

ITEM.img = Material("stalkerSHoC/ui/artifacts/slime.png")