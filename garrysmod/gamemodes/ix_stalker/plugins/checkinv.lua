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
			if (IsValid(ix.gui.invCheck)) then
				ix.gui.invCheck:Remove()
			end

			local frame = vgui.Create("DFrame")
			frame:SetSize(ScrW() * 0.5, ScrH() * 0.6)
			frame:Center()
			frame:SetTitle("Inventory Check")
			frame:MakePopup()
			frame:ShowCloseButton(true)
			
			frame.OnClose = function()
				netstream.Start("invCheckExit")
			end

			ix.gui.invCheck = frame

			local leftScroll = vgui.Create("DScrollPanel", frame)
			leftScroll:Dock(LEFT)
			leftScroll:SetWide(frame:GetWide() / 2 - 4)
			leftScroll:DockMargin(0, 0, 4, 0)

			local rightScroll = vgui.Create("DScrollPanel", frame)
			rightScroll:Dock(RIGHT)
			rightScroll:SetWide(frame:GetWide() / 2 - 4)

			local function SetupInv(inv, parent, title)
				local pnl = vgui.Create("ixInventory", parent)
				pnl:SetInventory(inv)
				pnl:SetTitle(title)
				pnl:ShowCloseButton(false)
				pnl:SetDraggable(false)
				pnl:SetSizable(false)
				pnl.MakePopup = function() end
				pnl:Dock(TOP)
				pnl:DockMargin(0, 0, 0, 5)
			end

			SetupInv(inventory, leftScroll, "Checked Inventory: " .. (name or "Unknown"))

			local inventory2 = LocalPlayer():GetCharacter():GetInventory()
			if (inventory2) then
				SetupInv(inventory2, rightScroll, "Your Inventory")
			end
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