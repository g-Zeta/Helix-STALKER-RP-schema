
local gradient = surface.GetTextureID("vgui/gradient-d")
local gradientUp = surface.GetTextureID("vgui/gradient-u")
local gradientLeft = surface.GetTextureID("vgui/gradient-l")
local gradientRadial = Material("helix/gui/radial-gradient.png")
local chatboxbg = Material("cotz/panels/frame1.png")
local menubg = Material("stalker2/ui/menu/main_menu", "smooth")
local pdabackground = Material("stalkerSHoC/ui/pda/pda_on_skin0.png")

ix.option.Add("PDAskin", ix.type.number, 0, {
	category = "STALKER Settings",
	min = 0,
	max = 4,
	OnChanged = function(oldValue, newValue)
		pdabackground = Material("stalkerSHoC/ui/pda/pda_on_skin" .. newValue .. ".png")
	end
})

hook.Add("InitializedConfig", "ixPDAskinInit", function()
	local skin = ix.option.Get("PDAskin", 0)
	pdabackground = Material("stalkerSHoC/ui/pda/pda_on_skin" .. skin .. ".png")
end)

local menubuttonbackground = Material("cotz/panels/button2.png")
local defaultBackgroundColor = Color(30, 30, 30, 200)

-- A default color to use when no character/faction is available.
local defaultColor = Color(127, 111, 63)

---
-- Returns the current character's faction color, or a default color.
-- This allows the UI theme to be dynamic based on the player's faction.
-- @return color The faction color or a default.
function ix.GetFactionColor()
	if (CLIENT) then
		local client = LocalPlayer()
		if (IsValid(client)) then
			local character = client:GetCharacter()
			if (character) then
				local faction = ix.faction.indices[character:GetFaction()]
				if (faction and faction.color) then
					return faction.color
				end
			end
		end
	end

	-- Fallback for main menu or if something goes wrong.
	return defaultColor
end

local SKIN = {}
derma.DefineSkin("helix", "The base skin for the Helix framework.", SKIN)

SKIN.fontCategory = "stalkerregularfont"
SKIN.fontCategoryBlur = "stalkerregularfont"
SKIN.fontSegmentedProgress = "stalkerregularfont"

SKIN.Colours = table.Copy(derma.SkinList.Default.Colours)

SKIN.Colours.Info = Color(100, 185, 255)
SKIN.Colours.Success = Color(64, 185, 85)
SKIN.Colours.Error = Color(255, 100, 100)
SKIN.Colours.Warning = Color(230, 180, 0)
SKIN.Colours.MenuLabel = color_white
SKIN.Colours.DarkerBackground = Color(0, 0, 0, 77)

SKIN.Colours.SegmentedProgress = {}
SKIN.Colours.SegmentedProgress.Bar = Color(64, 185, 85)
SKIN.Colours.SegmentedProgress.Text = color_white

SKIN.Colours.Area = {}

SKIN.Colours.Window.TitleActive = Color(0, 0, 0)
SKIN.Colours.Window.TitleInactive = color_white

SKIN.Colours.Button.Normal = color_white
SKIN.Colours.Button.Hover = color_white
SKIN.Colours.Button.Down = Color(180, 180, 180)
SKIN.Colours.Button.Disabled = Color(0, 0, 0, 100)

SKIN.Colours.Label.Default = color_white

function SKIN.tex.Menu_Strip(x, y, width, height, color)
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(x, y, width, height)

	surface.SetDrawColor(ColorAlpha(color or ix.config.Get("color"), 175))
	surface.SetTexture(gradient)
	surface.DrawTexturedRect(x, y, width, height)

	surface.SetTextColor(color_white)
end

hook.Add("ColorSchemeChanged", "ixSkin", function(color)
	SKIN.Colours.Area.Background = color
end)

