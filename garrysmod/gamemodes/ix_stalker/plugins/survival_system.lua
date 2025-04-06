PLUGIN.name = "Survival System"
PLUGIN.author = "ZeMysticalTaco"
PLUGIN.description = "A survival system consisting of hunger and thirst."

ix.config.Add("hungerTickTime", 600, "The time interval in seconds for ticking hunger.", nil, {
	data = {min = 60, max = 3600},
	category = "Survival"
})

ix.config.Add("thirstTickTime", 600, "The time interval in seconds for ticking thirst.", nil, {
	data = {min = 60, max = 3600},
	category = "Survival"
})

if SERVER then
	function PLUGIN:OnCharacterCreated(client, character)
		character:SetData("hunger", 100)
		character:SetData("thirst", 100)
	end

	function PLUGIN:PlayerLoadedCharacter(client, character)
		timer.Simple(0.25, function()
			client:SetLocalVar("hunger", character:GetData("hunger", 100))
			client:SetLocalVar("thirst", character:GetData("thirst", 100))
			
		end)

		timer.Simple(1, function()
			client:UpdateThirstState(client)
			client:UpdateHungerState(client)
		end)
	end

	function PLUGIN:CharacterPreSave(character)
		local client = character:GetPlayer()

		if (IsValid(client)) then
			character:SetData("hunger", client:GetLocalVar("hunger", 0))
			character:SetData("thirst", client:GetLocalVar("thirst", 0))
		end
	end

	local playerMeta = FindMetaTable("Player")

	function playerMeta:SetHunger(amount)
		local char = self:GetCharacter()

		if (char) then
			char:SetData("hunger", amount)
			self:SetLocalVar("hunger", amount)
		end
	end

	function playerMeta:SetThirst(amount)
		local char = self:GetCharacter()

		if (char) then
			char:SetData("thirst", amount)
			self:SetLocalVar("thirst", amount)
		end
	end

	function playerMeta:TickThirst(amount)
		local char = self:GetCharacter()
		
		if (char) then
			local thirst = char:GetData("thirst",100)
			local newthirst = (thirst - amount)
			
			if char:GetData("thirst", 100) < 0 then
				char:SetData("thirst", 0)
				self:SetLocalVar("thirst", 0)
			else
				char:SetData("thirst", newthirst)
				self:SetLocalVar("thirst", newthirst)
			end
			self:UpdateThirstState(self)
		end
	end

	function playerMeta:TickHunger(amount)
		local char = self:GetCharacter()
		
		if (char) then
			local hunger = char:GetData("hunger",100)
			local newhunger = (hunger - amount)

			if newhunger < 0 then
				char:SetData("hunger", 0)
				self:SetLocalVar("hunger", 0)
			else
				char:SetData("hunger", newhunger)
				self:SetLocalVar("hunger", newhunger)
			end
			self:UpdateHungerState(self)
		end
	end
	
	local ticktimer = 0
	
	function PLUGIN:PlayerTick(ply)
		
		if ticktimer > CurTime() then return end
		ticktimer = CurTime() + 1
		
		local char = ply:GetCharacter()
		
		if char then
			if char:GetData("lastpos") then
				if char:GetData("lastpos") == ply:GetPos() then
					return
				else
					char:SetData("lastpos",ply:GetPos())
				end
			else
				char:SetData("lastpos",ply:GetPos())
			end
		end
	
		if ply:GetNetVar("hungertick", 0) <= CurTime() then
			ply:SetNetVar("hungertick", ix.config.Get("hungerTickTime") + CurTime())
			ply:TickHunger(1)
		end

		if ply:GetNetVar("thirsttick", 0) <= CurTime() then
			ply:SetNetVar("thirsttick", ix.config.Get("thirstTickTime") + CurTime())
			ply:TickThirst(1)
		end
	end

	function playerMeta:UpdateHungerState(client)
		local hunger = client:GetHunger()
	
		if hunger > 60 then
			client:SetWalkSpeed(ix.config.Get("walkSpeed"))
			client:SetRunSpeed(ix.config.Get("runSpeed") * 1.1)
			client:SetMaxSpeed(200)
			client:SetJumpPower(200)
		elseif hunger <= 60 and hunger > 30 then
			client:SetWalkSpeed(ix.config.Get("walkSpeed"))
			client:SetRunSpeed(ix.config.Get("runSpeed"))
			client:SetMaxSpeed(175)
			client:SetJumpPower(150)
		elseif hunger <= 30 and hunger > 0 then
			client:SetWalkSpeed(ix.config.Get("walkSpeed") * 0.8)
			client:SetRunSpeed(ix.config.Get("runSpeed") * 0.8)
			client:SetMaxSpeed(150)
			client:SetJumpPower(125)
		elseif hunger <= 0 then
			client:SetWalkSpeed(ix.config.Get("walkSpeed") * 0.6)
			client:SetRunSpeed(ix.config.Get("runSpeed") * 0.6)
			client:SetMaxSpeed(125)
			client:SetJumpPower(100)
		end
	end

	function playerMeta:UpdateThirstState(client)
		local thirst = client:GetThirst()
		
		if thirst > 60 then
			client:SetWalkSpeed(ix.config.Get("walkSpeed"))
			client:SetRunSpeed(ix.config.Get("runSpeed") * 1.1)
			client:SetMaxSpeed(200)
			client:SetJumpPower(200)
		elseif thirst <= 60 and thirst > 30 then
			client:SetWalkSpeed(ix.config.Get("walkSpeed"))
			client:SetRunSpeed(ix.config.Get("runSpeed"))
			client:SetMaxSpeed(175)
			client:SetJumpPower(150)
		elseif thirst <= 30 and thirst > 0 then
			client:SetWalkSpeed(ix.config.Get("walkSpeed") * 0.8)
			client:SetRunSpeed(ix.config.Get("runSpeed") * 0.8)
			client:SetMaxSpeed(150)
			client:SetJumpPower(125)
		elseif thirst <= 0 then
			client:SetWalkSpeed(ix.config.Get("walkSpeed") * 0.6)
			client:SetRunSpeed(ix.config.Get("runSpeed") * 0.6)
			client:SetMaxSpeed(125)
			client:SetJumpPower(100)
		end
	end
