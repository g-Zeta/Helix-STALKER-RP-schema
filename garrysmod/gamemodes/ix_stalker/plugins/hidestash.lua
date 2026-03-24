local PLUGIN = PLUGIN
PLUGIN.name = "Hidden Stash System"
PLUGIN.author = "Unknown"
PLUGIN.desc = "Simple hidestash system."
PLUGIN.stashpoints = PLUGIN.stashpoints or {}

if (SERVER) then
	util.AddNetworkString("ixStashDisplay")
	util.AddNetworkString("ixStashDisplayRequest")

	function PLUGIN:LoadData()
		self.stashpoints = self:GetData() or {}
	end

	local displayListeners = {}

	local function sendStashDisplay(client)
		local points = PLUGIN.stashpoints

		net.Start("ixStashDisplay")
			net.WriteUInt(table.Count(points), 16)

			for _, v in pairs(points) do
				net.WriteVector(v[1])
				net.WriteString(ix.item.list[v[2]] and ix.item.list[v[2]].name or v[2])
			end
		net.Send(client)
	end

	local function broadcastStashDisplay()
		for client, _ in pairs(displayListeners) do
			if (IsValid(client) and client:IsAdmin()) then
				sendStashDisplay(client)
			else
				displayListeners[client] = nil
			end
		end
	end

	timer.Create("ixStashDisplayRefresh", 60, 0, function()
		broadcastStashDisplay()
	end)

	function PLUGIN:SaveData()
		self:SetData(self.stashpoints)
		broadcastStashDisplay()
	end

	function PLUGIN:SpawnStash(pos, item)
		for k, v in pairs(item) do
			table.insert(PLUGIN.stashpoints, {pos, v[1], Angle(), v[2]})
		end

		self:SaveData()
	end

	net.Receive("ixStashDisplayRequest", function(len, client)
		if (!client:IsAdmin()) then return end

		local enabled = net.ReadBool()

		if (enabled) then
			displayListeners[client] = true
			sendStashDisplay(client)
		else
			displayListeners[client] = nil
		end
	end)

	function PLUGIN:PlayerDisconnected(client)
		displayListeners[client] = nil
	end
