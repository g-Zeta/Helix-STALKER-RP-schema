ITEM.name = "Quest Item"
ITEM.model = "models/props_lab/box01a.mdl"
ITEM.description = "A quest item."
ITEM.longdesc = "Long description here. Use Customize to change the item's name, model, descriptions, weight and price."
ITEM.width = 2
ITEM.height = 2
ITEM.weight = 1
ITEM.price = 1
ITEM.flag = "N"
ITEM.category = "Quest"
ITEM.OnGetDropModel = true
ITEM.noBusiness = true

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
			local inventory = client:GetCharacter():GetInventory()
			
			if(!inventory:Add(item.uniqueID, 1, item.data)) then
				client:Notify("Inventory is full")
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

ITEM.functions.Sell = {
	name = "Sell",
	icon = "stalkerCoP/ui/icons/misc/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item:GetPrice()

		sellprice = math.Round(sellprice)
		client:Notify( "Sold for ".. ix.currency.Get(sellprice) .. "." )
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
		local sellprice = math.Round(item:GetPrice())

		client:Notify( "Item is sellable for ".. ix.currency.Get(sellprice) .. "." )
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1")
	end
}

function ITEM:GetDescription(partial)
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

function ITEM:GetModel() -- For icon in the inventory
	local model = self.model
	
	local customData = self:GetData("custom", {})
	if(customData.model) then
		model = customData.model
	end
	
	return model
end

function ITEM:OnGetDropModel()	-- For worldmodel
	local model = self.model
	
	local customData = self:GetData("custom", {})
	if(customData.model) then
		model = customData.model
	end
	
	return Format(model)
end

function ITEM:GetPrice()
	local customData = self:GetData("custom", {})
	return customData.price or self.price
end

function ITEM:GetWeight()
	local customData = self:GetData("custom", {})
	return customData.weight or self.weight
end