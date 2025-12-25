local PLUGIN = PLUGIN
PLUGIN.name = "PostProcess"
PLUGIN.author = "Copilot"
PLUGIN.desc = "Configurable visual post-process effects."

-- Bloom
ix.config.Add("EnableBloom", false, "Enable bloom postprocessing.", nil, {category = "Visual"})
ix.config.Add("BloomDarken", 0.0, "Bloom darken amount (0...1).", nil, {category = "Visual", data = {min = 0, max = 1, decimals = 2}})
ix.config.Add("BloomSizeX", 2.0, "Bloom X size.", nil, {category = "Visual", data = {min = 0, max = 2, decimals = 2}})
ix.config.Add("BloomSizeY", 2.0, "Bloom Y size.", nil, {category = "Visual", data = {min = 0, max = 2, decimals = 2}})
ix.config.Add("BloomPasses", 2, "Bloom pass count (integer >= 1).", nil, {category = "Visual", data = {min = 1, max = 30, decimals = 0}})
ix.config.Add("BloomColor", Color(255, 255, 255), "Bloom tint color.", nil, {category = "Visual"})
ix.config.Add("BloomColorMult", 2.0, "Bloom color multiplier (intensity).", nil, {category = "Visual", data = {min = 0, max = 10, decimals = 2}})
ix.config.Add("BloomMultiply", 0.25, "Bloom multiply amount (brightness).", nil, {category = "Visual", data = {min = 0, max = 1, decimals = 2}})

-- Sharpen
ix.config.Add("EnableSharpen", false, "Enable sharpen postprocess.", nil, {category = "Visual"})
ix.config.Add("SharpenContrast", 2.0, "Sharpen contrast.", nil, {category = "Visual", data = {min = 0, max = 2, decimals = 2}})
ix.config.Add("SharpenDistance", 1.0, "Sharpen distance.", nil, {category = "Visual", data = {min = 0, max = 1, decimals = 2}})

-- Color modifications
ix.config.Add("EnableColorModify", false, "Enable color adjustments (brightness/contrast/color).", nil, {category = "Visual"})
ix.config.Add("ColorBrightness", 0.0, "Color brightness (-1...1).", nil, {category = "Visual", data = {min = -1, max = 1, decimals = 2}})
ix.config.Add("ColorContrast", 1.0, "Color contrast (>=0).", nil, {category = "Visual", data = {min = 0, max = 2, decimals = 2}})
ix.config.Add("ColorSaturation", 1.0, "Color saturation (0...2).", nil, {category = "Visual", data = {min = 0, max = 2, decimals = 2}})
ix.config.Add("ColorAddR", 0.0, "Color add (red).", nil, {category = "Visual", data = {min = -1, max = 1, decimals = 2}})
ix.config.Add("ColorAddG", 0.0, "Color add (green).", nil, {category = "Visual", data = {min = -1, max = 1, decimals = 2}})
ix.config.Add("ColorAddB", 0.0, "Color add (blue).", nil, {category = "Visual", data = {min = -1, max = 1, decimals = 2}})

-- Color temperature (warm/cool) - simple tint adjustment
ix.config.Add("EnableTemperature", false, "Enable color temperature tinting (warm / cool).", nil, {category = "Visual"})
ix.config.Add("Temperature", 0.00, "Color temperature (-1.0 cold blue .. 0 neutral .. 1.0 warm orange)", nil, {category = "Visual", data = {min = -1, max = 1, decimals = 2}})
ix.config.Add("TemperatureStrength", 0.50, "Intensity multiplier for color temperature (0..1).", nil, {category = "Visual", data = {min = 0, max = 1, decimals = 2}})

-- Smoothing / soft-focus (approximates skin smoothing by drawing a subtle blur overlay)
ix.config.Add("EnableSmoothing", false, "Enable smoothing (soft-focus screen blur).", nil, {category = "Visual"})
ix.config.Add("SmoothingAmount", 0.25, "Smoothing strength (0..1).", nil, {category = "Visual", data = {min = 0, max = 1, decimals = 2}})
ix.config.Add("SmoothingBlur", 1.5, "Smoothing blur amount - controls the pp/blurscreen $blur value (0..5).", nil, {category = "Visual", data = {min = 0, max = 5, decimals = 2}})
ix.config.Add("SmoothingPasses", 1, "Smoothing passes (integer).", nil, {category = "Visual", data = {min = 1, max = 4, decimals = 0}})


