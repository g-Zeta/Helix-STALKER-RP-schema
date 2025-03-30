local background = Material("cotz/panels/loot_interface.png")
local background2 = Material("stalker/backgroundempty.png", "noclamp")
local btn1 = Material("cotz/panels/button1_1.png", "noclamp smooth")
local btn1hover = Material("cotz/panels/button1_2.png", "noclamp smooth")
local btn1press = Material("cotz/panels/button1_4.png", "noclamp smooth")
local btn1pressed = Material("cotz/panels/button1_3.png", "noclamp smooth")
local btnclose = Material("stalker/btnclose.png", "noclamp smooth")
local inventoryui = Material("stalkerCoP/ui/inventory/inventory.png", "noclamp smooth")
local equipmentui = Material("stalkerCoP/ui/inventory/equipment.png", "noclamp smooth")

local PANEL = {}

function PANEL:Init()
	self.frame = self
	self.frame:SetTitle("stalkertest")
	self.frame:ShowCloseButton(false)
	self.frame:DockPadding(self.frame:GetWide() * 0.1, self.frame:GetTall() * 0.05, self.frame:GetWide() * 0.1, self.frame:GetTall() * 0.05)


	self.closebtn = self.frame:Add("DImageButton")
	self.closebtn:SetSize(ScrW()*0.0123, ScrH()*0.02155)
	self.closebtn:SetMaterial(btnclose)
	self.closebtn:SetPos(self.frame:GetWide() - self.frame:GetWide() * 0.08, self.frame:GetTall() - self.frame:GetTall() * 0.96)

	function self.closebtn.DoClick()
		self:Close()
	end
end

function PANEL:PostLayoutUpdate()
	self.frame:DockPadding(self.frame:GetWide() * 0.075, self.frame:GetTall() * 0.05, self.frame:GetWide() * 0.075, self.frame:GetTall() * 0.05)
	self.frame:SetSize(self.frame:GetWide() * 1.15, self.frame:GetTall() * 1.1)
	self.closebtn:SetPos(self.frame:GetWide() - self.frame:GetWide() * 0.04 - self.closebtn:GetWide(), self.frame:GetTall() - self.frame:GetTall() * 0.96)
	self.frame:Center()
end
	

function PANEL:Paint(width, height)
	surface.SetMaterial(background)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(2, 2, width-4, height-4)
end

vgui.Register("ixStalkerFrame", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self:SetText(" -- ")
	self:DockMargin(self:GetParent():GetWide()*0.3, 20, self:GetParent():GetWide()*0.3, 0)
	self:SetTall(ScrH()*0.05 * (ScrH() / 1080))
	self:SetFont("stalkerregularfont")

    self.healthChanged = true
    self.moneyChanged = true
end

function PANEL:Paint(width, height)
	surface.SetMaterial(btn1)

	if self:IsHovered() then
		surface.SetMaterial(btn1hover)
	end

	if self:IsDown() then
		surface.SetMaterial(btn1press)
	end

	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, width, height)
end

vgui.Register("ixStalkerButton", PANEL, "DImageButton")


local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)

	ix.gui.menuInventoryContainer = self

	local panel = self:Add("ixInventory")
	panel:SetPos(0, 0)
	panel:SetDraggable(false)
	panel:SetSizable(false)
	panel:SetTitle(nil)
	panel.bNoBackgroundBlur = true
	panel.childPanels = {}

	local inventory = LocalPlayer():GetCharacter():GetInventory()

	if (inventory) then
		panel:SetInventory(inventory)
	end

	ix.gui.inv1 = panel

	self:SetWide(panel:GetWide() - 100 * (ScrW() / 1920))
end

vgui.Register("ixStalkerInventory", PANEL, "DScrollPanel")


local PANEL = {}

