local function ixActMenu()
	local animation = {"/Actstand","/Actsit","/Actsitwall","/Actcheer","/Actlean","/Actinjured","/Actarrestwall","/Actarrest","/Actthreat","/Actdeny","/Actmotion","/Actwave","/Actpant","/ActWindow"}
	local animationdesc = {"Stand here","Sit","Sit against a wall","Cheer","Lean against a wall","Lay on the ground injured","Face a wall","Put your hands on your head","Threat","Deny","Motion","Wave","Pant","Lay against a window"}
	local frame = vgui.Create( "DFrame" )
	frame:SetSize( 500, 300 )
	frame:SetTitle( "Utility Menu" )
	frame:MakePopup()
	frame:Center()

	local left = vgui.Create( "DScrollPanel", frame )
	left:Dock( LEFT )
	left:SetWidth( frame:GetWide() / 2 - 7 )
	left:SetPaintBackground( true )
	left:DockMargin( 0, 0, 4, 0 )

	local right = vgui.Create( "DScrollPanel", frame )
	right:Dock( FILL )
	right:SetPaintBackground( true )

	for i = 1, 14 do
		local but = vgui.Create( "DButton", frame )
		but:SetText( animationdesc [i] )
		but:SetFont("ixSmallFont")
		but:SetSize( 36, 24 )
		but:Dock( TOP )
		but.DoClick = function()
			frame:Close()
			RunConsoleCommand("say", animation [i])
		end
		right:AddItem( but )
	end
	
		local Perso = vgui.Create( "DLabel", frame )
		Perso:Dock( TOP )
		Perso:DockMargin( 8, 0, 0, 0 )
		Perso:SetFont("ixSmallFont")
		Perso:SetText( "".. LocalPlayer():GetCharacter():GetName() )
		Perso:SetSize( 36, 21 )
		left:AddItem( Perso )
		
		local faction = ix.faction.indices[LocalPlayer():GetCharacter():GetFaction()]
		
		local Perso = vgui.Create( "DLabel", frame )
		Perso:Dock( TOP )
		Perso:DockMargin( 8, 0, 0, 0 )
		Perso:SetFont("ixSmallFont")
		Perso:SetText( "Faction : ".. faction.name )
		Perso:SetSize( 36, 20 )
		left:AddItem( Perso )
		
		local Perso = vgui.Create( "DLabel", frame )
		Perso:Dock( TOP )
		Perso:DockMargin( 8, 0, 0, 0 )
		Perso:SetFont("ixSmallFont")
		Perso:SetText( "Money : ".. ix.currency.Get(LocalPlayer():GetCharacter():GetMoney()) )
		Perso:SetSize( 36, 20 )
		left:AddItem( Perso )

		local healthLabel = vgui.Create( "DLabel", frame )
		healthLabel:Dock( TOP )
		healthLabel:DockMargin( 8, 0, 0, 0 )
		healthLabel:SetFont("ixSmallFont")
		healthLabel:SetSize( 36, 20 )
		left:AddItem( healthLabel )

		local psyhealthLabel = vgui.Create( "DLabel", frame )
		psyhealthLabel:Dock( TOP )
		psyhealthLabel:DockMargin( 8, 0, 0, 0 )
		psyhealthLabel:SetFont("ixSmallFont")
		psyhealthLabel:SetSize( 36, 20 )
		left:AddItem( psyhealthLabel )

		local radiationLabel = vgui.Create( "DLabel", frame )
		radiationLabel:Dock( TOP )
		radiationLabel:DockMargin( 8, 0, 0, 0 )
		radiationLabel:SetFont("ixSmallFont")
		radiationLabel:SetSize( 36, 20 )
		left:AddItem( radiationLabel )

		local function updateLabels()
			healthLabel:SetText("Health : " .. LocalPlayer():Health())
			psyhealthLabel:SetText("Psyhealth : " .. (LocalPlayer():GetPsyHealth() or 100))
			radiationLabel:SetText("Radiation : " .. (LocalPlayer():GetNetVar("AccumRads") or 0))
		end

		updateLabels()
		timer.Create("UpdateLabelsTimer", 1, 0, function()
			if (IsValid(healthLabel) and IsValid(psyhealthLabel) and IsValid(radiationLabel)) then
				updateLabels()
			else
				timer.Remove("UpdateLabelsTimer")
			end
		end)
		
		local but = vgui.Create( "DButton", frame )
		but:SetText( "Description" )
		but:SetFont("ixSmallFont")
		but:SetSize( 36, 50 )
		but:Dock( TOP )
		but.DoClick = function()
			frame:Close()
			RunConsoleCommand("say", "/chardesc")
		end
		left:AddItem( but )
		
		local but = vgui.Create( "DButton", frame )
		but:SetText( "Fall over" )
		but:SetFont("ixSmallFont")
		but:SetSize( 36, 50 )
		but:Dock( TOP )
		but.DoClick = function()
			frame:Close()
			RunConsoleCommand("say", "/charfallover")
		end
		left:AddItem( but )
end
usermessage.Hook("ixActMenu", ixActMenu)
