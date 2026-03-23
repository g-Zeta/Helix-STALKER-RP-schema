ITEM.name = "Medicine"
ITEM.description = "Helps your body survive in the zone - in one way or another."
ITEM.longdesc = nil
ITEM.model = "models/Items/HealthKit.mdl"

ITEM.width = 1
ITEM.height = 1

ITEM.weight = nil		-- weight of the full item in KG

ITEM.price = nil
ITEM.flag = nil			--e.g. "1"

ITEM.maxUses = 1

ITEM.duration = 0		-- effect duration in seconds/ticks
ITEM.restore = 0		-- health restore amount per tick
ITEM.radrem = 0			-- radiation removal amount per tick
ITEM.stamBuff = 0		-- stamina restore amount per tick
ITEM.chemProt = 0		-- chemical protection total amount
ITEM.radProt = 0		-- radiation protection total amount
ITEM.weightBuff = 0		-- weight buff total amount

ITEM.stopsBleed = false -- stops bleeding if true
ITEM.psyprotect = false	-- fully protects against psy if true

ITEM.useName = "Heal"
ITEM.useIcon = "stalkerCoP/ui/icons/misc/heal.png"
ITEM.useText = {"opens a ", " and uses it"}

ITEM.sound = "items/battery_pickup.wav"

ITEM.img = nil 			-- e.g. Material("stalker/ui/medicine/medkit.png")

----- Only copy what is above this line -----

ITEM.category = "Medical"
ITEM.isMedical = true


ITEM:Hook("use", function(item)
	item.player:EmitSound(item.sound or "items/battery_pickup.wav")
end)

ITEM:Hook("usetarget", function(item)
	item.player:EmitSound(item.sound or "items/battery_pickup.wav")
end)

function ITEM:GetDescription()
	local str = self.description
	if self.longdesc and !IsValid(self.entity) then
		str = str.."\n\n"..(self.longdesc or "")
	end

	local customData = self:GetData("custom", {})
	if(customData.desc) then
		str = customData.desc
	end
	
	if (customData.longdesc) and !IsValid(self.entity) then
		str = str.."\n\n"..(customData.longdesc or "")
	end

	if (self.maxUses or 1) > 1 then
		local uses = self:GetData("uses", self.maxUses or 1)
		if (uses == 1) then
			str = str .. "\n\nThis item has only 1 use left."
		else
			str = str .. "\n\nThis item has " .. uses .. " uses left."
		end
	end

	if self.stopsBleed then
		str = str .. "\n\nIt can stop bleeding."
	end

    return (str)
end

function ITEM:GetName()
	local name = self.name
	
	local customData = self:GetData("custom", {})
	if(customData.name) then
		name = customData.name
	end
	
	return name
end

function ITEM:OnRegistered()
	if (self.functions.use) then
		self.functions.use.name = self.useName or "Heal"
		if (self.useIcon) then
			self.functions.use.icon = self.useIcon
		end
	end
end

if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		draw.SimpleText(item:GetData("uses", item.maxUses or 1) .. "/" .. item.maxUses, "DermaDefault", 3, h - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, color_black)
	end

	function ITEM:PopulateTooltip(tooltip)
		local healAmount = (self.duration or 0) * (self.restore or 0)

		if (healAmount > 0) then
			ix.util.PropertyDesc4(tooltip, "Healing regeneration: ", Color(255, 255, 255), "+" .. healAmount, Color(0, 135, 0), "materials/stalkerCoP/ui/icons/armorupgrades/hpregen.png")
		end

		local radAmount = (self.duration or 0) * (self.radrem or 0)

		if (radAmount > 0) then
			ix.util.PropertyDesc4(tooltip, "Radiation: ", Color(255, 255, 255), "-" .. radAmount, Color(0, 135, 0), "materials/stalkerCoP/ui/icons/armorupgrades/rad.png")
		end

		if self.chemProt > 0 then
			ix.util.PropertyDesc4(tooltip, "Chemical: ", Color(255, 255, 255), "+" .. self.chemProt, Color(0, 135, 0), "materials/stalkerCoP/ui/icons/armorupgrades/chemprot.png")
		end

		if self.psyprotect == true then
			ix.util.PropertyDesc4(tooltip, "Psi: ", Color(255, 255, 255), "+100", Color(0, 135, 0), "materials/stalkerCoP/ui/icons/armorupgrades/psiprot.png")
		end

		if self.radProt > 0 then
			ix.util.PropertyDesc4(tooltip, "Radiation: ", Color(255, 255, 255), "+" .. self.radProt, Color(0, 135, 0), "materials/stalkerCoP/ui/icons/armorupgrades/radprot.png")
		end

		if self.duration > 0 then
			ix.util.PropertyDesc4(tooltip, "Duration: ", Color(255, 255, 255), self.duration .. " sec.", Color(200, 200, 0), "materials/stalkerCoP/ui/icons/misc/time.png")
		end

		tooltip:SizeToContents()
	end
