ITEM.name = "9V Battery"
ITEM.model = "models/flaymi/anomaly/dynamics/equipments/trade/battery.mdl"
ITEM.description = "A disposable 9V battery for recharging electronic devices."
ITEM.longdesc = "Can be used to recharge equipment in need of a power source."
ITEM.category = "Electronics"
ITEM.price = 800
ITEM.flag = "1"
ITEM.width = 1
ITEM.height = 1
ITEM.weight = 0.05
ITEM.isBattery = true

ITEM.functions.Use = {
    name = "Use",
    tip = "useTip",
    icon = "icon16/add.png",
    isMulti = true,
    multiOptions = function(item, player)
        local options = {}
        local char = player:GetCharacter()

        if (char) then
            local inventory = char:GetInventory()
            local items = inventory:GetItems()

            for _, v in pairs(items) do
                if (v.isNVG or v.isArtifactdetector or v.isFlashlight or v.isAnomalydetector or v.isGeiger) then
                    local currentDura = v:GetData("durability", 0)

                    if (currentDura < 100) then
                    table.insert(options, {
                        name = v:GetName() .. " (" .. math.floor(currentDura) .. "%%)",
                        data = {v:GetID()},
                        sound = "cw/holster1.wav"
                    })
                    end
                end
            end
        end

        return options
    end,
    OnRun = function(item, data)
        local client = item.player
        local char = client:GetCharacter()
        
        if (!data) then return false end
        
        local target = ix.item.instances[data[1]]

        if (target and (target.isNVG or target.isArtifactdetector or target.isFlashlight or target.isAnomalydetector or target.isGeiger) and target:GetOwner() == client) then
            local oldCharge = target:GetData("durability", 0)
            local batteryPower = item:GetData("power", 100)

            target:SetData("durability", batteryPower)
            client:Notify("You replaced the battery in " .. target:GetName() .. ".")
            
            if (oldCharge > 0) then
                local inventory = char:GetInventory()

                if (!inventory:Add("9vbattery", 1, {power = oldCharge})) then
                    ix.item.Spawn("9vbattery", client:GetShootPos(), function(newItem)
                        newItem:SetData("power", oldCharge)
                    end)
                end
            end
            
            return true -- Consume the item
        else
            client:Notify("You have no valid device to insert this battery into, or invalid selection.")
            return false -- Do not consume the item
        end
    end,
    OnCanRun = function(item)
        return !IsValid(item.entity)
    end
}

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
		netstream.Start(item.player, "powerdurabilityAdjust", item:GetData("power", 100), item.id)
		return false
	end,
}

ITEM.functions.Value = {
	name = "Value",
	icon = "icon16/help.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local power = item:GetData("power", 100)
		local sellprice = (item:GetData("RealPrice") or item.price) * (power / 100)
		sellprice = math.Round(sellprice * 0.60)

		client:Notify("Item is sellable for " .. ix.currency.Get(sellprice) .. ".")
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item.player:GetCharacter():HasFlags("1")
	end
}

ITEM.functions.Sell = {
	name = "Sell",
	icon = "stalkerCoP/ui/icons/misc/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local power = item:GetData("power", 100)
		local sellprice = (item:GetData("RealPrice") or item.price) * (power / 100)
		sellprice = math.Round(sellprice * 0.60)

		if (sellprice <= 0) then
			client:Notify("This battery is too drained to have value.")
			return false
		end

		client:Notify("Sold for " .. ix.currency.Get(sellprice) .. ".")
		client:GetCharacter():GiveMoney(sellprice)
		return true
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item.player:GetCharacter():HasFlags("1")
	end
}

function ITEM:OnInstanced()
	if !self:GetData("power") then
		self:SetData("power", 100)
	end
end

function ITEM:GetDescription()
	local str = self.description
	if self.longdesc then
		str = str.."\n\n"..(self.longdesc or "")
	end

	return str .. "\n\nPower: " .. math.floor(self:GetData("power", 100)) .. "%"
end