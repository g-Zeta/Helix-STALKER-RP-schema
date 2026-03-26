local PLUGIN = PLUGIN
PLUGIN.name = "Admin Utilities"
PLUGIN.author = "liquid, Ghost"
PLUGIN.description = "Various tools for staff and players."

local hideWeaponList = {
	["weapon_physgun"] = true,
	["gmod_tool"] = true
}

if (CLIENT) then
	local function ShouldHideWeapon(wep)
		if (not IsValid(wep)) then return false end

		local owner = wep:GetOwner()
		if (not IsValid(owner) or not owner:IsPlayer()) then return false end
		local character = owner:GetCharacter()
		if (not character or character:GetFaction() != FACTION_STAFF) then return false end

		return hideWeaponList[wep:GetClass()] or false
	end

	function PLUGIN:PrePlayerDraw(client)
		local wep = client:GetActiveWeapon()
		if (not IsValid(wep)) then return end

		if (ShouldHideWeapon(wep)) then
			wep:SetNoDraw(true)
		end
	end

	function PLUGIN:UpdateAnimation(client)
		local wep = client:GetActiveWeapon()
		if (not ShouldHideWeapon(wep)) then return end

		if (not client:IsOnGround()) then
			client:SetSequence(client:LookupSequence("jump_fist"))
		elseif (client:GetVelocity():Length() >= 135) then
			client:SetSequence(client:LookupSequence("run_all_01"))
		elseif (client:Crouching()) then
			client:SetSequence(client:LookupSequence("cwalk_all"))
		else
			local idle = client:GetVelocity():Length() == 0
			client:SetSequence(client:LookupSequence(idle and "idle_all_01" or "walk_all"))
		end
	end

	function PLUGIN:DrawPhysgunBeam(client)
		return client == LocalPlayer()
	end

	function PLUGIN:InitPostEntity()
		local original = concommand.GetTable()["pac_load_url"]

		if (original) then
			concommand.Add("pac_load_url", function(ply, cmd, args, argStr)
				local character = LocalPlayer():GetCharacter()

				if (not character or (not character:HasFlags("P") and not LocalPlayer():IsAdmin())) then
					ix.util.Notify("You do not have permission to load PAC outfits from URLs.")
					return
				end

				original(ply, cmd, args, argStr)
			end)
		end
	end
end

