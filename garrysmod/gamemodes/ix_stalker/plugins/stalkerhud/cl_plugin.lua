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

-- STALKER SHoC Buff stat icons
local buffIconsSHOC = {
	{ name = "buff_slowheal", material = Material("stalkerCoP/ui/hud/status/healmin.png", "noclamp smooth") },
	{ name = "buff_radiationremoval", material = Material("stalkerCoP/ui/hud/status/radmin.png", "noclamp smooth") },
	{ name = "buff_staminarestore", material = Material("stalkerCoP/ui/hud/status/staminamin.png", "noclamp smooth") },
	{ name = "buff_weight", material = Material("stalkerCoP/ui/hud/status/weightmin.png", "noclamp smooth") },
	{ name = "buff_chemprotect", material = Material("stalkerCoP/ui/hud/status/chempro.png", "noclamp smooth") },
	{ name = "buff_psyprotect", material = Material("stalkerCoP/ui/hud/status/psypro.png", "noclamp smooth") },
	{ name = "buff_radprotect", material = Material("stalkerCoP/ui/hud/status/radpro.png", "noclamp smooth") }
}

--STALKER 2 HUD textures
local s2hud = Material("stalker2/ui/hud/s2hud.png", "noclamp smooth")
local hpbar = Material("stalker2/ui/hud/hpbar.png", "noclamp smooth")
local stmbar = Material("stalker2/ui/hud/stmbar.png", "noclamp smooth")
local radicon = Material("stalker2/ui/hud/radicon.png", "noclamp smooth")
local radsmeter = Material("stalker2/ui/hud/rads.vtf", "noclamp smooth")
local ammoS2 = Material("stalker2/ui/hud/ammo.png", "noclamp smooth")
local ammoSelector = Material("stalker2/ui/hud/ammotype_selector.png", "noclamp smooth")

-- STALKER 2 Buff stat icons
local buffIconsS2 = {
	{ name = "buff_slowheal", material = Material("stalker2/ui/hud/stat_healing.png", "noclamp smooth") },
	{ name = "buff_radiationremoval", material = Material("stalker2/ui/hud/stat_rads.png", "noclamp smooth") },
	{ name = "buff_staminarestore", material = Material("stalker2/ui/hud/stat_stamina.png", "noclamp smooth") },
	{ name = "buff_weight", material = Material("stalker2/ui/hud/stat_weightboost.png", "noclamp smooth") },
	{ name = "buff_chemprotect", material = Material("stalker2/ui/hud/stat_prot_chemical.png", "noclamp smooth") },
	{ name = "buff_psyprotect", material = Material("stalker2/ui/hud/stat_prot_psi.png", "noclamp smooth") },
	{ name = "buff_radprotect", material = Material("stalker2/ui/hud/stat_prot_rads.png", "noclamp smooth") },
}


local minScale = 0.9
local maxScale = 1.3
local scaleSpeed = 0.3
local elapsedTime = 0.1

-- Fading HUD logic
local hudAlpha = 255
local lastHUDActivity = 0
local hudFadeDuration = 1 -- seconds

local function ResetHUDFade()
    lastHUDActivity = CurTime()
    hudAlpha = 255
end

hook.Add("Think", "HUDThink", function()
    local lp = LocalPlayer()
    if not IsValid(lp) then return end
    local char = lp:GetCharacter()
    if not char then return end

    if not ix.option.Get("HUDImmersiveMode", false) then
        hudAlpha = 255
        return
    end

    -- Keep HUD visible if player has any radiation
    local radiation = 0
    if lp.getRadiation then radiation = lp:getRadiation() or 0 end
    if radiation > 0 then
        lastHUDActivity = CurTime()
        hudAlpha = 255
        return
    end

    -- Keep HUD visible if health is 40 or below
    if lp:Health() <= 40 then
        lastHUDActivity = CurTime()
        hudAlpha = 255
        return
    end

    -- Keep HUD visible if stamina is 30 or below
    if lp:GetLocalVar("stm", 100) <= 30 then
        lastHUDActivity = CurTime()
        hudAlpha = 255
        return
    end

    -- Keep HUD visible if heavily overweight
    if char:HeavilyOverweight() then
        lastHUDActivity = CurTime()
        hudAlpha = 255
        return
    end

    -- Keep HUD visible if hunger or thirst are below 15
    if (lp:GetHunger() and lp:GetHunger() < 15) or (lp:GetThirst() and lp:GetThirst() < 15) then
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

    local HUDFadeDelay = ix.option.Get("HUDFadeDelay", 5)
    if CurTime() - lastHUDActivity > HUDFadeDelay then
        hudAlpha = math.max(0, hudAlpha - (255 / hudFadeDuration) * FrameTime())
    end
end)

local wasTriggerKeyPressed = false
local prevHealth = nil
local prevClip = nil
local prevWepClass = nil

