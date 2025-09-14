ITEM.name = "Helmet/gasmask name"
ITEM.description = "Helmet/gasmask desc."
ITEM.longdesc = "No Longer Description Available."
ITEM.model = "models/Gibs/HGIBS.mdl"
ITEM.category = "Headgear"	--No need to add this line to the items

ITEM.price = 1
ITEM.weight = 1
ITEM.width = 2	--No need to add this line to the items
ITEM.height = 2	--No need to add this line to the items

--[[
ITEM.flag = "?"	--Set the flag according to the faction or trade tier
--]]

ITEM.radProt = 0.00 --Add this line if the item is a Gasmask

ITEM.BRC = 0

ITEM.res = {
	["Bullet"] = 0.00,
	["Blast"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = 0.00,
	["Shock"] = 0.00,
	["Chemical"] = 0.00,
	["Psi"] = 0.00,
	["Radiation"] = 0.00,
}

ITEM.ballisticlevels = {"1", "1"}	--Replace "1" with: 0, l, ll-a, ll, lll-a, lll, lll+, lV or V
ITEM.ballisticareas = {"  Head:", "  Face:"}	--No need to add this line to the items

ITEM.img = Material("placeholders/headgear_nomask.png")

ITEM.canRepair = true	--No need to add this line to the items
ITEM.isGasmask = false	--If the item is a gasmask add this line and switch it to true
ITEM.isHelmet = false	--If the item is a helmet add this line and switch it to true

ITEM.equipIcon = Material("materials/vgui/ui/stalker/misc/equip.png")	--No need to add this line to the items

ITEM.functions.SetDurability = {
	name = "Set Durability",
	tip = "Dura",
	icon = "icon16/wrench.png",
	
	OnCanRun = function(item)
		local char = item.player:GetChar()
		if char:HasFlags("N") then
			return true
		else
			return false
		end
	end,
	
	OnRun = function(item)
		netstream.Start(item.player, "armordurabilityAdjust", item:GetData("durability",10000), item.id)
		return false
	end,
}

function ITEM:GetDescription()
	local quant = self:GetData("quantity", self.ammoAmount or self.quantity or 0)
	local quantdesc = ""
	local invdesc = ""

	if self.longdesc then
		invdesc = "\n\n"..(self.longdesc)
	end

	if self.quantdesc then
		quantdesc = "\n\n"..Format(self.quantdesc, quant)
	end

	if (self.entity) then
		return (self.description)
	else
        return (self.description..quantdesc..invdesc)
	end
end

function ITEM:GetName()
	local name = self.name
	
	local customData = self:GetData("custom", {})
	if(customData.name) then
		name = customData.name
	end
	
	return name
end

-- Inventory drawing
if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		if (item:GetData("equip")) then
			surface.SetDrawColor(110, 255, 110, 255)
		else
			surface.SetDrawColor(255, 110, 110, 255)
		end

		surface.SetMaterial(item.equipIcon)
		surface.DrawTexturedRect(w-23,h-23,19,19)
	end

	function ITEM:PopulateTooltip(tooltip)
		if !self.entity then
			local ballistictitle = tooltip:AddRowAfter("description", "ballistictitle")
			ballistictitle:SetText("\nBRC: " .. self.BRC or 0)
			ballistictitle:SizeToContents()

			local anomPtitle = tooltip:AddRowAfter("ballisticdesc", "anomPtitle")
			anomPtitle:SetText("\nANOMALOUS PROTECTION LEVELS:")
			anomPtitle:SizeToContents()

			-- Calculate resistances
			if self.res then
				local resistances = {
					["Bullet"] = 0,
					["Impact"] = 0,
					["Slash"] = 0,
					["Burn"] = 0,
					["Shock"] = 0,
					["Chemical"] = 0,
					["Radiation"] = 0,
					["Psi"] = 0,
				}

				-- Add base resistances
				for k, v in pairs(self.res) do
					if resistances[k] then
						resistances[k] = resistances[k] + v
					end
				end

				-- Add modifications from mods
				local mods = self:GetData("mod")
				if mods then
					for x, y in pairs(mods) do
						local moditem = ix.item.Get(y[1])
						local modres = moditem.res

						if modres then
							for k, v in pairs(modres) do
								if resistances[k] then
									resistances[k] = resistances[k] + v
								end
							end
						end
					end
				end

				-- Display the calculated resistances in the tooltip
				local str = ""
				for k, v in pairs(resistances) do
					if k == "Fall" then
						str = str .. "  Impact" .. ": " .. (v * 100) .. "%"
					elseif k == "Burn" then
						str = str .. "\n" .. "  Thermal" .. ": " .. (v * 100) .. "%"
					elseif k == "Shock" then
						str = str .. "\n" .. "  Electrical" .. ": " .. (v * 100) .. "%"
					else
						str = str .. "\n" .. "  " .. k .. ": " .. (v * 100) .. "%"
					end
				end

				local resistanceDesc = tooltip:AddRowAfter("anomPtitle", "resistances")
				resistanceDesc:SetText(str)
				resistanceDesc:SizeToContents()
			end

			if((self.miscslots or 0) > 0) then
				local attachmenttitle = tooltip:AddRow("attachments")
				attachmenttitle:SetText("\nAttachments: ")
				attachmenttitle:SizeToContents()

				local lastrow = attachmenttitle

				local attachmentdata = self:GetData("attachments", {})
				for i = 1, (self.miscslots or 0) do
					local attachmenttmp = tooltip:AddRowAfter("attachments", "attachment"..i)
					local attachmentstr = "  ⬜ None"
					attachmenttmp:SetTextColor(Color(120,120,120))
					if(attachmentdata[i]) then
						attachmentstr = "  ⬛ "
						if (!ix.armortables.attachments[attachmentdata[i]]) then continue end
						attachmentstr = attachmentstr..ix.armortables.attachments[attachmentdata[i]].name
						attachmenttmp:SetTextColor(Color(255,255,255))
					end

					attachmenttmp:SetText(attachmentstr)
					attachmenttmp:SetFont("ixSmallFont")
					attachmenttmp:SizeToContents()

					lastrow = attachmenttmp
				end
			end

			ix.util.PropertyDesc3(tooltip, ("Durability: " .. (math.floor(self:GetData("durability", 10000))/100) .. "%"), Color(255, 255, 255), Material("vgui/ui/stalker/misc/overdrive.png"), 980)
		end
		
		tooltip:SizeToContents()
	end
end

function ITEM:OnInstanced()
	self:SetData("durability", 10000)
end

ITEM:Hook("drop", function(item)
	local client = item.player
	if (item:GetData("equip")) then
		item:SetData("equip", nil)
		item.player:ReevaluateOverlay()
		item:RemovePart(item.player)
	end
end)

ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/stalker/unequip.png",
	OnRun = function(item)
		local client = item.player
		item:RemovePart(item.player)
		item.player:ReevaluateOverlay()

		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true and
			hook.Run("CanPlayerUnequipItem", client, item) != false and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}

ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip", 
	icon = "icon16/stalker/equip.png",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local items = character:GetInventory():GetItems()

		for _, v in pairs(items) do
			if (v.id != item.id) then
				local itemTable = ix.item.instances[v.id]
				if itemTable then
					if (v.isHelmet == true and item.isHelmet == true and itemTable:GetData("equip")) then
						item.player:Notify("You are already equipping a helmet!")
						return false
					end

					if (v.isGasmask == true and item.isGasmask == true and itemTable:GetData("equip")) then
						item.player:Notify("You are already equipping a gasmask!")
						return false
					end
				end
			end
		end

		item:SetData("equip", true)
		item.player:AddPart(item.uniqueID, item)
		item.player:ReevaluateOverlay()

		if (item.attribBoosts) then
			for k, v in pairs(item.attribBoosts) do
				character:AddBoost(item.uniqueID, k, v)
			end
		end

		item:OnEquipped()
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and
			hook.Run("CanPlayerEquipItem", client, item) != false and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}

