PLUGIN.name = "Armor"
PLUGIN.author = "Lt. Taylor & Zeta"
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

	netstream.Hook("ixCheckCharResistances", function(header, body)
		chat.AddText(Color(0, 195, 255), header, Color(240, 240, 240), body)
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

function ix.util.PropertyDescResistances(tooltip, text, value, imagestring)
	if !tooltip:GetRow("resistanceheader") then
		local descheader = tooltip:AddRow("resistanceheader")
		descheader:SetText("\nRESISTANCES:")
		descheader:SizeToContents()
		descheader:SetContentAlignment(4)
	end

	local dot
	if !tooltip:GetRow("resistance_row") then
		dot = tooltip:AddRowAfter("resistanceheader", "resistance_row")
	else
		dot = tooltip:AddRowAfter("resistance_row", "resistance_row")
	end

	dot:SetText("")

	local image = dot:Add("DImage")
	image:SetMaterial(imagestring)
	image:SetPos(8, 0)
	image:SetSize(dot:GetTall(), dot:GetTall())

	local desctext = dot:Add("DLabel")
	desctext:MoveRightOf(image)
	desctext:SetText(" " .. text)
	desctext:SetTextColor(Color(255, 255, 255))
	desctext:SetFont("ixSmallFont")
	desctext:SizeToContents()

	local valueLabel = dot:Add("DLabel")
	valueLabel:MoveRightOf(desctext)
	valueLabel:SetText(": " .. value)
	valueLabel:SetTextColor(Color(255, 255, 255))
	valueLabel:SetFont("ixSmallFont")
	valueLabel:SizeToContents()

	dot:SetWide(image:GetWide() + desctext:GetWide() + valueLabel:GetWide() + 15)

	tooltip:SizeToContents()
end

ix.command.Add("CheckCharResistances", {
	description = "Displays your current character's anomalous resistances.",
	OnRun = function(self, client)
		local char = client:GetChar()
		if not char then
			client:Notify("You do not have a character.")
			return
		end
		
		local inventory = char:GetInv()
		local resistances = {
			["Bullet"] = 0,
			["Impact"] = 0,
			["Slash"] = 0,
			["Thermal"] = 0,
			["Electrical"] = 0,
			["Chemical"] = 0,
			["Psi"] = 0,
			["Radiation"] = 0,
		}
		
		for k, v in pairs(inventory:GetItems()) do
			if v:GetData("equip", false) then
				local itemRes = v:GetData("custom", {}).res or v.res or {}

				for resType, value in pairs(itemRes) do
					if resistances[resType] then
						resistances[resType] = resistances[resType] + value
					end
				end
			end
		end
		
		local chemBuff = client:GetNetVar("ix_chemprot", 0)
		if (chemBuff > 0) then
			resistances["Chemical"] = resistances["Chemical"] + (chemBuff / 100)
		end

		local radBuff = client:GetNetVar("ix_radprot", 0)
		if (radBuff > 0) then
			resistances["Radiation"] = resistances["Radiation"] + (radBuff / 100)
		end

		local psyBuff = client:GetNetVar("ix_psyblock", 0)
		if (psyBuff > 0) then
			resistances["Psi"] = resistances["Psi"] + (psyBuff / 100)
		end

		local header = "Your current resistances are:\n"
		local body = ""
		local resistanceOrder = {
			"Bullet",
			"Impact",
			"Slash",
			"Thermal",
			"Electrical",
			"Chemical",
			"Psi",
			"Radiation"
		}

		for _, resType in ipairs(resistanceOrder) do
			local value = resistances[resType]
			body = body .. string.format("%s:\t%.2f%%\n", resType, value * 100)
		end
		
		netstream.Start(client, "ixCheckCharResistances", header, body)
	end
})

ix.option.Add("gasmaskoverlay", ix.type.bool, true, {
	category = "STALKER Settings",
})

ix.option.Add("gasmaskbreathsound", ix.type.bool, true, {
	category = "STALKER Settings",
})