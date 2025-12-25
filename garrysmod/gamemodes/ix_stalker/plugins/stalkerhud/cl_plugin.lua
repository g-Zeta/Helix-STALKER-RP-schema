--STALKER SHoC HUD textures
local health = Material("stalkerSHoC/ui/hud/health.png", "noclamp smooth")
local healthbar = Material("stalkerSHoC/ui/hud/bar.png", "noclamp smooth")
local staminabar = Material("stalkerSHoC/ui/hud/bar4.png", "noclamp smooth")
local poseidle = Material("stalkerSHoC/ui/hud/hud_standingstill.png" , "noclamp smooth")
local posewalking = Material("stalkerSHoC/ui/hud/hud_walking.png" , "noclamp smooth")
local poserunning = Material("stalkerSHoC/ui/hud/hud_sprinting.png" , "noclamp smooth")
local posecrouching = Material("stalkerSHoC/ui/hud/hud_crouching.png" , "noclamp smooth")
local posecrouchmove = Material("stalkerSHoC/ui/hud/hud_crouchmove.png", "noclamp smooth")

local Ammo = Material("stalkerSHoC/ui/hud/ammo.png", "noclamp smooth")

--STALKER 2 HUD textures
local s2hud = Material("stalker2/ui/hud/s2hud.png", "noclamp smooth")
local hpbar = Material("stalker2/ui/hud/hpbar.png", "noclamp smooth")
local stmbar = Material("stalker2/ui/hud/stmbar.png", "noclamp smooth")
local radicon = Material("stalker2/ui/hud/radicon.png", "noclamp smooth")
local radsmeter = Material("stalker2/ui/hud/rads.vtf", "noclamp smooth")

local ammoS2 = Material("stalker2/ui/hud/ammo.png", "noclamp smooth")

local ammo9x18 = Material("stalker2/ui/ammunition/ammo_9x18_fmj.png", "noclamp smooth")
local ammo9x18ap = Material("stalker2/ui/ammunition/ammo_9x18_ap.png", "noclamp smooth")
local ammo9x19 = Material("stalker2/ui/ammunition/ammo_9x19_fmj.png", "noclamp smooth")
local ammo9x19ap = Material("stalker2/ui/ammunition/ammo_9x19_ap.png", "noclamp smooth")
local ammo45acp = Material("stalker2/ui/ammunition/ammo_45acp_fmj.png", "noclamp smooth")
local ammo45acpap = Material("stalker2/ui/ammunition/ammo_45acp_ap.png", "noclamp smooth")
local ammo45acphp = Material("stalker2/ui/ammunition/ammo_45acp_hp.png", "noclamp smooth")
local ammo12x70buck = Material("stalker2/ui/ammunition/ammo_12x70_buck.png", "noclamp smooth")
local ammo12x70dart = Material("stalker2/ui/ammunition/ammo_12x70_dart.png", "noclamp smooth")
local ammo12x70slug = Material("stalker2/ui/ammunition/ammo_12x70_slug.png", "noclamp smooth")
local ammo545x39 = Material("stalker2/ui/ammunition/ammo_545x39_fmj.png", "noclamp smooth")
local ammo545x39ap = Material("stalker2/ui/ammunition/ammo_545x39_ap.png", "noclamp smooth")
local ammo545x39hp = Material("stalker2/ui/ammunition/ammo_545x39_hp.png", "noclamp smooth")
local ammo556x45 = Material("stalker2/ui/ammunition/ammo_556x45_fmj.png", "noclamp smooth")
local ammo556x45ap = Material("stalker2/ui/ammunition/ammo_556x45_ap.png", "noclamp smooth")
local ammo556x45hp = Material("stalker2/ui/ammunition/ammo_556x45_hp.png", "noclamp smooth")
local ammo556x45ss = Material("stalker2/ui/ammunition/ammo_556x45_ss.png", "noclamp smooth")
local ammo762x39 = Material("stalker2/ui/ammunition/ammo_762x39_fmj.png", "noclamp smooth")
local ammo762x39ap = Material("stalker2/ui/ammunition/ammo_762x39_ap.png", "noclamp smooth")
local ammo762x39hp = Material("stalker2/ui/ammunition/ammo_762x39_hp.png", "noclamp smooth")
local ammo762x51 = Material("stalker2/ui/ammunition/ammo_308_fmj.png", "noclamp smooth")
local ammo762x51ap = Material("stalker2/ui/ammunition/ammo_308_ap.png", "noclamp smooth")
local ammo762x51match = Material("stalker2/ui/ammunition/ammo_308_match.png", "noclamp smooth")
local ammo762x54 = Material("stalker2/ui/ammunition/ammo_762x54_fmj.png", "noclamp smooth")
local ammo762x54ap = Material("stalker2/ui/ammunition/ammo_762x54_ap.png", "noclamp smooth")
local ammo762x54ss = Material("stalker2/ui/ammunition/ammo_762x54_ss.png", "noclamp smooth")
local ammo9x39 = Material("stalker2/ui/ammunition/ammo_9x39_fmj.png", "noclamp smooth")
local ammo9x39ppe = Material("stalker2/ui/ammunition/ammo_9x39_ppe.png", "noclamp smooth")
local ammo9x39sp5 = Material("stalker2/ui/ammunition/ammo_9x39_sp5.png", "noclamp smooth")
local ammo9x39sp6 = Material("stalker2/ui/ammunition/ammo_9x39_sp6.png", "noclamp smooth")
local ammogauss = Material("stalker2/ui/ammunition/ammo_gauss.png", "noclamp smooth")
local ammorpg = Material("stalker2/ui/ammunition/ammo_pg7v.png", "noclamp smooth")
local ammom203 = Material("stalker2/ui/ammunition/ammo_m203.png", "noclamp smooth")
local ammovog25 = Material("stalker2/ui/ammunition/ammo_vog25.png", "noclamp smooth")

local minScale = 0.9
local maxScale = 1.3
local scaleSpeed = 0.3
local elapsedTime = 0.1

