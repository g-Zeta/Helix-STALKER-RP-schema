ITEM.name = "Detector"
ITEM.description = "A detector."
ITEM.longdesc = nil
ITEM.model = "models/weapons/w_pistol.mdl"
ITEM.category = "Electronics"
ITEM.class = "weapon_pistol"

ITEM.width = 1
ITEM.height = 1

ITEM.isArtifactdetector = true
ITEM.isWeapon = true
ITEM.noAmmo = true
ITEM.weaponCategory = "artifactdetector"
ITEM.equipIcon = Material("materials/vgui/ui/stalker/misc/equip.png")


-- Inventory drawing
if (CLIENT) then
--[[
	function ITEM:PaintOver(item, w, h)
		//Equipsquare
		if (item:GetData("equip")) then
			surface.SetDrawColor(110, 255, 110, 255)
			--surface.DrawRect(w - 14, h - 14, 8, 8)
		else
			surface.SetDrawColor(255, 110, 110, 255)
		end

		surface.SetMaterial(item.equipIcon)
		surface.DrawTexturedRect(w-23,h-23,19,19)
	end
]]
	function ITEM:PopulateTooltip(tooltip)
		if (self:GetData("equip")) then
			local name = tooltip:GetRow("name")
			name:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end
	end
end

ITEM.functions.Sell = {
	name = "Sell",
	icon = "icon16/stalker/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item.price*0.75

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

		sellprice = math.Round(sellprice)
		client:Notify( "Item is sellable for "..(sellprice).." rubles." )
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1")
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
		netstream.Start(item.player, "armordurabilityAdjust", item:GetData("durability",10000), item.id)
		return false
	end,
}

function ITEM:GetDescription()
	local quant = self:GetData("quantity", 1)
	local str = self.description

	if self.longdesc and !IsValid(self.entity) then
		str = str.."\n\n"..(self.longdesc or "").."\n \nDurability: "..(math.floor(self:GetData("durability", 10000))/100).."%"
	end

	local customData = self:GetData("custom", {})
	if(customData.desc) then
		str = customData.desc
	end
	
	if (customData.longdesc) and !IsValid(self.entity) then
		str = str.."\n"..(customData.longdesc or "").."\n \nDurability: "..(math.floor(self:GetData("durability", 10000))/100).."%"
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

-- On item is dropped, Remove a weapon from the player and keep the ammo in the item.
ITEM:Hook("drop", function(item)
	local inventory = ix.item.inventories[item.invID]
	local character = item.player:GetCharacter()
	
	local wepslots = character:GetData("wepSlots",{})
	wepslots[item.weaponCategory] = nil
	character:SetData("wepSlots",wepslots)
	
	if (!inventory) then
		return
	end

	-- the item could have been dropped by someone else (i.e someone searching this player), so we find the real owner
	local owner

	for client, character in ix.util.GetCharacters() do
		if (character:GetID() == inventory.owner) then
			owner = client
			break
		end
	end

	if (!IsValid(owner)) then
		return
	end

	if (item:GetData("equip")) then
		item:SetData("equip", nil)

		owner.carryWeapons = owner.carryWeapons or {}

		local weapon = owner.carryWeapons[item.weaponCategory]

		if (!IsValid(weapon)) then
			weapon = owner:GetWeapon(item.class)
		end

		if (IsValid(weapon)) then
			item:SetData("ammo", weapon:Clip1())

			owner:StripWeapon(item.class)
			owner.carryWeapons[item.weaponCategory] = nil
			owner:EmitSound("stalkersound/inv_drop.mp3", 80)
		end
	end
end)

-- On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/stalker/unequip.png",
	OnRun = function(item)
		item:Unequip(item.player, true)
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true
	end
}

-- On player eqipped the item, Gives a weapon to player and load the ammo data from the item.
ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/stalker/equip.png",
	OnRun = function(item)
		item:Equip(item.player)
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true
	end
}

