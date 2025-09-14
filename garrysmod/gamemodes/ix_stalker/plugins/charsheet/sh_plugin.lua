local PLUGIN = PLUGIN
PLUGIN.name = "Enhanced Description"
PLUGIN.author = "Subleader"
PLUGIN.desc = "Another description with more capacity."
DESCRIPTIONLIMIT = 2000

-- A default color to use when no character/faction is available.
local defaultColor = Color(127, 111, 63)

-- Override the default Helix color config to make it dynamic.
-- We set it to hidden so it doesn't appear in the F1 menu.
ix.config.Add("color", defaultColor, "The main color theme for the framework.", nil, {
	hidden = true
})

ix.char.RegisterVar("dob", {
    field = "dob",
    fieldType = ix.type.text,
    category = "profile",
    default = "",
    index = 6,
    OnValidate = function(self, value, payload)
        local raw = string.Trim((tostring(value):gsub("\r\n", ""):gsub("\n", "")))

        -- Expect MM/DD/YYYY
        if not raw:match("^%d%d/%d%d/%d%d%d%d$") then
            return false, "Date of Birth must be in MM/DD/YYYY format."
        end

        -- Parse numbers
        local month, day, year = raw:match("^(%d%d)/(%d%d)/(%d%d%d%d)$")
        month, day, year = tonumber(month), tonumber(day), tonumber(year)

        -- Basic range checks
        if month < 1 or month > 12 then
            return false, "Invalid month in Date of Birth."
        end
        if day < 1 or day > 31 then
            return false, "Invalid day in Date of Birth."
        end
        if year < 1900 then
            return false, "Year must be 1900 or later."
        end

        -- Manual date validation to avoid os.time issues with pre-1970 dates
        local daysInMonth = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
        if (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0) then
            daysInMonth[2] = 29
        end
        if day > daysInMonth[month] then
            return false, "Invalid calendar date for Date of Birth."
        end

        -- Date cannot be in the future
        local now = os.date("*t")
        if year > now.year or (year == now.year and month > now.month) or (year == now.year and month == now.month and day > now.day) then
            return false, "Date of Birth cannot be in the future."
        end

        -- Enforce minimum/maximum age
        -- Calculate age
        local age = now.year - year
        if (now.month < month) or (now.month == month and now.day < day) then
            age = age - 1
        end
        local minAge, maxAge = 20, 120
        if age < minAge then
            return false, "You can't be below the age of " .. tostring(minAge) .. "."
        elseif age > maxAge then
            return false, "You can't be above the age of " .. tostring(maxAge) .. "."
        end

        -- If all good, return canonical MM/DD/YYYY string
        return string.format("%02d/%02d/%04d", month, day, year)
    end,
    OnPostSetup = function(self, panel, payload)
        panel:SetMultiline(false)
        panel:SetFont("ixMenuButtonFont")
        panel:SetTall(panel:GetTall())
        panel:SetPlaceholderText("MM/DD/YYYY")
        panel.AllowInput = function(_, character)
            -- Disallow newline
            if (character == "\n" or character == "\r") then
                return true
            end
        end
    end,
    OnAdjust = function(self, client, data, value, newData)
        -- Persist both the raw DOB and a friendly formatted text for the sheet
        local month, day, year = value:match("^(%d%d)/(%d%d)/(%d%d%d%d)$")
        month, day, year = tonumber(month), tonumber(day), tonumber(year)

        local suffix = function(d)
            if d % 10 == 1 and d ~= 11 then return "st"
            elseif d % 10 == 2 and d ~= 12 then return "nd"
            elseif d % 10 == 3 and d ~= 13 then return "rd"
            else return "th" end
        end

        local monthNames = {
            [1] = "January", [2] = "February", [3] = "March", [4] = "April",
            [5] = "May", [6] = "June", [7] = "July", [8] = "August",
            [9] = "September", [10] = "October", [11] = "November", [12] = "December"
        }

        local display = string.format("%s %d%s, %d", monthNames[month], day, suffix(day), year)

        newData = newData or {}
        newData.data = newData.data or {}
        newData.data.sheetDOB = value              -- "04/26/1986"
        newData.data.sheetDOBText = display        -- "April 26th, 1986"
        return newData
    end,
    ShouldDisplay = function(self, container, payload)
        return true
    end
})
--[[
ix.char.RegisterVar("age", {
    field = "age",
    fieldType = ix.type.text,
    category = "profile",
    default = "",
    index = 6,
    OnValidate = function(self, value, payload)
        value = tonumber(string.Trim((tostring(value):gsub("\r\n", ""):gsub("\n", ""))))
        if !isnumber(value) then
            return false, "Age is not a number"
        end
        local minLength = 20
        local maxLength = 99
        if (value < minLength) then
            return false, "You can't be below the age of 20.", minLength
        elseif (value > maxLength) then
            return false, "You can't be above the age of 99.", maxLength
        end
        return value
    end,
    OnPostSetup = function(self, panel, payload)
        panel:SetMultiline(true)
        panel:SetFont("ixMenuButtonFont")
        panel:SetTall(panel:GetTall() * 1 + 6)
        panel.AllowInput = function(_, character)
            if (character == "\n" or character == "\r") then
                return true
            end
        end
    end,
    OnAdjust = function(self, client, data, value, newData)
        newData = newData or {}
        newData.data = newData.data or {}
        newData.data.sheetAge = value
        return newData
    end,
    ShouldDisplay = function(self, container, payload)
        return true
    end
})
--]]
ix.char.RegisterVar("nationality", {
	field = "nationality",
	fieldType = ix.type.text,
	category = "profile",
	default = "Ukranian",
	index = 7,
	OnValidate = function(self, value, payload)
		value = string.Trim((tostring(value):gsub("\r\n", ""):gsub("\n", "")))
		
		local minLength = 4
		local maxLength = 30

		if (#value < minLength) then
			return false, "Invalid Nationality", minLength
		elseif (!value:find("%S")) then
			return false, "invalid", "nationality"
		elseif (#value:gsub("%s", "") > maxLength) then
			return false, "Invalid Nationality", maxLength
		end

		return value
	end,
	OnPostSetup = function(self, panel, payload)
		panel:SetMultiline(true)
		panel:SetFont("ixMenuButtonFont")
		panel:SetTall(panel:GetTall() * 1 + 6) -- add another line
        panel:SetPlaceholderText("Ukranian/Russian/Belorussian/Polish/Romanian/Other")
		panel.AllowInput = function(_, character)
			if (character == "\n" or character == "\r") then
				return true
			end
		end
	end,
	OnAdjust = function(self, client, data, value, newData)
		newData = newData or {}
		newData.data = newData.data or {}
		newData.data.sheetNationality = value
		return newData
	end,
	ShouldDisplay = function(self, container, payload)
		return true --!table.IsEmpty(ix.perks.list)
	end
})

ix.char.RegisterVar("race", {
	field = "race",
	fieldType = ix.type.text,
	category = "profile",
	default = "Caucasian",
	index = 8,
	OnValidate = function(self, value, payload)
		value = string.Trim((tostring(value):gsub("\r\n", ""):gsub("\n", "")))
		
		local minLength = 4
		local maxLength = 30

		if (#value < minLength) then
			return false, "Invalid Race", minLength
		elseif (!value:find("%S")) then
			return false, "invalid", "race"
		elseif (#value:gsub("%s", "") > maxLength) then
			return false, "Invalid Race", maxLength
		end

		return value
	end,
	OnPostSetup = function(self, panel, payload)
		panel:SetMultiline(true)
		panel:SetFont("ixMenuButtonFont")
		panel:SetTall(panel:GetTall() * 1 + 6) -- add another line
        panel:SetPlaceholderText("Slavic/European/Caucasian/Hispanic/Other")
		panel.AllowInput = function(_, character)
			if (character == "\n" or character == "\r") then
				return true
			end
		end
	end,
	OnAdjust = function(self, client, data, value, newData)
		newData = newData or {}
		newData.data = newData.data or {}
		newData.data.sheetRace = value
		return newData
	end,
	ShouldDisplay = function(self, container, payload)
		return true --!table.IsEmpty(ix.perks.list)
	end
})

ix.command.Add("charsetdob", {
    description = "Set a character's Date of Birth.",
	adminOnly = true,
    arguments = {
        ix.type.string, -- target (name/steamid)
        ix.type.text    -- MM/DD/YYYY
    },
    OnRun = function(self, client, targetArg, dobArg)
        local target = ix.util.FindPlayer(targetArg)
        if not IsValid(target) then
            client:Notify("Player not found")
            return
        end

        local function validateAndNormalizeDOB(raw)
            raw = string.Trim((tostring(raw):gsub("\r\n", ""):gsub("\n", "")))
            if not raw:match("^%d%d/%d%d/%d%d%d%d$") then
                return false, "Date of Birth must be in MM/DD/YYYY format."
            end

            local m, d, y = raw:match("^(%d%d)/(%d%d)/(%d%d%d%d)$")
            m, d, y = tonumber(m), tonumber(d), tonumber(y)

            if m < 1 or m > 12 then return false, "Invalid month in Date of Birth." end
            if d < 1 or d > 31 then return false, "Invalid day in Date of Birth." end
            if y < 1900 then return false, "Year must be 1900 or later." end

            -- Manual date validation
            local daysInMonth = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
            if (y % 4 == 0 and y % 100 ~= 0) or (y % 400 == 0) then
                daysInMonth[2] = 29
            end
            if d > daysInMonth[m] then
                return false, "Invalid calendar date for Date of Birth."
            end

            -- Future date check
            local now = os.date("*t")
            if y > now.year or (y == now.year and m > now.month) or (y == now.year and m == now.month and d > now.day) then
                return false, "Date of Birth cannot be in the future."
            end

            -- Enforce same age range as creation (20–120). Remove if you want admins unrestricted.
            local age = now.year - y
            if (now.month < m) or (now.month == m and now.day < d) then
                age = age - 1
            end
            local minAge, maxAge = 20, 120
            if age < minAge then
                return false, "You can't be below the age of " .. tostring(minAge) .. "."
            elseif age > maxAge then
                return false, "You can't be above the age of " .. tostring(maxAge) .. "."
            end

            local canonical = string.format("%02d/%02d/%04d", m, d, y)

            local function suffix(day)
                if day % 10 == 1 and day ~= 11 then return "st"
                elseif day % 10 == 2 and day ~= 12 then return "nd"
                elseif day % 10 == 3 and day ~= 13 then return "rd"
                else return "th" end
            end

            local monthNames = {
                [1] = "January", [2] = "February", [3] = "March", [4] = "April",
                [5] = "May", [6] = "June", [7] = "July", [8] = "August",
                [9] = "September", [10] = "October", [11] = "November", [12] = "December"
            }
            local display = string.format("%s %d%s, %d", monthNames[m], d, suffix(d), y)

            return true, canonical, display
        end

        local ok, canonical, displayOrErr = validateAndNormalizeDOB(dobArg)
        if not ok then
            client:Notify(displayOrErr)
            return
        end
        local display = displayOrErr

        local character = target:GetCharacter()
        if not character then
            client:Notify("Target has no character")
            return
        end

        -- Persist raw and display DOB values used by your UI
        character:SetData("sheetDOB", canonical)
        character:SetData("sheetDOBText", display)

        -- Also update the stored charsheetinfo row so viewers see it immediately
        local info = character:GetData("charsheetinfo", {}) or {}
        info["Date of Birth"] = { left = "Date of Birth", right = display, nonadmin = false }
        character:SetData("charsheetinfo", info)

        -- Keep char var in sync for any other systems using it
        character:SetVar("dob", canonical, true)

        client:Notify("Set Date of Birth to " .. display .. " for " .. target:Name() .. ".")
        if IsValid(target) then
            target:Notify("Your Date of Birth was set to " .. display .. " by an administrator.")
        end
    end
})

ix.command.Add("charsetnationality", {
    description = "Set a character's Nationality.",
	adminOnly = true,
    arguments = {
        ix.type.character,
        ix.type.text
    },
    OnRun = function(self, client, character, nationalityArg)
        local nationalityVar = ix.char.vars.nationality
        local result, fault = nationalityVar:OnValidate(nationalityArg)

        if result == false then
            client:Notify(fault)
            return
        end

        local value = result
        local target = character:GetPlayer()

        -- Persist value
        character:SetData("sheetNationality", value)

        -- Also update the stored charsheetinfo row so viewers see it immediately
        local info = character:GetData("charsheetinfo", {}) or {}
        info["Nationality"] = { left = "Nationality", right = value, nonadmin = false }
        character:SetData("charsheetinfo", info)

        -- Keep char var in sync for any other systems using it
        character:SetVar("nationality", value, true)

        client:Notify("Set Nationality to '" .. value .. "' for " .. character:GetName() .. ".")
        if IsValid(target) then
            target:Notify("Your Nationality was set to '" .. value .. "' by an administrator.")
        end
    end
})

ix.command.Add("charsetrace", {
    description = "Set a character's Race.",
	adminOnly = true,
    arguments = {
        ix.type.character,
        ix.type.text
    },
    OnRun = function(self, client, character, raceArg)
        local raceVar = ix.char.vars.race
        local result, fault = raceVar:OnValidate(raceArg)

        if result == false then
            client:Notify(fault)
            return
        end

        local value = result
        local target = character:GetPlayer()

        -- Persist value
        character:SetData("sheetRace", value)

        -- Also update the stored charsheetinfo row so viewers see it immediately
        local info = character:GetData("charsheetinfo", {}) or {}
        info["Race"] = { left = "Race", right = value, nonadmin = false }
        character:SetData("charsheetinfo", info)

        -- Keep char var in sync for any other systems using it
        character:SetVar("race", value, true)

        client:Notify("Set Race to '" .. value .. "' for " .. character:GetName() .. ".")
        if IsValid(target) then
            target:Notify("Your Race was set to '" .. value .. "' by an administrator.")
        end
    end
})

if (CLIENT) then
	netstream.Hook("ixReceiveDescription", function(client, contents, url, sheetdata, isadmin)
		local description = vgui.Create("ixDescriptionEn")
		local character = client:GetCharacter()
		local content = character:GetData("sheetPhysDesc", contents)
		local url = character:GetData("UrlDesc", url)

		description:buildSheet(client, isadmin)
		description:setText(content, url)
	end)
	
	netstream.Hook("ixReceiveViewDescription", function(target, contents, url, playerdata, isadmin)
		local description = vgui.Create("ixDescriptionEnView")
		local character = target:GetCharacter()
		local content = character:GetData("sheetPhysDesc", contents)
		local url = character:GetData("UrlDesc", url)

		description:buildSheet(target, isadmin, playerdata)
		description:setText(content, url)
	end)
else	
	netstream.Hook("ixDescriptionSendText", function(client, contents, url, sheetdata)
		local character = client:GetCharacter()
		character:SetData("sheetDesc", contents)
		character:SetData("UrlDesc", url)
		character:SetData("charsheetinfo", sheetdata)
	end)

	netstream.Hook("ixDescriptionTargetSendText", function(client, target, sheet)
		local character = target:GetCharacter()

		character:SetData("charsheetinfo", sheet)
	end)
end

function PLUGIN:OnCharacterCreated(client, character)
	local charsheetinfo = character:GetData("charsheetinfo", nil) or {}
	charsheetinfo["Name"] = {left = "Name", right = character:GetData("sheetName", nil) or character:GetName(), nonadmin = false}
	--charsheetinfo["Nickname"] = {left = "Nickname", right = character:GetData("sheetFullName", nil) or "None", nonadmin = true}
	charsheetinfo["Date of Birth"] = {left = "Date of Birth", right = character:GetData("sheetDOBText", nil) or "MM/DD/YYYY", nonadmin = false}
	--charsheetinfo["Age"] = {left = "Age", right = character:GetData("sheetAge", nil) or "Fill me.", nonadmin = false}
	charsheetinfo["Race"] = {left = "Race", right = character:GetData("sheetRace", nil) or "Fill me.", nonadmin = false}
	charsheetinfo["Nationality"] = {left = "Nationality", right = character:GetData("sheetNationality", nil) or "Fill me.", nonadmin = false}

	character:SetData("charsheetinfo", charsheetinfo)
end

--[[
do
	local COMMAND = {}
	COMMAND.description = "Edit your own description"
	COMMAND.adminOnly = false

	function COMMAND:OnRun(client)
			if (IsValid(client)) then
			local character = client:GetCharacter()
				netstream.Start(client, "ixReceiveDescription",client, character:GetData("sheetPhysDesc", contents), character:GetData("UrlDesc", url), character:GetData("charsheetinfo", nil), client:IsAdmin())
			else
				return "Not a valid player"
			end
	end

	ix.command.Add("Selfdesc", COMMAND)
end
--]]