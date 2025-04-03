PLUGIN.name = "Armor"
PLUGIN.author = "Lt. Taylor"
PLUGIN.desc = "Armor system including durability, upgrades, and anomaly resistances."
PLUGIN.repairFlag = "R"

ix.flag.Add(PLUGIN.repairFlag, "Access to repair things.")

ix.config.Add("Min Durability - Modify", 100, "Minimum durability req. for modding armor.", nil, {
	data = {min = 0, max = 100, decimals = 2},
    category = "Durability"
})

ix.config.Add("Min Durability - Sell", 100, "Minimum durability req. for selling armor.", nil, {
	data = {min = 0, max = 100, decimals = 2},
    category = "Durability"
})

if (CLIENT) then
	local PANEL = {}
	function PANEL:Init()
	    local DuraSlider = self:Add("DNumSlider")
		DuraSlider:SetText("Armor Durability")
		DuraSlider:SetMin(0)
		DuraSlider:SetMax(100)
		DuraSlider:SetDecimals(0)
		DuraSlider:Dock(FILL)
		
		self:SetTitle("Set Armor Durability")
		self:SetSize(400, 150)
		self:Center()
		self:MakePopup()

		self.submit = self:Add("DButton")
		self.submit:Dock(BOTTOM)
		self.submit:DockMargin(0, 5, 0, 0)
		self.submit:SetTall(25)
		self.submit:SetText("Confirm")
		self.submit.DoClick = function()
		    local dura = DuraSlider:GetValue()
    		netstream.Start("armordurabilityAdjust", (dura * 100), self.itemID)
    		self:Close()
		end
	end

	function PANEL:Think()
		self:MoveToFront()
	end

	vgui.Register("ArmorDurabilityMenu", PANEL, "DFrame")

	netstream.Hook("armordurabilityAdjust", function(dura, id)
		local adjust = vgui.Create("ArmorDurabilityMenu")

		if (id) then
			adjust.itemID = id
		end
	end)
else
	netstream.Hook("armordurabilityAdjust", function(client, dura, id)
		local inv = (client:GetChar() and client:GetChar():GetInv() or nil)

		if (inv) then
			local item
			if (id) then
				item = ix.item.instances[id]
    			local ent = item:GetEntity()
    			if (item and (IsValid(ent) or item:GetOwner() == client)) then
    				(ent or client):EmitSound("buttons/combine_button1.wav", 50, 170)
                    dura = math.Round(dura)
    				item:SetData("durability", dura)
    			else
    				client:Notify("No Armor")
    			end
			end
		end
	end)
end

ix.command.Add("CharResistances", {
	description = "Displays your current resistances.",
	OnRun = function(self, client)
		local char = client:GetChar()
		if not char then
			client:Notify("You do not have a character.")
			return
		end
		
		local inventory = char:GetInv()
		local resistances = {
			["Fall"] = 0,
			["Burn"] = 0,
			["Shock"] = 0,
			["Chemical"] = 0,
			["Psi"] = 0,
			["Radiation"] = 0,
		}
		
		for k, v in pairs(inventory:GetItems()) do
			if v:GetData("equip", false) then
				for resType, value in pairs(v.res or {}) do
					if resistances[resType] then
						resistances[resType] = resistances[resType] + value
					end
				end
			end
		end
		
		local response = "Your current resistances are:\n"
		for resType, value in pairs(resistances) do
			response = response .. string.format("%s: %.2f%%\n", resType, value * 100)
		end
		
		client:ChatPrint(response)
	end
})