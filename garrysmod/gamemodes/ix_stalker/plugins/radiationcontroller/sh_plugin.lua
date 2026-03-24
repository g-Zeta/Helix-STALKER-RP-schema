local PLUGIN = PLUGIN
PLUGIN.name = "Radiation Controller"
PLUGIN.author = "verne, refactor by Ghost."
PLUGIN.desc = "Allows for spawning and managing radiation entities"

PLUGIN.radiationdefs = PLUGIN.radiationdefs or {}
PLUGIN.radiationpoints = PLUGIN.radiationpoints or {}

CAMI.RegisterPrivilege({
	Name = "Helix - Manage Radiation",
	MinAccess = "admin"
})

ix.util.Include("sh_radiationdefs.lua")

function PLUGIN:InitPostEntity()
	local radClasses = {"rad_light", "rad_moderate", "rad_heavy", "rad_fog", "rad_swampfog", "rad_deathfog"}
	for _, name in ipairs(radClasses) do
		local class = scripted_ents.GetStored(name)
		if class and class.t then
			class.t.bNoPersist = true
		end
	end
end

local radZoneNames = {}
local radZoneColors = {
	rad_light = Color(100, 255, 100),
	rad_moderate = Color(255, 200, 50),
	rad_heavy = Color(255, 50, 50),
	rad_fog = Color(150, 150, 150),
	rad_swampfog = Color(100, 150, 100),
	rad_deathfog = Color(200, 0, 200),
}

if SERVER then
	function PLUGIN:cleanRadiation()
		for k, v in pairs(ents.GetAll()) do
			if (string.sub(v:GetClass(), 1, 4) == "rad_") then
				v:Remove()
			end
		end
	end

	function PLUGIN:cleanRadiationInSphere(pos, range)
		local count = 0

		for k, v in pairs(ents.FindInSphere(pos, range)) do
			if (string.sub(v:GetClass(), 1, 4) == "rad_") then
				v:Remove()
				count = count + 1
			end
		end

		return count
	end

	function PLUGIN:spawnRadiationAtPoint(v)
		local selectedRadiation = {}
		for i = 1, #self.radiationdefs do
			if string.sub(v[3], i, i) == "1" then
				table.insert(selectedRadiation, self.radiationdefs[i])
			end
		end

		local entity = table.Random(selectedRadiation)
		if not entity or entity.name == "Nil" or not entity.entityname then
			return 0
		end

		local position = v[1]
		local range = v[2]

		local spawnedent = ents.Create(entity.entityname)
		if IsValid(spawnedent) then
			spawnedent:SetPos(position)
			spawnedent:Spawn()

			if range and range > 0 then
				spawnedent:SetNWInt("Range", range)
			end

			return 1
		end

		return 0
	end

	function PLUGIN:spawnRadiation()
		for k, v in pairs(self.radiationpoints) do
			self:spawnRadiationAtPoint(v)
		end
	end

	function PLUGIN:LoadData()
		self.radiationpoints = self:GetData() or {}

		self:cleanRadiation()
		self:spawnRadiation()
		SetNetVar("radiationSpawnPoints", self.radiationpoints)
	end

	function PLUGIN:SaveData()
		self:SetData(self.radiationpoints)
		SetNetVar("radiationSpawnPoints", self.radiationpoints)
	end
