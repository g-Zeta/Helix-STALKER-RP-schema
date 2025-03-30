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
local ammoS2 = Material("stalker2/ui/hud/ammo.png", "noclamp smooth")

local ammo9x18 = Material("stalker2/ui/ammunition/ammo_9x18.png", "noclamp smooth")
local ammo9x19 = Material("stalker2/ui/ammunition/ammo_9x19.png", "noclamp smooth")
local ammo12x70buck = Material("stalker2/ui/ammunition/ammo_12x70_buck.png", "noclamp smooth")
local ammo50AE = Material("spawnicons/models/kek1ch/ammo_50_ae_128.png", "noclamp smooth")
local ammo545x39 = Material("stalker2/ui/ammunition/ammo_545x39.png", "noclamp smooth")
local ammo556x45 = Material("stalker2/ui/ammunition/ammo_556x45.png", "noclamp smooth")
local ammo762x25 = Material("spawnicons/models/kek1ch/ammo_762x25_p_128.png", "noclamp smooth")
local ammo762x39 = Material("stalker2/ui/ammunition/ammo_762x39.png", "noclamp smooth")
local ammo762x54 = Material("stalker2/ui/ammunition/ammo_762x54_7n1.png", "noclamp smooth")
local ammo86x70 = Material("spawnicons/models/kek1ch/ammo_86x70_fmj_128.png", "noclamp smooth")
local ammo9x39 = Material("stalker2/ui/ammunition/ammo_9x39.png", "noclamp smooth")
local ammogauss = Material("stalker2/ui/ammunition/ammo_gauss.png", "noclamp smooth")

local minScale = 1.0  -- Minimum scale (100% original size)
local maxScale = 1.3  -- Maximum scale (130% of original size)
local scaleSpeed = 0.25   -- Speed of the scaling effect
local elapsedTime = 0.1  -- Time elapsed for the heartbeat effect

--Ammo and Clip fonts
surface.CreateFont("ClipFont", {
	font = "arial",
	size = ScreenScale(12),
	extended = true,
	weight = 600,
})
surface.CreateFont("SlashFont", {
	font = "arial",
	size = ScreenScale(10),
	extended = true,
	weight = 500,
})
surface.CreateFont("AmmoFont", {
	font = "arial",
	size = ScreenScale(10),
	extended = true,
	weight = 500,
})
--end
surface.CreateFont("stalkermainmenufont", {	--Main Menu
	font = "stalker2",
	size = ScreenScale(8),
	extended = true,
	weight = 500,
	antialias = true
})

surface.CreateFont("stalkerregularsmallfont", {	--Regular Small
	font = "arial",
	size = ScreenScale(6),
	extended = true,
	weight = 500,
	antialias = true
})

surface.CreateFont("stalkerregularsmallboldfont", {	--Regular Small Bold
	font = "arial",
	size = ScreenScale(6),
	extended = true,
	weight = 600,
	antialias = true
})

surface.CreateFont("stalkerregularfont", {	--Regular
	font = "arial",
	size = ScreenScale(8),
	extended = true,
	weight = 500,
	antialias = true
})

surface.CreateFont("stalkerregularboldfont", {	--Regular Bold
	font = "arial",
	size = ScreenScale(8),
	extended = true,
	weight = 600,
	antialias = true
})

surface.CreateFont("stalkerregularfont2", {	--Regular 2
	font = "arial",
	size = ScreenScale(10),
	extended = true,
	weight = 500, 
	antialias = true
})

surface.CreateFont("stalkerregularboldfont2", {	--Regular 2 Bold
	font = "arial",
	size = ScreenScale(10),
	extended = true,
	weight = 600, 
	antialias = true
})

surface.CreateFont("stalkerregularfont3", {	--Regular 3
	font = "arial",
	size = ScreenScale(11),
	extended = true,
	weight = 500, 
	antialias = true
})

surface.CreateFont("stalkerregulartitlefont", {	--Regular Title
	font = genericFont,
	size = ScreenScale(8),
	extended = true,
	weight = 500,
	antialias = true
})

