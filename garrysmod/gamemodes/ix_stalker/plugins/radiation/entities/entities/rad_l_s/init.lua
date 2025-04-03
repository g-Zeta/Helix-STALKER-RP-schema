AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
local delayTime = 0
local range = 512
local radiationamount = 1
local geigerHeavy = {"stalker/detectors/geiger_3.ogg", "stalker/detectors/geiger_4.ogg", "stalker/detectors/geiger_5.ogg", }
local geigerLight = {"stalker/detectors/geiger_1.ogg", "stalker/detectors/geiger_2.ogg", }

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create( self.ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:OnRemove()
end

function ENT:Initialize()

	self.Entity:SetModel( "models/props_junk/watermelon01.mdl" ) --Set its model.
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_BBOX)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self.Entity:SetKeyValue("rendercolor", "150 255 150")
	self.Entity:SetKeyValue("renderamt", "0")
	self.Entity:SetMaterial("models/props_combine/portalball001_sheet")
	self.Entity:SetPersistent(true)
        local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Think()
	if delayTime < CurTime() then
		delayTime = CurTime() + 0.5
		for k, v in pairs( ents.FindInSphere( self.Entity:GetPos(), 2560 )  ) do
			if v:IsPlayer() and v:GetCharacter() and v:GetMoveType() != MOVETYPE_NOCLIP then
				local items = v:GetCharacter():GetInventory():GetItems(true)
				
				if v:GetPos( ):Distance( self:GetPos( ) ) <= range then
				
					local TEMP_TargetDamage = DamageInfo()
								
					TEMP_TargetDamage:SetDamage(radiationamount)
					TEMP_TargetDamage:SetInflictor(self)
					TEMP_TargetDamage:SetDamageType(DMG_RADIATION)
					TEMP_TargetDamage:SetAttacker(self)

					v:TakeDamageInfo(TEMP_TargetDamage)
					
					if v:hasGeiger() then
						local randomsound = table.Random(geigerHeavy)
						v:EmitSound(randomsound)
					end
				elseif v:GetPos( ):Distance( self:GetPos( ) ) <= range + 256 then
					if v:hasGeiger() then
						local randomsound = table.Random(geigerLight)
						v:EmitSound(randomsound)
					end
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