-- Fading HUD logic
local hudAlpha = 255
local lastHUDActivity = 0
local hudFadeDelay = 5 -- seconds
local hudFadeDuration = 1 -- seconds

local function ResetHUDFade()
    lastHUDActivity = CurTime()
    hudAlpha = 255
end

hook.Add("Think", "HUDThink", function()
    local lp = LocalPlayer()
    if not IsValid(lp) then return end

    -- Keep HUD visible if player has any radiation
    local radiation = 0
    if lp.getRadiation then radiation = lp:getRadiation() or 0 end
    if radiation > 0 then
        lastHUDActivity = CurTime()
        hudAlpha = 255
        return
    end

    -- Prevent fading if current weapon clip is at or below 25%
    local wep = lp:GetActiveWeapon()
    if IsValid(wep) and wep.Primary and type(wep.Primary.ClipSize) == "number" and wep.Primary.ClipSize > 0 then
        local curClip = wep:Clip1()
        local threshold = math.ceil(wep.Primary.ClipSize * 0.25)
        if curClip <= threshold then
            lastHUDActivity = CurTime()
            hudAlpha = 255
            return
        end
    end
	
    if lastHUDActivity == 0 then
        lastHUDActivity = CurTime()
    end

    if CurTime() - lastHUDActivity > hudFadeDelay then
        hudAlpha = math.max(0, hudAlpha - (255 / hudFadeDuration) * FrameTime())
    end
end)

local wasRKeyPressed = false
local prevHealth = nil
local prevClip = nil
local prevWepClass = nil

hook.Add("Think", "HUDRKeyCheck", function()
    local lp = LocalPlayer()
    if not IsValid(lp) then
        prevClip = nil
        prevWepClass = nil
        return
    end

    if prevHealth == nil then
        prevHealth = lp:Health()
    end

    -- R key detection (fires once per press)
    local isRKeyDown = input.IsKeyDown(KEY_R)
    if isRKeyDown and not wasRKeyPressed then
        ResetHUDFade()
    end
    wasRKeyPressed = isRKeyDown

    -- Show HUD when player loses health
    local curHealth = lp:Health()
    if lp:Alive() and curHealth < prevHealth then
        ResetHUDFade()
    end
    prevHealth = curHealth

    -- Show HUD when clip size drops to 25% or less (trigger on drop)
    local wep = lp:GetActiveWeapon()
    if IsValid(wep) and wep:HasAmmo() and wep.Primary and type(wep.Primary.ClipSize) == "number" and wep.Primary.ClipSize > 0 then
        local curClip = wep:Clip1()
        local wepClass = wep:GetClass()
        local threshold = math.floor(wep.Primary.ClipSize * 0.25 + 0.5)

        if prevWepClass ~= wepClass then
            prevClip = curClip
            prevWepClass = wepClass
        else
            if curClip < (prevClip or curClip) and curClip <= threshold then
                ResetHUDFade()
            end
            prevClip = curClip
        end
    else
        prevClip = nil
        prevWepClass = nil
    end
end)

--Ammo and Clip fonts
surface.CreateFont("ClipFont", {
	font = "arial",
	size = ScreenScale(17),
	extended = true,
	weight = 600,
})
surface.CreateFont("SlashFont", {
	font = "arial",
	size = ScreenScale(12),
	extended = true,
	weight = 500,
})
surface.CreateFont("AmmoFont", {
	font = "arial",
	size = ScreenScale(10),
	extended = true,
	weight = 500,
})

local color = {}
color["$pp_colour_addr"] = 0
color["$pp_colour_addg"] = 0
color["$pp_colour_addb"] = 0
color["$pp_colour_brightness"] = -0.01
color["$pp_colour_contrast"] = 0.90
color["$pp_colour_colour"] = 0.75
color["$pp_colour_mulr"] = 0
color["$pp_colour_mulg"] = 0
color["$pp_colour_mulb"] = 0

local function cursorDraw()
	if ix.option.Get("cursor", false) then
	    local x, y = gui.MousePos()
		local material = Material("stalker/cursor.vmt") 
	    if (x != 0 && y != 0) then 
	        surface.SetDrawColor( 255, 255, 255, 255 );
	        surface.SetMaterial(material)
	        surface.DrawTexturedRect( x, y, 60, 60 )
	    end
    end
end

local function cursorThink() 
	if ix.option.Get("cursor", false) then
	    local hover = vgui.GetHoveredPanel()
	    if not IsValid(hover) then 
	        return; 
	    end; 
	    hover:SetCursor('blank')
	end
end; 

hook.Add("DrawOverlay", "Draw_Cursor_Function_FGSHAR", cursorDraw)
hook.Add("Think", "Cursor_Think_Function_FGSHAR", cursorThink)

function PLUGIN:HUDPaint()
	if (hudAlpha <= 0) then return end
	-- Also hide the HUD if the tab menu is open and our custom blur is active.
	if ix.option.Get("DisableHUD", false) or (not ix.option.Get("cheapBlur", false) and IsValid(ix.gui.menu)) then
		return false
	else

		self:SurvivalIconHUDPaint()
		self:ArmorIconHUDPaint()
		self:WeaponIconHUDPaint()
		self:WeightIconHUDPaint()
		self:RadiationIconHUDPaint()
		self:PsyhealthIconHUDPaint()
		self:HeadgearIconHUDPaint()
		self:ArtifactBeltHUDPaint()

		-- Check which HUD style to use
		if ix.option.Get("StalkerHUD") then
			self:S2HUDPaint() -- Call S2HUD Paint Function
		else
			self:SHoCHUDPaint() -- Call SHoC Paint Function
		end
	end
end