if (SERVER) then
	timer.Create("ixOutOfWorldItemCleanup", 300, 0, function()
		for _, e in pairs(ents.GetAll()) do
			if e:GetClass() == "ix_item" and not util.IsInWorld(e:GetPos()) then
				local itemTable = e:GetItemTable()
				if itemTable and itemTable.isArtefact then
					e:Remove()
				end
			end
		end
	end)

	hook.Add("CAMI.PlayerHasAccess", "ixBotCAMIOverride", function(actorPly)
		if (not IsValid(actorPly)) then return end
		if (actorPly:IsBot()) then return true end
	end)

	hook.Remove("PhysgunDrop", "ulxPlayerDrop")
	local function isPlayer(ent) return IsValid(ent) and ent.GetClass and ent:GetClass() == "player" end

	hook.Add("PhysgunPickup", "_ply_physgungrab", function(ply, targ)
		if (IsValid(ply) and isPlayer(targ)) then
			if (ply:query("ulx physgunplayer")) then
				local allowed = ULib.getUser("@", true, ply)
				if (isPlayer(allowed)) then
					if (allowed.frozen and ply:query("ulx unfreeze")) then
						allowed.phrozen = true
						allowed.frozen = false
					end
					allowed._ulx_physgun = {p = targ:GetPos(), b = true}
				end
			end
		end
	end, HOOK_HIGH)

	hook.Add("PlayerSpawn", "_ply_physgungrab", function(ply)
		if (ply._ulx_physgun) then
			if (ply._ulx_physgun.b and ply._ulx_physgun.p) then
				timer.Simple(0.001, function()
					if (not IsValid(ply)) then return end
					ply:SetPos(ply._ulx_physgun.p)
					ply:SetMoveType(MOVETYPE_NONE)
				end)
			end
		end
	end)

	local function physgun_freeze(calling_ply, target_ply, should_unfreeze)
		if (target_ply:InVehicle()) then
			target_ply:ExitVehicle()
		end

		if (not should_unfreeze) then
			target_ply:Lock()
			target_ply.frozen = true
			target_ply.phrozen = true
			ulx.setExclusive(target_ply, "frozen")
		else
			target_ply:UnLock()
			target_ply.frozen = nil
			target_ply.phrozen = nil
			ulx.clearExclusive(target_ply)
		end

		target_ply:DisallowSpawning(not should_unfreeze)
		ulx.setNoDie(target_ply, not should_unfreeze)

		if (target_ply.whipped) then
			target_ply.whipcount = target_ply.whipamt
		end
	end

	hook.Add("PhysgunDrop", "_ulx_physgunfreeze", function(pl, ent)
		if (isPlayer(ent)) then
			ent:SetMoveType(MOVETYPE_WALK)
			ent._ulx_physgun = {p = ent:GetPos(), b = false}
		end

		if (IsValid(pl) and isPlayer(ent)) then
			if (pl:query("ulx physgunplayer")) then
				local isFrozen = ent:IsFrozen() or ent.frozen or ent.phrozen
				ent:SetVelocity(ent:GetVelocity() * -1)
				ent:SetMoveType(pl:KeyDown(IN_ATTACK2) and MOVETYPE_NOCLIP or MOVETYPE_WALK)
				timer.Simple(0.001, function()
					if (not IsValid(pl) or not IsValid(ent)) then return end
					if (pl:KeyDown(IN_ATTACK2) and not isFrozen) then
						if (pl:query("ulx freeze")) then
							ulx.freeze(pl, {ent}, false)
							if (ent.frozen) then ent.phrozen = true end
						end
					elseif (pl:query("ulx unfreeze") and isFrozen) then
						if (pl:KeyDown(IN_ATTACK2) and pl:query("ulx freeze")) then
							physgun_freeze(pl, ent, true)
							timer.Simple(0.001, function()
								if (not IsValid(pl) or not IsValid(ent)) then return end
								physgun_freeze(pl, ent, false)
							end)
						else
							ulx.freeze(pl, {ent}, true)
							if (not ent.frozen) then ent.phrozen = nil end
						end
					end
				end)
			else
				ent:SetMoveType(MOVETYPE_WALK)
			end
		end
	end)
end

function PLUGIN:InitializedPlugins()
	for _, v in pairs(ix.item.list) do
		if (not v.functions.delete) then
			v.functions.delete = {
				name = "Delete",
				icon = "icon16/delete.png",
				OnClick = function(item)
					Derma_Query("Are you sure you want to delete " .. item:GetName() .. "?", "Delete Item", "Yes", function()
						net.Start("ixInventoryAction")
							net.WriteString("delete")
							net.WriteUInt(item.id, 32)
							net.WriteUInt(item.invID, 32)
							net.WriteTable({})
						net.SendToServer()
					end, "No")

					return false
				end,
				OnRun = function(item)
					if (not item.player:IsAdmin()) then return false end

					if (item:GetData("equip") and item.functions.EquipUn and item.functions.EquipUn.OnRun) then
						item.functions.EquipUn.OnRun(item)
					end

					ix.item.inventories[item.invID]:Remove(item.id)
					return false
				end,
				OnCanRun = function(item)
					return item.player:IsAdmin() and (not input or input.IsKeyDown(KEY_LSHIFT))
				end
			}
		end
	end
end

ix.command.Add("ForceFallOver", {
	description = "Force a character to fall over.",
	adminOnly = true,
	arguments = {ix.type.character, bit.bor(ix.type.number, ix.type.optional)},
	OnRun = function(self, client, target, time)
		local ply = target:GetPlayer()

		if (not IsValid(ply) or not ply:Alive()) then
			return "That player is not available."
		end

		if (IsValid(ply.ixRagdoll)) then
			return "That player is already ragdolled."
		end

		if (time and time > 0) then
			time = math.Clamp(time, 1, 60)
		end

		ply:SetRagdolled(true, time)
	end
})

ix.command.Add("ForceGetUp", {
	description = "Force a character to get up.",
	adminOnly = true,
	arguments = {ix.type.character},
	OnRun = function(self, client, target)
		local ply = target:GetPlayer()

		if (not IsValid(ply)) then
			return "That player is not available."
		end

		if (not IsValid(ply.ixRagdoll)) then
			return "That player is not ragdolled."
		end

		ply:SetRagdolled(false)
	end
})
