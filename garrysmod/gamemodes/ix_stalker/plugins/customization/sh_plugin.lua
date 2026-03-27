local PLUGIN = PLUGIN
PLUGIN.name = "Item Customization"
PLUGIN.author = "Unknown (modified by Zeta)"
PLUGIN.desc = "This plugin allows you to customize existing items or create new ones."

if(SERVER) then
	util.AddNetworkString("ixCustom")
	util.AddNetworkString("ixCustomA")
	util.AddNetworkString("ixSwepUpdate")
	util.AddNetworkString("ixCustomF")
	util.AddNetworkString("ixAttribF")

	--updates clientside values of sweps
	function PLUGIN:updateSWEP(client, item)
		local customData = item:GetData("custom", {})
		
		if(item.class) then --i dont know why i need this here
			local swep = weapons.Get(item.class)
			local itemInfo = {}
			
			itemInfo.class = item.class
			
			itemInfo.wepDmg = customData.wepDmg or (swep and swep.Damage)
			itemInfo.wepSpd = customData.wepSpd or (swep and swep.FireDelay)
			itemInfo.wepAcc = customData.wepAcc
			itemInfo.wepRec = customData.wepRec
			itemInfo.wepMag = customData.wepMag or (swep and swep.Primary.ClipSize)
			
			itemInfo.name = customData.name
			
			net.Start("ixSwepUpdate")
				net.WriteTable(itemInfo)
			net.Send(client)
		end
	end	
	
	--customization statrt
	function PLUGIN:startCustom(client, item, extra)
		--customizations require a flag in the items set, so it's unnecessary to do this here, uncomment it if you want.
		--[[
		if !client:IsAdmin() then
			return
		end
		--]]

		local customData = item:GetData("custom", {})
	
		local itemInfo = {}
		itemInfo.id = item.id
		itemInfo.name = item:GetName() or item.name
		itemInfo.description = customData.desc or item.description
		itemInfo.longdesc = customData.longdesc or item.longdesc or ""
		--itemInfo.color = customData.color or item.color or ix.config.Get("color") or Color(255, 255, 255)
		itemInfo.model = customData.model or item.model
		itemInfo.material = customData.material or item.material
		itemInfo.quality = customData.quality
		itemInfo.weight = customData.weight or item.weight
		itemInfo.price = customData.price or item.price
		
		if(item.isWeapon) then
			itemInfo.weapon = true
			itemInfo.dura = item:GetData("durability", 100)
		end
		
		if(item.isArmor) then
			itemInfo.armor = true
			itemInfo.dura = item:GetData("durability", 100)
		end

		if(item.isGasmask and not item.isArmor) then
			itemInfo.gasmask = true
			itemInfo.dura = item:GetData("durability", 100)
		end

		if(item.isHelmet and not item.isArmor) then
			itemInfo.helmet = true
			itemInfo.dura = item:GetData("durability", 100)
		end

		if(item.quantity or item.maxStack or item.ammoAmount) then
			itemInfo.quantity = true		
			itemInfo.quantity = item:GetData("quantity", item.maxStack or item.quantity or item.ammoAmount) or customData.quantity or 100
		end

		if (item.res) then
			itemInfo.res = customData.res or item.res
		end
		
		net.Start("ixCustom")
			net.WriteTable(itemInfo)
		net.Send(client)
	end
	
	--attribute customization start
	function PLUGIN:startCustomA(client, item)
		local char = client:GetCharacter()
		if not char or not char:HasFlags("N") then return end

		local attribData = item:GetData("attrib", item.attribBoosts) or {}
	
		local itemInfo = {}
		itemInfo.id = item.id
		itemInfo.attrib = attribData
		
		net.Start("ixCustomA")
			net.WriteTable(itemInfo)
		net.Send(client)
	end

	--regular finish hook
	net.Receive("ixCustomF", function(_, client)
		local char = client:GetCharacter()
		if not char or not char:HasFlags("N") then return end

		local id = net.ReadUInt(32)
		local item = ix.item.instances[id]

		if not item or item:GetOwner() != client then return end

		local customData = net.ReadTable()

		/*if(customData.dura and customData.quality) then
			local qualities = {
				[1] = "Garbage",
				[2] = "Terrible",
				[3] = "Awful",
				[4] = "Bad",
				[5] = "Poor",
				[6] = "Normal",
				[7] = "Standard",
				[8] = "Decent",
				[9] = "Good",
				[10] = "Great",
				[11] = "Excellent",
				[12] = "Master",
				[14] = "Near-Perfect",
				[15] = "Perfect",
				[16] = "Transcendent"
			}		
		
			local maxDura = (table.KeyFromValue(qualities, customData.quality) or 7) * 1000
			
			item:SetData("maxDura", maxDura)
			customData.dura = (customData.dura / 100) * maxDura
			
			if(customData.quality == "None") then
				customData.quality = nil
			end
		end*/
		
		if (customData.dura) then
			item:SetData("durability", customData.dura)
		end

		if (customData.quantity) then
			item:SetData("quantity", customData.quantity)
		end

		if (item) then
			item:SetData("custom", customData)
		end
	end)	
	
	--attribute finish hook
	net.Receive("ixAttribF", function(_, client)
		local char = client:GetCharacter()
		if not char or not char:HasFlags("N") then return end

		local id = net.ReadUInt(32)
		local item = ix.item.instances[id]
		
		if not item or item:GetOwner() != client then return end

		local attribData = net.ReadTable()
		item:SetData("attrib", attribData)
	end)
