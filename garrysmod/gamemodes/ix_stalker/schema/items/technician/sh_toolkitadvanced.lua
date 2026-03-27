ITEM.name = "Advanced Toolkit"
ITEM.description = "A set of tools for fine work on armors."
ITEM.longdesc = "A decent set of tools. It looks like it was carefully put together by an experienced technician for his own use. Despite their age, the tools are in good condition."
ITEM.model = "models/flaymi/anomaly/dynamics/equipments/quest/box_toolkit_2.mdl"

ITEM.width = 2
ITEM.height = 2
ITEM.weight = 1.75

ITEM.price = 20000
ITEM.flag = "A"

ITEM.maxUses = 50
ITEM.repairTreshhold = 4000

ITEM.sound = "stalker/inventory/inv_repair_sewing_kit.mp3"

ITEM.isArmorToolkit = true

if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		draw.SimpleText(item:GetData("quantity", 1).."/"..item.maxUses, "DermaDefault", 3, h - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, color_black)
	end
end

function ITEM:GetWeight()
	return (self:GetData("quantity", self.maxUses) / self.maxUses) * (self.weight or 0)
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
        return (str.."\n\n".."Minimum durability percentage: "..(self.repairTreshhold / 100).."%".."\n\nThis tool has "..quant.."/"..self.maxUses.." uses left.")
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

function ITEM:OnInstanced(invID, x, y)
	if !self:GetData("quantity") then
		self:SetData("quantity", self.maxUses)
	end
end

ITEM.functions.use = {
	name = "Repair Outfit",
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
						local price = v:GetData("RealPrice") or v.price
						local durability = v:GetData("durability", 10000)
						local cost = math.Round((price * ((10000 - durability) / 10000)) * 0.85)

                        table.insert(targets, {
							name = L("Repair "..v.name.." | Cost: "..ix.currency.Get(cost)),
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
		local char = item.player:GetCharacter()

		if (char and char:HasFlags("6")) then
			return !IsValid(item.entity)
		else
			return false
		end
	end,

	OnRun = function(item, data)
		local client = item.player
		local char = client:GetCharacter()
		local inv = char:GetInventory()
		local items = inv:GetItems()
		local target = data[1]

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

		if target:GetData("equip") != true then
			local items = client:GetChar():GetInv():GetItems()

			local price = target:GetData("RealPrice") or target.price
			local durability = target:GetData("durability", 10000)
			local cost = math.Round((price * ((10000 - durability) / 10000)) * 0.75)

			if char:HasMoney(cost) then
				char:TakeMoney(cost)
				target:SetData("durability", 10000)
				client:EmitSound(item.sound or "items/battery_pickup.wav")
				ix.chat.Send(client, "iteminternal", "uses their "..item.name.." to repair the "..target.name..".", false)
			else
				client:Notify("Insufficient Funds!")
				return false
			end
			
			if item:GetData("quantity", item.maxUses) > 1 then
				item:SetData("quantity", item:GetData("quantity", item.maxUses) - 1)

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
			client:Notify("Unequip first!")
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