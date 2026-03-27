local PLUGIN = PLUGIN
PLUGIN.name = "Buffs and Debuffs"
PLUGIN.author = "Black Tea (NS 1.0), Neon (NS 1.1) - Modified by Zeta"
PLUGIN.desc = "Sometimes, You get sick or high. DrunkyBlur by Spy."
PLUGIN.buffs = {}

local playerMeta = FindMetaTable("Player")

ix.util.Include("sh_buffs.lua")
ix.util.Include("sh_buffhooks.lua")

-- player:GetBuffs()
-- returns table
-- This function gets one's all buffs.
function playerMeta:GetBuffs()
	local char = self:GetCharacter()
	if (char) then
		return char:GetData("buffs", {})
	end

	return {}
end

-- player:AddBuff( string [Buff's unique name] )
-- returns table or boolean( false )
-- This function allows you handle buffs
function playerMeta:HasBuff( strBuff )
	local char = self:GetCharacter()
	if (char) then
		local buffs = char:GetData("buffs", {})
		return buffs[strBuff]
	end

	return false
end

function PLUGIN:GetBuff( strBuff )
	return self.buffs[strBuff]
end

if (SERVER) then
	-- player:AddBuff(string [Buff's unique name], integer [Buff's Duration Time], table [Parameters])
	-- This function allows to add some buffs to a player
	function playerMeta:AddBuff( strBuff, intDuration, parameter ) 
		local char = self:GetCharacter()
		if (!char) then return end

		if intDuration < 0 then intDuration = 1000000 end
		local tblBuffs = char:GetData( "buffs", {} )
		local tblBuffInfo = PLUGIN:GetBuff(strBuff)

		if tblBuffInfo and tblBuffInfo.onbuffed then
			if !self:HasBuff( strBuff ) then
				tblBuffInfo.onbuffed( self, parameter )
			end
		end

		tblBuffs[ strBuff ] = { CurTime() + intDuration, parameter }
		hook.Call( "OnBuffed", GAMEMODE, strBuff, intDuration, parameter )
		char:SetData( "buffs", tblBuffs )
	end
	
	-- player:RemoveBuff(string [Buff's unique name], table [Parameters])
	-- This function allows to remove some buffs from a player
	function playerMeta:RemoveBuff( strBuff, parameter ) -- perma
		local char = self:GetCharacter()
		if (!char) then return end

		local tblBuffs = char:GetData( "buffs", {} )
		local tblBuffInfo = PLUGIN:GetBuff(strBuff)

		if tblBuffInfo and tblBuffInfo.ondebuffed then
			tblBuffInfo.ondebuffed( self, parameter )
		end

		tblBuffs[ strBuff ] = nil
		hook.Call( "OnDebuffed", GAMEMODE, strBuff, parameter )
		char:SetData( "buffs", tblBuffs )
	end
	
	-- player:PlayerDeath(player)
	-- This hook wipes every buffs on the character when the player dies
	function PLUGIN:PlayerDeath(client)
		local char = client:GetCharacter()
		if (char) then
			local buffs = char:GetData("buffs", {})

			for name, data in pairs(buffs) do
				local buffInfo = self:GetBuff(name)

				if (buffInfo and buffInfo.ondebuffed) then
					buffInfo.ondebuffed(client, data[2])
				end

				hook.Call("OnDebuffed", GAMEMODE, name, data[2])
			end

			char:SetData("buffs", {})
		end
	end

	-- This hook prevents transfering buffs from one character to another when changed
	function PLUGIN:PlayerLoadedCharacter(client, character, oldCharacter)
		if (oldCharacter) then
			local buffs = oldCharacter:GetData("buffs", {})

			for name, data in pairs(buffs) do
				local buffInfo = self:GetBuff(name)

				if (buffInfo and buffInfo.ondebuffed) then
					buffInfo.ondebuffed(client, data[2])
				end
			end
		end

		if (character) then
			local buffs = character:GetData("buffs", {})

			for name, data in pairs(buffs) do
				local buffInfo = self:GetBuff(name)

				if (buffInfo and buffInfo.onbuffed) then
					buffInfo.onbuffed(client, data[2])
				end
			end
		end
	end

	-- This hook removes any active buff from a player that disconnects
	function PLUGIN:PlayerDisconnected(client)
		local char = client:GetCharacter()
		if (char) then
			local buffs = char:GetData("buffs", {})

			for name, data in pairs(buffs) do
				local buffInfo = self:GetBuff(name)

				if (buffInfo and buffInfo.ondebuffed) then
					buffInfo.ondebuffed(client, data[2])
				end

				hook.Call("OnDebuffed", GAMEMODE, name, data[2])
			end

			char:SetData("buffs", {})
		end
	end

	-- This hook removes all active buffs when the server shuts down or restarts
	function PLUGIN:ShutDown()
		for k, client in pairs(player.GetAll()) do
			local char = client:GetCharacter()
			if (char) then
				local buffs = char:GetData("buffs", {})

				for name, data in pairs(buffs) do
					local buffInfo = self:GetBuff(name)

					if (buffInfo and buffInfo.ondebuffed) then
						buffInfo.ondebuffed(client, data[2])
					end

					hook.Call("OnDebuffed", GAMEMODE, name, data[2])
				end

				char:SetData("buffs", {})
			end
		end
	end

	-- player:Think()
	-- This hook handles every player's buff effect
	function PLUGIN:Think()
		for k, v in pairs ( player.GetAll() ) do
			if !( v:IsValid() and v:Alive() ) then continue end

			local char = v:GetCharacter()
			if (!char) then continue end

			local tblBuffs = char:GetData("buffs", {})
			if (table.IsEmpty(tblBuffs)) then continue end

			local hasChanged = false
			for name, dat in pairs( tblBuffs ) do
				local tblBuffInfo = self.buffs[ name ]
				if tblBuffInfo then
					if tblBuffInfo.func then
						tblBuffInfo.func( v, dat[2] )
					end

					if dat[1] < CurTime() then
						if tblBuffInfo.ondebuffed then
							tblBuffInfo.ondebuffed( v, dat[2] )
						end
						tblBuffs[ name ] = nil
						hasChanged = true
						hook.Call( "OnDebuffed", GAMEMODE, name, dat[2] )
					end
				else
					-- Buff definition doesn't exist anymore, remove it from the character
					tblBuffs[ name ] = nil
					hasChanged = true
				end
			end

			if (hasChanged) then
				char:SetData("buffs", tblBuffs)
			end
		end
	end

else
	function PLUGIN:Think()
		for k, v in pairs ( player.GetAll() ) do
			if !( v:IsValid() and v:Alive() ) then continue end
			
			local tblBuffs = v:GetNetVar("buffs", {})
			for name, dat in pairs( tblBuffs ) do
				local tblBuffInfo = self.buffs[ name ]
				if tblBuffInfo and tblBuffInfo.cl_func then
					tblBuffInfo.cl_func( v, dat[2] )
				end
			end
		end
	end

end