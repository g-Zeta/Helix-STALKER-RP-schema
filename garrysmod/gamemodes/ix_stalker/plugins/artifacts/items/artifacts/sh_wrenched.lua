ITEM.name = "Wrenched"
ITEM.model = "models/stalker/artifacts/wrenched.mdl"
ITEM.description = "A bizarrely-shaped artifact."
ITEM.longdesc = "Acting as a kind of sponge that absorbs radioactive elements, the Wrenched provides protection from outside radiation as well as from radioactive particles that have already made their way into the body.\n\nThis artifact was once a common find for any stalker—essentially a radioactive rock offering minimal protection. However, its nature has transformed; it now absorbs radiation instead. This change could be the result of two artifacts being mistaken for one another or perhaps evidence of artifacts evolving over time due to unknown stimuli. Yet, no artifact comes without consequences. The Wrenched, for instance, leaves a lingering taste of sanitizer on the tongue, lasting for several hours."

ITEM.price = 8000
ITEM.weight = 0.40

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

ITEM.img = Material("stalkerSHoC/ui/artifacts/wrenched.png")