if (CLIENT) then
	function PLUGIN:RenderScreenspaceEffects()
		-- Bloom
		if (ix.config.Get("EnableBloom", false)) then
			local multiply = tonumber(ix.config.Get("BloomMultiply", 1.0)) or 1.0
			local darken = tonumber(ix.config.Get("BloomDarken", 0.0)) or 0.0
			local sizex = tonumber(ix.config.Get("BloomSizeX", 2.0)) or 2.0
			local sizey = tonumber(ix.config.Get("BloomSizeY", 2.0)) or 2.0
			local passes = math.max(1, math.floor(tonumber(ix.config.Get("BloomPasses", 2)) or 2))
			local color = ix.config.Get("BloomColor", Color(255, 255, 255)) or Color(255,255,255)
			local colorMult = tonumber(ix.config.Get("BloomColorMult", 2.0)) or 2.0

			-- Normalize color components to 0..1 and ensure numeric fallbacks exist.
			local cr = (tonumber(color.r) or 255) / 255
			local cg = (tonumber(color.g) or 255) / 255
			local cb = (tonumber(color.b) or 255) / 255

			-- Ensure we pass numbers, not booleans/nils
			DrawBloom(tonumber(darken) or 0, tonumber(multiply) or 1, tonumber(sizex) or 2, tonumber(sizey) or 2, passes, colorMult, cr, cg, cb)
		end

		-- Sharpen
		if (ix.config.Get("EnableSharpen", false)) then
			local contrast = tonumber(ix.config.Get("SharpenContrast", 2.0)) or 2.0
			local distance = tonumber(ix.config.Get("SharpenDistance", 1.0)) or 1.0

			DrawSharpen(contrast, distance)
		end

		-- Color modify + Temperature tinting
		local enableColorModify = ix.config.Get("EnableColorModify", false)
		local enableTemp = ix.config.Get("EnableTemperature", false)

		local tab = {}

		-- Only include brightness/contrast/colour/saturation if color modify is explicitly enabled
		if (enableColorModify) then
			tab[ "$pp_colour_addr" ] = tonumber(ix.config.Get("ColorAddR", 0)) or 0
			tab[ "$pp_colour_addg" ] = tonumber(ix.config.Get("ColorAddG", 0)) or 0
			tab[ "$pp_colour_addb" ] = tonumber(ix.config.Get("ColorAddB", 0)) or 0
			tab[ "$pp_colour_brightness" ] = tonumber(ix.config.Get("ColorBrightness", 0)) or 0
			tab[ "$pp_colour_contrast" ] = tonumber(ix.config.Get("ColorContrast", 1)) or 1
			tab[ "$pp_colour_colour" ] = tonumber(ix.config.Get("ColorSaturation", 1)) or 1
		end

		-- Temperature: warm/cool tint (simple additive method)
		if (enableTemp) then
			local temp = math.Clamp(tonumber(ix.config.Get("Temperature", 0)) or 0, -1, 1)
			local strength = math.Clamp(tonumber(ix.config.Get("TemperatureStrength", 0.5)) or 0.5, 0, 1)

			local shift = temp * strength
			-- maximum additive channel offset (keeps values small): ~0.15
			local maxAdd = 0.15

			tab[ "$pp_colour_addr" ] = math.Clamp((tab[ "$pp_colour_addr" ] or 0) + shift * maxAdd * 1.25, -1, 1)
			tab[ "$pp_colour_addg" ] = math.Clamp((tab[ "$pp_colour_addg" ] or 0) + shift * maxAdd * 0.5, -1, 1)
			tab[ "$pp_colour_addb" ] = math.Clamp((tab[ "$pp_colour_addb" ] or 0) - shift * maxAdd * 1.25, -1, 1)

			-- ensure we draw color modify if temperature is enabled even if EnableColorModify is false
			-- but we intentionally do NOT create or modify saturation/contrast/brightness when EnableColorModify is false
			-- this prevents ColorSaturation (and similar) from affecting the result unless ColorModify is enabled
			doColorModify = true
		end
		if (doColorModify) then
			DrawColorModify(tab)
		end

		-- Smoothing / soft-focus (screen-wide approximation)
		if (ix.config.Get("EnableSmoothing", false)) then
			local amount = math.Clamp(tonumber(ix.config.Get("SmoothingAmount", 0.25)) or 0.25, 0, 1)
			local blurValue = math.Clamp(tonumber(ix.config.Get("SmoothingBlur", 2.0)) or 2.0, 0, 20)
			local passes = math.max(1, math.floor(tonumber(ix.config.Get("SmoothingPasses", 1)) or 1))

			local blurMat = Material("pp/blurscreen")
			if (blurMat and !blurMat:IsError()) then
				cam.Start2D()
					surface.SetDrawColor(255, 255, 255, math.floor(amount * 255))
					surface.SetMaterial(blurMat)
					for i = 1, passes do
						blurMat:SetFloat("$blur", blurValue)
						blurMat:Recompute()
						render.UpdateScreenEffectTexture()
						surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
					end
				cam.End2D()
			end
		end
	end
end