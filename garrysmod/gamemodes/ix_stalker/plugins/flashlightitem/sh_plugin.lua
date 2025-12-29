
PLUGIN.name = "Flashlight item"
PLUGIN.author = "SleepyMode"
PLUGIN.description = "Adds an item allowing players to toggle their flashlight."

function PLUGIN:PlayerSwitchFlashlight(client, bEnabled)
	local character = client:GetCharacter()
	local inventory = character and character:GetInventory()

	if (inventory) then
		for _, item in pairs(inventory:GetItems()) do
			if (item.uniqueID == "headlamp" and item:GetData("equip")) then
				return true
			end
		end
	end
end