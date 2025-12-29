local PLUGIN = PLUGIN

PLUGIN.name = "Check Inventory"
PLUGIN.author = "some faggot"
PLUGIN.desc = "Simple command to check inventory of target player"

ix.command.Add("charcheckinv", {
	adminOnly = true,
	arguments = {
		ix.type.character,
	},
	OnRun = function(self, client, character)
		if character then
			local target = character
			local inventory = target:GetInventory()
		
			if (target and target != client) then
				inventory:Sync(client)
				inventory:AddReceiver(client)
				
				netstream.Start(client, "invCheck", inventory:GetID(), target:GetName())
	        elseif target == client then
	        	client:Notify("Can't check yourself")
	        else
	            client:Notify("Player not found")
	        end
	    end
	end
})

ix.command.Add("charcheckmoney", {
	adminOnly = true,
	arguments = {
		ix.type.character,
	},	
	OnRun = function(self, client, character)
		if character then
			local target = character
		
			if (target and target != client) then
				client:Notify("Target has "..ix.currency.Get(target:GetMoney()))
	        elseif target == client then
	        	client:Notify("Can't check yourself")
	        else
	            client:Notify("Player not found")
	        end
	    end
	end
})

if CLIENT then
	netstream.Hook("invCheck", function(index, name)
		local inventory = ix.item.inventories[index]

		if (inventory and inventory.slots) then
			
			local w, h = 500, 600

			ix.gui.inv1 = vgui.Create("DFrame")
			ix.gui.inv1:SetSize(w, h)
			ix.gui.inv1:SetTitle("Your Inventory")
			ix.gui.inv1:ShowCloseButton(true)
			ix.gui.inv1:SetPos(ScrW()*0.5 + 10, ScrH()*0.5 - h*0.5)
			ix.gui.inv1:MakePopup()

			local scroll1 = ix.gui.inv1:Add("DScrollPanel")
			scroll1:Dock(FILL)

			local inv1 = scroll1:Add("ixInventory")
			inv1:SetTitle(nil)
			inv1:SetDraggable(false)
			inv1:SetSizable(false)

			local inventory2 = LocalPlayer():GetCharacter():GetInventory()

			if (inventory2) then
				inv1:SetInventory(inventory2)
				ix.gui.inv1:SetWide(inv1:GetWide() + 32)
			end

			ix.gui.inv1.childPanels = {}
			ix.gui.inv1.GetIconSize = function() return inv1:GetIconSize() end
			ix.gui.inv1.OnRemove = function(this)
				if (this.childPanels) then
					for _, v in ipairs(this.childPanels) do
						if (v != this) then
							v:Remove()
						end
					end
				end
			end

			local panel = vgui.Create("DFrame")
			panel:SetSize(w, h)
			panel:ShowCloseButton(true)
			panel:SetTitle("Checked inventory: " .. (name or "Unknown"))
			panel:MakePopup()

			local scroll2 = panel:Add("DScrollPanel")
			scroll2:Dock(FILL)

			local inv2 = scroll2:Add("ixInventory")
			inv2:SetTitle(nil)
			inv2:SetDraggable(false)
			inv2:SetSizable(false)
			inv2:SetInventory(inventory)
			panel:SetWide(inv2:GetWide() + 32)
			panel:SetPos(ScrW()*0.5 - panel:GetWide() - 10, ScrH()*0.5 - h*0.5)

			panel.OnClose = function(this)
				if (IsValid(ix.gui.inv1) and !IsValid(ix.gui.menu)) then
					ix.gui.inv1:Remove()
				end

				netstream.Start("invCheckExit")
			end

			local oldClose = ix.gui.inv1.OnClose
			ix.gui.inv1.OnClose = function()
				if (IsValid(panel) and !IsValid(ix.gui.menu)) then
					panel:Remove()
				end

				netstream.Start("invCheckExit")
				-- IDK Why. Just make it sure to not glitch out with other stuffs.
				if ix.gui.inv1 then
					ix.gui.inv1.OnClose = oldClose
				end
			end

			ix.gui["inv"..index] = panel
		end
	end)
else
	netstream.Hook("invCheckExit", function(client)
		local entity = client.ixBagEntity

		if (IsValid(entity)) then
			entity.receivers[client] = nil
		end

		client.ixBagEntity = nil
	end)
end