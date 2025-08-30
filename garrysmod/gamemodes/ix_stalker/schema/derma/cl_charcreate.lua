
local padding = ScreenScale(32)

local BASE_W, BASE_H = 1920, 1080
local function UIScale()
  -- uniform scale, using the minimum axis to avoid stretch
  return math.min(ScrW() / BASE_W, ScrH() / BASE_H)
end

local function SW(x) return math.floor(x * UIScale() + 0.5) end
local function SH(y) return math.floor(y * UIScale() + 0.5) end

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

	-- faction selection subpanel
	self.factionPanel = self:AddSubpanel("faction", true)
	self.factionPanel:SetTitle("chooseFaction")
	self.factionPanel.title:SetContentAlignment(5)

	local bottomButtons = self.factionPanel:Add("Panel")
	bottomButtons:Dock(BOTTOM)

	local factionBack = bottomButtons:Add("ixMenuButton")
	factionBack:SetText("return")
	factionBack:SetContentAlignment(5)
	factionBack:Dock(LEFT)
	factionBack:SizeToContents()
	factionBack.DoClick = function()
		self.progress:DecrementProgress()

		self:SetActiveSubpanel("faction", 0)
		self:SlideDown()

		parent.mainPanel:Undim()
	end

	bottomButtons:SetTall(factionBack:GetTall())

	local proceed = bottomButtons:Add("ixMenuButton")
	proceed:SetText("proceed")
	proceed:SetContentAlignment(5)
	proceed:Dock(RIGHT)
	proceed:SizeToContents()
	proceed.DoClick = function()
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
	self.factionModel:SetFOV(modelFOV - 15)
	self.factionModel.PaintModel = self.factionModel.Paint

	-- character customization subpanel
	self.description = self:AddSubpanel("profile")
	self.description:SetTitle("chooseDescription")
	self.description.title:SetContentAlignment(5)

	local descriptionModelList = self.description:Add("Panel")
	descriptionModelList:Dock(LEFT)
	descriptionModelList:SetSize(halfWidth, halfHeight)

	local descriptionBack = descriptionModelList:Add("ixMenuButton")
	descriptionBack:SetText("return")
	descriptionBack:SetContentAlignment(4)
	descriptionBack:SizeToContents()
	descriptionBack:Dock(BOTTOM)
	descriptionBack.DoClick = function()
		self.progress:DecrementProgress()

		if (#self.factionButtons == 1) then
			factionBack:DoClick()
		else
			self:SetActiveSubpanel("faction")
		end
	end

	self.descriptionModel = descriptionModelList:Add("ixModelPanel")
	self.descriptionModel:Dock(FILL)
	self.descriptionModel:SetModel(self.factionModel:GetModel())
	self.descriptionModel:SetFOV(modelFOV - 13)
	self.descriptionModel.PaintModel = self.descriptionModel.Paint

	self.descriptionPanel = self.description:Add("Panel")
	self.descriptionPanel:SetWide(halfWidth + padding * 2)
	self.descriptionPanel:Dock(RIGHT)

	local descriptionProceed = self.descriptionPanel:Add("ixMenuButton")
	descriptionProceed:SetText("proceed")
	descriptionProceed:SetContentAlignment(6)
	descriptionProceed:SizeToContents()
	descriptionProceed:Dock(BOTTOM)
	descriptionProceed.DoClick = function()
		if (self:VerifyProgression("profile")) then
			-- there are no panels on the attributes section other than the create button, so we can just create the character
			if (#self.attributesPanel:GetChildren() < 2) then
				self:SendPayload()
				return
			end

			self.progress:IncrementProgress()
			self:SetActiveSubpanel("attributes")
		end
	end

	-- attributes subpanel
	self.attributes = self:AddSubpanel("attributes")
	self.attributes:SetTitle("chooseSkills")
	self.attributes.title:SetContentAlignment(5)

	local attributesModelList = self.attributes:Add("Panel")
	attributesModelList:Dock(LEFT)
	attributesModelList:SetSize(halfWidth, halfHeight)

	local attributesBack = attributesModelList:Add("ixMenuButton")
	attributesBack:SetText("return")
	attributesBack:SetContentAlignment(4)
	attributesBack:SizeToContents()
	attributesBack:Dock(BOTTOM)
	attributesBack.DoClick = function()
		self.progress:DecrementProgress()
		self:SetActiveSubpanel("profile")
	end

	self.attributesModel = attributesModelList:Add("ixModelPanel")
	self.attributesModel:Dock(FILL)
	self.attributesModel:SetModel(self.factionModel:GetModel())
	self.attributesModel:SetFOV(modelFOV - 13)
	self.attributesModel.PaintModel = self.attributesModel.Paint

	self.attributesPanel = self.attributes:Add("Panel")
	self.attributesPanel:SetWide(halfWidth + padding * 2)
	self.attributesPanel:Dock(RIGHT)

	local create = self.attributesPanel:Add("ixMenuButton")
	create:SetText("finish")
	create:SetContentAlignment(6)
	create:SizeToContents()
	create:Dock(BOTTOM)
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
		local faction = ix.faction.indices[self.payload.faction]

		if (faction) then
			local model = faction:GetModels(LocalPlayer())[value]

			-- assuming bodygroups
			if (istable(model)) then
				self.factionModel:SetModel(model[1], model[2] or 0, model[3])
				self.descriptionModel:SetModel(model[1], model[2] or 0, model[3])
				self.attributesModel:SetModel(model[1], model[2] or 0, model[3])
			else
				self.factionModel:SetModel(model)
				self.descriptionModel:SetModel(model)
				self.attributesModel:SetModel(model)
			end
		end
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
	if (name == "description") then
		return self.descriptionPanel
	elseif (name == "attributes") then
		return self.attributesPanel
	end

	return self.descriptionPanel
end

function PANEL:AttachCleanup(panel)
	self.repopulatePanels[#self.repopulatePanels + 1] = panel
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
			tile.Scale = 1.0        -- current scale
			tile.TargetScale = 1.0  -- target scale
			tile.ScaleSpeed = 10    -- how fast to lerp towards target
			tile.HoverScale = 1.025  -- subtle hover scale for allowed tiles

			function tile:Think()
				-- update target on hover (only if allowed)
				if self.IsAllowed then
					if self.Hovered and not self.Selected then
						self.TargetScale = self.HoverScale
					elseif not self.Selected then
						self.TargetScale = 1.0
					end
				else
					self.TargetScale = 1.0
				end

				-- smooth scale towards target
				self.Scale = Lerp(FrameTime() * self.ScaleSpeed, self.Scale, self.TargetScale)
			end

			-- rounded background + selection outline
			function tile:Paint(w, h)
				local bg = self.Hovered and Color(50, 50, 50, 100) or Color(30, 30, 30, 0)
				draw.RoundedBox(8, 0, 0, w, h, bg)

				-- selection outline only if allowed
				if (self.Selected and self.IsAllowed) then
					surface.SetDrawColor(v.color or color_white)
					surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 2)
				end
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
				end

				local faction = ix.faction.indices[panel.faction]
				local models = faction:GetModels(LocalPlayer())

				self.payload:Set("faction", panel.faction)
				self.payload:Set("model", math.random(1, #models))

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

			-- track default selection
			if ((lastSelected and lastSelected == v.index) or (not lastSelected and v.isDefault)) and tile.IsAllowed then
				tile.Selected = true
				lastSelected = v.index
				-- also apply payload and info immediately
				selectTile(tile)
			end
		end
	end

	-- remove panels created for character vars
	for i = 1, #self.repopulatePanels do
		self.repopulatePanels[i]:Remove()
	end

	self.repopulatePanels = {}

	if (not self.payload.faction) then
		for _, btn in pairs(self.factionButtons) do
			if (IsValid(btn) and btn.Selected) then
				-- if you want to re-apply selection visuals and payload:
				-- clear others
				for _, b in ipairs(self.factionButtons) do
					if IsValid(b) then b.Selected = false end
				end
				btn.Selected = true

				-- also ensure payload and info are consistent
				local faction = ix.faction.indices[btn.faction]
				if faction then
					local models = faction:GetModels(LocalPlayer())
					self.payload:Set("faction", btn.faction)
					self.payload:Set("model", math.random(1, #models))
				end
				break
			end
		end
	end

	local zPos = 1

	-- set up character vars
	for k, v in SortedPairsByMemberValue(ix.char.vars, "index") do
		if (!v.bNoDisplay and k != "__SortedIndex") then
			local container = self:GetContainerPanel(v.category or "AAAA")

			if (v.ShouldDisplay and v:ShouldDisplay(container, self.payload) == false) then
				continue
			end

			local panel

			-- if the var has a custom way of displaying, we'll use that instead
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
				-- add label for entry
				local label = container:Add("DLabel")
				label:SetFont("ixMenuButtonLabelFont")
				label:SetText(L(k):utf8upper())
				label:SizeToContents()
				label:DockMargin(0, 16, 0, 2)
				label:Dock(TOP)

				-- we need to set the docking order so the label is above the panel
				label:SetZPos(zPos - 1)
				panel:SetZPos(zPos)

				self:AttachCleanup(label)
				self:AttachCleanup(panel)

				if (v.OnPostSetup) then
					v:OnPostSetup(panel, self.payload)
				end

				zPos = zPos + 2
			end
		end
	end

	if (!self.bInitialPopulate) then
		-- setup progress bar segments
		if (#self.factionButtons > 1) then
			self.progress:AddSegment("@faction")
		end

		self.progress:AddSegment("@profile")

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

function PANEL:VerifyProgression(name)
	for k, v in SortedPairsByMemberValue(ix.char.vars, "index") do
		if (name ~= nil and (v.category or "profile") != name) then
			continue
		end

		local value = self.payload[k]

		if (!v.bNoDisplay or v.OnValidate) then
			if (v.OnValidate) then
				local result = {v:OnValidate(value, self.payload, LocalPlayer())}

				if (result[1] == false) then
					self:GetParent():ShowNotice(3, L(unpack(result, 2)))
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

vgui.Register("ixCharMenuNew", PANEL, "ixCharMenuPanel")