function SKIN:DrawHelixCurved(x, y, radius, segments, barHeight, fraction, color, altColor)
	radius = radius or math.min(ScreenScale(72), 128) * 2
	segments = segments or 76
	barHeight = barHeight or 64
	color = color or ix.config.Get("color")
	altColor = altColor or Color(color.r * 0.5, color.g * 0.5, color.b * 0.5, color.a)
	fraction = fraction or 1

	surface.SetTexture(-1)

	for i = 1, math.ceil(segments) do
		local angle = math.rad((i / segments) * -360)
		local barX = x + math.sin(angle + (fraction * math.pi * 2)) * radius
		local barY = y + math.cos(angle + (fraction * math.pi * 2)) * radius
		local barOffset = math.sin(SysTime() + i * 0.5)

		if (barOffset > 0) then
			surface.SetDrawColor(color)
		else
			surface.SetDrawColor(altColor)
		end

		surface.DrawTexturedRectRotated(barX, barY, 4, barOffset * (barHeight * fraction), math.deg(angle))
	end
end

function SKIN:DrawHelix(x, y, width, height, segments, color, fraction, speed)
	segments = segments or width * 0.05
	color = color or ix.config.Get("color")
	fraction = fraction or 0.25
	speed = speed or 1

	for i = 1, math.ceil(segments) do
		local offset = math.sin((SysTime() + speed) + i * fraction)
		local barHeight = height * offset

		surface.SetTexture(-1)

		if (offset > 0) then
			surface.SetDrawColor(color)
		else
			surface.SetDrawColor(color.r * 0.5, color.g * 0.5, color.b * 0.5, color.a)
		end

		surface.DrawTexturedRectRotated(x + (i / segments) * width, y + height * 0.5, 4, barHeight, 0)
	end
end

function SKIN:PaintFrame(panel)
	if (!panel.bNoBackgroundBlur) then
		ix.util.DrawBlur(panel, 10)
	end

	

	if (panel:GetTitle() != "" or panel.btnClose:IsVisible()) then
		surface.SetDrawColor(30, 30, 30, 150)
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
		
		surface.SetDrawColor(ix.config.Get("color"))
		surface.DrawRect(0, 0, panel:GetWide(), 24)

		if (panel.bHighlighted) then
			self:DrawImportantBackground(0, 0, panel:GetWide(), 24, ColorAlpha(color_white, 22))
		end
		surface.SetDrawColor(ix.config.Get("color"))
		surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
	end

	
end

function SKIN:PaintBaseFrame(panel, width, height)
	if (!panel.bNoBackgroundBlur) then
		ix.util.DrawBlur(panel, 10)
	end

	surface.SetDrawColor(30, 30, 30, 150)
	surface.DrawRect(0, 0, width, height)

	surface.SetDrawColor(ix.config.Get("color"))
	surface.DrawOutlinedRect(0, 0, width, height)
end

function SKIN:DrawImportantBackground(x, y, width, height, color)
	color = color or defaultBackgroundColor

	surface.SetTexture(gradientLeft)
	surface.SetDrawColor(color)
	surface.DrawTexturedRect(x, y, width, height)
end

function SKIN:DrawCharacterStatusBackground(panel, fraction)
	surface.SetDrawColor(0, 0, 0, fraction * 100)
	surface.DrawRect(0, 0, ScrW(), ScrH())
	ix.util.DrawBlurAt(0, 0, ScrW(), ScrH(), 5, nil, fraction * 255)
end

function SKIN:PaintPanel(panel)
	if (panel.m_bBackground) then
		local width, height = panel:GetSize()
		if (panel.m_bgColor) then
			surface.SetDrawColor(panel.m_bgColor)
		else
			surface.SetDrawColor(30, 30, 30, 100)
		end
		surface.DrawRect(0, 0, width, height)
		surface.SetDrawColor(0, 0, 0, 150)
		surface.DrawOutlinedRect(0, 0, width, height)
	end
end

-- Animated background DHTML with a VP8 .webm
local WEBM_BG_HTML = [[
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<style>
  html, body {
    margin: 0; padding: 0; background: #0a0a0a; overflow: hidden;
    width: 100%; height: 100%;
  }
  video {
    position: fixed; top: 50%; left: 50%;
    transform: translate(-50%, -50%);
    min-width: 100%; min-height: 100%;
    width: auto; height: auto;
    object-fit: cover;
    background: #0a0a0a;
  }
</style>
</head>
<body>
  <video id="bg" autoplay playsinline muted loop preload="auto">
    <source src="asset://garrysmod/materials/stalker2/ui/menu/main_menu.webm" type="video/webm; codecs=vp8,vorbis">
  </video>
</body>
</html>
]]