surface.CreateFont("stalkertitlefont", {	--Title
	font = "alsina",
	size = ScreenScale(13),
	extended = true,
	weight = 500,
	antialias = true
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

function PLUGIN:RenderScreenspaceEffects()
	DrawColorModify(color)
end

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
	if ix.option.Get("DisableHUD", false) then
		return false
	else

		self:SurvivalIconHUDPaint()
		self:ArmorIconHUDPaint()
		self:WeaponIconHUDPaint()
		self:WeightIconHUDPaint()
		self:RadiationIconHUDPaint()
		self:PsyhealthIconHUDPaint()
		self:HeadgearIconHUDPaint()

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
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawTexturedRect(ScrW()-280 * (ScrW()/1920), ScrH()-195 * (ScrH() / 1080), 250 * (ScrW()/1920), 90 * (ScrH() / 1080))

	--Health bar
	surface.SetMaterial(healthbar)
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawTexturedRect(ScrW()-233 * (ScrW()/1920), ScrH()-136 * (ScrH() / 1080), (1.72*math.Clamp( LocalPlayer():Health()/LocalPlayer():GetMaxHealth()*100, 0, 100 )) * (ScrW()/1920), 17 * (ScrH() / 1080))

	--Stamina bar
	surface.SetMaterial(staminabar)
	surface.SetDrawColor(Color(255, 255, 255, 255))
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
        surface.SetDrawColor(Color(255, 255, 255, 255))
        surface.DrawTexturedRect(100 * (ScrW() / 1920), 865 * (ScrH() / 1080), 156 * (ScrW() / 1920), 191 * (ScrH() / 1080))
    end

	--Ammo UI
	surface.SetMaterial(Ammo)
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawTexturedRect(ScrW()-250 * (ScrW() / 1920), ScrH()-115 * (ScrH() / 1080), 210 * (ScrW() / 1920), 90 * (ScrH() / 1080))
	
	--Ammo display
	if IsValid( wep ) then
		if wep:HasAmmo() and wep:Clip1() >= 0 then
			draw.DrawText( tostring(wep:Clip1()) .. " / " .. tostring(lp:GetAmmoCount( wep:GetPrimaryAmmoType() )), "stalkermainmenufont", ScrW()-120 * (ScrW() / 1920), ScrH()-75 * (ScrH() / 1080), Color( 193, 136, 21, 255 ), TEXT_ALIGN_CENTER )
			if wep:GetPrimaryAmmoType() then
				if string.sub(game.GetAmmoName(wep:GetPrimaryAmmoType()) or "no", -1) == "-" then
					draw.DrawText( string.sub(game.GetAmmoName(wep:GetPrimaryAmmoType()), -3, -2) , "stalkermainmenufont", ScrW()-210 * (ScrW() / 1920), ScrH()-75 * (ScrH() / 1080), Color( 193, 136, 21, 255 ), TEXT_ALIGN_CENTER )
				end
			end
		end
	end
--// End HUD Code //--
end

--STALKER 2 HUD
function PLUGIN:S2HUDPaint()
	local lp = LocalPlayer()
	local wep = LocalPlayer():GetActiveWeapon()
	local char = lp:GetCharacter()

	if (!lp:GetCharacter() or !lp:Alive() or ix.gui.characterMenu:IsVisible()) then return end

	--UI
	surface.SetMaterial(s2hud)
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawTexturedRect(30 * (ScrW() / 1920), 930 * (ScrH() / 1080), 319 * (ScrW() / 1920), 111 * (ScrH() / 1080))
	
	--Health bar
	surface.SetMaterial(hpbar)
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawTexturedRect(ScrW()-1776 * (ScrW() / 1920), ScrH()-110 * (ScrH() / 1080), (1.88*math.Clamp( LocalPlayer():Health()/LocalPlayer():GetMaxHealth()*100, 0, 100 )) * (ScrW() / 1920), 11 * (ScrH() / 1080))
	
	--Stamina bars
	local maxStamina = 100 -- Player's maximum stamina
	local fullWidth = 171 * (ScrW() / 1920)  -- Full width of the stamina bar
	local stamina = LocalPlayer():GetLocalVar("stm", 100)  -- Get the current stamina value
	local sectionWidth = fullWidth / 3 -- Calculate the width of each segment
	local width1 = (stamina >= maxStamina * (1/3)) and sectionWidth or (sectionWidth * (stamina / (maxStamina * (1/3))))
	local width2 = (stamina >= maxStamina * (2/3)) and sectionWidth or (sectionWidth * ((stamina - maxStamina * (1/3)) / (maxStamina * (1/3))))
	local width3 = (stamina >= maxStamina) and sectionWidth or (sectionWidth * ((stamina - maxStamina * (2/3)) / (maxStamina * (1/3))))
	
	surface.SetMaterial(stmbar)
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawTexturedRect(ScrW() - 1776 * (ScrW() / 1920), ScrH() - 90 * (ScrH() / 1080), width1, 8, Color(255, 255, 255, 255))  -- First 33.33%
	surface.DrawTexturedRect(ScrW() - 1776 * (ScrW() / 1920) + sectionWidth, ScrH() - 90 * (ScrH() / 1080), width2, 8, Color(255, 255, 255, 255))  -- Second 33.33%
	surface.DrawTexturedRect(ScrW() - 1776 * (ScrW() / 1920) + 2 * sectionWidth, ScrH() - 90 * (ScrH() / 1080), width3, 8, Color(255, 255, 255, 255))  -- Third 33.33%

	--Radiation status
    local radiation = lp:getRadiation()
    local radMaterials = {}

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

    if radiation > 0 then
        -- Set the material and draw color
        surface.SetMaterial(radicon)
        surface.SetDrawColor(colorWhite)

    -- Determine color based on radiation level
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

    -- Set the material and draw color
    surface.SetMaterial(radicon)
    surface.SetDrawColor(currentColor)

        -- Calculate the size of the texture based on the heartbeat scale
        local width, height = 61 * scale * (ScrW() / 1920), 61 * scale * (ScrH() / 1080)  -- Adjust the size based on the scale
        local xPosition = ScrW() - 1880 * (ScrW() / 1920) - (width - 75 * (ScrW() / 1920)) / 2  -- Center the image based on its resized width
        local yPosition = ScrH() - 129 * (ScrH() / 1080) - (height - 75 * (ScrH() / 1080)) / 2  -- Center the image based on its resized height

        -- Draw the texture at the specified position with the scaled size
        surface.DrawTexturedRect(xPosition, yPosition, width, height)
    end

    -- Load all the materials into a table
    for i = 1, 24 do
        radMaterials[i] = Material("stalker2/ui/hud/rad" .. i .. ".png", "noclamp smooth")
    end

    local materialIndex = 1  -- Default index

    if radiation > 0 then
        -- Calculate the material index based on radiation
        materialIndex = math.min(math.floor(radiation / 4) + 1, 24)  -- Ensure it does not exceed 24

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

    -- Set the material and draw color
    surface.SetMaterial(radMaterials[materialIndex])
	surface.SetDrawColor(currentColor)

    -- Draw the texture at the specified position
    surface.DrawTexturedRect(ScrW() - 1880 * (ScrW() / 1920), ScrH() - 131 * (ScrH() / 1080), 75 * (ScrW() / 1920), 78 * (ScrH() / 1080))  -- Adjust position as needed
    else
        -- If radiation is 0, set a transparent draw color to ensure nothing is drawn
        surface.SetDrawColor(0, 0, 0, 0)  -- Fully transparent
	end

	--Ammo UI
	surface.SetMaterial(ammoS2)
	surface.SetDrawColor(Color(255, 255, 255, 240))
	surface.DrawTexturedRect(ScrW()-280 * (ScrW() / 1920), ScrH()-160 * (ScrH() / 1080), 251 * (ScrW() / 1920), 131 * (ScrH() / 1080))

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
        elseif wep.Primary.Ammo == ".50 AE" then
            ammoMaterial = ammo50AE
        elseif wep.Primary.Ammo == "5.45x39MM" then
            ammoMaterial = ammo545x39
        elseif wep.Primary.Ammo == "5.56x45MM" then
            ammoMaterial = ammo556x45
        elseif wep.Primary.Ammo == "7.62x25MM" then
            ammoMaterial = ammo762x25
        elseif wep.Primary.Ammo == "7.62x39MM" then
            ammoMaterial = ammo762x39
        elseif wep.Primary.Ammo == "7.62x54MM" then
            ammoMaterial = ammo762x54
        elseif wep.Primary.Ammo == ".338 Lapua" then
            ammoMaterial = ammo86x70
        elseif wep.Primary.Ammo == "9x39MM" then
            ammoMaterial = ammo9x39
        elseif wep.Primary.Ammo == "Batteries" then
            ammoMaterial = ammogauss
        end

        -- If a valid ammo material was found, draw it
        if ammoMaterial then
            surface.SetMaterial(ammoMaterial)
            surface.SetDrawColor(Color(255, 255, 255, 255))
            surface.DrawTexturedRect(ScrW() - 138 * (ScrW() / 1920), ScrH() - 115 * (ScrH() / 1080), 96 * (ScrW() / 1920), 48 * (ScrH() / 1080))
        end
    end

	--Ammo display
	if IsValid(wep) then
		if wep:HasAmmo() and wep:Clip1() >= 0 then
			local clipText = tostring(wep:Clip1())
			local ammoCount = tostring(lp:GetAmmoCount(wep:GetPrimaryAmmoType()))
			local slash = "/" -- The slash character
			
			-- Calculate the positions for the text
			local baseX = ScrW() - 222 * (ScrW() / 1920)
			local baseY = ScrH() - 122 * (ScrH() / 1080)

			-- Draw the Clip size
			draw.DrawText(clipText, "ClipFont", baseX, baseY, Color(200, 200, 200, 255), TEXT_ALIGN_CENTER)
			
			-- Draw the slash
			draw.DrawText(slash, "SlashFont", baseX + 34 * (ScrW() / 1920), baseY + 6 * (ScrH() / 1080), Color(200, 200, 200, 255), TEXT_ALIGN_CENTER)

			-- Draw the Ammo count
			draw.DrawText(ammoCount, "AmmoFont", baseX + 60 * (ScrW() / 1920), baseY + 6 * (ScrH() / 1080), Color(200, 200, 200, 255), TEXT_ALIGN_CENTER)
		end
	end
--// End HUD Code //--
end

ix.option.Add("StalkerHUD", ix.type.bool, false, {
    category = "STALKER Settings",
	description = "Choose between SHoC and STALKER 2 HUD."
})

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
			surface.SetDrawColor(Color(255, 255, 255, 255))
		elseif LocalPlayer():GetHunger() <= 45 and LocalPlayer():GetHunger() > 30 then
			surface.SetMaterial(hunger2)
			surface.SetDrawColor(Color(255, 255, 255, 255))
		elseif LocalPlayer():GetHunger() <= 30 and LocalPlayer():GetHunger() > 15 then
			surface.SetMaterial(hunger3)
			surface.SetDrawColor(Color(255, 255, 255, 255))
		elseif LocalPlayer():GetHunger() <= 15 then
			surface.SetMaterial(hunger4)
			surface.SetDrawColor(Color(255, 255, 255, 255))
		end
		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-550 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, 255))

		--Thirst
		surface.SetMaterial(thirst)
		if LocalPlayer():GetThirst() > 60 then
			surface.SetMaterial(thirst)
			surface.SetDrawColor(Color(0, 0, 0, 0))
		elseif LocalPlayer():GetThirst() <= 60 and LocalPlayer():GetThirst() > 45 then
			surface.SetMaterial(thirst)
			surface.SetDrawColor(Color(255, 255, 255, 255))
		elseif LocalPlayer():GetThirst() <= 45 and LocalPlayer():GetThirst() > 30 then
			surface.SetMaterial(thirst2)
			surface.SetDrawColor(Color(255, 255, 255, 255))
		elseif LocalPlayer():GetThirst() <= 30 and LocalPlayer():GetThirst() > 15 then
			surface.SetMaterial(thirst3)
			surface.SetDrawColor(Color(255, 255, 255, 255))
		elseif LocalPlayer():GetThirst() <= 15 then
			surface.SetMaterial(thirst4)
			surface.SetDrawColor(Color(255, 255, 255, 255))
		end
		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-600 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, 255))
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
				surface.SetDrawColor(Color(255, 255, 255, 255))
			elseif equippedpartdurafinal < 6000 and equippedpartdurafinal >= 4000 then
				surface.SetMaterial(helmet2)
				surface.SetDrawColor(Color(255, 255, 255, 255))
			elseif equippedpartdurafinal < 4000 and equippedpartdurafinal >= 2000 then
				surface.SetMaterial(helmet3)
				surface.SetDrawColor(Color(255, 255, 255, 255))
			elseif equippedpartdurafinal < 2000 and equippedpartdurafinal >= 0 then
				surface.SetMaterial(helmet4)
				surface.SetDrawColor(Color(255, 255, 255, 255))
			end
		else
			surface.SetDrawColor(Color(0, 0, 0, 0))
		end
		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-500 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, 255))
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
				surface.SetDrawColor(Color(255, 255, 255, 255))
			elseif equippedpartdurafinal < 6000 and equippedpartdurafinal >= 4000 then
				surface.SetMaterial(armor2)
				surface.SetDrawColor(Color(255, 255, 255, 255))
			elseif equippedpartdurafinal < 4000 and equippedpartdurafinal >= 2000 then
				surface.SetMaterial(armor3)
				surface.SetDrawColor(Color(255, 255, 255, 255))
			elseif equippedpartdurafinal < 2000 and equippedpartdurafinal >= 0 then
				surface.SetMaterial(armor4)
				surface.SetDrawColor(Color(255, 255, 255, 255))
			end
		else
			surface.SetDrawColor(Color(0, 0, 0, 0))
		end
		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-450 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, 255))
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
						surface.SetDrawColor(Color(255, 255, 255, 255))
					elseif weapondura > 40 and weapondura <= 60 then
						surface.SetMaterial(gun2)
						surface.SetDrawColor(Color(255, 255, 255, 255))
					elseif weapondura > 20 and weapondura <= 40 then
						surface.SetMaterial(gun3)
						surface.SetDrawColor(Color(255, 255, 255, 255))
					elseif weapondura > 0 and weapondura <= 20 then
						surface.SetMaterial(gun4)
						surface.SetDrawColor(Color(255, 255, 255, 255))
					end
				end
			else
				surface.SetDrawColor(Color(0, 0, 0, 0))
			end
		end
		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-400 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, 255))
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
			surface.SetDrawColor(Color(255, 255, 255, 255))
		elseif char:Overweight() then
			surface.SetMaterial(weight2)
			surface.SetDrawColor(Color(255, 255, 255, 255))
		elseif currentCarry >= (ix.config.Get("maxWeight", 30) - 10) then
			surface.SetMaterial(weight)
			surface.SetDrawColor(Color(255, 255, 255, 255))
		else
			surface.SetDrawColor(Color(255, 255, 255, 0))
		end
		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-350 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, 255))
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
			surface.SetDrawColor(Color(255, 255, 255, alpha))
		elseif LocalPlayer():getRadiation() > 25 and LocalPlayer():getRadiation() <= 60 then
			surface.SetMaterial(rad2)
			surface.SetDrawColor(Color(255, 255, 255, alpha))
		elseif LocalPlayer():getRadiation() > 60 and LocalPlayer():getRadiation() <= 89 then
			surface.SetMaterial(rad3)
			surface.SetDrawColor(Color(255, 255, 255, alpha))
		elseif LocalPlayer():getRadiation() > 89 and LocalPlayer():getRadiation() <= 100 then
			surface.SetMaterial(rad4)
			surface.SetDrawColor(Color(255, 255, 255, alpha))
		end

		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-300 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, 255))
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

		surface.SetDrawColor(Color(255, 255, 255, 0))
		if (lp:GetPsyHealth() <= 99) then
			surface.SetMaterial(psy1)
			surface.SetDrawColor(Color(255, 255, 255, 255))
		end
		if (lp:GetPsyHealth() <= 75) then
			surface.SetMaterial(psy2)
			surface.SetDrawColor(Color(255, 255, 255, 255))
		end
		if (lp:GetPsyHealth() <= 50) then
			surface.SetMaterial(psy3)
			surface.SetDrawColor(Color(255, 255, 255, 255))
		end
		if (lp:GetPsyHealth() <= 20) then
			surface.SetMaterial(psy4)
			surface.SetDrawColor(Color(255, 255, 255, 255))
		end
		surface.DrawTexturedRect(ScrW()-80 * (ScrW() / 1920), ScrH()-250 * (ScrH() / 1080), 35 * (ScrW() / 1920), 35 * (ScrH() / 1080), Color(0, 255, 0, 255))
	end
end