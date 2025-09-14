ITEM.name = "Suit name"
ITEM.model = "models/props_c17/BriefCase001a.mdl"
ITEM.description = "Short description."
ITEM.longdesc = "Long description."
ITEM.category = "Armor"	--No need to add this line to the items
ITEM.outfitCategory = "model"	--No need to add this line to the items

ITEM.price = 1
ITEM.weight = 1
ITEM.width = 2	--No need to add this line to the items
ITEM.height = 3	--No need to add this line to the items

--[[
ITEM.flag = "?"	--Set the flag according to the faction or trade tier
--]]

--[[
ITEM.radProt = 0.00	--Only add this line if the suit includes a gasmask
--]]

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

ITEM.ballisticlevels = {"1", "1", "1", "1", "1"}	--Replace "1" with: 0, l, ll-a, ll, lll-a, lll, lll+, lV or V
ITEM.ballisticareas = {"  Head:", "  Face:", "  Arms:", "  Torso:", "  Legs:"}	--No need to add this line to the items
ITEM.artifactcontainers = {"0"}	--Number of containers that come with the suit

ITEM.img = Material("placeholders/armor_nosuit.png")

ITEM.isGasmask = false	--Add this line to the item if the suit comes with a gasmask and switch to true
ITEM.isHelmet = false	--Add this line to the item if the suit comes with a helmet and switch to true
ITEM.isArmor = true		--No need to add this line to the items
ITEM.isBodyArmor = true	--No need to add this line to the items
ITEM.playermodel = nil	--No need to add this line to the items
ITEM.canRepair = true	--No need to add this line to the items

--[[
--Only use these lines if the model has to show in any specific skin and/or bodygroups

ITEM.newSkin = 0

ITEM.bodyGroups = {
	["bg"] = 0,
}
--]]

--[[
--Add these lines to make the player's model change when the item is equipped
ITEM.OnGetReplacement = function(self, player)
    local player = self.player
	if player:IsFemale() then
        return "female_playermodel"		--Female model path goes here
    end;
    return "male_playermodel"			--Male model path goes here
end

--If there is no female model for the same item then just use this line
ITEM.replacements = "playermodel_path"
--]]

ITEM.equipIcon = Material("materials/vgui/ui/stalker/misc/equip.png")	--No need to add this line to the items
ITEM.skincustom = {}

ITEM.miscslots = 1

function ITEM:GetRepairCost()
	return self.price * 0.001 -- 0.1% of price per %
end

ix.config.Add("Armor Durability", true, "Enable durability for armor items.", nil, {category = "Durability"})

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

			local anomPtitle = tooltip:AddRowAfter("ballistictitle", "anomPtitle")
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
					str = str .. "\n" .. "  " .. k .. ": " .. (v * 100) .. "%"
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

			local artifactContainersCount = tonumber(self.artifactcontainers[1]) or 0
			ix.util.PropertyDesc3(tooltip, ("Artifact Containers: " .. artifactContainersCount), Color(255, 255, 255), Material("vgui/ui/stalker/armorupgrades/explosion.png"), 981)

	        if (self.PopulateTooltipIndividual) then
		      self:PopulateTooltipIndividual(tooltip)
		    end
		end

		tooltip:SizeToContents()
	end
end

