AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create( self.ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self.Entity:SetModel("models/anomaly/anomaly_fix.mdl")
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_BBOX)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self.Entity:SetKeyValue("rendercolor", "150 255 150")
	self.Entity:SetKeyValue("renderamt", "0")
    local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

    self:SetNWInt("Range", range)
	self.delayTime = 0
end

function ENT:Think()
	local range = self:GetNWInt("Range", 256)
	local psiamount = 1
	if (self.delayTime or 0) < CurTime() then
		for k, v in pairs(ents.FindInSphere(self.Entity:GetPos(), range + 256)) do
            if v:IsPlayer() and v:GetCharacter() and v:GetMoveType() != MOVETYPE_NOCLIP then
                local distance = v:GetPos():Distance(self:GetPos())
                if distance <= range then
                    local TEMP_TargetDamage = DamageInfo()
					local damageAmount
					--Calculate damage amount based on distance within the entity's radius
					if distance < (range / 2) then
						damageAmount = psiamount
					elseif distance >= (range / 2) then
						damageAmount = psiamount / 2
					end
                    TEMP_TargetDamage:SetDamage(damageAmount)
					TEMP_TargetDamage:SetInflictor(self)
                    TEMP_TargetDamage:SetDamageType(DMG_SONIC)
                    TEMP_TargetDamage:SetAttacker(self)
                    v:TakeDamageInfo(TEMP_TargetDamage)
                end
            end
        end
    end
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

function ENT:OnRemove()
end