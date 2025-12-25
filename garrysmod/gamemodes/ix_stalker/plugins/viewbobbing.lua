local BobbingSpeed = 4.5 
local BobbingAmount = 0.1 
local RollSmoothing = 0.2 
local breathingSpeed = 1.8
local breathingAmount = 0.4

local rollAngle = 0
local pitchOffset = 0
local rollOffset = 0
local yawOffset = 0
local verticalBobbingAmount = 0.1
local customBobbingSpeed = 1.4

ix.option.Add("ViewBobbing", ix.type.bool, true, {
    category = "View"
})

ix.lang.AddTable("english", {
	viewbobbing = "View Bobbing",

	optViewBobbing = "Enable View Bobbing",
	optdViewBobbing = "Whether to enable view bobbing."
})

hook.Add("CalcView", "ViewBobbing", function(ply, origin, angles, fov)
    if not ply:Alive() or not ix.option.Get("ViewBobbing", true) or ply:GetMoveType() == MOVETYPE_NOCLIP then
        return
    end

    local walkSpeed = ply:GetVelocity():Length()
    local bobbingOffset = math.sin(CurTime() * BobbingSpeed * customBobbingSpeed) * BobbingAmount
    local verticalBobbingOffset = math.sin(CurTime() * BobbingSpeed * 2 * customBobbingSpeed) * verticalBobbingAmount

    if ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) then
        rollAngle = Lerp(RollSmoothing, rollAngle, bobbingOffset * 3)

        pitchOffset = verticalBobbingOffset
        yawOffset = Lerp(0.1, yawOffset, 0)

        local rollDirection = ply:GetVelocity():Dot(angles:Right()) > 0 and 1 or -1
        rollOffset = math.cos(CurTime() * BobbingSpeed * customBobbingSpeed) * BobbingAmount * rollDirection
    else
        -- Breathing effect
        local currentBreathingSpeed = breathingSpeed
        local currentBreathingAmount = breathingAmount
        local lp = LocalPlayer()
        local stamina = lp:GetLocalVar("stm", 100)

        if (stamina < 30) then
            currentBreathingSpeed = 4
            currentBreathingAmount = 0.8
        elseif (stamina <= 60) then
            currentBreathingSpeed = 2.8
            currentBreathingAmount = 0.6
        end

        local breathCycle = math.sin(CurTime() * currentBreathingSpeed)
        local breathCycleYaw = math.cos(CurTime() * currentBreathingSpeed * 0.5)
        pitchOffset = Lerp(0.1, pitchOffset, breathCycle * currentBreathingAmount)
        yawOffset = Lerp(0.1, yawOffset, breathCycleYaw * currentBreathingAmount * 0.5)
        rollAngle = Lerp(0.1, rollAngle, breathCycle * currentBreathingAmount * 0.2)
        rollOffset = Lerp(0.1, rollOffset, 0)
    end

    if walkSpeed < 90 then
        BobbingSpeed = 4
        BobbingAmount = 0.1
        verticalBobbingAmount = 0.2
        customBobbingSpeed = 1.5
    elseif walkSpeed > 100 then
        BobbingSpeed = 4.5
        BobbingAmount = 0.3
        verticalBobbingAmount = 0.5
        customBobbingSpeed = 2
    else
        BobbingSpeed = 4.5
        BobbingAmount = 0.1
        verticalBobbingAmount = 0.4
        customBobbingSpeed = 1.5
    end

    angles.roll = angles.roll + rollAngle

    angles.pitch = angles.pitch + pitchOffset
    angles.yaw = angles.yaw + yawOffset

    angles.roll = angles.roll + rollOffset

    if ply.VBSpringAngle then
        angles:Add(ply.VBSpringAngle)
    end

    return {
        origin = origin,
        angles = angles,
        fov = fov
    }
end)