else
	local stashDisplayPoints = {}
	local stashDisplayCvar = CreateConVar("ix_stashdisplay", "0", FCVAR_ARCHIVE)

	function PLUGIN:CharacterLoaded(character)
		if (stashDisplayCvar:GetBool()) then
			net.Start("ixStashDisplayRequest")
				net.WriteBool(true)
			net.SendToServer()
		end
	end

	cvars.AddChangeCallback("ix_stashdisplay", function(name, old, new)
		net.Start("ixStashDisplayRequest")
			net.WriteBool(tonumber(new) == 1)
		net.SendToServer()

		if (tonumber(new) != 1) then
			stashDisplayPoints = {}
		end
	end, "ixStashDisplayToggle")

	net.Receive("ixStashDisplay", function()
		stashDisplayPoints = {}
		local count = net.ReadUInt(16)

		for i = 1, count do
			local pos = net.ReadVector()
			local name = net.ReadString()
			local key = tostring(pos)

			if (!stashDisplayPoints[key]) then
				stashDisplayPoints[key] = {pos = pos, items = {}}
			end

			table.insert(stashDisplayPoints[key].items, name)
		end
	end)

	function PLUGIN:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
		if (bDrawingDepth or bDrawingSkybox) then return end
		if (!stashDisplayCvar:GetBool()) then return end
		if (!LocalPlayer():IsAdmin() or LocalPlayer():GetMoveType() != MOVETYPE_NOCLIP) then return end

		local eyePos = LocalPlayer():EyePos()

		for key, stash in pairs(stashDisplayPoints) do
			local pos = stash.pos
			local dist = eyePos:Distance(pos)
			local itemCount = #stash.items
			local closeRange = 512

			if (dist > closeRange) then
				render.DrawLine(pos, pos + Vector(0, 0, 1024), Color(255, 186, 50), false)
			end

			if (dist <= 1024) then
				local labelPos = dist <= closeRange and pos + Vector(0, 0, 16) or pos + Vector(0, 0, 1032)
				local ang = (labelPos - eyePos):Angle()
				ang:RotateAroundAxis(ang:Up(), -90)
				ang:RotateAroundAxis(ang:Forward(), 90)

				local scale = math.Clamp(dist / 2048, 0.12, 0.5)

				cam.Start3D2D(labelPos, ang, scale)
					draw.SimpleText(itemCount .. " item" .. (itemCount != 1 and "s" or ""), "DermaLarge", 0, 0, Color(255, 186, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

					for i, name in ipairs(stash.items) do
						draw.SimpleText(name, "DermaDefault", 0, (i - 1) * 18 + 4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					end
				cam.End3D2D()
			end
		end
	end
end

ix.command.Add("stashhide", {
	adminOnly = false,
	OnRun = function(self, client)
		if (!client:Alive() or !client:GetCharacter()) then return end

		if (timer.Exists("ixAct" .. client:SteamID64())) then
			client:Notify("You are already busy.")
			return
		end

		local startPos = client:GetPos()
		local timerID = "ixStashMove" .. client:SteamID64()

		client:SetAction("Covering up items...", 10, function()
			timer.Remove(timerID)

			if (!client:Alive() or !client:GetCharacter()) then return end

			local trace = client:GetEyeTraceNoCursor()
			local hitpos = trace.HitPos + trace.HitNormal * 5
			local mt = 0

			for k, v in pairs(ix.item.instances) do
				if (v:GetEntity() and IsValid(v:GetEntity())) then
					local entPos = v:GetEntity():GetPos()
					local distance = entPos:Distance(hitpos)

					if (distance <= 32 and entPos:Distance(client:GetPos()) <= 70) then
						table.insert(PLUGIN.stashpoints, {hitpos, v.uniqueID, v:GetEntity():GetAngles(), v.data})
						ix.log.Add(client, "command", "created a stash at x:" .. hitpos.x .. " y:" .. hitpos.y .. " z:" .. hitpos.z .. " containing: " .. v.name)
						-- TODO: log item ID (v:GetID()) and name here for advanced logging/item tracking before removal,
						-- since unhiding spawns a new item with a new DB ID, breaking the trail.
						v:Remove()
						client:Notify("You hid " .. v.name)
						mt = mt + 1
					end
				end
			end

			if (mt > 0) then
				PLUGIN:SaveData()
			end
		end)

		timer.Create(timerID, 0.25, 0, function()
			if (!IsValid(client) or !client:Alive() or !client:GetCharacter()) then
				timer.Remove(timerID)
				return
			end

			if (client:GetPos():Distance(startPos) > 48) then
				client:SetAction(false)
				client:Notify("You moved too far away.")
				timer.Remove(timerID)
			end
		end)
	end
})

ix.command.Add("stashunhide", {
	adminOnly = false,
	OnRun = function(self, client)
		if (!client:Alive() or !client:GetCharacter()) then return end

		if (timer.Exists("ixAct" .. client:SteamID64())) then
			client:Notify("You are already busy.")
			return
		end

		local startPos = client:GetPos()
		local timerID = "ixStashMove" .. client:SteamID64()

		client:SetAction("Searching...", 7, function()
			timer.Remove(timerID)

			if (!client:Alive() or !client:GetCharacter()) then return end

			local trace = client:GetEyeTraceNoCursor()
			local hitpos = trace.HitPos + trace.HitNormal * 5
			local mt = 0

			for k, v in pairs(PLUGIN.stashpoints) do
				local dist = hitpos:Distance(client:GetPos())
				local distance = v[1]:Distance(hitpos)

				if (dist <= 70 and distance <= 64) then
					local itemName = ix.item.list[v[2]] and ix.item.list[v[2]].name or v[2]
					ix.item.Spawn(v[2], v[1] + Vector(0, 0, mt * 5), nil, v[3], v[4])
					PLUGIN.stashpoints[k] = nil
					client:Notify("You uncovered a(n) " .. itemName)
					mt = mt + 1
				end
			end

			if (mt == 0) then
				client:Notify("You didn't find anything")
			else
				PLUGIN:SaveData()
			end
		end)

		timer.Create(timerID, 0.25, 0, function()
			if (!IsValid(client) or !client:Alive() or !client:GetCharacter()) then
				timer.Remove(timerID)
				return
			end

			if (client:GetPos():Distance(startPos) > 48) then
				client:SetAction(false)
				client:Notify("You moved too far away.")
				timer.Remove(timerID)
			end
		end)
	end
})
