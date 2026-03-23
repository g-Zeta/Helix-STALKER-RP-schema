local PLUGIN = PLUGIN

PLUGIN.name = "Inventory Snapshot"
PLUGIN.author = "Ghost"
PLUGIN.desc = "Read-only snapshot of a target player's inventory and money."

local ICON_SIZE = 64
local SLOT_PAD = 4

if SERVER then
	util.AddNetworkString("ixCheckInvSnapshot")
end

local function SerializeInventory(inventory)
	local items = {}
	local bags = {}

	for _, item in pairs(inventory:GetItems(true)) do
		items[#items + 1] = {
			name = item:GetName(),
			model = item:GetModel(),
			uniqueID = item.uniqueID,
			x = (item.gridX or 1) - 1,
			y = (item.gridY or 1) - 1,
			w = item.width or 1,
			h = item.height or 1,
		}

		local isBag = ((item.base == "base_bags") or item.isBag) and item.data and item.data.id
		if isBag then
			local bagInv = ix.item.inventories[isBag]
			if bagInv then
				local bw, bh = bagInv:GetSize()
				local bagItems = {}

				for _, bagItem in pairs(bagInv:GetItems(true)) do
					bagItems[#bagItems + 1] = {
						name = bagItem:GetName(),
						model = bagItem:GetModel(),
						uniqueID = bagItem.uniqueID,
						x = (bagItem.gridX or 1) - 1,
						y = (bagItem.gridY or 1) - 1,
						w = bagItem.width or 1,
						h = bagItem.height or 1,
					}
				end

				bags[#bags + 1] = {
					name = item:GetName(),
					w = bw,
					h = bh,
					items = bagItems,
				}
			end
		end
	end

	local w, h = inventory:GetSize()
	return w, h, items, bags
end

