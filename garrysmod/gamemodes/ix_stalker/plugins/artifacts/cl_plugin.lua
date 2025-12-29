if CLIENT then
    -- Function to draw the artifact image on the HUD
    function DrawArtifactHUD()
        local client = LocalPlayer() -- Get the local player

        -- Check if the client is valid and has a character
        if not IsValid(client) then return end

        local character = client:GetCharacter() -- Get the player's character
        
        -- Check if the character exists
        if not character then
            return -- Exit if there is no character
        end

        local inv = character:GetInv() -- Get the inventory
        
        -- Check if the inventory exists
        if not inv then
            return -- Exit if there is no inventory
        end

        local items = inv:GetItems() -- Get the items in the inventory

        local x = 360 * (ScrW()/1920) -- Starting X position
        local y = 950 * (ScrH()/1080) -- Y position
        local imageSize = 64 -- Size of the artifact images
		
		-- Iterate through the items to find the equipped artifact
		for _, item in pairs(items) do
			if item.isArtefact and item:GetData("equip", false) then

				-- If the item is an artifact and it is equipped
				local artifactImage = item.img -- Get the artifact image

				-- Draw the artifact image on the HUD
				surface.SetMaterial(artifactImage)
				surface.SetDrawColor(255, 255, 255, 255) -- Set color to white
				surface.DrawTexturedRect(x, y, imageSize * (ScrW()/1920), imageSize * (ScrH()/1080)) -- Draw the image (width, height)

                -- Update the x position for the next artifact
                x = x + 5 + imageSize -- Move x to the right for the next image

			end
		end
    end

    -- Hook the HUD drawing function to the HUDPaint event
    hook.Add("HUDPaint", "DrawArtifactHUD", DrawArtifactHUD)

end