function PANEL:Init()
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	self:SetSizable(false)
	self:SetTitle("")
	self.thinkdelay = 0

	ix.gui.menuInventoryFrame = self

	-- Inventory Panel
	self.inventorypanel = self:Add("DImage")
	self.inventorypanel:SetSize(341 * (ScrW() / 1920), 768 * (ScrH() / 1080))
	self.inventorypanel:SetMaterial(inventoryui)
	self.inventorypanel:SetPos(714 * (ScrW() / 1920), 77 * (ScrH() / 1080))
	self.inventorypanel:SetZPos(-1)

	local container = self:Add("ixStalkerInventory")
	self:SetSize(container:GetWide() + 1065 * (ScrW() / 1920), container:GetTall() + 100 * (ScrH() / 1080))
	self:DockPadding(732 * (ScrW() / 1920), 185 * (ScrH() / 1080), 0, 0) --Inventory grid position

	self.name = self.inventorypanel:Add("DLabel")
	self.name:SetFont("stalkerregularsmallboldfont")
	self.name:SetTextColor(color_white)
	self.name:SetPos(17 * (ScrW() / 1920), 20 * (ScrH() / 1080))
	self.name:SetContentAlignment(7)
	self.name:SetWide(190 * (ScrW() / 1920))
	self.name:SetText(LocalPlayer():GetName())

	self.rep = self.inventorypanel:Add("DLabel")
	self.rep:SetFont("stalkerregularsmallfont")
	self.rep:SetTextColor(color_white)
	self.rep:SetText("Rank: "..LocalPlayer():getCurrentRankName())
	self.rep:SetPos(17 * (ScrW() / 1920), 45 * (ScrH() / 1080))
	self.rep:SetWide(190 * (ScrW() / 1920))
	self.rep:SetContentAlignment(7)

	self.money = self.inventorypanel:Add("DLabel")
	self.money:SetFont("stalkerregularsmallboldfont")
	self.money:SetPos(7 * (ScrW() / 1920), 75 * (ScrH() / 1080))
	self.money:SetWide(190 * (ScrW() / 1920))
	self.money:SetContentAlignment(6)
	self.money:SetText(ix.currency.Get(LocalPlayer():GetCharacter():GetMoney()))

	self.charbackgroundicon = self.inventorypanel:Add("DImage")
	self.charbackgroundicon:SetSize(124 * (ScrW() / 1920), 87 * (ScrH() / 1080))
	self.charbackgroundicon:SetPos(208 * (ScrW() / 1920), 11 * (ScrH() / 1080))
	self.charbackgroundicon:SetZPos(-1)
	
	local isImperial = ix.option.Get("imperial", false) -- Get the user's preference for units
	if LocalPlayer():GetChar() == nil then return end
	local character = LocalPlayer():GetChar()
	local weight = character:GetData("Weight", 0)
	local maxweight = character:GetData("MaxWeight", 30)
	local weightString = ix.weight.WeightString(weight, isImperial) -- Format the weight string
	local maxWeightValue = ix.config.Get("maxWeight", 30)
	local maxOverWeightValue = ix.config.Get("maxOverWeight", 20)
	local carrybuff = LocalPlayer():GetChar():GetData("WeightBuffCur") or 0
	local totalMaxWeight = maxWeightValue + maxOverWeightValue + carrybuff
	local maxWeightString = ix.weight.WeightString(totalMaxWeight, isImperial) -- Format the total max weight string	
	self.weight = self.inventorypanel:Add("DLabel")
	self.weight:SetFont("stalkerregularsmallboldfont")
	self.weight:SetPos(137 * (ScrW() / 1920), 733 * (ScrH() / 1080))
	self.weight:SetWide(190 * (ScrW() / 1920))
	self.weight:SetContentAlignment(6)
	self.weight:SetText(weightString .. " of " .. maxWeightString)

	if LocalPlayer():GetCharacter():GetData("pdaavatar") then 
		self.charbackgroundicon:SetImage( LocalPlayer():GetCharacter():GetData("pdaavatar") )
	else
		self.charbackgroundicon:SetImage( "vgui/icons/face_31.png" )
	end

	--Equipment panel and image
    self.equipmentpanel = self:Add("DImage")
    self.equipmentpanel:SetSize(343 * (ScrW() / 1920), 768 * (ScrH() / 1080))
    self.equipmentpanel:SetMaterial(equipmentui)
    self.equipmentpanel:SetPos(371 * (ScrW() / 1920), 77 * (ScrH() / 1080))
    self.equipmentpanel:SetZPos(-1)

	local client = LocalPlayer()
	local character = client:GetCharacter()
	local inv = character:GetInv()
	local items = inv:GetItems()
	local blocker = Material("stalkerCoP/ui/inventory/blockplate.png")
	local blockercont = Material("stalkerCoP/ui/inventory/blockplate_container.png")

	if not client or not character or not inv then return end

	-- EQUIPMENT PANELS
	-- Helmet
	self.HelmetPanel = self.equipmentpanel:Add("DPanel")
	self.HelmetPanel:SetSize(96 * (ScrW() / 1920), 115 * (ScrH() / 1080))
	self.HelmetPanel:SetPos(12 * (ScrW() / 1920), 11 * (ScrH() / 1080))
	function self.HelmetPanel:Paint(w, h)
		for _, item in pairs(items) do
			if item:GetData("equip", false) then
				if (item.isArmor and item.isHelmet) or (item.isHelmet and item.isGasmask) then
					surface.SetMaterial(blocker)
					surface.SetDrawColor(255, 255, 255, 255) 
					surface.DrawTexturedRect(0, 0, 96 * (ScrW()/1920), 115 * (ScrH()/1080))
				elseif not item.isArmor and not item.isGasmask then
					if item.isHelmet then
						local helmetImage = item.img
						surface.SetMaterial(helmetImage)
						surface.SetDrawColor(255, 255, 255, 255) 
						surface.DrawTexturedRect(4 * (ScrW()/1920), 12 * (ScrH()/1080), 88 * (ScrW()/1920), 88 * (ScrH()/1080))
					end
				end
			end
		end
	end

	-- Helmet Durability
	self.HelmetDura = self.HelmetPanel:Add("DPanel")
	self.HelmetDura:SetSize(2 * (ScrW() / 1920) * 15 + 2 * 15, 4 * (ScrH() / 1080)) -- Calculate total width including spacing
	self.HelmetDura:SetPos(19 * (ScrW() / 1920), 108 * (ScrH() / 1080))
	local duraImage = Material("stalkerCoP/ui/inventory/durability_bar_1dp.png")
	function self.HelmetDura:Paint(w, h)
		for _, item in pairs(items) do
			if item:GetData("equip", false) then
				if item.isHelmet and (not item.isArmor and not item.isGasmask) then
					local durability = item:GetData("durability")
					local maxDura = 10000
					local duraPercentage = durability / maxDura
					local segmentsToDraw = math.ceil(duraPercentage * 15)

					-- Draw segments
					for i = 0, 15 do
						if i < segmentsToDraw then
							surface.SetMaterial(duraImage)
							if durability > 6000 then
								surface.SetDrawColor(115, 180, 130, 150)	-- green
							elseif durability > 4000 and durability <= 6000 then
								surface.SetDrawColor(173, 173, 105, 150)	-- yellow
							elseif durability > 2000 and durability <= 4000 then
								surface.SetDrawColor(Color(170, 115, 85, 150)) -- orange
							elseif durability > 0 and durability <= 2000 then
								surface.SetDrawColor(Color(160, 45, 45, 150))	-- red
							end
							surface.DrawTexturedRect(i * (2 + 2), 0, 2 * (ScrW() / 1920), h * (ScrH()/1080)) -- Draw each segment with spacing
						end
					end
				end
			end
		end
	end

	-- Gasmask/Headgear
	self.HeadgearPanel = self.equipmentpanel:Add("DPanel")
	self.HeadgearPanel:SetSize(110 * (ScrW() / 1920), 115 * (ScrH() / 1080))
	self.HeadgearPanel:SetPos(117 * (ScrW() / 1920), 11 * (ScrH() / 1080))
	function self.HeadgearPanel:Paint(w, h)
		for _, item in pairs(items) do
			if item:GetData("equip", false) then
				if item.isArmor and item.isGasmask then
					surface.SetMaterial(blocker)
					surface.SetDrawColor(255, 255, 255, 255) 
					surface.DrawTexturedRect(0, 0, 110 * (ScrW()/1920), 115 * (ScrH()/1080))
				elseif not item.isArmor then
					if (item.isGasmask and item.isHelmet) or item.isGasmask then
						local headgearImage = item.img
						surface.SetMaterial(headgearImage)
						surface.SetDrawColor(255, 255, 255, 255) 
						surface.DrawTexturedRect(5 * (ScrW()/1920), 3 * (ScrH()/1080), 100 * (ScrW()/1920), 100 * (ScrH()/1080))
					end
				end
			end
		end
	end

	-- Headgear Durability
	self.HeadgearDura = self.HeadgearPanel:Add("DPanel")
	self.HeadgearDura:SetSize(2 * (ScrW() / 1920) * 15 + 2 * 15, 4 * (ScrH() / 1080)) -- Calculate total width including spacing
	self.HeadgearDura:SetPos(26 * (ScrW() / 1920), 108 * (ScrH() / 1080))
	local duraImage = Material("stalkerCoP/ui/inventory/durability_bar_1dp.png")
	function self.HeadgearDura:Paint(w, h)
		for _, item in pairs(items) do
			if item:GetData("equip", false) then
				if not item.isArmor and ((item.isGasmask and item.isHelmet) or item.isGasmask) then
					local durability = item:GetData("durability")
					local maxDura = 10000
					local duraPercentage = durability / maxDura
					local segmentsToDraw = math.ceil(duraPercentage * 15)

					-- Draw segments
					for i = 0, 15 do
						if i < segmentsToDraw then
							surface.SetMaterial(duraImage)
							if durability > 6000 then
								surface.SetDrawColor(115, 180, 130, 150)	-- green
							elseif durability > 4000 and durability <= 6000 then
								surface.SetDrawColor(173, 173, 105, 150)	-- yellow
							elseif durability > 2000 and durability <= 4000 then
								surface.SetDrawColor(Color(170, 115, 85, 150)) -- orange
							elseif durability > 0 and durability <= 2000 then
								surface.SetDrawColor(Color(160, 45, 45, 150))	-- red
							end
							surface.DrawTexturedRect(i * (2 + 2), 0, 2 * (ScrW() / 1920), h * (ScrH()/1080)) -- Draw each segment with spacing
						end
					end
				end
			end
		end
	end

	-- Armor
	self.ArmorPanel = self.equipmentpanel:Add("DPanel")
	self.ArmorPanel:SetSize(110 * (ScrW() / 1920), 181 * (ScrH() / 1080))
	self.ArmorPanel:SetPos(117 * (ScrW() / 1920), 135 * (ScrH() / 1080))
	function self.ArmorPanel:Paint(w, h)
		for _, item in pairs(items) do
			if item.isArmor and item:GetData("equip", false) then
				local armorImage = item.img
				surface.SetMaterial(armorImage)
				surface.SetDrawColor(255, 255, 255, 255) 
				surface.DrawTexturedRect(2 * (ScrW()/1920), 10 * (ScrH()/1080), 106 * (ScrW()/1920), 159 * (ScrH()/1080))
			end
		end
	end

	-- Armor Durability
	self.ArmorDura = self.ArmorPanel:Add("DPanel")
	self.ArmorDura:SetSize(2 * (ScrW() / 1920) * 15 + 2 * 15, 4 * (ScrH() / 1080)) -- Calculate total width including spacing
	self.ArmorDura:SetPos(26 * (ScrW() / 1920), 174 * (ScrH() / 1080))
	function self.ArmorDura:Paint(w, h)
		for _, item in pairs(items) do
			if item:GetData("equip", false) then
				if item.isArmor then
					local durability = item:GetData("durability")
					local maxDura = 10000
					local duraPercentage = durability / maxDura
					local segmentsToDraw = math.ceil(duraPercentage * 15)

					-- Draw segments
					for i = 0, 15 do
						if i < segmentsToDraw then
							surface.SetMaterial(duraImage)
							if durability > 6000 then
								surface.SetDrawColor(115, 180, 130, 150)	-- green
							elseif durability > 4000 and durability <= 6000 then
								surface.SetDrawColor(173, 173, 105, 150)	-- yellow
							elseif durability > 2000 and durability <= 4000 then
								surface.SetDrawColor(Color(170, 115, 85, 150)) -- orange
							elseif durability > 0 and durability <= 2000 then
								surface.SetDrawColor(Color(160, 45, 45, 150))	-- red
							end
							surface.DrawTexturedRect(i * (2 + 2), 0, 2 * (ScrW() / 1920), h * (ScrH()/1080)) -- Draw each segment with spacing
						end
					end
				end
			end
		end
	end

	-- Left Weapon
	self.LWepPanel = self.equipmentpanel:Add("DPanel")
	self.LWepPanel:SetSize(92 * (ScrW() / 1920), 250 * (ScrH() / 1080))
	self.LWepPanel:SetPos(14 * (ScrW() / 1920), 135 * (ScrH() / 1080))

	-- Right Weapon
	self.RWepPanel = self.equipmentpanel:Add("DPanel")
	self.RWepPanel:SetSize(92 * (ScrW() / 1920), 250 * (ScrH() / 1080))
	self.RWepPanel:SetPos(238 * (ScrW() / 1920), 135 * (ScrH() / 1080))

	-- Sidearm
	self.SidearmPanel = self.equipmentpanel:Add("DPanel")
	self.SidearmPanel:SetSize(110 * (ScrW() / 1920), 60 * (ScrH() / 1080))
	self.SidearmPanel:SetPos(117 * (ScrW() / 1920), 325 * (ScrH() / 1080))

	-- PDA icon
	self.PDAiconPanel = self.equipmentpanel:Add("DPanel")
	self.PDAiconPanel:SetSize(78 * (ScrW() / 1920), 67 * (ScrH() / 1080))
	self.PDAiconPanel:SetPos(11 * (ScrW() / 1920), 395 * (ScrH() / 1080))
	function self.PDAiconPanel:Paint(w, h)
		for _, item in pairs(items) do
			if item.isPDA and item:GetData("equip", false) then
				local PDAiconImage = item.img
				surface.SetMaterial(PDAiconImage)
				surface.SetDrawColor(255, 255, 255, 255) 
				surface.DrawTexturedRect(7 * (ScrW()/1920), 1 * (ScrH()/1080), 64 * (ScrW()/1920), 64 * (ScrH()/1080))
			end
		end
	end

	-- Geiger
	self.GeigerPanel = self.equipmentpanel:Add("DPanel")
	self.GeigerPanel:SetSize(78 * (ScrW() / 1920), 67 * (ScrH() / 1080))
	self.GeigerPanel:SetPos(92 * (ScrW() / 1920), 395 * (ScrH() / 1080))
	function self.GeigerPanel:Paint(w, h)
		for _, item in pairs(items) do
			if item.isGeiger and item:GetData("equip", false) then
				local GeigerImage = item.img
				surface.SetMaterial(GeigerImage)
				surface.SetDrawColor(255, 255, 255, 255) 
				surface.DrawTexturedRect(7 * (ScrW()/1920), 1 * (ScrH()/1080), 64 * (ScrW()/1920), 64 * (ScrH()/1080))
			end
		end
	end

	-- Anomaly Detector
	self.AnomDetPanel = self.equipmentpanel:Add("DPanel")
	self.AnomDetPanel:SetSize(78 * (ScrW() / 1920), 67 * (ScrH() / 1080))
	self.AnomDetPanel:SetPos(173 * (ScrW() / 1920), 395 * (ScrH() / 1080))
	function self.AnomDetPanel:Paint(w, h)
		for _, item in pairs(items) do
			if item.isAnomalydetector and item:GetData("equip", false) then
				local AnomDetImage = item.img
				surface.SetMaterial(AnomDetImage)
				surface.SetDrawColor(255, 255, 255, 255) 
				surface.DrawTexturedRect(7 * (ScrW()/1920), 1 * (ScrH()/1080), 64 * (ScrW()/1920), 64 * (ScrH()/1080))
			end
		end
	end

	-- Artifact Detector
	self.ArtDetPanel = self.equipmentpanel:Add("DPanel")
	self.ArtDetPanel:SetSize(78 * (ScrW() / 1920), 67 * (ScrH() / 1080))
	self.ArtDetPanel:SetPos(254 * (ScrW() / 1920), 395 * (ScrH() / 1080))
	function self.ArtDetPanel:Paint(w, h)
		for _, item in pairs(items) do
			if (item.class == "detector_veles" or item.class == "detector_bear" or item.class == "detector_echo") and item:GetData("equip", false) then
				local detectorImage = item.img
				surface.SetMaterial(detectorImage)
				surface.SetDrawColor(255, 255, 255, 255) 
				surface.DrawTexturedRect(7 * (ScrW()/1920), 1 * (ScrH()/1080), 64 * (ScrW()/1920), 64 * (ScrH()/1080))
			end
		end
	end

	-- Artifacts panel
	self.ArtifactsPanel = self.equipmentpanel:Add("DPanel")
	self.ArtifactsPanel:SetSize(322 * (ScrW() / 1920), 62 * (ScrH() / 1080))
	self.ArtifactsPanel:SetPos(11 * (ScrW() / 1920), 471 * (ScrH() / 1080))
	function self.ArtifactsPanel:Paint(w, h)
		local artX = 3 * (ScrW()/1920)
		local artY = 2 * (ScrH()/1080)
		local artifactSize = 55
		for _, item in pairs(items) do
			if item.isArtefact and item:GetData("equip", false) then
				local artifactImage = item.img
				surface.SetMaterial(artifactImage)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(artX, artY, artifactSize * (ScrW()/1920), artifactSize * (ScrH()/1080))

                -- Update the x position for the next artifact
                artX = artX + 10 + artifactSize -- Move x to the right for the next image
			end
		end

		local totalContainers = 5
		local equippedContainers = 0

		-- Iterate over equipped items to count the total artifact containers
		local items = LocalPlayer():GetCharacter():GetInventory():GetItems()
		for _, item in pairs(items) do
			if item:GetData("equip", false) then
				equippedContainers = equippedContainers + (item.artifactcontainers and tonumber(item.artifactcontainers[1]) or 0)
			end
		end

		-- Calculate how many more containers are needed
		local missingContainers = totalContainers - equippedContainers
		if missingContainers < 0 then
			missingContainers = 0  -- Ensure we don't draw negative blockers
		end

		-- Draw blocker images
		local contX = 261 * (ScrW()/1920)
		local conteinerSize = 59
		local spacing = 6 -- Spacing between containers
		for i = 1, missingContainers do
			surface.SetMaterial(blockercont)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(contX, 0, conteinerSize * (ScrW() / 1920), conteinerSize * (ScrH() / 1080)) -- Adjust the position and size as needed

            contX = contX - spacing - conteinerSize
		end
	end

	-- Health panel
	self.healthImage = self.equipmentpanel:Add("DPanel") -- Use DPanel to manage multiple health images
	self.healthImage:SetSize(2 * (ScrW() / 1920) * 54 + 2 * 54, 16 * (ScrH() / 1080)) -- Calculate total width including spacing
	self.healthImage:SetPos(14 * (ScrW() / 1920), 570 * (ScrH() / 1080))

	local hpImage = Material("stalkerCoP/ui/inventory/health_bar_1hp.png")
	function self.healthImage:Paint(w, h)
		local health = LocalPlayer():Health() -- Get player's current health
		local maxHealth = LocalPlayer():GetMaxHealth() -- Get player's max health
		local healthPercentage = health / maxHealth
		local segmentsToDraw = math.ceil(healthPercentage * 54) -- Calculate the number of segments to draw

		-- Draw health segments
		for i = 0, 54 do
			if i < segmentsToDraw then
				surface.SetMaterial(hpImage)
				surface.SetDrawColor(115, 40, 40, 255) -- Set color to red
				surface.DrawTexturedRect(i * (2 + 2), 0, 2 * (ScrW() / 1920), h * (ScrH() / 1080)) -- Draw each segment with spacing
			end
		end
	end

	local heartbeatSpeed = 2.5 -- Speed of the heartbeat effect
	local maxAlpha = 255 -- Maximum alpha value
	local minAlpha = 50 -- Minimum alpha value (to avoid complete transparency)
	local lp = LocalPlayer()
	local char = lp:GetCharacter()

	-- Bleed panel
	self.BleedIcon = self.equipmentpanel:Add("DPanel")
	self.BleedIcon:SetSize(45 * (ScrW() / 1920), 45 * (ScrH() / 1080))
	self.BleedIcon:SetPos(240 * (ScrW() / 1920), 547 * (ScrH() / 1080))

	local bleedImage = Material("stalkerCoP/ui/inventory/bleed.png")
	local bleedImage2 = Material("stalkerCoP/ui/inventory/bleed2.png")
	local bleedImage3 = Material("stalkerCoP/ui/inventory/bleed3.png")
	local bleedImage4 = Material("stalkerCoP/ui/inventory/bleed4.png")

	function self.BleedIcon:Paint(w, h)
		local bleeding = character:GetData("Bleeding", 0) > 0
		local time = CurTime() * heartbeatSpeed
		local alpha = math.abs(math.sin(time)) * (maxAlpha - minAlpha) + minAlpha
		local health = LocalPlayer():Health()

		if bleeding or (timer.Exists(client:Name().."res_bleed")) then
			surface.SetMaterial(bleedImage)
			if health == 100 then
				surface.SetMaterial(bleedImage)
				surface.SetDrawColor(Color(0, 0, 0, 0))
			elseif health < 100 and health >= 89 then
				surface.SetMaterial(bleedImage)
				surface.SetDrawColor(Color(255, 255, 255, alpha))
			elseif health < 89 and health >= 60 then
				surface.SetMaterial(bleedImage2)
				surface.SetDrawColor(Color(255, 255, 255, alpha))
			elseif health < 60 and health >= 25 then
				surface.SetMaterial(bleedImage3)
				surface.SetDrawColor(Color(255, 255, 255, alpha))
			elseif health < 25 and health >= 0 then
				surface.SetMaterial(bleedImage4)
				surface.SetDrawColor(Color(255, 255, 255, alpha))
			end

			surface.DrawTexturedRect(0, 0, w * (ScrW() / 1920), h * (ScrH() / 1080))
		end
	end

	-- Radiation panel
	self.RadIcon = self.equipmentpanel:Add("DImage")
	self.RadIcon:SetSize(45 * (ScrW() / 1920), 45 * (ScrH() / 1080))
	self.RadIcon:SetPos(288 * (ScrW() / 1920), 545 * (ScrH() / 1080))

	local radImage = Material("stalkerCoP/ui/inventory/rad.png")
	local radImage2 = Material("stalkerCoP/ui/inventory/rad2.png")
	local radImage3 = Material("stalkerCoP/ui/inventory/rad3.png")
	local radImage4 = Material("stalkerCoP/ui/inventory/rad4.png")

	function self.RadIcon:Paint(w, h)
		local time = CurTime() * heartbeatSpeed
		local alpha = math.abs(math.sin(time)) * (maxAlpha - minAlpha) + minAlpha
		local radiation = lp:getRadiation()
		
		surface.SetMaterial(radImage)
		if radiation == 0 then
			surface.SetMaterial(radImage)
			surface.SetDrawColor(Color(0, 0, 0, 0))
		elseif radiation > 0 and radiation <= 25 then
			surface.SetMaterial(radImage)
			surface.SetDrawColor(Color(255, 255, 255, alpha))
		elseif radiation > 25 and radiation <= 60 then
			surface.SetMaterial(radImage2)
			surface.SetDrawColor(Color(255, 255, 255, alpha))
		elseif radiation > 60 and radiation <= 89 then
			surface.SetMaterial(radImage3)
			surface.SetDrawColor(Color(255, 255, 255, alpha))
		elseif radiation > 89 and radiation <= 100 then
			surface.SetMaterial(radImage4)
			surface.SetDrawColor(Color(255, 255, 255, alpha))
		end

		surface.DrawTexturedRect(0, 0, w * (ScrW() / 1920), h * (ScrH() / 1080)) 
	end

	-- Resistances panel
	self.ResistancesImage = self.equipmentpanel:Add("DImage")
	self.ResistancesImage:SetSize(283 * (ScrW() / 1920), 104 * (ScrH() / 1080))
	self.ResistancesImage:SetPos(39 * (ScrW() / 1920), 610 * (ScrH() / 1080))

	local resImage = Material("stalkerCoP/ui/inventory/health_bar_1hp.png")

	-- Function to create a resistance bar
	local function CreateResistanceBar(parent, material, resistanceType, posX, posY)
		local bar = parent:Add("DImage")
		bar:SetSize(2 * (ScrW() / 1920) * 31 + 2 * 31, 18 * (ScrH() / 1080))
		bar:SetPos(posX, posY)

		-- Function to calculate total resistance
		local function calculateResistance()
			local character = LocalPlayer():GetChar()
			local inventory = character:GetInventory()
			local items = inventory:GetItems()
			local totalRes = 0

			-- Iterate through equipped items
			for _, item in pairs(items) do
				if item:GetData("equip", false) then
					if item.res and item.res[resistanceType] then
						totalRes = totalRes + item.res[resistanceType]
					end
				end
			end

			return totalRes
		end

		-- Modify the bar's paint function
		function bar:Paint(w, h)
			local resistance = calculateResistance()
			local maxResistance = 31 -- Maximum number of segments
			local segmentsToDraw = math.ceil(resistance * maxResistance)

			-- Draw resistance segments
			for i = 0, maxResistance do
				if i < segmentsToDraw then
					surface.SetMaterial(material)
					if resistanceType == "Radiation" then
						surface.SetDrawColor(0, 150, 0, 255) -- Darker green for radiation
					elseif resistanceType == "Chemical" then
						surface.SetDrawColor(150, 150, 0, 255) -- Darker yellow for chemical
					elseif resistanceType == "Shock" then
						surface.SetDrawColor(0, 100, 168, 255) -- Darker light blue for shock
					elseif resistanceType == "Burn" then
						surface.SetDrawColor(150, 0, 0, 255) -- Darker red for burn
					elseif resistanceType == "Psi" then
						surface.SetDrawColor(85, 0, 140, 255) -- Darker purple for psi
					elseif resistanceType == "Slash" then
						surface.SetDrawColor(150, 150, 150, 255) -- Darker gray for slash
					elseif resistanceType == "Fall" then
						surface.SetDrawColor(150, 150, 150, 255) -- Darker gray for fall
					end
					surface.DrawTexturedRect(i * (2 + 2), 0, 2 * (ScrW() / 1920), h * (ScrH() / 1080)) -- Draw each segment with spacing
				end
			end
		end

		return bar
	end

	-- Create resistances bars using the unified function
	self.radiationBar = CreateResistanceBar(self.ResistancesImage, resImage, "Radiation", 1 * (ScrW() / 1920), 1 * (ScrH() / 1080))
	self.chemicalBar = CreateResistanceBar(self.ResistancesImage, resImage, "Chemical", 1 * (ScrW() / 1920), 29 * (ScrH() / 1080))
	self.shockBar = CreateResistanceBar(self.ResistancesImage, resImage, "Shock", 1 * (ScrW() / 1920), 57 * (ScrH() / 1080))
	self.burnBar = CreateResistanceBar(self.ResistancesImage, resImage, "Burn", 1 * (ScrW() / 1920), 85 * (ScrH() / 1080))
	self.psiBar = CreateResistanceBar(self.ResistancesImage, resImage, "Psi", 160 * (ScrW() / 1920), 1 * (ScrH() / 1080))
	self.slashBar = CreateResistanceBar(self.ResistancesImage, resImage, "Slash", 160 * (ScrW() / 1920), 29 * (ScrH() / 1080))
	self.fallBar = CreateResistanceBar(self.ResistancesImage, resImage, "Fall", 160 * (ScrW() / 1920), 57 * (ScrH() / 1080))

	-- Playermodel Panel
	self.modelpanelframe = self:Add("DImage")
	self.modelpanelframe:SetSize(371 * (ScrW() / 1920), 768 * (ScrH() / 1080))
	self.modelpanelframe:SetMaterial(Material("cotz/panels/loot_interface.png"))
	self.modelpanelframe:SetPos(0 * (ScrW() / 1920), 77 * (ScrH() / 1080))

	-- modelpanel
	self.modelpanel = self.modelpanelframe:Add("ixPlayerModelPanel")	-- Check cl_modelpanel for camera pos etc.
	self.modelpanel.Entity = LocalPlayer()
	self.modelpanel.OnRemove = nil
	self.modelpanel:Dock(FILL)

