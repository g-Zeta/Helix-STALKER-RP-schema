ENT.Type = "anim"
ENT.Base = "base_anim"
 
ENT.PrintName		= "Psi-field - Large"
ENT.Author			= "Zeta"
ENT.Contact			= ""
ENT.Purpose			= "Affects the psyche of players in a large radius"
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
