ITEM.name = "Exohelm"
ITEM.model = "models/flaymi/anomaly/dynamics/outfit/helm_exo.mdl"
ITEM.description = "A heavy-duty ballistic helmet."
ITEM.longdesc = "A thick titanium helmet with ear protection and a gas mask, worn most commonly by Exoskeleton operators. It tends to sacrifice additional padding for anomalous fields in exchange for pure bullet protection."

ITEM.price = 45000
ITEM.weight = 3.5

ITEM.flag = "3"

ITEM.radProt = 2.0

ITEM.res = {
	["Bullet"] = 0.36,
	["Impact"] = 0,
	["Slash"] = 0.05,
	["Burn"] = 0.12,
	["Shock"] = 0,
	["Chemical"] = 0.18,
	["Radiation"] = 0.30,
	["Psi"] = 0.26,
}

ITEM.BRC = 55

ITEM.img = Material("stalker2/ui/headgear/headgear_helmet_exo.png")
ITEM.overlayPath = "vgui/overlays/hud_exo"

ITEM.isGasmask = true
ITEM.isHelmet = true