--STALKER SHoC HUD
function PLUGIN:SHoCHUDPaint()
	local lp = LocalPlayer()
	local wep = LocalPlayer():GetActiveWeapon()
	local char = lp:GetCharacter()

	if (!lp:GetCharacter() or !lp:Alive() or ix.gui.characterMenu:IsVisible()) then return end

	--HP and stamina UI
	surface.SetMaterial(health)
	surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
	surface.DrawTexturedRect(ScrW()-280 * (ScrW()/1920), ScrH()-195 * (ScrH() / 1080), 250 * (ScrW()/1920), 90 * (ScrH() / 1080))

	--Health bar
	surface.SetMaterial(healthbar)
	surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
	surface.DrawTexturedRect(ScrW()-233 * (ScrW()/1920), ScrH()-136 * (ScrH() / 1080), (1.72*math.Clamp( LocalPlayer():Health()/LocalPlayer():GetMaxHealth()*100, 0, 100 )) * (ScrW()/1920), 17 * (ScrH() / 1080))

	--Stamina bar
	surface.SetMaterial(staminabar)
	surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
	surface.DrawTexturedRect(ScrW()-233 * (ScrW()/1920), ScrH()-163 * (ScrH() / 1080), (173*LocalPlayer():GetLocalVar("stm", 100)) / 100 * (ScrW()/1920), 17 * (ScrH() / 1080))

    -- Player stance indicator
    local stanceMaterial
	local velocity = lp:GetVelocity()
	if lp:Crouching() and lp:GetVelocity():Length() == 0 then
        stanceMaterial = posecrouching  -- Crouching
    elseif lp:Crouching() and velocity:Length() > 0 then
        stanceMaterial = posecrouchmove  -- Crouching and moving
    elseif lp:GetVelocity():Length() == 0 then
        stanceMaterial = poseidle  -- Idle/Standing
    elseif velocity:Length() < 100 and lp:GetMoveType() == MOVETYPE_WALK then
        stanceMaterial = posewalking  -- Walking
    elseif velocity:Length() > 100 and lp:GetMoveType() == MOVETYPE_WALK then
        stanceMaterial = poserunning    -- Running
    end

    -- Draw the stance indicator if a material is set
    if stanceMaterial then
        surface.SetMaterial(stanceMaterial)
        surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
        surface.DrawTexturedRect(100 * (ScrW() / 1920), 865 * (ScrH() / 1080), 156 * (ScrW() / 1920), 191 * (ScrH() / 1080))
    end

	--Ammo UI
	surface.SetMaterial(Ammo)
	surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
	surface.DrawTexturedRect(ScrW()-250 * (ScrW() / 1920), ScrH()-115 * (ScrH() / 1080), 210 * (ScrW() / 1920), 90 * (ScrH() / 1080))
	
	--Ammo display
	if IsValid( wep ) then
		if wep:HasAmmo() and wep:Clip1() >= 0 then
			draw.DrawText( tostring(wep:Clip1()) .. " / " .. tostring(lp:GetAmmoCount( wep:GetPrimaryAmmoType() )), "stalker2regularfont", ScrW()-120 * (ScrW() / 1920), ScrH()-75 * (ScrH() / 1080), Color( 193, 136, 21, hudAlpha ), TEXT_ALIGN_CENTER )
			if wep:GetPrimaryAmmoType() then
				if string.sub(game.GetAmmoName(wep:GetPrimaryAmmoType()) or "no", -1) == "-" then
					draw.DrawText( string.sub(game.GetAmmoName(wep:GetPrimaryAmmoType()), -3, -2) , "stalker2regularfont", ScrW()-210 * (ScrW() / 1920), ScrH()-75 * (ScrH() / 1080), Color( 193, 136, 21, hudAlpha ), TEXT_ALIGN_CENTER )
				end
			end
		end
	end
--// End HUD Code //--
end

