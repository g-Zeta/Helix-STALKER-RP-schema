ITEM.name = "Ammo Base"
ITEM.model = "models/Items/BoxSRounds.mdl"
ITEM.description = "A box with %s rounds of ammunition."
ITEM.longdesc = nil

ITEM.ammo = "pistol" -- type of the ammo
ITEM.ammoAmount = 30 -- amount of the ammo
ITEM.ammoMax = 150

ITEM.stats = {
	["BR"] = nil,
	["Pierce"] = nil,
	["Blunt"] = nil,
}

ITEM.price = nil	-- e.g. 1000
ITEM.flag = nil		-- e.g. "1"

ITEM.width = 2
ITEM.height = 1

ITEM.weight = nil -- weight of the full box in KG e.g. 1

ITEM.img = nil -- e.g. Material("vgui/hud/ammo_box.png")

---- Only copy what is above this line ----

ITEM.category = "Ammunition"
ITEM.splitSize = {1, 2, 5, 10, 15, 30, 50}
ITEM.isAmmo = true

function ITEM:GetDescription()
	local quant = self:GetData("quantity", self.ammoAmount)
	local ammodesc = Format(self.description, quant)
	local str = ""
	if self.longdesc then
		str = (self.longdesc or "")
	end

	local customData = self:GetData("custom", {})
	if(customData.desc) then
		str = customData.desc
	end

	if (self.entity) then
		return (ammodesc)
	else
        return (str.."\n \nThis box contains "..quant.." rounds.")
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

-- Calculate weight based on amount of rounds left in the box
function ITEM:GetWeight()
	return (self:GetData("quantity", self.ammoAmount) / self.ammoAmount) * (self.weight or 0)
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

if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		draw.SimpleText(
			item:GetData("quantity", item.ammoAmount).."/"..item.ammoMax, "DermaDefault", 3, h - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, color_black
		)
	end
end

ITEM.functions.split = {
    name = "Split",
    tip = "useTip",
    icon = "stalkerCoP/ui/icons/misc/split.png",
    isMulti = true,
    multiOptions = function(item, client)
		local targets = {}
        local quantity = item:GetData("quantity", item.ammoAmount)

        for i=1,#item.splitSize-1 do
			if quantity > item.splitSize[i] then
				table.insert(targets, {
					name = item.splitSize[i],
					data = {item.splitSize[i]},
				})
			end
		end
        return targets
	end,
	OnCanRun = function(item)
		if item:GetData("quantity", item.ammoAmount) == 1 then
			return false
		end

		return (!IsValid(item.entity) and item.invID == item.player:GetCharacter():GetInventory():GetID())
	end,
    OnRun = function(item, data)
		if data[1] then
			local quantity = item:GetData("quantity", item.ammoAmount)
			local client = item.player

			quantity = quantity - data[1]

			if quantity <= 0 then
				return false
			end
			
			item:SetData("quantity", quantity)

			local x, y, bagInvID = client:GetCharacter():GetInventory():Add(item.uniqueID, 1, {["quantity"] = data[1]})

			if (!x) then
				item:SetData("quantity", quantity + data[1])
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

		if targetItem and targetItem.ammo == item.ammo then
			return true
		else
			return false
		end
	end,
	OnRun = function(item, data)
		local sourceItem = ix.item.instances[data[1]]
		local targetAmmoDiff = item.ammoMax - item:GetData("quantity", item.ammoAmount)
		local localQuant = item:GetData("quantity", item.ammoAmount)
		local sourceQuant = sourceItem:GetData("quantity", sourceItem.ammoAmount)
		item.player:EmitSound("stalker/inventory/inv_properties.mp3", 100)
		if targetAmmoDiff >= sourceQuant then
			item:SetData("quantity", localQuant + sourceQuant)
			sourceItem:Remove()
			return false
		else
			sourceItem:SetData("quantity", sourceQuant - targetAmmoDiff)
			item:SetData("quantity", item.ammoMax)
			return false
		end
	end,
}

-- Called after the item is registered into the item tables.
function ITEM:OnRegistered()
	if (ix.ammo) then
		ix.ammo.Register(self.ammo)
	end
end

function ITEM:OnInstanced()
	if (self:GetData("quantity", 0) == 0) then
		self:SetData("quantity", self.ammoAmount)
	end
end

ITEM.functions.Sell = {
	name = "Sell",
	icon = "stalkerCoP/ui/icons/misc/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		client:Notify( "Sold for "..(math.Round((item.price/1.32)*(item:GetData("quantity",1)/item.ammoAmount))).." rubles." )
		client:GetCharacter():GiveMoney(math.Round((item.price/1.32)*(item:GetData("quantity",1)/item.ammoAmount)))
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
		client:Notify( "Item is sellable for "..(math.Round((item.price/1.32)*(item:GetData("quantity",1)/item.ammoAmount))).." rubles." )
		return false
	end,
	OnCanRun = function(item)
		local owner = item:GetOwner()
		return !IsValid(item.entity) and owner and owner:GetCharacter() and owner:GetCharacter():HasFlags("1")
	end
}