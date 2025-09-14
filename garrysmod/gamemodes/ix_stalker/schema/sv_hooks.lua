-- Here is where all of your serverside hooks should go.

function Schema:OnCharacterCreated(client, character)
	local inventory = character:GetInventory()
    if (not inventory) then return end

    -- Always grant a PDA and basic items to new characters
    local defaultitems = { "pda", "geigercounter", "anomalydetector", "headlamp" }

    -- Add default items to inventory
    for k, v in ipairs(defaultitems) do
		if IsValid(client) and character and inventory then
			inventory:Add(v)
		end
	end

    -- read saved selection (persisted in CharacterPreCreate via values.data)
    local loadout = character:GetData("loadoutSelection", nil)
    if not loadout and character.vars and character.vars.data then
        loadout = character.vars.data.loadoutSelection
    end

    if not istable(loadout) then return end

    -- Sanitize on server (don’t trust client)
    local MAX_PER_ITEM = 10
    local totalCost = 0
    local budget = ix.config.Get("characterCreationBudget", 50000) or 0

    for uid, qty in pairs(loadout) do
        local def = ix.item.list[uid]
        local n = math.max(0, math.min(tonumber(qty) or 0, MAX_PER_ITEM))
        if def and n > 0 then
            local price = tonumber(def.price) or 0
            totalCost = totalCost + (price * n)
            loadout[uid] = n
        else
            loadout[uid] = nil
        end
    end

    -- Give items
    for uid, n in pairs(loadout) do
        local def = ix.item.list[uid]
        if def and n > 0 then
            for i = 1, n do
                inventory:Add(uid)
            end
        end
    end

    -- Grant unused budget as starting money
    if budget > 0 then
        local unused = math.max(0, budget - totalCost)
        if unused > 0 then
            character:GiveMoney(unused)
        end
    end
end

function Schema:PlayerSpray(client)
	return true
end
--[[
local deathSounds = {
Sound("stalkersound/die1.wav"),
Sound("stalkersound/die2.wav"),
Sound("stalkersound/die3.wav"),
Sound("stalkersound/die4.wav"),
}

function Schema:GetPlayerDeathSound(client)
	return table.Random(deathSounds)
end

local painSounds = {
Sound("stalkersound/pain1.wav"),
Sound("stalkersound/pain2.wav"),
Sound("stalkersound/pain3.wav"),
Sound("stalkersound/pain4.wav"),
Sound("stalkersound/pain5.wav"),
Sound("stalkersound/pain6.wav"),
Sound("stalkersound/pain7.wav"),
Sound("stalkersound/pain8.wav"),
Sound("stalkersound/pain9.wav"),
Sound("stalkersound/pain10.wav"),
Sound("stalkersound/pain11.wav"),
Sound("stalkersound/pain12.wav"),
Sound("stalkersound/pain13.wav"),
Sound("stalkersound/pain14.wav"),
}

function Schema:GetPlayerPainSound(client)
	return table.Random(painSounds)
end
--]]
function Schema:PlayerSpawnEffect(client, weapon, info)
	return client:IsAdmin() or client:GetCharacter():HasFlags("N")
end

function Schema:Initialize()
	game.ConsoleCommand("net_maxfilesize 64\n");
	game.ConsoleCommand("sv_kickerrornum 0\n");

	game.ConsoleCommand("sv_allowupload 0\n");
	game.ConsoleCommand("sv_allowdownload 0\n");
	game.ConsoleCommand("sv_allowcslua 0\n");
end

netstream.Hook("qurReq", function(client, time, bResponse)
	if (client.nutQueReqs and client.nutQueReqs[time]) then
		client.nutQueReqs[time](bResponse)
		client.nutQueReqs[time] = nil
	end
end)

-- Hidden var so ixCharacterCreate won't discard "loadoutSelection"
ix.char.RegisterVar("loadoutSelection", {
    field = nil,               -- not stored as a column
    bNoDisplay = true,         -- not shown in UI
    isLocal = true,
    index = 9000,              -- far end, after stock vars
    OnValidate = function(self, value, payload, client)
        -- accept tables; we’ll sanitize later
        if value == nil then return end
        if not istable(value) then
            return false, "unknownError"
        end
        return value
    end,
    -- move the accepted value into newData.data so it’s persisted in the JSON "data" column
    OnAdjust = function(self, client, data, value, newData)
        newData = newData or {}
        newData.data = newData.data or {}
        -- keep raw, will be sanitized/given in OnCharacterCreated
        newData.data.loadoutSelection = istable(value) and value or {}
        return newData
    end
})