local PLUGIN = PLUGIN
PLUGIN.name = "Anomaly Controller"
PLUGIN.author = "Unknown, refactor by Ghost."
PLUGIN.desc = "Allows for randomly spawning anomaly entities"

PLUGIN.anomalydefs = PLUGIN.anomalydefs or {}
PLUGIN.anomalypoints = PLUGIN.anomalypoints or {} -- ANOMALYPOINTS STRUCTURE table.insert( PLUGIN.eventpoints, { position, radius, anoms } )

PLUGIN.spawnrate = 900
PLUGIN.spawnchance = 1

CAMI.RegisterPrivilege({
	Name = "Helix - Manage Anomalies",
	MinAccess = "admin"
})

ix.util.Include("sh_anomalydefs.lua")

function PLUGIN:InitPostEntity()
	for i = 1, #self.anomalydefs do
		local class = scripted_ents.GetStored(self.anomalydefs[i].entityname)
		if class and class.t then
			class.t.bNoPersist = true
		end
	end

	local extraAnomalies = {"kometa", "kometa_electra", "kometa_kisel", "teleport", "space_anomaly", "anom_passive"}
	for _, name in ipairs(extraAnomalies) do
		local class = scripted_ents.GetStored(name)
		if class and class.t then
			class.t.bNoPersist = true
		end
	end
end

if SERVER then
	util.AddNetworkString("ixAnomalyCleanSounds")

	local spawntime = 1

	function PLUGIN:Think()
		if spawntime > CurTime() then return end
		spawntime = CurTime() + self.spawnrate - #player.GetAll()*5

		for i, j in RandomPairs(self.anomalypoints) do
			if j then
				if math.random(100) <= self.spawnchance then
					local data = {}
					data.start = j[1]
					data.endpos = data.start + Vector(0, 0, -64)
					data.filter = client
					data.mins = Vector(-32, -32, 0)
					data.maxs = Vector(32, 32, 32)
					local trace = util.TraceHull(data)

					if trace.Entity:IsValid() then
						if !(trace.Entity:GetClass() == "ix_storage") then
							continue
						end
					end

					local rand = math.random(101)
					local rarityselector = 0
					local anomalyselector = 0

					if rand <= 75 then
						rarityselector = 0
					elseif rand <= 95 then
						rarityselector = 1
					elseif rand <= 100 then
						rarityselector = 2
					else return end

					for k,v in RandomPairs(ents.FindInSphere(j[1], 400)) do
						if (string.sub(v:GetClass(), 1, 5) == "anom_") then
							for i=1,#self.anomalydefs do
								if self.anomalydefs[i].entityname == v:GetClass() then
									anomalyselector = i
									break
								end
							end
						end
					end

					if anomalyselector == 0 then return end

					local idat = 0

					if rarityselector == 0 then
						idat = table.Random(self.anomalydefs[anomalyselector].commonArtifacts)
					elseif rarityselector == 1 then
						idat = table.Random(self.anomalydefs[anomalyselector].rareArtifacts)
					else
						idat = table.Random(self.anomalydefs[anomalyselector].veryRareArtifacts)
					end

					ix.item.Spawn(idat, j[1] + Vector( math.Rand(-8,8), math.Rand(-8,8), 20 ), nil, AngleRand(), {})
				end
			end
		end
	end


	function PLUGIN:cleanAnomalies()
		net.Start("ixAnomalyCleanSounds")
		net.Broadcast()

		for k, v in pairs( ents.GetAll() ) do
			if (string.sub(v:GetClass(), 1, 5) == "anom_") then
				v:Remove()
			end
		end
	end

	function PLUGIN:cleanAnomaliesInSphere(pos, range)
		local count = 0

		net.Start("ixAnomalyCleanSounds")
		net.Broadcast()

		for k, v in pairs(ents.FindInSphere(pos, range)) do
			if (string.sub(v:GetClass(), 1, 5) == "anom_") then
				v:Remove()
				count = count + 1
			end
		end

		return count
	end

	function PLUGIN:spawnAnomaliesAtPoint(v)
		local count = 0
		local selectedAnoms = {}
		for i=1, #self.anomalydefs do
			if string.sub(v[3],i,i) == "1" then
				table.insert( selectedAnoms, self.anomalydefs[i])
			end
		end

		local entity = table.Random(selectedAnoms)
		if entity then
			for i = 1, math.ceil(v[2]/entity.interval) do
				local position = v[1] + Vector( math.Rand(-v[2],v[2]), math.Rand(-v[2],v[2]), math.Rand(10,20) )
				local data = {}
				data.start = position
				data.endpos = position
				data.mins = Vector(-16, -16, 0)
				data.maxs = Vector(16, 16, 71)
				local trace = util.TraceHull(data)

				if trace.Entity:IsValid() then
					continue
				end

				local spawnedent = ents.Create(entity.entityname)
				if spawnedent then
					spawnedent:SetPos(position)
					spawnedent:Spawn()
					count = count + 1
				end
			end
		end
		return count
	end

	function PLUGIN:spawnAnomalies()
		if CurTime() > 5 then
			spawntime = 1
		end

		for k, v in pairs(self.anomalypoints) do
			self:spawnAnomaliesAtPoint(v)
		end
	end

	function PLUGIN:LoadData()
		self.anomalypoints = self:GetData() or {}

		self:cleanAnomalies()
		self:spawnAnomalies()
		SetNetVar("anomalySpawnPoints", self.anomalypoints)
	end

	function PLUGIN:SaveData()
		self:SetData(self.anomalypoints)
		SetNetVar("anomalySpawnPoints", self.anomalypoints)
	end
