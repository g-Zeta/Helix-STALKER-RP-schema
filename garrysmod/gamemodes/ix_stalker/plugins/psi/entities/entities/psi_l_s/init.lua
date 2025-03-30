AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
local delayTime = 0
local range = 512
local psiamount = 1
local psisound = {"anomalyrp/player/phy/psy_voices_1_l.wav", "anomalyrp/player/phy/psy_voices_1_r.wav",	}

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
	self.Entity:SetModel( "models/props_junk/watermelon01.mdl" ) --Set its model
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_BBOX )
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

local isSoundPlaying = false
local initialVolume = 0	--starting volume of the sound
local maxVolume = 1	--maximum volume the sound will reach
local volumeInterval = 0.1
local soundEmitter

function ENT:Think()
    if delayTime < CurTime() then
        delayTime = CurTime() + 0.5
        for k, v in pairs(ents.FindInSphere(self.Entity:GetPos(), 2560)) do
            if v:IsPlayer() and v:GetCharacter() and v:GetMoveType() != MOVETYPE_NOCLIP then
                local distance = v:GetPos():Distance(self:GetPos())
                if distance <= range then
                    local TEMP_TargetDamage = DamageInfo()
					local damageAmount
					--Calculate damage amount based on distance within the entity's radius
					if distance < (range / 2) then
						damageAmount = psiamount
					elseif distance < (range * 0.75) and distance >= (range / 2) then
						damageAmount = psiamount / 2
					elseif distance >= (range * 0.75) then
						damageAmount = psiamount / 4
					end
                    TEMP_TargetDamage:SetDamage(damageAmount)
					TEMP_TargetDamage:SetInflictor(self)
                    TEMP_TargetDamage:SetDamageType(DMG_SONIC)
                    TEMP_TargetDamage:SetAttacker(self)
                    v:TakeDamageInfo(TEMP_TargetDamage)

                    if not isSoundPlaying then
                        isSoundPlaying = true
                        local randomsound = table.Random(psisound)
                        soundEmitter = CreateSound(v, randomsound)
                        soundEmitter:PlayEx(initialVolume, 100)

                        timer.Create("AdjustVolumeTimer", volumeInterval, 0, function()
                            if isSoundPlaying and IsValid(v) and IsValid(self) then
                                local newDistance = v:GetPos():Distance(self:GetPos())
                                local volume = math.Clamp(1 - (newDistance / range), 0, 1)
                                soundEmitter:ChangeVolume(volume, 0)
                            end
                        end)
                    end
                elseif isSoundPlaying then
                    isSoundPlaying = false
                    if soundEmitter then
                        soundEmitter:Stop()
                        soundEmitter = nil
                        timer.Remove("AdjustVolumeTimer")
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

function ENT:OnRemove()
end