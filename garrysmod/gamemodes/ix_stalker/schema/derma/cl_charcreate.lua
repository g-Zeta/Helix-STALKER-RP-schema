local padding = ScreenScale(32)

local BASE_W, BASE_H = 1920, 1080
local function UIScale()
  -- uniform scale, using the minimum axis to avoid stretch
  return math.min(ScrW() / BASE_W, ScrH() / BASE_H)
end

local function SW(x) return math.floor(x * UIScale() + 0.5) end
local function SH(y) return math.floor(y * UIScale() + 0.5) end

-- Shared cache for materials
local MAT_CACHE = MAT_CACHE or {}
local function GetMat(pathOrMat)
    if not pathOrMat then return nil end
    if not isstring(pathOrMat) then return pathOrMat end
    MAT_CACHE[pathOrMat] = MAT_CACHE[pathOrMat] or Material(pathOrMat, "smooth")
    return MAT_CACHE[pathOrMat]
end

local function IsSingleCap(def)
    if not def then return false end
    if def.isArmor then return true end
    if def.isHelmet or def.isGasmask then return true end
    local wc = def.weaponCategory
    return wc == "primary" or wc == "secondary" or wc == "sidearm" or wc == "artifactdetector"
end

local function GetPrice(def)
    return tonumber(def and def.price) or 0
end

-- create character panel
DEFINE_BASECLASS("ixCharMenuPanel")
local PANEL = {}

