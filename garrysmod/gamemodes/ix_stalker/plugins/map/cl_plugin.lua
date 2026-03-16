local BASE_W, BASE_H = 1920, 1080
local function UIScale()
  -- uniform scale, using the minimum axis to avoid stretch
  return math.min(ScrW() / BASE_W, ScrH() / BASE_H)
end

local function SW(x) return math.floor(x * UIScale() + 0.5) end
local function SH(y) return math.floor(y * UIScale() + 0.5) end

-- This table defines map layers. You can add entries for maps that have multiple vertical layers.
-- 'name' is a unique identifier for the layer.
-- 'height' is the Z coordinate for the camera when rendering the map image.
-- 'z_min' and 'z_max' define the vertical range for a player to be considered on this layer.
local mapLayers = {
    -- Replace "map_name_here" with the actual map name, e.g. "rp_pripyat".
    -- You can add more layers by copying the inner table structure.
    ["map_name_here"] = {
        {name = "inferior", height = 7000, z_min = -math.huge, z_max = 8000},
        {name = "middle", height = 9100, z_min = 8000, z_max = 10000},
        {name = "superior", height = 11000, z_min = 10000, z_max = math.huge},
    }, -- <--- Don't forget the comma whenever you add a map
    ["rp_barricadas_stalker_definitive_edition"] = {
        {name = "Darkscape", height = 4800, z_min = -math.huge, z_max = 5000},
        {name = "Garbage", height = 9100, z_min = 5000, z_max = 11000},
        {name = "Cordon", height = 16300, z_min = 11000, z_max = math.huge},
    }
}

CreateClientConVar("cl_point_r", 0, true, false)
CreateClientConVar("cl_point_g", 174, true, false)
CreateClientConVar("cl_point_b", 222, true, false)

CreateClientConVar("cl_map_displayfriends", 1, true, false)
CreateClientConVar("cl_map_showgps", 1, true, false)

surface.CreateFont("MapFont1", {
	font = "DermaLarge",
	weight = 600,
	size = 14,
})

local MAP = {}

local function RequestMAPSize()
	net.Start("RequestMAPSize")
	net.SendToServer()
end

net.Receive("SendMAPSize", function()
	local tbl = net.ReadTable()
	MAP = tbl
end)

local function RebuildMapImage(w, h, height, layerName)
	RequestMAPSize()

	if not MAP.SizeHeight or not MAP.SizeW or not MAP.SizeE or not MAP.SizeS or not MAP.SizeN then return end

	if not file.IsDir("mapimages", "DATA") then
		file.CreateDir("mapimages")
	end

	local oldFiles = file.Find("mapimages/"..game.GetMap()..w.."x"..h.."_"..layerName.."_*.jpg", "DATA")
	for _, v in ipairs(oldFiles) do
		file.Delete("mapimages/" .. v)
	end

	local mapRT = GetRenderTarget("ixStalkerMap_"..w.."_"..h.."_"..layerName, w, h)
	local oldRT = render.GetRenderTarget()
	render.SetRenderTarget(mapRT)
	render.Clear(0, 0, 0, 0, true, true)

	local data = {
		angles = Angle(90, 90, 0),
		origin = Vector(0, 0, height),
		x = 0,
		y = 0,
		w = w,
		h = h,
		bloomtone = false,
		drawviewmodel = false,
		ortho = true,
		ortholeft = MAP.SizeW,
		orthoright = MAP.SizeE,
		orthotop = MAP.SizeS,
		orthobottom =  MAP.SizeN
	}

	render.ClearStencil()
	render.SetStencilEnable(true)

	render.SetStencilWriteMask(255)
	render.SetStencilTestMask(255)
	render.SetStencilReferenceValue(255)
	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)

	render.SuppressEngineLighting(false)
	render.SetColorModulation(0, 1, 0)
	render.SetBlend(0.4)

	render.RenderView(data)

	local tbl = render.Capture({
		format = "jpeg",
		quality = 100,
		w = w, 
		h = h,
		x = 0,
		y = 0
	})

	render.SuppressEngineLighting(false)
	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)

	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilEnable(false)
	render.SetRenderTarget(oldRT)

	local fileName = "mapimages/"..game.GetMap()..w.."x"..h.."_"..layerName.."_"..os.time()..".jpg"
	local image = file.Open(fileName, "wb", "DATA")
	image:Write(tbl)
	image:Close()

	return fileName
