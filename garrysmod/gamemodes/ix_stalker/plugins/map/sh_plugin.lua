local PLUGIN = PLUGIN
PLUGIN.name = "Map Menu"
PLUGIN.author = "Zeta (Gemini Code assisted)"
PLUGIN.description = "Adds a map menu tab. Based on GUI Map | Minimap by WYPWWAPL."

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")

if (SERVER) then
	util.AddNetworkString("ixMapRebuild")
end

ix.command.Add("rebuildPDAmap", {
	description = "Rebuilds the PDA map image.",
	OnRun = function(self, client)
		net.Start("ixMapRebuild")
		net.Send(client)
	end
})