local DHTMLBackground = nil

local function EnsureBackgroundDHTML(parent)
    if IsValid(DHTMLBackground) then
        if parent and DHTMLBackground:GetParent() ~= parent then
            DHTMLBackground:SetParent(parent)
        end
        return DHTMLBackground
    end

    DHTMLBackground = vgui.Create("DHTML", parent or nil)
    DHTMLBackground:SetPos(0, 0)
    DHTMLBackground:SetSize(ScrW(), ScrH())
    DHTMLBackground:SetHTML(WEBM_BG_HTML)
    DHTMLBackground:SetKeyboardInputEnabled(false)
    DHTMLBackground:SetMouseInputEnabled(false)
    DHTMLBackground:SetAllowLua(false) -- safer
    DHTMLBackground:MoveToBack()

    -- Keep it fullscreen on resolution changes
    hook.Add("OnScreenSizeChanged", "ixWebmBGResize", function()
        if IsValid(DHTMLBackground) then
            DHTMLBackground:SetSize(ScrW(), ScrH())
        end
    end)

    return DHTMLBackground
end

-- Expose helper for skin usage
ix = ix or {}
ix.webmBackground = ix.webmBackground or {}
function ix.webmBackground.Show(parent)
    local pnl = EnsureBackgroundDHTML(parent)
    if IsValid(pnl) then pnl:SetVisible(true) pnl:MoveToBack() end
end
function ix.webmBackground.Hide()
    if IsValid(DHTMLBackground) then DHTMLBackground:SetVisible(false) end
end

-- Draw in Main menu
function SKIN:PaintMainMenuBackground(panel, w, h)
    ix.webmBackground.Show(panel)
end

-- Draw in Character create menu
function SKIN:PaintCharacterCreateBackground(panel, w, h)
    ix.webmBackground.Show(panel)
end

-- Draw in Character load screen
function SKIN:PaintCharacterLoadBackground(panel, w, h)
    ix.webmBackground.Show(panel)
end

function SKIN:PaintMenuBackground(panel, width, height, alphaFraction)
	alphaFraction = alphaFraction or 1
 
	surface.SetDrawColor(255, 255, 255, alphaFraction * 255)
	surface.SetMaterial(pdabackground)
	surface.DrawTexturedRect(0, 0, width, height)
end

function SKIN:PaintPlaceholderPanel(panel, width, height, barWidth, padding)
	local size = math.max(width, height)
	barWidth = barWidth or size * 0.05

	local segments = size / barWidth

	for i = 1, segments do
		surface.SetTexture(-1)
		surface.SetDrawColor(0, 0, 0, 88)
		surface.DrawTexturedRectRotated(i * barWidth, i * barWidth, barWidth, size * 2, -45)
	end
end

function SKIN:PaintCategoryPanel(panel, text, color)
	text = text or ""
	color = color or ix.GetFactionColor()

	surface.SetFont(self.fontCategoryBlur)

	local textHeight = select(2, surface.GetTextSize(text)) + 6
	local width, height = panel:GetSize()

	surface.SetDrawColor(0, 0, 0, 100)
	surface.DrawRect(0, textHeight, width, height - textHeight)

	self:DrawImportantBackground(0, 0, width, textHeight, color)

	surface.SetTextColor(color_black)
	surface.SetTextPos(4, 4)
	surface.DrawText(text)

	surface.SetFont(self.fontCategory)
	surface.SetTextColor(color_white)
	surface.SetTextPos(4, 4)
	surface.DrawText(text)

	surface.SetDrawColor(color)
	surface.DrawOutlinedRect(0, 0, width, height)

	return 1, textHeight, 1, 1
end

function SKIN:PaintButton(panel)
	if (panel.m_bBackground) then
		local w, h = panel:GetWide(), panel:GetTall()
		local alpha = 50

		if (panel:GetDisabled()) then
			alpha = 10
		elseif (panel.Depressed) then
			alpha = 180
		elseif (panel.Hovered) then
			alpha = 75
		end

		if (panel:GetParent():GetName() == "DListView_Column") then
			surface.SetDrawColor(color_white)
			surface.DrawRect(0, 0, w, h)
		end

		surface.SetDrawColor(30, 30, 30, alpha)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 180)
		surface.DrawOutlinedRect(0, 0, w, h)

		surface.SetDrawColor(180, 180, 180, 2)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
	end