function ITEM:RemoveOutfit(client)
	local character = client:GetCharacter()
	local bgroups = {}

	self:SetData("equip", false)
	if (character:GetData("oldModel" .. self.outfitCategory)) then
		character:SetModel(character:GetData("oldModel" .. self.outfitCategory))
		character:SetData("oldModel" .. self.outfitCategory, nil)
	end

	if (self.newSkin) then
		if (character:GetData("oldSkin" .. self.outfitCategory)) then
			client:SetSkin(character:GetData("oldSkin" .. self.outfitCategory))
			character:SetData("oldSkin" .. self.outfitCategory, nil)
		else
			client:SetSkin(0)
		end
	end

	for k, _ in pairs(self.bodyGroups or {}) do
		local index = client:FindBodygroupByName(k)

		if (index > -1) then
			client:SetBodygroup(index, 0)

			local groups = character:GetData("groups" .. self.outfitCategory, {})

			if (groups[index]) then
				groups[index] = nil
				character:SetData("groups" .. self.outfitCategory, groups)
			end
		end
	end

	for k, v in pairs( self:GetData("origgroups")) do
		self.player:SetBodygroup( k, v )
		bgroups[k] = v
	end

	self.player:GetCharacter():SetData("groups", bgroups)

	if (self.attribBoosts) then
		for k, _ in pairs(self.attribBoosts) do
			character:RemoveBoost(self.uniqueID, k)
		end
	end

	for k, _ in pairs(self:GetData("outfitAttachments", {})) do
		self:RemoveAttachment(k, client)
	end
	character:SetData("ArtiSlots",0)
	self:OnUnequipped()

    -- Unequip all artifacts when armor is removed
    local inventory = character:GetInventory():GetItems()  -- Get all items in the character's inventory
    for _, item in pairs(inventory) do
        if item.isArtefact and item:GetData("equip") then
            item:SetData("equip", false)  -- Unequip the artifact
            item:OnLoadout()  -- Call any additional unequip logic for the artifact

            -- Reset all buffs associated with the artifact
            if item.buff == "heal" then
                character:SetData("ArtiHealAmt", 0)
            end
            
            if item.buff == "woundheal" then
                character:SetData("WoundHeal", 0)
            end
            
            if item.buff == "antirad" then
                character:SetData("AntiRads", 0)
            end
            
            if item.buff == "endbuff" then
                client:RemoveBuff("buff_staminarestore")
            end
            
            if item.debuff == "rads" then
                character:SetData("Rads", 0)
            end
            
            if item.buff == "weight" then
                character:SetData("WeightBuff", 0)
            end
        end
    end
end

function ITEM:OnInstanced()
	self:SetData("durability", 10000)
end