function PANEL:Init()
	local parent = self:GetParent()
	local halfWidth = parent:GetWide() * 0.5 - (padding * 2)
	local halfHeight = parent:GetTall() * 0.5 - (padding * 2)
	local modelFOV = (ScrW() > ScrH() * 1.8) and 100 or 78

	self:ResetPayload(true)

	self.factionButtons = {}
	self.repopulatePanels = {}

	-- Faction Selection subpanel
	self.factionPanel = self:AddSubpanel("faction", true)
	self.factionPanel:SetTitle("chooseFaction")
	self.factionPanel.title:SetContentAlignment(5)

	local bottomButtons = self.factionPanel:Add("Panel")
	bottomButtons:Dock(BOTTOM)

	local factionBack = bottomButtons:Add("ixMenuButton")
	factionBack:SetText("return")
	factionBack:SetContentAlignment(4)
	factionBack:Dock(LEFT)
	factionBack:SizeToContents()
	factionBack:SetBackgroundColor(ix.config.Get("color"))
	factionBack:SetGradientDirection("l")
	factionBack.DoClick = function()
		self.progress:DecrementProgress()
		self:SetActiveSubpanel("faction", 0)
		self:SlideDown()
		parent.mainPanel:Undim()
	end

	bottomButtons:SetTall(factionBack:GetTall())

	self.proceedButton = bottomButtons:Add("ixMenuButton")
	self.proceedButton:SetText("proceed")
	self.proceedButton:SetContentAlignment(6)
	self.proceedButton:Dock(RIGHT)
	self.proceedButton:SizeToContents()
	self.proceedButton:SetBackgroundColor(ix.config.Get("color"))
	self.proceedButton:SetGradientDirection("r")
	self.proceedButton:SetEnabled(false)
	self.proceedButton:SetVisible(false)
	self.proceedButton.DoClick = function()
		if not self.payload.faction then
			self:GetParent():ShowNotice(3, L("Please select a faction first."))
        	return
    	end

		self.progress:IncrementProgress()
		self:Populate()
		self:SetActiveSubpanel("profile")
	end

	self.factionButtonsPanel = self.factionPanel:Add("DIconLayout")
	self.factionButtonsPanel:Dock(LEFT)
	self.factionButtonsPanel:SetWide(halfWidth / 1.5)
	self.factionButtonsPanel:SetSpaceX(8)
	self.factionButtonsPanel:SetSpaceY(8)
	self.factionButtonsPanel:DockMargin(8, 8, 8, 8)

	self.factionInfoPanel = self.factionPanel:Add("Panel")
	self.factionInfoPanel:Dock(RIGHT)
	self.factionInfoPanel:SetWide(halfWidth / 1.5)

	self.factionModel = self.factionPanel:Add("ixModelPanel")
	self.factionModel:Dock(FILL)
	self.factionModel:SetModel("models/error.mdl")
	self.factionModel:SetFOV(modelFOV - 13)
	self.factionModel.PaintModel = self.factionModel.Paint
	self.factionModel:SetVisible(false)

	-- Character Profile subpanel
	self.profilePanel = self:AddSubpanel("profile")
	self.profilePanel:SetTitle("chooseDescription")
	self.profilePanel.title:SetContentAlignment(5)

	local bottomprofButtons = self.profilePanel:Add("Panel")
	bottomprofButtons:Dock(BOTTOM)

	local profileModelList = self.profilePanel:Add("Panel")
	profileModelList:Dock(LEFT)
	profileModelList:SetSize(halfWidth, halfHeight)

	local profileBack = bottomprofButtons:Add("ixMenuButton")
	profileBack:SetText("return")
	profileBack:SetContentAlignment(4)
	profileBack:SizeToContents()
	profileBack:SetBackgroundColor(ix.config.Get("color"))
	profileBack:SetGradientDirection("l")
	profileBack:Dock(LEFT)
	profileBack.DoClick = function()
		self.progress:DecrementProgress()

		if (#self.factionButtons == 1) then
			factionBack:DoClick()
		else
			self:SetActiveSubpanel("faction")
		end
	end

	bottomprofButtons:SetTall(profileBack:GetTall())

	self.profileModel = profileModelList:Add("ixModelPanel")
	self.profileModel:Dock(FILL)
	self.profileModel:SetFOV(modelFOV - 13)
	self.profileModel.PaintModel = self.profileModel.Paint
	self.profileModel:SetVisible(false)

	self.profileVarsPanel = self.profilePanel:Add("Panel")
	self.profileVarsPanel:SetWide(halfWidth + padding * 2)
	self.profileVarsPanel:Dock(RIGHT)

	self.profileProceed = bottomprofButtons:Add("ixMenuButton")
	self.profileProceed:SetText("proceed")
	self.profileProceed:SetContentAlignment(6)
	self.profileProceed:SizeToContents()
	self.profileProceed:SetBackgroundColor(ix.config.Get("color"))
	self.profileProceed:SetGradientDirection("r")
	self.profileProceed:Dock(RIGHT)
	self.profileProceed:SetVisible(false)
	self.profileProceed.DoClick = function()
		if (self:VerifyProgression("profile")) then
			-- there are no panels on the attributes section other than the create button, so we can just create the character
			if (#self.attributesPanel:GetChildren() < 2) then
				self:SendPayload()
				return
			end

			self.progress:IncrementProgress()
			self:SetActiveSubpanel("loadout")
		end
	end

	-- Loadout subpanel
	self.loadout = self:AddSubpanel("loadout")
	self.loadout:SetTitle("chooseLoadout")
	self.loadout.title:SetContentAlignment(5)

	local bottomloadoutButtons = self.loadout:Add("Panel")
	bottomloadoutButtons:Dock(BOTTOM)
	
	local loadoutModelList = self.loadout:Add("Panel")
	loadoutModelList:Dock(LEFT)
	loadoutModelList:SetSize(halfWidth, halfHeight)

	self.loadoutModel = loadoutModelList:Add("ixModelPanel")
	self.loadoutModel:Dock(FILL)
	self.loadoutModel:SetFOV(modelFOV - 13)
	self.loadoutModel.PaintModel = self.loadoutModel.Paint
	self.loadoutModel:SetVisible(false)

	local loadoutBack = bottomloadoutButtons:Add("ixMenuButton")
	loadoutBack:SetText("return")
	loadoutBack:SetContentAlignment(4)
	loadoutBack:SizeToContents()
	loadoutBack:SetBackgroundColor(ix.config.Get("color"))
	loadoutBack:SetGradientDirection("l")
	loadoutBack:Dock(LEFT)
	loadoutBack.DoClick = function()
		self.progress:DecrementProgress()
		self:SetActiveSubpanel("profile")
	end

	bottomloadoutButtons:SetTall(loadoutBack:GetTall())

	self.loadoutPanel = self.loadout:Add("Panel")
	self.loadoutPanel:SetWide(halfWidth + padding * 2)
	self.loadoutPanel:Dock(RIGHT)

	local loadoutSubPanel = self.loadoutPanel:Add("Panel")
	loadoutSubPanel:Dock(FILL)

    -- Budget label
    self.loadoutBudgetLabel = loadoutSubPanel:Add("DLabel")
    self.loadoutBudgetLabel:SetFont("stalkerregularboldfont")
    self.loadoutBudgetLabel:SetText(("Budget: %s %s / %s %s"):format(self.currencySym or (ix.currency and ix.currency.symbol), self.loadoutCost or 0, self.currencySym or (ix.currency and ix.currency.symbol), self.loadoutBudget or ix.config.Get("characterCreationBudget", 50000) or 0))
    self.loadoutBudgetLabel:Dock(TOP)
    self.loadoutBudgetLabel:DockMargin(8, 8, 8, 4)
    self.loadoutBudgetLabel:SizeToContents()

    local loadoutSelected = loadoutSubPanel:Add("DPanel")
    loadoutSelected:Dock(LEFT)
    loadoutSelected:SetWide(SW(315))

	function loadoutSelected:Paint(w, h)
		RNDX.Draw(8, 0, 0, w, h, nil, RNDX.BLUR)
		RNDX.Draw(8, 0, 0, w, h, Color(20, 20, 20, 100))
	end
	
    -- Selected list
    local selectedScroll = loadoutSelected:Add("DScrollPanel")
	self.selectedScroll = loadoutSelected

	local loadoutShop = loadoutSubPanel:Add("DPanel")
	loadoutShop:Dock(RIGHT)
	loadoutShop:SetWide(SW(605))
	self.loadoutShopPanel = loadoutShop

	function loadoutShop:Paint(w, h)
		RNDX.Draw(8, 0, 0, w, h, nil, RNDX.BLUR)
		RNDX.Draw(8, 0, 0, w, h, Color(20, 20, 20, 100))
	end

	-- Loadout Shop list
	self:BuildLoadoutShopGrid(loadoutShop)

	local loadoutProceed = bottomloadoutButtons:Add("ixMenuButton")
	loadoutProceed:SetText("proceed")
	loadoutProceed:SetContentAlignment(6)
	loadoutProceed:SizeToContents()
	loadoutProceed:SetBackgroundColor(ix.config.Get("color"))
	loadoutProceed:SetGradientDirection("r")
	loadoutProceed:Dock(RIGHT)
    loadoutProceed.DoClick = function()
        self.progress:IncrementProgress()
        self:SetActiveSubpanel("attributes")
    end

	-- attributes subpanel
	self.attributes = self:AddSubpanel("attributes")
	self.attributes:SetTitle("chooseSkills")
	self.attributes.title:SetContentAlignment(5)

	local bottomattributesButtons = self.attributes:Add("Panel")
	bottomattributesButtons:Dock(BOTTOM)
	
	local attributesModelList = self.attributes:Add("Panel")
	attributesModelList:Dock(LEFT)
	attributesModelList:SetSize(halfWidth, halfHeight)

	local attributesBack = bottomattributesButtons:Add("ixMenuButton")
	attributesBack:SetText("return")
	attributesBack:SetContentAlignment(4)
	attributesBack:SizeToContents()
	attributesBack:SetBackgroundColor(ix.config.Get("color"))
	attributesBack:SetGradientDirection("l")
	attributesBack:Dock(LEFT)
	attributesBack.DoClick = function()
		self.progress:DecrementProgress()
		self:SetActiveSubpanel("loadout")
	end

	bottomattributesButtons:SetTall(attributesBack:GetTall())
	
	self.attributesModel = attributesModelList:Add("ixModelPanel")
	self.attributesModel:Dock(FILL)
	self.attributesModel:SetFOV(modelFOV - 13)
	self.attributesModel.PaintModel = self.attributesModel.Paint
	self.attributesModel:SetVisible(false)

	self.attributesPanel = self.attributes:Add("Panel")
	self.attributesPanel:SetWide(halfWidth + padding * 2)
	self.attributesPanel:Dock(RIGHT)

	local create = bottomattributesButtons:Add("ixMenuButton")
	create:SetText("finish")
	create:SetContentAlignment(6)
	create:SizeToContents()
	create:SetBackgroundColor(ix.config.Get("color"))
	create:SetGradientDirection("r")
	create:Dock(RIGHT)
	create.DoClick = function()
		self:SendPayload()
	end

	-- creation progress panel
	self.progress = self:Add("ixSegmentedProgress")
	self.progress:SetBarColor(ix.config.Get("color"))
	self.progress:SetSize(parent:GetWide(), 0)
	self.progress:SizeToContents()
	self.progress:SetPos(0, parent:GetTall() - self.progress:GetTall())

	-- setup payload hooks
	self:AddPayloadHook("model", function(value)
		local facIndex = self.payload and self.payload.faction
		if not facIndex then return end

		local faction = ix.faction.indices[facIndex]
		if not faction or not faction.GetModels then return end

		local models = faction:GetModels(LocalPlayer())
		if not istable(models) or #models < 1 then return end

		local model = models[value]
		if not model then return end

		-- assuming bodygroups
		if istable(model) then
			self.factionModel:SetModel(model[1], model[2] or 0, model[3])
			self.profileModel:SetModel(model[1], model[2] or 0, model[3])
			self.loadoutModel:SetModel(model[1], model[2] or 0, model[3])
			self.attributesModel:SetModel(model[1], model[2] or 0, model[3])
		else
			self.factionModel:SetModel(model)
			self.profileModel:SetModel(model)
			self.loadoutModel:SetModel(model)
			self.attributesModel:SetModel(model)
		end
	
		-- Reveal the models now that we have a valid selection
		if IsValid(self.factionModel) then self.factionModel:SetVisible(true) end
		if IsValid(self.profileModel) then self.profileModel:SetVisible(true) end
		if IsValid(self.loadoutModel) then self.loadoutModel:SetVisible(true) end
		if IsValid(self.attributesModel) then self.attributesModel:SetVisible(true) end	
	end)

	-- setup character creation hooks
	net.Receive("ixCharacterAuthed", function()
		timer.Remove("ixCharacterCreateTimeout")
		self.awaitingResponse = false

		local id = net.ReadUInt(32)
		local indices = net.ReadUInt(6)
		local charList = {}

		for _ = 1, indices do
			charList[#charList + 1] = net.ReadUInt(32)
		end

		ix.characters = charList

		self:SlideDown()

		if (!IsValid(self) or !IsValid(parent)) then
			return
		end

		if (LocalPlayer():GetCharacter()) then
			parent.mainPanel:Undim()
			parent:ShowNotice(2, L("charCreated"))
		elseif (id) then
			self.bMenuShouldClose = true

			net.Start("ixCharacterChoose")
				net.WriteUInt(id, 32)
			net.SendToServer()
		else
			self:SlideDown()
		end
	end)

	net.Receive("ixCharacterAuthFailed", function()
		timer.Remove("ixCharacterCreateTimeout")
		self.awaitingResponse = false

		local fault = net.ReadString()
		local args = net.ReadTable()

		self:SlideDown()

		parent.mainPanel:Undim()
		parent:ShowNotice(3, L(fault, unpack(args)))
	end)
end

function PANEL:SendPayload()
	if (self.awaitingResponse or !self:VerifyProgression()) then
		return
	end

	self.awaitingResponse = true

	timer.Create("ixCharacterCreateTimeout", 10, 1, function()
		if (IsValid(self) and self.awaitingResponse) then
			local parent = self:GetParent()

			self.awaitingResponse = false
			self:SlideDown()

			parent.mainPanel:Undim()
			parent:ShowNotice(3, L("unknownError"))
		end
	end)

	-- include selected loadout in payload
	if self.loadoutSelection and next(self.loadoutSelection) then
		-- send a plain table: { [uniqueID] = count }
		self.payload:Set("loadoutSelection", table.Copy(self.loadoutSelection))
	end
	
	self.payload:Prepare()

	net.Start("ixCharacterCreate")
	net.WriteUInt(table.Count(self.payload), 8)

	for k, v in pairs(self.payload) do
		net.WriteString(k)
		net.WriteType(v)
	end

	net.SendToServer()
end

function PANEL:OnSlideUp()
	self:ResetPayload()

	-- Deselect all faction buttons and reset their state.
	if (self.factionButtons) then
		for _, v in ipairs(self.factionButtons) do
			if (IsValid(v)) then
				v.Selected = false
				v.TargetScale = 0.90 -- Reset scale to default.
			end
		end
	end

	-- Hide the proceed button and clear the faction info panel.
	if (IsValid(self.proceedButton)) then
		self.proceedButton:SetEnabled(false)
		self.proceedButton:SetVisible(false)
	end
	self.factionInfoPanel:Clear()
	-- Also hide the model panel until a new faction is selected.
	if (IsValid(self.factionModel)) then
		self.factionModel:SetVisible(false)
	end

	self:Populate()
	self.progress:SetProgress(1)

	-- the faction subpanel will skip to next subpanel if there is only one faction to choose from,
	-- so we don't have to worry about it here
	self:SetActiveSubpanel("faction", 0)
end

function PANEL:OnSlideDown()
end

function PANEL:ResetPayload(bWithHooks)
	if (bWithHooks) then
		self.hooks = {}
	end

	self.payload = {}

	-- TODO: eh..
	function self.payload.Set(payload, key, value)
		self:SetPayload(key, value)
	end

	function self.payload.AddHook(payload, key, callback)
		self:AddPayloadHook(key, callback)
	end

	function self.payload.Prepare(payload)
		self.payload.Set = nil
		self.payload.AddHook = nil
		self.payload.Prepare = nil
	end
end

function PANEL:SetPayload(key, value)
	self.payload[key] = value
	self:RunPayloadHook(key, value)

	if (IsValid(self.profileProceed)) then
		self.profileProceed:SetVisible(self:VerifyProgression("profile", true))
	end
end

function PANEL:AddPayloadHook(key, callback)
	if (!self.hooks[key]) then
		self.hooks[key] = {}
	end

	self.hooks[key][#self.hooks[key] + 1] = callback
end

function PANEL:RunPayloadHook(key, value)
	local hooks = self.hooks[key] or {}

	for _, v in ipairs(hooks) do
		v(value)
	end
end

function PANEL:GetContainerPanel(name)
	-- TODO: yuck
	if (name == "profile") then
		return self.profileVarsPanel
	elseif (name == "attributes") then
		return self.attributesPanel
	end

	return self.profileVarsPanel
end

function PANEL:AttachCleanup(panel)
	self.repopulatePanels[#self.repopulatePanels + 1] = panel
end

function PANEL:UpdateCharPanels()
	-- remove panels created for character vars
	for i = 1, #self.repopulatePanels do
		self.repopulatePanels[i]:Remove()
	end

	self.repopulatePanels = {}

	local zPos = 1

	-- set up character vars
	for k, v in SortedPairsByMemberValue(ix.char.vars, "index") do
		if (!v.bNoDisplay and k != "__SortedIndex") then
			local container = self:GetContainerPanel(v.category or "profile")

			local shouldDisplay = true

			-- Skip non-profile until faction chosen
			local function HasFaction(payload)
				local idx = payload and payload.faction
				return idx ~= nil and ix.faction and ix.faction.indices and ix.faction.indices[idx] ~= nil
			end

			local isProfileLike = (v.category == "profile" or v.category == nil or v.category == "description")

			if not isProfileLike and not HasFaction(self.payload) then
				shouldDisplay = false
			else
				if v.ShouldDisplay then
					local ok, res = pcall(function()
						return v:ShouldDisplay(container, self.payload)
					end)
					if ok then
						if res == false then
							shouldDisplay = false
						end
					else
						-- Prevent hard crash if ShouldDisplay assumes faction
						shouldDisplay = false
					end
				end
			end

			if (shouldDisplay) then
				local panel

				if (v.OnDisplay) then
					panel = v:OnDisplay(container, self.payload)
				elseif (isstring(v.default)) then
					panel = container:Add("ixTextEntry")
					panel:Dock(TOP)
					panel:SetFont("ixMenuButtonHugeFont")
					panel:SetUpdateOnType(true)
					panel.OnValueChange = function(this, text)
						self.payload:Set(k, text)
					end
				end

				if (IsValid(panel)) then
					local label = container:Add("DLabel")
					label:SetFont("ixMenuButtonLabelFont")
					label:SetText(L(k):utf8upper())
					label:SizeToContents()
					label:DockMargin(0, 16, 0, 2)
					label:Dock(TOP)

					label:SetZPos(zPos - 1)
					panel:SetZPos(zPos)

					self:AttachCleanup(label)
					self:AttachCleanup(panel)

					if (v.OnPostSetup) then
						-- Protect against schema vars that still assume faction
						pcall(function()
							v:OnPostSetup(panel, self.payload)
						end)
					end

					zPos = zPos + 2
				end
			end
		end
	end
end

local function GetFactionPatchPath(factionIndex)
	local fac = ix.faction.GetByID and ix.faction.GetByID(factionIndex) or ix.faction.indices[factionIndex]
	if fac and fac.patch and fac.patch ~= "" then
		return fac.patch
	end
	return "placeholders/patch_nofaction.png" -- default patch
end

function PANEL:Populate()
	if (!self.bInitialPopulate) then
		-- setup buttons for the faction panel
		-- TODO: make this a bit less janky
		local lastSelected

		for _, v in pairs(self.factionButtons) do
			if (v:GetSelected()) then
				lastSelected = v.faction
			end

			if (IsValid(v)) then
				v:Remove()
			end
		end

		self.factionButtons = {}

		for _, v in SortedPairs(ix.faction.teams) do
			-- tile container
			local tile = self.factionButtonsPanel:Add("DButton")
			tile:SetText("")
			tile:SetSize(SW(140), SH(140))
			tile:SetCursor("hand")
			tile.faction = v.index
			tile.Selected = false
			tile.IsAllowed = ix.faction.HasWhitelist(v.index) == true

			-- size animation state
			tile.Scale = 0.90        -- current scale
			tile.TargetScale = 0.90  -- target scale
			tile.ScaleSpeed = 20    -- how fast to lerp towards target
			tile.HoverScale = 1.015  -- subtle hover scale for allowed tiles

			function tile:Think()
				-- update target on hover (only if allowed)
				if self.IsAllowed then
					if self.Hovered and not self.Selected then
						self.TargetScale = self.HoverScale
					elseif not self.Selected then
						self.TargetScale = 0.90
					end
				else
					self.TargetScale = 0.90
				end

				-- smooth scale towards target
				self.Scale = Lerp(FrameTime() * self.ScaleSpeed, self.Scale, self.TargetScale)
			end

			-- rounded background + selection outline
			function tile:Paint(w, h)
				local bg = self.Hovered and Color(80, 80, 80, 100) or Color(30, 30, 30, 0)
				draw.RoundedBox(8, 0, 0, w, h, bg)
			end

			-- image
			local img = tile:Add("DImage")
			img:SetSize(SW(125), SH(125))
			img:Center()
			img:SetKeepAspect(true)

			local patchPath = GetFactionPatchPath(v.index)
			local patchMat = patchPath and Material(patchPath, "smooth") or nil

			tile.IconMaterial = patchMat
			img:SetMaterial(patchMat)

			function img:Paint(w, h)
				local mat = tile.IconMaterial
				if (not mat) then return end

				-- compute base rect (keep aspect)
				local tw, th = mat:Width(), mat:Height()
				if (tw <= 0 or th <= 0) then
					tw, th = w, h
				end
				local baseScale = math.min(w / tw, h / th)
				local rw, rh = math.floor(tw * baseScale), math.floor(th * baseScale)

				-- apply tile scale animation
				local s = tile.Scale or 1.0
				rw = math.floor(rw * s)
				rh = math.floor(rh * s)

				local rx = math.floor((w - rw) * 0.5)
				local ry = math.floor((h - rh) * 0.5)

				surface.SetMaterial(mat)

				if (tile.IsAllowed) then
					-- draw normally
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRect(rx, ry, rw, rh)
				else
					-- tone down faction image's colors if not whitelisted
					surface.SetDrawColor(120, 120, 120, 120)
					surface.DrawTexturedRect(rx, ry, rw, rh)
				end
			end

			-- emulate selection group
			table.insert(self.factionButtons, tile)

			-- selection behavior
			local function selectTile(panel)
				-- clear selection in group
				for _, b in ipairs(self.factionButtons) do
					if (IsValid(b)) then
						b.Selected = false
						-- reset target scale on others
						b.TargetScale = 1.0
					end
				end
				panel.Selected = true

				-- click "pop" effect: quickly scale up, then ease back to 1
				if panel.IsAllowed then
					panel.TargetScale = 0.85
					-- schedule easing back down after a short delay
					timer.Simple(0.02, function()
						if IsValid(panel) then
							panel.TargetScale = 1.0
						end
					end)
					-- Play sound once on selection
					LocalPlayer():EmitSound("STALKER.Press.MainMenu")
				end

				local faction = ix.faction.indices[panel.faction]
				if not faction then return end

				local models = faction:GetModels(LocalPlayer()) or {}
				if #models < 1 then
					self.payload:Set("faction", panel.faction)
					-- no models to set; keep placeholders
					return
				end

				self.payload:Set("faction", panel.faction)
				self.payload:Set("model", math.random(1, #models))
				
				self:UpdateCharPanels()

				if IsValid(self.proceedButton) then
					self.proceedButton:SetEnabled(true)
					self.proceedButton:SetVisible(true)
				end

				self.factionInfoPanel:Clear()

				if (faction.name) then
					local name = self.factionInfoPanel:Add("DLabel")
					name:SetFont("stalkertitlefont")
					name:SetText(L(faction.name):utf8upper())
					name:SetTextColor(faction.color or color_white)
					name:SizeToContents()
					name:Dock(TOP)
					name:DockMargin(0, 0, 0, 8)
				end

				if (faction.description) then
					local description = self.factionInfoPanel:Add("DLabel")
					description:SetFont("stalkerregularfont2")
					description:SetText(L(faction.description))
					description:SetWrap(true)
					description:SetAutoStretchVertical(true)
					description:Dock(TOP)
					description:DockMargin(0, 0, 0, 8)

					if (string.len(faction.description) < 1) then
						description:SetText(ix.chat.Format(L("noDesc")))
					end
				end
			end

			tile.DoClick = function(panel)
				if (not panel.IsAllowed) then
					surface.PlaySound("buttons/combine_button2.wav")
					self:GetParent():ShowNotice(3, L("You are not whitelisted for this faction."))
					return
				end

				selectTile(panel)
			end

			-- Play sound when hovering a faction tile
			function tile:OnCursorEntered()
				-- Only play for allowed/interactive tiles
				if self.IsAllowed then
					LocalPlayer():EmitSound("STALKER.Rollover.MainMenu")
				end
			end
		end
	end

	self:UpdateCharPanels()

	if (!self.bInitialPopulate) then
		-- setup progress bar segments
		if (#self.factionButtons > 1) then
			self.progress:AddSegment("@faction")
		end

		self.progress:AddSegment("@profile")

		self.progress:AddSegment("@loadout")

		if (#self.attributesPanel:GetChildren() > 1) then
			self.progress:AddSegment("@skills")
		end

		-- we don't need to show the progress bar if there's only one segment
		if (#self.progress:GetSegments() == 1) then
			self.progress:SetVisible(false)
		end
	end

	self.bInitialPopulate = true
end

function PANEL:VerifyProgression(name, bSilent)
	for k, v in SortedPairsByMemberValue(ix.char.vars, "index") do
		if (name ~= nil and (v.category or "profile") != name) then
			continue
		end

		local value = self.payload[k]

		if (!v.bNoDisplay or v.OnValidate) then
			if (v.OnValidate) then
				local result = {v:OnValidate(value, self.payload, LocalPlayer())} -- This needs to be wrapped in a table for unpack to work with multiple returns

				if (result[1] == false) then
					if (not bSilent) then
						self:GetParent():ShowNotice(3, L(unpack(result, 2)))
					end

					return false
				end
			end

			self.payload[k] = value
		end
	end

	return true
end

function PANEL:Paint(width, height)
	derma.SkinFunc("PaintCharacterCreateBackground", self, width, height)
	BaseClass.Paint(self, width, height)
end

------ LOADOUT SYSTEM RELATED ↓↓↓ ------

-- Count helpers to enforce category limits (uses self.loadoutLimits)
function PANEL:CanAddItem(def)
    if not def then return false end
    local price = GetPrice(def)
    if price <= 0 then return false end
    if (self.loadoutCost + price) > self.loadoutBudget then return false end

	local function CountWhere(sel, pred)
		local n = 0
		for uid, c in pairs(sel or {}) do
			if c > 0 then
				local d = ix.item.list[uid]
				if d and pred(d) then n = n + c end
			end
		end
		return n
	end

    -- Limits
    local L = self.loadoutLimits or {}
    local sel = self.loadoutSelection or {}

    if def.isArmor then
        if CountWhere(sel, function(d) return d.isArmor end) >= (L.armor or 1) then
			return false
		end
    end

    if def.isHelmet or def.isGasmask then
        if CountWhere(sel, function(d) return d.isHelmet or d.isGasmask end) >= (L.helmetOrGasmask or 1) then
            return false
        end
    end

    local wc = def.weaponCategory
    if wc == "primary" then
        if CountWhere(sel, function(d) return d.weaponCategory == "primary" end) >= (L.primary or 1) then
			return false
		end
    elseif wc == "secondary" then
        if CountWhere(sel, function(d) return d.weaponCategory == "secondary" end) >= (L.secondary or 1) then
			return false
		end
    elseif wc == "sidearm" then
        if CountWhere(sel, function(d) return d.weaponCategory == "sidearm" end) >= (L.sidearm or 1) then
			return false
		end
    elseif wc == "artifactdetector" then
        if CountWhere(sel, function(d) return d.weaponCategory == "artifactdetector" end) >= (L.artifactdetector or 1) then
            return false
        end
    end

    return true
end

function PANEL:AddItem(uniqueID)
	local def = ix.item.list[uniqueID]
	if not def then return end
	if not self:CanAddItem(def) then
		surface.PlaySound("buttons/combine_button2.wav")
		return
	end

	local price = GetPrice(def)
	self.loadoutSelection[uniqueID] = (self.loadoutSelection[uniqueID] or 0) + 1
	self.loadoutCost = (self.loadoutCost or 0) + price
	LocalPlayer():EmitSound("STALKER.Press.MainMenu")

	-- incremental updates only
	self:RefreshSelectedTiles()
	self:RefreshShopTiles()
	self:UpdateBudgetLabel()
end

function PANEL:RemoveItem(uniqueID)
	local def = ix.item.list[uniqueID]
	if not def then return end
	local count = (self.loadoutSelection[uniqueID] or 0)
	if count <= 0 then return end

	local price = GetPrice(def)
	self.loadoutSelection[uniqueID] = math.max(0, count - 1)
	self.loadoutCost = math.max(0, (self.loadoutCost or 0) - price)
	LocalPlayer():EmitSound("STALKER.Press.MainMenu")

	-- incremental updates only
	self:RefreshSelectedTiles()
	self:RefreshShopTiles()
	self:UpdateBudgetLabel()
end

-- Update Budget
function PANEL:UpdateBudgetLabel()
    if not IsValid(self.loadoutBudgetLabel) then return end
    local sym = self.currencySym or (ix.currency and ix.currency.symbol) or "₽"
    local cost = self.loadoutCost or 0
    local budget = self.loadoutBudget
    self.loadoutBudgetLabel:SetText(("Budget: %s %s / %s %s"):format(sym, cost, sym, budget))
    self.loadoutBudgetLabel:SizeToContents()
end

function PANEL:RefreshShopTiles()
    if not self._shopTiles then return end
    for uid, tile in pairs(self._shopTiles) do
        local def = ix.item.list[uid]
        if not def or not IsValid(tile) then
            if IsValid(tile) then tile:Remove() end
            self._shopTiles[uid] = nil
        else
            -- hide single-cap items that are already selected
            local hide = IsSingleCap(def) and (self.loadoutSelection[uid] or 0) > 0
            tile:SetVisible(not hide)
        end
    end
    if IsValid(self._shopLayout) then self._shopLayout:InvalidateLayout(true) end
end

function PANEL:RefreshSelectedTiles()
    if not IsValid(self._selLayout) then return end
    local sel = self.loadoutSelection or {}

    -- create/update tiles that should exist
    for uid, count in pairs(sel) do
        if count > 0 then
            local def = ix.item.list[uid]
            if def then
                local tile = self._selTiles[uid]
                if not IsValid(tile) then
                    local mat = GetMat(def.img or "placeholders/patch_nofaction.png")
                    if mat and not mat:IsError() then
                        tile = self._selLayout:Add("DButton")
                        tile:SetText("")
                        tile:SetSize(SW(140), SH(155))
                        tile.UniqueID = uid
                        tile.Root = self

                        function tile:Paint(w, h)
                            draw.RoundedBox(8, 0, 0, w, h, Color(26, 26, 26, 200))
                            if self.Hovered then
                                draw.RoundedBox(8, 0, 0, w, h, Color(100, 100, 100, 100))
                            end
                        end
                        function tile:OnCursorEntered()
                            LocalPlayer():EmitSound("STALKER.Rollover.MainMenu")
                        end

                        local img = tile:Add("DImage")
                        img:SetMaterial(mat)
                        img:SetSize(SW(125), SH(125))
                        img:SetKeepAspect(true)
                        img:CenterHorizontal()
                        img:SetPos(img:GetX(), 5)

						function img:Paint(w, h)
							local mat = self.m_Material
							if not mat then return end

							local tw, th = mat:Width(), mat:Height()
							if tw <= 0 or th <= 0 then tw, th = w, h end

							local scale = math.min(w / tw, h / th)
							local rw, rh = math.floor(tw * scale), math.floor(th * scale)
							local rx = math.floor((w - rw) * 0.5)
							local ry = math.floor((h - rh) * 0.5)

							surface.SetMaterial(mat)
							surface.SetDrawColor(255, 255, 255, 255)
							surface.DrawTexturedRect(rx, ry, rw, rh)
						end
						
						-- Tooltip
						local itemDef = ix.item.list[uid]
						if itemDef then
							img:SetHelixTooltip(function(tooltip)
								ix.hud.PopulateItemTooltip(tooltip, itemDef)
							end)
						end

                        local lbl = tile:Add("DLabel")
                        lbl:SetFont("stalkerregularsmallboldfont")
                        lbl:Dock(TOP)
                        lbl:DockMargin(8, SH(132), 8, 0)
                        lbl:SetContentAlignment(5)

                        function tile:SetCount(c)
                            lbl:SetText(("x%s"):format(c or 1))
                            lbl:SizeToContents()
                        end

                        function tile:DoClick()
                            local root = self.Root
                            if not IsValid(root) then return end
                            root:RemoveItem(self.UniqueID)         -- no full rebuild
                            root:RefreshSelectedTiles()
                            root:RefreshShopTiles()
                            root:UpdateBudgetLabel()
                        end

                        self._selTiles[uid] = tile
                    end
                end

                if IsValid(tile) then
                    tile:SetVisible(true)
                    if tile.SetCount then tile:SetCount(count) end
                end
            end
        end
    end

    -- remove tiles that no longer belong
    for uid, tile in pairs(self._selTiles) do
        if (not sel[uid]) or sel[uid] <= 0 then
            if IsValid(tile) then tile:Remove() end
            self._selTiles[uid] = nil
        end
    end

    self._selLayout:InvalidateLayout(true)
end

-- LOADOUT SHOP grid: build once and reuse tiles; respects category limits and cleans duplicate rebuilds
function PANEL:BuildLoadoutShopGrid(loadoutShop)
    if not IsValid(loadoutShop) then return end

    -- init config/state only once
    self.loadoutBudget = self.loadoutBudget or ix.config.Get("characterCreationBudget", 50000)
    self.currencySym   = self.currencySym   or (ix.currency and ix.currency.symbol) or "₽"
    self.loadoutSelection = self.loadoutSelection or {}
    self.loadoutCost = self.loadoutCost or 0

    -- Limits
    self.loadoutLimits = self.loadoutLimits or {
        armor = 1,
        helmetOrGasmask = 1,
        sidearm = 1,
        primary = 1,
        secondary = 1,
        artifactdetector = 1,
    }

    -- one-time UI creation
    if not IsValid(self._shopScroll) then
        loadoutShop:Clear()

        self._shopScroll = loadoutShop:Add("DScrollPanel")
        self._shopScroll:Dock(FILL)
        self._shopScroll:DockMargin(0, 15, 0, 15)

        self._shopLayout = self._shopScroll:Add("DIconLayout")
        self._shopLayout:Dock(TOP)
        self._shopLayout:SetSpaceX(5)
        self._shopLayout:SetSpaceY(5)
        self._shopLayout:DockMargin(15, 0, 0, 5)

        self._shopTiles = {}
    end

    -- Build tiles once (persist and only toggle visibility)
    local function allowInShop(def)
        if not def then return false end
        if def.isArmor or def.isHelmet or def.isGasmask or def.isAmmo then return true end
        if def.category == "Medical" then return true end
        local wc = def.weaponCategory
        return wc == "primary" or wc == "secondary" or wc == "sidearm" or wc == "artifactdetector"
    end

	-- Build stable, sorted order once (and reuse). Reset self._shopOrder = nil if items change at runtime.
	if not self._shopOrder then
		local tmp = {}
		for uid, d in pairs(ix.item.list or {}) do
			if istable(d) and d.flag == "1" and allowInShop(d) then
				tmp[#tmp + 1] = { uid = uid, name = d.name or uid }
			end
		end
		table.SortByMember(tmp, "name", true)
		self._shopOrder = tmp
	end

	-- Create tiles in alphabetical order
	for _, it in ipairs(self._shopOrder) do
		local uniqueID = it.uid
		local def = ix.item.list[uniqueID]
		if not (def and allowInShop(def)) then goto cont end

		if not IsValid(self._shopTiles[uniqueID]) then
			local mat = GetMat(def.img or "placeholders/patch_nofaction.png")
			if not mat or mat:IsError() then goto cont end

			local tile = self._shopLayout:Add("DButton")
			tile:SetText("")
			tile:SetSize(SW(140), SH(155))
			tile.UniqueID = uniqueID
			tile.Root = self

			function tile:Paint(w, h)
				draw.RoundedBox(8, 0, 0, w, h, Color(26, 26, 26, 200))
				if self.Hovered then
					draw.RoundedBox(8, 0, 0, w, h, Color(100, 100, 100, 100))
				end
			end
			function tile:OnCursorEntered()
				LocalPlayer():EmitSound("STALKER.Rollover.MainMenu")
			end

            local img = tile:Add("DImage")
            img:SetMaterial(mat)
            img:SetSize(SW(125), SH(125))
            img:SetKeepAspect(true)
            img:CenterHorizontal()
            img:SetPos(img:GetX(), 5)

			function img:Paint(w, h)
				local mat = self.m_Material
				if not mat then return end

				local tw, th = mat:Width(), mat:Height()
				if tw <= 0 or th <= 0 then tw, th = w, h end

				local scale = math.min(w / tw, h / th)
				local rw, rh = math.floor(tw * scale), math.floor(th * scale)
				local rx = math.floor((w - rw) * 0.5)
				local ry = math.floor((h - rh) * 0.5)

				surface.SetMaterial(mat)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(rx, ry, rw, rh)
			end
			
			-- Tooltip
			local itemDef = ix.item.list[uniqueID]
			if itemDef then
				img:SetHelixTooltip(function(tooltip)
					ix.hud.PopulateItemTooltip(tooltip, itemDef)
				end)
			end

            local lbl = tile:Add("DLabel")
            lbl:SetFont("stalkerregularsmallboldfont")
            lbl:SetText(def.name or uniqueID)
            lbl:Dock(TOP)
            lbl:DockMargin(8, SH(132), 8, 0)
            lbl:SetContentAlignment(5)
            lbl:SizeToContents()

            function tile:DoClick()
                local root = self.Root
                if not IsValid(root) then return end
                local d = ix.item.list[self.UniqueID]
                if not d then return end

                if IsSingleCap(d) then
                    -- toggle for single-cap
                    local current = (root.loadoutSelection[self.UniqueID] or 0)
                    if current > 0 then
                        root:RemoveItem(self.UniqueID)
                    else
                        root:AddItem(self.UniqueID)
                    end
                else
                    root:AddItem(self.UniqueID)
                end
            end

            self._shopTiles[uniqueID] = tile
        end
        ::cont::
    end

    -- final visibility refresh
    self:RefreshShopTiles()

    -- ensure selected panel exists/refreshes at least once
    if IsValid(self.selectedScroll) then
        self:BuildLoadoutSelectedGrid(self.selectedScroll)
    end
end

-- Selected grid: build once; update counts and add/remove tiles incrementally
function PANEL:BuildLoadoutSelectedGrid(container)
    if not IsValid(container) then return end

    if not IsValid(self._selScroll) then
        container:Clear()

        self._selScroll = container:Add("DScrollPanel")
        self._selScroll:Dock(FILL)
        self._selScroll:DockMargin(0, 15, 0, 15)

        self._selLayout = self._selScroll:Add("DIconLayout")
        self._selLayout:Dock(TOP)
        self._selLayout:SetSpaceX(5)
        self._selLayout:SetSpaceY(5)
        self._selLayout:DockMargin(15, 0, 0, 5)

        self._selTiles = {}
    end

    -- initial refresh and on subsequent calls
    self:RefreshSelectedTiles()
end

vgui.Register("ixCharMenuNew", PANEL, "ixCharMenuPanel")