end

function ITEM:GetWeight()
	local uses = self:GetData("uses", self.maxUses or 1)
	local maxUses = self.maxUses or 1
	return (self.weight or 0) * (uses / maxUses)
end

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
		local char = client:GetCharacter()
		return char and char:HasFlags("N") and !IsValid(item.entity)
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
		local char = client:GetCharacter()
		return char and char:HasFlags("N") and !IsValid(item.entity)
	end
}

ITEM.functions.split = {
	name = "Split",
	tip = "useTip",
	icon = "stalkerCoP/ui/icons/misc/split.png",
	isMulti = true,
	multiOptions = function(item, client)
		local targets = {}
		local uses = item:GetData("uses", item.maxUses or 1)

		-- Generate split options for every possible amount (1 to uses-1)
		for i = 1, uses - 1 do
			table.insert(targets, {
				name = i,
				data = {i},
			})
		end
		return targets
	end,
	OnCanRun = function(item)
		local uses = item:GetData("uses", item.maxUses or 1)
		if (uses <= 1) then
			return false
		end

		return (!IsValid(item.entity) and item.invID == item.player:GetCharacter():GetInventory():GetID())
	end,
	OnRun = function(item, data)
		if (data[1]) then
			local uses = item:GetData("uses", item.maxUses or 1)
			local client = item.player
			local splitAmount = data[1]

			if (splitAmount >= uses or splitAmount <= 0) then
				return false
			end
			
			-- Update the current item's uses and weight
			item:SetData("uses", uses - splitAmount)
			if (ix.weight) then
				ix.weight.Update(client:GetChar())
			end

			-- Create the new item with the split amount
			local x, y, bagInvID = client:GetCharacter():GetInventory():Add(item.uniqueID, 1, {["uses"] = splitAmount})

			if (!x) then
				-- Revert if inventory is full
				item:SetData("uses", uses)
				if (ix.weight) then
					ix.weight.Update(client:GetChar())
				end
				client:NotifyLocalized("noSpace")
				return false
			end

			item.player:EmitSound("stalker/inventory/inv_properties.mp3", 110)
		end
		return false
	end,
}

ITEM.functions.combine = {
	OnCanRun = function(item, data)
		if !data then
			return false
		end

		if (data[1] == item.id) then
			return false
		end

		local targetItem = ix.item.instances[data[1]]

		if (targetItem and targetItem.uniqueID == item.uniqueID and (item.maxUses or 1) > 1) then
			return true
		else
			return false
		end
	end,
	OnRun = function(item, data)
		local sourceItem = ix.item.instances[data[1]]
		local maxUses = item.maxUses or 1
		local currentUses = item:GetData("uses", maxUses)
		local sourceUses = sourceItem:GetData("uses", maxUses)
		
		item.player:EmitSound("stalker/inventory/inv_properties.mp3", 100)
		
		local needed = maxUses - currentUses
		
		if (needed >= sourceUses) then
			item:SetData("uses", currentUses + sourceUses)
			sourceItem:Remove()
		else
			item:SetData("uses", maxUses)
			sourceItem:SetData("uses", sourceUses - needed)
		end
		
		if (ix.weight) then
			ix.weight.Update(item.player:GetChar())
		end

		return false
	end,
}