--STALKER 2 HUD New
function PLUGIN:S2HUDPaint()
	local lp = LocalPlayer()
	local wep = LocalPlayer():GetActiveWeapon()
	local char = lp:GetCharacter()

	if (!lp:GetCharacter() or !lp:Alive() or ix.gui.characterMenu:IsVisible()) then return end

	local scrW, scrH = ScrW(), ScrH()
	local scaleX, scaleY = scrW / 1920, scrH / 1080

	--UI
	local hudX, hudY = 40 * scaleX, 960 * scaleY
	local hudW, hudH = 291 * scaleX, 83 * scaleY
	surface.SetMaterial(s2hud)
	surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
	surface.DrawTexturedRect(hudX, hudY, hudW, hudH)
	
	--Health bar
	local hpFraction = math.Clamp(lp:Health() / lp:GetMaxHealth(), 0, 1)
	local hpBarX, hpBarY = hudX + 94 * scaleX, hudY + 27 * scaleY
	local hpBarW, hpBarH = (185 * scaleX) * hpFraction, 12 * scaleY

	surface.SetMaterial(hpbar)
	surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
	-- Draw the bar with UV coordinates adjusted by health. This crops the texture instead of resizing it.
	-- The arguments are: x, y, width, height, startU, startV, endU, endV
	surface.DrawTexturedRectUV(hpBarX, hpBarY, hpBarW, hpBarH, 0, 0, hpFraction, 1)
	
	--Stamina bar
	local stmFraction = math.Clamp(lp:GetLocalVar("stm", 100) / 100, 0, 1)
	local stmBarX, stmBarY = hudX + 97 * scaleX, hudY + 45 * scaleY
	local stmBarW, stmBarH = (164 * scaleX) * stmFraction, 7 * scaleY

	surface.SetMaterial(stmbar)
	surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
	surface.DrawTexturedRectUV(stmBarX, stmBarY, stmBarW, stmBarH, 0, 0, stmFraction, 1)

	--Radiation status
	local radiation = lp:getRadiation()
	local radMaterials = {}
	local scale = 1.0 -- Default scale

	-- Position for the animated frame indicator
	local radsX = hudX + 13 * scaleX
	local radsY = hudY + 9 * scaleY

    -- Modify scaleSpeed based on radiation level
    scaleSpeed = 1 + (radiation / 5) -- Adjust '50' to control sensitivity

    -- Update elapsed time for heartbeat effect
    elapsedTime = elapsedTime + FrameTime() * scaleSpeed  -- Adjust based on frame time and speed

    -- Calculate scale based on sine function for heartbeat effect
    local scale = minScale + (maxScale - minScale) * 0.5 * (1 + math.sin(elapsedTime))

    -- Define color ranges
    local colorWhite = Color(255, 255, 255, 255) 	--White
    local colorYellow = Color(255, 255, 0, 255)  	--Yellow
    local colorOrange = Color(255, 165, 0, 255)  	--Orange
    local colorRed = Color(255, 0, 0, 255)        	--Red

    -- Load all the materials into a table
    for i = 1, 32 do
        radMaterials[i] = Material("stalker2/ui/hud/radc" .. i .. ".png", "noclamp smooth")
    end

    local materialIndex = 1  -- Default index

    if radiation > 0 then
        local currentColor

        -- Calculate the material index based on radiation
        materialIndex = math.min(math.floor((radiation / 100) * 31) + 1, 32) -- Map 1-100 radiation to 1-32 frames

    -- Determine the color based on radiation level
    local currentColor
    if radiation <= 25 then
        -- Fully white
        currentColor = colorWhite
    elseif radiation <= 50 then
        -- Interpolate from white to yellow
        local factor = (radiation - 25) / 25
        currentColor = Color(
            Lerp(factor, colorWhite.r, colorYellow.r),
            Lerp(factor, colorWhite.g, colorYellow.g),
            Lerp(factor, colorWhite.b, colorYellow.b),
            colorWhite.a
        )
    elseif radiation <= 75 then
        -- Interpolate from yellow to orange
        local factor = (radiation - 50) / 25
        currentColor = Color(
            Lerp(factor, colorYellow.r, colorOrange.r),
            Lerp(factor, colorYellow.g, colorOrange.g),
            Lerp(factor, colorYellow.b, colorOrange.b),
            colorYellow.a
        )
    else
        -- Interpolate from orange to red
        local factor = (radiation - 75) / 25
        currentColor = Color(
            Lerp(factor, colorOrange.r, colorRed.r),
            Lerp(factor, colorOrange.g, colorRed.g),
            Lerp(factor, colorOrange.b, colorRed.b),
            colorOrange.a
        )
    end

		-- Draw the animated meter frame
		surface.SetMaterial(radMaterials[materialIndex])
		surface.SetDrawColor(Color(currentColor.r, currentColor.g, currentColor.b, math.min(currentColor.a, hudAlpha)))
		local radmeterSize = 60
		local radmeterX = radsX + (60 - radmeterSize) * 0.5 * scaleX
		local radmeterY = radsY + (61 - radmeterSize) * 0.5 * scaleY
		surface.DrawTexturedRect(radmeterX, radmeterY, radmeterSize * scaleX, radmeterSize * scaleY)

		-- Draw the pulsing icon in the center
		surface.SetMaterial(radicon)
		surface.SetDrawColor(Color(currentColor.r, currentColor.g, currentColor.b, math.min(currentColor.a, hudAlpha)))
		local radiconSize = 30 * scale
		local radiconX = radsX + (60 - radiconSize) * 0.5 * scaleX
		local radiconY = radsY + (61 - radiconSize) * 0.5 * scaleY
		surface.DrawTexturedRect(radiconX, radiconY, radiconSize * scaleX, radiconSize * scaleY)
	else
		-- If radiation is 0, draw a static white icon
		surface.SetMaterial(radicon)
		surface.SetDrawColor(Color(colorWhite.r, colorWhite.g, colorWhite.b, math.min(colorWhite.a, hudAlpha)))
		local radiconSize = 30
		local radiconX = radsX + (60 - radiconSize) * 0.5 * scaleX
		local radiconY = radsY + (61 - radiconSize) * 0.5 * scaleY
		surface.DrawTexturedRect(radiconX, radiconY, radiconSize * scaleX, radiconSize * scaleY)
		-- Also ensure the animated meter is not drawn
		surface.SetDrawColor(0, 0, 0, 0)
	end
	
	--Ammo UI
	local ammoX, ammoY = 1650 * scaleX, 960 * scaleY
	local ammoW, ammoH = 226 * scaleX, 83 * scaleY
	surface.SetMaterial(ammoS2)
	surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
	surface.DrawTexturedRect(ammoX, ammoY, ammoW, ammoH)

	local auto = Material("stalker2/ui/hud/firetype_auto.png", "noclamp smooth")
	local single = Material("stalker2/ui/hud/firetype_single.png", "noclamp smooth")
	local burst = Material("stalker2/ui/hud/firetype_queue.png", "noclamp smooth")

	-- Define fire modes with their names, materials, and positions
	local fireModes = {
		{names = {"auto"}, mat = auto},
		{names = {"burst", "2burst", "3burst"}, mat = burst},
		{names = {"single", "semi", "bolt", "pump", "break", "double"}, mat = single},
	}

	-- Get the current fire mode from the weapon
	local currentFireMode = IsValid(wep) and wep.FireMode or "single"
	local highlightColor = Color(255, 255, 255, hudAlpha)
	local defaultColor = Color(100, 100, 100, hudAlpha)

	-- Dynamically draw and position available fire mode icons
	if IsValid(wep) and wep.FireModes and type(wep.FireModes) == "table" then
		local modesToDraw = {}
		-- First, collect all available fire modes for the weapon in the correct display order
		for _, iconData in ipairs(fireModes) do
			for _, availableModeName in ipairs(wep.FireModes) do
				if table.HasValue(iconData.names, availableModeName) then
					-- Store the icon data and whether it's the active mode
					modesToDraw[#modesToDraw + 1] = {
						mat = iconData.mat,
						active = (availableModeName == currentFireMode)
					}
					break -- Found a match for this icon type, move to the next
				end
			end
		end

		-- Now, draw the collected icons from right to left
		local start_x_offset = 120 -- Starting offset for the rightmost icon
		local icon_width = 18
		local icon_spacing = 5
		local current_x_offset = start_x_offset

		for _, mode in ipairs(modesToDraw) do
			surface.SetDrawColor(mode.active and highlightColor or defaultColor)
			surface.SetMaterial(mode.mat)
			surface.DrawTexturedRect(ammoX + current_x_offset * scaleX, ammoY + 54 * scaleY, icon_width * scaleX, icon_width * scaleY)

			-- Decrement the offset for the next icon to the left
			current_x_offset = current_x_offset - (icon_width + icon_spacing)
		end
	end

    -- Display ammo icon based on the weapon's primary ammo type
    if IsValid(wep) and wep.Primary then
        local ammoMaterial = nil

        -- Determine the material based on the ammo type
        if wep.Primary.Ammo == "9x18MM" then
            ammoMaterial = ammo9x18
        elseif wep.Primary.Ammo == "9x19MM" then
            ammoMaterial = ammo9x19
        elseif wep.Primary.Ammo == "12 Gauge" then
            ammoMaterial = ammo12x70buck
        elseif wep.Primary.Ammo == "5.45x39MM" then
            ammoMaterial = ammo545x39
        elseif wep.Primary.Ammo == "5.56x45MM" then
            ammoMaterial = ammo556x45
        elseif wep.Primary.Ammo == "7.62x39MM" then
            ammoMaterial = ammo762x39
        elseif wep.Primary.Ammo == "7.62x54MM" then
            ammoMaterial = ammo762x54
        elseif wep.Primary.Ammo == "9x39MM" then
            ammoMaterial = ammo9x39
        elseif wep.Primary.Ammo == "Batteries" then
            ammoMaterial = ammogauss
        end

        -- If a valid ammo material was found, draw it
        if ammoMaterial then
            surface.SetMaterial(ammoMaterial)
            surface.SetDrawColor(Color(255, 255, 255, hudAlpha))			
			local ammoIconX = ammoX + 141 * scaleX
			local ammoIconY = ammoY + 22 * scaleY
			local ammoIconW, ammoIconH = 77 * scaleX, 39 * scaleY
            surface.DrawTexturedRect(ammoIconX, ammoIconY, ammoIconW, ammoIconH)
        end
    end

	--Ammo display
	if IsValid(wep) then
		if wep:HasAmmo() and wep:Clip1() >= 0 then
			local clipText = tostring(wep:Clip1())
			local ammoCountText = tostring(lp:GetAmmoCount(wep:GetPrimaryAmmoType()))
			
			-- Calculate the positions for the text relative to the ammo UI panel
			local baseX = ammoX + 80 * scaleX
			local baseY = ammoY + 2 * scaleY
			
			local defaultTextColor = Color(215, 215, 215, hudAlpha)
			local clipTextColor = defaultTextColor

			local ammoCountColor = defaultTextColor
			local ammoType = wep:GetPrimaryAmmoType()
			local currentAmmo = lp:GetAmmoCount(ammoType)
			local maxAmmo = 100
			if maxAmmo > 0 and currentAmmo <= (maxAmmo * 0.10) then
				ammoCountColor = Color(255, 0, 0, hudAlpha) -- Red
			end

			local flashSpeed = 20 -- Higher is faster, lower is slower.
			-- Check if ammo is low (e.g., 25% of clip size)
			if wep.Primary and wep.Primary.ClipSize > 0 and wep:Clip1() <= (wep.Primary.ClipSize * 0.25) then
				-- Create a flashing effect using a sine wave
				if math.sin(CurTime() * flashSpeed) > 0 then
					clipTextColor = Color(255, 0, 0, hudAlpha) -- Red
				end
			end

			-- Define text properties in a table for cleaner drawing calls
			local textSpec = {}
			
			-- Draw the clip text right-aligned to prevent overlap
			textSpec.text, textSpec.font, textSpec.pos, textSpec.xalign, textSpec.color = clipText, "ClipFont", {baseX, baseY}, TEXT_ALIGN_RIGHT, clipTextColor
			draw.Text(textSpec)
			
			-- Draw the slash and ammo count with the default color
			textSpec.color = defaultTextColor
			textSpec.text, textSpec.font, textSpec.pos = "/", "SlashFont", {baseX + 12 * scaleX, baseY + 7 * scaleY}
			draw.Text(textSpec)
			
			textSpec.text, textSpec.font, textSpec.pos, textSpec.xalign, textSpec.color = ammoCountText, "AmmoFont", {baseX + 15 * scaleX, baseY + 11 * scaleY}, TEXT_ALIGN_LEFT, ammoCountColor
			draw.Text(textSpec)

			-- Reset xalign for other text elements if needed elsewhere
			textSpec.xalign = TEXT_ALIGN_CENTER
		end
	end
