AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local geigerHeavy = {"geiger/heavy/geiger_heavy_1.wav", "geiger/heavy/geiger_heavy_2.wav", }
local geigerMid = {"geiger/light/geiger_light_5.wav", "geiger/heavy/geiger_heavy_4.wav", "geiger/heavy/geiger_heavy_5.wav", }
local geigerLight = {"geiger/light/geiger_light_1.wav", "geiger/light/geiger_light_2.wav", }

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
	local radiationamount = 1
	if (self.delayTime or 0) < CurTime() then
		for k, v in pairs(ents.FindInSphere(self.Entity:GetPos(), range + 256)) do
			if v:IsPlayer() and v:GetCharacter() then
				local items = v:GetCharacter():GetInventory():GetItems(true)

				local tr = util.TraceLine({
					start = self:GetPos() + Vector(0, 0, 10),
					endpos = v:BodyTarget(self:GetPos()),
					filter = {self, v},
					mask = MASK_SOLID_BRUSHONLY
				})

				if (tr.Hit) then continue end
				
				local distance = v:GetPos():Distance(self:GetPos())
				if distance <= range then
					local delay = distance / range
					self.delayTime = CurTime() + delay
					local TEMP_TargetDamage = DamageInfo()
								
					TEMP_TargetDamage:SetDamage(radiationamount)
					TEMP_TargetDamage:SetInflictor(self)
					TEMP_TargetDamage:SetDamageType(DMG_RADIATION)
					TEMP_TargetDamage:SetAttacker(self)

					if v:GetMoveType() != MOVETYPE_NOCLIP then
						v:TakeDamageInfo(TEMP_TargetDamage)
					end
					
					if v:hasGeiger() then
						local randomsound
						if distance <= (range / 2) then
							randomsound = table.Random(geigerHeavy)
						else
							randomsound = table.Random(geigerMid)
						end
						v:EmitSound(randomsound)
					end
				elseif distance <= range + 256 then
					self.delayTime = CurTime() + 1
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
