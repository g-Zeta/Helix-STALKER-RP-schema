PLUGIN.name = "Rankings"
PLUGIN.author = "Lt. Taylor and Zeta"
PLUGIN.desc = "Ranking list plugin."

if SERVER then
    -- Hook to update the avatar image
    netstream.Hook("UpdatePDAAvatar", function(client)
        local character = client:GetCharacter()
        local image = character:GetData("pdaavatar", "vgui/icons/face_31.png")
        netstream.Start(client, "UpdatePDAAvatar", image)
    end)
end

local BASE_W, BASE_H = 1920, 1080
local function UIScale()
  -- uniform scale, using the minimum axis to avoid stretch
  return math.min(ScrW() / BASE_W, ScrH() / BASE_H)
end

local function SW(x) return math.floor(x * UIScale() + 0.5) end
local function SH(y) return math.floor(y * UIScale() + 0.5) end

local PANEL = {}
local headcolor = Color(104, 104, 104)
local repcolor = Color(107,104,175)
local stndcolor = Color(255,255,255)

if CLIENT then
	
	local thinktime = 1
	
	local PANELEDIT = {}

	function PANELEDIT:GetContentSize()
		surface.SetFont( self:GetFont() )
		local w, h = surface.GetTextSize( self:GetText() )
		local heightorig = h
		
		while self:GetWide() < w do
			h = h + (heightorig)
			w = w - (self:GetWide())
		end
		h = h + (heightorig) + 5
		
		return w, h
	end

	vgui.Register( "DTextEntry_Edit", PANELEDIT, "DTextEntry" )


	function PANEL:Init()
		local client = LocalPlayer()
		local character = client:GetCharacter()
		local image = character:GetData("pdaavatar","vgui/icons/face_31.png")
		local rank = client:getCurrentRankName()
		local reputation = client:getReputation()
		local public = character:GetData("RankPublic",false)
		local private = character:GetData("RankPrivate",false)
		
		self:SetSize(SW(1165), SH(770)) --Adjust size of the whole panel
		--self:Center()
		self:SetPos(SW(54), SH(86)) --Adjust position of the whole panel
		self:SetDrawBackground(false)
		self:SetPaintBackground(false)
		
		local pdabg = self:Add("DImage")
		pdabg:Center()
		pdabg:Dock(FILL)
		pdabg:SetPaintBackground(false)
		--pdabg:SetImage("stalker/ui/pda/background.png")
		pdabg:SetMouseInputEnabled(true)
		
		-- PLAYER PROFILE PANEL
		local profbox = pdabg:Add("DImage")
		profbox:SetSize(SW(1165), SH(140))
		profbox:Dock(TOP)
		profbox:DockMargin(0, 0, 0, 0)
		profbox:SetImage("stalker/ui/rankings/profile.png")
		profbox:SetMouseInputEnabled(true)
		
		-- Create a horizontal layout for the six boxes
		local boxLayout = profbox:Add("DPanel")
		boxLayout:Dock(FILL)
		boxLayout:SetPaintBackground(false)

		-- Create the first box for the profile image
		local imageBox = boxLayout:Add("DPanel")
		imageBox:Dock(LEFT)
		imageBox:SetSize(SW(124), SH(124)) -- Adjust size as needed
		imageBox:SetPaintBackground(false)
		imageBox:DockMargin(SW(7), 0, 0, 0)

		local profimage = Material(image)
		local imageDisplay = imageBox:Add("DImage")
		imageDisplay:SetImage(image)
		imageDisplay:Dock(TOP)
		imageDisplay:SetSize(SW(124), SH(124)) -- Adjust size if needed
		imageDisplay:SetPaintBackground(false) -- Ensure background is not painted
		imageDisplay:Center()
		imageDisplay:DockMargin(0, SH(9), 0, 0)

		-- Create the second box for titles
		local titleBox = boxLayout:Add("DPanel")
		titleBox:Dock(LEFT)
		titleBox:SetSize(SW(110), SH(124)) -- Adjust size as needed
		titleBox:SetPaintBackground(false)

		-- Titles
		local titles = {"Name:", "Date of Birth:", "Nationality:", "Race:"}
		for _, title in ipairs(titles) do
			local titleLabel = titleBox:Add("DLabel")
			titleLabel:SetText(title)
			titleLabel:SetTextColor(headcolor)
			titleLabel:SetFont("stalkerregularsmallboldfont")
			titleLabel:Dock(TOP)
			titleLabel:DockMargin(SW(4), SH(7), 0, 0)
		end

		-- Create the third box for values
		local valueBox = boxLayout:Add("DPanel")
		valueBox:Dock(LEFT)
		valueBox:SetSize(SW(245), SH(124)) -- Adjust size as needed
		valueBox:SetPaintBackground(false)

		-- Values
		local values = {
			character:GetName() or "Unknown",
			character:GetData("sheetDOBText", "Unknown"),
			character:GetData("sheetNationality", "Unknown"),
			character:GetData("sheetRace", "Unknown"),
		}
		for _, value in ipairs(values) do
			local valueLabel = valueBox:Add("DLabel")
			valueLabel:SetText(value)
			valueLabel:SetTextColor(Color(255, 255, 255))
			valueLabel:SetFont("stalkerregularsmallboldfont")
			valueLabel:Dock(TOP)
			valueLabel:DockMargin(0, SH(7), 0, 0)
		end

		-- Create the fourth box for rank and reputation titles
		local rankBox = boxLayout:Add("DPanel")
		rankBox:Dock(LEFT)
		rankBox:SetSize(SW(104), SH(124)) -- Adjust size as needed
		rankBox:SetPaintBackground(false)

		local rankTitles = {"PDA Handle:", "Rank:", "Reputation:"}
		for _, title in ipairs(rankTitles) do
			local rankTitleLabel = rankBox:Add("DLabel")
			rankTitleLabel:SetText(title)
			rankTitleLabel:SetTextColor(headcolor)
			rankTitleLabel:SetFont("stalkerregularsmallboldfont")
			rankTitleLabel:Dock(TOP)
			rankTitleLabel:DockMargin(0, SH(7), 0, 0)
		end

		-- Create the fifth box for rank and reputation values
		local reputationBox = boxLayout:Add("DPanel")
		reputationBox:Dock(LEFT)
		reputationBox:SetSize(SW(250), SH(124)) -- Adjust size as needed
		reputationBox:SetPaintBackground(false)

		local reputationValues = {character:GetData("pdanickname", "No PDA Name"), rank, reputation}
		for _, value in ipairs(reputationValues) do
			local reputationLabel = reputationBox:Add("DLabel")
			reputationLabel:SetText(value)
			if value == reputation then
				reputationLabel:SetTextColor(repcolor)
			else
				reputationLabel:SetTextColor(Color(255, 255, 255, 255))
			end
			reputationLabel:SetFont("stalkerregularsmallboldfont")
			reputationLabel:Dock(TOP)
			reputationLabel:DockMargin(0, SH(7), 0, 0)
		end
		
		-- Create the sixth box for profile publicity
		local publicityBox = boxLayout:Add("DPanel")
		publicityBox:Dock(LEFT)
		publicityBox:SetSize(SW(200), SH(124)) -- Adjust size as needed
		publicityBox:SetPaintBackground(false)

		local publicityTitle = publicityBox:Add("DLabel")
		publicityTitle:SetText("Profile Publicity")
		publicityTitle:SetTextColor(headcolor)
		publicityTitle:SetFont("stalkerregularsmallboldfont")
		publicityTitle:Dock(TOP)
		publicityTitle:DockMargin(0, SH(5), 0, 0)

		-- Define the buttons first
		local publicButton = publicityBox:Add("DImageButton")
		local privateButton = publicityBox:Add("DImageButton")

		-- Public Button
		publicButton:SetText("PUBLIC")
		publicButton:SetFont("stalkerregularsmallboldfont")
		publicButton:SetImage("stalker/ui/pda/pda_button.png") -- Default image
		publicButton:Dock(TOP)
		publicButton:DockMargin(0, SH(10), 0, 0)
		publicButton.DoClick = function()
			if string.match(publicButton:GetImage(), "pda_button.png") then
				publicButton:SetImage("stalker/ui/pda/pda_button_click.png")
			else
				publicButton:SetImage("stalker/ui/pda/pda_button.png")
			end
			netstream.Start("ProfileChange", "public")
			-- Update RankListData and pdaavatar
			netstream.Start("GetRankListData")
			netstream.Start("UpdatePDAAvatar")
		end 

		-- Private Button
		privateButton:SetText("PRIVATE")
		privateButton:SetFont("stalkerregularsmallboldfont")
		privateButton:SetImage("stalker/ui/pda/pda_button.png") -- Default image
		privateButton:Dock(TOP)
		privateButton:DockMargin(0, SH(10), 0, 0)
		privateButton.DoClick = function()
			if string.match(privateButton:GetImage(), "pda_button.png") then
				privateButton:SetImage("stalker/ui/pda/pda_button_click.png")
			else
				privateButton:SetImage("stalker/ui/pda/pda_button.png")
			end
			netstream.Start("ProfileChange", "private")
			-- Update RankListData and pdaavatar
			netstream.Start("GetRankListData")
			netstream.Start("UpdatePDAAvatar")
		end

		-- Hook to update the avatar image
		netstream.Hook("UpdatePDAAvatar", function(image)
			imageDisplay:SetImage(image)
		end)

		-- PLAYER INFO PANEL
		local rankinfo = pdabg:Add("DImage")
		rankinfo:SetSize(SW(800), SH(655))	--Panel on the LEFT
		rankinfo:Dock(LEFT)
		rankinfo:DockMargin(0, SH(5), 0, 0)
		rankinfo:SetImage("stalker/ui/rankings/rank_display.png")
		rankinfo:SetMouseInputEnabled(true)
		
		netstream.Hook("SetupInfoPanel", function(plydata)
			local desc
			local name
			local dob
			local nationality
			local race
			local image
			local pdaname
			local rank
			local reputation
			
			for k,v in pairs(plydata) do
				--[[ if k == "description" then
					desc = v --]]
					
				if k == "name" then
					name = v
				
				elseif k == "dob" then
					dob = v
					
				elseif k == "nationality" then
					nationality = v
					
				elseif k == "race" then
					race = v
					
				elseif k == "pdaimage" then
					image = v
					
				elseif k == "pdaname" then
					pdaname = v
					
				elseif k == "rank" then
					rank = v 
					
				elseif k == "reputation" then
					reputation = v
					
				end
			end
			
			if rankinfo:HasChildren() then
				for k,v in pairs(rankinfo:GetChildren()) do
					v:Remove()
				end
			end

			-- Create a horizontal layout for the six boxes
			local infoboxLayout = rankinfo:Add("DPanel")
			infoboxLayout:Dock(FILL)
			infoboxLayout:SetPaintBackground(false)
			
			local infoimageBox = infoboxLayout:Add("DPanel")
			infoimageBox:Dock(LEFT)
			infoimageBox:SetSize(SW(124), SH(124)) -- Adjust size as needed
			infoimageBox:SetPaintBackground(false)
			infoimageBox:DockMargin(SW(7), 0, 0, 0)			

			local infoimage = Material(image or "vgui/icons/face_31.png")
			local imageDisplay = infoimageBox:Add("DImage")
			imageDisplay:SetImage(image or "vgui/icons/face_31.png")
			imageDisplay:Dock(TOP)
			imageDisplay:SetSize(SW(124), SH(124)) -- Adjust size if needed
			imageDisplay:SetPaintBackground(false) -- Ensure background is not painted
			imageDisplay:Center()
			imageDisplay:DockMargin(0, SH(9), 0, 0)

			-- Create the second box for titles
			local titleBox = infoboxLayout:Add("DPanel")
			titleBox:Dock(LEFT)
			titleBox:SetSize(SW(110), SH(124)) -- Adjust size as needed
			titleBox:SetPaintBackground(false)

			-- Titles
			local titles = {"Name:", "Date of Birth:", "Nationality:", "Race:"}
			for _, title in ipairs(titles) do
				local titleLabel = titleBox:Add("DLabel")
				titleLabel:SetText(title)
				titleLabel:SetTextColor(headcolor)
				titleLabel:SetFont("stalkerregularsmallboldfont")
				titleLabel:Dock(TOP)
				titleLabel:DockMargin(SW(4), SH(7), 0, 0)
			end

			-- Create the third box for values
			local valueBox = infoboxLayout:Add("DPanel")
			valueBox:Dock(LEFT)
			valueBox:SetSize(SW(245), SH(124)) -- Adjust size as needed
			valueBox:SetPaintBackground(false)

			local function createLabel(parent, text, size)
				local label = valueBox:Add("DLabel")
				label:SetFont("stalkerregularsmallboldfont")
				label:Dock(TOP)
				label:SetText(text or "N/A")  -- Set the text or default to "N/A"
				label:DockMargin(0, SH(7), 0, 0)
				return label
			end
			-- Now you can create the labels using the unified function
			createLabel(valueBox, name)
			createLabel(valueBox, dob)
			createLabel(valueBox, nationality)
			createLabel(valueBox, race)
			
			-- Create the fourth box for rank and reputation titles
			local rankBox = infoboxLayout:Add("DPanel")
			rankBox:Dock(LEFT)
			rankBox:SetSize(SW(104), SH(124)) -- Adjust size as needed
			rankBox:SetPaintBackground(false)
			
			local function createLabel(parent, text)
				local rightlabel = rankBox:Add("DLabel")
				rightlabel:Dock(TOP)
				rightlabel:SetWidth(SH(77))
				rightlabel:SetTextColor(headcolor)
				rightlabel:SetFont("stalkerregularsmallboldfont")
				rightlabel:SetText(text)
				rightlabel:DockMargin(0, SH(7), 0, 0)
				return rightlabel
			end
			-- Create the labels using the unified function
			createLabel(rankBox, "PDA Handle:")
			createLabel(rankBox, "Rank:")
			createLabel(rankBox, "Reputation:")

			-- Create the fifth box for rank and reputation values
			local reputationBox = infoboxLayout:Add("DPanel")
			reputationBox:Dock(LEFT)
			reputationBox:SetSize(SW(145), SH(124)) -- Adjust size as needed
			reputationBox:SetPaintBackground(false)

			-- Function to create a DLabel with common properties
			local function createLabel(parent, text, color, size, margin)
				local label = reputationBox:Add("DLabel")
				label:Dock(TOP)
				label:SetFont("stalkerregularsmallboldfont")
				label:DockMargin(0, SH(7), 0, 0)
				label:SetText(text)
				if color then
					label:SetTextColor(color)
				end
				return label
			end
			-- Create the labels using the function
			createLabel(reputationBox, pdaname)
			createLabel(reputationBox, rank)
			createLabel(reputationBox, reputation, repcolor)
		end)
		
		-- RANK LIST PANEL
		local ranklistbox = pdabg:Add("DImage")
		ranklistbox:SetSize(SW(360), SH(655)) --Panel on the RIGHT
		ranklistbox:Dock(LEFT)
		ranklistbox:DockMargin(SW(5), SH(5), 0, 0)
		ranklistbox:SetImage("stalker/ui/rankings/rank_list.png")
		ranklistbox:SetName("RankListBox")
		ranklistbox:SetMouseInputEnabled(true)
		
		netstream.Start("GetRankListData")
		netstream.Hook("RankListData", function(rankdata)
			local ranklistold
			local img
			local name
			local rnk
			local repu
			local plyr
			local count = 1
			
			if ranklistbox:GetChildren() then
				for x,y in pairs(ranklistbox:GetChildren()) do
					if y:GetName() == "RankList" then
						y:Remove()
					end
				end
			end
			
			local ranklist = ranklistbox:Add("DScrollPanel")
			ranklist:Dock(FILL)
			ranklist:DockMargin(SW(5), SH(5), 0, SH(5))
			ranklist:SetName("RankList")
			ranklist:SetMouseInputEnabled(true)
				
			for k,v in ipairs(rankdata) do
				
				for x,y in pairs(v) do
					if x == "pdaimage" then
						img = y
						
					elseif x == "pdaname" then
						name = y
	
					elseif x == "rank" then
						rnk = y
						
					elseif x == "reputation" then
						repu = y
							
					elseif x == "player" then
						plyr = y
					
					end
				end
				
				local plyrankbox = ranklist:Add("DImageButton")
				plyrankbox:SetSize(SW(380), SH(92))
				plyrankbox:Dock(TOP)
				plyrankbox:DockMargin(0, 0, SW(5), 0)
				plyrankbox:SetImage("stalker/ui/rankings/rank_list_box.png")
				plyrankbox:SetMouseInputEnabled(true)
				plyrankbox.Player = plyr
					
				if rnk and name and repu and img then
					local rankings = plyrankbox:Add("DLabel")
					rankings:SetText(count..". ")
					rankings:SetTextColor(Color(255,255,255))
					rankings:SetFont("stalkerregularsmallboldfont")
					rankings:SetPos(SW(524), SH(3))
					rankings:SetAutoStretchVertical(true)
					rankings:SizeToContentsX()
					rankings:Dock(LEFT)
					rankings:DockMargin(SW(10), SH(34), 0, 0)

					local imageBox = plyrankbox:Add("DPanel")
					imageBox:Dock(LEFT)
					imageBox:SetSize(SW(82), SH(82)) -- Adjust size as needed
					imageBox:SetPaintBackground(false)
					imageBox:DockMargin(0, SH(5), 0, 0)
					imageBox:SetMouseInputEnabled(false)

					local infoimage = Material(image or "vgui/icons/face_31.png")
					local imageDisplay = imageBox:Add("DImage")
					imageDisplay:SetImage(image or "vgui/icons/face_31.png")
					imageDisplay:Dock(TOP)
					imageDisplay:SetSize(SW(82), SH(82)) -- Adjust size if needed
					imageDisplay:SetPaintBackground(false) -- Ensure background is not painted
					imageDisplay:Center()
					imageDisplay:DockMargin(0, 0, 0, 0)
					
					-- Create a container for labels and values
					local infoContainer = plyrankbox:Add("DPanel")
					infoContainer:Dock(LEFT)
					infoContainer:SetWidth(SW(384))  -- Adjust width as needed
					infoContainer:SetPaintBackground(false)

					-- Left box for labels
					local labelBox = infoContainer:Add("DPanel")
					labelBox:Dock(LEFT)
					labelBox:SetWidth(SW(50))  -- Adjust width as needed
					labelBox:SetBackgroundColor(Color(0, 0, 0, 0))  -- Set background color if needed
					
					-- Override Paint function to avoid borders
					function labelBox:Paint(w, h) end

					local pdaLabel = labelBox:Add("DLabel")
					pdaLabel:SetText("PDA:")
					pdaLabel:SetTextColor(headcolor)
					pdaLabel:SetFont("stalkerregularsmallboldfont")
					pdaLabel:Dock(TOP)
					pdaLabel:DockMargin(SW(4), SH(4), 0, 0)

					local rankLabel = labelBox:Add("DLabel")
					rankLabel:SetText("Rank:")
					rankLabel:SetTextColor(headcolor)
					rankLabel:SetFont("stalkerregularsmallboldfont")
					rankLabel:Dock(TOP)
					rankLabel:DockMargin(SW(4), SH(12), 0, 0)

					local reputationLabel = labelBox:Add("DLabel")
					reputationLabel:SetText("Rep:")
					reputationLabel:SetTextColor(headcolor)
					reputationLabel:SetFont("stalkerregularsmallboldfont")
					reputationLabel:Dock(TOP)
					reputationLabel:DockMargin(SW(4), SH(12), 0, 0)

					-- Right box for values
					local valueBox = infoContainer:Add("DPanel")
					valueBox:Dock(LEFT)
					valueBox:SetWidth(SW(210))  -- Adjust width as needed
					valueBox:SetBackgroundColor(Color(0, 0, 0, 0))  -- Set background color if needed

					-- Override Paint function to avoid borders
					function valueBox:Paint(w, h) end

					local pdaValue = valueBox:Add("DLabel")
					pdaValue:SetText(name)
					pdaValue:SetTextColor(Color(255, 255, 255))  -- Set to desired color
					pdaValue:SetFont("stalkerregularsmallboldfont")
					pdaValue:Dock(TOP)
					pdaValue:DockMargin(0, SH(4), 0, 0)

					local rankValue = valueBox:Add("DLabel")
					rankValue:SetText(rnk)
					rankValue:SetTextColor(Color(255, 255, 255))  -- Set to desired color
					rankValue:SetFont("stalkerregularsmallboldfont")
					rankValue:Dock(TOP)
					rankValue:DockMargin(0, SH(12), 0, 0)

					local reputationValue = valueBox:Add("DLabel")
					reputationValue:SetText(repu)
					reputationValue:SetTextColor(repcolor)  -- Set to desired color
					reputationValue:SetFont("stalkerregularsmallboldfont")
					reputationValue:Dock(TOP)
					reputationValue:DockMargin(0, SH(12), 0, 0)
					
					count = count + 1
						
					rnk = nil
					repu = nil
					name = nil
					image = nil
					plyr = nil

					plyrankbox.DoClick = function()
						if plyrankbox.Player then
							netstream.Start("SetInfoPanel", plyrankbox.Player)
						else
							LocalPlayer():Notify("Error Referencing Player")
						end
					end
				end
			end
		end)
	end
	
	vgui.Register("RankingsListFrame", PANEL, "DPanel")

	hook.Add("CreateMenuButtons", "ixRankings", function(tabs)
		tabs["Rankings"] = function(container)
			container:Add("RankingsListFrame")
		end
	end)

	hook.Add("CreateMenuButtons", "ixRankings", function(tabs)
		local client = LocalPlayer()
		local character = client:GetCharacter()
		local inventory = character:GetInventory()

		if character and inventory then
			local pdaItem

			-- Iterate through the inventory to find the PDA item and check if it is equipped
			for _, item in pairs(inventory:GetItems()) do
				if item.isPDA and item:GetData("equip", false) then
					pdaItem = item
					break
				end
			end

			if pdaItem then
				tabs["Rankings"] = function(container)
					container:Add("RankingsListFrame")
				end
			end
		end
	end)

