PLUGIN.name = "NVG"
PLUGIN.author = "Scrat Knapp & Zeta"
PLUGIN.description = "Plugin for working NVGs based on Artic's Night Vision addon."


local playerMeta = FindMetaTable("Player")

function PLUGIN:PlayerLoadedCharacter(client, character, currentChar)
    client:SetNWInt("nvg", 0)
    local inventory = client:GetCharacter():GetInventory()

    for k, v in pairs (inventory:GetItems()) do
        if(!v:GetData("equip", false)) then continue end --ignores unequipped items
        if v.isNVG then ArcticNVGs_SetPlayerGoggles(client, v.goggleType) end 
    end
end 

ix.option.Add("ToggleNVGs", ix.type.string, "N", {
	category = "STALKER Controls",
	OnChanged = function(oldValue, value) end
})

ix.lang.AddTable("english", {
	optToggleNVGs = "Toggle NVGs",
	optdToggleNVGs = "The key to toggle the night vision goggles."
})

if (SERVER) then
    hook.Add("ArcticNVGs_PlayerCanToggle", "NVGPowerCheck", function(ply)
        local char = ply:GetCharacter()
        if not char then return end

        local inventory = char:GetInventory()
        if not inventory then return end

        local nvgItem
        for _, item in pairs(inventory:GetItems()) do
            if item.isNVG and item:GetData("equip") then
                nvgItem = item
                break
            end
        end

        if not nvgItem then
            return false
        end

        -- If NVGs are off, we are trying to turn them on.
        if not ply:GetNWBool("nvg_on", false) then
            if nvgItem:GetData("durability", 0) <= 0 then
                ply:Notify("Your NVGs have no power.")
                return false -- Prevent toggling on.
            end
        end

        return true
    end)
end

if (CLIENT) then
	function PLUGIN:PlayerButtonDown(client, button)
		local key = ix.option.Get("ToggleNVGs", "N")
		local buttonName = input.GetKeyName(button)

		if (buttonName and key and buttonName:upper() == key:upper()) then
			local char = client:GetCharacter()
			if (char and !vgui.GetKeyboardFocus() and IsFirstTimePredicted()) then
				-- Check for equipped NVG and power before sending the command
				local inventory = char:GetInventory()
				if not inventory then
					RunConsoleCommand("arc_vm_nvg")
					return
				end

				local nvgItem
				for _, item in pairs(inventory:GetItems()) do
					if item.isNVG and item:GetData("equip") then
						nvgItem = item
						break
					end
				end

				-- If we have an NVG equipped and we're trying to turn it on without power
				if nvgItem and not client:GetNWBool("nvg_on", false) and nvgItem:GetData("durability", 0) <= 0 then
					client:Notify("Your NVGs have no power.")
					return -- Don't run the command
				end

				RunConsoleCommand("arc_vm_nvg")
			end
		end
	end
end