end

local PANEL = {}

local function GetMapPos(pos)
	if not MAP.SizeX or not MAP.SizeY then return 0.5, 0.5 end
	local a, b
	if MAP.SizeS > 0 then
		a = pos.y + MAP.SizeN
	else
		a = pos.y - MAP.SizeS
	end
	if MAP.SizeW > 0 then
		b = pos.x + MAP.SizeE
	else
		b = pos.x - MAP.SizeW
	end
	return b / MAP.SizeX, a / MAP.SizeY
end

function PANEL:Init()
	local client = LocalPlayer()
	local character = client:GetCharacter()

	self:SetSize(SW(1165), SH(770)) -- Size of the whole panel
	self:SetPos(SW(54), SH(86)) -- Position of the whole panel
	self:SetDrawBackground(false)
	self:SetPaintBackground(false)
	
	self.showGPS = GetConVar("cl_map_showgps"):GetBool()
	net.Start("ixMapGPSToggle")
	net.WriteBool(self.showGPS)
	net.SendToServer()

	self.zoom = self.showGPS and 3 or 1
	self.offsetX = 0
	self.offsetY = 0
	RequestMAPSize()

	hook.Add("ixMapShouldReload", self, function()
		self.mapMaterials = nil
	end)

	local btnSize = 21
	local btnPad = 3

	local layers = mapLayers[game.GetMap()]
    local hasLayers = layers and #layers > 1
    local columns = hasLayers and 4 or 3

	local clusterW = btnSize * columns + btnPad * (columns - 1)
	local clusterH = btnSize * 3 + btnPad * 2
	
	local startX = self:GetWide() - SW(clusterW) - SW(10)
	local startY = self:GetTall() - SH(clusterH) - SH(10) - SH(20)
	
	local mat = Material("stalkerSHoC/ui/pda/navigation_panel.png")
	
	local function AddNavButton(bx, by, tx, ty, func, continuous, condition, colorFunc, tooltip)
		local btn = self:Add("DButton")
		btn:SetText("")
		btn:SetSize(SW(btnSize), SH(btnSize))
		btn:SetPos(startX + SW(bx * (btnSize + btnPad)), startY + SH(by * (btnSize + btnPad)))
		
		if (tooltip and not isfunction(tooltip)) then
			btn:SetTooltip(tooltip)
		end

		btn.Paint = function(s, w, h)
			if (condition and not condition()) then
				surface.SetDrawColor(100, 100, 100, 255)
			elseif (colorFunc) then
				local r, g, b, a = colorFunc(s)
				surface.SetDrawColor(r, g, b, a)
			elseif (s:IsHovered()) then
				surface.SetDrawColor(255, 255, 255, 255)
			else
				surface.SetDrawColor(200, 200, 200, 255)
			end
			surface.SetMaterial(mat)
			surface.DrawTexturedRectUV(0, 0, w, h, tx/69, ty/69, (tx+btnSize)/69, (ty+btnSize)/69)
		end

		local OnMousePressed = btn.OnMousePressed
		btn.OnMousePressed = function(s, code)
			if (condition and not condition()) then
				if (code == MOUSE_LEFT) then
					surface.PlaySound("helix/ui/rollover.wav")
				end
				return
			end

			if (code == MOUSE_LEFT) then
				surface.PlaySound("helix/ui/press.wav")
			end
			if (OnMousePressed) then OnMousePressed(s, code) end
		end

		if continuous then
			btn.Think = function(s)
				if s:IsDown() then func() end
				if (tooltip and isfunction(tooltip)) then s:SetTooltip(tooltip()) end
			end
		else
			btn.DoClick = func
			if (tooltip and isfunction(tooltip)) then
				btn.Think = function(s)
					s:SetTooltip(tooltip())
				end
			end
		end
	end
	
	-- GPS Toggle (Row 0, Col 0)
	AddNavButton(0, 0, 0, 0, function()
		self.showGPS = not self.showGPS
		RunConsoleCommand("cl_map_showgps", self.showGPS and "1" or "0")
		
		net.Start("ixMapGPSToggle")
		net.WriteBool(self.showGPS)
		net.SendToServer()

		if (self.showGPS) then
			self.offsetX = 0
			self.offsetY = 0
		else
			local px, py = GetMapPos(LocalPlayer():GetPos())
			local w, h = self:GetSize()
			local scale = self.zoom or 1
			local mapW, mapH = w * scale, h * scale
			
			self.offsetX = (0.5 - px) * mapW
			self.offsetY = mapH * (py - 0.5)
		end
	end, false, nil, function(s)
		if (not self.showGPS) then
			return 100, 100, 100, 255
		elseif (s:IsHovered()) then
			return 255, 255, 255, 255
		else
			return 200, 200, 200, 255
		end
	end, function() return self.showGPS and "GPS on" or "GPS off" end)

	-- Up (Row 0, Col 1)
	AddNavButton(1, 0, 24, 0, function() self.offsetY = (self.offsetY or 0) + 10 end, true, function()
		return (self.curMapY or 0) < -1
	end)
	
	-- Zoom In (Row 0, Col 2)
	AddNavButton(2, 0, 48, 0, function() self:SetZoom((self.zoom or 1) + 0.05) end, true, function()
		return (self.zoom or 1) < 5
	end, nil, "Zoom in")

	-- Left (Row 1, Col 0)
	AddNavButton(0, 1, 0, 24, function() self.offsetX = (self.offsetX or 0) + 10 end, true, function()
		return (self.curMapX or 0) < -1
	end)
	
	-- Center (Row 1, Col 1)
	AddNavButton(1, 1, 24, 24, function()
		if (self.showGPS) then
			self.offsetX = 0
			self.offsetY = 0

			if (hasLayers) then
				local ply = LocalPlayer()
				local playerZ = ply:GetPos().z
				for i, layer in ipairs(layers) do
					if (playerZ >= layer.z_min and playerZ < layer.z_max) then
						self.viewedLayerIndex = i
						break
					end
				end
			end
		end
	end, false, function() return self.showGPS end, nil, "Center on player")
	
	-- Right (Row 1, Col 2)
	AddNavButton(2, 1, 48, 24, function() self.offsetX = (self.offsetX or 0) - 10 end, true, function()
		return (self.curMapX or 0) > (self.curPanelW or 0) - (self.curMapW or 0) + 1
	end)
	
	-- Zoom Out (Row 2, Col 0)
	AddNavButton(0, 2, 0, 48, function() self:SetZoom((self.zoom or 1) - 0.05) end, true, function()
		return (self.zoom or 1) > 1
	end, nil, "Zoom out")

	-- Down (Row 2, Col 1)
	AddNavButton(1, 2, 24, 48, function() self.offsetY = (self.offsetY or 0) - 10 end, true, function()
		return (self.curMapY or 0) > (self.curPanelH or 0) - (self.curMapH or 0) + 1
	end)

	-- Show All (Row 2, Col 2)
	AddNavButton(2, 2, 48, 48, function() self.zoom = 1 self.offsetX = 0 self.offsetY = 0 end, false, nil, nil, "Show map")

	if (hasLayers) then
		if (not self.viewedLayerIndex) then
			local playerZ = client:GetPos().z
			for i, layer in ipairs(layers) do
				if (playerZ >= layer.z_min and playerZ < layer.z_max) then
					self.viewedLayerIndex = i
					break
				end
			end
			self.viewedLayerIndex = self.viewedLayerIndex or 1
		end

		-- Layer Up button
		AddNavButton(3, 0, 24, 0, function() -- Using up arrow icon
			self.viewedLayerIndex = self.viewedLayerIndex + 1
			if (self.viewedLayerIndex > #layers) then
				self.viewedLayerIndex = 1
			end
		end, false, nil, nil, "Next Area")

		-- Layer Down button
		AddNavButton(3, 1, 24, 48, function() -- Using down arrow icon
			self.viewedLayerIndex = self.viewedLayerIndex - 1
			if (self.viewedLayerIndex < 1) then
				self.viewedLayerIndex = #layers
			end
		end, false, nil, nil, "Previous Area")
	end

	self.layerLabel = self:Add("DLabel")
	self.layerLabel:SetFont("MapFont1")

	-- Refresh Button
	local refreshBtn = self:Add("DButton")
	local refreshSize = 32
	refreshBtn:SetText("")
	refreshBtn:SetSize(SW(refreshSize), SH(refreshSize))
	refreshBtn:SetPos(self:GetWide() - SW(refreshSize + 10), SH(10))
	refreshBtn:SetTooltip("Rebuild Map Image (your game might freeze a bit)")
	
	local refreshMat = Material("gui/html/refresh")
	refreshBtn.Paint = function(s, w, h)
		if (s.nextClick and s.nextClick > RealTime()) then
			surface.SetDrawColor(200, 200, 200, 200)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(refreshMat)

		local rotation = 0
		if (s.rotateStartTime) then
			local timeDiff = RealTime() - s.rotateStartTime
			local duration = 5
			if (timeDiff < duration) then
				rotation = (timeDiff / duration) * -360 * 5
			else
				s.rotateStartTime = nil
			end
		end

		surface.DrawTexturedRectRotated(w / 2, h / 2, w, h, rotation)
	end
	
	refreshBtn.DoClick = function(s)
		if (s.nextClick and s.nextClick > RealTime()) then return end
		s.nextClick = RealTime() + 5

		surface.PlaySound("helix/ui/press.wav")
		s.rotateStartTime = RealTime()

		timer.Simple(0.1, function()
			if (IsValid(self)) then
				self.mapMaterials = {}
				local layers = mapLayers[game.GetMap()]

				if (layers and #layers > 0) then
					for _, layer in ipairs(layers) do
						local mapPath = RebuildMapImage(3840, 2160, layer.height, layer.name)
						if (mapPath) then
							self.mapMaterials[layer.name] = Material("data/"..mapPath)
						end
					end
				else
					-- Fallback for maps without defined layers
					local mapPath = RebuildMapImage(3840, 2160, MAP.SizeHeight, "default")
					if (mapPath) then
						self.mapMaterials["default"] = Material("data/"..mapPath)
					end
				end
			end
		end)
	end
end

function PANEL:SetZoom(zoom)
	local oldZoom = self.zoom or 1
	self.zoom = math.Clamp(zoom, 1, 5)
	
	if (self.offsetX) then
		self.offsetX = self.offsetX * (self.zoom / oldZoom)
	end
	if (self.offsetY) then
		self.offsetY = self.offsetY * (self.zoom / oldZoom)
	end
end

function PANEL:OnMouseWheeled(delta)
	self:SetZoom((self.zoom or 1) + delta * 0.2)
end

function PANEL:OnMousePressed(code)
	if (code == MOUSE_LEFT) then
		self.dragging = true
		self.mouseX = gui.MouseX()
		self.mouseY = gui.MouseY()
		self:MouseCapture(true)
		self:SetCursor("sizeall")
	elseif (code == MOUSE_RIGHT) then
		local cx, cy = self:CursorPos()
		local mapX = self.curMapX or 0
		local mapY = self.curMapY or 0
		local mapW = self.curMapW or 1
		local mapH = self.curMapH or 1

		local fx = (cx - mapX) / mapW
		local fy = 1 - (cy - mapY) / mapH
		
		local worldX, worldY = 0, 0
		if (MAP.SizeX and MAP.SizeY) then
			local b = fx * MAP.SizeX
			local a = fy * MAP.SizeY
			
			if (MAP.SizeW > 0) then
				worldX = b - MAP.SizeE
			else
				worldX = b + MAP.SizeW
			end
			
			if (MAP.SizeS > 0) then
				worldY = a - MAP.SizeN
			else
				worldY = a + MAP.SizeS
			end
		end

		local menu = DermaMenu()
		menu:AddOption("Copy Coordinates", function()
			SetClipboardText(string.format("X: %.0f Y: %.0f", worldX, worldY))
		end):SetIcon("icon16/page_white_copy.png")

		local waypoints = ix.data.Get("mapWaypoints", {})
		if (#waypoints > 0) then
			menu:AddOption("Clear All Waypoints", function()
				Derma_Query("Are you sure you want to clear all waypoints?", "Clear Waypoints", "Yes", function()
					ix.data.Set("mapWaypoints", {})
				end, "No")
			end):SetIcon("icon16/bin_empty.png")
		end

		local anomalyFields = ix.data.Get("mapAnomalyFields", {})
		if (#anomalyFields > 0) then
			menu:AddOption("Clear All Anomaly Fields", function()
				Derma_Query("Are you sure you want to clear all anomaly fields?", "Clear Anomaly Fields", "Yes", function()
					ix.data.Set("mapAnomalyFields", {})
				end, "No")
			end):SetIcon("icon16/bin_empty.png")
		end

		local removeIndex

		for k, v in ipairs(waypoints) do
			local pos = Vector(v.x, v.y, 0)
			local fx, fy = GetMapPos(pos)
			local sx = (self.curMapX or 0) + fx * (self.curMapW or 1)
			local sy = (self.curMapY or 0) + (self.curMapH or 1) * (1 - fy)

			if (math.abs(cx - sx) < 12 and math.abs(cy - (sy - 8)) < 12) then
				removeIndex = k
				break
			end
		end

		local removeAnomalyIndex
		local worldW = math.abs((MAP.SizeE or 0) - (MAP.SizeW or 0))
		if (worldW == 0) then worldW = 1 end
		local pixelsPerUnit = (self.curMapW or 1) / worldW

		for k, v in ipairs(anomalyFields) do
			local pos = Vector(v.x, v.y, 0)
			local fx, fy = GetMapPos(pos)
			local sx = (self.curMapX or 0) + fx * (self.curMapW or 1)
			local sy = (self.curMapY or 0) + (self.curMapH or 1) * (1 - fy)

			local screenRadius = (v.radius or 200) * pixelsPerUnit

			if ((cx - sx)^2 + (cy - sy)^2 < screenRadius^2) then
				removeAnomalyIndex = k
				break
			end
		end

		if (removeIndex) then
			menu:AddOption("Remove Waypoint", function()
				table.remove(waypoints, removeIndex)
				ix.data.Set("mapWaypoints", waypoints)
			end):SetIcon("icon16/map_delete.png")
		end

		if (removeAnomalyIndex) then
			menu:AddOption("Remove Anomaly Field", function()
				table.remove(anomalyFields, removeAnomalyIndex)
				ix.data.Set("mapAnomalyFields", anomalyFields)
			end):SetIcon("icon16/error_delete.png")
			menu:AddOption("Resize Anomaly Field", function()
				Derma_StringRequest("Anomaly Field Size", "Enter the new radius for this anomaly field:", anomalyFields[removeAnomalyIndex].radius, function(text)
					local radius = tonumber(text)
					if (radius) then
						anomalyFields[removeAnomalyIndex].radius = radius
						ix.data.Set("mapAnomalyFields", anomalyFields)
					end
				end)
			end):SetIcon("icon16/arrow_out.png")

			menu:AddOption("Rename Anomaly Field", function()
				Derma_StringRequest("Anomaly Field Name", "Enter the new name for this anomaly field:", anomalyFields[removeAnomalyIndex].name or "", function(text)
					anomalyFields[removeAnomalyIndex].name = text
					ix.data.Set("mapAnomalyFields", anomalyFields)
				end)
			end):SetIcon("icon16/page_white_edit.png")

			local sub, subOption = menu:AddSubMenu("Set Anomaly Type")
			subOption:SetIcon("icon16/palette.png")
			local types = {
				{name = "Default", color = Color(255, 255, 255, 255)},
				{name = "Chemical", color = Color(150, 150, 0, 255)},
				{name = "Electrical", color = Color(0, 100, 168, 255)},
				{name = "Thermal", color = Color(150, 0, 0, 255)},
				{name = "Psionic", color = Color(85, 0, 140, 255)}
			}
			for _, v in ipairs(types) do
				sub:AddOption(v.name, function()
					anomalyFields[removeAnomalyIndex].color = v.color
					anomalyFields[removeAnomalyIndex].name = v.name
					ix.data.Set("mapAnomalyFields", anomalyFields)
				end)
			end
		end

		if (not removeIndex and not removeAnomalyIndex) then
			local sub, subOption = menu:AddSubMenu("Add Waypoint")
			subOption:SetIcon("icon16/map_add.png")
			local icons = {
				"icon16/flag_blue.png", "icon16/flag_green.png", "icon16/flag_orange.png",
				"icon16/flag_pink.png", "icon16/flag_purple.png", "icon16/flag_red.png", "icon16/flag_yellow.png"
			}

			for _, icon in ipairs(icons) do
				local name = string.gsub(string.match(icon, "flag_(.+).png"), "^%l", string.upper)
				sub:AddOption(name, function()
					Derma_StringRequest("Waypoint Name", "Enter a name for this waypoint:", "", function(text)
						table.insert(waypoints, {x = worldX, y = worldY, icon = icon, name = text, layer = self.viewedLayerIndex})
						ix.data.Set("mapWaypoints", waypoints)
					end)
				end):SetIcon(icon)
			end

			menu:AddOption("Add Anomaly Field", function()
				Derma_StringRequest("Anomaly Field Size", "Enter the radius for this anomaly field:", "200", function(text)
					local radius = tonumber(text)
					if (radius) then
						table.insert(anomalyFields, {x = worldX, y = worldY, radius = radius, layer = self.viewedLayerIndex})
						ix.data.Set("mapAnomalyFields", anomalyFields)
					end
				end)
			end):SetIcon("icon16/error_add.png")
		end

		menu:Open()
	end
end

function PANEL:OnMouseReleased(code)
	if (code == MOUSE_LEFT) then
		self.dragging = false
		self:MouseCapture(false)
		self:SetCursor("arrow")
	end
end

function PANEL:Think()
	if (self.dragging) then
		local x, y = gui.MouseX(), gui.MouseY()

		self.offsetX = (self.offsetX or 0) + (x - self.mouseX)
		self.offsetY = (self.offsetY or 0) + (y - self.mouseY)

		self.mouseX = x
		self.mouseY = y
	end

	local layers = mapLayers[game.GetMap()]
	if (layers and #layers > 1) then
		local ply = LocalPlayer()
		local playerZ = ply:GetPos().z
		local currentLayerIndex

		for i, layer in ipairs(layers) do
			if (playerZ >= layer.z_min and playerZ < layer.z_max) then
				currentLayerIndex = i
				break
			end
		end

		if (currentLayerIndex) then
			if (self.lastPlayerLayerIndex and self.lastPlayerLayerIndex != currentLayerIndex) then
				self.viewedLayerIndex = currentLayerIndex
			end
			self.lastPlayerLayerIndex = currentLayerIndex
		end
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBox(3, 0, 0, w, h, Color(0, 0, 0, 200))

	if (not self.mapMaterials) then
		self.mapMaterials = {}
		local layers = mapLayers[game.GetMap()]

		if (layers and #layers > 0) then
			for _, layer in ipairs(layers) do
				local files = file.Find("mapimages/"..game.GetMap().."3840x2160_"..layer.name.."_*.jpg", "DATA")
				local mapPath

				if (#files > 0) then
					table.sort(files)
					mapPath = "mapimages/" .. files[#files]
				else
					mapPath = RebuildMapImage(3840, 2160, layer.height, layer.name)
				end

				if (mapPath) then
					self.mapMaterials[layer.name] = Material("data/"..mapPath)
				end
			end
		else
			-- Fallback for maps without defined layers
			local files = file.Find("mapimages/"..game.GetMap().."3840x2160_default_*.jpg", "DATA")
			local mapPath

			if (#files > 0) then
				table.sort(files)
				mapPath = "mapimages/" .. files[#files]
			else
				mapPath = RebuildMapImage(3840, 2160, MAP.SizeHeight, "default")
			end

			if (mapPath) then
				self.mapMaterials["default"] = Material("data/"..mapPath)
			end
		end
	end

	local ply = LocalPlayer()
	local currentLayerName = "default"
	local currentLayerDisplayName
    local layers = mapLayers[game.GetMap()]
    local hasLayers = layers and #layers > 0
    local viewedLayer

	if (hasLayers) then
		if (not self.viewedLayerIndex) then
			local playerZ = ply:GetPos().z
			for i, layer in ipairs(layers) do
				if (playerZ >= layer.z_min and playerZ < layer.z_max) then
					self.viewedLayerIndex = i
					break
				end
			end
			self.viewedLayerIndex = self.viewedLayerIndex or 1
		end

		viewedLayer = layers[self.viewedLayerIndex]
		if (viewedLayer) then
			currentLayerName = viewedLayer.name
			currentLayerDisplayName = viewedLayer.name
		else
			currentLayerName = layers[1].name
			viewedLayer = layers[1]
			currentLayerDisplayName = layers[1].name
			self.viewedLayerIndex = 1
		end
	end

	self.layerLabel:SetText(currentLayerDisplayName and ("Area: " .. currentLayerDisplayName) or "")
	self.layerLabel:SizeToContents()
	self.layerLabel:SetPos(self:GetWide() - self.layerLabel:GetWide() - SW(10), self:GetTall() - self.layerLabel:GetTall() - SH(5))

	local currentMapMaterial = self.mapMaterials and self.mapMaterials[currentLayerName]

	if (currentMapMaterial) then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(currentMapMaterial)

		if not MAP.SizeHeight or not MAP.SizeW or not MAP.SizeE or not MAP.SizeS or not MAP.SizeN then 
			surface.DrawTexturedRect(0, 0, w, h)
			RequestMAPSize()
			return
		end

		local px, py
		if (self.showGPS) then
			px, py = GetMapPos(ply:GetPos())
		else
			px, py = 0.5, 0.5
		end

		local worldW = math.abs(MAP.SizeE - MAP.SizeW)
		local worldH = math.abs(MAP.SizeS - MAP.SizeN)
		local fitScale = math.max(w / worldW, h / worldH)

		local scale = self.zoom or 1
		local mapW, mapH = worldW * fitScale * scale, worldH * fitScale * scale
		local targetMapX = w / 2 - px * mapW + (self.offsetX or 0)
		local targetMapY = h / 2 - mapH * (1 - py) + (self.offsetY or 0)

		local mapX = math.Clamp(targetMapX, w - mapW, 0)
		local mapY = math.Clamp(targetMapY, h - mapH, 0)

		self.curMapX = mapX
		self.curMapY = mapY
		self.curMapW = mapW
		self.curMapH = mapH
		self.curPanelW = w
		self.curPanelH = h

		if (targetMapX != mapX) then
			self.offsetX = mapX - (w / 2 - px * mapW)
		end

		if (targetMapY != mapY) then
			self.offsetY = mapY - (h / 2 - mapH * (1 - py))
		end

		local x, y = self:LocalToScreen(0, 0)
		render.SetScissorRect(x, y, x + w, y + h, true)

		surface.DrawTexturedRect(mapX, mapY, mapW, mapH)

		local cx, cy = self:CursorPos()
		local tooltipText
		local anomalyFields = ix.data.Get("mapAnomalyFields", {})
		local anomalyIcon = Material("stalkerSHoC/ui/pda/area_icon.png")

		for _, v in ipairs(anomalyFields) do
			if (hasLayers and (v.layer or 1) ~= self.viewedLayerIndex) then continue end

			local fx, fy = GetMapPos(Vector(v.x, v.y, 0))
			local sx = mapX + fx * mapW
			local sy = mapY + mapH * (1 - fy)

			local pixelsPerUnit = mapW / worldW
			local screenRadius = (v.radius or 200) * pixelsPerUnit

			local col = v.color or Color(255, 255, 255, 255)
			surface.SetDrawColor(col.r, col.g, col.b, col.a)
			surface.SetMaterial(anomalyIcon)
			surface.DrawTexturedRect(sx - screenRadius, sy - screenRadius, screenRadius * 2, screenRadius * 2)

			if ((cx - sx)^2 + (cy - sy)^2 < screenRadius^2) then
				tooltipText = v.name or "Anomaly Field"
			end
		end

		local colorr, colorg, colorb = GetConVarNumber("cl_point_r"), GetConVarNumber("cl_point_g"), GetConVarNumber("cl_point_b")
		
		local iconMat = Material("stalkerSHoC/ui/pda/player_icon.png")
		local otherIconMat = Material("stalkerSHoC/ui/pda/player_other_icon.png")
		local pointerMat = Material("stalkerSHoC/ui/pda/player_pointer_icon.png")

		local function DrawPoint(pos, ang, color, name, isLocal)
			local fx, fy = GetMapPos(pos)
			local sx = mapX + fx * mapW
			local sy = mapY + mapH * (1 - fy)

			surface.SetDrawColor(color)
			if isLocal then
				surface.SetMaterial(iconMat)
			else
				surface.SetMaterial(otherIconMat)
			end
			surface.DrawTexturedRect(sx - 12.5, sy - 12.5, 25, 25)

			if isLocal then
				surface.SetMaterial(pointerMat)
				surface.DrawTexturedRectRotated(sx, sy, 51, 51, ang - 90)
			end

			draw.SimpleText(string.sub(name, 1, 8),  "MapFont1", sx + 1, sy + 27, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)  
			draw.SimpleText(string.sub(name, 1, 8),  "MapFont1", sx, sy + 26, color, TEXT_ALIGN_CENTER)
		end

		if (self.showGPS) then
			if (not hasLayers or (viewedLayer and ply:GetPos().z >= viewedLayer.z_min and ply:GetPos().z < viewedLayer.z_max)) then
				DrawPoint(ply:GetPos(), ply:EyeAngles().y, Color(colorr, colorg, colorb, 255), ply:Nick(), true)
			end
		end
		
		if (self.showGPS) and tobool(GetConVarNumber("cl_map_displayfriends")) then
			local character = ply:GetCharacter()
			for _, pl in pairs(player.GetAll()) do
				if pl != ply and pl:GetCharacter() and pl:GetNetVar("gpsActive", true) then
					if (not hasLayers or (viewedLayer and pl:GetPos().z >= viewedLayer.z_min and pl:GetPos().z < viewedLayer.z_max)) then
						local name = pl:Nick()
						if (character and not character:DoesRecognize(pl:GetCharacter())) then
							name = "???"
						end
						DrawPoint(pl:GetPos(), pl:EyeAngles().y, team.GetColor(pl:Team()), name, false)
					end
				end
			end
		end

		local waypoints = ix.data.Get("mapWaypoints", {})
		for _, v in ipairs(waypoints) do
			if (hasLayers and (v.layer or 1) ~= self.viewedLayerIndex) then continue end

			local fx, fy = GetMapPos(Vector(v.x, v.y, 0))
			local sx = mapX + fx * mapW
			local sy = mapY + mapH * (1 - fy)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Material(v.icon))
			surface.DrawTexturedRect(sx - 8, sy - 16, 16, 16)

			local dist = ply:GetPos():Distance(Vector(v.x, v.y, ply:GetPos().z)) * 0.01905
			draw.SimpleText(math.Round(dist) .. "m", "MapFont1", sx, sy - 16, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

			if (cx >= sx - 8 and cx <= sx + 8 and cy >= sy - 16 and cy <= sy) then
				tooltipText = (v.name and v.name != "") and (v.name .. " (" .. math.Round(dist) .. "m)") or (math.Round(dist) .. "m")
			end
		end
		
		render.SetScissorRect(0, 0, 0, 0, false)

		if (tooltipText and tooltipText != "") then
			surface.SetFont("MapFont1")
			local tw, th = surface.GetTextSize(tooltipText)
			local tx, ty = cx + 20, cy - 20

			if (tx + tw + 10 > w) then tx = tx - tw - 30 end
			if (ty + th + 6 > h) then ty = ty - th - 30 end

			draw.RoundedBox(4, tx, ty, tw + 10, th + 6, Color(0, 0, 0, 200))
			draw.SimpleText(tooltipText, "MapFont1", tx + 5, ty + 3, Color(255, 255, 255, 255))
		end

		if (cx >= 0 and cx <= w and cy >= 0 and cy <= h) then
			local fx = (cx - mapX) / mapW
			local fy = 1 - (cy - mapY) / mapH
			
			local worldX, worldY = 0, 0
			if (MAP.SizeX and MAP.SizeY) then
				local b = fx * MAP.SizeX
				local a = fy * MAP.SizeY
				
				if (MAP.SizeW > 0) then
					worldX = b - MAP.SizeE
				else
					worldX = b + MAP.SizeW
				end
				
				if (MAP.SizeS > 0) then
					worldY = a - MAP.SizeN
				else
					worldY = a + MAP.SizeS
				end
			end
			
			draw.SimpleText(string.format("X: %.0f Y: %.0f", worldX, worldY), "MapFont1", SW(10), h - SH(22), Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
		end
	end
end

vgui.Register("ixMapPanel", PANEL, "DPanel")

hook.Add("CreateMenuButtons", "ixMap", function(tabs)
	local client = LocalPlayer()
	local character = client:GetCharacter()
	local inventory = character and character:GetInventory()

	if (character and inventory) then
		local pdaItem

		for _, item in pairs(inventory:GetItems()) do
			if (item.isPDA and item:GetData("equip", false)) then
				pdaItem = item
				break
			end
		end

		if (pdaItem) then
			tabs["Map"] = function(container)
				container:Add("ixMapPanel")
			end
		end
	end
end)

hook.Add("InitPostEntity", "ixMapSyncGPS", function()
	net.Start("ixMapGPSToggle")
	net.WriteBool(GetConVar("cl_map_showgps"):GetBool())
	net.SendToServer()
end)

net.Receive("ixMapRebuild", function()
	local files = file.Find("mapimages/" .. game.GetMap() .. "*", "DATA")

	for _, v in ipairs(files) do
		file.Delete("mapimages/" .. v)
	end

	hook.Run("ixMapShouldReload")
end)