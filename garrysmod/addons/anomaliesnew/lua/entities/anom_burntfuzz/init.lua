AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

ENT.AutomaticFrameAdvance = true 
local delayTime = 0
local anomalyID = tostring(math.Rand(1,2))

function ENT:OnRemove()
	timer.Destroy(anomalyID)
end


function ENT:Initialize()

	self.Entity:SetModel( "models/zerochain/props_stalker/burntfuzz.mdl" ) --Set its model.
	self.Entity:SetMoveType(MOVETYPE_NONE)  
	self.Entity:SetSolid(SOLID_BBOX)	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	
    local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.Entity:ResetSequenceInfo() 
end

function ENT:Think()
	self.Entity:SetSequence("idle_move")
	if delayTime < CurTime() then
		delayTime = CurTime() + 0.5
		for k, v in pairs( ents.FindInBox( self:GetPos() + Vector(-32,-32,0), self:GetPos() + Vector(32,32,-220))) do
			
			if v:IsPlayer() and v:Alive() and v:IsValid() then
				local b = DamageInfo()
				b:SetDamage( 15 )
				b:SetDamageType( DMG_ACID )
				b:SetAttacker( self.Entity )
				b:SetInflictor( self.Entity )

				v:TakeDamageInfo( b )
			
			self:EmitSound("ambient/levels/canals/toxic_slime_sizzle3.wav")
			end
		end
	end
	self:NextThink(CurTime())
	return true
end

function ENT:Use( activator, caller, type, value )
end

function ENT:KeyValue( key, value )
end

function ENT:OnTakeDamage( dmginfo )
end

function ENT:StartTouch( entity )
end

function ENT:EndTouch( entity )
end

function ENT:Touch( entity )
end

