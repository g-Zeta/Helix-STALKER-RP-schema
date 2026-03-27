ITEM.name = "Outfit Sewing Kit"
ITEM.description = "Common tools and materials for taking care of damaged outfits."
ITEM.longdesc = "A light sewing kit consisting of a cloth reel, several steel needles and a pair of scissors. It can be used to sew up bullet holes or ruptures in soft fabrics of outfits. Its practical applications are limited due to the short length of the thread and subpar durability of needles, so the kit will be useless in case of more serious damage. For the same reason, it's compatible with only a handful of materials. Nonetheless, it is strongly advised to always use whatever is available to make the kit more effective."
ITEM.model = "models/flaymi/anomaly/dynamics/repair/sewing_kit_a.mdl"

ITEM.width = 1
ITEM.height = 1
ITEM.weight = 0.35

ITEM.price = 9000
ITEM.flag = "6"

ITEM.maxUses = 3
ITEM.repairAmount = 500
ITEM.repairTreshhold = 8000

ITEM.sound = "stalker/inventory/inv_repair_sewing_kit_fast.mp3"


if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		draw.SimpleText(item:GetData("quantity", 1).."/"..item.maxUses, "DermaDefault", 3, h - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, color_black)
	end
end

function ITEM:GetDescription()
	local quant = self:GetData("quantity", 1)
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

	if (self.entity) then
		return self.description.."\n\nThis tool has "..math.Round(quant).." uses left durability."
	else
        return (str.."\n\n".."Amount of durability restored: "..(self.repairAmount / 100).."% \nMinimum durability percentage: "..(self.repairTreshhold / 100).."%".."\n\nThis tool has "..quant.."/"..self.maxUses.." uses left.")
	end
end

function ITEM:GetWeight()
	return (self:GetData("quantity", self.maxUses) / self.maxUses) * (self.weight or 0)
end

function ITEM:GetName()
	local name = self.name
	
	local customData = self:GetData("custom", {})
	if(customData.name) then
		name = customData.name
	end
	
	return name
end

function ITEM:OnInstanced(invID, x, y)
	if !self:GetData("quantity") then
		self:SetData("quantity", self.maxUses)
	end
end

ITEM.functions.use = {
	name = "Stitch up outfit",
	tip = "useTip",
	icon = "stalkerCoP/ui/icons/misc/repair.png",
	isMulti = true,
	multiOptions = function(item, client)
		local targets = {}
		local char = client:GetCharacter()

		if (char) then
			local inv = char:GetInventory()

			if (inv) then
				local items = inv:GetItems()

				for k, v in pairs(items) do
					if (v.isBodyArmor or v.isArmor or v.isHelmet or v.isGasmask) and item.repairTreshhold < v:GetData("durability", 0) and v:GetData("durability", 0) < 10000 then
						table.insert(targets, {
							name = "Repair "..v.name.." with "..math.Round((v:GetData("durability", 0) / 100), 2).." percent durability to "..math.Clamp(math.Round((v:GetData("durability", 0) / 100), 2) + (item.repairAmount / 100), 0, 100).." percent durability.",
							data = {v:GetID()},
						})
					else
						continue
					end
				end
			end
		end

		return targets
		end,
	OnCanRun = function(item)				
		return (!IsValid(item.entity))
	end,
	OnRun = function(item, data)
		local client = item.player
		local char = client:GetCharacter()
		local inv = char:GetInventory()
		local items = inv:GetItems()
		local target = data
		
		for k, invItem in pairs(items) do
			if (data[1]) then
				if (invItem:GetID() == data[1]) then
					target = invItem

					break
				end
			else
				client:Notify("No outfit selected.")
				return false
			end
		end
		
		if item:GetData("quantity", 3) > 3 then
			item:SetData("quantity", 3)
		end
		
		if target:GetData("equip") != true then
			if target:GetData("durability", 10000) > item.repairTreshhold then
				target:SetData("durability", math.Clamp(target:GetData("durability", 10000) + item.repairAmount, 0, 10000))
				client:Notify(target.name.." successfully repaired.")
				item.player:EmitSound(item.sound or "items/battery_pickup.wav")
				if item:GetData("quantity", 3) > 1 then
					item:SetData("quantity", item:GetData("quantity", 3) - 1)

					if (SERVER and ix.weight) then
						ix.weight.Update(char)
					end
					return false
				else
					if (SERVER and ix.weight) then
						timer.Simple(0, function()
							if (char) then
								ix.weight.Update(char)
							end
						end)
					end
					return true
				end
			else
				client:Notify("Outfit too damaged.")
				return false
			end
		else
			client:Notify("Unequip the outfit first!")
			return false	
		end
	end,
}

ITEM.functions.Sell = {
	name = "Sell",
	icon = "stalkerCoP/ui/icons/misc/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item.price * 0.7
		sellprice = math.Round(sellprice * (item:GetData("quantity", 1) / item.maxUses))
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
		local sellprice = (item.price * 0.7)
		sellprice = math.Round(sellprice * (item:GetData("quantity", 1) / item.maxUses))
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