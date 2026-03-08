local att = {}
att.name = "am_flechetterounds"
att.displayName = "Flechette rounds"
att.displayNameShort = "Flechette"

att.statModifiers = {ClumpSpreadMult = -0.4,
	DamageMult = -0.4}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/flechetterounds")
	att.description = {{t = "Increases amount of rounds per shot to 20.", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	self.Shots = 20
	self:unloadWeapon()
	local str = self.Primary.Ammo.." -FT-"
	self.Primary.Ammo = str
end

function att:detachFunc()
	self.Shots = self.Shots_Orig
	self:unloadWeapon()
	local str = string.sub(self.Primary.Ammo, 1, -6)
	self.Primary.Ammo = str
end

CustomizableWeaponry:registerAttachment(att)