PLUGIN.name = "CW Weapons"
PLUGIN.author = "Lt. Taylor"
PLUGIN.desc = "Allows CW2.0 and CW2.0 KK INS2 SWEPs to be used."
PLUGIN.techFlag = "8"

ix.flag.Add(PLUGIN.techFlag, "Access to apply internal weapon upgrades.")

if (CLIENT) then
	local PANEL = {}
	function PANEL:Init()
	    local DuraSlider = self:Add("DNumSlider")
		DuraSlider:SetText("Weapon Durability")
		DuraSlider:SetMin(0)
		DuraSlider:SetMax(100)
		DuraSlider:SetDecimals(0)
		DuraSlider:Dock(FILL)
		
		self:SetTitle("Set Weapon Durability")
		self:SetSize(400, 150)
		self:Center()
		self:MakePopup()

		self.submit = self:Add("DButton")
		self.submit:Dock(BOTTOM)
		self.submit:DockMargin(0, 5, 0, 0)
		self.submit:SetTall(25)
		self.submit:SetText("Confirm")
		self.submit.DoClick = function()
		    local dura = DuraSlider:GetValue()
    		netstream.Start("weapondurabilityAdjust", (dura * 100), self.itemID)
    		self:Close()
		end
	end

	function PANEL:Think()
		self:MoveToFront()
	end

	vgui.Register("WeaponDurabilityMenu", PANEL, "DFrame")

	netstream.Hook("weapondurabilityAdjust", function(dura, id)
		local adjust = vgui.Create("WeaponDurabilityMenu")

		if (id) then
			adjust.itemID = id
		end
	end)
end

if (CLIENT) then return end

local delay = 0

function PLUGIN:WeaponFired(entity)
    if entity:IsPlayer() then
		local wep = entity:GetActiveWeapon()
		local wepclass = wep:GetClass()
		local item
		local ammo
		local newdura = 0
		
		for k,v in pairs(entity:GetChar():GetInv():GetItems()) do
			if v.isAmmo == true then
				if wep.Primary.Ammo == v.ammo then
					ammo = v
				end
			end
			if v.isPLWeapon then
				if v:GetData("equip",false) == true then
					if wepclass == v.class then
						item = v
					end
				end
			end
		end
		
		
		local newAmmo
		if ammo then
			local ammoCount = ammo:GetData("quantity") or 1
			if ammoCount == 1 then
				ammo:Remove()
			end
			newAmmo = ammoCount - 1
		end
		
		local dura
		if delay < CurTime() then
			delay = CurTime() + 3
			if ammo then
				ammo:SetData("quantity",newAmmo)
			end
			if not item then return end
			if ammo then
				wep:SetWeaponHP((item:GetData("durability")/100),100)
			end
			dura = item:GetData("durability", 10000)
			if (dura ~= 0) then
				if string.EndsWith(wep.Primary.Ammo, " -ZL-") then
					newdura = (dura - math.Round(item.modifier))
				else
					newdura = (dura - math.Round(item.modifier/2))
				end
				item:SetData("durability", newdura)
			end
			
			if (newdura <= 0) then
				item:SetData("equip", false)
				entity:StripWeapon(wepclass)
			end
		else
			if ammo then
				ammo:SetData("quantity",newAmmo,nil,true)
			end
			if not item then return end
			dura = item:GetData("durability", 10000)
			if (dura ~= 0) then
				if string.EndsWith(wep.Primary.Ammo, " -ZL-") then
					newdura = (dura - math.Round(item.modifier))
				else
					newdura = (dura - math.Round(item.modifier/2))
				end
				item:SetData("durability", newdura, nil, true)
			end
		end
		if (newdura <= 0) then
			item:SetData("equip", false)
			entity:StripWeapon(wepclass)
		end
    end
end

function PLUGIN:AmmoCheck(client, weapon)
	local ammoCount = 0
	local ammoCountGL = 0
	local ammoType = weapon.Primary.Ammo
	local char = client:GetChar()
	local inventory = char:GetInv()
	local items = inventory:GetItems()
	
	for k,v in pairs(items) do
		if v.class then
			if v.class == weapon:GetClass() then
				if v.noAmmo then
					return
				end
			end
		end
	end
	
	for k,v in pairs(items) do
		if v.isAmmo == true then
			if ammoType == v.ammo then
				ammoCount = ammoCount + v:GetData("quantity",1)
			elseif "40MM" == v.ammo then
				ammoCountGL = ammoCount + v:GetData("quantity",1)
			end
		end
	end
	
	if ammoCount > 0 then
		client:SetAmmo((ammoCount - weapon:Clip1()),ammoType)
	else
		client:SetAmmo(0,ammoType)
		weapon:SetClip1(0)
	end
	
	if ammoCountGL > 0 then
		client:SetAmmo((ammoCountGL - weapon:Clip1()),"40MM")
	else
		client:SetAmmo(0,"40MM")
	end
end

function PLUGIN:M203Fired(client)
	for k,v in pairs(client:GetChar():GetInv():GetItems()) do
		if v.isAmmo == true then
			if v.ammo == "40MM" then
				local oldquan = v:GetData("quantity",1)
				if oldquan <= 1 then
					v:Remove()
				end
				v:SetData("quantity",(oldquan - 1))
				return
			end
		end
	end
end

function PLUGIN:InitializedPlugins()
		-- There is no Customization Keys.
		CustomizableWeaponry.customizationMenuKey = "" -- the key we need to press to toggle the customization menu
		CustomizableWeaponry.canDropWeapon = false
		CustomizableWeaponry.enableWeaponDrops = false
		CustomizableWeaponry.quickGrenade.enabled = false
		CustomizableWeaponry.quickGrenade.canDropLiveGrenadeIfKilled = false
		CustomizableWeaponry.quickGrenade.unthrownGrenadesGiveWeapon = false
		CustomizableWeaponry.customizationEnabled = false

		hook.Remove("PlayerInitialSpawn", "CustomizableWeaponry.PlayerInitialSpawn")
		hook.Remove("PlayerSpawn", "CustomizableWeaponry.PlayerSpawn")
		hook.Remove("AllowPlayerPickup", "CustomizableWeaponry.AllowPlayerPickup")
	do
		function CustomizableWeaponry:hasAttachment(ply, att, lookIn)		
			return true
		end


	end
end

netstream.Hook("weapondurabilityAdjust", function(client, dura, id)
	local inv = (client:GetChar() and client:GetChar():GetInv() or nil)

	if (inv) then
		local item
		if (id) then
			item = ix.item.instances[id]
			local ent = item:GetEntity()
			if (item and (IsValid(ent) or item:GetOwner() == client)) then
				(ent or client):EmitSound("buttons/combine_button1.wav", 50, 170)
				dura = math.Round(dura)
				item:SetData("durability", dura)
				
				if item:GetData("equip") and item.player then
					local wep = item.player:GetWeapon(item.class)
					if IsValid(wep) then
						wep:SetWeaponHP((dura/100), 100)
					end
				end
			else
				client:Notify("No Weapon")
			end
		end
	end
end)