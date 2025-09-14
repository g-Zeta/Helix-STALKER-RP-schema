-- This will hold messages that are sent before the database is ready.
-- File-based storage for PDA messages. This is an alternative to using a MySQL database.
local GLOBAL_DATA_FILE = "ix_gpda_messages.json"
local PRIVATE_DATA_FILE = "ix_pda_private_messages.json"
local pdaMessageHistory = {}
local pdaPrivateMessageHistory = {}

-- The maximum number of messages to store in the history file and send to clients.
local MESSAGE_HISTORY_LIMIT = 1000

-- Function to load messages from the file on server start.
local function LoadMessages()
    if (file.Exists(GLOBAL_DATA_FILE, "DATA")) then
        local content = file.Read(GLOBAL_DATA_FILE, "DATA")
        if (content and content ~= "") then
            local success, data = pcall(util.JSONToTable, content)
            if (success and type(data) == "table") then
                pdaMessageHistory = data
                print("[IX-PDA] Loaded " .. #pdaMessageHistory .. " messages from file.")
            else
                ErrorNoHalt("[IX-PDA] Failed to parse global message history file: " .. GLOBAL_DATA_FILE .. "\n")
            end
        end
    else
        print("[IX-PDA] Global message history file not found. A new one will be created.")
    end
end

-- Function to load private messages from the file on server start.
local function LoadPrivateMessages()
    if (file.Exists(PRIVATE_DATA_FILE, "DATA")) then
        local content = file.Read(PRIVATE_DATA_FILE, "DATA")
        if (content and content ~= "") then
            local success, data = pcall(util.JSONToTable, content)
            if (success and type(data) == "table") then
                pdaPrivateMessageHistory = data
                print("[IX-PDA] Loaded " .. #pdaPrivateMessageHistory .. " private messages from file.")
            else
                ErrorNoHalt("[IX-PDA] Failed to parse private message history file: " .. PRIVATE_DATA_FILE .. "\n")
            end
        end
    else
        print("[IX-PDA] Private message history file not found. A new one will be created.")
    end
end

-- Function to save the current message history to the file.
local function SaveMessages()
    local json = util.TableToJSON(pdaMessageHistory, true) -- 'true' for pretty printing
    file.Write(GLOBAL_DATA_FILE, json)
end

-- Function to save the current private message history to the file.
local function SavePrivateMessages()
    local json = util.TableToJSON(pdaPrivateMessageHistory, true)
    file.Write(PRIVATE_DATA_FILE, json)
end

-- Load messages when the server starts.
LoadMessages()
LoadPrivateMessages()

local function SaveAndSendMessage(msgData, senderClient)
    local receivers = {}
    if (msgData.is_global) then
        table.insert(pdaMessageHistory, msgData)
        if (#pdaMessageHistory > MESSAGE_HISTORY_LIMIT) then
            table.remove(pdaMessageHistory, 1)
        end
        SaveMessages()
        receivers = player.GetAll()
    else
        table.insert(pdaPrivateMessageHistory, msgData)
        -- Private messages can have a larger history since they are filtered per-player
        if (#pdaPrivateMessageHistory > MESSAGE_HISTORY_LIMIT * 5) then
            table.remove(pdaPrivateMessageHistory, 1)
        end
        SavePrivateMessages()

        table.insert(receivers, senderClient)
        for _, ply in ipairs(player.GetAll()) do
            local recipientChar = ply:GetCharacter()
            if recipientChar and recipientChar:GetData("pdausername", recipientChar:GetName()) == msgData.recipient_char_name then
                table.insert(receivers, ply)
                break
            end
        end
    end
    if #receivers > 0 then
        net.Start("ixPDAReceiveMessage")
            net.WriteTable(msgData)
        net.Send(receivers)
    end
end

-- When a player sends a message
net.Receive("ixPDASendMessage", function(len, client)
    local message = net.ReadString()
    local isGlobal = net.ReadBool()

    if (string.Trim(message) == "") then return end

    local char = client:GetCharacter()
    if not char then return end

    local timestamp = os.time()

    local msgData = {
        sender_char_id = char:GetID(),
        sender_char_name = char:GetName(),
        sender_steamid = client:SteamID64(),
        sender_name = char:GetData("pdausername", char:GetName()),
        sender_avatar = char:GetData("pdaavatar", "stalker/ui/avatars/nodata.png"),
        message = message,
        time = timestamp,
        formatted_time = os.date("%Y-%m-%d %H:%M:%S", timestamp),
        is_global = isGlobal,
    }

    if (not isGlobal) then
        msgData.recipient_char_name = net.ReadString()

        -- Verify the recipient is online before proceeding.
        local recipientOnline = false
        local recipientChar = nil
        for _, ply in ipairs(player.GetAll()) do
            local plyChar = ply:GetCharacter()
            if plyChar and (plyChar:GetData("pdausername", plyChar:GetName()) == msgData.recipient_char_name) then
                recipientOnline = true
                recipientChar = plyChar
                break
            end
        end

        if not recipientOnline then
            client:Notify("Recipient is not online.")
            return
        end

        msgData.recipient_char_id = recipientChar:GetID()
    end

    -- Print the message details to the server console.
    if (isGlobal) then
        print(string.format("[%s][GPDA] '%s' (%s): %s", msgData.formatted_time, char:GetName(), client:SteamID(), message))
    else
        print(string.format("[%s][PDA] '%s' to '%s': %s", msgData.formatted_time, char:GetName(), msgData.recipient_char_name, message))
    end

    -- Save and send the message.
    SaveAndSendMessage(msgData, client)
end)

-- When a player loads in, send them the message history.
function PLUGIN:PlayerLoadedCharacter(client, character, lastChar)
    -- Let's load the last X messages for history.
    local messageLimit = MESSAGE_HISTORY_LIMIT
    local localCharID = character:GetID()
    local localCharName = character:GetData("pdausername", character:GetName())
    local history = {}

    -- Add global messages
    local totalGlobal = #pdaMessageHistory
    local startGlobal = math.max(1, totalGlobal - messageLimit + 1)
    for i = startGlobal, totalGlobal do
        table.insert(history, pdaMessageHistory[i])
    end

    -- Add relevant private messages
    for _, msg in ipairs(pdaPrivateMessageHistory) do
        -- Use the character ID for both sender and recipient if available, falling back to name for older messages.
        if (msg.sender_char_id == localCharID or msg.recipient_char_id == localCharID or (not msg.recipient_char_id and msg.recipient_char_name == localCharName)) then
            table.insert(history, msg)
        end
    end

    -- Sort combined history by time
    table.sort(history, function(a, b) return a.time < b.time end)

    -- Limit the combined history to avoid sending too much data
    local finalHistory = {}
    local totalMessages = #history
    local startIndex = math.max(1, totalMessages - messageLimit + 1)
    for i = startIndex, totalMessages do
        table.insert(finalHistory, history[i])
    end

    net.Start("ixPDAReceiveHistory")
        net.WriteTable(finalHistory)
    net.Send(client)
end