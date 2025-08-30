local PANEL = {}

function PANEL:Init()
	self:SetSize(ScrW()*0.35, ScrH()*0.8)	
	self:MakePopup()
	self:Center()
	self:SetTitle("Character Sheet")

	self.controls = self:Add("DPanel")
	self.controls:Dock(BOTTOM)
	self.controls:SetTall(30)
	self.controls:DockMargin(0, 5, 0, 0)
	
	self.photo = self.controls:Add("DTextEntry")
	self.photo:Dock(FILL)
	self.photo:SetMultiline(true)
	self.photo:SetEditable(true)

	self.confirm = self.controls:Add("DButton")
	self.confirm:Dock(RIGHT)
	self.confirm:SetDisabled(false)
	self.confirm:SetText("Finish")
	
	self.hardcontents = self:Add("DPanel")
	self.hardcontents:Dock(FILL)
	self.hardcontents:SizeToContents()
	self.hardcontents:SetTall(self.hardcontents:GetParent():GetTall()*0.3)
	self.hardcontents:DockMargin(0, 5, 0, 0)

	self.titles = self.hardcontents:Add("DPanel")
	self.titles:Dock(LEFT)
	self.titles:SetWide(self:GetWide()*0.3)

	self.titlesright = self.hardcontents:Add("DPanel")
	self.titlesright:Dock(FILL)
	self.titlesright:SizeToContents()

	self.confirm.DoClick = function(this)
		local url = self.photo:GetValue()
		local character = LocalPlayer():GetCharacter()
		local sheet = character:GetData("charsheetinfo", {})
		sheet["Name"].right = charsheetnameright:GetValue()
		sheet["Nickname"].right = charsheetnicknameright:GetValue()
		sheet["Age"].right = charsheetageright:GetValue()
		sheet["Race"].right = charsheetraceright:GetValue()
		sheet["Nationality"].right = charsheetnationalityright:GetValue()

		netstream.Start("ixDescriptionSendText", text, url, sheet)
		self:Close()
	end

	self.controls.Paint = function(this, w, h)
		local url = self.photo:GetValue()
		draw.SimpleText(Format(string.len(url)), "DermaDefault", 10, h/2, color_white, TEXT_ALIGN_LEFT, 1)
	end
end

function PANEL:setText(text, url)
	self.photo:SetValue(url or "Place your link")
end

