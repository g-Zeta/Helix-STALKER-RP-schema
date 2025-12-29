
local RECEIVER_NAME = "ixInventoryItem"

-- The queue for the rendered icons.
ICON_RENDER_QUEUE = ICON_RENDER_QUEUE or {}

local BASE_W, BASE_H = 1920, 1080
local function UIScale()
  -- uniform scale, using the minimum axis to avoid stretch
  return math.min(ScrW() / BASE_W, ScrH() / BASE_H)
end

local function SW(x) return math.floor(x * UIScale() + 0.5) end
local function SH(y) return math.floor(y * UIScale() + 0.5) end

-- To make making inventory variant, This must be followed up.
local function RenderNewIcon(panel, itemTable)
	local model = itemTable:GetModel()

	-- re-render icons
	if ((itemTable.iconCam and !ICON_RENDER_QUEUE[string.lower(model)]) or itemTable.forceRender) then
		local iconCam = itemTable.iconCam
		iconCam = {
			cam_pos = iconCam.pos,
			cam_ang = iconCam.ang,
			cam_fov = iconCam.fov,
		}
		ICON_RENDER_QUEUE[string.lower(model)] = true

		panel.Icon:RebuildSpawnIconEx(
			iconCam
		)
	end
end

local function InventoryAction(action, itemID, invID, data)
	net.Start("ixInventoryAction")
		net.WriteString(action)
		net.WriteUInt(itemID, 32)
		net.WriteUInt(invID, 32)
		net.WriteTable(data or {})
	net.SendToServer()
end

-- A global utility function to format numbers with commas as thousand separators.
function ix.util.FormatNumber(number)
	if not tonumber(number) then return number end
	local s = tostring(math.floor(number))
	local formatted = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	-- Remove leading comma if the number of digits is a multiple of 3
	if formatted:sub(1,1) == "," then
		formatted = formatted:sub(2)
	end
	return formatted
end

ix.currency.Get = function(price, noSymbol) return (noSymbol and "" or (ix.currency.symbol or "$") .. " ") .. (ix.util.FormatNumber(price) or "0") end

local PANEL = {}

AccessorFunc(PANEL, "itemTable", "ItemTable")
AccessorFunc(PANEL, "inventoryID", "InventoryID")

function PANEL:Init()
	self:Droppable(RECEIVER_NAME)
end

function PANEL:OnMousePressed(code)
	if (code == MOUSE_LEFT and self:IsDraggable()) then
		self:MouseCapture(true)
		self:DragMousePress(code)

		self.clickX, self.clickY = input.GetCursorPos()
	elseif (code == MOUSE_RIGHT and self.DoRightClick) then
		self:DoRightClick()
	end
end

function PANEL:OnMouseReleased(code)
	-- move the item into the world if we're dropping on something that doesn't handle inventory item drops
	if (!dragndrop.m_ReceiverSlot or dragndrop.m_ReceiverSlot.Name != RECEIVER_NAME) then
		self:OnDrop(dragndrop.IsDragging())
	end

	self:DragMouseRelease(code)
	self:SetZPos(99)
	self:MouseCapture(false)
end

function PANEL:DoRightClick()
	local itemTable = self.itemTable
	local inventory = self.inventoryID

	if (itemTable and inventory) then
		itemTable.player = LocalPlayer()

		local menu = DermaMenu()
		local override = hook.Run("CreateItemInteractionMenu", self, menu, itemTable)

		if (override == true) then
			if (menu.Remove) then
				menu:Remove()
			end

			return
		end

		for k, v in SortedPairs(itemTable.functions) do
			if (k == "drop" or k == "combine" or (v.OnCanRun and v.OnCanRun(itemTable) == false)) then
				continue
			end

			-- is Multi-Option Function
			if (v.isMulti) then
				local subMenu, subMenuOption = menu:AddSubMenu(L(v.name or k), function()
					itemTable.player = LocalPlayer()
						local send = true

						if (v.OnClick) then
							send = v.OnClick(itemTable)
						end

						if (v.sound) then
							surface.PlaySound(v.sound)
						end

						if (send != false) then
							InventoryAction(k, itemTable.id, inventory)
						end
					itemTable.player = nil
				end)
				subMenuOption:SetImage(v.icon or "icon16/brick.png")

				if (v.multiOptions) then
					local options = isfunction(v.multiOptions) and v.multiOptions(itemTable, LocalPlayer()) or v.multiOptions

					for _, sub in pairs(options) do
						subMenu:AddOption(L(sub.name or "subOption"), function()
							itemTable.player = LocalPlayer()
								local send = true

								if (sub.OnClick) then
									send = sub.OnClick(itemTable)
								end

								if (sub.sound) then
									surface.PlaySound(sub.sound)
								end

								if (send != false) then
									InventoryAction(k, itemTable.id, inventory, sub.data)
								end
							itemTable.player = nil
						end)
					end
				end
			else
				menu:AddOption(L(v.name or k), function()
					itemTable.player = LocalPlayer()
						local send = true

						if (v.OnClick) then
							send = v.OnClick(itemTable)
						end

						if (v.sound) then
							surface.PlaySound(v.sound)
						end

						if (send != false) then
							InventoryAction(k, itemTable.id, inventory)
						end
					itemTable.player = nil
				end):SetImage(v.icon or "icon16/brick.png")
			end
		end

		-- we want drop to show up as the last option
		local info = itemTable.functions.drop

		if (info and info.OnCanRun and info.OnCanRun(itemTable) != false) then
			menu:AddOption(L(info.name or "drop"), function()
				itemTable.player = LocalPlayer()
					local send = true

					if (info.OnClick) then
						send = info.OnClick(itemTable)
					end

					if (info.sound) then
						surface.PlaySound(info.sound)
					end

					if (send != false) then
						InventoryAction("drop", itemTable.id, inventory)
					end
				itemTable.player = nil
			end):SetImage("stalkerCoP/ui/icons/misc/drop.png")
		end

		menu:Open()
		itemTable.player = nil
	end
end

function PANEL:OnDrop(bDragging, inventoryPanel, inventory, gridX, gridY)
	local item = self.itemTable

	if (!item or !bDragging) then
		return
	end

	if (!IsValid(inventoryPanel)) then
		local inventoryID = self.inventoryID

		if (inventoryID) then
			InventoryAction("drop", item.id, inventoryID, {})
		end
	elseif (inventoryPanel:IsAllEmpty(gridX, gridY, item.width, item.height, self)) then
		local oldX, oldY = self.gridX, self.gridY

		if (oldX != gridX or oldY != gridY or self.inventoryID != inventoryPanel.invID) then
			self:Move(gridX, gridY, inventoryPanel)
		end
	elseif (inventoryPanel.combineItem) then
		local combineItem = inventoryPanel.combineItem
		local inventoryID = combineItem.invID

		if (inventoryID) then
			combineItem.player = LocalPlayer()
				if (combineItem.functions.combine.sound) then
					surface.PlaySound(combineItem.functions.combine.sound)
				end

				InventoryAction("combine", combineItem.id, inventoryID, {item.id})
			combineItem.player = nil
		end
	end
end

