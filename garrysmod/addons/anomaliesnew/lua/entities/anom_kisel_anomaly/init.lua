AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

hook.Add( "OnDamagedByExplosion", "DisableSound", function()
	return true
end )

sound.Add( {
	name = "buzz_idle",
	channel = CHAN_STATIC,
	volume = 0.25,
	level = 70,
	pitch = 100,
	sound = "anomaly/buzz_idle.wav"
} )

sound.Add( {
	name = "bfuzz_hit",
	channel = CHAN_STATIC,
	volume = 1,
	level = 100,
	pitch = 100,
	sound = "anomaly/bfuzz_hit.mp3"
} )

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)  
	self:SetSolid(SOLID_BBOX)	
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetModel("models/anomaly/anomaly_fix.mdl")
	--self.Entity:SetNotSolid( true )
	self:SetName("Kisel' Anomaly")
	self:SetTrigger(1)
	self.Entity:SetCollisionBounds( Vector( -50, -50, -5 ), Vector( 50, 50, 30 ) )
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:StartTouch(ent)
	timer.Create("kisel_activated_once", 0.01, 1, function()
		self:SetNWBool("Activated", true)
		self:EmitSound("bfuzz_hit");
        -- Create a DamageInfo object
        local dmgInfo = DamageInfo()
        dmgInfo:SetDamage(35)                    -- Set the damage amount
        dmgInfo:SetAttacker(self)                 -- Set the attacker (the entity itself)
        dmgInfo:SetInflictor(self)                -- Set the inflictor (also the entity itself)
        dmgInfo:SetDamageType(DMG_ACID)          -- Set the damage type to DMG_ACID
        
        -- Apply the damage to the entity that touched it
        ent:TakeDamageInfo(dmgInfo)
	end)	
	timer.Create("kisel_recharge", 0.5, 0, function()
		self:SetNWBool("Activated", false)
	end)
	timer.Create("kisel_activated", 0.65, 0, function()
		self:SetNWBool("Activated", true)
		self:EmitSound("bfuzz_hit");
        -- Create a DamageInfo object
        local dmgInfo = DamageInfo()
        dmgInfo:SetDamage(35)                    -- Set the damage amount
        dmgInfo:SetAttacker(self)                 -- Set the attacker (the entity itself)
        dmgInfo:SetInflictor(self)                -- Set the inflictor (also the entity itself)
        dmgInfo:SetDamageType(DMG_ACID)          -- Set the damage type to DMG_ACID
        
        -- Apply the damage to the entity that touched it
        ent:TakeDamageInfo(dmgInfo)
	end)
end

function ENT:EndTouch()
	timer.Stop("kisel_activated")
	timer.Stop("kisel_recharge")
	self.Timer = "kisel_" .. self:EntIndex()
	timer.Create( self.Timer, 0.5, 1, function()
		self:SetNWBool("Activated", false)
	end)
end

function ENT:SpawnFunction( ply, tr, ClassName, activator )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + Vector(0, 0, 4)
	local SpawnAng = tr.HitNormal:Angle()
	SpawnAng.p = SpawnAng.p +90
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()
	ent:SetTrigger( 1 )
	ent:SetColor( Color( 0, 0, 0, 0 ) )
	ent:SetRenderMode( RENDERMODE_TRANSALPHA ) 
	return ent
end

function ENT:OnRemove()
	self.Timer = "kisel_" .. self:EntIndex()
	self:StopSound("buzz_idle")
	timer.Stop("kisel_activated")
	timer.Stop("kisel_recharge")
	timer.Stop(self.Timer)
end