ITEM.functions.RemoveUpgrade = {
	name = "Remove Upgrade",
	tip = "Remove",
	icon = "icon16/wrench.png",
    isMulti = true,
    multiOptions = function(item, client)
	
	local targets = {}

	for k, v in pairs(item:GetData("mod", {})) do
		local attTable = ix.item.list[v[1]]
		local niceName = attTable:GetName()
		table.insert(targets, {
			name = niceName,
			data = {k},
		})
    end
    return targets
end,
	OnCanRun = function(item)
		if (table.Count(item:GetData("mod", {})) <= 0) then
			return false
		end
	    
		if item:GetData("equip") then
			return false
		end
		
        local char = item.player:GetChar()
        if(char:HasFlags("6")) then
            return (!IsValid(item.entity))
        end
	end,
	OnRun = function(item, data)
		local client = item.player
		
	    if item:GetData("durability", 10000) < (ix.config.Get("Min Durability - Modify") * 100) then
            client:NotifyLocalized("Must Repair Headgear!")
            return false
        end
		
		if (data) then
			local char = client:GetChar()

			if (char) then
				local inv = char:GetInv()

				if (inv) then
					local mods = item:GetData("mod", {})
					local attData = mods[data[1]]

					if (attData) then
						inv:Add(attData[1])
						mods[data[1]] = nil
                        
                        curPrice = item:GetData("RealPrice")
                	    if !curPrice then
                		    curPrice = item.price
                		end
                		
						local targetitem = ix.item.list[attData[1]]
						
                        item:SetData("RealPrice", (curPrice - targetitem.price))
                        
						if (table.Count(mods) == 0) then
							item:SetData("mod", nil)
						else
							item:SetData("mod", mods)
						end
						
						local itemweight = item:GetData("weight",0)
                        local targetweight = targetitem.weight
						local weightreduc = 0
						
						if targetitem.weightreduc then
							weightreduc = targetitem.weightreduc
						end
						
                        local totweight = itemweight - targetweight + weightreduc
                        item:SetData("weight", totweight)
						
						client:EmitSound("cw/holster4.wav")
					else
						client:NotifyLocalized("notAttachment")
					end
				end
			end
		else
			client:NotifyLocalized("detTarget")
		end
	return false
end,
}

