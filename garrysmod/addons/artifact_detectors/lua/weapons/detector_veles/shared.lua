sound.Add({	name		= "V92_Uni_QuickMove",
	channel		= CHAN_WEAPON,
	level		= 100,
	volume		= 1.0,
	pitch		= { 95, 105 },
	sound		= "jessev92/weapons/univ/throw_gren.wav",
})
 
sound.Add({	name		= "V92_Uni_Draw",
	channel		= CHAN_BODY,
	level		= 75,
	volume		= 1.0,
	pitch		= { 95, 105 },
	sound		= "jessev92/weapons/univ/draw1.wav",
})

sound.Add({	name		= "V92_Uni_Holster",
	channel		= CHAN_BODY,
	level		= 75,
	volume		= 1.0,
	pitch		= { 95, 105 },
	sound		= "jessev92/weapons/univ/holster1.wav",
})


SWEP.PrintName			= "Veles Detector"			
SWEP.Slot				= 3
SWEP.SlotPos			= 5
SWEP.Category = "S.T.A.L.K.E.R. Detector Sweps"
SWEP.Author	= "Subleader and AirBlack and Hobo_Gus"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Right click to throw a bolt."	
SWEP.Base	= "base_sweps_detector"
SWEP.HoldType = "pistol"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = true
SWEP.UseHands = false
SWEP.ViewModel = "models/weapons/v_cw_fraggrenade.mdl"
SWEP.WorldModel = ""
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.Spawnable	= true
SWEP.AdminSpawnable	= true

SWEP.UseDel = CurTime()

function SWEP:IdleTiming()
end

SWEP.Primary.Delay				= 0
SWEP.Primary.Recoil				= 0
SWEP.Primary.Damage				= 0
SWEP.Primary.NumShots			= 0
SWEP.Primary.Cone				= 0	
SWEP.Primary.ClipSize			= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic   		= false
SWEP.Primary.Ammo         		= "none"
SWEP.Secondary.Delay			= 0
SWEP.Secondary.Recoil			= 0
SWEP.Secondary.Damage			= 0
SWEP.Secondary.NumShots			= 0
SWEP.Secondary.Cone		  		= 0
SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Automatic   		= false
SWEP.Secondary.Ammo         	= "none"