end

function PANEL:Update()
	-- money update
	self.money:SetText(ix.currency.Get(LocalPlayer():GetCharacter():GetMoney()))

	-- weight update
	local isImperial = ix.option.Get("imperial", false) -- Get the user's preference for units
	if LocalPlayer():GetChar() == nil then return end
	local character = LocalPlayer():GetChar()
	local weight = character:GetData("Weight", 0)
	local maxweight = character:GetData("MaxWeight", 30)
	local weightString = ix.weight.WeightString(weight, isImperial) -- Format the weight string
	local maxWeightValue = ix.config.Get("maxWeight", 30)
	local maxOverWeightValue = ix.config.Get("maxOverWeight", 20)
	local carrybuff = LocalPlayer():GetChar():GetData("WeightBuffCur") or 0
	local totalMaxWeight = maxWeightValue + maxOverWeightValue + carrybuff
	local maxWeightString = ix.weight.WeightString(totalMaxWeight, isImperial) -- Format the total max weight string	
	self.weight:SetText(weightString .. " of " .. maxWeightString)

	-- avatar update
	if LocalPlayer():GetCharacter():GetData("pdaavatar") then 
		self.charbackgroundicon:SetImage( LocalPlayer():GetCharacter():GetData("pdaavatar") )
	else
		self.charbackgroundicon:SetImage( "vgui/icons/face_31.png" )
	end
end

function PANEL:Think()
	if self.thinkdelay < CurTime() then
		self:Update()
		self.thinkdelay = CurTime() + 0.1
	end
end

function PANEL:Paint(w, h)
	return
end

vgui.Register("ixStalkerInventoryPanel", PANEL, "DFrame")