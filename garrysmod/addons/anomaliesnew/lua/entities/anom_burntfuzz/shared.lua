ENT.Type = "anim"
ENT.Base = "base_anim"
 
ENT.PrintName		= "Burnt Fuzz"
ENT.Author			= "unknown"
ENT.Purpose			= "Damages nearby entities"
ENT.Category 		= "Anomalies"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true

/*---------------------------------------------------------
   Name: OnRemove
   Desc: Called just before entity is deleted
---------------------------------------------------------*/
function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
end

function ENT:PhysicsCollide(data,phys)

end