function ITEM:stopBleed(client)
	if(timer.Exists(client:Name().."res_bleed")) then
		timer.Remove(client:Name().."res_bleed")
		client:Notify("Your bleeding has stopped.")
	end
end

ITEM.functions.use = {
	name = ITEM.useName,
	icon = "stalkerCoP/ui/icons/misc/heal.png",
	OnRun = function(item)
		if (item.stamBuff > 0) then
			item.player:AddBuff("buff_staminarestore", item.duration, { amount = item.stamBuff })
		end
		
		if (item.restore > 0) then
			item.player:AddBuff("buff_slowheal", item.duration, { amount = item.restore })
		end

		if (item.radrem > 0) then
			item.player:AddBuff("buff_radiationremoval", item.duration, { amount = item.radrem })
		end

		if (item.psyprotect) then
			item.player:AddBuff("buff_psyprotect", item.duration)
		end

		if (item.radProt > 0) then
			item.player:AddBuff("buff_radprotect", item.duration, { amount = item.radProt })
		end
		
		if (item.chemProt > 0) then
			item.player:AddBuff("buff_chemprotect", item.duration, { amount = item.chemProt })
		end

		ix.chat.Send(item.player, "iteminternal", item.useText[1]..item.name..item.useText[2], false)
		
		local client = item.player
		local character = client:GetChar()
		if (item.stopsBleed) then
			item:stopBleed(item.player)
			character:SetData("Bleeding", 0)
		end
		
		local uses = item:GetData("uses", item.maxUses or 1)
		uses = uses - 1
		item:SetData("uses", uses)
		
		-- Always update the character's weight after the number of uses has changed.
		if (ix.weight) then ix.weight.Update(character) end

		if (uses > 0) then
			return false
		end

		return true
	end,
	OnCanRun = function(item)
		return (!IsValid(item.entity))
	end
}

ITEM.functions.Sell = {
	name = "Sell",
	icon = "stalkerCoP/ui/icons/misc/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local uses = item:GetData("uses", item.maxUses or 1)
		local maxUses = item.maxUses or 1
		local sellprice = ((item.price or 0) * (uses / maxUses)) * 0.75

		sellprice = math.Round(sellprice)
		client:Notify( "Sold for "..(sellprice).." rubles." )
		client:GetCharacter():GiveMoney(sellprice)
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1") and !item:GetData("equip",false)
	end
}

ITEM.functions.Value = {
	name = "Value",
	icon = "icon16/help.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local uses = item:GetData("uses", item.maxUses or 1)
		local maxUses = item.maxUses or 1
		local sellprice = ((item.price or 0) * (uses / maxUses)) * 0.75

		sellprice = math.Round(sellprice)
		client:Notify( "Item is sellable for "..(sellprice).." rubles." )
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1")
	end
}

--[[
ITEM.functions.usetarget = {
	name = "Heal Target",
	icon = "icon16/stalker/heal.png",
	onRun = function(item)
		local data = {}
			data.start = item.player:GetShootPos()
			data.endpos = data.start + item.player:GetAimVector()*96
			data.filter = item.player
		local target = util.TraceLine(data).Entity
		local quantity = item:getData("quantity", item.quantity)
		if (IsValid(target) and target:IsPlayer()) then
			target:AddBuff("buff_slowheal", 15, { amount = item.restore*(1+(item.player:getChar():getAttrib("medical", 0)/50))/10 })
			nut.chat.send(item.player, "iteminternal", "opens a "..item.name.." and uses it on "..target:Name()..".", false)
			
			quantity = quantity - 1

			if (quantity >= 1) then
				item:setData("quantity", quantity)
				return false
			end
			
			
		else
			item.player:notify("Not looking at a player!")
			return false
		end

		return true
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity))
	end
}
--]]