else
	netstream.Hook("GetRankListData",function(client)
		local rankdata = {}
		local plylist = player.GetAll()
		
		for k,v in pairs(plylist) do
			local character = v:GetCharacter()
			if character then
				if character:GetData("RankPublic",false) or character:GetData("RankPrivate",false) then
					rankdata[k] = {
						["player"] = v,
						["pdaimage"] = character:GetData("pdaavatar","vgui/icons/face_31.png"),
						["pdaname"] = character:GetData("pdanickname","Unknown"),
						["rank"] = v:getCurrentRankName() or "Tourist",
						["reputation"] = v:getReputation() or 0,
					}
				end
			end
		end
		
		if not table.IsEmpty(rankdata) then
			
			local counter = 1
			local newrankdata = {}
			
			if not table.IsSequential(rankdata) then
				for k,v in pairs(rankdata) do
					newrankdata[counter] = v
					counter = counter + 1
				end
				rankdata = newrankdata
			end
			
			if #rankdata >= 2 then
				table.sort(rankdata, function(a, b)
					return a["reputation"] > b["reputation"]
				end)
			end
			
			netstream.Start(client, "RankListData", rankdata)
		end
	end)

	netstream.Hook("ProfileChange", function(client, pubtype)
		local character = client:GetCharacter()

		-- Check if the PDA item is equipped
		local items = character:GetInventory():GetItems()
		for _, item in pairs(items) do
			if item.isPDA and item:GetData("equip") then
				if pubtype == "private" then
					if character:GetData("RankPrivate", false) then
						character:SetData("RankPrivate", false)
					else
						character:SetData("RankPrivate", true)
						character:SetData("RankPublic", false)
						character:SetData("pdaavatar", "vgui/icons/face_31.png")
					end
				elseif pubtype == "public" then
					if character:GetData("RankPublic", false) then
						character:SetData("RankPublic", false)
					else
						character:SetData("RankPublic", true)
						character:SetData("RankPrivate", false)
						character:SetData("pdaavatar", item:GetData("avatar", "vgui/icons/face_31.png"))
					end
				end
			end
		end
	end)
	
	netstream.Hook("SetInfoPanel", function(client, ply)
		local plylist = player.GetAll()
		local target
		local plydata = {}
		
		for k,v in pairs(plylist) do
			if v == ply then
				target = v
			end
		end
		
		local character = target:GetCharacter()
		
		if character:GetData("RankPublic",false) then
			plydata = {
				--[[["description"] = character:GetDescription() or "Unknown",--]]
				["name"] = character:GetName() or "Unknown",
				["dob"] = character:GetData("sheetDOBText"),
				["nationality"] = character:GetData("sheetNationality","Unknown"),
				["race"] = character:GetData("sheetRace"),
				["pdaimage"] = character:GetData("pdaavatar","vgui/icons/face_31.png"),
				["pdaname"] = character:GetData("pdanickname","Unknown"),
				["rank"] = target:getCurrentRankName() or "Tourist",
				["reputation"] = target:getReputation() or 0,
			}
		elseif character:GetData("RankPrivate",false) then
			plydata = {
				["pdaimage"] = character:GetData("pdaavatar","vgui/icons/face_31.png"),
				["pdaname"] = character:GetData("pdanickname","Unknown"),
				["rank"] = target:getCurrentRankName() or "Tourist",
				["reputation"] = target:getReputation() or 0,
			}
		end
		if not table.IsEmpty(plydata) then
			netstream.Start(client, "SetupInfoPanel", plydata)
		end
	end)
end