hook.Add("Think", "HUDRKeyCheck", function()
    if not ix.option.Get("HUDImmersiveMode", false) then return end

    local lp = LocalPlayer()
    if not IsValid(lp) then
        prevClip = nil
        prevWepClass = nil
        return
    end

    if prevHealth == nil then
        prevHealth = lp:Health()
    end

    -- Trigger key detection (fires once per press)
    local triggerKey = ix.option.Get("HUDtriggerkey", "R")
    local isTriggerKeyDown = input.IsKeyDown(input.GetKeyCode(triggerKey))
    if isTriggerKeyDown and not wasTriggerKeyPressed then
        ResetHUDFade()
    end
    wasTriggerKeyPressed = isTriggerKeyDown

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
surface.CreateFont("AmmoNameFont", {
	font = "arial",
	size = ScreenScale(5),
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

local function isInteractivePanel(panel)
	if not IsValid(panel) then return false end

	if panel.DoClick then return true end

	if not panel.GetCursor then return false end

	local cur = panel:GetCursor()
	return cur == "hand" or cur == "beam"
end

local function isMenuOpen()
	if IsValid(ix.gui.menu) and not ix.gui.menu.bClosing then return true end
	if IsValid(ix.gui.characterMenu) then return true end

	return false
end

local function shouldDrawCustomCursor()
	if not ix.option.Get("cursor", false) then return false end
	if not isMenuOpen() then return false end
	if isInteractivePanel(vgui.GetHoveredPanel()) then return false end

	return true
end

local cursorMaterial = Material("stalker/cursor.vmt")

local function cursorDraw()
	if shouldDrawCustomCursor() then
		local x, y = gui.MousePos()
		if (x != 0 && y != 0) then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(cursorMaterial)
			surface.DrawTexturedRect(x, y, 60, 60)
		end
	end
end

local lastBlanked = nil
local lastOriginalCursor = nil

local function cursorThink()
	if lastBlanked and IsValid(lastBlanked) then
		lastBlanked:SetCursor(lastOriginalCursor or "arrow")
		lastBlanked = nil
		lastOriginalCursor = nil
	end

	if shouldDrawCustomCursor() then
		local hover = vgui.GetHoveredPanel()
		if IsValid(hover) then
			lastOriginalCursor = (hover.GetCursor and hover:GetCursor()) or "arrow"
			lastBlanked = hover
			hover:SetCursor("blank")
		end
	end
end

hook.Add("DrawOverlay", "Draw_Cursor_Function_FGSHAR", cursorDraw)
hook.Add("Think", "Cursor_Think_Function_FGSHAR", cursorThink)

function DrawBuffTimer(endTime, x, y)
	local timeLeft = math.ceil(endTime - CurTime())
	if (timeLeft > 0 and timeLeft < 9999) then
		draw.SimpleTextOutlined(timeLeft, "ixSmallFont", x + 14, y, Color(180, 180, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
	end
end

function PLUGIN:PostDrawHUD()
	if (hudAlpha <= 0) then return end
	-- Also hide the HUD if the tab menu is open and our custom blur is active.
	if ix.option.Get("DisableHUD", false) or (not ix.option.Get("cheapBlur", false) and IsValid(ix.gui.menu)) then
		return false
	else

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

    -- Player stance indicator (hidden in noclip/observer)
    local moveType = lp:GetMoveType()
    if moveType != MOVETYPE_NOCLIP and lp:GetObserverMode() == OBS_MODE_NONE then
        local stanceMaterial
        local velocity = lp:GetVelocity()
        if lp:Crouching() and velocity:Length() == 0 then
            stanceMaterial = posecrouching
        elseif lp:Crouching() and velocity:Length() > 0 then
            stanceMaterial = posecrouchmove
        elseif velocity:Length() == 0 then
            stanceMaterial = poseidle
        elseif velocity:Length() < 100 and moveType == MOVETYPE_WALK then
            stanceMaterial = posewalking
        elseif velocity:Length() > 100 and moveType == MOVETYPE_WALK then
            stanceMaterial = poserunning
        end

        if stanceMaterial then
            surface.SetMaterial(stanceMaterial)
            surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
            surface.DrawTexturedRect(100 * (ScrW() / 1920), 865 * (ScrH() / 1080), 156 * (ScrW() / 1920), 191 * (ScrH() / 1080))
        end
    end

	--Ammo UI
	surface.SetMaterial(Ammo)
	surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
	surface.DrawTexturedRect(ScrW()-250 * (ScrW() / 1920), ScrH()-115 * (ScrH() / 1080), 210 * (ScrW() / 1920), 90 * (ScrH() / 1080))
	
	--Ammo display
	if IsValid( wep ) then
		if wep:HasAmmo() and wep:Clip1() >= 0 then
			draw.DrawText( tostring(wep:Clip1()) .. "/" .. tostring(lp:GetAmmoCount( wep:GetPrimaryAmmoType() )), "stalker2regularboldfont", ScrW()-110 * (ScrW() / 1920), ScrH()-75 * (ScrH() / 1080), Color( 193, 136, 21, hudAlpha ), TEXT_ALIGN_CENTER )
			if wep:GetPrimaryAmmoType() then
				if string.sub(game.GetAmmoName(wep:GetPrimaryAmmoType()) or "no", -1) == "-" then
					draw.DrawText( string.sub(game.GetAmmoName(wep:GetPrimaryAmmoType()), -3, -2) , "stalker2regularboldfont", ScrW()-210 * (ScrW() / 1920), ScrH()-75 * (ScrH() / 1080), Color( 193, 136, 21, hudAlpha ), TEXT_ALIGN_CENTER )
				end
			end
		end
	end

	local ammo9x18 = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_9x18.png", "noclamp smooth")
	local ammo9x18ap = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_9x18_ap.png", "noclamp smooth")
	local ammo9x19 = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_9x19.png", "noclamp smooth")
	local ammo9x19ap = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_9x19_ap.png", "noclamp smooth")
	local ammo45acp = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_45acp.png", "noclamp smooth")
	local ammo45acpap = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_45acp_ap.png", "noclamp smooth")
	local ammo12x70buck = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_12x70_buck.png", "noclamp smooth")
	local ammo12x70dart = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_12x70_ap.png", "noclamp smooth")
	local ammo12x70slug = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_12x70_slug.png", "noclamp smooth")
	local ammo545x39 = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_545x39.png", "noclamp smooth")
	local ammo545x39ap = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_545x39_ap.png", "noclamp smooth")
	local ammo545x39hp = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_545x39_hp.png", "noclamp smooth")
	local ammo556x45 = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_556x45.png", "noclamp smooth")
	local ammo556x45ap = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_556x45_ap.png", "noclamp smooth")
	local ammo556x45hp = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_556x45_hp.png", "noclamp smooth")
	local ammo762x39 = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_762x39.png", "noclamp smooth")
	local ammo762x39ap = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_762x39_ap.png", "noclamp smooth")
	local ammo762x51 = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_762x51.png", "noclamp smooth")
	local ammo762x51ap = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_762x51_ap.png", "noclamp smooth")
	local ammo762x54 = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_762x54.png", "noclamp smooth")
	local ammo762x54ap = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_762x54_ap.png", "noclamp smooth")
	local ammo762x54hp = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_762x54_hp.png", "noclamp smooth")
	local ammo9x39 = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_9x39.png", "noclamp smooth")
	local ammo9x39ap = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_9x39_ap.png", "noclamp smooth")
	local ammogauss = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_gauss.png", "noclamp smooth")
	local ammorpg = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_rpg.png", "noclamp smooth")
	local ammom203 = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_m203.png", "noclamp smooth")
	local ammovog25 = Material("stalkerAnomaly/mods/Maids_Vanilla_HD_icons/ui/ammunition/ammo_vog25.png", "noclamp smooth")

	local statusiconSize = 35
	local statusIconX = ScrW() - 80 * (ScrW() / 1920)
	local currentStatusY = ScrH() - 300 * (ScrH() / 1080)
	local statusYIncrement = -50 * (ScrH() / 1080)
	local iconW = statusiconSize * (ScrW() / 1920)
	local iconH = statusiconSize * (ScrH() / 1080)
	
	local heartbeatSpeed = 2.5 -- Speed of the heartbeat effect
	local maxAlpha = 255 -- Maximum alpha value
	local minAlpha = 50 -- Minimum alpha value (to avoid complete transparency)
	local time = CurTime() * heartbeatSpeed
	local alpha = math.abs(math.sin(time)) * (maxAlpha - minAlpha) + minAlpha
	
	-- Bleeding status icon
	local bleedMats = {
		Material("stalkerCoP/ui/hud/status/bleed.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/bleed2.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/bleed3.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/bleed4.png", "noclamp smooth")
	}

	local bleeding = char:GetData("Bleeding", 0) > 0
	local health = lp:Health()

	if bleeding or timer.Exists(lp:Name() .. "res_bleed") then
		if health < 100 then
			local matIndex = 1
			if health < 80 then matIndex = 2 end
			if health < 50 then matIndex = 3 end
			if health < 25 then matIndex = 4 end

			surface.SetMaterial(bleedMats[matIndex])
			surface.SetDrawColor(Color(255, 255, 255, math.min(alpha, hudAlpha)))
			surface.DrawTexturedRect(statusIconX, currentStatusY, iconW, iconH)
			currentStatusY = currentStatusY + statusYIncrement
		end
	end

	--Psyhealth status icon
	local psyMats = {
		Material("stalkerCoP/ui/hud/status/psyhealth.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/psyhealth2.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/psyhealth3.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/psyhealth4.png", "noclamp smooth")
	}
	local psyLvl = lp:GetPsyHealth()

	if (psyLvl <= 99) then
		local matIndex = 1
		if psyLvl <= 75 then matIndex = 2 end
		if psyLvl <= 50 then matIndex = 3 end
		if psyLvl <= 20 then matIndex = 4 end

		surface.SetMaterial(psyMats[matIndex])
		surface.SetDrawColor(Color(255, 255, 255, math.min(alpha, hudAlpha)))
		surface.DrawTexturedRect(statusIconX, currentStatusY, iconW, iconH)
		currentStatusY = currentStatusY + statusYIncrement
	end

	--Radiation status icon
	local radMats = {
		Material("stalkerCoP/ui/hud/status/rad.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/rad2.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/rad3.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/rad4.png", "noclamp smooth")
	}

	local radiationLvl = LocalPlayer():getRadiation()

	if radiationLvl > 0 then
		local matIndex = 1
		if radiationLvl > 25 then matIndex = 2 end
		if radiationLvl > 60 then matIndex = 3 end
		if radiationLvl > 89 then matIndex = 4 end

		surface.SetMaterial(radMats[matIndex])
		surface.SetDrawColor(Color(255, 255, 255, math.min(alpha, hudAlpha)))
		surface.DrawTexturedRect(statusIconX, currentStatusY, iconW, iconH)
		currentStatusY = currentStatusY + statusYIncrement
	end

	--Weight status icon
	local weightMats = {
		weight = Material("stalkerCoP/ui/hud/status/weight.png", "noclamp smooth"),
		weight2 = Material("stalkerCoP/ui/hud/status/weight2.png", "noclamp smooth"),
		weight4 = Material("stalkerCoP/ui/hud/status/weight4.png", "noclamp smooth")
	}

	local currentCarry = char:GetData("carry", 0)
	local maxWeight = ix.config.Get("maxWeight", 30)

	if currentCarry >= maxWeight then
		local mat = weightMats.weight
		if char:Overweight() then mat = weightMats.weight2 end
		if char:HeavilyOverweight() then mat = weightMats.weight4 end

		surface.SetMaterial(mat)
		surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		surface.DrawTexturedRect(statusIconX, currentStatusY, iconW, iconH)
		currentStatusY = currentStatusY + statusYIncrement
	end

	--Weapon status icon
	local gunMats = {
		Material("stalkerCoP/ui/hud/status/gun.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/gun2.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/gun3.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/gun4.png", "noclamp smooth")
	}

	--Weapon condition
	if IsValid( wep ) then
		if string.sub(wep:GetClass(),1,3) == "cw_" and not string.match(wep:GetClass(),"nade") then
			if LocalPlayer():GetActiveWeapon():GetWeaponHP() then
				local weapondura = LocalPlayer():GetActiveWeapon():GetWeaponHP()
				if weapondura <= 80 then
					local matIndex = 1
					if weapondura <= 60 then matIndex = 2 end
					if weapondura <= 40 then matIndex = 3 end
					if weapondura <= 20 then matIndex = 4 end

					surface.SetMaterial(gunMats[matIndex])
					surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
					surface.DrawTexturedRect(statusIconX, currentStatusY, iconW, iconH)
					currentStatusY = currentStatusY + statusYIncrement
				end
			end
		end
	end

	--Armor status icon
	local equippedarmor = LocalPlayer():getEquippedBodyArmor()
	local armorDura = 10000
	local armorDuraFinal = 10000

	local armorMats = {
		Material("stalkerCoP/ui/hud/status/armor.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/armor2.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/armor3.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/armor4.png", "noclamp smooth")
	}

	if equippedarmor then
		if equippedarmor:GetData("durability") and equippedarmor:GetData("durability") < armorDura then
			armorDura = equippedarmor:GetData("durability")
			if armorDuraFinal > armorDura then
				armorDuraFinal = armorDura
			end
		end
	end

	if armorDuraFinal < 8000 then
		local matIndex = 1
		if armorDuraFinal < 6000 then matIndex = 2 end
		if armorDuraFinal < 4000 then matIndex = 3 end
		if armorDuraFinal < 2000 then matIndex = 4 end

		surface.SetMaterial(armorMats[matIndex])
		surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		surface.DrawTexturedRect(statusIconX, currentStatusY, iconW, iconH)
		currentStatusY = currentStatusY + statusYIncrement
	end

	--Headgear status icon
	local equippedgasmask = LocalPlayer():getEquippedGasmask()
	local equippedhelmet = LocalPlayer():getEquippedHelmet() 
	local headDura = 10000
	local headDuraFinal = 10000

	local helmetMats = {
		Material("stalkerCoP/ui/hud/status/helmet.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/helmet2.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/helmet3.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/helmet4.png", "noclamp smooth")
	}

	if equippedgasmask then
		if equippedgasmask:GetData("durability") and equippedgasmask:GetData("durability") < headDura then
			headDura = equippedgasmask:GetData("durability")
			if headDuraFinal > headDura then
				headDuraFinal = headDura
			end
		end
	end

	if equippedhelmet then
		if equippedhelmet:GetData("durability") and equippedhelmet:GetData("durability") < headDura then
			headDura = equippedhelmet:GetData("durability")
			if headDuraFinal > headDura then
				headDuraFinal = headDura
			end
		end
	end

	if headDuraFinal < 8000 then
		local matIndex = 1
		if headDuraFinal < 6000 then matIndex = 2 end
		if headDuraFinal < 4000 then matIndex = 3 end
		if headDuraFinal < 2000 then matIndex = 4 end

		surface.SetMaterial(helmetMats[matIndex])
		surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		surface.DrawTexturedRect(statusIconX, currentStatusY, iconW, iconH)
		currentStatusY = currentStatusY + statusYIncrement
	end

	--Hunger and thirst status icons
	local hungerMats = {
		Material("stalkerCoP/ui/hud/status/hunger.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/hunger2.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/hunger3.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/hunger4.png", "noclamp smooth")
	}
	
	local thirstMats = {
		Material("stalkerCoP/ui/hud/status/thirst.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/thirst2.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/thirst3.png", "noclamp smooth"),
		Material("stalkerCoP/ui/hud/status/thirst4.png", "noclamp smooth")
	}
	
	--Hunger
	local hungerLvl = LocalPlayer():GetHunger()
	if hungerLvl <= 60 then
		local matIndex = 1
		if hungerLvl <= 45 then matIndex = 2 end
		if hungerLvl <= 30 then matIndex = 3 end
		if hungerLvl <= 15 then matIndex = 4 end

		surface.SetMaterial(hungerMats[matIndex])
		surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		surface.DrawTexturedRect(statusIconX, currentStatusY, iconW, iconH)
		currentStatusY = currentStatusY + statusYIncrement
	end
	
	--Thirst
	local thirstLvl = LocalPlayer():GetThirst()
	if thirstLvl <= 60 then
		local matIndex = 1
		if thirstLvl <= 45 then matIndex = 2 end
		if thirstLvl <= 30 then matIndex = 3 end
		if thirstLvl <= 15 then matIndex = 4 end
		
		surface.SetMaterial(thirstMats[matIndex])
		surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
		surface.DrawTexturedRect(statusIconX, currentStatusY, iconW, iconH)
		currentStatusY = currentStatusY + statusYIncrement
	end

	local currentBuffX = ScrW() - 260
	local buffY = ScrH() - 229
	local buffW, buffH = 28, 32
	local buffXIncrement = 30

	for _, iconData in ipairs(buffIconsSHOC) do
		local buff = LocalPlayer():HasBuff(iconData.name)
		if buff then
			surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
			surface.SetMaterial(iconData.material)
			surface.DrawTexturedRect(currentBuffX, buffY, buffW, buffH)
			DrawBuffTimer(buff[1], currentBuffX, buffY)
			currentBuffX = currentBuffX + buffXIncrement
		end
	end

	--// End HUD Code //--
end

local ammoOrder = {
	["Normal"] = 1,
	["am_armorpiercing"] = 2,
	["am_hollowpoint"] = 3,
	["am_matchgrade"] = 4,
	["am_slugrounds"] = 5,
	["am_flechetterounds"] = 6,
	["am_birdshot"] = 7,
	["am_trishot"] = 8,
	["am_penetrator"] = 9,
	["am_zoneloaded"] = 10,
}

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

	local status1 = Material("stalker2/ui/hud/stat_weight.png", "noclamp smooth")
	local status2 = Material("stalker2/ui/hud/stat_hunger.png", "noclamp smooth")
	local status3 = Material("stalker2/ui/hud/stat_thirst.png", "noclamp smooth")
	local status4 = Material("stalker2/ui/hud/stat_bleeding.png", "noclamp smooth")

	local statusiconSize = 25
	
	local currentStatusX = hudX + 70 * scaleX
	local statusXIncrement = 30 * scaleX
	
	-- Weight status icon
	local currentCarry = char:GetData("carry", 0)
	local maxWeight = ix.config.Get("maxWeight", 30)
	local maxOverWeight = ix.config.Get("maxOverWeight", 20)

	if (currentCarry > maxWeight) then
		local weightAlpha = math.Clamp((currentCarry / (maxWeight + maxOverWeight) + 0.1) * 255, 0, 255)
		local colorX = math.min(weightAlpha, 255)
		local color = Color(colorX, colorX, colorX, math.min(weightAlpha, hudAlpha))

		if (char:HeavilyOverweight()) then
			color = Color(200, 0, 0, hudAlpha)
		end

		surface.SetMaterial(status1)
		surface.SetDrawColor(color)
		surface.DrawTexturedRect(currentStatusX, hudY + 70 * scaleY, statusiconSize, statusiconSize)
		currentStatusX = currentStatusX + statusXIncrement
	end

	-- Hunger status icon
	local hunger = lp:GetHunger()
	if (hunger < 75) then
		local hungerAlpha = math.Clamp(((100 - hunger) / 75) * 255, 0, 255)
		local colorX = math.min(hungerAlpha, 255)
		local color = Color(colorX, colorX, colorX, math.min(hungerAlpha, hudAlpha))

		if (hunger <= 15) then
			color = Color(200, 0, 0, hudAlpha)
		end

		surface.SetMaterial(status2)
		surface.SetDrawColor(color)
		surface.DrawTexturedRect(currentStatusX, hudY + 70 * scaleY, statusiconSize * scaleX, statusiconSize * scaleY)
		currentStatusX = currentStatusX + statusXIncrement
	end

	-- Thirst status icon
	local thirst = lp:GetThirst()
	if (thirst < 75) then
		local thirstAlpha = math.Clamp(((100 - thirst) / 75) * 255, 0, 255)
		local colorX = math.min(thirstAlpha, 255)
		local color = Color(colorX, colorX, colorX, math.min(thirstAlpha, hudAlpha))

		if (thirst <= 15) then
			color = Color(200, 0, 0, hudAlpha)
		end

		surface.SetMaterial(status3)
		surface.SetDrawColor(color)
		surface.DrawTexturedRect(currentStatusX, hudY + 70 * scaleY, statusiconSize, statusiconSize)
		currentStatusX = currentStatusX + statusXIncrement
	end

	-- Bleeding status icon
	local bleeding = char:GetData("Bleeding", 0) > 0

	if (bleeding or timer.Exists(lp:Name() .. "res_bleed")) then
		surface.SetMaterial(status4)
		surface.SetDrawColor(Color(200, 0, 0, hudAlpha))
		surface.DrawTexturedRect(currentStatusX, hudY + 70 * scaleY, statusiconSize, statusiconSize)
		currentStatusX = currentStatusX + statusXIncrement
	end

	-- Buff stat icons
	local currentBuffX = hudX + 70 * scaleX
	local buffXIncrement = 30 * scaleX

	for _, iconData in ipairs(buffIconsS2) do
		local buff = LocalPlayer():HasBuff(iconData.name)
		if buff then
			surface.SetDrawColor(Color(255, 255, 255, hudAlpha))
			surface.SetMaterial(iconData.material)
			surface.DrawTexturedRect(currentBuffX, hudY - 15 * scaleY, statusiconSize, statusiconSize)
			DrawBuffTimer(buff[1], currentBuffX, hudY - 15 * scaleY)
			currentBuffX = currentBuffX + buffXIncrement
		end
	end

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

	local ammo9x18 = Material("stalker2/ui/ammunition/ammo_9x18.png", "noclamp smooth")
	local ammo9x18ap = Material("stalker2/ui/ammunition/ammo_9x18_ap.png", "noclamp smooth")
	local ammo9x19 = Material("stalker2/ui/ammunition/ammo_9x19.png", "noclamp smooth")
	local ammo9x19ap = Material("stalker2/ui/ammunition/ammo_9x19_ap.png", "noclamp smooth")
	local ammo45acp = Material("stalker2/ui/ammunition/ammo_45acp.png", "noclamp smooth")
	local ammo45acpap = Material("stalker2/ui/ammunition/ammo_45acp_ap.png", "noclamp smooth")
	local ammo45acphp = Material("stalker2/ui/ammunition/ammo_45acp_hp.png", "noclamp smooth")
	local ammo12x70buck = Material("stalker2/ui/ammunition/ammo_12x70_buck.png", "noclamp smooth")
	local ammo12x70dart = Material("stalker2/ui/ammunition/ammo_12x70_dart.png", "noclamp smooth")
	local ammo12x70slug = Material("stalker2/ui/ammunition/ammo_12x70_slug.png", "noclamp smooth")
	local ammo545x39 = Material("stalker2/ui/ammunition/ammo_545x39.png", "noclamp smooth")
	local ammo545x39ap = Material("stalker2/ui/ammunition/ammo_545x39_ap.png", "noclamp smooth")
	local ammo545x39hp = Material("stalker2/ui/ammunition/ammo_545x39_hp.png", "noclamp smooth")
	local ammo556x45 = Material("stalker2/ui/ammunition/ammo_556x45.png", "noclamp smooth")
	local ammo556x45ap = Material("stalker2/ui/ammunition/ammo_556x45_ap.png", "noclamp smooth")
	local ammo556x45hp = Material("stalker2/ui/ammunition/ammo_556x45_hp.png", "noclamp smooth")
	local ammo556x45mg = Material("stalker2/ui/ammunition/ammo_556x45_mg.png", "noclamp smooth")
	local ammo762x39 = Material("stalker2/ui/ammunition/ammo_762x39.png", "noclamp smooth")
	local ammo762x39ap = Material("stalker2/ui/ammunition/ammo_762x39_ap.png", "noclamp smooth")
	local ammo762x39hp = Material("stalker2/ui/ammunition/ammo_762x39_hp.png", "noclamp smooth")
	local ammo762x51 = Material("stalker2/ui/ammunition/ammo_308.png", "noclamp smooth")
	local ammo762x51ap = Material("stalker2/ui/ammunition/ammo_308_ap.png", "noclamp smooth")
	local ammo762x51mg = Material("stalker2/ui/ammunition/ammo_308_mg.png", "noclamp smooth")
	local ammo762x54 = Material("stalker2/ui/ammunition/ammo_762x54.png", "noclamp smooth")
	local ammo762x54ap = Material("stalker2/ui/ammunition/ammo_762x54_ap.png", "noclamp smooth")
	local ammo762x54mg = Material("stalker2/ui/ammunition/ammo_762x54_mg.png", "noclamp smooth")
	local ammo9x39 = Material("stalker2/ui/ammunition/ammo_9x39.png", "noclamp smooth")
	local ammo9x39ap = Material("stalker2/ui/ammunition/ammo_9x39_ap.png", "noclamp smooth")
	local ammo9x39hp = Material("stalker2/ui/ammunition/ammo_9x39_hp.png", "noclamp smooth")
	local ammo9x39mg = Material("stalker2/ui/ammunition/ammo_9x39_mg.png", "noclamp smooth")
	local ammogauss = Material("stalker2/ui/ammunition/ammo_gauss.png", "noclamp smooth")
	local ammorpg = Material("stalker2/ui/ammunition/ammo_pg7v.png", "noclamp smooth")
	local ammom203 = Material("stalker2/ui/ammunition/ammo_m203.png", "noclamp smooth")
	local ammovog25 = Material("stalker2/ui/ammunition/ammo_vog25.png", "noclamp smooth")

    -- Display ammo icon based on the weapon's primary ammo type
    if IsValid(wep) and wep.Primary then
        local ammoMaterial = nil

        -- Determine the material based on the ammo type
        if wep.Primary.Ammo == "9x18MM" then
            ammoMaterial = ammo9x18
		elseif wep.Primary.Ammo == "9x18MM -AP-" then
			ammoMaterial = ammo9x18ap
		elseif wep.Primary.Ammo == "9x18MM -HP-" then
			ammoMaterial = ammo9x18hp
		elseif wep.Primary.Ammo == "9x18MM -MG-" then
			ammoMaterial = ammo9x18
		elseif wep.Primary.Ammo == "9x18MM -ZL-" then
			ammoMaterial = ammo9x18
        elseif wep.Primary.Ammo == "9x19MM" then
            ammoMaterial = ammo9x19
		elseif wep.Primary.Ammo == "9x19MM -AP-" then
			ammoMaterial = ammo9x19ap
		elseif wep.Primary.Ammo == "9x19MM -HP-" then
			ammoMaterial = ammo9x19hp
		elseif wep.Primary.Ammo == "9x19MM -MG-" then
			ammoMaterial = ammo9x19
		elseif wep.Primary.Ammo == "9x19MM -ZL-" then
			ammoMaterial = ammo9x19
		elseif wep.Primary.Ammo == ".45 ACP" then
			ammoMaterial = ammo45acp
		elseif wep.Primary.Ammo == ".45 ACP -AP-" then
			ammoMaterial = ammo45acpap
		elseif wep.Primary.Ammo == ".45 ACP -HP-" then
			ammoMaterial = ammo45acphp
		elseif wep.Primary.Ammo == ".45 ACP -MG-" then
			ammoMaterial = ammo45acp
		elseif wep.Primary.Ammo == ".45 ACP -ZL-" then
			ammoMaterial = ammo45acp
        elseif wep.Primary.Ammo == "12 Gauge" then
            ammoMaterial = ammo12x70buck
		elseif wep.Primary.Ammo == "12 Gauge -SG-" then
			ammoMaterial = ammo12x70slug
		elseif wep.Primary.Ammo == "12 Gauge -FT-" then
			ammoMaterial = ammo12x70dart
        elseif wep.Primary.Ammo == "5.45x39MM" then
            ammoMaterial = ammo545x39
		elseif wep.Primary.Ammo == "5.45x39MM -AP-" then
			ammoMaterial = ammo545x39ap
		elseif wep.Primary.Ammo == "5.45x39MM -HP-" then
			ammoMaterial = ammo545x39hp
		elseif wep.Primary.Ammo == "5.45x39MM -MG-" then
			ammoMaterial = ammo545x39
		elseif wep.Primary.Ammo == "5.45x39MM -ZL-" then
			ammoMaterial = ammo545x39
        elseif wep.Primary.Ammo == "5.56x45MM" then
            ammoMaterial = ammo556x45
		elseif wep.Primary.Ammo == "5.56x45MM -AP-" then
			ammoMaterial = ammo556x45ap
		elseif wep.Primary.Ammo == "5.56x45MM -HP-" then
			ammoMaterial = ammo556x45hp
		elseif wep.Primary.Ammo == "5.56x45MM -MG-" then
			ammoMaterial = ammo556x45mg
        elseif wep.Primary.Ammo == "7.62x39MM" then
            ammoMaterial = ammo762x39
		elseif wep.Primary.Ammo == "7.62x39MM -AP-" then
			ammoMaterial = ammo762x39ap
		elseif wep.Primary.Ammo == "7.62x39MM -HP-" then
			ammoMaterial = ammo762x39hp
		elseif wep.Primary.Ammo == "7.62x39MM -MG-" then
			ammoMaterial = ammo762x39
		elseif wep.Primary.Ammo == "7.62x39MM -ZL-" then
			ammoMaterial = ammo762x39
		elseif wep.Primary.Ammo == "7.62x51MM" then
            ammoMaterial = ammo762x51
		elseif wep.Primary.Ammo == "7.62x51MM -AP-" then
			ammoMaterial = ammo762x51ap
		elseif wep.Primary.Ammo == "7.62x51MM -MG-" then
			ammoMaterial = ammo762x51mg
		elseif wep.Primary.Ammo == "7.62x51MM -ZL-" then
			ammoMaterial = ammo762x51
        elseif wep.Primary.Ammo == "7.62x54MM" then
            ammoMaterial = ammo762x54
		elseif wep.Primary.Ammo == "7.62x54MM -AP-" then
			ammoMaterial = ammo762x54ap
		elseif wep.Primary.Ammo == "7.62x54MM -MG-" then
			ammoMaterial = ammo762x54mg
		elseif wep.Primary.Ammo == "7.62x54MM -ZL-" then
			ammoMaterial = ammo762x54
        elseif wep.Primary.Ammo == "9x39MM" then
            ammoMaterial = ammo9x39
		elseif wep.Primary.Ammo == "9x39MM -AP-" then
			ammoMaterial = ammo9x39ap
		elseif wep.Primary.Ammo == "9x39MM -HP-" then
			ammoMaterial = ammo9x39hp
		elseif wep.Primary.Ammo == "9x39MM -MG-" then
			ammoMaterial = ammo9x39mg
		elseif wep.Primary.Ammo == "9x39MM -ZL-" then
			ammoMaterial = ammo9x39
         elseif wep.Primary.Ammo == "Batteries" then
            ammoMaterial = ammogauss
		elseif wep.Primary.Ammo == "PG-7VM Grenade" then
			ammoMaterial = ammorpg
        end

        -- If a valid ammo material was found, draw it
        if ammoMaterial then
            surface.SetMaterial(ammoMaterial)
            surface.SetDrawColor(Color(255, 255, 255, hudAlpha))			
			local ammoIconX = ammoX + 147 * scaleX
			local ammoIconY = ammoY + 18 * scaleY
			local maxW, maxH = 65 * scaleX, 33 * scaleY

			local matW = ammoMaterial:Width()
			local matH = ammoMaterial:Height()
			local scale = math.min(maxW / matW, maxH / matH)

			local drawW = matW * scale
			local drawH = matH * scale

			local drawX = ammoIconX + (maxW - drawW) / 2
			local drawY = ammoIconY + (maxH - drawH) / 2
            surface.DrawTexturedRect(drawX, drawY, drawW, drawH)

			local ammoName = wep.Primary.Ammo
			surface.SetFont("AmmoNameFont")
			local textW, textH = surface.GetTextSize(ammoName)

			if (textW > maxW) then
				if (string.find(ammoName, " %-")) then
					ammoName = string.gsub(ammoName, " %-", "\n-")
				else
					ammoName = string.gsub(ammoName, " ", "\n")
				end
			end

			draw.DrawText(ammoName, "AmmoNameFont", ammoIconX + maxW / 2, ammoIconY + maxH, Color(215, 215, 215, hudAlpha), TEXT_ALIGN_CENTER)
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

	if IsValid(wep) then
		-- Ammo type selector dots
		local item = wep.ixItem
		if not item and char then
			local inv = char:GetInv()
			if inv then
				for _, v in pairs(inv:GetItems()) do
					if v.class == wep:GetClass() and v:GetData("equip") then
						item = v
						break
					end
				end
			end
		end

		if item then
			local availableAmmoTypes = {"Normal"}
			if wep.Attachments then
				for _, category in pairs(wep.Attachments) do
					for _, attName in pairs(category.atts) do
						if ammoOrder[attName] then
							table.insert(availableAmmoTypes, attName)
						end
					end
				end
			end

			table.sort(availableAmmoTypes, function(a, b)
				return (ammoOrder[a] or 99) < (ammoOrder[b] or 99)
			end)

			local currentAmmo = item:GetData("ammoType", "Normal")
			local dotSize = 8 * scaleX
			local dotSpacing = 12 * scaleY
			local startX = ammoX + ammoW + 5 * scaleX
			local totalHeight = #availableAmmoTypes * dotSpacing
			local startY = ammoY + (ammoH - totalHeight) / 2

			surface.SetMaterial(ammoSelector)
			for i, ammoName in ipairs(availableAmmoTypes) do
				if ammoName == currentAmmo then
					surface.SetDrawColor(255, 255, 255, hudAlpha)
				else
					surface.SetDrawColor(100, 100, 100, hudAlpha)
				end
				surface.DrawTexturedRect(startX, startY + (i - 1) * dotSpacing, dotSize, dotSize)
			end
		end
	end
--// End HUD Code //--
end

ix.option.Add("StalkerHUD", ix.type.bool, false, { category = "STALKER Settings", })

ix.option.Add("HUDImmersiveMode", ix.type.bool, false, {
	category = "STALKER Settings",
})

ix.option.Add("HUDFadeDelay", ix.type.number, 5, {
	category = "STALKER Settings",
	min = 1,
	max = 15,
	decimals = 0
})

ix.option.Add("HUDtriggerkey", ix.type.string, "R", {
	category = "STALKER Controls",
	OnChanged = function(oldValue, value) end
})

ix.lang.AddTable("english", {
	optHUDImmersiveMode = "HUD immersive mode",
	optdHUDImmersiveMode = "Enables or disables the HUD fading triggered by situational events (health loss, low ammo, etc.) or a specific key.",

	optHUDtriggerkey = "HUD trigger key (immersive mode)",
	optdHUDtriggerkey = "The key to make the HUD display in immersive mode.",

	optHUDFadeDelay = "HUD Fade Delay",
	optdHUDFadeDelay = "The delay in seconds before the HUD starts to fade out in immersive mode."
})

--ARTIFACT BELT HUD
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

		-- Separate equipped artifacts into slotted and unslotted
		local slotted = {}
		local unslotted = {}

		for _, item in pairs(items) do
			if item.isArtefact and item:GetData("equip", false) then
				local slot = item:GetData("equipSlot")
				if slot then
					slotted[slot] = item
				else
					table.insert(unslotted, item)
				end
			end
		end

		-- Sort unslotted items by ID (matches inventory UI behavior)
		table.sort(unslotted, function(a, b) return a.id < b.id end)

		local totalSlots = 5 -- Maximum artifact slots
		
		-- Iterate slots 1-5 to display in order
		for i = 1, totalSlots do
			local item = slotted[i] or unslotted[i]

			if item then
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