SWEP.ViewModelBoneMods = {
	["Base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Dummy01"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.ViewModelBoneMods = {
	["l-ring-low"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0.555, 0), angle = Angle(36.666, 7.777, -38.889) },
	["l-thumb-low"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-18.889, 10, 0) },
	["l-pinky-low"] = { scale = Vector(1, 1, 1), pos = Vector(-0.556, 0.699, 0), angle = Angle(1.11, 7.777, -38.889) },
	["l-middle-low"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0.555, 0), angle = Angle(16.666, 3.332, -25.556) },
	["l-index-low"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0.555, 0), angle = Angle(10, 14.444, -27.778) },
	["lwrist"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, -98.889) },
	["r-index-low"] = { scale = Vector(1, 1, 1), pos = Vector(-0.186, 0, 0), angle = Angle(-1.111, -1.111, 16.666) },
	["r-thumb-low"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(10, -14.445, 16.666) },
	["r-middle-low"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(36.666, 0, 0) },
	["r-pinky-low"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(36.666, 0, 0) },
	["Base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["r-ring-low"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(34.444, 0, 0) },
	["Dummy01"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.VElements = {
	["Veles"] = { type = "Model", model = "models/kali/miscstuff/stalker/detector_veles.mdl", bone = "lwrist", rel = "", pos = Vector(3.635, 1.2, -0.801), angle = Angle(-43.248, 1.169, 111.039), size = Vector(0.699, 0.699, 0.699), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 1, bodygroup = {[1] = 1} },
	["element_name"] = { type = "Model", model = "models/kali/miscstuff/stalker/bolt.mdl", bone = "Base", rel = "", pos = Vector(0, 0, 0), angle = Angle(12.857, -29.222, 180), size = Vector(0.755, 0.755, 0.755), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["screen"] = { type = "Quad", bone = "Base", rel = "Veles", pos = Vector(1.5, 0.1, .760), angle = Angle(0, -90, 0), size = 0.040, draw_func = nil}
}


SWEP.WElements = {
	["Bear"] = { type = "Model", model = "models/kali/miscstuff/stalker/detector_veles.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.675, 1.557, -2.597), angle = Angle(-106.364, -167.144, 12.857), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {[1] = 1} }
}

function SWEP:PrimaryAttack()
	if (self.UseDel < CurTime()) then
		self.UseDel = CurTime() + 3
		self.Owner:DoAttackEvent( )	
		self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
		self.Owner:ViewPunch( Angle( 10, -10, 0 ) )
		if (SERVER) then
			timer.Simple( 0.9, function()
				self:EmitSound( Sound("weapons/slam/throw.wav", 100, 100 ) )
				local bolt = ents.Create( "ent_stalker_bolt" )	
				bolt:SetPos(self.Owner:GetShootPos() + self.Owner:GetAimVector() * 10)
				bolt:SetAngles(self.Owner:EyeAngles())
				bolt:Spawn()
				bolt:SetOwner( self.Owner )
				bolt:Fire("kill", "", 12)
				bolt:GetPhysicsObject():ApplyForceCenter( self.Owner:GetVelocity() + self.Owner:GetAimVector() * 5000)
				bolt:GetPhysicsObject():AddAngleVelocity(Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500)))		
				bolt:GetPhysicsObject():SetMass(1)
			end)
		--	if GetConVarNumber("vnt_stalker_bolt_ammo") != 0 then	
		--		self:TakePrimaryAmmo(1)	
			--end
		end
		timer.Simple( 0.75, function()
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)	
		end)
	end
end

function SWEP:SecondaryAttack()
	if (self.UseDel < CurTime()) then
		self.UseDel = CurTime() + 3
		self.Owner:DoAttackEvent( )
		self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
		self.Owner:ViewPunch( Angle( -2, 0, 0 ) )
		if (SERVER) then
			timer.Simple( 0.9, function()
				self:EmitSound( Sound("weapons/slam/throw.wav", 100, 100 ) )
				local bolt = ents.Create( "ent_stalker_bolt" )	
				bolt:SetPos(self.Owner:GetShootPos() + self.Owner:GetAimVector() * 10)
				bolt:SetAngles(self.Owner:EyeAngles())
				bolt:Spawn()
				bolt:SetOwner( self.Owner )
				bolt:Fire("kill", "", 12)
				bolt:GetPhysicsObject():ApplyForceCenter( self.Owner:GetVelocity() + self.Owner:GetAimVector() * 2500)
				bolt:GetPhysicsObject():AddAngleVelocity(Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500)))		
				bolt:GetPhysicsObject():SetMass(1)
			end)
			--if GetConVarNumber("vnt_stalker_bolt_ammo") != 0 then
			--	self:TakePrimaryAmmo(1)
			--end
		end
		timer.Simple( 0.75, function()	
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		end)
	end
end

function SWEP:Deploy()
	timer.Simple( 0.75, function()	
	end)
	return true
end

local anomalies = {}
--Common Artifacts--
anomalies["models/stalker/artifacts/altered_wheel.mdl"] = true
anomalies["models/stalker/artifacts/altered_insulator.mdl"] = true
anomalies["models/stalker/artifacts/anomalous_plant.mdl"] = true
anomalies["models/stalker/artifacts/crystal.mdl"] = true
anomalies["models/stalker/artifacts/droplet.mdl"] = true
anomalies["models/stalker/artifacts/jellyfish.mdl"] = true
anomalies["models/stalker/artifacts/slime.mdl"] = true
anomalies["models/stalker/artifacts/sparkler.mdl"] = true
anomalies["models/stalker/artifacts/thorn.mdl"] = true

--Uncommon Artifacts--
anomalies["models/stalker/artifacts/battery.mdl"] = true
anomalies["models/stalker/artifacts/crystal_thorn.mdl"] = true
anomalies["models/stalker/artifacts/fireball.mdl"] = true
anomalies["models/stalker/artifacts/flash.mdl"] = true
anomalies["models/stalker/artifacts/meatchunk.mdl"] = true
anomalies["models/stalker/artifacts/nightstar.mdl"] = true
anomalies["models/stalker/artifacts/slug.mdl"] = true
anomalies["models/stalker/artifacts/stoneblood.mdl"] = true
anomalies["models/stalker/artifacts/stoneflower.mdl"] = true