function ITEM:Equip(client)
	local character = client:GetCharacter()
	local wepslots = character:GetData("wepSlots",{})

	if wepslots[self.weaponCategory] then
		client:NotifyLocalized("weaponSlotFilled", self.weaponCategory)

		return false
	end

	if (client:HasWeapon(self.class)) then
		client:StripWeapon(self.class)
	end

	local weapon = client:Give(self.class, !self.isGrenade)

	if (IsValid(weapon)) then
		local ammoType = weapon:GetPrimaryAmmoType()

		wepslots[self.weaponCategory] = weapon
		character:SetData("wepSlots",wepslots)
		client:SelectWeapon(weapon:GetClass())
		client:EmitSound("stalkersound/items/inv_items_wpn_1.ogg")

		-- Remove default given ammo.
		if (client:GetAmmoCount(ammoType) == weapon:Clip1() and self:GetData("ammo", 0) == 0) then
			client:RemoveAmmo(weapon:Clip1(), ammoType)
		end

		-- assume that a weapon with -1 clip1 and clip2 would be a throwable (i.e hl2 grenade)
		-- TODO: figure out if this interferes with any other weapons
		if (weapon:GetMaxClip1() == -1 and weapon:GetMaxClip2() == -1 and client:GetAmmoCount(ammoType) == 0) then
			client:SetAmmo(1, ammoType)
		end

		self:SetData("equip", true)
		if self:GetData("ammoType") ~= nil then

		else
			timer.Simple(0.1,function()
				local weapon1 = client:GetActiveWeapon()
				weapon1:SetClip1(self:GetData("ammo", 0))
			end)
		end

		if (self.isGrenade) then
			weapon:SetClip1(1)
			client:SetAmmo(0, ammoType)
		else
			weapon:SetClip1(self:GetData("ammo", 0))
		end

		weapon.ixItem = self

		if (self.OnEquipWeapon) then
			self:OnEquipWeapon(client, weapon)
		end
	else
		print(Format("[Helix] Cannot equip weapon - %s does not exist!", self.class))
	end
end

function ITEM:OnInstanced(invID, x, y)
	if !self:GetData("durability") then
		self:SetData("durability", 10000)
	end

	if !self:GetData("ammo") then
		self:SetData("ammo", 0)
	end
end

function ITEM:Unequip(client, bPlaySound, bRemoveItem)
	local character = client:GetCharacter()
	local wepslots = character:GetData("wepSlots",{})

	local weapon = wepslots[self.weaponCategory]

	if (!IsValid(weapon)) then
		weapon = client:GetWeapon(self.class)
	end

	if (IsValid(weapon)) then
		weapon.ixItem = nil

		self:SetData("ammo", weapon:Clip1())

		client:StripWeapon(self.class)
	else
		print(Format("[Helix] Cannot unequip weapon - %s does not exist!", self.class))
	end

	if (bPlaySound) then
		client:EmitSound("stalkersound/inv_slot.mp3")
	end

	wepslots[self.weaponCategory] = nil
	character:SetData("wepSlots",wepslots)
	self:SetData("equip", nil)

	if (self.OnUnequipWeapon) then
		self:OnUnequipWeapon(client, weapon)
	end

	if (bRemoveItem) then
		self:Remove()
	end
end

function ITEM:CanTransfer(oldInventory, newInventory)
	if (newInventory and self:GetData("equip")) then
		local owner = self:GetOwner()

		if (IsValid(owner)) then
			owner:NotifyLocalized("equippedWeapon")
		end

		return false
	end

	return true
end

function ITEM:OnLoadout()
	if (self:GetData("equip")) then
		local client = self.player
		local character = client:GetCharacter()
		local wepslots = character:GetData("wepSlots",{})

		local weapon = client:Give(self.class)

		if (IsValid(weapon)) then
			client:RemoveAmmo(weapon:Clip1(), weapon:GetPrimaryAmmoType())
			wepslots[self.weaponCategory] = weapon
			character:SetData("wepSlots",wepslots)
			weapon.ixItem = self
			weapon:SetClip1(self:GetData("ammo", 0))
		else
			print(Format("[Helix] Cannot give weapon - %s does not exist!", self.class))
		end
	end
end

function ITEM:OnSave()
	local weapon = self.player:GetWeapon(self.class)

	if (IsValid(weapon)) then
		self:SetData("ammo", weapon:Clip1())
	end
end

function ITEM:OnRemoved()
	local inventory = ix.item.inventories[self.invID]
	local owner = inventory.GetOwner and inventory:GetOwner()

	if (IsValid(owner) and owner:IsPlayer()) then
		local weapon = owner:GetWeapon(self.class)

		if (IsValid(weapon)) then
			weapon:Remove()
		end
	end
end

hook.Add("PlayerDeath", "ixStripClip", function(client)
	local character = client:GetCharacter()
	local wepslots = character:SetData("wepSlots",{})

	for _, v in pairs(client:GetCharacter():GetInventory():GetItems()) do
		if (v.isWeapon and v:GetData("equip")) then
			v:SetData("ammo", nil)
			v:SetData("equip", nil)
		end
	end
end)