function PANEL:buildSheet(client, isadmin)
	local sheetdata = client:GetCharacter():GetData("charsheetinfo", nil)

	-- Name
	charsheetnameleft = self.titles:Add("DLabel")
	charsheetnameleft:Dock(TOP)
	charsheetnameleft:SetText(sheetdata["Name"].left..": ")
	charsheetnameleft:SizeToContents()
	charsheetnameleft:SetContentAlignment(7)
	charsheetnameleft:SetFont("stalkerregularfont")
	charsheetnameleft:SetTall(ScrH()*0.020)

	charsheetnameright = self.titlesright:Add("DTextEntry")
	charsheetnameright:SetMultiline(true)
	if sheetdata["Name"].nonadmin == true or isadmin == true then
		charsheetnameright:SetEditable(true)
	else
		charsheetnameright:SetEditable(false)
	end
	charsheetnameright:Dock(TOP)
	charsheetnameright:SetText(sheetdata["Name"].right)
	charsheetnameright:SizeToContents()
	charsheetnameright:SetTall(ScrH()*0.020)
	charsheetnameright:SetFont("stalkerregularsmallfont")

	--Nickname
	charsheetnicknameleft = self.titles:Add("DLabel")
	charsheetnicknameleft:Dock(TOP)
	charsheetnicknameleft:SetText(sheetdata["Nickname"].left..": ")
	charsheetnicknameleft:SizeToContents()
	charsheetnicknameleft:SetContentAlignment(7)
	charsheetnicknameleft:SetFont("stalkerregularfont")
	charsheetnicknameleft:SetTall(ScrH()*0.020)

	charsheetnicknameright = self.titlesright:Add("DTextEntry")
	charsheetnicknameright:SetMultiline(true)
	if sheetdata["Nickname"].nonadmin == true or isadmin == true then
		charsheetnicknameright:SetEditable(true)
	else
		charsheetnicknameright:SetEditable(false)
	end
	charsheetnicknameright:Dock(TOP)
	charsheetnicknameright:SetText(sheetdata["Nickname"].right)
	charsheetnicknameright:SizeToContents()
	charsheetnicknameright:SetTall(ScrH()*0.020)
	charsheetnicknameright:SetFont("stalkerregularsmallfont")

	--Age
	charsheetageleft = self.titles:Add("DLabel")
	charsheetageleft:Dock(TOP)
	charsheetageleft:SetText(sheetdata["Age"].left..": ")
	charsheetageleft:SizeToContents()
	charsheetageleft:SetContentAlignment(7)
	charsheetageleft:SetFont("stalkerregularfont")
	charsheetageleft:SetTall(ScrH()*0.020)

	charsheetageright = self.titlesright:Add("DTextEntry")
	charsheetageright:SetMultiline(true)
	if sheetdata["Age"].nonadmin == true or isadmin == true then
		charsheetageright:SetEditable(true)
	else
		charsheetageright:SetEditable(false)
	end
	charsheetageright:Dock(TOP)
	charsheetageright:SetText(sheetdata["Age"].right)
	charsheetageright:SizeToContents()
	charsheetageright:SetTall(ScrH()*0.020)
	charsheetageright:SetFont("stalkerregularsmallfont")

	--Race
	charsheetraceleft = self.titles:Add("DLabel")
	charsheetraceleft:Dock(TOP)
	charsheetraceleft:SetText(sheetdata["Race"].left..": ")
	charsheetraceleft:SizeToContents()
	charsheetraceleft:SetContentAlignment(7)
	charsheetraceleft:SetFont("stalkerregularfont")
	charsheetraceleft:SetTall(ScrH()*0.020)

	charsheetraceright = self.titlesright:Add("DTextEntry")
	charsheetraceright:SetMultiline(true)
	if sheetdata["Race"].nonadmin == true or isadmin == true then
		charsheetraceright:SetEditable(true)
	else
		charsheetraceright:SetEditable(false)
	end
	charsheetraceright:Dock(TOP)
	charsheetraceright:SetText(sheetdata["Race"].right)
	charsheetraceright:SizeToContents()
	charsheetraceright:SetTall(ScrH()*0.020)
	charsheetraceright:SetFont("stalkerregularsmallfont")

	--Nationality
	charsheetnationalityleft = self.titles:Add("DLabel")
	charsheetnationalityleft:Dock(TOP)
	charsheetnationalityleft:SetText(sheetdata["Nationality"].left..": ")
	charsheetnationalityleft:SizeToContents()
	charsheetnationalityleft:SetContentAlignment(7)
	charsheetnationalityleft:SetFont("stalkerregularfont")
	charsheetnationalityleft:SetTall(ScrH()*0.020)

	charsheetnationalityright = self.titlesright:Add("DTextEntry")
	charsheetnationalityright:SetMultiline(true)
	if sheetdata["Nationality"].nonadmin == true or isadmin == true then
		charsheetnationalityright:SetEditable(true)
	else
		charsheetnationalityright:SetEditable(false)
	end
	charsheetnationalityright:Dock(TOP)
	charsheetnationalityright:SetText(sheetdata["Nationality"].right)
	charsheetnationalityright:SizeToContents()
	charsheetnationalityright:SetTall(ScrH()*0.020)
	charsheetnationalityright:SetFont("stalkerregularsmallfont")

	--StalkerNET Status
	charsheetstalkernetleft = self.titles:Add("DLabel")
	charsheetstalkernetleft:Dock(TOP)
	charsheetstalkernetleft:SetText("StalkerNET Rank"..": ")
	charsheetstalkernetleft:SizeToContents()
	charsheetstalkernetleft:SetContentAlignment(7)
	charsheetstalkernetleft:SetFont("stalkerregularfont")
	charsheetstalkernetleft:SetTall(ScrH()*0.030)

	charsheetstalkernetright = self.titlesright:Add("DLabel")
	charsheetstalkernetright:Dock(TOP)
	charsheetstalkernetright:SetText(client:getCurrentRankName())
	charsheetstalkernetright:SizeToContents()
	charsheetstalkernetright:SetTall(ScrH()*0.030)
	charsheetstalkernetright:SetContentAlignment(7)
	charsheetstalkernetright:SetFont("stalkerregularfont")

	--Attributes
	charsheetattributesleft = self.titles:Add("DLabel")
	charsheetattributesleft:Dock(TOP)
	charsheetattributesleft:SetText("Primary Attributes"..": ")
	charsheetattributesleft:SizeToContents()
	charsheetattributesleft:SetContentAlignment(7)
	charsheetattributesleft:SetFont("stalkerregularfont")
	charsheetattributesleft:SetTall(ScrH()*0.020)

	for k, v in SortedPairsByMemberValue(ix.attributes.list, "name") do
		if v.secondary then
			continue
		end

		charsheetattributesright = self.titles:Add("DLabel")
		charsheetattributesright:Dock(TOP)
		charsheetattributesright:SetFont("stalkerregularsmallfont")
		charsheetattributesright:SetText(v.name..": "..client:GetCharacter():GetAttribute(k, 0))
		charsheetattributesright:SizeToContents()
		charsheetattributesright:SetTall(ScrH()*0.016)
	end

	--Secondary Attributes
	charsheetsecattributesleft = self.titles:Add("DLabel")
	charsheetsecattributesleft:Dock(TOP)
	charsheetsecattributesleft:SetText("Secondary Attributes"..": ")
	charsheetsecattributesleft:SizeToContents()
	charsheetsecattributesleft:SetContentAlignment(1)
	charsheetsecattributesleft:SetFont("stalkerregularfont")
	charsheetsecattributesleft:SetTall(ScrH()*0.030)

	for k, v in SortedPairsByMemberValue(ix.attributes.list, "name") do
		if v.secondary == true then
			charsheetsecattributesright = self.titles:Add("DLabel")
			charsheetsecattributesright:Dock(TOP)
			charsheetsecattributesright:SetFont("stalkerregularsmallfont")
			charsheetsecattributesright:SetText(v.name..": "..client:GetCharacter():GetAttribute(k, 0))
			charsheetsecattributesright:SizeToContents()
			charsheetsecattributesright:SetTall(ScrH()*0.016)
		end
	end

	--Perks
	charsheetperksleft = self.titlesright:Add("DLabel")
	charsheetperksleft:Dock(TOP)
	charsheetperksleft:SetText("Perks"..": ")
	charsheetperksleft:SizeToContents()
	charsheetperksleft:SetContentAlignment(7)
	charsheetperksleft:SetFont("stalkerregularfont")
	charsheetperksleft:SetTall(ScrH()*0.020)

	for k, v in SortedPairsByMemberValue(ix.perks.list, "name") do
		charsheetperksright = self.titlesright:Add("DLabel")
		charsheetperksright:Dock(TOP)
		charsheetperksright:SetFont("stalkerregularsmallfont")
		charsheetperksright:SetText(v.name..": "..client:GetCharacter():GetPerk(k, 0))
		charsheetperksright:SizeToContents()
		charsheetperksright:SetTall(ScrH()*0.016)
	end



end

vgui.Register("ixDescriptionEn", PANEL, "DFrame")