else
	CreateConVar("ix_radiationdisplay", "0", FCVAR_ARCHIVE)

	ix.option.Add("radiationDisplayRange", ix.type.number, 4096, {
		category = "observer", min = 512, max = 32768,
		hidden = function()
			return !CAMI.PlayerHasAccess(LocalPlayer(), "Helix - Manage Radiation", nil)
		end
	})

	local function IsInRange(center, radius)
		return LocalPlayer():GetPos():Distance(center) <= ix.option.Get("radiationDisplayRange", 4096) + (radius or 0)
	end

	local function DecodeRadBitmask(bitmask, radiationdefs)
		local names = {}
		for i = 1, #bitmask do
			if string.sub(bitmask, i, i) == "1" then
				local def = radiationdefs[i]
				if def and def.name and def.name ~= "Nil" then
					table.insert(names, def.name)
				end
			end
		end
		return table.concat(names, ", ")
	end

	local function GetZoneColor(bitmask, radiationdefs)
		for i = 1, #bitmask do
			if string.sub(bitmask, i, i) == "1" then
				local def = radiationdefs[i]
				if def and def.entityname then
					return radZoneColors[def.entityname] or Color(255, 186, 50)
				end
			end
		end
		return Color(255, 186, 50)
	end

	function PLUGIN:HUDPaint()
		local cvar = GetConVar("ix_radiationdisplay")
		if not cvar or not cvar:GetBool() then return end
		if not LocalPlayer():IsAdmin() or LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP then return end

		local client = LocalPlayer()
		local displayRange = ix.option.Get("radiationDisplayRange", 4096)
		local scrW, scrH = ScrW(), ScrH()
		local marginX, marginY = scrH * 0.1, scrH * 0.1

		for _, v in ipairs(ents.GetAll()) do
			if string.sub(v:GetClass(), 1, 4) == "rad_" then
				local distance = client:GetPos():Distance(v:GetPos())
				local range = v:GetNWFloat("Range", 256)
				if distance > displayRange + range then continue end

				local screenPos = v:GetPos():ToScreen()
				local x = math.Clamp(screenPos.x, marginX, scrW - marginX)
				local y = math.Clamp(screenPos.y, marginY, scrH - marginY)
				local factor = 1 - math.Clamp(distance / displayRange, 0, 1)
				local size = math.max(10, 32 * factor)
				local alpha = math.max(255 * factor, 80)

				surface.SetDrawColor(0, 255, 0, alpha)
				surface.DrawRect(x - size / 2, y - size / 2, size, size)

				if IsValid(v) then
					ix.util.DrawText(v:GetClass(), x, y - size, ColorAlpha(Color(0, 255, 0), alpha, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, nil, alpha))
				end
			end
		end
	end

	function PLUGIN:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox, bDraw3DSkybox)
		if bDrawingDepth or bDrawingSkybox or bDraw3DSkybox then return end
		local cvar = GetConVar("ix_radiationdisplay")
		if not cvar or not cvar:GetBool() then return end
		if not LocalPlayer():IsAdmin() or LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP then return end

		local displayRange = ix.option.Get("radiationDisplayRange", 4096)

		for _, v in ipairs(ents.GetAll()) do
			if string.sub(v:GetClass(), 1, 4) == "rad_" then
				local range = v:GetNWFloat("Range", 256)
				if LocalPlayer():GetPos():Distance(v:GetPos()) <= displayRange + range then
					render.SetColorMaterial()
					render.DrawWireframeSphere(v:GetPos(), range, 30, 30, Color(0, 255, 0, 255), true)
				end
			end
		end

		local points = GetNetVar("radiationSpawnPoints", {})

		for idx, point in pairs(points) do
			local center = point[1]
			local range = point[2]
			local bitmask = point[3]
			if not center then continue end

			local displayRadius = (range and range > 0) and range or 256
			if not IsInRange(center, displayRadius) then continue end

			local zoneColor = GetZoneColor(bitmask, self.radiationdefs)
			local mins = Vector(-displayRadius, -displayRadius, 0)
			local maxs = Vector(displayRadius, displayRadius, displayRadius)

			render.DrawWireframeBox(center, Angle(), mins, maxs, zoneColor, false)
			render.DrawLine(center, center + Vector(0, 0, displayRadius), Color(0, 255, 0), false)

			if bitmask then
				local labelPos = center + Vector(0, 0, displayRadius + 16)
				local ang = (labelPos - LocalPlayer():EyePos()):Angle()
				ang:RotateAroundAxis(ang:Up(), -90)
				ang:RotateAroundAxis(ang:Forward(), 90)

				local scale = math.Clamp(displayRadius / 256, 0.3, 1.5)
				cam.Start3D2D(labelPos, ang, scale)
					local title = "#" .. idx
					local types = DecodeRadBitmask(bitmask, self.radiationdefs)
					local info = "R: " .. displayRadius

					draw.SimpleText(title, "DermaLarge", 0, 0, zoneColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(types, "DermaLarge", 0, 4, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					draw.SimpleText(info, "DermaDefault", 0, 30, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				cam.End3D2D()
			end
		end
	end
end

local radiationAliases = {
	light =    {20},
	moderate = {21},
	heavy =    {22},
	fog =      {5},
	swampfog = {5, 6},
	deathfog = {7},
}

ix.command.Add("radaddzone", {
	privilege = "Manage Radiation",
	arguments = {
		ix.type.number,
		ix.type.string
	},
	OnRun = function(self, client, radius, radiation)
		local trace = client:GetEyeTraceNoCursor()
		local hitpos = trace.HitPos + trace.HitNormal * 5
		local radius = radius or 256

		if not radius or not isnumber(radius) or radius < 0 or radius > 4096 then
			return "@invalidArg", 2
		end

		local radiation = string.lower(radiation or "light")

		local bits = {}
		for i = 1, #PLUGIN.radiationdefs do
			bits[i] = "0"
		end

		for word in string.gmatch(radiation, "%S+") do
			local indices = radiationAliases[word]
			if indices then
				for _, idx in ipairs(indices) do
					bits[idx] = "1"
				end
			end
		end

		local raddef = table.concat(bits)

		if string.match(raddef, "1", 1) then
			table.insert(PLUGIN.radiationpoints, {hitpos, radius, raddef})
			client:Notify("Radiation zone added successfully.")
		else
			client:Notify("Invalid radiation type. Valid types: light, moderate, heavy, fog, swampfog, deathfog")
		end

		PLUGIN:SaveData()
	end
})

ix.command.Add("radremovezone", {
	privilege = "Manage Radiation",
	arguments = {
		ix.type.number
	},
	OnRun = function(self, client, range)
		local trace = client:GetEyeTraceNoCursor()
		local hitpos = trace.HitPos + trace.HitNormal * 5
		local range = range or 128
		local mt = 0

		for k, v in pairs(PLUGIN.radiationpoints) do
			local distance = v[1]:Distance(hitpos)
			if distance <= tonumber(range) then
				local cleanRadius = (v[2] and v[2] > 0) and v[2] or 256
				PLUGIN:cleanRadiationInSphere(v[1], cleanRadius)
				PLUGIN.radiationpoints[k] = nil
				mt = mt + 1
			end
		end

		if mt > 0 then
			client:Notify(mt .. " radiation zone(s) removed.")
		else
			client:Notify("No radiation zones found at location.")
		end

		PLUGIN:SaveData()
	end
})

ix.command.Add("radforcespawn", {
	privilege = "Manage Radiation",
	arguments = {
		bit.bor(ix.type.number, ix.type.optional)
	},
	OnRun = function(self, client, range)
		local trace = client:GetEyeTraceNoCursor()
		local hitpos = trace.HitPos + trace.HitNormal * 5
		local range = tonumber(range) or 0
		local spawnerCount = 0
		local entityCount = 0

		for k, v in pairs(PLUGIN.radiationpoints) do
			if range > 0 and v[1]:Distance(hitpos) > range then
				continue
			end

			PLUGIN:cleanRadiationInSphere(v[1], v[2] > 0 and v[2] or 256)
			entityCount = entityCount + PLUGIN:spawnRadiationAtPoint(v)
			spawnerCount = spawnerCount + 1
		end

		if spawnerCount > 0 then
			client:Notify("Spawned " .. entityCount .. " radiation zones from " .. spawnerCount .. " points.")
		else
			client:Notify("No radiation points found within range.")
		end
	end
})

ix.command.Add("radclean", {
	privilege = "Manage Radiation",
	arguments = {
		bit.bor(ix.type.number, ix.type.optional)
	},
	OnRun = function(self, client, range)
		local range = tonumber(range) or 0

		if range > 0 then
			local trace = client:GetEyeTraceNoCursor()
			local hitpos = trace.HitPos + trace.HitNormal * 5
			local count = PLUGIN:cleanRadiationInSphere(hitpos, range)

			if count > 0 then
				client:Notify("Removed " .. count .. " radiation entities within " .. range .. " units.")
			else
				client:Notify("No radiation entities found within range.")
			end
		else
			PLUGIN:cleanRadiation()
			client:Notify("All radiation entities have been removed.")
		end
	end
})
