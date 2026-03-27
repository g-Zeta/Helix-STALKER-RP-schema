ITEM.name = "Mutant Trinkets"
ITEM.description = "It is the Mutant Trinkets."
ITEM.longdesc = "Long description here."
ITEM.model = "models/Gibs/HGIBS.mdl"

ITEM.width = 1
ITEM.height = 1

ITEM.weight = 1.0

ITEM.price = 100

ITEM.flag = "1"
ITEM.category = "Mutant Trinkets"


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