--// End HUD Code //--
end

ix.option.Add("StalkerHUD", ix.type.bool, false, { category = "STALKER Settings", })

--// STATUS HUD ICONS //--

-- Hunger and Thirst
function PLUGIN:SurvivalIconHUDPaint()
	if ix.option.Get("DisableHUD", false) then
		return false
	else

		local lp = LocalPlayer()
		local char = lp:GetCharacter()

		if (!lp:GetCharacter() or !lp:Alive() or ix.gui.characterMenu:IsVisible()) then return end
		
		local hunger = Material("stalkerCoP/ui/hud/status/hunger.png", "noclamp smooth") 
		local hunger2 = Material("stalkerCoP/ui/hud/status/hunger2.png", "noclamp smooth") 
		local hunger3 = Material("stalkerCoP/ui/hud/status/hunger3.png", "noclamp smooth") 
		local hunger4 = Material("stalkerCoP/ui/hud/status/hunger4.png", "noclamp smooth") 
		
		local thirst = Material("stalkerCoP/ui/hud/status/thirst.png", "noclamp smooth") 
		local thirst2 = Material("stalkerCoP/ui/hud/status/thirst2.png", "noclamp smooth") 
		local thirst3 = Material("stalkerCoP/ui/hud/status/thirst3.png", "noclamp smooth") 
		local thirst4 = Material("stalkerCoP/ui/hud/status/thirst4.png", "noclamp smooth")
		
		--Hunger
		surface.SetMaterial(hunger)
		if LocalPlayer():GetHunger() > 60 then
			surface.SetMaterial(hunger)
			surface.SetDrawColor(Color(0, 0, 0, 0))
		elseif LocalPlayer():GetHunger() <= 60 and LocalPlayer():GetHunger() > 45 then
			surface.SetMaterial(hunger)
			surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		elseif LocalPlayer():GetHunger() <= 45 and LocalPlayer():GetHunger() > 30 then
			surface.SetMaterial(hunger2)
			surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		elseif LocalPlayer():GetHunger() <= 30 and LocalPlayer():GetHunger() > 15 then
			surface.SetMaterial(hunger3)
			surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		elseif LocalPlayer():GetHunger() <= 15 then
			surface.SetMaterial(hunger4)
			surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		end
		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-550 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, hudAlpha))

		--Thirst
		surface.SetMaterial(thirst)
		if LocalPlayer():GetThirst() > 60 then
			surface.SetMaterial(thirst)
			surface.SetDrawColor(Color(0, 0, 0, 0))
		elseif LocalPlayer():GetThirst() <= 60 and LocalPlayer():GetThirst() > 45 then
			surface.SetMaterial(thirst)
			surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		elseif LocalPlayer():GetThirst() <= 45 and LocalPlayer():GetThirst() > 30 then
			surface.SetMaterial(thirst2)
			surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		elseif LocalPlayer():GetThirst() <= 30 and LocalPlayer():GetThirst() > 15 then
			surface.SetMaterial(thirst3)
			surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		elseif LocalPlayer():GetThirst() <= 15 then
			surface.SetMaterial(thirst4)
			surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		end
		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-600 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, hudAlpha))
	end