end



local playerMeta = FindMetaTable("Player")

function playerMeta:GetHunger()
	local char = self:GetCharacter()

	if (char) then
		return char:GetData("hunger", 100)
	end
end

function playerMeta:GetThirst()
	local char = self:GetCharacter()

	if (char) then
		return char:GetData("thirst", 100)
	end
end

function PLUGIN:AdjustStaminaOffset(client, offset)
	local hunger = client:GetHunger()
	local thirst = client:GetThirst()

	if (hunger <= 0) or (thirst <= 0) then
		return offset-0.9
	elseif (hunger <= 30 and hunger > 0) or (thirst <= 30 and thirst > 0) then 
		return offset-0.6
	elseif (hunger <= 60 and hunger > 30) or (thirst <= 60 and thirst > 30) then
		return offset-0.3
	elseif hunger > 60 or thirst > 60 then
		return offset
	end
end

ix.command.Add("charsetthirst", {
	adminOnly = true,
	arguments = {
		ix.type.string,
		ix.type.number,
	},
	OnRun = function(self, client, target, thirst)
		local target = ix.util.FindPlayer(target)
		local thirst = tonumber(thirst)
		
		if !target then
			client:Notify("Invalid Target!")
			return
		end
		target:SetThirst(thirst)

		if client == target then
            client:Notify("You have set your thrist to "..thirst)
        else
            client:Notify("You have set "..target:Name().."'s thirst to "..thirst)
            target:Notify(client:Name().." has set your thirst to "..thirst)
        end
        target:UpdateThirstState(target)
	end
})

ix.command.Add("charsethunger", {
	adminOnly = true,
	arguments = {
		ix.type.string,
		ix.type.number,
	},
	OnRun = function(self, client, target, hunger)
		local target = ix.util.FindPlayer(target)
		local hunger = tonumber(hunger)

		if !target then
			client:Notify("Invalid Target!")
			return
		end

		target:SetHunger(hunger)

		if client == target then
            client:Notify("You have set your hunger to "..hunger)
        else
            client:Notify("You have set "..target:Name().."'s hunger to "..hunger)
            target:Notify(client:Name().." has set your hunger to "..hunger)
        end
        target:UpdateHungerState(target)
	end
})