--Rare Artifacts--
anomalies["models/stalker/artifacts/eye.mdl"] = true
anomalies["models/stalker/artifacts/goldfish.mdl"] = true
anomalies["models/stalker/artifacts/gravi.mdl"] = true
anomalies["models/stalker/artifacts/mamas_beads.mdl"] = true
anomalies["models/stalker/artifacts/moonlight.mdl"] = true
anomalies["models/stalker/artifacts/shell.mdl"] = true
anomalies["models/stalker/artifacts/snowflake.mdl"] = true
anomalies["models/stalker/artifacts/soul.mdl"] = true
anomalies["models/stalker/artifacts/spring.mdl"] = true
anomalies["models/stalker/artifacts/urchin.mdl"] = true
anomalies["models/stalker/artifacts/wrenched.mdl"] = true

--Exclusive Artifacts--
anomalies["models/stalker/artifacts/bubble.mdl"] = true
anomalies["models/stalker/artifacts/flame.mdl"] = true
anomalies["models/stalker/artifacts/kolobok.mdl"] = true
anomalies["models/stalker/artifacts/mica.mdl"] = true

--Special Artifacts--
anomalies["models/stalker/artifacts/compass.mdl"] = true
anomalies["models/stalker/artifacts/firefly.mdl"] = true
anomalies["models/stalker/artifacts/heart_of_oasis.mdl"] = true


if CLIENT then

		/*self.VElements["screen"].draw_func = function( weapon )
			//surface.SetDrawColor(quadInnerColor)
			draw.SimpleText(weapon:Clip1(), "QuadFont", 0, 0, Color(0,255,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end*/

end
SWEP.LastBeep = 0

function PointOnCircle( ang, radius, offX, offY )
	ang = math.rad( ang )
	local x = math.cos( ang ) * -radius + offX
	local y = math.sin( ang ) * radius + offY
	return x, y
end

function SWEP:Think()
	if CLIENT then
		self.ArtifactDetectionTimes = self.ArtifactDetectionTimes or {}
		self.LastArtifactBeepTimes = self.LastArtifactBeepTimes or {}
		local anoms = {}
		for k,v in pairs(ents.GetAll()) do
			if v:GetClass() == "ix_item" then
				if anomalies[string.lower(v:GetModel())] then
					table.insert(anoms, v)
				end
			end
		end

		self.VElements["screen"].draw_func = function( weapon )
		
			local function DrawPointOnThatShit(material, x, y, ang, size )
				surface.SetMaterial(Material(material))
				surface.DrawTexturedRectRotated(x, y, size, size, ang )
			end
		
			-- Scanner effect
			local cx, cy = -3, 3
			local scanRad = 25
			
			local scanAng = -(CurTime() * 150) % 360
			
			surface.SetTexture(0)
			for i = 0, 180, 2 do
				if math.sin(math.rad(scanAng + i)) <= 0 then
					local alpha = (1 - (i / 180)) * 25
					surface.SetDrawColor(0, 255, 0, alpha)
					local x1, y1 = PointOnCircle(scanAng + i, scanRad, cx, cy)
					local x2, y2 = PointOnCircle(scanAng + i + 2, scanRad, cx, cy)
					surface.DrawPoly({{ x = cx, y = cy }, { x = x1, y = y1 }, { x = x2, y = y2 }})
				end
			end

			local plypos = self.Owner:GetPos()
			for k, v in pairs( anoms ) do
				if ( v:IsValid() ) then
					local ang = (v:GetPos() - plypos):Angle()
					local diff = math.AngleDifference(ang.yaw, self.Owner:EyeAngles().yaw)
					local dest = plypos:Distance(v:GetPos())

					if math.abs(diff) < 90 and dest < 700 then
						local adiff = math.AngleDifference(diff - 90, scanAng)
						if adiff > 0 and adiff < 15 then
							self.ArtifactDetectionTimes[v:EntIndex()] = CurTime()

							if (self.LastArtifactBeepTimes[v:EntIndex()] or 0) < CurTime() - 1 then
								self.Owner:EmitSound(Sound("stalker2/detectors/detector_veles.wav"), 100, 100)
								self.LastArtifactBeepTimes[v:EntIndex()] = CurTime()
							end
						end

						local lastSeen = self.ArtifactDetectionTimes[v:EntIndex()] or 0
						local x, y = PointOnCircle( diff - 90, dest/30, -3, 3 )
						
						if CurTime() - lastSeen < 1.5 then
							local alpha = 255 * (1 - (CurTime() - lastSeen) / 1.5)
							surface.SetDrawColor( 255, 0, 0, alpha )
							DrawPointOnThatShit("sprites/glow04_noz", x, y, v:GetAngles().yaw, 6 )
						end
					end
				end
			end
		end
	end
end