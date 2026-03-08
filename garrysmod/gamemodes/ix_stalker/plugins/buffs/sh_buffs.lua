--[[
	PLUGIN.buffs[ << string, Buff's Unique Name>> ] = { -- This is the unique name for identifying the buff.
		name =<< string, Buff's Display Name>>, -- This is the display name of the buff. 
		desc = << string, Buff's Description>>, -- This is the description of this buff.
		nodisp = << boolean, Buff's Display Factor >>, -- This is the factor for displaying this buff. ( For advaced scripters )
		func = << function, Buff's Think Function >>,
		onbuffed = << function, Buff's Function that executes on buffed >>, 
		ondebuffed = << function, Buff's Function that executes on Unbuffed >>, 
	}
]]--

local PLUGIN = PLUGIN

PLUGIN.buffs[ "buff_slowheal" ] = {
	name = "Healing",
	desc = "You're healing.",
	func = function( player, parameter)
		player.timeNextHeal = player.timeNextHeal or CurTime()
		if player.timeNextHeal < CurTime() then
			local amount = parameter.amount or 1
			player.ixHealAcc = (player.ixHealAcc or 0) + amount

			if (player.ixHealAcc >= 1) then
				local heal = math.floor(player.ixHealAcc)
				player:SetHealth(math.Clamp(player:Health() + heal, 0, player:GetMaxHealth()))
				player.ixHealAcc = player.ixHealAcc - heal
			end

			player.timeNextHeal = CurTime() +  1
		end
	end,
}

PLUGIN.buffs[ "buff_staminarestore" ] = {
	name = "Energy",
	desc = "You're restoring energy faster.",
	func = function( player, parameter)
		player.timeNextTickStam = player.timeNextTickStam or CurTime()
		if player.timeNextTickStam < CurTime() then
			player:SetLocalVar("stm", math.min(player:GetLocalVar("stm", 100) + (parameter.amount or 1), 100))

			player.timeNextTickStam = CurTime() + 1
		end
	end,
}

PLUGIN.buffs[ "buff_radiationremoval" ] = {
	name = "Antirad",
	desc = "You're becoming less radioactive.",
	func = function( player, parameter)
		player.timeNextTickRadRem = player.timeNextTickRadRem or CurTime()
		if player.timeNextTickRadRem < CurTime() then
			player:addRadiation(-parameter.amount)

			player.timeNextTickRadRem = CurTime() + 1
		end
	end,
}

PLUGIN.buffs[ "debuff_radiation" ] = {
	name = "Radiation",
	desc = "You're becoming radioactive.",
	func = function( player, parameter)
		player.timeNextTickRad = player.timeNextTickRad or CurTime()
		if player.timeNextTickRad < CurTime() then
			player:addRadiation(parameter.amount)

			player.timeNextTickRad = CurTime() + 0.5
		end
	end,
}

PLUGIN.buffs[ "buff_chemprotect" ] = {
	name = "Chemical Protection",
	desc = "You have increased resistance to chemicals.",
	func = function(player, parameter)
	end,
	onbuffed = function(player, parameter)
		player:SetNetVar("ix_chemprot", (player:GetNetVar("ix_chemprot", 0) + parameter.amount))
	end,
	ondebuffed = function(player, parameter)
		player:SetNetVar("ix_chemprot", math.max(0, (player:GetNetVar("ix_chemprot", 0) - parameter.amount)))
	end,
}

PLUGIN.buffs[ "buff_psyprotect" ] = {
	name = "Psy Protection",
	desc = "You are temporarily immune to psychic attacks.",
	onbuffed = function( player, parameter )
		player:SetNetVar("ix_psyblock", (player:GetNetVar("ix_psyblock", 0) + 100))
	end,
	ondebuffed = function( player, parameter )
		player:SetNetVar("ix_psyblock", math.max(0, (player:GetNetVar("ix_psyblock", 0) - 100)))
	end,
	func = function( player, parameter)
	end,
}

PLUGIN.buffs[ "buff_radprotect" ] = {
	name = "Radiation Protection",
	desc = "You have increased resistance to radiation.",
	func = function(player, parameter)
	end,
	onbuffed = function(player, parameter)
		player:SetNetVar("ix_radprot", (player:GetNetVar("ix_radprot", 0) + parameter.amount))
	end,
	ondebuffed = function(player, parameter)
		player:SetNetVar("ix_radprot", math.max(0, (player:GetNetVar("ix_radprot", 0) - parameter.amount)))
	end,
}

/*
PLUGIN.buffs[ "leghurt" ] = {
	name = "Leg Injury",
	desc = "Your legs are injured and your movement has been handicapped.",
	onbuffed = function( player, parameter )
		if !player:HasBuff( "leghurt" ) then
			player:ChatPrint( nut.lang.Get("buff_legs_injured") )
		end
	end,
	ondebuffed = function( player, parameter )
		if !player:Alive() then return end
		if player:HasBuff( "leghurt" ) then
			player:ChatPrint( nut.lang.Get("buff_legs_restored") )
		end
	end,
	func = function( player, parameter)
		player.timeNextMoan = player.timeNextMoan or CurTime()
		if player.timeNextMoan < CurTime() then
			local gender = player.character:GetVar( "gender" )
			player:EmitSound( Format( "vo/npc/%s01/pain0%d.wav", gender, math.random( 1, 9 ) ) )
			player.timeNextMoan = CurTime() + 5
			player:ScreenFadeOut(.5, Color(255, 50, 50, 50))
		end
	end,
}
*/