end

-- Headgear
function PLUGIN:HeadgearIconHUDPaint()
	if ix.option.Get("DisableHUD", false) then
		return false
	else

		local lp = LocalPlayer()
		local char = lp:GetCharacter()

		if (!lp:GetCharacter() or !lp:Alive() or ix.gui.characterMenu:IsVisible()) then return end

		local equippedgasmask = LocalPlayer():getEquippedGasmask()
		local equippedhelmet = LocalPlayer():getEquippedHelmet() 
		local equippedpartdura = 10000
		local equippedpartdurafinal = 10000

		local helmet = Material("stalkerCoP/ui/hud/status/helmet.png", "noclamp smooth") 
		local helmet2 = Material("stalkerCoP/ui/hud/status/helmet2.png", "noclamp smooth") 
		local helmet3 = Material("stalkerCoP/ui/hud/status/helmet3.png", "noclamp smooth") 
		local helmet4 = Material("stalkerCoP/ui/hud/status/helmet4.png", "noclamp smooth") 

		if equippedgasmask then
			if equippedgasmask:GetData("durability") and equippedgasmask:GetData("durability") < equippedpartdura then
				equippedpartdura = equippedgasmask:GetData("durability")
				if equippedpartdurafinal > equippedpartdura then
					equippedpartdurafinal = equippedpartdura
				end
			end
		end

		if equippedhelmet then
			if equippedhelmet:GetData("durability") and equippedhelmet:GetData("durability") < equippedpartdura then
				equippedpartdura = equippedhelmet:GetData("durability")
				if equippedpartdurafinal > equippedpartdura then
					equippedpartdurafinal = equippedpartdura
				end
			end
		end

		if equippedpartdura then
		surface.SetMaterial(helmet)
			if equippedpartdurafinal >= 8000 then
				surface.SetDrawColor(Color(0, 0, 0, 0))
			elseif equippedpartdurafinal < 8000 and equippedpartdurafinal >= 6000 then
				surface.SetMaterial(helmet)
				surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
			elseif equippedpartdurafinal < 6000 and equippedpartdurafinal >= 4000 then
				surface.SetMaterial(helmet2)
				surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
			elseif equippedpartdurafinal < 4000 and equippedpartdurafinal >= 2000 then
				surface.SetMaterial(helmet3)
				surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
			elseif equippedpartdurafinal < 2000 and equippedpartdurafinal >= 0 then
				surface.SetMaterial(helmet4)
				surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
			end
		else
			surface.SetDrawColor(Color(0, 0, 0, 0))
		end
		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-500 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, hudAlpha))
	end
end

-- Armor
function PLUGIN:ArmorIconHUDPaint()
	if ix.option.Get("DisableHUD", false) then
		return false
	else

		local lp = LocalPlayer()
		local wep = LocalPlayer():GetActiveWeapon()
		local char = lp:GetCharacter()

		if (!lp:GetCharacter() or !lp:Alive() or ix.gui.characterMenu:IsVisible()) then return end

		local equippedarmor = LocalPlayer():getEquippedBodyArmor()
		local equippedpartdura = 10000
		local equippedpartdurafinal = 10000

		local armor = Material("stalkerCoP/ui/hud/status/armor.png", "noclamp smooth") 
		local armor2 = Material("stalkerCoP/ui/hud/status/armor2.png", "noclamp smooth") 
		local armor3 = Material("stalkerCoP/ui/hud/status/armor3.png", "noclamp smooth") 
		local armor4 = Material("stalkerCoP/ui/hud/status/armor4.png", "noclamp smooth") 

		if equippedarmor then
			if equippedarmor:GetData("durability") and equippedarmor:GetData("durability") < equippedpartdura then
				equippedpartdura = equippedarmor:GetData("durability")
				if equippedpartdurafinal > equippedpartdura then
					equippedpartdurafinal = equippedpartdura
				end
			end
		end

		if equippedpartdura then
		surface.SetMaterial(armor)
			if equippedpartdurafinal >= 8000 then
				surface.SetDrawColor(Color(0, 0, 0, 0))
			elseif equippedpartdurafinal < 8000 and equippedpartdurafinal >= 6000 then
				surface.SetMaterial(armor)
				surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
			elseif equippedpartdurafinal < 6000 and equippedpartdurafinal >= 4000 then
				surface.SetMaterial(armor2)
				surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
			elseif equippedpartdurafinal < 4000 and equippedpartdurafinal >= 2000 then
				surface.SetMaterial(armor3)
				surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
			elseif equippedpartdurafinal < 2000 and equippedpartdurafinal >= 0 then
				surface.SetMaterial(armor4)
				surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
			end
		else
			surface.SetDrawColor(Color(0, 0, 0, 0))
		end
		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-450 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, hudAlpha))
	end