else
	local anomalySounds = {
		"electra_idle", "buzz_idle", "myasorubka_idle",
		"tramplin_idle", "voronka_idle", "teleport_idle",
		"par_idle", "kometa_idle"
	}

	net.Receive("ixAnomalyCleanSounds", function()
		for _, ent in pairs(ents.GetAll()) do
			local class = ent:GetClass()
			if (string.sub(class, 1, 4) == "anom" or string.sub(class, 1, 6) == "kometa" or class == "teleport") then
				for _, snd in pairs(anomalySounds) do
					ent:StopSound(snd)
				end
			end
		end
	end)

	CreateConVar("ix_anomalydisplay", "0", FCVAR_ARCHIVE)

	ix.option.Add("anomalySpawnerDisplayRange", ix.type.number, 2048, {
		category = "observer", min = 512, max = 32768,
		hidden = function()
			return !CAMI.PlayerHasAccess(LocalPlayer(), "Helix - Manage Anomalies", nil)
		end
	})

	local function IsInRange(center, radius)
		return LocalPlayer():GetPos():Distance(center) <= ix.option.Get("anomalySpawnerDisplayRange", 2048) + (radius or 0)
	end

	local function DecodeAnomBitmask(bitmask, anomalydefs)
		local names = {}
		local nameMap = {
			[1] = "Burner 1", [2] = "Burner 2",
			[3] = "Electro 1", [4] = "Electro 2",
			[5] = "Bubble 1", [6] = "Bubble 2",
			[7] = "Whirligig",
			[8] = "Fruitpunch 1", [9] = "Fruitpunch 2",
			[10] = "Karusel"
		}
		for i = 1, #bitmask do
			if string.sub(bitmask, i, i) == "1" then
				local name = nameMap[i] or ("Unknown #" .. i)
				table.insert(names, name)
			end
		end
		return table.concat(names, ", ")
	end

	function PLUGIN:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
		if bDrawingSkybox then return end
		local cvar = GetConVar("ix_anomalydisplay")
		if not cvar or not cvar:GetBool() then return end
		if not LocalPlayer():IsAdmin() or LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP then return end

		local points = GetNetVar("anomalySpawnPoints", {})

		for idx, point in pairs(points) do
			local center = point[1]
			local radius = point[2]
			local bitmask = point[3]
			if not center or not radius then continue end
			if not IsInRange(center, radius) then continue end

			local mins = Vector(-radius, -radius, 0)
			local maxs = Vector(radius, radius, radius)

			render.DrawWireframeBox(center, Angle(), mins, maxs, Color(255, 186, 50), false)
			render.DrawLine(center, center + Vector(0, 0, radius), Color(0, 255, 0), false)

			if bitmask then
				local labelPos = center + Vector(0, 0, radius + 16)
				local ang = (labelPos - LocalPlayer():EyePos()):Angle()
				ang:RotateAroundAxis(ang:Up(), -90)
				ang:RotateAroundAxis(ang:Forward(), 90)

				local scale = math.Clamp(radius / 256, 0.3, 1.5)
				cam.Start3D2D(labelPos, ang, scale)
					local title = "#" .. idx
					local types = DecodeAnomBitmask(bitmask, self.anomalydefs)
					local info = "R: " .. radius

					draw.SimpleText(title, "DermaLarge", 0, 0, Color(255, 186, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(types, "DermaLarge", 0, 4, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					draw.SimpleText(info, "DermaDefault", 0, 30, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				cam.End3D2D()
			end
		end
	end
end

local anomalyAliases = {
	burner =      {1, 2},
	burner1 =     {1},
	burner2 =     {2},
	electro =     {3, 4},
	electro1 =    {3},
	electro2 =    {4},
	bubble =      {5, 6},
	bubble1 =     {5},
	bubble2 =     {6},
	whirligig =   {7},
	fruitpunch =  {8, 9},
	fruitpunch1 = {8},
	fruitpunch2 = {9},
	karusel =     {10},
}

ix.command.Add("anomaddspawner", {
	privilege = "Manage Anomalies",
	arguments = {
		ix.type.number,
		ix.type.string
	},
	OnRun = function(self, client, radius, anomalies)
		local trace = client:GetEyeTraceNoCursor()
		local hitpos = trace.HitPos + trace.HitNormal*5
		local radius = radius or 128
		local anomalies = string.lower(anomalies) or "bubble"
		if (!radius or !isnumber(radius) or radius < 0 or radius > 2048) then
			return "@invalidArg", 2
		end

		local bits = {}
		for i = 1, #PLUGIN.anomalydefs do
			bits[i] = "0"
		end

		for word in string.gmatch(anomalies, "%S+") do
			local indices = anomalyAliases[word]
			if indices then
				for _, idx in ipairs(indices) do
					bits[idx] = "1"
				end
			end
		end

		local anomdef = table.concat(bits)

		if string.match(anomdef,"1",1) then
			client:Notify( "Anomaly spawner successfully added." )
			table.insert( PLUGIN.anomalypoints, { hitpos, radius, anomdef } )
		else
			client:Notify("Anomaly spawner failed to be added.")
		end
		PLUGIN:SaveData()
	end
})

ix.command.Add("anomremovespawner", {
	privilege = "Manage Anomalies",
	arguments = {
		ix.type.number
	},
	OnRun = function(self, client, range)
		local trace = client:GetEyeTraceNoCursor()
		local hitpos = trace.HitPos + trace.HitNormal*5
		local range = range or 128
		local mt = 0
		for k, v in pairs( PLUGIN.anomalypoints ) do
			local distance = v[1]:Distance( hitpos )
			if distance <= tonumber(range) then
				PLUGIN:cleanAnomaliesInSphere(v[1], v[2])
				PLUGIN.anomalypoints[k] = nil
				mt = mt + 1
			end
		end
		if mt > 0 then
			client:Notify( mt .. " anomaly locations have been removed.")
		else
			client:Notify( "No anomaly spawn points found at location.")
		end
		PLUGIN:SaveData()
	end
})

ix.command.Add("anomforcespawn", {
	privilege = "Manage Anomalies",
	arguments = {
		bit.bor(ix.type.number, ix.type.optional)
	},
	OnRun = function(self, client, range)
		local trace = client:GetEyeTraceNoCursor()
		local hitpos = trace.HitPos + trace.HitNormal*5
		local range = tonumber(range) or 0
		local spawnerCount = 0
		local entityCount = 0

		for k, v in pairs(PLUGIN.anomalypoints) do
			if range > 0 and v[1]:Distance(hitpos) > range then
				continue
			end

			PLUGIN:cleanAnomaliesInSphere(v[1], v[2])
			entityCount = entityCount + PLUGIN:spawnAnomaliesAtPoint(v)
			spawnerCount = spawnerCount + 1
		end

		if spawnerCount > 0 then
			client:Notify("Spawned " .. entityCount .. " anomalies from " .. spawnerCount .. " spawners.")
		else
			client:Notify("No spawners found within range.")
		end
	end
})

ix.command.Add("anomclean", {
	privilege = "Manage Anomalies",
	arguments = {
		bit.bor(ix.type.number, ix.type.optional)
	},
	OnRun = function(self, client, range)
		local range = tonumber(range) or 0

		if range > 0 then
			local trace = client:GetEyeTraceNoCursor()
			local hitpos = trace.HitPos + trace.HitNormal*5
			local count = PLUGIN:cleanAnomaliesInSphere(hitpos, range)

			if count > 0 then
				client:Notify("Removed " .. count .. " anomalies within " .. range .. " units.")
			else
				client:Notify("No anomalies found within range.")
			end
		else
			PLUGIN:cleanAnomalies()
			client:Notify("All anomalies have been removed.")
		end
	end
})

