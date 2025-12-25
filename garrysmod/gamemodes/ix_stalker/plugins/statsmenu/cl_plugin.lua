local BASE_W, BASE_H = 1920, 1080
local function UIScale()
  -- uniform scale, using the minimum axis to avoid stretch
  return math.min(ScrW() / BASE_W, ScrH() / BASE_H)
end

local function SW(x) return math.floor(x * UIScale() + 0.5) end
local function SH(y) return math.floor(y * UIScale() + 0.5) end

local PANEL = {}

function PANEL:Init()
	local client = LocalPlayer()
	local character = client:GetCharacter()
	local image = character:GetData("pdaavatar","stalker/ui/avatars/nodata.png")

	self:SetSize(SW(1165), SH(770)) -- Size of the whole panel
	self:SetPos(SW(54), SH(86)) -- Position of the whole panel
	self:SetDrawBackground(false)
	self:SetPaintBackground(false)

	-- PROFILE PANEL
	local profilePanel = self:Add("DImage")
	profilePanel:SetSize(SW(1165), SH(160))
	profilePanel:Dock(TOP)
	profilePanel:SetImage("stalker/ui/pda/rankings/profile.png")
	profilePanel:SetMouseInputEnabled(true)

	-- Create a horizontal layout inside the profile panel
	local profileLayout = profilePanel:Add("DPanel")
	profileLayout:Dock(FILL)
	profileLayout:SetPaintBackground(false)

	-- Create panel for the character's avatar and name
	local characterPanel = profileLayout:Add("DPanel")
	characterPanel:Dock(LEFT)
	characterPanel:SetSize(SW(177), SH(124)) -- Adjust size if needed
	characterPanel:SetPaintBackground(false)
	characterPanel:DockMargin(SW(7), 0, 0, 0)

	-- Character Avatar
	local avatar = characterPanel:Add("DImage")
	avatar:SetSize(SW(124), SH(124))
	avatar:SetImage(image)
	avatar:Dock(TOP)
	avatar:DockMargin(0, SH(9), 0, 0)
	avatar:SetMouseInputEnabled(false)

	-- Character Name
	local name = characterPanel:Add("ixLabel")
	name:Dock(TOP)
	name:SetText(character:GetName())
	name:SetFont("stalkerregularboldfont")
	name:SetContentAlignment(5)
	name:SetMouseInputEnabled(false)

	-- STATS INFO PANEL
	local statsPanel = self:Add("DImage")
	statsPanel:SetSize(SW(450), SH(0))
	statsPanel:Dock(LEFT)
	statsPanel:DockMargin(0, SH(5), 0, 0)
	statsPanel:SetImage("stalker/ui/pda/rankings/rank_display.png")
	statsPanel:SetMouseInputEnabled(true)

	-- Attributes
	if (character) then
		self.attributes = statsPanel:Add("ixCategoryPanel")
		self.attributes:SetText(L("attributes"))
		self.attributes:Dock(TOP)
		self.attributes:DockMargin(SW(5), SH(5), SW(5), 0)

		local boost = character:GetBoosts()
		local bFirst = true

		for k, v in SortedPairsByMemberValue(ix.attributes.list, "name") do
			local attributeBoost = 0

			if (boost[k]) then
				for _, bValue in pairs(boost[k]) do
					attributeBoost = attributeBoost + bValue
				end
			end

			local bar = self.attributes:Add("ixAttributeBar")
			bar:Dock(TOP)

			if (!bFirst) then
				bar:DockMargin(0, 3, 0, 0)
			else
				bFirst = false
			end

			local value = character:GetAttribute(k, 0)

			if (attributeBoost) then
				bar:SetValue(value - attributeBoost or 0)
			else
				bar:SetValue(value)
			end

			local maximum = v.maxValue or ix.config.Get("maxAttributes", 100)
			bar:SetMax(maximum)
			bar:SetReadOnly()
			bar:SetText(Format("%s [%.1f/%.1f] (%.1f%%)", L(v.name), value, maximum, value / maximum * 100))
			bar.label:SetFont("stalkerregularsmallfont")

			if (attributeBoost) then
				bar:SetBoost(attributeBoost)
			end
		end

		self.attributes:SizeToContents()
	end
end

-- Register the panel with a unique name.
vgui.Register("ixStatsPanel", PANEL, "DPanel")

-- Add the "Stats" tab to the character menu.
hook.Add("CreateMenuButtons", "ixStats", function(tabs)
	tabs["Stats"] = function(container)
		container:Add("ixStatsPanel")
	end
end)