ix.command.Add("charcheckinv", {
	adminOnly = true,
	arguments = {
		ix.type.character,
	},
	OnRun = function(self, client, character)
		if !character then return end

		local owner = character:GetPlayer()
		if IsValid(owner) and owner == client then
			client:Notify("Can't check your own inventory.")
			return
		end

		local inventory = character:GetInventory()
		if !inventory then
			client:Notify("Target has no inventory.")
			return
		end

		local w, h, items, bags = SerializeInventory(inventory)

		net.Start("ixCheckInvSnapshot")
			net.WriteString(character:GetName())
			net.WriteUInt(w, 8)
			net.WriteUInt(h, 8)
			net.WriteUInt(#items, 16)

			for _, v in ipairs(items) do
				net.WriteString(v.name)
				net.WriteString(v.model)
				net.WriteString(v.uniqueID)
				net.WriteUInt(v.x, 8)
				net.WriteUInt(v.y, 8)
				net.WriteUInt(v.w, 8)
				net.WriteUInt(v.h, 8)
			end

			net.WriteUInt(#bags, 8)
			for _, bag in ipairs(bags) do
				net.WriteString(bag.name)
				net.WriteUInt(bag.w, 8)
				net.WriteUInt(bag.h, 8)
				net.WriteUInt(#bag.items, 16)

				for _, v in ipairs(bag.items) do
					net.WriteString(v.name)
					net.WriteString(v.model)
					net.WriteString(v.uniqueID)
					net.WriteUInt(v.x, 8)
					net.WriteUInt(v.y, 8)
					net.WriteUInt(v.w, 8)
					net.WriteUInt(v.h, 8)
				end
			end
		net.Send(client)
	end
})

ix.command.Add("charcheckmoney", {
	adminOnly = true,
	arguments = {
		ix.type.character,
	},
	OnRun = function(self, client, character)
		if !character then return end

		local owner = character:GetPlayer()
		if IsValid(owner) and owner == client then
			client:Notify("Can't check your own money.")
			return
		end

		client:Notify(character:GetName() .. " has " .. ix.currency.Get(character:GetMoney()))
	end
})

if CLIENT then
	local function ReadItems(count)
		local items = {}
		for i = 1, count do
			items[i] = {
				name = net.ReadString(),
				model = net.ReadString(),
				uniqueID = net.ReadString(),
				x = net.ReadUInt(8),
				y = net.ReadUInt(8),
				w = net.ReadUInt(8),
				h = net.ReadUInt(8),
			}
		end
		return items
	end

	local function BuildGrid(parent, gridW, gridH, items, slotSize)
		local grid = vgui.Create("DPanel", parent)
		grid:SetSize(gridW * slotSize, gridH * slotSize)
		grid.Paint = function(self, w, h)
			surface.SetDrawColor(40, 40, 40, 200)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(60, 60, 60, 255)
			for gx = 0, gridW - 1 do
				for gy = 0, gridH - 1 do
					surface.DrawOutlinedRect(gx * slotSize, gy * slotSize, slotSize, slotSize)
				end
			end
		end

		for _, item in ipairs(items) do
			local slot = vgui.Create("DPanel", grid)
			slot:SetPos(item.x * slotSize, item.y * slotSize)
			slot:SetSize(item.w * slotSize, item.h * slotSize)
			slot.Paint = function(self, w, h)
				surface.SetDrawColor(80, 80, 80, 150)
				surface.DrawRect(0, 0, w, h)
				surface.SetDrawColor(100, 100, 100, 255)
				surface.DrawOutlinedRect(0, 0, w, h)
			end

			local icon = vgui.Create("SpawnIcon", slot)
			icon:SetPos(2, 2)
			icon:SetSize(item.w * slotSize - 4, item.h * slotSize - 16)
			icon:SetModel(item.model)
			icon:SetMouseInputEnabled(false)

			local lbl = vgui.Create("DLabel", slot)
			lbl:SetText(item.name)
			lbl:SetFont("ixSmallFont")
			lbl:SizeToContents()
			lbl:SetPos(2, item.h * slotSize - 14)
			lbl:SetTextColor(Color(255, 255, 255, 200))

			slot:SetTooltip(item.name .. " [" .. item.uniqueID .. "]")
		end

		return grid
	end

	net.Receive("ixCheckInvSnapshot", function()
		local charName = net.ReadString()
		local invW = net.ReadUInt(8)
		local invH = net.ReadUInt(8)
		local count = net.ReadUInt(16)
		local items = ReadItems(count)

		local bagCount = net.ReadUInt(8)
		local bags = {}
		for i = 1, bagCount do
			bags[i] = {
				name = net.ReadString(),
				w = net.ReadUInt(8),
				h = net.ReadUInt(8),
			}
			local bItemCount = net.ReadUInt(16)
			bags[i].items = ReadItems(bItemCount)
		end

		local slotSize = ICON_SIZE + SLOT_PAD

		local frame = vgui.Create("DFrame")
		frame:SetTitle(charName .. "'s Inventory (Read-Only)")
		frame:MakePopup()
		frame:SetDraggable(true)

		local yOffset = 30
		local maxW = invW * slotSize

		local mainGrid = BuildGrid(frame, invW, invH, items, slotSize)
		mainGrid:SetPos(10, yOffset)
		yOffset = yOffset + invH * slotSize + 10

		for _, bag in ipairs(bags) do
			local bagLabel = vgui.Create("DLabel", frame)
			bagLabel:SetPos(10, yOffset)
			bagLabel:SetText(bag.name)
			bagLabel:SetFont("ixSmallFont")
			bagLabel:SetTextColor(Color(200, 200, 150, 255))
			bagLabel:SizeToContents()
			yOffset = yOffset + 16

			local bagGrid = BuildGrid(frame, bag.w, bag.h, bag.items, slotSize)
			bagGrid:SetPos(10, yOffset)
			yOffset = yOffset + bag.h * slotSize + 10

			if bag.w * slotSize > maxW then
				maxW = bag.w * slotSize
			end
		end

		frame:SetSize(maxW + 20, yOffset)
		frame:Center()
	end)
end