if CLIENT then
    local vb_landingsound = CreateClientConVar("vb_landingsound", 1, true, false, "Play landing sounds?", 0, 1)
    local onground = false

    stumbleamt = 0
    local stumblecap = 25
    local stumblecaptarget = 25
    local stumbletarget = 0
    local stumbletargetspeed = 400
    local function DoStumble(mul, target, speed)
        stumblecaptarget = stumblecap or target
        stumbletarget = stumblecap*mul
        stumbletargetspeed = speed or 400
    end

    local matsounds = {
    [MAT_METAL] = "metal",
    [MAT_GRASS] = "grass",
    [MAT_DIRT] = "dirt",
    [MAT_SNOW] = "snow",
    [MAT_SAND] = "sand",
    [MAT_TILE] = "tile",
    [MAT_CONCRETE] = "concrete",
    [MAT_WOOD] = "wood",
    [MAT_FLESH] = "flesh",
    [MAT_GLASS] = "glass",
    [MAT_PLASTIC] = "plastic",
    [MAT_GRATE] = "metalgrate",
    [MAT_SLOSH] = "water",
    [MAT_VENT] = "duct",
    [MAT_FOLIAGE] = "foliage"
    }

    local lastvel = 0
    local hulltr, hulltr_out

    local function LandingSound(ply, hard)
        if !vb_landingsound:GetBool() then return end
        if !hulltr then
            hulltr = {}
            hulltr_out = {}
            hulltr.filter = ply
            hulltr.output = hulltr_out
        end
        
        hulltr.mins, hulltr.maxs = ply:GetHull()
        hulltr.start = ply:GetPos()
        hulltr.endpos = hulltr.start - Vector(0,0,8)
        util.TraceHull(hulltr)
        
        ply:EmitSound(string.format("player/footsteps/LandingSounds/%s_land%d.ogg", matsounds[hulltr_out.MatType] or "stone", math.random(1,3)), 75, 100, math.min(1 * (math.abs(lastvel+100)/85), 1))
        if hard then
            ply:EmitSound(string.format("player/footsteps/LandingSounds/hardland%d.wav", math.random(1,5)), 40)
        end
    end

    local DAMPING = 5
    local SPRING_CONSTANT = 80

    local function lensqr(ang)
        return (ang[1] ^ 2) + (ang[2] ^ 2) + (ang[3] ^ 2)
    end

    local function VBSpringThink()
        local self = LocalPlayer()
        if !self.VBSpringVelocity or !self.VBSpringAngle then
            self.VBSpringVelocity = Angle()
            self.VBSpringAngle = Angle()
        end
        local vpa = self.VBSpringAngle
        local vpv = self.VBSpringVelocity

        if !self.VBSpringDone and lensqr(vpa) + lensqr(vpv) > 0.000001 then
            local FT = FrameTime()

            vpa = vpa + (vpv * FT)
            local damping = 1 - (DAMPING * FT)
            if damping < 0 then
                damping = 0
            end
            vpv = vpv * damping

            local springforcemagnitude = SPRING_CONSTANT * FT
            springforcemagnitude = math.Clamp(springforcemagnitude, 0, 2)
            vpv = vpv - (vpa * springforcemagnitude)

            vpa[1] = math.Clamp(vpa[1], -89.9, 89.9)
            vpa[2] = math.Clamp(vpa[2], -179.9, 179.9)
            vpa[3] = math.Clamp(vpa[3], -89.9, 89.9)

            self.VBSpringAngle = vpa
            self.VBSpringVelocity = vpv
        else
            self.VBSpringDone = true
        end
    end
    hook.Add("Think", "VBSpring", VBSpringThink)

    local meta = FindMetaTable("Player")
    function meta:VBSpring(angle)
        if !self.VBSpringVelocity then return end
        local intensity = 20
        self.VBSpringVelocity:Add(angle * intensity)
        if !self.VBSpringVelocity then self.VBSpringVelocity=Angle() end
        local ang = self.VBSpringVelocity

        ang[1] = math.Clamp(ang[1], -180, 180)
        ang[2] = math.Clamp(ang[2], -180, 180)
        ang[3] = math.Clamp(ang[3], -180, 180)
        
        self.VBSpringDone = false
    end

    local jump = false
    local jumpheld = false
    local jumptimer = 0

    hook.Add("CreateMove", "VBJumpLand", function(cmd)
        local ply = LocalPlayer()
        if !ply:Alive() then return end

        if ply:OnGround() and cmd:KeyDown(IN_JUMP) and !jumpheld then
            if !jump then
                ply:VBSpring(Angle(1,0,-0.5))
            end
            jump = true
            jumpheld = true
            jumptimer = CurTime() + 0.5
        end
        
        jumpheld = cmd:KeyDown(IN_JUMP)
        
        if jump then
            if !ply:OnGround() or CurTime() > jumptimer then
                jump = false
            end
        end

        if !ply:OnGround() and onground then
            onground = false
        end
        
        if !ply:OnGround() and !onground then
            lastvel = ply:GetVelocity().z
        end
        
        if ply:OnGround() and ply:WaterLevel() < 2 and !onground and ply:GetMoveType() == MOVETYPE_WALK then
            onground = true
            if lastvel < -250 then
                LandingSound(ply, true)
                ply:VBSpring(Angle(5,0,-5))
                timer.Simple(0.05, function() if IsValid(ply) then ply:VBSpring(Angle(-2.5)) end end)
            elseif lastvel < -80 then
                LandingSound(ply)
                ply:VBSpring(Angle(1,0,-0.5))
                timer.Simple(0.05, function() if IsValid(ply) then ply:VBSpring(Angle(-0.25)) end end)
            end
        end
    end)
end