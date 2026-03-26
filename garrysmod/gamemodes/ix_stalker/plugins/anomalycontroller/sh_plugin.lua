local PLUGIN = PLUGIN
PLUGIN.name = "Anomaly Controller"
PLUGIN.author = "Unknown, refactor by Ghost."
PLUGIN.desc = "Allows for randomly spawning anomaly entities"

PLUGIN.anomalydefs = PLUGIN.anomalydefs or {}
PLUGIN.anomalypoints = PLUGIN.anomalypoints or {} -- ANOMALYPOINTS STRUCTURE table.insert( PLUGIN.eventpoints, { position, radius, anoms } )
PLUGIN.artifactCounts = PLUGIN.artifactCounts or {}

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
		spawntime = CurTime() + self.spawnrate - #player.GetAll() * 5

		for i, j in RandomPairs(self.anomalypoints) do
			if j then
				self.artifactCounts[i] = self.artifactCounts[i] or 0
					if self.artifactCounts[i] >= 2 then
						continue
					end

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

					local rand = math.random(100)
					local rarityselector = 0
					local anomalyselector = 0

					if rand <= 75 then
						rarityselector = 0
					elseif rand <= 95 then
						rarityselector = 1
					else
						rarityselector = 2
					end

					local nearbyEnts = ents.FindInSphere(j[1], j[2])

					local chosenAnom
					for k,v in RandomPairs(nearbyEnts) do
						if (string.sub(v:GetClass(), 1, 5) == "anom_") then
							for ii=1,#self.anomalydefs do
								if self.anomalydefs[ii].entityname == v:GetClass() then
									anomalyselector = ii
									chosenAnom = v
									break
								end
							end
							if chosenAnom then break end
						end
					end

					if anomalyselector == 0 then
						continue
					end

					local idat = 0

					if rarityselector == 0 then
						idat = table.Random(self.anomalydefs[anomalyselector].commonArtifacts)
					elseif rarityselector == 1 then
						idat = table.Random(self.anomalydefs[anomalyselector].rareArtifacts)
					else
						idat = table.Random(self.anomalydefs[anomalyselector].veryRareArtifacts)
					end

					local anomPos = chosenAnom:GetPos()
					local spawnPos = anomPos + Vector( math.Rand(-32,32), math.Rand(-32,32), 0 )
					local groundTrace = util.TraceLine({start = spawnPos + Vector(0, 0, 512), endpos = spawnPos - Vector(0, 0, 128)})
					if groundTrace.Hit and not groundTrace.HitSky and groundTrace.HitPos.z >= anomPos.z - 50 then
						local pointIndex = i
						ix.item.Spawn(idat, groundTrace.HitPos + Vector(0, 0, 15), function(item, entity)
							self.artifactCounts[pointIndex] = (self.artifactCounts[pointIndex] or 0) + 1

							entity:CallOnRemove("ixArtifactCounter", function()
								self.artifactCounts[pointIndex] = math.max(0, (self.artifactCounts[pointIndex] or 1) - 1)
							end)
						end, AngleRand(), {})
					end
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

		if #selectedAnoms > 0 then
			local sampleEntity = selectedAnoms[1]
			local maxCount = math.max(2, math.min(7, math.ceil(v[2] / sampleEntity.interval)))
			local minCount = math.max(1, math.floor(maxCount / 3))
			if v[2] >= 768 then
				maxCount = math.max(2, maxCount - 1)
				minCount = math.max(2, math.ceil(maxCount / 3))
			end
			if v[2] >= 2500 then
				minCount = math.max(4, minCount)
			elseif v[2] >= 2000 then
				minCount = math.max(3, minCount)
			end
			local spawnCount = math.random(minCount, maxCount)

			local sectorSize = (2 * math.pi) / spawnCount
			local sectorOffset = math.Rand(0, 2 * math.pi)

			for i = 1, spawnCount do
				local entity = table.Random(selectedAnoms)

				for attempt = 1, 10 do
					local sectorStart = sectorOffset + (i - 1) * sectorSize
					local wiggle = (attempt - 1) * sectorSize * 0.25
					local angle = sectorStart + math.Rand(-wiggle, sectorSize + wiggle)
					local dist = math.sqrt(math.Rand(0.1, 1)) * v[2]
					local position = v[1] + Vector( math.cos(angle) * dist, math.sin(angle) * dist, 0 )

					local groundTrace = util.TraceLine({start = position + Vector(0, 0, 128), endpos = position - Vector(0, 0, 256)})
					if not groundTrace.Hit or groundTrace.HitSky then continue end

					position = groundTrace.HitPos + Vector(0, 0, 10)

					local losTrace = util.TraceLine({start = v[1] + Vector(0, 0, 50), endpos = position + Vector(0, 0, 50)})
					if losTrace.Hit and losTrace.Fraction < 0.95 then continue end

					if v[2] >= 768 then
						local tooClose = false
						for _, nearby in pairs(ents.FindInSphere(position, math.min(v[2] * 0.25, 500))) do
							if string.sub(nearby:GetClass(), 1, 5) == "anom_" then
								tooClose = true
								break
							end
						end
						if tooClose then continue end
					end

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
					break
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
		self.artifactCounts = {}

		self:cleanAnomalies()

		local artifacts = {}
		for _, ent in pairs(ents.FindByClass("ix_item")) do
			local itemTable = ent:GetItemTable()
			if itemTable and itemTable.isArtefact then
				table.insert(artifacts, ent)
			end
		end
		if #artifacts > 5 then
			for _, ent in pairs(artifacts) do
				ent:Remove()
			end
		end

		timer.Simple(10, function()
			local artifacts = {}
			for _, ent in pairs(ents.FindByClass("ix_item")) do
				local itemTable = ent:GetItemTable()
				if itemTable and itemTable.isArtefact then
					table.insert(artifacts, ent)
				end
			end
			if #artifacts > 5 then
				for _, ent in pairs(artifacts) do
					ent:Remove()
				end
			end
		end)

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

	ix.option.Add("anomalySpawnerDisplayRange", ix.type.number, 3072, {
		category = "observer", min = 512, max = 32768,
		hidden = function()
			return !CAMI.PlayerHasAccess(LocalPlayer(), "Helix - Manage Anomalies", nil)
		end
	})

	local function IsInRange(center, radius)
		return LocalPlayer():GetPos():Distance(center) <= ix.option.Get("anomalySpawnerDisplayRange", 3072) + (radius or 0)
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
		if (!radius or !isnumber(radius) or radius < 0 or radius > 3072) then
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

