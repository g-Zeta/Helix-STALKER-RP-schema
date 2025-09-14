PLUGIN.name = "PDA"
PLUGIN.author = "Zeta & Gemini Code Assist"
PLUGIN.description = "Adds a PDA with messaging and other features."

ix.pda = ix.pda or {}
ix.pda.messages = ix.pda.messages or {} -- Client-side cache

if (SERVER) then
    -- Include server-side logic
    ix.util.Include("sv_messaging.lua") 
    ix.util.Include("sv_contacts.lua")

    -- Network strings for messaging
    util.AddNetworkString("ixPDASendMessage")
    util.AddNetworkString("ixPDAReceiveMessage")
    util.AddNetworkString("ixPDAReceiveHistory")
    util.AddNetworkString("ixPDAAddContact")
    util.AddNetworkString("ixPDAUpdateContacts")
    util.AddNetworkString("ixPDAContactStatusUpdate")
    util.AddNetworkString("ixPDARemoveContact")
    util.AddNetworkString("ixPDAAcceptRequest")
    util.AddNetworkString("ixPDADeclineRequest")
else
    -- Include client-side derma
    ix.util.Include("derma/cl_messages.lua")
end

ix.option.Add("PDAvolume", ix.type.number, 0.4, {
    category = "STALKER Settings",
    min = 0,
    max = 1,
    decimals = 1,
})