ITEM.functions.Custom = {
	name = "Customize",
	tip = "Customize this item",
	icon = "icon16/wrench.png",
	OnRun = function(item)		
		ix.plugin.list["customization"]:startCustom(item.player, item)
		
		return false
	end,
	
	OnCanRun = function(item)
		local client = item.player
		return client:GetCharacter():HasFlags("N") and !IsValid(item.entity)
	end
}

ITEM.functions.Clone = {
	name = "Clone",
	tip = "Clone this item",
	icon = "icon16/wrench.png",
	OnRun = function(item)
		local client = item.player	
	
		client:requestQuery("Are you sure you want to clone this item?", "Clone", function(text)
			if text then
				local inventory = client:GetCharacter():GetInventory()
				
				if(!inventory:Add(item.uniqueID, 1, item.data)) then
					client:Notify("Inventory is full")
				end
			end
		end)
		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		return client:GetCharacter():HasFlags("N") and !IsValid(item.entity)
	end
}

function ITEM:RemovePart(client)
	local char = client:GetCharacter()

    self:SetData("equip", false)
    client:RemovePart(self.uniqueID)

	if (self.attribBoosts) then
		for k, _ in pairs(self.attribBoosts) do
			char:RemoveBoost(self.uniqueID, k)
		end
	end

	self:OnUnequipped()
end

function ITEM:CanTransfer(oldInventory, newInventory)
	if (newInventory and self:GetData("equip")) then
		return false
	end

	return true
end

function ITEM:OnRemoved()
	local inventory = ix.item.inventories[self.invID]
	local owner = inventory.GetOwner and inventory:GetOwner()

	if (IsValid(owner) and owner:IsPlayer()) then
		if (self:GetData("equip")) then
			self:RemovePart(owner)
		end
	end
end

function ITEM:OnEquipped()
	if self.isGasmask == true then
		self.player:EmitSound("stalkersound/gasmask_on.ogg")
		return
	end
	
	if self.isHelmet == true and self.isGasmask == false then
		self.player:EmitSound("metro/gasmaskon.wav")
	end
end

function ITEM:OnUnequipped()
	if self.isGasmask == true then
		self.player:EmitSound("stalkersound/gasmask_off.ogg")
		return
	end

	if self.isHelmet == true and self.isGasmask == false then
		self.player:EmitSound("metro/gasmaskoff.wav")
	end
end

ITEM.functions.Sell = {
	name = "Sell",
	icon = "icon16/stalker/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item:GetData("RealPrice") or item.price
		sellprice = math.Round((sellprice*(item:GetData("durability",0)/10000))*0.75)
		if item:GetData("durability",0) < (ix.config.Get("Min Durability - Sell") * 100) then
			client:Notify("Must be Repaired")
			return false
		end
		client:Notify( "Sold for "..(sellprice).." rubles." )
		client:GetCharacter():GiveMoney(sellprice)
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item.player:GetCharacter():HasFlags("1") and !item:GetData("equip")
	end
}

ITEM.functions.Value = {
	name = "Value",
	icon = "icon16/help.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item:GetData("RealPrice") or item.price
		sellprice = math.Round((sellprice*(item:GetData("durability",0)/10000))*0.75)
		if item:GetData("durability",0) < (ix.config.Get("Min Durability - Sell") * 100) then
			client:Notify("Must be Repaired")
			return false
		end
		client:Notify( "Item is sellable for "..(sellprice).." rubles." )
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item.player:GetCharacter():HasFlags("1") and !item:GetData("equip")
	end
}