function PANEL:Move(newX, newY, givenInventory, bNoSend)
	local iconSize = givenInventory.iconSize
	local oldX, oldY = self.gridX, self.gridY
	local oldParent = self:GetParent()

	if (givenInventory:OnTransfer(oldX, oldY, newX, newY, oldParent, bNoSend) == false) then
		return
	end

	local x = (newX - 1) * iconSize + SW(7)
	local y = (newY - 1) * iconSize + givenInventory:GetPadding(2)

	self.gridX = newX
	self.gridY = newY

	self:SetParent(givenInventory)
	self:SetPos(x, y)

	if (self.slots) then
		for _, v in ipairs(self.slots) do
			if (IsValid(v) and v.item == self) then
				v.item = nil
			end
		end
	end

	self.slots = {}

	for currentX = 1, self.gridW do
		for currentY = 1, self.gridH do
			local slot = givenInventory.slots[self.gridX + currentX - 1][self.gridY + currentY - 1]

			slot.item = self
			self.slots[#self.slots + 1] = slot
		end
	end
end

function PANEL:PaintOver(width, height)
	local itemTable = self.itemTable

	if (itemTable and itemTable.PaintOver) then
		itemTable.PaintOver(self, itemTable, width, height)
	end
end

function PANEL:ExtraPaint(width, height)
end

local gradient = Material("vgui/gradient-d")

function PANEL:Paint(width, height)
	--surface.SetDrawColor(255, 255, 255, 10)			-- ixItemIcon background (keep it for debugging purposes)
	--surface.DrawRect(2, 2, width - 4, height - 4)

	if (self.itemTable and self.itemTable:GetData("equip") and self.gridX) then	-- Gradient effect for equipped items in the inventory
		surface.SetDrawColor(0, 250, 0, 5)
		surface.SetMaterial(gradient)
		surface.DrawTexturedRect(2, 2, width - 4, height - 4)
	end

	if self.itemTable and self.gridX then
		surface.SetDrawColor(0, 0, 0, 85)
		surface.DrawRect(2, 2, width - 4, height - 4)
	end
	
	self:ExtraPaint(width, height)
end

vgui.Register("ixItemIcon", PANEL, "SpawnIcon")

PANEL = {}
DEFINE_BASECLASS("DFrame")

AccessorFunc(PANEL, "iconSize", "IconSize", FORCE_NUMBER)
AccessorFunc(PANEL, "bHighlighted", "Highlighted", FORCE_BOOL)

local moneyLabel
local weightLabel
local charbackgroundicon

-- compute "current of max" weight string respecting unit preference and buffs
local function computeWeightString()
    local char = LocalPlayer() and LocalPlayer():GetCharacter()
    if not char then return "" end

    local isImperial = ix.option.Get("imperial", false)

    -- current weight
    local cur = char:GetData("Weight", 0)

    -- total max = base + over + buffs; fall back to config if character data missing
    local baseMax = ix.config.Get("maxWeight", 30)
    local overMax = ix.config.Get("maxOverWeight", 20)
    local carryBuff = char:GetData("WeightBuffCur") or 0
    local totalMax = baseMax + overMax + carryBuff

    return ix.weight.WeightString(cur, isImperial) .. " of " .. ix.weight.WeightString(totalMax, isImperial)
end

local function RefreshMoney()
    if not IsValid(moneyLabel) then return end
    local char = LocalPlayer() and LocalPlayer():GetCharacter()
    if not char then return end
    moneyLabel:SetText(ix.currency.Get(char:GetMoney() or 0))
end

local function RefreshWeight()
    if not IsValid(weightLabel) then return end
    weightLabel:SetText(computeWeightString())
end

local function GetEquippedPDAAvatar()
    local client = LocalPlayer()
    local char = client and client:GetCharacter()
    if not char then return nil end

    local inv = char:GetInventory()
    if not inv then return nil end

    for _, item in pairs(inv:GetItems()) do
        if item.isPDA and item:GetData("equip", false) then
            -- PDA stores its own "avatar"
            return item:GetData("avatar")
        end
    end

    return nil
end

local function ResolveAvatarPath()
    local char = LocalPlayer() and LocalPlayer():GetCharacter()
    if not char then return "stalker/ui/avatars/nodata.png" end

    return GetEquippedPDAAvatar()
        or char:GetData("pdaavatar")
        or char:GetData("avatar")
        or "stalker/ui/avatars/nodata.png"
end

local function RefreshCharAvatar()
    if not IsValid(charbackgroundicon) then return end
    charbackgroundicon:SetImage(ResolveAvatarPath())
end

function PANEL:Init()
	local baseIcon = 60
	local scaling = UIScale()

	self:SetIconSize(math.floor(baseIcon * scaling + 0.5))
	self:ShowCloseButton(false)
	self:SetDraggable(true)
	self:SetSizable(true)
	self:SetTitle(L"inv")
	self:Receiver(RECEIVER_NAME, self.ReceiveDrop)

	self.btnMinim:SetVisible(false)
	self.btnMinim:SetMouseInputEnabled(false)
	self.btnMaxim:SetVisible(false)
	self.btnMaxim:SetMouseInputEnabled(false)

	self.panels = {}
end

function PANEL:GetPadding(index)
	return select(index, self:GetDockPadding())
end

function PANEL:SetTitle(text)
	if (text == nil) then
		self.oldPadding = {self:GetDockPadding()}

		self.lblTitle:SetText("")
		self.lblTitle:SetVisible(false)

		self:DockPadding(5, 5, 5, 5)
	else
		if (self.oldPadding) then
			self:DockPadding(unpack(self.oldPadding))
			self.oldPadding = nil
		end

		BaseClass.SetTitle(self, text)
	end
end

function PANEL:FitParent(invWidth, invHeight)
	local parent = self:GetParent()

	if (!IsValid(parent)) then
		return
	end

	local padding = SW(4)
	local iconSize = math.floor(math.min((self:GetParent():GetWide() - padding * 2) / invWidth, (self:GetParent():GetTall() - padding * 2) / invHeight) + 0.5)
	
	self:SetSize(iconSize * invWidth + padding * 2, iconSize * invHeight + padding * 2)
	self:SetIconSize(iconSize)
end

function PANEL:OnRemove()
	if (self.childPanels) then
		for _, v in ipairs(self.childPanels) do
			if (v != self) then
				v:Remove()
			end
		end
	end
end

function PANEL:ViewOnly()
	self.viewOnly = true

	for _, icon in pairs(self.panels) do
		icon.OnMousePressed = nil
		icon.OnMouseReleased = nil
		icon.doRightClick = nil
	end
end

function PANEL:SetInventory(inventory, bFitParent)
	if (inventory.slots) then
		local invWidth, invHeight = inventory:GetSize()
		self.invID = inventory:GetID()

		if (IsValid(ix.gui.inv1) and ix.gui.inv1.childPanels and inventory != LocalPlayer():GetCharacter():GetInventory()) then
			self:SetIconSize(ix.gui.inv1:GetIconSize())
			self:SetPaintedManually(true)
			self.bNoBackgroundBlur = true

			ix.gui.inv1.childPanels[#ix.gui.inv1.childPanels + 1] = self
		elseif (bFitParent) then
			self:FitParent(invWidth, invHeight)
		else
			self:SetSize(self.iconSize, self.iconSize)
		end

		self:SetGridSize(invWidth, invHeight)

		for x, items in pairs(inventory.slots) do
			for y, data in pairs(items) do
				if (!data.id) then continue end

				local item = ix.item.instances[data.id]

				if (item and !IsValid(self.panels[item.id])) then

					local icon = self:AddIcon(item:GetModel() or "models/props_junk/popcan01a.mdl",
						x, y, item.width, item.height, item:GetSkin())

					if (IsValid(icon)) then
						icon:SetHelixTooltip(function(tooltip)
							ix.hud.PopulateItemTooltip(tooltip, item)
						end)

						self.panels[item.id] = icon
					end
				end
			end
		end
	end
end

function PANEL:SetGridSize(w, h)
	local paddingYTop, paddingYBottom = self:GetPadding(2), self:GetPadding(4)
	local newWidth = w * self.iconSize + SW(14)
	local newHeight = h * self.iconSize + paddingYTop + paddingYBottom

	self.gridW = w
	self.gridH = h

	self:SetSize(newWidth, newHeight)
	self:SetMinWidth(newWidth)
	self:SetMinHeight(newHeight)
	self:BuildSlots()
end

function PANEL:PerformLayout(width, height)
	BaseClass.PerformLayout(self, width, height)

	if (self.Sizing and self.gridW and self.gridH) then
		local newWidth = (width - SW(14)) / self.gridW
		local newHeight = (height - self:GetPadding(2) + self:GetPadding(4)) / self.gridH

		self:SetIconSize((newWidth + newHeight) / 2)
		self:RebuildItems()
	end
end

function PANEL:BuildSlots()
	local iconSize = self.iconSize

	self.slots = self.slots or {}

	for _, v in ipairs(self.slots) do
		for _, v2 in ipairs(v) do
			v2:Remove()
		end
	end

	self.slots = {}

	for x = 1, self.gridW do
		self.slots[x] = {}

		for y = 1, self.gridH do
			local slot = self:Add("DPanel")
			slot:SetZPos(-999)
			slot.gridX = x
			slot.gridY = y
			slot:SetPos((x - 1) * iconSize + SW(7), (y - 1) * iconSize + self:GetPadding(2))
			slot:SetSize(iconSize, iconSize)
			slot.Paint = function(panel, width, height)
				derma.SkinFunc("PaintInventorySlot", panel, width, height)
			end

			self.slots[x][y] = slot
		end
	end
end

function PANEL:RebuildItems()
	local iconSize = self.iconSize

	for x = 1, self.gridW do
		for y = 1, self.gridH do
			local slot = self.slots[x][y]

			slot:SetPos((x - 1) * iconSize + SW(7), (y - 1) * iconSize + self:GetPadding(2))
			slot:SetSize(iconSize, iconSize)
		end
	end

	for _, v in pairs(self.panels) do
		if (IsValid(v)) then
			v:SetPos(self.slots[v.gridX][v.gridY]:GetPos())
			v:SetSize(v.gridW * iconSize, v.gridH * iconSize)
		end
	end
end

function PANEL:PaintDragPreview(width, height, mouseX, mouseY, itemPanel)
	local iconSize = self.iconSize
	local item = itemPanel.GetItemTable and itemPanel:GetItemTable() or itemPanel.itemTable

	if (item) then
		local itemW = item.width or 1
		local itemH = item.height or 1
		local inventory = ix.item.inventories[self.invID]
		local dropX = math.ceil((mouseX - SW(7) - (itemW - 1) * iconSize) / iconSize)
		local dropY = math.ceil((mouseY - self:GetPadding(2) - (itemH - 1) * iconSize) / iconSize)

		local hoveredPanel = vgui.GetHoveredPanel()

		if (IsValid(hoveredPanel) and hoveredPanel != itemPanel and hoveredPanel.GetItemTable) then
			local hoveredItem = hoveredPanel:GetItemTable()

			if (hoveredItem) then
				local info = hoveredItem.functions.combine

				if (info and info.OnCanRun and info.OnCanRun(hoveredItem, {item.id}) != false) then
					surface.SetDrawColor(ColorAlpha(derma.GetColor("Info", self, Color(200, 0, 0)), 20))
					surface.DrawRect(
						hoveredPanel.x,
						hoveredPanel.y,
						hoveredPanel:GetWide(),
						hoveredPanel:GetTall()
					)

					self.combineItem = hoveredItem

					return
				end
			end
		end

		self.combineItem = nil

		-- don't draw grid if we're dragging it out of bounds
		if (inventory) then
			local invWidth, invHeight = inventory:GetSize()

			if (dropX < 1 or dropY < 1 or
				dropX + itemW - 1 > invWidth or
				dropY + itemH - 1 > invHeight) then
				return
			end
		end

		local bEmpty = true

		for x = 0, itemW - 1 do
			for y = 0, itemH - 1 do
				local x2 = dropX + x
				local y2 = dropY + y

				bEmpty = self:IsEmpty(x2, y2, itemPanel)

				if (!bEmpty) then
					-- no need to iterate further since we know something is blocking the hovered grid cells, break through both loops
					goto finish
				end
			end
		end

		::finish::
		local previewColor = ColorAlpha(derma.GetColor(bEmpty and "Success" or "Error", self, Color(200, 0, 0)), 20)

		surface.SetDrawColor(previewColor)
		surface.DrawRect(
			(dropX - 1) * iconSize + SW(7),
			(dropY - 1) * iconSize + self:GetPadding(2),
			itemW * iconSize,
			itemH * iconSize
		)
	end
end

function PANEL:PaintOver(width, height)
	local panel = self.previewPanel

	if (IsValid(panel)) then
		local itemPanel = (dragndrop.GetDroppable() or {})[1]

		if (IsValid(itemPanel)) then
			self:PaintDragPreview(width, height, self.previewX, self.previewY, itemPanel)
		end
	end

	self.previewPanel = nil
end

function PANEL:IsEmpty(x, y, this)
	return (self.slots[x] and self.slots[x][y]) and (!IsValid(self.slots[x][y].item) or self.slots[x][y].item == this)
end

function PANEL:IsAllEmpty(x, y, width, height, this)
	for x2 = 0, width - 1 do
		for y2 = 0, height - 1 do
			if (!self:IsEmpty(x + x2, y + y2, this)) then
				return false
			end
		end
	end

	return true
end

function PANEL:OnTransfer(oldX, oldY, x, y, oldInventory, noSend)
	local inventories = ix.item.inventories
	local inventory = inventories[oldInventory.invID]
	local inventory2 = inventories[self.invID]
	local item

	if (inventory) then
		item = inventory:GetItemAt(oldX, oldY)

		if (!item) then
			return false
		end

		if (hook.Run("CanTransferItem", item, inventories[oldInventory.invID], inventories[self.invID]) == false) then
			return false, "notAllowed"
		end

		if (item.CanTransfer and
			item:CanTransfer(inventory, inventory != inventory2 and inventory2 or nil) == false) then
			return false
		end
	end

	if (!noSend) then
		net.Start("ixInventoryMove")
			net.WriteUInt(oldX, 6)
			net.WriteUInt(oldY, 6)
			net.WriteUInt(x, 6)
			net.WriteUInt(y, 6)
			net.WriteUInt(oldInventory.invID, 32)
			net.WriteUInt(self != oldInventory and self.invID or oldInventory.invID, 32)
		net.SendToServer()
	end

	if (inventory) then
		inventory.slots[oldX][oldY] = nil
	end

	if (item and inventory2) then
		inventory2.slots[x] = inventory2.slots[x] or {}
		inventory2.slots[x][y] = item
	end
end

function PANEL:AddIcon(model, x, y, w, h, skin)
	local iconSize = self.iconSize

	w = w or 1
	h = h or 1

	if (self.slots[x] and self.slots[x][y]) then
		local panel = self:Add("ixItemIcon")
		panel:SetSize(w * iconSize, h * iconSize)
		panel:SetZPos(999)
		panel:InvalidateLayout(true)
		panel:SetModel(model, skin)
		panel:SetPos(self.slots[x][y]:GetPos())
		panel.gridX = x
		panel.gridY = y
		panel.gridW = w
		panel.gridH = h

		local inventory = ix.item.inventories[self.invID]

		if (!inventory) then
			return
		end

		local itemTable = inventory:GetItemAt(panel.gridX, panel.gridY)

		panel:SetInventoryID(inventory:GetID())
		panel:SetItemTable(itemTable)

		if (self.panels[itemTable:GetID()]) then
			self.panels[itemTable:GetID()]:Remove()
		end

		if (itemTable.exRender) then
			panel.Icon:SetVisible(false)
			panel.ExtraPaint = function(this, panelX, panelY)
				local exIcon = ikon:GetIcon(itemTable.uniqueID)
				if (exIcon) then
					surface.SetMaterial(exIcon)
					surface.SetDrawColor(color_white)
					surface.DrawTexturedRect(0, 0, panelX, panelY)
				else
					ikon:renderIcon(
						itemTable.uniqueID,
						itemTable.width,
						itemTable.height,
						itemTable:GetModel(),
						itemTable.material,
						itemTable.iconCam
					)
				end
			end
		elseif (itemTable.img) then
			panel.Icon:SetVisible(false)
			panel.ExtraPaint = function(this, panelX, panelY)
				local icon = itemTable.img
				if (icon) then
					surface.SetMaterial(icon)
					surface.SetDrawColor(color_white)
					surface.DrawTexturedRect(0, 0, panelX, panelY)
				end
			end
		else
			-- yeah..
			RenderNewIcon(panel, itemTable)
		end

		panel.slots = {}

		for i = 0, w - 1 do
			for i2 = 0, h - 1 do
				local slot = self.slots[x + i] and self.slots[x + i][y + i2]

				if (IsValid(slot)) then
					slot.item = panel
					panel.slots[#panel.slots + 1] = slot
				else
					for _, v in ipairs(panel.slots) do
						v.item = nil
					end

					panel:Remove()

					return
				end
			end
		end

		return panel
	end
end

function PANEL:ReceiveDrop(panels, bDropped, menuIndex, x, y)
	local panel = panels[1]

	if (!IsValid(panel)) then
		self.previewPanel = nil
		return
	end

	if (bDropped) then
		local inventory = ix.item.inventories[self.invID]

		if (inventory and panel.OnDrop) then
			local item = panel.GetItemTable and panel:GetItemTable() or panel.itemTable
			local itemW = panel.gridW or (item and item.width) or 1
			local itemH = panel.gridH or (item and item.height) or 1

			local dropX = math.ceil((x - SW(7) - (itemW - 1) * self.iconSize) / self.iconSize)
			local dropY = math.ceil((y - self:GetPadding(2) - (itemH - 1) * self.iconSize) / self.iconSize)

			panel:OnDrop(true, self, inventory, dropX, dropY)
		end

		self.previewPanel = nil
	else
		self.previewPanel = panel
		self.previewX = x
		self.previewY = y
	end
end

vgui.Register("ixInventory", PANEL, "DFrame")

PANEL = {}

AccessorFunc(PANEL, "itemFilter", "ItemFilter")
AccessorFunc(PANEL, "equipFunction", "EquipFunction")
AccessorFunc(PANEL, "unequipFunction", "UnequipFunction")
AccessorFunc(PANEL, "inventoryID", "InventoryID")
AccessorFunc(PANEL, "iconRotation", "IconRotation", FORCE_NUMBER)
AccessorFunc(PANEL, "slotIndex", "SlotIndex", FORCE_NUMBER)

function PANEL:Init()
	self:SetItemFilter(function(item) return true end)
	self:SetEquipFunction("Equip")
	self:SetUnequipFunction("EquipUn")
	self:SetPaintBackground(false)

	self:Receiver(RECEIVER_NAME, self.ReceiveDrop)
end

function PANEL:ReceiveDrop(panels, bDropped, menuIndex, x, y)
	local panel = panels[1]

	if (!IsValid(panel)) then return end

	local item = panel.itemTable

	if (!item) then return end
	if (self.itemFilter and !self.itemFilter(item)) then return end

	if (bDropped) then
		if (item:GetData("equip")) then return end

		local action = item.functions[self:GetEquipFunction()]
		local actionName = self:GetEquipFunction()

		if (!action) then
			for k, v in pairs(item.functions) do
				if (k:lower() == actionName:lower()) then
					action = v
					actionName = k
					break
				end
			end
		end

		if (action) then
			item.player = LocalPlayer()

			if (!action.OnCanRun or action.OnCanRun(item) != false) then
				local send = true

				if (action.OnClick) then
					send = action.OnClick(item)
				end

				if (action.sound) then
					surface.PlaySound(action.sound)
				end

				if (send != false) then
					InventoryAction(actionName, item.id, panel.inventoryID)
				end
			end

			item.player = nil
		end
	end
end

function PANEL:Think()
	local char = LocalPlayer():GetCharacter()
	if (!char) then return end
	local inv = char:GetInventory()
	if (!inv) then return end

	self:SetInventoryID(inv:GetID())

	local equippedItem = nil

	if (self:GetSlotIndex()) then
		local found = {}
		for _, item in pairs(inv:GetItems()) do
			if (item:GetData("equip", false) and self.itemFilter(item)) then
				table.insert(found, item)
			end
		end
		table.sort(found, function(a, b) return a.id < b.id end)
		equippedItem = found[self:GetSlotIndex()]
	else
		for _, item in pairs(inv:GetItems()) do
			if (item:GetData("equip", false) and self.itemFilter(item)) then
				equippedItem = item
				break
			end
		end
	end

	if (equippedItem) then
		if (!IsValid(self.itemIcon)) then
			local icon = self:Add("ixItemIcon")
			icon:SetSize(self:GetWide(), self:GetTall())
			icon:SetModel(equippedItem:GetModel(), equippedItem:GetSkin())
			icon:SetItemTable(equippedItem)
			icon:SetInventoryID(inv:GetID())
			icon:SetHelixTooltip(function(tooltip)
				ix.hud.PopulateItemTooltip(tooltip, equippedItem)
			end)

			if (equippedItem.img) then
				if (IsValid(icon.Icon)) then icon.Icon:SetVisible(false) end
				icon.ExtraPaint = function(this, panelX, panelY)
					local exIcon = equippedItem.img
					if (exIcon) then
						surface.SetMaterial(exIcon)
						surface.SetDrawColor(color_white)
						local rot = self:GetIconRotation() or 0
						local iw, ih = equippedItem.width or 1, equippedItem.height or 1

						if (rot % 180 == 90) then
							local newH = panelX
							local newW = newH * (iw / ih)
							if (newW > panelY) then
								newW = panelY
								newH = newW * (ih / iw)
							end
							surface.DrawTexturedRectRotated(panelX * 0.5, panelY * 0.5, newW, newH, rot)
						else
							local newW = panelX
							local newH = newW * (ih / iw)
							if (newH > panelY) then
								newH = panelY
								newW = newH * (iw / ih)
							end
							surface.DrawTexturedRectRotated(panelX * 0.5, panelY * 0.5, newW, newH, rot)
						end
					end
				end
			else
				if (IsValid(icon.Icon)) then icon.Icon:SetVisible(true) end
				icon.ExtraPaint = function() end
			end

			icon.OnDrop = function(this, bDragging, inventoryPanel, inventory, gridX, gridY)
				local item = this.itemTable
				if (!item or !bDragging) then return end

				if (!IsValid(inventoryPanel)) then
					InventoryAction("drop", item.id, item.invID, {})
					return
				end

				local invIcon = inventoryPanel.panels[item.id]

				if (inventoryPanel:IsAllEmpty(gridX, gridY, item.width, item.height, invIcon)) then
					local oldX, oldY

					if (IsValid(invIcon)) then
						oldX, oldY = invIcon.gridX, invIcon.gridY
						invIcon:Move(gridX, gridY, inventoryPanel, true)
					else
						oldX, oldY = item.gridX, item.gridY
					end

					net.Start("ixInventoryMove")
						net.WriteUInt(oldX, 6)
						net.WriteUInt(oldY, 6)
						net.WriteUInt(gridX, 6)
						net.WriteUInt(gridY, 6)
						net.WriteUInt(item.invID, 32)
						net.WriteUInt(inventoryPanel.invID, 32)
					net.SendToServer()

					InventoryAction(self:GetUnequipFunction(), item.id, item.invID)
				else
					InventoryAction(self:GetUnequipFunction(), item.id, item.invID)
				end
			end

			self.itemIcon = icon
		elseif (self.itemIcon:GetItemTable() != equippedItem) then
			self.itemIcon:SetItemTable(equippedItem)
			self.itemIcon:SetModel(equippedItem:GetModel(), equippedItem:GetSkin())
			self.itemIcon:SetHelixTooltip(function(tooltip)
				ix.hud.PopulateItemTooltip(tooltip, equippedItem)
			end)

			if (equippedItem.img) then
				if (IsValid(self.itemIcon.Icon)) then self.itemIcon.Icon:SetVisible(false) end
				self.itemIcon.ExtraPaint = function(this, panelX, panelY)
					local exIcon = equippedItem.img
					if (exIcon) then
						surface.SetMaterial(exIcon)
						surface.SetDrawColor(color_white)
						local rot = self:GetIconRotation() or 0
						local iw, ih = equippedItem.width or 1, equippedItem.height or 1

						if (rot % 180 == 90) then
							local newH = panelX
							local newW = newH * (iw / ih)
							if (newW > panelY) then
								newW = panelY
								newH = newW * (ih / iw)
							end
							surface.DrawTexturedRectRotated(panelX * 0.5, panelY * 0.5, newW, newH, rot)
						else
							local newW = panelX
							local newH = newW * (ih / iw)
							if (newH > panelY) then
								newH = panelY
								newW = newH * (iw / ih)
							end
							surface.DrawTexturedRectRotated(panelX * 0.5, panelY * 0.5, newW, newH, rot)
						end
					end
				end
			else
				if (IsValid(self.itemIcon.Icon)) then self.itemIcon.Icon:SetVisible(true) end
				self.itemIcon.ExtraPaint = function() end
			end
		end
	else
		if (IsValid(self.itemIcon)) then
			self.itemIcon:Remove()
		end
	end
end

function PANEL:Paint(w, h)
	if (dragndrop.IsDragging() and dragndrop.m_Receiver == self) then
		local panel = dragndrop.m_Dragging and dragndrop.m_Dragging[1]
		local item = panel and panel.itemTable

		if (item and self.itemFilter(item)) then
			surface.SetDrawColor(100, 100, 100, 10)
			surface.DrawRect(0, 0, w, h)
		end
	end
end

vgui.Register("ixEquipmentSlot", PANEL, "DPanel")

local MODEL_ANGLE = Angle(0, 90, 0)
hook.Add("CreateMenuButtons", "ixInventory", function(tabs)
	if (hook.Run("CanPlayerViewInventory") == false) then
		return
	end

	tabs["inv"] = {
		bDefault = true,
		Create = function(info, container)
			local canvas = container:Add("DTileLayout")
			local canvasLayout = canvas.PerformLayout
			canvas.PerformLayout = nil -- we'll layout after we add the panels instead of each time one is added
			canvas:SetBorder(0)
			canvas:SetSpaceX(2)
			canvas:SetSpaceY(2)
			canvas:Dock(FILL)
			canvas:DockMargin(SW(53), SH(86), 0, 0)

			ix.gui.menuInventoryContainer = canvas

			local mainpanel = canvas:Add("DPanel")
			mainpanel:SetSize(SW(1167), SH(768))
			mainpanel:SetPos(0, 0) -- adjust as needed to align with your layout
			mainpanel:SetZPos(-1000) -- ensure it renders behind inventory contents
			mainpanel:SetAlpha(255)   -- fully opaque

			-- small cached values to avoid redundant SetText/SetImage calls
			local lastMoney, lastWeightStr, lastAvatar

			-- attach to the inventory root panel so it only runs while visible
			function mainpanel:Think()
				-- bail if the inventory tab isn’t active
				if not IsValid(moneyLabel) or not IsValid(weightLabel) or not IsValid(charbackgroundicon) then
					return
				end

				local char = LocalPlayer() and LocalPlayer():GetCharacter()
				if not char then return end

				-- money
				local money = char:GetMoney() or 0
				if money ~= lastMoney then
					lastMoney = money
					moneyLabel:SetText(ix.currency.Get(money))
				end

				-- weight
				local wStr = computeWeightString()
				if wStr ~= lastWeightStr then
					lastWeightStr = wStr
					weightLabel:SetText(wStr)
				end

				-- avatar
				local avatar = ResolveAvatarPath()
				if avatar ~= lastAvatar then
					lastAvatar = avatar
					charbackgroundicon:SetImage(avatar)
				end
			end

			-- Scroll Panel for inventory
			local scroll = mainpanel:Add("DScrollPanel")
			scroll:SetPos(SW(841), SH(109))
			scroll:SetSize(SW(355), SH(609))
			scroll:GetVBar():SetWide(0)

			local panel = scroll:Add("ixInventory")
			panel:SetDraggable(false)
			panel:SetSizable(false)
			panel:SetTitle(nil)
			panel.bNoBackgroundBlur = true
			panel.childPanels = {}

			-- Playermodel Panel
			local playermodelFrame = mainpanel:Add("DImage")
			playermodelFrame:SetSize(SW(483), SH(768))
			playermodelFrame:SetMaterial(Material("cotz/panels/loot_interface.png", "smooth"))
			playermodelFrame:Dock(LEFT)
			playermodelFrame:SetZPos(-1)

			local playermodelPanel = playermodelFrame:Add("DPanel")
			playermodelPanel:SetSize(SW(483) * 0.95, SH(768) * 0.95)
			playermodelPanel:Center()
			playermodelPanel:SetAlpha(0)

			-- Playermodel
			local playermodel = playermodelPanel:Add("ixPlayerModelPanel")	-- Check cl_modelpanel for camera pos etc.
			playermodel.Entity = LocalPlayer()
			playermodel.OnRemove = nil
			playermodel:Dock(FILL)

			--Equipment Panel and image
			local equipmentpanel = mainpanel:Add("DImage")
			equipmentpanel:SetSize(SW(343), SH(768))
			equipmentpanel:SetMaterial(Material("stalkerCoP/ui/inventory/equipment.png", "smooth"))
			equipmentpanel:Dock(FILL)
			equipmentpanel:SetZPos(-1)
			equipmentpanel:SetMouseInputEnabled(true)

			-- Inventory Panel and image
			local inventorypanel = mainpanel:Add("DImage")
			inventorypanel:SetSize(SW(341), SH(768))
			inventorypanel:SetMaterial(Material("stalkerCoP/ui/inventory/inventory.png", "smooth"))
			inventorypanel:Dock(RIGHT)
			inventorypanel:SetZPos(-1)

			-- INVENTORY LABELS AND INFO
			local nameLabel = inventorypanel:Add("DLabel")
			nameLabel:SetFont("stalkerregularsmallboldfont")
			nameLabel:SetTextColor(color_white)
			nameLabel:SetPos(SW(15), SH(20))
			nameLabel:SetContentAlignment(7)
			nameLabel:SetWide(SW(190))
			nameLabel:SetText(LocalPlayer():GetName())

			local repLabel = inventorypanel:Add("DLabel")
			repLabel:SetFont("stalkerregularsmallfont")
			repLabel:SetTextColor(color_white)
			repLabel:SetText("Rank: "..LocalPlayer():getCurrentRankName())
			repLabel:SetPos(SW(15), SH(45))
			repLabel:SetWide(SW(190))
			repLabel:SetContentAlignment(7)

			moneyLabel = inventorypanel:Add("DLabel")
			moneyLabel:SetFont("stalkerregularsmallboldfont")
			moneyLabel:SetPos(SW(7), SH(75))
			moneyLabel:SetWide(SW(190))
			moneyLabel:SetContentAlignment(6)
			moneyLabel:SetText(ix.currency.Get(LocalPlayer():GetCharacter():GetMoney()))

			local factionbanner = inventorypanel:Add("DPanel")
			factionbanner:SetSize(SW(190), SH(60))
			factionbanner:SetPos(SW(12), SH(10))
			factionbanner:SetZPos(-1)

--[[ Add gradient based on faction color if you want
			local grad = Material("vgui/gradient-r") -- fades (pick l/r/u/d as you like)

			function factionbanner:Paint(w, h)
				local col = Color(40, 40, 40)

				local ply = LocalPlayer()
				local char = ply and ply:GetCharacter()
				if char and char.GetFaction then
					local facVal = char:GetFaction()
					local fac

					if isnumber(facVal) then
						fac = ix.faction.Get(facVal)
					elseif istable(facVal) then
						fac = facVal
					end

					if fac and fac.color then
						col = fac.color
					else
						-- fallback to team color if available
						if IsValid(ply) and ply.Team then
							local tcol = team.GetColor(ply:Team())
							if tcol then col = tcol end
						end
					end
				end

				-- tint the gradient with the faction color; adjust alpha for intensity
				surface.SetMaterial(grad)
				surface.SetDrawColor(col.r, col.g, col.b, 40) -- alpha controls strength of the tint
				surface.DrawTexturedRect(0, 0, w, h)
			end
--]]

			local factionpatch = factionbanner:Add("DImage")
			factionpatch:SetPos(SW(134), SH(2))
			factionpatch:SetSize(SW(56), SH(56))
			factionpatch:SetAlpha(200)

			local function GetLocalFactionPatchPath()
				local ply = LocalPlayer()
				if not IsValid(ply) then
					return "placeholders/patch_nofaction.png"
				end

				local factionIndex = ply:Team()
				local fac = (ix.faction.GetByID and ix.faction.GetByID(factionIndex)) or ix.faction.indices[factionIndex]
				if fac and fac.patch and fac.patch ~= "" then
					return fac.patch
				end

				return "placeholders/patch_nofaction.png"
			end

			-- Drawing/creating the patch icon:
			local patchPath = GetLocalFactionPatchPath()
			local patchMat = Material(patchPath, "smooth")

			factionpatch:SetMaterial(patchMat)

			charbackgroundicon = inventorypanel:Add("DImage")
			charbackgroundicon:SetSize(SW(124), SH(87))
			charbackgroundicon:SetPos(SW(208), SH(11))
			charbackgroundicon:SetZPos(-1)

			if LocalPlayer():GetCharacter():GetData("avatar") then 
				charbackgroundicon:SetImage(ResolveAvatarPath())
			else
				charbackgroundicon:SetImage( "stalker/ui/avatars/nodata.png" )
			end

			weightLabel = inventorypanel:Add("DLabel")
			weightLabel:SetFont("stalkerregularsmallboldfont")
			weightLabel:SetPos(SW(137), SH(733))
			weightLabel:SetWide(SW(190))
			weightLabel:SetContentAlignment(6)
			weightLabel:SetText(computeWeightString())

			local client = LocalPlayer()
			local character = client and client:GetCharacter()
			local inv = character and character:GetInventory()
			if not character or not inv then
				inv = nil
			end
			
			local items = inv and inv:GetItems() or {}
			local blocker = Material("stalkerCoP/ui/inventory/blockplate.png", "smooth")
			local duraImage = Material("stalkerCoP/ui/inventory/durability_bar.png", "smooth") -- Durability bar image

			-- EQUIPMENT PANELS
			-- Helmet
			local HelmetPanel = equipmentpanel:Add("DPanel")
			HelmetPanel:SetSize(SW(96), SH(115))
			HelmetPanel:SetPos(SW(12), SH(11))
			HelmetPanel:SetPaintBackground(false)
			function HelmetPanel:PaintOver(w, h)
				for _, item in pairs(items) do
					if item:GetData("equip", false) then
						if (item.isArmor and item.isHelmet) or (item.isHelmet and item.isGasmask) then
							surface.SetMaterial(blocker)
							surface.SetDrawColor(255, 255, 255, 255) 
							surface.DrawTexturedRect(SW(0), SH(0), SW(110), SH(115))
						end
					end
				end
			end

			-- Helmet Icon
			local HelmetIcon = HelmetPanel:Add("ixEquipmentSlot")
			HelmetIcon:SetSize(SW(92), SH(92))
			HelmetIcon:Center()
			HelmetIcon:SetItemFilter(function(item) return item.isHelmet and (not item.isArmor and not item.isGasmask) end)

			-- Helmet Durability
			local HelmetDura = HelmetPanel:Add("DPanel")
			HelmetDura:SetSize(SW(58), SH(4))
			HelmetDura:SetPos(SW(19), SH(108))
			function HelmetDura:Paint(w, h)
				for _, item in pairs(items) do
					if item:GetData("equip", false) then
						if item.isHelmet and (not item.isArmor and not item.isGasmask) then
							local durability = item:GetData("durability")
							local maxDura = 10000
							local duraPercentage = math.Clamp(durability / maxDura, 0, 1)

							-- choose color
							if durability > 6000 then
								surface.SetDrawColor(115, 180, 130, 200) -- green
							elseif durability > 4000 then
								surface.SetDrawColor(173, 173, 105, 200) -- yellow
							elseif durability > 2000 then
								surface.SetDrawColor(170, 115, 85, 200)  -- orange
							elseif durability > 0 then
								surface.SetDrawColor(160, 45, 45, 200)   -- red
							else
								surface.SetDrawColor(0, 0, 0, 0)
							end

							surface.SetMaterial(duraImage)

							-- Draw only the left portion of the texture, keeping on-screen size constant
							-- UVs: (u0,v0) top-left; (u1,v1) bottom-right
							-- For full texture u1=1; to crop to duraPercentage, set u1=duraPercentage
							local drawW = math.floor(w * duraPercentage + 0.5)

							-- Reduce draw width (simpler, slight scaling at non-1x UI scale is usually fine)
							if drawW > 0 then
								surface.DrawTexturedRectUV(0, 0, drawW, h, 0, 0, duraPercentage, 1)
							end
						end
					end
				end
			end

			-- Gasmask/Headgear
			local HeadgearPanel = equipmentpanel:Add("DPanel")
			HeadgearPanel:SetSize(SW(110), SH(115))
			HeadgearPanel:SetPos(SW(117), SH(11))
			HeadgearPanel:SetPaintBackground(false)
			function HeadgearPanel:PaintOver(w, h)
				for _, item in pairs(items) do
					if item:GetData("equip", false) then
						if item.isArmor and item.isGasmask then
							surface.SetMaterial(blocker)
							surface.SetDrawColor(255, 255, 255, 255) 
							surface.DrawTexturedRect(SW(0), SH(0), SW(110), SH(115))
						end
					end
				end
			end

			-- Gasmask/Headgear Icon
			local HeadgearIcon = HeadgearPanel:Add("ixEquipmentSlot")
			HeadgearIcon:SetSize(SW(100), SH(100))
			HeadgearIcon:Center()
			HeadgearIcon:SetItemFilter(function(item) return not item.isArmor and ((item.isGasmask and item.isHelmet) or item.isGasmask) end)
			
			-- Gasmask/Headgear Durability
			local HeadgearDura = HeadgearPanel:Add("DPanel")
			HeadgearDura:SetSize(SW(58), SH(4))
			HeadgearDura:SetPos(SW(26), SH(108))
			function HeadgearDura:Paint(w, h)
				for _, item in pairs(items) do
					if item:GetData("equip", false) then
						if not item.isArmor and ((item.isGasmask and item.isHelmet) or item.isGasmask) then
							local durability = item:GetData("durability")
							local maxDura = 10000
							local duraPercentage = math.Clamp(durability / maxDura, 0, 1)

							-- choose color
							if durability > 6000 then
								surface.SetDrawColor(115, 180, 130, 200) -- green
							elseif durability > 4000 then
								surface.SetDrawColor(173, 173, 105, 200) -- yellow
							elseif durability > 2000 then
								surface.SetDrawColor(170, 115, 85, 200)  -- orange
							elseif durability > 0 then
								surface.SetDrawColor(160, 45, 45, 200)   -- red
							else
								surface.SetDrawColor(0, 0, 0, 0)
							end

							surface.SetMaterial(duraImage)

							-- Draw only the left portion of the texture, keeping on-screen size constant
							-- UVs: (u0,v0) top-left; (u1,v1) bottom-right
							-- For full texture u1=1; to crop to duraPercentage, set u1=duraPercentage
							local drawW = math.floor(w * duraPercentage + 0.5)

							-- Reduce draw width (simpler, slight scaling at non-1x UI scale is usually fine)
							if drawW > 0 then
								surface.DrawTexturedRectUV(0, 0, drawW, h, 0, 0, duraPercentage, 1)
							end
						end
					end
				end
			end

			-- Backpack
			local BackpackPanel = equipmentpanel:Add("DPanel")
			BackpackPanel:SetSize(SW(92), SH(115))
			BackpackPanel:SetPos(SW(238), SH(11))
			BackpackPanel:SetPaintBackground(false)
			
			-- Backpack Icon
			local BackpackIcon = BackpackPanel:Add("ixEquipmentSlot")
			BackpackIcon:SetSize(SW(92), SH(92))
			BackpackIcon:Center()
			BackpackIcon:SetItemFilter(function(item) return item.isBackpack end)

			-- Armor
			local ArmorPanel = equipmentpanel:Add("DPanel")
			ArmorPanel:SetSize(SW(110), SH(180))
			ArmorPanel:SetPos(SW(117), SH(135))
			ArmorPanel:SetPaintBackground(false)

			-- Armor Icon
			local ArmorIcon = ArmorPanel:Add("ixEquipmentSlot")
			ArmorIcon:SetSize(SW(106), SH(170))
			ArmorIcon:SetPos(SW(2), SH(2))
			ArmorIcon:SetItemFilter(function(item) return item.isArmor end)

			-- Armor Durability
			local ArmorDura = ArmorPanel:Add("DPanel")
			ArmorDura:SetSize(SW(58), SH(4))
			ArmorDura:SetPos(SW(26), SH(174))
			ArmorDura:SetPaintBackground(false)
			function ArmorDura:Paint(w, h)
				for _, item in pairs(items) do
					if item:GetData("equip", false) then
						if item.isArmor then
							local durability = item:GetData("durability")
							local maxDura = 10000
							local duraPercentage = math.Clamp(durability / maxDura, 0, 1)

							-- choose color
							if durability > 6000 then
								surface.SetDrawColor(115, 180, 130, 200) -- green
							elseif durability > 4000 then
								surface.SetDrawColor(173, 173, 105, 200) -- yellow
							elseif durability > 2000 then
								surface.SetDrawColor(170, 115, 85, 200)  -- orange
							elseif durability > 0 then
								surface.SetDrawColor(160, 45, 45, 200)   -- red
							else
								surface.SetDrawColor(0, 0, 0, 0)
							end

							surface.SetMaterial(duraImage)

							-- Draw only the left portion of the texture, keeping on-screen size constant
							-- UVs: (u0,v0) top-left; (u1,v1) bottom-right
							-- For full texture u1=1; to crop to duraPercentage, set u1=duraPercentage
							local drawW = math.floor(w * duraPercentage + 0.5)

							-- Reduce draw width (simpler, slight scaling at non-1x UI scale is usually fine)
							if drawW > 0 then
								surface.DrawTexturedRectUV(0, 0, drawW, h, 0, 0, duraPercentage, 1)
							end
						end
					end
				end
			end

			-- Secondary Weapon (Left)
			local LWepPanel = equipmentpanel:Add("DPanel")
			LWepPanel:SetSize(SW(92), SH(179))
			LWepPanel:SetPos(SW(14), SH(137))
			LWepPanel:SetPaintBackground(false)
			
			-- Secondary Weapon Icon
			local LWepIcon = LWepPanel:Add("ixEquipmentSlot")
			LWepIcon:SetSize(SW(92), SH(167))
			LWepIcon:SetPos(SW(0), SH(2))
			LWepIcon:SetItemFilter(function(item) return item.weaponCategory == "secondary" end)
			LWepIcon:SetIconRotation(90)

			-- Secondary Weapon Durability
			local LWepDura = LWepPanel:Add("DPanel")
			LWepDura:SetSize(SW(58), SH(4))
			LWepDura:SetPos(SW(16), SH(172))
			function LWepDura:Paint(w, h)
				for _, item in pairs(items) do
					if item.weaponCategory == "secondary" and item:GetData("equip", false) then
						local durability = item:GetData("durability")
						if durability == nil then return end

						local maxDura = 10000
						local duraPercentage = math.Clamp(durability / maxDura, 0, 1)

						if durability > 6000 then
							surface.SetDrawColor(115, 180, 130, 200) -- green
						elseif durability > 4000 then
							surface.SetDrawColor(173, 173, 105, 200) -- yellow
						elseif durability > 2000 then
							surface.SetDrawColor(170, 115, 85, 200)  -- orange
						elseif durability > 0 then
							surface.SetDrawColor(160, 45, 45, 200)   -- red
						else
							surface.SetDrawColor(0, 0, 0, 0)
						end

						surface.SetMaterial(duraImage)
						local drawW = math.floor(w * duraPercentage + 0.5)
						if drawW > 0 then
							surface.DrawTexturedRectUV(0, 0, drawW, h, 0, 0, duraPercentage, 1)
						end
						return
					end
				end
			end

			-- Sidearm (Center)
			local SidearmPanel = equipmentpanel:Add("DPanel")
			SidearmPanel:SetSize(SW(110), SH(58))
			SidearmPanel:SetPos(SW(117), SH(327))
			SidearmPanel:SetPaintBackground(false)

			-- Sidearm Icon
			local SidearmIcon = SidearmPanel:Add("ixEquipmentSlot")
			SidearmIcon:SetSize(SW(100), SH(50))
			SidearmIcon:SetPos(SW(5), SH(0))
			SidearmIcon:SetItemFilter(function(item) return item.weaponCategory == "sidearm" end)

			-- Sidearm Durability
			local SidearmDura = SidearmPanel:Add("DPanel")
			SidearmDura:SetSize(SW(58), SH(4))
			SidearmDura:SetPos(SW(26), SH(51))
			function SidearmDura:Paint(w, h)
				for _, item in pairs(items) do
					if item.weaponCategory == "sidearm" and item:GetData("equip", false) then
						local durability = item:GetData("durability")
						if durability == nil then return end

						local maxDura = 10000
						local duraPercentage = math.Clamp(durability / maxDura, 0, 1)

						if durability > 6000 then
							surface.SetDrawColor(115, 180, 130, 200) -- green
						elseif durability > 4000 then
							surface.SetDrawColor(173, 173, 105, 200) -- yellow
						elseif durability > 2000 then
							surface.SetDrawColor(170, 115, 85, 200)  -- orange
						elseif durability > 0 then
							surface.SetDrawColor(160, 45, 45, 200)   -- red
						else
							surface.SetDrawColor(0, 0, 0, 0)
						end

						surface.SetMaterial(duraImage)
						local drawW = math.floor(w * duraPercentage + 0.5)
						if drawW > 0 then
							surface.DrawTexturedRectUV(0, 0, drawW, h, 0, 0, duraPercentage, 1)
						end
						return
					end
				end
			end

			-- Primary Weapon (Right)
			local RWepPanel = equipmentpanel:Add("DPanel")
			RWepPanel:SetSize(SW(92), SH(179))
			RWepPanel:SetPos(SW(238), SH(137))
			RWepPanel:SetPaintBackground(false)

			-- Primary Weapon Icon
			local RWepIcon = RWepPanel:Add("ixEquipmentSlot")
			RWepIcon:SetSize(SW(92), SH(167))
			RWepIcon:SetPos(SW(0), SH(2))
			RWepIcon:SetItemFilter(function(item) return item.weaponCategory == "primary" end)
			RWepIcon:SetIconRotation(-90)

			-- Primary Weapon Durability
			local RWepDura = RWepPanel:Add("DPanel")
			RWepDura:SetSize(SW(58), SH(4))
			RWepDura:SetPos(SW(17), SH(172))
			function RWepDura:Paint(w, h)
				for _, item in pairs(items) do
					if item.weaponCategory == "primary" and item:GetData("equip", false) then
						local durability = item:GetData("durability")
						if durability == nil then return end

						local maxDura = 10000
						local duraPercentage = math.Clamp(durability / maxDura, 0, 1)

						if durability > 6000 then
							surface.SetDrawColor(115, 180, 130, 200) -- green
						elseif durability > 4000 then
							surface.SetDrawColor(173, 173, 105, 200) -- yellow
						elseif durability > 2000 then
							surface.SetDrawColor(170, 115, 85, 200)  -- orange
						elseif durability > 0 then
							surface.SetDrawColor(160, 45, 45, 200)   -- red
						else
							surface.SetDrawColor(0, 0, 0, 0)
						end

						surface.SetMaterial(duraImage)
						local drawW = math.floor(w * duraPercentage + 0.5)
						if drawW > 0 then
							surface.DrawTexturedRectUV(0, 0, drawW, h, 0, 0, duraPercentage, 1)
						end
						return
					end
				end
			end

			-- Night Vision (Left)
			local NVPanel = equipmentpanel:Add("DPanel")
			NVPanel:SetSize(SW(92), SH(58))
			NVPanel:SetPos(SW(14), SH(327))
			NVPanel:SetPaintBackground(false)

			local NVIcon = NVPanel:Add("ixEquipmentSlot")
			NVIcon:SetSize(SW(50), SH(50))
			NVIcon:Dock(TOP)
			NVIcon:SetItemFilter(function(item) return item.isNVG end)

			-- Artifact Detector (Right)
			local ArtDetPanel = equipmentpanel:Add("DPanel")
			ArtDetPanel:SetSize(SW(92), SH(58))
			ArtDetPanel:SetPos(SW(238), SH(327))
			ArtDetPanel:SetPaintBackground(false)

			local ArtDetIcon = ArtDetPanel:Add("ixEquipmentSlot")
			ArtDetIcon:SetSize(SW(50), SH(50))
			ArtDetIcon:SetPos(SW(21), SH(0))
			ArtDetIcon:SetItemFilter(function(item) return item.isArtifactdetector end)

			local ArtDetDura = ArtDetPanel:Add("DPanel")
			ArtDetDura:SetSize(SW(58), SH(4))
			ArtDetDura:SetPos(SW(17), SH(51))
			function ArtDetDura:Paint(w, h)
				for _, item in pairs(items) do
					if item.isArtifactdetector and item:GetData("equip", false) then
						local durability = item:GetData("durability", 10000)
						if durability == nil then return end

						local maxDura = 10000
						local duraPercentage = math.Clamp(durability / maxDura, 0, 1)

						if durability > 6000 then
							surface.SetDrawColor(115, 180, 130, 200) -- green
						elseif durability > 4000 then
							surface.SetDrawColor(173, 173, 105, 200) -- yellow
						elseif durability > 2000 then
							surface.SetDrawColor(170, 115, 85, 200)  -- orange
						elseif durability > 0 then
							surface.SetDrawColor(160, 45, 45, 200)   -- red
						else
							surface.SetDrawColor(0, 0, 0, 0)
						end

						surface.SetMaterial(duraImage)
						local drawW = math.floor(w * duraPercentage + 0.5)
						if drawW > 0 then
							surface.DrawTexturedRectUV(0, 0, drawW, h, 0, 0, duraPercentage, 1)
						end
						return
					end
				end
			end

			-- Tool Panels
			for i = 1, 4 do
				local ToolPanel = equipmentpanel:Add("DPanel")
				ToolPanel:SetSize(SW(78), SH(67))
				ToolPanel:SetPos(SW(11 + (i - 1) * 81), SH(395))
				ToolPanel:SetPaintBackground(false)

				local ToolIcon = ToolPanel:Add("ixEquipmentSlot")
				ToolIcon:SetSize(SW(65), SH(65))
				ToolIcon:Center()
				ToolIcon:SetSlotIndex(i)
				ToolIcon:SetItemFilter(function(item) return item.isPDA or item.isAnomalydetector or item.isGeiger or item.isFlashlight end)
			end

			-- Artifacts panel
			local ArtifactsPanel = equipmentpanel:Add("DPanel")
			ArtifactsPanel:SetSize(SW(320), SH(60))
			ArtifactsPanel:SetPos(SW(12), SH(471))
			function ArtifactsPanel:Paint(w, h)
				local client = LocalPlayer()
				local char = client and client:GetCharacter()
				if not char then return end

				local inv = char:GetInventory()
				if not inv then return end

				local items = inv:GetItems()

				-- Layout
				local totalSlots = 5
				local slotSize = SW(60)  -- size of a slot (match your texture size so it snaps nicely)
				local artSize  = SW(50)  -- artifact icon size within a slot
				local spacing  = SW(5)
				local startX   = SW(0)   -- leftmost slot X
				local startY   = SH(0)

				-- Find equipped armor and determine how many artifact containers it grants
				local armorContainers = 0
				local equippedArmor
				for _, it in pairs(items) do
					if it:GetData("equip", false) and it.isArmor then
						equippedArmor = it
						-- artifactcontainers is expected like { "2" } or { 2 }; be defensive
						local c = it.artifactcontainers
						if c then
							local n = tonumber(c[1] or c) or 0
							armorContainers = math.Clamp(n, 0, totalSlots)
						end
						break
					end
				end

				-- Collect equipped artifacts
				local equippedArtifacts = {}
				for _, it in pairs(items) do
					if it:GetData("equip", false) and (it.isArtefact or it.isArtifact) then
						table.insert(equippedArtifacts, it)
					end
				end

				-- Draw slots 1..5
				local blockercont = Material("stalkerCoP/ui/inventory/blockplate_container.png", "smooth")

				local drawnArtifacts = 0
				for i = 1, totalSlots do
					local slotX = startX + (i - 1) * (slotSize + spacing)
					local slotY = 0

					-- If this slot index exceeds the count of armor-provided containers, draw blocker
					if i > armorContainers then
						surface.SetMaterial(blockercont)
						surface.SetDrawColor(255, 255, 255, 255)
						surface.DrawTexturedRect(slotX, slotY, slotSize, slotSize)
					else
						-- There is a container here; draw an equipped artifact if we have one
						local art = equippedArtifacts[drawnArtifacts + 1]
						if art and art.img then
							surface.SetMaterial(art.img)
							surface.SetDrawColor(255, 255, 255, 255)
							-- center artifact inside the slot
							local pad = math.floor((slotSize - artSize) * 0.5 + 0.5)
							surface.DrawTexturedRect(slotX + pad, startY + pad, artSize, artSize)
							drawnArtifacts = drawnArtifacts + 1
						end
						-- If no artifact for this container, leave it empty (no blocker shown)
					end
				end
			end

			-- Health Panel
			local healthImage = equipmentpanel:Add("DPanel")
			healthImage:SetSize(SW(214), SH(16))
			healthImage:SetPos(SW(14), SH(570))

			local hpImage = Material("stalkerCoP/ui/inventory/health_bar.png", "smooth")
			function healthImage:Paint(w, h)
				local health = LocalPlayer():Health() -- Get player's current health
				local maxHealth = LocalPlayer():GetMaxHealth() -- Get player's max health
				local healthPercentage = math.Clamp(health / maxHealth, 0, 1)

				local drawW = math.floor(w * healthPercentage + 0.5)

				if drawW > 0 then
					surface.SetMaterial(hpImage)
					surface.SetDrawColor(115, 40, 40, 255) -- Set color to red
					surface.DrawTexturedRectUV(0, 0, drawW, h, 0, 0, healthPercentage, 1)
				end
			end

			local heartbeatSpeed = 2.5 -- Speed of the heartbeat effect
			local maxAlpha = 255 -- Maximum alpha value
			local minAlpha = 50 -- Minimum alpha value (to avoid complete transparency)
			local lp = LocalPlayer()
			local char = lp:GetCharacter()

			-- Bleed Icon Panel
			local BleedIcon = equipmentpanel:Add("DImage")
			BleedIcon:SetSize(45, 45)
			BleedIcon:SetPos(SW(238), SH(545))

			local bleedImage = Material("stalkerCoP/ui/inventory/bleed.png", "smooth")
			local bleedImage2 = Material("stalkerCoP/ui/inventory/bleed2.png", "smooth")
			local bleedImage3 = Material("stalkerCoP/ui/inventory/bleed3.png", "smooth")
			local bleedImage4 = Material("stalkerCoP/ui/inventory/bleed4.png", "smooth")

			function BleedIcon:Paint(w, h)
				local lp = LocalPlayer()
				local char = lp and lp:GetCharacter()
				if not char then return end

				local bleeding = char:GetData("Bleeding", 0) > 0
				local time = CurTime() * heartbeatSpeed
				local alpha = math.abs(math.sin(time)) * (maxAlpha - minAlpha) + minAlpha
				local health = lp:Health()

				if bleeding or timer.Exists(lp:Name() .. "res_bleed") then
					if health == 100 then
						surface.SetMaterial(bleedImage)
						surface.SetDrawColor(Color(0, 0, 0, 0))
					elseif health < 100 and health >= 89 then
						surface.SetMaterial(bleedImage)
						surface.SetDrawColor(Color(255, 255, 255, alpha))
					elseif health < 89 and health >= 60 then
						surface.SetMaterial(bleedImage2)
						surface.SetDrawColor(Color(255, 255, 255, alpha))
					elseif health < 60 and health >= 25 then
						surface.SetMaterial(bleedImage3)
						surface.SetDrawColor(Color(255, 255, 255, alpha))
					else -- health < 25
						surface.SetMaterial(bleedImage4)
						surface.SetDrawColor(Color(255, 255, 255, alpha))
					end

					surface.DrawTexturedRect(0, 0, SW(w), SH(h))
				end
			end

			-- Radiation Icon Panel
			local RadIcon = equipmentpanel:Add("DImage")
			RadIcon:SetSize(45, 45)
			RadIcon:SetPos(SW(288), SH(545))

			local radImage = Material("stalkerCoP/ui/inventory/rad.png", "smooth")
			local radImage2 = Material("stalkerCoP/ui/inventory/rad2.png", "smooth")
			local radImage3 = Material("stalkerCoP/ui/inventory/rad3.png", "smooth")
			local radImage4 = Material("stalkerCoP/ui/inventory/rad4.png", "smooth")

			function RadIcon:Paint(w, h)
				local time = CurTime() * heartbeatSpeed
				local alpha = math.abs(math.sin(time)) * (maxAlpha - minAlpha) + minAlpha
				local radiation = lp:getRadiation()
				
				surface.SetMaterial(radImage)
				if radiation == 0 then
					surface.SetMaterial(radImage)
					surface.SetDrawColor(Color(0, 0, 0, 0))
				elseif radiation > 0 and radiation <= 25 then
					surface.SetMaterial(radImage)
					surface.SetDrawColor(Color(255, 255, 255, alpha))
				elseif radiation > 25 and radiation <= 60 then
					surface.SetMaterial(radImage2)
					surface.SetDrawColor(Color(255, 255, 255, alpha))
				elseif radiation > 60 and radiation <= 89 then
					surface.SetMaterial(radImage3)
					surface.SetDrawColor(Color(255, 255, 255, alpha))
				elseif radiation > 89 and radiation <= 100 then
					surface.SetMaterial(radImage4)
					surface.SetDrawColor(Color(255, 255, 255, alpha))
				end

				surface.DrawTexturedRect(0, 0, SW(w), SH(h)) 
			end

			-- RESISTANCES PANEL
			local ResPanel = equipmentpanel:Add("DPanel")
			ResPanel:SetSize(SW(282), SH(100))
			ResPanel:SetPos(SW(40), SH(612))
			ResPanel:SetPaintBackgroundEnabled(false)
			ResPanel:SetPaintBorderEnabled(false)
			function ResPanel:Paint() end

			local resbarImage = Material("stalkerCoP/ui/inventory/resistance_bar.png", "smooth")

			-- Function to create a resistance bar
			local function CreateResistanceBar(parent, material, resistanceType, posX, posY)
				local barW, barH = SW(122), SH(16)

				local resbar = parent:Add("DPanel")
				resbar:SetSize(barW, barH)
				resbar:SetPos(posX, posY)
				resbar:SetPaintBackgroundEnabled(false)
				resbar:SetPaintBorderEnabled(false)

				-- Function to calculate total resistance
				local function calculateResistance()
					local character = LocalPlayer():GetChar()
					local inventory = character:GetInventory()
					local items = inventory:GetItems()
					local totalRes = 0

					-- Iterate through equipped items
					for _, item in pairs(items) do
						if item:GetData("equip", false) then
							if item.res and item.res[resistanceType] then
								totalRes = totalRes + item.res[resistanceType]
							end
						end
					end

					return math.Clamp(totalRes, 0, 1)
				end

				-- Modify the bar's paint function
				function resbar:Paint(w, h)
					local resistance = calculateResistance()
					if resistanceType == "Radiation" then
						surface.SetDrawColor(0, 150, 0, 255) -- green for radiation
					elseif resistanceType == "Chemical" then
						surface.SetDrawColor(150, 150, 0, 255) -- yellow for chemical
					elseif resistanceType == "Shock" then
						surface.SetDrawColor(0, 100, 168, 255) -- light blue for shock
					elseif resistanceType == "Burn" then
						surface.SetDrawColor(150, 0, 0, 255) -- red for burn
					elseif resistanceType == "Psi" then
						surface.SetDrawColor(85, 0, 140, 255) -- purple for psi
					elseif resistanceType == "Slash" then
						surface.SetDrawColor(150, 150, 150, 255) -- gray for slash
					elseif resistanceType == "Bullet" then
						surface.SetDrawColor(150, 150, 150, 255) -- gray for bullet
					elseif resistanceType == "Impact" then
						surface.SetDrawColor(150, 150, 150, 255) -- gray for impact
					end

					surface.SetMaterial(resbarImage)

					local drawW = math.floor(w * resistance + 0.5)
					if drawW > 0 then
						surface.DrawTexturedRectUV(0, 0, drawW, h, 0, 0, resistance, 1)
					end
				end

				return resbar
			end

			-- Create resistances bars using the unified function
			local radiationBar = CreateResistanceBar(ResPanel, resbarImage, "Radiation", SW(0), 	SH(0))
			local chemicalBar  = CreateResistanceBar(ResPanel, resbarImage, "Chemical",  SW(0), 	SH(28))
			local shockBar     = CreateResistanceBar(ResPanel, resbarImage, "Shock",     SW(0), 	SH(56))
			local burnBar      = CreateResistanceBar(ResPanel, resbarImage, "Burn",      SW(0), 	SH(84))
			local psiBar       = CreateResistanceBar(ResPanel, resbarImage, "Psi",       SW(159), 	SH(0))
			local slashBar     = CreateResistanceBar(ResPanel, resbarImage, "Slash",     SW(159), 	SH(28))
			local bulletBar      = CreateResistanceBar(ResPanel, resbarImage, "Bullet",      SW(159), 	SH(56))
			local impactBar      = CreateResistanceBar(ResPanel, resbarImage, "Impact",      SW(159), 	SH(84))

			local inventory = inv or (LocalPlayer():GetCharacter() and LocalPlayer():GetCharacter():GetInventory())

			if (inventory) then
				panel:SetInventory(inventory)
			end

			ix.gui.inv1 = panel

			if (ix.option.Get("openBags", true)) then
				for _, v in pairs(inventory:GetItems()) do
					if (!v.isBag) then
						continue
					end

					v.functions.View.OnClick(v)
				end
			end

			canvas.PerformLayout = canvasLayout
			canvas:Layout()

		end
	}
end)

hook.Add("CreateMenuButtons", "ixCharInfo", function(tabs)	--Removes You tab
	tabs["you"] = nil
end)

-- Update hooks for money, weight and pda avatar
hook.Add("CharacterVarChanged", "ixInv_UpdateMoney", function(character, key, old, new)
    if character ~= LocalPlayer():GetCharacter() then return end
    if key == "money" then
        RefreshMoney()
    end
end)

hook.Add("CharacterDataChanged", "ixInv_UpdateWeight", function(character, key, old, new)
    if character ~= LocalPlayer():GetCharacter() then return end
    if key == "Weight" or key == "MaxWeight" or key == "WeightBuffCur" then
        RefreshWeight()
    end
end)

-- also respond to unit preference changes
hook.Add("HelixOptionChanged", "ixInv_UnitPrefChanged", function(client, key, old, new)
    if key == "imperial" then
        RefreshWeight()
    end
end)

-- Refresh when equipped items change (covers PDA equip/unequip)
hook.Add("ItemEquipped", "ixInv_PDAAvatar_OnEquip", function(client, item)
    if client ~= LocalPlayer() then return end
    if item and item.isPDA then
        RefreshCharAvatar()
    end
end)

hook.Add("ItemUnequipped", "ixInv_PDAAvatar_OnUnequip", function(client, item)
    if client ~= LocalPlayer() then return end
    if item and item.isPDA then
        RefreshCharAvatar()
    end
end)