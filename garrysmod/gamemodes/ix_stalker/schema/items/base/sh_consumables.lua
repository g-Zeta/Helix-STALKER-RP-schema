ITEM.name = "Consumable"
ITEM.description = "Something to eat or drink."
ITEM.longdesc = "Long description here."
ITEM.model = "models/props_junk/garbage_metalcan001a.mdl"

ITEM.quantity = 1
ITEM.width = 1
ITEM.height = 1
ITEM.quantMax = 10
ITEM.weight = 1.0

ITEM.price = 100
ITEM.flag = "1"

ITEM.isFood = false
ITEM.isDrink = false
ITEM.cookable = false

ITEM.hunger = 0
ITEM.thirst = 0

ITEM.duration = 0		-- effect duration in seconds/ticks
ITEM.radrem = 0			-- radiation removal amount per tick
ITEM.stamBuff = 0		-- stamina restore amount per tick

ITEM.category = "Consumables"

if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		local quantity = item:GetData("quantity", 1)

		if (quantity > 1) then
			draw.SimpleTextOutlined("x" .. quantity, "DermaDefault", w - 2, h - 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black)
		end
	end

	function ITEM:PopulateTooltip(tooltip)
		if (self.hunger and self.hunger != 0) then
			local color = self.hunger > 0 and Color(0, 135, 0) or Color(200, 0, 0)
			local prefix = self.hunger > 0 and "+" or ""
			ix.util.PropertyDesc4(tooltip, "Hunger: ", Color(255, 255, 255), prefix .. self.hunger, color, "materials/stalkerCoP/ui/icons/armorupgrades/hunger.png")
		end

		if (self.thirst and self.thirst != 0) then
			local color = self.thirst > 0 and Color(0, 135, 0) or Color(200, 0, 0)
			local prefix = self.thirst > 0 and "+" or ""
			ix.util.PropertyDesc4(tooltip, "Thirst: ", Color(255, 255, 255), prefix .. self.thirst, color, "materials/stalkerCoP/ui/icons/armorupgrades/bleeding.png")
		end

		local radAmount = (self.duration or 0) * (self.radrem or 0)

		if (radAmount > 0) then
			ix.util.PropertyDesc4(tooltip, "Radiation: ", Color(255, 255, 255), "-" .. radAmount, Color(0, 135, 0), "materials/stalkerCoP/ui/icons/armorupgrades/rad.png")
		end

		local staminaAmount = (self.stamBuff or 0)

		if (staminaAmount > 0) then
			ix.util.PropertyDesc4(tooltip, "Stamina: ", Color(255, 255, 255), "+" .. staminaAmount, Color(0, 135, 0), "materials/stalkerCoP/ui/icons/armorupgrades/stamina.png")
		end

		if self.duration > 0 then
			ix.util.PropertyDesc4(tooltip, "Duration: ", Color(255, 255, 255), self.duration .. " sec.", Color(200, 200, 0), "materials/stalkerCoP/ui/icons/misc/time.png")
		end

		tooltip:SizeToContents()
	end
end

function ITEM:GetWeight()
	return (self.weight or 0) * self:GetData("quantity", 1)
end

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
		str = str.."\n\n"..customData.longdesc or ""
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

ITEM.functions.use = {
	name = "Use",
	tip = "Use this item",
	icon = "icon16/cup.png",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local quantity = item:GetData("quantity", 1)

		if (item.hunger and item.hunger != 0 and client.SetHunger and client.GetHunger) then
			local newHunger = math.Clamp(client:GetHunger() + item.hunger, 0, 100)
			client:SetHunger(newHunger)
			if (client.UpdateHungerState) then client:UpdateHungerState(client) end
		end

		if (item.thirst and item.thirst != 0 and client.SetThirst and client.GetThirst) then
			local newThirst = math.Clamp(client:GetThirst() + item.thirst, 0, 100)
			client:SetThirst(newThirst)
			if (client.UpdateThirstState) then client:UpdateThirstState(client) end
		end

		if (item.radrem > 0) then
			client:AddBuff("buff_radiationremoval", item.duration, { amount = item.radrem })
		end

		if (item.stamBuff > 0) then
			client:AddBuff("buff_staminarestore", item.duration, { amount = item.stamBuff })
		end

		quantity = quantity - 1
		item:SetData("quantity", quantity)

		if (ix.weight) then	ix.weight.Update(character)	end
		
		if (quantity > 0) then
			return false
		end

		return true
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity)
	end
}

function ITEM:OnRegistered()
	if (self.isFood) then
		self.functions.use.name = "Eat"
		self.functions.use.icon = "stalkerCoP/ui/icons/misc/eat.png"
	elseif (self.isDrink) then
		self.functions.use.name = "Drink"
		self.functions.use.icon = "stalkerCoP/ui/icons/misc/drink.png"
	end
end

ITEM.functions.Sell = {
	name = "Sell",
	icon = "stalkerCoP/ui/icons/misc/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = math.Round(item.price)

		client:Notify( "Sold for ".. ix.currency.Get(sellprice) .. "." )
		client:GetCharacter():GiveMoney(sellprice)
	end,
	OnCanRun = function(item)
		local owner = item:GetOwner()
		return !IsValid(item.entity) and owner and owner:GetCharacter() and owner:GetCharacter():HasFlags("1")
	end
}

ITEM.functions.Value = {
	name = "Value",
	icon = "icon16/help.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = math.Round(item.price)

		client:Notify( "Item is sellable for ".. ix.currency.Get(sellprice) .. "." )
		return false
	end,
	OnCanRun = function(item)
		local owner = item:GetOwner()
		return !IsValid(item.entity) and owner and owner:GetCharacter() and owner:GetCharacter():HasFlags("1")
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
		local quantity = item:GetData("quantity", 1)

		for i = 1, quantity - 1 do
			table.insert(targets, {
				name = i,
				data = {i},
			})
		end
		return targets
	end,
	OnCanRun = function(item)
		local quantity = item:GetData("quantity", 1)
		if (quantity <= 1) then
			return false
		end

		return (!IsValid(item.entity) and item.invID == item.player:GetCharacter():GetInventory():GetID())
	end,
	OnRun = function(item, data)
		if (data[1]) then
			local quantity = item:GetData("quantity", 1)
			local client = item.player
			local splitAmount = data[1]

			if (splitAmount >= quantity or splitAmount <= 0) then
				return false
			end
			
			item:SetData("quantity", quantity - splitAmount)
			if (ix.weight) then
				ix.weight.Update(client:GetChar())
			end

			local x, y, bagInvID = client:GetCharacter():GetInventory():Add(item.uniqueID, 1, {["quantity"] = splitAmount})

			if (!x) then
				item:SetData("quantity", quantity)
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
		if (!data or data[1] == item.id) then return false end

		local targetItem = ix.item.instances[data[1]]
		return targetItem and targetItem.uniqueID == item.uniqueID
	end,
	OnRun = function(item, data)
		local sourceItem = ix.item.instances[data[1]]
		local quantMax = item.quantMax or 10
		local currentQuant = item:GetData("quantity", 1)
		local sourceQuant = sourceItem:GetData("quantity", 1)
		local canAdd = quantMax - currentQuant
		
		item.player:EmitSound("stalker/inventory/inv_properties.mp3", 100)
		
		if (canAdd >= sourceQuant) then
			item:SetData("quantity", currentQuant + sourceQuant)
			sourceItem:Remove()
		else
			item:SetData("quantity", quantMax)
			sourceItem:SetData("quantity", sourceQuant - canAdd)
		end
		
		if (ix.weight) then
			ix.weight.Update(item.player:GetChar())
		end

		return false
	end,
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