
PLUGIN.name = "Flashlight item"
PLUGIN.author = "SleepyMode"
PLUGIN.description = "Adds an item allowing players to toggle their flashlight."

function PLUGIN:PlayerSwitchFlashlight(client, bEnabled)
	local character = client:GetCharacter()

	if (character and character:GetFaction() == FACTION_STAFF) then
		return true
	end

	local inventory = character and character:GetInventory()

	if (inventory) then
		for _, item in pairs(inventory:GetItems()) do
			if (item.isFlashlight and item:GetData("equip")) then
				if (bEnabled and item:GetData("durability", 0) <= 0) then
					client:Notify("Your headlamp has no power.")
					return false
				end

				return true -- Allow turning off without a battery.
			end
		end
	end
end