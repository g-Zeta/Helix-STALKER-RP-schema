ENT.Type = "anim"
ENT.Base = "base_anim"
 
ENT.PrintName		= "Radiation - Heavy - Small"
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= "Irradiates players heavily in a radius of 256 units."
ENT.Category 		= "Radiation"

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