end

-- Weapon
function PLUGIN:WeaponIconHUDPaint()
	if ix.option.Get("DisableHUD", false) then
		return false
	else

		local lp = LocalPlayer()
		local wep = LocalPlayer():GetActiveWeapon()
		local char = lp:GetCharacter()

		if (!lp:GetCharacter() or !lp:Alive() or ix.gui.characterMenu:IsVisible()) then return end

		local gun = Material("stalkerCoP/ui/hud/status/gun.png", "noclamp smooth")
		local gun2 = Material("stalkerCoP/ui/hud/status/gun2.png", "noclamp smooth")
		local gun3 = Material("stalkerCoP/ui/hud/status/gun3.png", "noclamp smooth")
		local gun4 = Material("stalkerCoP/ui/hud/status/gun4.png", "noclamp smooth")

		--Weapon condition
		surface.SetMaterial(gun)
		if IsValid( wep ) then
			if string.sub(wep:GetClass(),1,3) == "cw_" and not string.match(wep:GetClass(),"nade") then
				if LocalPlayer():GetActiveWeapon():GetWeaponHP() then
					local weapondura = LocalPlayer():GetActiveWeapon():GetWeaponHP()
					if weapondura > 80 then
						surface.SetDrawColor(Color(0, 0, 0, 0))
					elseif weapondura > 60 and weapondura <= 80 then
						surface.SetMaterial(gun)
						surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
					elseif weapondura > 40 and weapondura <= 60 then
						surface.SetMaterial(gun2)
						surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
					elseif weapondura > 20 and weapondura <= 40 then
						surface.SetMaterial(gun3)
						surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
					elseif weapondura > 0 and weapondura <= 20 then
						surface.SetMaterial(gun4)
						surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
					end
				end
			else
				surface.SetDrawColor(Color(0, 0, 0, 0))
			end
		end
		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-400 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, hudAlpha))
	end
end

-- Weight
function PLUGIN:WeightIconHUDPaint()
	if ix.option.Get("DisableHUD", false) then
		return false
	else

		local lp = LocalPlayer()
		local char = lp:GetCharacter()
		
		if (!lp:GetCharacter() or !lp:Alive() or ix.gui.characterMenu:IsVisible()) then return end

		local weight = Material("stalkerCoP/ui/hud/status/weight.png", "noclamp smooth") 
		local weight2 = Material("stalkerCoP/ui/hud/status/weight2.png", "noclamp smooth") 
		local weight4 = Material("stalkerCoP/ui/hud/status/weight4.png", "noclamp smooth") 

		local currentCarry = char:GetData("carry", 0)
		local baseWeight = ix.weight.BaseWeight(char)
		local maxOverweight = ix.config.Get("maxOverWeight", 20)

		if char:HeavilyOverweight() then
			surface.SetMaterial(weight4)
			surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		elseif char:Overweight() then
			surface.SetMaterial(weight2)
			surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		elseif currentCarry >= (ix.config.Get("maxWeight", 30) - 10) then
			surface.SetMaterial(weight)
			surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		else
			surface.SetDrawColor(Color(255, 255, 255, 0))
		end
		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-350 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, hudAlpha))
	end
end

-- Radiation
function PLUGIN:RadiationIconHUDPaint()
	if ix.option.Get("DisableHUD", false) then
		return false
	else
	
		local lp = LocalPlayer()
		local wep = LocalPlayer():GetActiveWeapon()
		local char = lp:GetCharacter()

		if (!lp:GetCharacter() or !lp:Alive() or ix.gui.characterMenu:IsVisible()) then return end

		local rad = Material("stalkerCoP/ui/hud/status/rad.png", "noclamp smooth") 
		local rad2 = Material("stalkerCoP/ui/hud/status/rad2.png", "noclamp smooth") 
		local rad3 = Material("stalkerCoP/ui/hud/status/rad3.png", "noclamp smooth") 
		local rad4 = Material("stalkerCoP/ui/hud/status/rad4.png", "noclamp smooth")

		local heartbeatSpeed = 2.5 -- Speed of the heartbeat effect
		local maxAlpha = 255 -- Maximum alpha value
		local minAlpha = 50 -- Minimum alpha value (to avoid complete transparency)
		local time = CurTime() * heartbeatSpeed
		local alpha = math.abs(math.sin(time)) * (maxAlpha - minAlpha) + minAlpha

		surface.SetMaterial(rad)
		if LocalPlayer():getRadiation() == 0 then
			surface.SetMaterial(rad)
			surface.SetDrawColor(Color(0, 0, 0, 0))
		elseif LocalPlayer():getRadiation() > 0 and LocalPlayer():getRadiation() <= 25 then
			surface.SetMaterial(rad)
			surface.SetDrawColor(Color(255, 255, 255, math.min(alpha, hudAlpha)))
		elseif LocalPlayer():getRadiation() > 25 and LocalPlayer():getRadiation() <= 60 then
			surface.SetMaterial(rad2)
			surface.SetDrawColor(Color(255, 255, 255, math.min(alpha, hudAlpha)))
		elseif LocalPlayer():getRadiation() > 60 and LocalPlayer():getRadiation() <= 89 then
			surface.SetMaterial(rad3)
			surface.SetDrawColor(Color(255, 255, 255, math.min(alpha, hudAlpha)))
		elseif LocalPlayer():getRadiation() > 89 and LocalPlayer():getRadiation() <= 100 then
			surface.SetMaterial(rad4)
			surface.SetDrawColor(Color(255, 255, 255, math.min(alpha, hudAlpha)))
		end

		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-300 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, hudAlpha))
	end
