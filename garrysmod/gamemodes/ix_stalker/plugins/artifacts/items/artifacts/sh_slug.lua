ITEM.name = "Slug"
ITEM.model = "models/stalker/artifacts/slug.mdl"
ITEM.description = "A very slimey artifact."
ITEM.longdesc = "Resembling the Slime in its jelly-like consistency, the Slug is encased within rigid, trapezoidal plates that form a protective shell for its interior. This unusual artifact exhibits a constant, rhythmic pulsing, with each plate expanding outward. When the plates retract, a viscous, coagulant ooze is released, behaving almost as if it was a living organism—seeking out open wounds. However, much like the sister artifact, the Slug leaves its user vulnerable to potent chemicals and severe burns.\n\nUnlike the Slime, ooze secretions from the Slug only move towards open wounds, lessening the grosser side effects of the artifact - to a point. Prolonged use results in hard plates growing on the user. Though no stalker has used a Slug long enough to find out, some stalkers think Slugs are actually a parasitic organism using its ooze to convert other organisms into itself, thus prolonging its existence and creating something more."

ITEM.price = 5000
ITEM.weight = 0.6

ITEM.res = {
	["Bullet"] = 0.00,
	["Impact"] = 0.00,
	["Slash"] = 0.00,
	["Thermal"] = -0.30,
	["Chemical"] = -0.30,
	["Electrical"] = 0.00,
	["Psi"] = 0.00,
	["Radiation"] = 0.00,
}

ITEM.buff = "woundheal"
ITEM.buffval = 2

ITEM.img = Material("stalkerSHoC/ui/artifacts/slug.png")