end

function SKIN:PaintEntityInfoBackground(panel, width, height)
	ix.util.DrawBlur(panel, 1)

	surface.SetDrawColor(self.Colours.DarkerBackground)
	surface.DrawRect(0, 0, width, height)
end

function SKIN:PaintTooltipBackground(panel, width, height)
	surface.SetMaterial(Material("cotz/panels/loot_interface.png"))
	surface.SetDrawColor(255, 255, 255, 245)
	surface.DrawTexturedRect(0, 0, width, height)
end

function SKIN:PaintTooltipMinimalBackground(panel, width, height)
	--surface.SetDrawColor(0, 0, 0, 150 * panel.fraction)
	--surface.SetMaterial(gradientRadial)
	--surface.DrawTexturedRect(0, 0, width, height)
end

function SKIN:PaintSegmentedProgressBackground(panel, width, height)
end

function SKIN:PaintSegmentedProgress(panel, width, height)
	local font = panel:GetFont() or self.fontSegmentedProgress
	local textColor = panel:GetTextColor() or self.Colours.SegmentedProgress.Text
	local barColor = panel:GetBarColor() or self.Colours.SegmentedProgress.Bar
	local segments = panel:GetSegments()
	local segmentHalfWidth = width / #segments * 0.5

	surface.SetDrawColor(barColor)
	surface.DrawRect(0, 0, panel:GetFraction() * width, height)

	for i = 1, #segments do
		local text = segments[i]
		local x = (i - 1) / #segments * width + segmentHalfWidth
		local y = height * 0.5

		draw.SimpleText(text, font, x, y, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function SKIN:PaintCharacterTransitionOverlay(panel, x, y, width, height, color)
	color = color or ix.config.Get("color")

	surface.SetDrawColor(color)
	surface.DrawRect(x, y, width, height)
end

function SKIN:PaintAreaEntry(panel, width, height)
	local color = ColorAlpha(panel:GetBackgroundColor() or self.Colours.Area.Background, panel:GetBackgroundAlpha())

	self:DrawImportantBackground(0, 0, width, height, color)
end

function SKIN:PaintListRow(panel, width, height)
	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(0, 0, width, height)
end

function SKIN:PaintSettingsRowBackground(panel, width, height)
	local index = panel:GetBackgroundIndex()
	local bReset = panel:GetShowReset()

	if (index == 0) then
		surface.SetDrawColor(30, 30, 30, 45)
		surface.DrawRect(0, 0, width, height)
	end

	if (bReset) then
		surface.SetDrawColor(self.Colours.Warning)
		surface.DrawRect(0, 0, 2, height)
	end
end

function SKIN:PaintVScrollBar(panel, width, height)
end

function SKIN:PaintScrollBarGrip(panel, width, height)
	local parent = panel:GetParent()
	local upButtonHeight = parent.btnUp:GetTall()
	local downButtonHeight = parent.btnDown:GetTall()

	DisableClipping(true)
		surface.SetDrawColor(30, 30, 30, 200)
		surface.DrawRect(4, -upButtonHeight, width - 8, height + upButtonHeight + downButtonHeight)
	DisableClipping(false)
end

function SKIN:PaintButtonUp(panel, width, height)
end

function SKIN:PaintButtonDown(panel, width, height)
end

function SKIN:PaintComboBox(panel, width, height)
end

function SKIN:PaintComboDownArrow(panel, width, height)
	surface.SetFont("ixIconsSmall")

	local textWidth, textHeight = surface.GetTextSize("r")
	local alpha = (panel.ComboBox:IsMenuOpen() or panel.ComboBox.Hovered) and 200 or 100

	surface.SetTextColor(ColorAlpha(ix.GetFactionColor(), alpha))
	surface.SetTextPos(width * 0.5 - textWidth * 0.5, height * 0.5 - textHeight * 0.5)
	surface.DrawText("r")
end

function SKIN:PaintMenu(panel, width, height)
	ix.util.DrawBlur(panel)

	surface.SetDrawColor(30, 30, 30, 150)
	surface.DrawRect(0, 0, width, height)
end

function SKIN:PaintMenuOption(panel, width, height)
	surface.SetDrawColor(Color(255, 255, 255))
	surface.SetMaterial(menubuttonbackground)
	surface.DrawTexturedRect(0, 0, width, height)

	if (panel.m_bBackground and (panel.Hovered or panel.Highlight)) then
		self:DrawImportantBackground(0, 0, width, height, ix.config.Get("color"))
	end
end

function SKIN:PaintHelixSlider(panel, width, height)
	surface.SetDrawColor(self.Colours.DarkerBackground)
	surface.DrawRect(0, 0, width, height)

	surface.SetDrawColor(self.Colours.Success)
	surface.DrawRect(0, 0, panel:GetVisualFraction() * width, height)
end

function SKIN:PaintChatboxTabButton(panel, width, height)
	if (panel:GetActive()) then
		surface.SetDrawColor(ix.config.Get("color"))
		surface.DrawRect(0, 0, width, height)
	else
		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawRect(0, 0, width, height)

		if (panel:GetUnread()) then
			surface.SetDrawColor(ColorAlpha(self.Colours.Warning, Lerp(panel.unreadAlpha, 0, 100)))
			surface.SetTexture(gradient)
			surface.DrawTexturedRect(0, 0, width, height - 1)
		end
	end

	-- border
	surface.SetDrawColor(color_black)
	surface.DrawRect(width - 1, 0, 1, height) -- right
end

function SKIN:PaintChatboxTabs(panel, width, height, alpha)
	surface.SetDrawColor(0, 0, 0, 33)
	surface.DrawRect(0, 0, width, height)

	surface.SetDrawColor(0, 0, 0, 100)
	surface.SetTexture(gradient)
	surface.DrawTexturedRect(0, height * 0.5, width, height * 0.5)

	local tab = panel:GetActiveTab()

	if (tab) then
		local button = tab:GetButton()
		local x, _ = button:GetPos()

		-- outline
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(0, height - 1, x, 1) -- left
		surface.DrawRect(x + button:GetWide(), height - 1, width - x - button:GetWide(), 1) -- right
	end
end
--Chatbox image
function SKIN:PaintChatboxBackground(panel, width, height)
	ix.util.DrawBlur(panel, 10)

	if (panel:GetActive()) then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(chatboxbg)
		surface.DrawTexturedRectUV(0, 0, width, height, 0, 1, 1, 0)
	end

	surface.SetDrawColor(color_black)
	surface.DrawOutlinedRect(0, 0, width, height)
end

function SKIN:PaintChatboxEntry(panel, width, height)
	surface.SetDrawColor(0, 0, 0, 66)
	surface.DrawRect(0, 0, width, height)

	panel:DrawTextEntryText(color_white, ix.config.Get("color"), color_white)

	surface.SetDrawColor(color_black)
	surface.DrawOutlinedRect(0, 0, width, height)
end

function SKIN:DrawChatboxPreviewBox(x, y, text, color)
	color = color or ix.config.Get("color")

	local textWidth, textHeight = surface.GetTextSize(text)
	local width, height = textWidth + 8, textHeight + 8

	-- background
	surface.SetDrawColor(color)
	surface.DrawRect(x, y, width, height)

	-- text
	surface.SetTextColor(color_white)
	surface.SetTextPos(x + width * 0.5 - textWidth * 0.5, y + height * 0.5 - textHeight * 0.5)
	surface.DrawText(text)

	-- outline
	surface.SetDrawColor(color.r * 0.5, color.g * 0.5, color.b * 0.5, 255)
	surface.DrawOutlinedRect(x, y, width, height)

	return width
end

function SKIN:DrawChatboxPrefixBox(panel, width, height)
	local color = panel:GetBackgroundColor()

	-- background
	surface.SetDrawColor(color)
	surface.DrawRect(0, 0, width, height)

	-- outline
	surface.SetDrawColor(color.r * 0.5, color.g * 0.5, color.b * 0.5, 255)
	surface.DrawOutlinedRect(0, 0, width, height)
end


function SKIN:PaintChatboxAutocompleteEntry(panel, width, height)
	-- selected background
	if (panel.highlightAlpha > 0) then
		self:DrawImportantBackground(0, 0, width, height, ColorAlpha(ix.config.Get("color"), panel.highlightAlpha * 66))
	end

	-- lower border
	surface.SetDrawColor(200, 200, 200, 33)
	surface.DrawRect(0, height - 1, width, 1)
end

function SKIN:PaintWindowMinimizeButton(panel, width, height)
end

function SKIN:PaintWindowMaximizeButton(panel, width, height)
end

function SKIN:PaintInfoBar(panel, width, height, color)
	-- bar
	surface.SetDrawColor(color.r, color.g, color.b, 250)
	surface.DrawRect(0, 0, width, height)

	-- gradient overlay
	surface.SetDrawColor(230, 230, 230, 8)
	surface.SetTexture(gradientUp)
	surface.DrawTexturedRect(0, 0, width, height)
end

function SKIN:PaintInventorySlot(panel, width, height)
	surface.SetDrawColor(35, 35, 35, 85)
	surface.DrawRect(1, 1, width - 2, height - 2)

	surface.SetDrawColor(0, 0, 0, 250)
	surface.DrawOutlinedRect(1, 1, width - 2, height - 2)
end

do
	-- check if sounds exist, otherwise fall back to default UI sounds
	local bWhoosh = file.Exists("sound/helix/ui/whoosh1.wav", "GAME")
	local bRollover = file.Exists("sound/helix/ui/rollover.wav", "GAME")
	local bPress = file.Exists("sound/helix/ui/press.wav", "GAME")
	local bNotify = file.Exists("sound/helix/ui/REPLACEME.wav", "GAME") -- @todo

	sound.Add({
		name = "Helix.Whoosh",
		channel = CHAN_STATIC,
		volume = 0.4,
		level = 80,
		pitch = bWhoosh and {90, 105} or 100,
		sound = bWhoosh and {
			"helix/ui/whoosh1.wav",
			"helix/ui/whoosh2.wav",
			"helix/ui/whoosh3.wav",
			"helix/ui/whoosh4.wav",
			"helix/ui/whoosh5.wav",
			"helix/ui/whoosh6.wav"
		} or ""
	})

	sound.Add({
		name = "STALKER.Rollover.MainMenu",
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 80,
		pitch = {99, 101},
		sound = "stalker/menu/button_rollover.wav"
	})

	sound.Add({
		name = "STALKER.Press.MainMenu",
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 80,
		pitch = {99, 101},
		sound = "stalker/menu/button_select.wav"
	})
	
	sound.Add({
		name = "Helix.Rollover",
		channel = CHAN_STATIC,
		volume = 0.2,
		level = 80,
		pitch = {99, 101},
		sound = bRollover and "stalker/detectors/contact.wav" or "ui/buttonrollover.wav"
	})

	sound.Add({
		name = "Helix.Press",
		channel = CHAN_STATIC,
		volume = 0.5,
		level = 80,
		pitch = bPress and {99, 101} or 100,
		sound = bPress and "stalker/pda/pda_select.ogg" or "ui/buttonclickrelease.wav"
	})

	sound.Add({
		name = "Helix.Notify",
		channel = CHAN_STATIC,
		volume = 0.35,
		level = 80,
		pitch = 100,
		sound = bNotify and "helix/ui/REPLACEME.wav" or "stalker/pda/pda_alarm.wav"
	})
end

--
-- Custom sound logic for menu buttons
-- This section overrides the default OnCursorEntered for ixMenuButton
-- to play different sounds depending on the active menu.
--
do
	local PANEL = vgui.GetControlTable("ixMenuButton")
	if not PANEL then return end

	-- Override the function to add conditional sound logic.
	function PANEL:OnCursorEntered()
		if (self:GetDisabled()) then
			return
		end

		-- Replicate the visual/animation part of the original function.
		local color = self:GetTextColor()
		self:SetTextColorInternal(Color(math.max(color.r - 25, 0), math.max(color.g - 25, 0), math.max(color.b - 25, 0)))

		self:CreateAnimation(0.15, {
			target = {currentBackgroundAlpha = self.backgroundAlpha}
		})

		-- Play sound based on the current menu context.
		if (IsValid(ix.gui.characterMenu)) then
			LocalPlayer():EmitSound("STALKER.Rollover.MainMenu")
		else
			LocalPlayer():EmitSound("Helix.Rollover")
		end
	end

	-- Override the function to add conditional sound logic for clicks.
	function PANEL:OnMousePressed(code)
		if (self:GetDisabled()) then
			return
		end

		if (self.color) then
			self:SetTextColor(self.color)
		else
			self:SetTextColor(ix.config.Get("color"))
		end

		-- Play sound based on the current menu context.
		if (IsValid(ix.gui.characterMenu)) then
			LocalPlayer():EmitSound("STALKER.Press.MainMenu")
		else
			LocalPlayer():EmitSound("Helix.Press")
		end

		if (code == MOUSE_LEFT and self.DoClick) then
			self:DoClick(self)
		elseif (code == MOUSE_RIGHT and self.DoRightClick) then
			self:DoRightClick(self)
		end
	end
end

--
-- Custom sound logic for selection menu buttons
-- This section overrides the default OnMousePressed for selection buttons
-- to play different sounds depending on the active menu. This is needed
-- because these buttons have their own OnMousePressed which calls the
-- original base function, bypassing our override on ixMenuButton.
--
do
	-- This local function contains the shared logic for both selection button types.
	local function CustomSelectionButtonMousePressed(panel, code)
		if (panel:GetDisabled()) then
			return
		end

		-- Replicate the original selection logic from cl_menubutton.lua
		for _, v in pairs(panel.buttonList or {}) do
			if (IsValid(v) and v != panel) then
				v:SetSelected(false, panel.sectionParent == v)
			end
		end
		panel:SetSelected(true)

		-- Replicate the logic from our ixMenuButton override
		if (panel.color) then
			panel:SetTextColor(panel.color)
		else
			panel:SetTextColor(ix.config.Get("color"))
		end

		if (IsValid(ix.gui.characterMenu)) then
			LocalPlayer():EmitSound("STALKER.Press.MainMenu")
		else
			LocalPlayer():EmitSound("Helix.Press")
		end

		if (code == MOUSE_LEFT and panel.DoClick) then
			panel:DoClick(panel)
		elseif (code == MOUSE_RIGHT and panel.DoRightClick) then
			panel:DoRightClick(panel)
		end
	end

	-- Override for the standard selection button
	local PANEL_SEL = vgui.GetControlTable("ixMenuSelectionButton")
	if PANEL_SEL then
		PANEL_SEL.OnMousePressed = CustomSelectionButtonMousePressed
	end

	-- Override for the top-bar selection button
	local PANEL_TOP = vgui.GetControlTable("ixMenuSelectionButtonTop")
	if PANEL_TOP then
		PANEL_TOP.OnMousePressed = CustomSelectionButtonMousePressed
	end
end

derma.RefreshSkins()

--
-- Tooltip Overrides for Faction Colors
-- This section overrides core Helix tooltip functions to use the dynamic
-- ix.GetFactionColor() without modifying core framework files.
--

-- Override for the main tooltip row's "important" style.
local PANEL_ROW = vgui.GetControlTable("ixTooltipRow")
if (PANEL_ROW) then
	function PANEL_ROW:SetImportant()
		self:SetFont("ixSmallTitleFont")
		self:SetExpensiveShadow(1, color_black)
		self:SetBackgroundColor(ix.GetFactionColor())
	end
end

-- Override for the minimal tooltip row's "important" style.
local PANEL_MINIMAL_ROW = vgui.GetControlTable("ixTooltipMinimalRow")
if (PANEL_MINIMAL_ROW) then
	function PANEL_MINIMAL_ROW:SetImportant()
		self:SetFont("ixMinimalTitleFont")
		self:SetBackgroundColor(ix.GetFactionColor())
	end
end

-- Override for the container entity's tooltip, as it sets its own color.
timer.Simple(0, function() -- Use a timer to ensure the entity script has loaded.
	local ENTITY = scripted_ents.Get("ix_container")
	if (ENTITY and ENTITY.OnPopulateEntityInfo) then
		local base_OnPopulateEntityInfo = ENTITY.OnPopulateEntityInfo
		function ENTITY:OnPopulateEntityInfo(tooltip)
			base_OnPopulateEntityInfo(self, tooltip)
			local nameRow = tooltip:GetRow("name")
			if (IsValid(nameRow)) then nameRow:SetBackgroundColor(ix.GetFactionColor()) end
		end
	end
end)
