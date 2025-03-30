
-- Any files in the libs/ folder will be automatically included on the server and/or client, depending on the prefix of the
-- file. There are a few conventions you'll want to follow when creating a library.

-- Your library should reside in the "ix" table.
ix.util.text = ix.util.text or {}

-- Your library functions should reside in the table as regular function calls, not method calls (i.e use "." instead of ":") to
-- maintain consistency with the rest of Helix. What you shouldn't do: function ix.test:Add(one, two)
function ix.util.PropertyDesc(tooltip, text, color) -- property, no image
	if !tooltip:GetRow("propertyheader") then
		local descheader = tooltip:AddRow("propertyheader")
		descheader:SetText("\nPROPERTIES:")
		descheader:SizeToContents()
		descheader:SetContentAlignment(4)
	end

	local dot 
	dot = tooltip:AddRowAfter("propertyheader", "propertyitem")
	dot:SetText("")

	local image = dot:Add("DLabel")
	image:SetText("•")
	image:SetContentAlignment(8)
	image:SetTextColor( color or Color( 255, 255, 255) )
	image:SetPos(8, 0)
	image:SetSize(dot:GetTall(), dot:GetTall())

	local desctext = dot:Add("DLabel")
	desctext:MoveRightOf(image)
	desctext:SetText("  "..text)
	desctext:SetTextColor(color or Color(255, 255, 255))
	desctext:SetFont("ixSmallFont")
	desctext:SizeToContents()

	dot:SetWide(image:GetWide() + desctext:GetWide() + 15)

	tooltip:SizeToContents()
end

function ix.util.PropertyDesc2(tooltip, text, color, imagestring) -- property, with image
	if !tooltip:GetRow("propertyheader") then
		local descheader = tooltip:AddRow("propertyheader")
		descheader:SetText("\nPROPERTIES:")
		descheader:SizeToContents()
		descheader:SetContentAlignment(4)
	end

	local dot
	if !tooltip:GetRow("propertyitem") then
		dot = tooltip:AddRowAfter("propertyitem", "propertyitem2")
		dot:SetText("")
	else
		dot = tooltip:AddRowAfter("propertyitem", "propertyitem2")
		dot:SetText("")
	end

	local image = dot:Add("DImage")
	image:SetMaterial(imagestring)
	image:SetPos(8, 0)
	image:SetSize(dot:GetTall(), dot:GetTall())

	local desctext = dot:Add("DLabel")
	desctext:MoveRightOf(image)
	desctext:SetText(" "..text)
	desctext:SetTextColor(color or Color(255, 255, 255))
	desctext:SetFont("ixSmallFont")
	desctext:SizeToContents()

	dot:SetWide(image:GetWide() + desctext:GetWide() + 15)

	tooltip:SizeToContents()
end

function ix.util.PropertyDesc3(tooltip, text, color, imagestring, zpos) -- property, with image and zpos
	if !tooltip:GetRow("propertyheader") then
		local descheader = tooltip:AddRow("propertyheader")
		descheader:SetText("\nPROPERTIES:")
		descheader:SizeToContents()
		descheader:SetContentAlignment(4)
	end

	local dot
	if !tooltip:GetRow("propertyitemheader") then
		dot = tooltip:AddRowAfter("propertyitem", "propertyitem2")
		dot:SetText("")
	else
		dot = tooltip:AddRowAfter("propertyitem", "propertyitem2")
		dot:SetText("")
	end

	local image = dot:Add("DImage")
	image:SetMaterial(imagestring)
	image:SetPos(8, 0)
	image:SetSize(dot:GetTall(), dot:GetTall())

	local desctext = dot:Add("DLabel")
	desctext:MoveRightOf(image)
	desctext:SetText(" "..text)
	desctext:SetTextColor(color or Color(255, 255, 255))
	desctext:SetFont("ixSmallFont")
	desctext:SizeToContents()

	if zpos then
		dot:SetZPos(zpos)
	end

	dot:SetWide(image:GetWide() + desctext:GetWide() + 15)

	tooltip:SizeToContents()
end

function ix.util.PropertyDesc4(tooltip, text, textColor, value, valueColor, imagestring)
    if not tooltip:GetRow("propertyheader") then
        local descheader = tooltip:AddRow("propertyheader")
        descheader:SetText("\nPROPERTIES:")
        descheader:SizeToContents()
        descheader:SetContentAlignment(4)
    end

    local dot
    if not tooltip:GetRow("propertyitem") then
        dot = tooltip:AddRowAfter("propertyheader", "propertyitem")
        dot:SetText("")
    else
        dot = tooltip:AddRowAfter("propertyitem", "propertyitem")
        dot:SetText("")
    end

    -- Create the image
    local image = dot:Add("DImage")
    image:SetMaterial(imagestring)
    image:SetPos(8, 0)
    image:SetSize(dot:GetTall(), dot:GetTall())

    -- Create the text label
    local desctext = dot:Add("DLabel")
    desctext:MoveRightOf(image)
    desctext:SetText(" " .. text)
    desctext:SetTextColor(textColor or Color(255, 255, 255))
    desctext:SetFont("ixSmallFont")
    desctext:SizeToContents()

    -- Create the value label
    local valueLabel = dot:Add("DLabel")
    valueLabel:MoveRightOf(desctext)
    valueLabel:SetText("" .. value)
    valueLabel:SetTextColor(valueColor or Color(255, 255, 255))
    valueLabel:SetFont("ixSmallFont")
    valueLabel:SizeToContents()

    -- Adjust the width of the dot to fit all elements
    dot:SetWide(image:GetWide() + desctext:GetWide() + valueLabel:GetWide() + 15)

    tooltip:SizeToContents()
end