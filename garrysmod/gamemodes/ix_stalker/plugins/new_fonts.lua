PLUGIN.name = "New Fonts"
PLUGIN.author = "Zeta"
PLUGIN.description = "Adds new fonts for use."

--Any new custom fonts can be added here.

if (CLIENT) then
	surface.CreateFont("stalker2regularfont", {	--Stalker 2 regular font
		font = "stalker2",
		size = ScreenScale(8),
		extended = true,
		weight = 500,
		antialias = true
	})

	surface.CreateFont("stalkerregularsmallfont", {	--Regular Small
		font = "arial",
		size = ScreenScale(6),
		extended = true,
		weight = 500,
		antialias = true
	})

	surface.CreateFont("stalkerregularsmallboldfont", {	--Regular Small Bold
		font = "arial",
		size = ScreenScale(6),
		extended = true,
		weight = 600,
		antialias = true
	})

	surface.CreateFont("stalkerregularfont", {	--Regular
		font = "arial",
		size = ScreenScale(8),
		extended = true,
		weight = 500,
		antialias = true
	})

	surface.CreateFont("stalkerregularboldfont", {	--Regular Bold
		font = "arial",
		size = ScreenScale(8),
		extended = true,
		weight = 600,
		antialias = true
	})

	surface.CreateFont("stalkerregularfont2", {	--Regular 2
		font = "arial",
		size = ScreenScale(10),
		extended = true,
		weight = 500, 
		antialias = true
	})

	surface.CreateFont("stalkerregulartitlefont", {	--Regular Title
		font = ix.config.Get("genericFont"),
		size = ScreenScale(8),
		extended = true,
		weight = 500,
		antialias = true
	})

	surface.CreateFont("stalkertitlefont", {	--Title
		font = "arial",
		size = ScreenScale(21),
		extended = true,
		weight = 500,
		antialias = true
	})

	surface.CreateFont("mainenutitlefont", {	--Main Menu Title (schemaName)
		font = "AmazS.T.A.L.K.E.R.v.3.0",
		size = ScreenScale(70),
		extended = true,
		weight = 500,
		antialias = true
	})

	surface.CreateFont("mainenutitledescfont", {	--Main Menu Title description (schemaDesc)
		font = "Roboto Italic",
		size = ScreenScale(14),
		extended = true,
		weight = 500,
		antialias = true
	})
end