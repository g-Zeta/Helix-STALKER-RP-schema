local PLUGIN = PLUGIN

function PLUGIN:RenderScreenspaceEffects()
local character = LocalPlayer():GetCharacter()
	if character and ix.option.Get("gasmaskoverlay", false) and LocalPlayer():GetNetVar("gasmask") == true then
		local inventory = character:GetInventory()
		local items = inventory:GetItems()
		local armorHealth = 10000
		for k, v in pairs(items) do
			if (v.overlayPath != nil and v:GetData("equip")) then
				armorHealth = v:GetData("durability", 10000)

				if (armorHealth <= 0) then
					DrawMaterialOverlay( v.overlayPath.."12.png", 0.2 )
				elseif (armorHealth <= 1000) then
					DrawMaterialOverlay( v.overlayPath.."11.png", 0.2 )
				elseif (armorHealth <= 2000) then
					DrawMaterialOverlay( v.overlayPath.."9.png", 0.2 )
				elseif (armorHealth <= 4000) then
					DrawMaterialOverlay( v.overlayPath.."7.png", 0.2 )
				elseif (armorHealth <= 6000) then
					DrawMaterialOverlay( v.overlayPath.."5.png", 0.2 )
				elseif (armorHealth <= 8000) then
					DrawMaterialOverlay( v.overlayPath.."3.png", 0.2 )
				else
					DrawMaterialOverlay( v.overlayPath.."1.png", 0.2 )
				end
			end
		end
	end
end