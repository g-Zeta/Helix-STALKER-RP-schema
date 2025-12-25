PLUGIN.name = "IK Enabler"
PLUGIN.author = "Zeta"
PLUGIN.description = "Enables Inverse Kinematics for player models to allow for more natural animations."

if (CLIENT) then
	-- This hook is called when a new entity is created on the client
	-- We'll use it to enable IK on players
	function PLUGIN:NetworkEntityCreated(entity)
		if (entity:IsPlayer()) then
			-- The base Helix hook sets IK to false. We'll run this with a slight
			-- delay to ensure our setting is applied *after* the base hook runs
			timer.Simple(0, function()
				if (IsValid(entity)) then
					entity:SetIK(true)
				end
			end)
		end
	end

	-- This hook is called when a player spawns
	-- We need to re-apply IK settings here as well
	function PLUGIN:player_spawn(data)
		local client = Player(data.userid)

		if (IsValid(client)) then
			-- A timer is used here as well to ensure this runs after other spawn logic
			timer.Simple(0, function()
				if (IsValid(client)) then
					client:SetIK(true)
				end
			end)
		end
	end
end
