PLUGIN.name = "Rankings"
PLUGIN.author = "Lt. Taylor and Zeta"
PLUGIN.desc = "Ranking list plugin."

local function FindEquippedPDA(character)
    if not character then return nil end
    local inv = character:GetInventory()
    if not inv then return nil end
    for _, item in pairs(inv:GetItems()) do
        if item.isPDA and item:GetData("equip", false) then
            return item
        end
    end
    return nil
end

if SERVER then
    -- Hook to update the avatar image
    netstream.Hook("UpdatePDAAvatar", function(client)
        local character = client:GetCharacter()
        local image = character:GetData("pdaavatar", "stalker/ui/avatars/nodata.png")
        netstream.Start(client, "UpdatePDAAvatar", image)
    end)

	netstream.Hook("RequestProfileStatus", function(client)
		local character = client:GetCharacter()
		if not character then return end

		local pdaItem = FindEquippedPDA(character)
		if not pdaItem then
			character:SetData("RankPublic", false)
			character:SetData("RankPrivate", false)
			character:SetData("pdaavatar", "stalker/ui/avatars/nodata.png")
		else
			-- If neither flag is set, default to Private
			local isPublic = character:GetData("RankPublic", false)
			local isPrivate = character:GetData("RankPrivate", false)
			if not isPublic and not isPrivate then
				character:SetData("RankPublic", false)
				character:SetData("RankPrivate", true)
				-- keep existing avatar if any, otherwise nodata is fine
			end
		end

		netstream.Start(client, "ProfileStatusChanged", {
			public = character:GetData("RankPublic", false),
			private = character:GetData("RankPrivate", false),
			avatar = character:GetData("pdaavatar", "stalker/ui/avatars/nodata.png"),
			hasPDA = FindEquippedPDA(character) ~= nil,
		})
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

if not Rankings_ProfileStatusChanged_Hooked then
    netstream.Hook("ProfileStatusChanged", function(state)
        -- Use a safe global lookup to the current open panel if you have one
        local pnl = Rankings_CurrentPanel
        if not IsValid(pnl) then return end
        local imageDisplay = pnl._imageDisplay
        local publicButton = pnl._publicButton
        local privateButton = pnl._privateButton
        if not (IsValid(imageDisplay) and IsValid(publicButton) and IsValid(privateButton)) then return end

        imageDisplay:SetImage(state.avatar or "stalker/ui/avatars/nodata.png")
        publicButton:SetImage(state.public and "stalker/ui/pda/button_selected.png" or "stalker/ui/pda/button.png")
        privateButton:SetImage(state.private and "stalker/ui/pda/button_selected.png" or "stalker/ui/pda/button.png")
    
	    -- Refresh the rank list box after status changes
        netstream.Start("GetRankListData")
	end)
    Rankings_ProfileStatusChanged_Hooked = true
end

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
		local image = character:GetData("pdaavatar","stalker/ui/avatars/nodata.png")
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
		profbox:SetImage("stalker/ui/pda/rankings/profile.png")
		profbox:SetMouseInputEnabled(true)
		
		-- Create a horizontal layout for the six boxes
		local boxLayout = profbox:Add("DPanel")
		boxLayout:Dock(FILL)
		boxLayout:SetPaintBackground(false)

		-- Create the first box for the profile image
		local imageBox = boxLayout:Add("DPanel")
		imageBox:Dock(LEFT)
		imageBox:SetSize(SW(177), SH(124)) -- Adjust size as needed
		imageBox:SetPaintBackground(false)
		imageBox:DockMargin(SW(7), 0, 0, 0)

		local imageDisplay = imageBox:Add("DImage")
		imageDisplay:SetImage(image)
		imageDisplay:Dock(TOP)
		imageDisplay:SetSize(SW(177), SH(124)) -- Adjust size if needed
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

		local reputationValues = {character:GetData("pdausername", "No PDA Name"), rank, reputation}
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
		publicButton:SetImage(public and "stalker/ui/pda/button_selected.png" or "stalker/ui/pda/button.png")
		publicButton:Dock(TOP)
		publicButton:DockMargin(0, SH(10), 0, 0)
		publicButton.DoClick = function()
			netstream.Start("ProfileChange", "public")
			LocalPlayer():EmitSound("Helix.Press")
		end 

		-- Private Button
		privateButton:SetText("PRIVATE")
		privateButton:SetFont("stalkerregularsmallboldfont")
		privateButton:SetImage(private and "stalker/ui/pda/button_selected.png" or "stalker/ui/pda/button.png")
		privateButton:Dock(TOP)
		privateButton:DockMargin(0, SH(10), 0, 0)
		privateButton.DoClick = function()
			netstream.Start("ProfileChange", "private")
			LocalPlayer():EmitSound("Helix.Press")
		end

		self._imageDisplay = imageDisplay
		self._publicButton = publicButton
		self._privateButton = privateButton
		Rankings_CurrentPanel = self

		-- Receive status and update UI so only the active one shows selected
		netstream.Hook("ProfileStatusChanged", function(state)
			if not IsValid(imageDisplay) or not IsValid(publicButton) or not IsValid(privateButton) then return end

			imageDisplay:SetImage(state.avatar or "stalker/ui/avatars/nodata.png")
			publicButton:SetImage(state.public and "stalker/ui/pda/button_selected.png" or "stalker/ui/pda/button.png")
			privateButton:SetImage(state.private and "stalker/ui/pda/button_selected.png" or "stalker/ui/pda/button.png")

			local enabled = state.hasPDA ~= false
			publicButton:SetEnabled(enabled)
			privateButton:SetEnabled(enabled)
			publicButton:SetAlpha(enabled and 255 or 120)
			privateButton:SetAlpha(enabled and 255 or 120)
		
			-- Refresh rank list whenever status changes
    		netstream.Start("GetRankListData")
		end)

		-- Hook to update the avatar image
		netstream.Hook("UpdatePDAAvatar", function(image)
			imageDisplay:SetImage(image)
		end)

		-- PLAYER INFO PANEL
		local rankinfo = pdabg:Add("DImage")
		rankinfo:SetSize(SW(840), SH(655))	--Panel on the LEFT
		rankinfo:Dock(LEFT)
		rankinfo:DockMargin(0, SH(5), 0, 0)
		rankinfo:SetImage("stalker/ui/pda/rankings/rank_display.png")
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
			infoimageBox:SetSize(SW(177), SH(124)) -- Adjust size as needed
			infoimageBox:SetPaintBackground(false)
			infoimageBox:DockMargin(SW(7), 0, 0, 0)			

			local infoimage = Material(image or "stalker/ui/avatars/nodata.png")
			local imageDisplay = infoimageBox:Add("DImage")
			imageDisplay:SetImage(image or "stalker/ui/avatars/nodata.png")
			imageDisplay:Dock(TOP)
			imageDisplay:SetSize(SW(177), SH(124)) -- Adjust size if needed
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
			reputationBox:SetSize(SW(190), SH(124)) -- Adjust size as needed
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
		ranklistbox:SetSize(SW(320), SH(655)) --Panel on the RIGHT
		ranklistbox:Dock(LEFT)
		ranklistbox:DockMargin(SW(5), SH(5), 0, 0)
		ranklistbox:SetImage("stalker/ui/pda/rankings/rank_list.png")
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
				plyrankbox:SetImage("stalker/ui/pda/rankings/rank_list_box.png")
				plyrankbox:SetMouseInputEnabled(true)
				plyrankbox.Player = plyr
					
				if rnk and name and repu and img then
					local rankings = plyrankbox:Add("DLabel")
					rankings:SetText(count..". ")
					rankings:SetTextColor(Color(255,255,255))
					rankings:SetFont("stalkerregularsmallboldfont")
					rankings:SetAutoStretchVertical(true)
					rankings:SizeToContentsX()
					rankings:Dock(LEFT)
					rankings:DockMargin(SW(10), SH(34), 0, 0)

					local imageBox = plyrankbox:Add("DPanel")
					imageBox:Dock(LEFT)
					imageBox:SetSize(SW(100), SH(70)) -- Adjust size as needed
					imageBox:SetPaintBackground(false)
					imageBox:DockMargin(0, SH(11), 0, 0)
					imageBox:SetMouseInputEnabled(false)

					local infoimage = Material(img or "stalker/ui/avatars/nodata.png")
					local imageDisplay = imageBox:Add("DImage")
					imageDisplay:SetImage(img or "stalker/ui/avatars/nodata.png")
					imageDisplay:Dock(TOP)
					imageDisplay:SetSize(SW(100), SH(70)) -- Adjust size if needed
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
					valueBox:SetWidth(SW(140))  -- Adjust width as needed
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
						LocalPlayer():EmitSound("Helix.Press")
					end
				end
			end
		end)
		netstream.Start("RequestProfileStatus")
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
	netstream.Hook("GetRankListData", function(client)
		local rankdata = {}
		for _, v in pairs(player.GetAll()) do
			local character = v:GetCharacter()
			if character then
				local hasPDA = FindEquippedPDA(character) ~= nil
				local isVisible = hasPDA and (character:GetData("RankPublic", false) or character:GetData("RankPrivate", false))
				if isVisible then
					rankdata[#rankdata + 1] = {
						["player"] = v,
						["pdaimage"] = character:GetData("pdaavatar", "stalker/ui/avatars/nodata.png"),
						["pdaname"] = character:GetData("pdausername", "Unknown"),
						["rank"] = v:getCurrentRankName() or "Tourist",
						["reputation"] = v:getReputation() or 0,
					}
				end
			end
		end

		if #rankdata > 0 then
			table.sort(rankdata, function(a, b)
				return (a["reputation"] or 0) > (b["reputation"] or 0)
			end)
			netstream.Start(client, "RankListData", rankdata)
		end
	end)

	netstream.Hook("ProfileChange", function(client, pubtype)
		local character = client:GetCharacter()
		if not character then return end

		local pdaItem = FindEquippedPDA(character)

		if not pdaItem then
			-- Force hidden if no PDA equipped
			character:SetData("RankPublic", false)
			character:SetData("RankPrivate", false)
			character:SetData("pdaavatar", "stalker/ui/avatars/nodata.png")
		else
			-- If neither set yet, consider defaulting to Private here too
			local hadState = character:GetData("RankPublic", false) or character:GetData("RankPrivate", false)

			if pubtype == "public" then
				character:SetData("RankPublic", true)
				character:SetData("RankPrivate", false)
				character:SetData("pdaavatar", pdaItem:GetData("avatar", "stalker/ui/avatars/nodata.png"))
			elseif pubtype == "private" then
				character:SetData("RankPublic", false)
				character:SetData("RankPrivate", true)
				character:SetData("pdaavatar", "stalker/ui/avatars/nodata.png")
			elseif pubtype == "hidden" then
				character:SetData("RankPublic", false)
				character:SetData("RankPrivate", false)
				character:SetData("pdaavatar", "stalker/ui/avatars/nodata.png")
			end
		end

		-- Push a confirmation to the client so it can sync button visuals
		netstream.Start(client, "ProfileStatusChanged", {
			public = character:GetData("RankPublic", false),
			private = character:GetData("RankPrivate", false),
			avatar = character:GetData("pdaavatar", "stalker/ui/avatars/nodata.png"),
			hasPDA = FindEquippedPDA(character) ~= nil,
		})
	end)
	
	netstream.Hook("SetInfoPanel", function(client, ply)
		if not IsValid(ply) then return end
		local character = ply:GetCharacter()
		if not character then return end

		if not FindEquippedPDA(character) then
			return -- hidden if no PDA
		end

		local plydata
		if character:GetData("RankPublic", false) then
			plydata = {
				--[[["description"] = character:GetDescription() or "Unknown",--]]
				["name"] = character:GetName() or "Unknown",
				["dob"] = character:GetData("sheetDOBText"),
				["nationality"] = character:GetData("sheetNationality", "Unknown"),
				["race"] = character:GetData("sheetRace"),
				["pdaimage"] = character:GetData("pdaavatar", "stalker/ui/avatars/nodata.png"),
				["pdaname"] = character:GetData("pdausername", "Unknown"),
				["rank"] = ply:getCurrentRankName() or "Tourist",
				["reputation"] = ply:getReputation() or 0,
			}
		elseif character:GetData("RankPrivate", false) then
			plydata = {
				["pdaimage"] = character:GetData("pdaavatar", "stalker/ui/avatars/nodata.png"),
				["pdaname"] = character:GetData("pdausername", "Unknown"),
				["rank"] = ply:getCurrentRankName() or "Tourist",
				["reputation"] = ply:getReputation() or 0,
			}
		end

		if plydata then
			netstream.Start(client, "SetupInfoPanel", plydata)
		end
	end)
end