ITEM.functions.zCustomizeSkin = {
	name = "Customize Skin",
	tip = "useTip",
	icon = "icon16/stalker/customize.png",
	isMulti = true,
	multiOptions = function(item, client)
		local targets = {}

		for k, v in pairs(item.skincustom) do
			table.insert(targets, {
				name = v.name,
				data = {v.skingroup, v.modelOverride or nil},
			})
		end

		return targets
	end,
	OnCanRun = function(item)				
		return (!IsValid(item.entity) and #item.skincustom > 0 and item:GetData("equip") == true and item:GetOwner():GetCharacter():GetInventory():HasItem("paint") and item:GetOwner():GetCharacter():GetFlags("T"))
	end,
	OnRun = function(item, data)
		if !data[1] then
			return false
		end

		item.player:SetSkin(data[1])
		item:SetData("setSkin", data[1])
		if data[2] then
			item.player:GetCharacter():SetModel(data[2])
			item:SetData("setSkinOverrideModel", data[2])
		else
			item.player:GetCharacter():SetModel(item.newModel)
			item:SetData("setSkinOverrideModel", nil)
		end

		return false
	end,
}

ITEM:Hook("drop", function(item)
	local client = item.player
	if (item:GetData("equip")) then
		item:SetData("equip", nil)
		item.player:ReevaluateOverlay()
		item:RemoveOutfit(item:GetOwner())
		if (item.armorclass != "helmet") then
			item.player:SetModel(item.player:GetChar():GetModel())
		end
	end
end)

ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/stalker/unequip.png",
	OnRun = function(item)
		local client = item.player
		item:RemoveOutfit(item.player)
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
					if (v.outfitCategory == item.outfitCategory and itemTable:GetData("equip")) then
						item.player:Notify("You're already equipping a suit!")
						return false
					end

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

		local origbgroups = {}
		for k, v in ipairs(client:GetBodyGroups()) do
			origbgroups[v.id] = client:GetBodygroup(v.id)
		end
		item:SetData("origgroups", origbgroups)

		item.player:ReevaluateOverlay()

		if (type(item.OnGetReplacement) == "function") then
			character:SetData("oldModel" .. item.outfitCategory, character:GetData("oldModel" .. item.outfitCategory, item.player:GetModel()))
			character:SetModel(item:OnGetReplacement())
		elseif (item.replacement or item.replacements) then
			character:SetData("oldModel" .. item.outfitCategory, character:GetData("oldModel" .. item.outfitCategory, item.player:GetModel()))

			if (type(item.replacements) == "table") then
				if (#item.replacements == 2 and type(item.replacements[1]) == "string") then
					character:SetModel(item.player:GetModel():gsub(item.replacements[1], item.replacements[2]))
				else
					for _, v in ipairs(item.replacements) do
						character:SetModel(item.player:GetModel():gsub(v[1], v[2]))
					end
				end
			else
				character:SetModel(item.replacement or item.replacements)
			end
		end

		if (item.newSkin) then
			character:SetData("oldSkin" .. item.outfitCategory, item.player:GetSkin())
			item.player:SetSkin(item.newSkin)
		end

		if item:GetData("setSkin", nil) != nil then
			client:SetSkin( item:GetData("setSkin", item.newSkin) )
		end

		if (item.bodyGroups) then
			local groups = {}

			for k, value in pairs(item.bodyGroups) do
				local index = item.player:FindBodygroupByName(k)

				if (index > -1) then
					groups[index] = value
				end
			end

			local newGroups = character:GetData("groups", {})

			for index, value in pairs(groups) do
				newGroups[index] = value
				item.player:SetBodygroup(index, value)
			end

			if (table.Count(newGroups) > 0) then
				character:SetData("groups", newGroups)
			end
		end

		local articont = tonumber(item.artifactcontainers[1]) or 0
		local mods = item:GetData("mod")
		
		if mods then
			for k,v in pairs(mods) do
				local upgitem = ix.item.Get(v[1])
				if upgitem and upgitem.articontainer then
					articont = articont + upgitem.articontainer
				end
			end
		end
		
		character:SetData("ArtiSlots",articont)
		item:OnEquipped()

		if (item.attribBoosts) then
			for k, v in pairs(item.attribBoosts) do
				character:AddBoost(item.uniqueID, k, v)
			end
		end
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and
			hook.Run("CanPlayerEquipItem", client, item) != false and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}

function ITEM:ModelOff(client)
	local character = client:GetCharacter()
	local bgroups = {}
	
	if (character:GetData("oldModel" .. self.outfitCategory)) then
		character:SetModel(character:GetData("oldModel" .. self.outfitCategory))
		character:SetData("oldModel" .. self.outfitCategory, nil)
	end

	if (self.newSkin) then
		if (character:GetData("oldSkin" .. self.outfitCategory)) then
			client:SetSkin(character:GetData("oldSkin" .. self.outfitCategory))
			character:SetData("oldSkin" .. self.outfitCategory, nil)
		else
			client:SetSkin(0)
		end
	end

	for k, _ in pairs(self.bodyGroups or {}) do
		local index = client:FindBodygroupByName(k)

		if (index > -1) then
			client:SetBodygroup(index, 0)

			local groups = character:GetData("groups" .. self.outfitCategory, {})

			if (groups[index]) then
				groups[index] = nil
				character:SetData("groups" .. self.outfitCategory, groups)
			end
		end
	end

	for k, v in pairs( self:GetData("origgroups")) do
		self.player:SetBodygroup( k, v )
		bgroups[k] = v
	end

	self.player:GetCharacter():SetData("groups", bgroups)

	if (self.attribBoosts) then
		for k, _ in pairs(self.attribBoosts) do
			character:RemoveBoost(self.uniqueID, k)
		end
	end

	for k, _ in pairs(self:GetData("outfitAttachments", {})) do
		self:RemoveAttachment(k, client)
	end
end

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
            client:NotifyLocalized("Must Repair Armor!")
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

-- makes another outfit depend on this outfit in terms of requiring this item to be equipped in order to equip the attachment
-- also unequips the attachment if this item is dropped
function ITEM:AddAttachment(id)
	local attachments = self:GetData("outfitAttachments", {})
	attachments[id] = true

	self:SetData("outfitAttachments", attachments)
end

function ITEM:RemoveAttachment(id, client)
	local item = ix.item.instances[id]
	local attachments = self:GetData("outfitAttachments", {})

	if (item and attachments[id]) then
		item:OnDetached(client)
	end

	attachments[id] = nil
	self:SetData("outfitAttachments", attachments)
end

local function skinset(item, data)
	if data then
		item.player:SetSkin(data[1])
		item:SetData("setSkin", data[1])
		if data[2] then
			--item.player:GetCharacter():SetModel(data[2])
			item:SetData("setSkinOverrideModel", data[2])
		else
			--item.player:GetCharacter():SetModel(item.replacements)
			item:SetData("setSkinOverrideModel", nil)
		end
	end
	return false
end

ITEM.functions.ModelOff = { 
	name = "Model Off",
	tip = "useTip",
	icon = "icon16/stalker/customize.png",
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetData("equip")
	end,
	
	OnRun = function(item)
		item:ModelOff(item.player)
		return false
	end,
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

function ITEM:OnLoadout()
	if (self:GetData("equip")) then
		local client = self.player
		local character = client:GetCharacter()
		if self.newSkin then
			client:SetSkin( self.newSkin )
		end
		
		local articont = tonumber(self.artifactcontainers[1]) or 0
		local mods = self:GetData("mod")
		
		if mods then
			for k,v in pairs(mods) do
				local upgitem = ix.item.Get(v[1])
				if upgitem and upgitem.articontainer then
					articont = articont + upgitem.articontainer
				end
			end
		end
		
		character:SetData("ArtiSlots",articont)
		if self:GetData("setSkin", nil) != nil then
			client:SetSkin( self:GetData("setSkin", self.newSkin) )
		end

		if self:GetData("setBG", nil) != nil then
			local data = self:GetData("setBG", nil)
			local bgroup = data[1]
			local bgroupsub = data[2]

			for i=1,#bgroup do
				client:SetBodygroup( bgroup[i], bgroupsub[i] )
			end
		end
	end
end

function ITEM:CanTransfer(oldInventory, newInventory)
	if (newInventory and self:GetData("equip")) then
		return false
	end

	return true
end

function ITEM:OnRemoved()
	local client = self:GetOwner()
	if (self:GetData("equip")) then
		client:ReevaluateOverlay()
		self:RemoveOutfit(self:GetOwner())
	end
end

function ITEM:OnEquipped()
	self.player:EmitSound("player/shove_02.wav")

	if self.isGasmask == true then
		self.player:EmitSound("stalkersound/gasmask_on.ogg")
		return
	end
end

function ITEM:OnUnequipped()
	self.player:EmitSound("player/shove_03.wav")

	if self.isGasmask == true then
		self.player:EmitSound("stalkersound/gasmask_off.ogg")
		return
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
			client:Notify("Must be Repaired!")
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
			client:Notify("Must be Repaired!")
			return false
		end
		client:Notify( "Item is sellable for "..(sellprice).." rubles." )
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item.player:GetCharacter():HasFlags("1") and !item:GetData("equip")
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
					client:Notify("Inventory is full!")
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

function ITEM:GetWeight()
  local retval = self.weight

  local upgrades = self:GetData("upgrades", {})
	
  for k,v in pairs(upgrades) do
  	if (!ix.armortables.upgrades[v]) then continue end
    if ix.armortables.upgrades[v].weight then
		  retval = retval + ix.armortables.upgrades[v].weight
    end
  end
	
	--For artifacts, kevlarplates, mutant hides, etc..
	local attachments = self:GetData("attachments", {})
	
	for k,v in pairs(attachments) do
		if (!ix.armortables.attachments[v]) then continue end
		if ix.armortables.attachments[v].weight then
			retval = retval + ix.armortables.attachments[v].weight
		end
	end

  return retval
end