else
	--clientside hook for menus
	net.Receive("ixCustom", function()
		local data = net.ReadTable()
		local item = data
	
		--current values of item
		local name = item.name
		local desc = item.description
		local longdesc = item.longdesc
		--local color = item.color
		local model = item.model
		local material = item.material or ""
		local quality = item.quality or "None"
		local weight = item.weight
		local price = item.price

		local dura = item.dura
		local quantity = (item.maxStack or item.ammoAmount or item.quantity)
		local dmg = item.wepDmg
		local spd = item.wepSpd
		local acc = item.wepAcc
		local rec = item.wepRec
		local mag = item.wepMag
		local res = item.res
		

		local frame = vgui.Create("DFrame")
		frame:SetSize(450, 600)
		frame:Center()
		frame:SetTitle(name or "")
		frame:MakePopup()
		frame:ShowCloseButton(true)

		local scroll = vgui.Create("DScrollPanel", frame)
		scroll:Dock(FILL)

		--name customization
		local nameL = vgui.Create("DLabel", scroll)
		nameL:SetText("Name:")
		nameL:Dock(TOP)

		local nameC = vgui.Create("DTextEntry", scroll)
		nameC:SetText(name or "")
		nameC:Dock(TOP)

		--model customization
		local modelL = vgui.Create("DLabel", scroll)
		modelL:SetText("Worldmodel:")
		modelL:Dock(TOP)

		local modelC = vgui.Create("DTextEntry", scroll)
		modelC:SetText(model)
		modelC:Dock(TOP)

		--description customization
		local descL = vgui.Create("DLabel", scroll)
		descL:SetText("Description:")
		descL:Dock(TOP)

		local descC = vgui.Create("DTextEntry", scroll)
		descC:SetText(desc or "")
		descC:Dock(TOP)

		-- Long description customization
		local longdescL = vgui.Create("DLabel", scroll)
		longdescL:SetText("Long Description:")
		longdescL:Dock(TOP)

		local longdescC = vgui.Create("DTextEntry", scroll)
		longdescC:SetText(longdesc or "")
		longdescC:Dock(TOP)

		local weightL = vgui.Create("DLabel", scroll)
		weightL:SetText("Weight:")
		weightL:Dock(TOP)
		local weightC = vgui.Create("DTextEntry", scroll)
		weightC:SetText(weight or 0)
		weightC:Dock(TOP)

		local priceL = vgui.Create("DLabel", scroll)
		priceL:SetText("Price:")
		priceL:Dock(TOP)
		local priceC = vgui.Create("DTextEntry", scroll)
		priceC:SetText(price or 0)
		priceC:Dock(TOP)

		/*--material customization
		local materialL = vgui.Create("DLabel", scroll)
		materialL:SetText("Material:")
		materialL:Dock(TOP)

		local materialC = vgui.Create("DTextEntry", scroll)
		materialC:SetText(material or "")
		materialC:Dock(TOP)	*/
		
		/*--color customization
		local colorL = vgui.Create("DLabel", scroll)
		colorL:SetText("Color:")
		colorL:Dock(TOP)

		local colorC = vgui.Create("DColorMixer", scroll)
		colorC:Dock(TOP)
		colorC:SetColor(color)
		
		--color customization
		local colorRan = vgui.Create("DButton", scroll)
		colorRan:SetText("Random Color")
		colorRan:Dock(TOP)
		colorRan.DoClick = function()
			local ranColor = Color(math.random(0,255), math.random(0,255), math.random(0,255))
			colorC:SetColor(ranColor)
		end*/

		/*local qualities = {
			[0] = "None",
			[1] = "Garbage",
			[2] = "Terrible",
			[3] = "Awful",
			[4] = "Bad",
			[5] = "Poor",
			[6] = "Normal",
			[7] = "Standard",
			[8] = "Decent",
			[9] = "Good",
			[10] = "Great",
			[11] = "Excellent",
			[12] = "Master",
			[14] = "Near-Perfect",
			[15] = "Perfect",
			[16] = "Transcendent"
		}
		
		--quality customization
		local qualityL = vgui.Create("DLabel", scroll)
		qualityL:SetText("Quality:")
		qualityL:Dock(TOP)
		
		local qualityC = vgui.Create("DComboBox", scroll)
		qualityC:Dock(TOP)
		qualityC:SetValue(quality or "None")
		qualityC:SetSortItems(false)
		for k, v in SortedPairs(qualities) do
			qualityC:AddChoice(v)
		end*/
				
		--weapon stuff
		local wepC
		local duraC
		local dmgC
		local rpmC
		local accC
		local recC
		local magC
		
		if(item.weapon) then
			local duraL = vgui.Create("DLabel", scroll)
			duraL:SetText(" Durability:")
			duraL:Dock(TOP)		
			
			duraC = vgui.Create("DTextEntry", scroll)
			duraC:SetText(dura or 100)
			duraC:Dock(TOP)	

			wepC = vgui.Create("DCheckBoxLabel", scroll)
			wepC:SetText("SWEP Modifiers")
			wepC:SetValue(0)
			wepC:SetToolTip("Toggle this if you want any of the stuff below to apply.")
			wepC:Dock(TOP)			
			
			local dmgL = vgui.Create("DLabel", scroll)
			dmgL:SetText(" Damage:")
			dmgL:Dock(TOP)
			
			dmgC = vgui.Create("DTextEntry", scroll)
			dmgC:SetText(dmg or 1)
			dmgC:Dock(TOP)
			
			local rpmL = vgui.Create("DLabel", scroll)
			rpmL:SetText(" Fire Delay Multiplier:")
			rpmL:Dock(TOP)
			
			rpmC = vgui.Create("DTextEntry", scroll)
			rpmC:SetText(spd or 1)
			rpmC:Dock(TOP)
			
			local accL = vgui.Create("DLabel", scroll)
			accL:SetText(" Accuracy Multiplier:")
			accL:Dock(TOP)
			
			accC = vgui.Create("DTextEntry", scroll)
			accC:SetToolTip("Higher is worse.")
			accC:SetText(acc or 1)
			accC:Dock(TOP)		
			
			local recL = vgui.Create("DLabel", scroll)
			recL:SetText(" Recoil Multiplier:")
			recL:Dock(TOP)
			
			recC = vgui.Create("DTextEntry", scroll)
			recC:SetText(rec or 1)
			recC:Dock(TOP)
			
			local magL = vgui.Create("DLabel", scroll)
			magL:SetText(" Magazine Size:")
			magL:Dock(TOP)
			
			magC = vgui.Create("DTextEntry", scroll)
			magC:SetText(mag or 1)
			magC:Dock(TOP)
		end
		
		if (item.armor) then
			local duraL = vgui.Create("DLabel", scroll)
			duraL:SetText("Durability:")
			duraL:Dock(TOP)		
			
			duraC = vgui.Create("DTextEntry", scroll)
			duraC:SetText(dura or 100)
			duraC:Dock(TOP)
		end

		if (item.gasmask) then
			local duraL = vgui.Create("DLabel", scroll)
			duraL:SetText("Durability:")
			duraL:Dock(TOP)		
			
			duraC = vgui.Create("DTextEntry", scroll)
			duraC:SetText(dura or 100)
			duraC:Dock(TOP)
		end

		if (item.helmet) then
			local duraL = vgui.Create("DLabel", scroll)
			duraL:SetText("Durability:")
			duraL:Dock(TOP)		
			
			duraC = vgui.Create("DTextEntry", scroll)
			duraC:SetText(dura or 100)
			duraC:Dock(TOP)
		end

		local quantityC
		if (item.quantity or item.maxStack or item.ammoAmount) then
			local quantityL = vgui.Create("DLabel", scroll)
			quantityL:SetText(" Quantity:")
			quantityL:Dock(TOP)		
			
			quantityC = vgui.Create("DTextEntry", scroll)
			quantityC:SetText(quantity or 100)
			quantityC:Dock(TOP)		
		end

		local resC = {}
		if (res) then
			local resL = vgui.Create("DLabel", scroll)
			resL:SetText("Resistances:")
			resL:Dock(TOP)

			local resTypes = {"Bullet", "Impact", "Slash", "Thermal", "Electrical", "Chemical", "Psi", "Radiation"}
			
			for _, type in ipairs(resTypes) do
				local typeL = vgui.Create("DLabel", scroll)
				typeL:SetText(" " .. type .. ":")
				typeL:Dock(TOP)
				
				local typeC = vgui.Create("DTextEntry", scroll)
				typeC:SetText(res[type] or 0)
				typeC:Dock(TOP)
				
				resC[type] = typeC
			end
		end
		
		local finishB = vgui.Create("DButton", scroll)
		finishB:SetSize(60,20)
		finishB:SetText("Complete")
		finishB:Dock(TOP)
		finishB.DoClick = function()
			local customData = {}
			customData[1] = item.id
			customData[2] = {}
			customData[2].longdesc = longdescC:GetValue()
			customData[2].name = nameC:GetValue()
			customData[2].desc = descC:GetValue()
			
			
			--customData[2].color = colorC:GetColor()
			
			customData[2].model = modelC:GetValue()
			customData[2].weight = tonumber(weightC:GetValue())
			customData[2].price = tonumber(priceC:GetValue())
			
			/*if(materialC:GetValue() != "") then
				customData[2].material = materialC:GetValue()
			end*/
			
			if item.weapon or item.armor or item.gasmask or item.helmet then
				customData[2].dura = tonumber(duraC:GetValue())
			end

			if(item.weapon and wepC:GetChecked()) then
				--customData[2].quality = qualityC:GetValue()
				customData[2].wepDmg = math.Clamp(tonumber(dmgC:GetValue()), 0, 100000)
				customData[2].wepSpd = math.Clamp(tonumber(rpmC:GetValue()), 1, 1000000000)
				customData[2].wepAcc = math.Clamp(tonumber(accC:GetValue()), 0.0001, 100)
				customData[2].wepRec = math.Clamp(tonumber(recC:GetValue()), 0, 1000)
				customData[2].wepMag = math.Clamp(tonumber(magC:GetValue()), 0, 10000)
			end

			if(item.quantity or item.maxStack or item.ammoAmount) then
				customData[2].quantity = tonumber(quantityC:GetValue())
			end

			if (res) then
				customData[2].res = {}
				for type, panel in pairs(resC) do
					customData[2].res[type] = tonumber(panel:GetValue()) or 0
				end
			end

			net.Start("ixCustomF")
				net.WriteUInt(customData[1], 32)
				net.WriteTable(customData[2])
			net.SendToServer()
			
			frame:Remove()
		end
		
		local cancelB = vgui.Create("DButton", scroll)
		cancelB:SetSize(60,20)
		cancelB:SetText("Cancel")
		cancelB:Dock(TOP)
		cancelB.DoClick = function()
			frame:Remove()
		end		
	end)
	
	net.Receive("ixCustomA", function()
		local data = net.ReadTable()
		local item = data
	
		--current values of item
		local attribData = item.attrib

		local frame = vgui.Create("DFrame")
		frame:SetSize(450, 600)
		frame:Center()
		frame:SetTitle("Attributes")
		frame:MakePopup()
		frame:ShowCloseButton(true)

		local scroll = vgui.Create("DScrollPanel", frame)
		scroll:Dock(FILL)

		--attribute customization
		local attribs = {}
		for k, v in pairs(ix.attributes.list) do
			local attribL = vgui.Create("DLabel", scroll)
			attribL:SetText(v.name)
			attribL:Dock(TOP)
			
			local attribC = vgui.Create("DNumberWang", scroll)
			attribC.attrib = k
			attribC:SetDecimals(2)
			attribC:Dock(TOP)
			attribC:SetMax(200)
			attribC:SetMin(-200)
			attribC:SetValue(attribData[k] or 0)
			
			attribs[k] = attribC
		end
		
		local finishB = vgui.Create("DButton", scroll)
		finishB:SetSize(60,20)
		finishB:SetText("Complete")
		finishB:Dock(TOP)
		finishB.DoClick = function()
			local customData = {}
			customData[1] = item.id
			customData[2] = {}

			for k, v in pairs(attribs) do
				local value = v:GetValue()
				if(value != 0) then
					customData[2][k] = value
				end
			end

			net.Start("ixAttribF")
				net.WriteUInt(customData[1], 32)
				net.WriteTable(customData[2])
			net.SendToServer()
			
			frame:Remove()
		end
		
		local cancelB = vgui.Create("DButton", scroll)
		cancelB:SetSize(60,20)
		cancelB:SetText("Cancel")
		cancelB:Dock(TOP)
		cancelB.DoClick = function()
			frame:Remove()
		end		
	end)
	
	net.Receive("ixSwepUpdate", function()
		local data = net.ReadTable()
		local item = data
		local weapon = LocalPlayer():GetWeapon(item.class)
		
		if (weapon and IsValid(weapon)) then
			if (item.name) then
				weapon.PrintName = item.name
			end
			
			if (item.wepDmg) then
				weapon.Damage = tonumber(item.wepDmg)
			end
			
			if (item.wepSpd) then
				weapon.FireDelay = weapon.FireDelay * tonumber(item.wepSpd)
				print(weapon.FireDelay)
			end
			
			if (item.wepRec) then
				weapon.Recoil = weapon.Recoil * item.wepRec
			end
			
			--needs to happen in both client and server
			if (item.wepAcc) then
				weapon.MaxSpreadInc = weapon.MaxSpreadInc * item.wepAcc
				weapon.AimSpread = weapon.AimSpread * item.wepAcc
			end				
			
			--needs to happen in both client and server
			if(item.wepMag) then
				weapon.Primary.ClipSize = tonumber(item.wepMag)
			end
		end
	end)	
end