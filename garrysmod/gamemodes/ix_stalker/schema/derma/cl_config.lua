
-- config manager
local PANEL = {}

function PANEL:Init()
	self:SetSearchEnabled(true)
	self:Dock(FILL)
	self:DockMargin(149 * (ScrW() / 1920), 80 * (ScrH() / 1080), 216 * (ScrW() / 1920), 69 * (ScrH() / 1080))	--(left, up, right, down)

	self:Populate()
end

function PANEL:Populate()
	-- gather categories
	local categories = {}
	local categoryIndices = {}

	for k, v in pairs(ix.config.stored) do
		local index = v.data and v.data.category or "misc"

		categories[index] = categories[index] or {}
		categories[index][k] = v
	end

	-- sort by category phrase
	for k, _ in pairs(categories) do
		categoryIndices[#categoryIndices + 1] = k
	end

	table.sort(categoryIndices, function(a, b)
		return L(a) < L(b)
	end)

	-- add panels
	for _, category in ipairs(categoryIndices) do
		local categoryPhrase = L(category)
		self:AddCategory(categoryPhrase)

		-- we can use sortedpairs since configs don't have phrases to account for
		for k, v in SortedPairs(categories[category]) do
			if (isfunction(v.hidden) and v.hidden()) then
				continue
			end

			local data = v.data.data
			local type = v.type
			local value = ix.util.SanitizeType(type, ix.config.Get(k))

			local row = self:AddRow(type, categoryPhrase)
			row:SetText(ix.util.ExpandCamelCase(k))

			-- type-specific properties
			if (type == ix.type.number) then
				row:SetMin(data and data.min or 0)
				row:SetMax(data and data.max or 1)
				row:SetDecimals(data and data.decimals or 0)
			end

			row:SetValue(value, true)
			row:SetShowReset(value != v.default, k, v.default)

			row.OnValueChanged = function(panel)
				local newValue = ix.util.SanitizeType(type, panel:GetValue())

				panel:SetShowReset(newValue != v.default, k, v.default)

				net.Start("ixConfigSet")
					net.WriteString(k)
					net.WriteType(newValue)
				net.SendToServer()
			end

			row.OnResetClicked = function(panel)
				panel:SetValue(v.default, true)
				panel:SetShowReset(false)

				net.Start("ixConfigSet")
					net.WriteString(k)
					net.WriteType(v.default)
				net.SendToServer()
			end

			row:GetLabel():SetHelixTooltip(function(tooltip)
				local title = tooltip:AddRow("name")
				title:SetImportant()
				title:SetText(k)
				title:SizeToContents()
				title:SetMaxWidth(math.max(title:GetMaxWidth(), ScrW() * 0.5))

				local description = tooltip:AddRow("description")
				description:SetText(v.description)
				description:SizeToContents()
			end)
		end
	end

	self:SizeToContents()
end

vgui.Register("ixConfigManager", PANEL, "ixSettings")