end

-- Psyhealth
function PLUGIN:PsyhealthIconHUDPaint()
	if ix.option.Get("DisableHUD", false) then
		return false
	else

		local lp = LocalPlayer()

		if (!lp:GetCharacter() or !lp:Alive() or ix.gui.characterMenu:IsVisible()) then return end

		local psy1 = Material("stalkerCoP/ui/hud/status/psyz.png", "noclamp smooth") 
		local psy2 = Material("stalkerCoP/ui/hud/status/psyz2.png", "noclamp smooth") 
		local psy3 = Material("stalkerCoP/ui/hud/status/psyz3.png", "noclamp smooth") 
		local psy4 = Material("stalkerCoP/ui/hud/status/psyz4.png", "noclamp smooth") 

		local heartbeatSpeed = 2.5 -- Speed of the heartbeat effect
		local maxAlpha = 255 -- Maximum alpha value
		local minAlpha = 50 -- Minimum alpha value (to avoid complete transparency)
		local time = CurTime() * heartbeatSpeed
		local alpha = math.abs(math.sin(time)) * (maxAlpha - minAlpha) + minAlpha

		surface.SetDrawColor(Color(255, 255, 255, 0))
		if (lp:GetPsyHealth() <= 99) then
			surface.SetMaterial(psy1)
			surface.SetDrawColor(Color(255, 255, 255, math.min(alpha, hudAlpha)))
		end
		if (lp:GetPsyHealth() <= 75) then
			surface.SetMaterial(psy2)
			surface.SetDrawColor(Color(255, 255, 255, math.min(alpha, hudAlpha)))
		end
		if (lp:GetPsyHealth() <= 50) then
			surface.SetMaterial(psy3)
			surface.SetDrawColor(Color(255, 255, 255, math.min(alpha, hudAlpha)))
		end
		if (lp:GetPsyHealth() <= 20) then
			surface.SetMaterial(psy4)
			surface.SetDrawColor(Color(255, 255, 255, math.min(alpha, hudAlpha)))
		end
		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-250 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, hudAlpha))
	end
end

function PLUGIN:ArtifactBeltHUDPaint()
	if ix.option.Get("DisableHUD", false) then
		return false
	else

		local client = LocalPlayer() -- Get the local player

		-- Check if the client is valid and has a character
		if not IsValid(client) then return end

		local character = client:GetCharacter() -- Get the player's character
		
		-- Check if the character exists
		if not character then
			return -- Exit if there is no character
		end

		local inv = character:GetInv() -- Get the inventory
		
		-- Check if the inventory exists
		if not inv then
			return -- Exit if there is no inventory
		end

		local items = inv:GetItems() -- Get the items in the inventory

		local x = 360 * (ScrW()/1920) -- Starting X position
		local y = 950 * (ScrH()/1080) -- Y position
		local imageSize = 64 -- Size of the artifact images
		
		-- Iterate through the items to find the equipped artifact
		for _, item in pairs(items) do
			if item.isArtefact and item:GetData("equip", false) then

				-- If the item is an artifact and it is equipped
				local artifactImage = item.img -- Get the artifact image

				-- Draw the artifact image on the HUD
				surface.SetMaterial(artifactImage)
				surface.SetDrawColor(255, 255, 255, hudAlpha) -- Set color to white
				surface.DrawTexturedRect(x, y, imageSize * (ScrW()/1920), imageSize * (ScrH()/1080)) -- Draw the image (width, height)

				-- Update the x position for the next artifact
				x = x + 5 + imageSize -- Move x to the right for the next image

			end
		end
	end
end

local vignette = Material("vgui/zoom")
local exhaustSmooth = 0

if (CLIENT) then
	function ExhaustionHUD()
		local lp = LocalPlayer()

		-- Exhaustion vignette effect when stamina is low
		local staminaFraction = math.Clamp(lp:GetLocalVar("stm", 100) / 100, 0, 1)
		local exhaustion = math.max(0, (1 - staminaFraction))
		exhaustSmooth = math.Approach(exhaustSmooth, exhaustion, FrameTime() * 2) -- Smooth transition
		
		if exhaustSmooth > 0 then
			surface.SetMaterial(vignette)
			surface.SetDrawColor(255, 255, 255, 230 * exhaustSmooth)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			surface.DrawTexturedRectUV(0, 0, ScrW(), ScrH(), 1, 1, 0, 0) -- Inverted UVs for vignette effect
		end
	end

	hook.Add("HUDPaint", "ExhaustionHUD", ExhaustionHUD)

	local blurMaterial = Material("pp/blurscreen")

	function PLUGIN:RenderScreenspaceEffects()
		-- Apply color correction from earlier in the file.
		DrawColorModify(color)

		-- Add a high-quality blur overlay for the tab menu when cheapBlur is disabled,
		-- replacing the default Helix blur.
		if (not ix.option.Get("cheapBlur", false) and IsValid(ix.gui.menu)) then
			local blurAmount = (ix.gui.menu.currentBlur or 0) * 5
			if (blurAmount > 0) then
				-- Use pp/blurscreen material directly to force a real blur effect.
				surface.SetMaterial(blurMaterial)
				surface.SetDrawColor(255, 255, 255, 255)

				local scrW, scrH = ScrW(), ScrH()

				-- This loop mimics the blur passes from ix.util.DrawBlurAt for a quality effect.
				for i = -0.2, 1, 0.2 do
					blurMaterial:SetFloat("$blur", i * blurAmount)
					blurMaterial:Recompute()

					render.UpdateScreenEffectTexture()
					surface.DrawTexturedRect(0, 0, scrW, scrH)
				end
			end
		end
	end
end