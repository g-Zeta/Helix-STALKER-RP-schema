PLUGIN.name = "Batteries"
PLUGIN.author = "Zeta (Gemini Code assisted)"
PLUGIN.description = "Handles power drain for electronic devices."

ix.config.Add("nvgDrainRate", 3, "Seconds between NVG battery drain ticks.", nil, {
	data = {min = 1, max = 36, decimals = 0},
	category = "Electronics Settings"
})

ix.config.Add("flashlightDrainRate", 3, "Seconds between flashlight battery drain ticks.", nil, {
	data = {min = 1, max = 36, decimals = 0},
	category = "Electronics Settings"
})

ix.config.Add("artdetectorDrainRate", 3, "Seconds between artifact detector battery drain ticks.", nil, {
	data = {min = 1, max = 36, decimals = 0},
	category = "Electronics Settings"
})

ix.config.Add("anomDetectorDrainRate", 3, "Seconds between anomaly detector battery drain ticks.", nil, {
	data = {min = 1, max = 36, decimals = 0},
	category = "Electronics Settings"
})

ix.config.Add("geigerDrainRate", 3, "Seconds between geiger counter battery drain ticks.", nil, {
	data = {min = 1, max = 36, decimals = 0},
	category = "Electronics Settings"
})

if (SERVER) then
    local playerTimers = {}

    function PLUGIN:PlayerTick(ply)
        local char = ply:GetCharacter()
        if (!char or !ply:Alive()) then return end

        local steamID = ply:SteamID64()
        if (!playerTimers[steamID]) then
            playerTimers[steamID] = {nvg = 0, flashlight = 0, artdetector = 0, anomdetector = 0, geiger = 0}
        end

        local curTime = CurTime()
        local timers = playerTimers[steamID]

        local nvgRate = ix.config.Get("nvgDrainRate", 3)
        local flashlightRate = ix.config.Get("flashlightDrainRate", 3)
        local artdetectorRate = ix.config.Get("artdetectorDrainRate", 3)
        local anomDetectorRate = ix.config.Get("anomDetectorDrainRate", 3)
        local geigerRate = ix.config.Get("geigerDrainRate", 3)

        local bProcessNVG = ply:GetNWBool("nvg_on", false) and (timers.nvg <= curTime)
        local bProcessFlashlight = ply:FlashlightIsOn() and (timers.flashlight <= curTime)
        local bProcessAnom = ply:GetNetVar("ixhasanomdetector", false) and (timers.anomdetector <= curTime)
        local bProcessGeiger = ply:GetNetVar("ixhasgeiger", false) and (timers.geiger <= curTime)

        if (bProcessNVG or bProcessFlashlight or bProcessAnom or bProcessGeiger) then
            local inventory = char:GetInventory()
            if (inventory) then
                local items = inventory:GetItems()

                -- NVG Drain
                if (bProcessNVG) then
                    for _, item in pairs(items) do
                        if (item.isNVG and item:GetData("equip")) then
                            local currentPower = item:GetData("durability", 0)
                            if (currentPower > 0) then
                                item:SetData("durability", math.max(0, currentPower - 1))

                                if (item:GetData("durability") <= 0) then
                                    ply:SetNWBool("nvg_on", false)
                                    ply:Notify("Your NVGs' battery has run out.")
                                    ply:ConCommand("arc_vm_nvg")
                                end
                            else
                                ply:SetNWBool("nvg_on", false)
                                ply:ConCommand("arc_vm_nvg")
                            end
                            timers.nvg = curTime + nvgRate
                            break
                        end
                    end
                    if (timers.nvg <= curTime) then timers.nvg = curTime + 1 end
                end

                -- Headlamp Drain
                if (bProcessFlashlight) then
                    for _, item in pairs(items) do
                        if (item.isFlashlight and item:GetData("equip")) then
                            local currentPower = item:GetData("durability", 0)
                            if (currentPower > 0) then
                                item:SetData("durability", math.max(0, currentPower - 1))

                                if (item:GetData("durability") <= 0) then
                                    ply:Flashlight(false)
                                    ply:Notify("Your headlamp's battery has run out.")
                                end
                            else
                                ply:Flashlight(false)
                            end
                            timers.flashlight = curTime + flashlightRate
                            break
                        end
                    end
                    if (timers.flashlight <= curTime) then timers.flashlight = curTime + 1 end
                end

                -- Anomaly Detector Drain
                if (bProcessAnom) then
                    for _, item in pairs(items) do
                        if (item.isAnomalydetector and item:GetData("equip")) then
                            local currentPower = item:GetData("durability", 0)
                            if (currentPower > 0) then
                                item:SetData("durability", math.max(0, currentPower - 1))

                                if (item:GetData("durability") <= 0) then
                                    ply:Notify("Your anomaly detector's battery has run out.")
                                    item.player = ply
                                    if (item.functions.EquipUn and item.functions.EquipUn.OnRun) then
                                        item.functions.EquipUn.OnRun(item)
                                    end
                                end
                            end
                            timers.anomdetector = curTime + anomDetectorRate
                            break
                        end
                    end
                    if (timers.anomdetector <= curTime) then timers.anomdetector = curTime + 1 end
                end

                -- Geiger Counter Drain
                if (bProcessGeiger) then
                    for _, item in pairs(items) do
                        if (item.isGeiger and item:GetData("equip")) then
                            local currentPower = item:GetData("durability", 0)
                            if (currentPower > 0) then
                                item:SetData("durability", math.max(0, currentPower - 1))

                                if (item:GetData("durability") <= 0) then
                                    ply:Notify("Your geiger counter's battery has run out.")
                                    item.player = ply
                                    if (item.functions.EquipUn and item.functions.EquipUn.OnRun) then
                                        item.functions.EquipUn.OnRun(item)
                                    end
                                end
                            end
                            timers.geiger = curTime + geigerRate
                            break
                        end
                    end
                    if (timers.geiger <= curTime) then timers.geiger = curTime + 1 end
                end
            end
        end

        -- Artifact Detector Drain
        if (timers.artdetector <= curTime) then
            local wep = ply:GetActiveWeapon()
            if (IsValid(wep) and wep.ixItem and wep.ixItem.isArtifactdetector) then
                local item = wep.ixItem
                local currentPower = item:GetData("durability", 0)
                if (currentPower > 0) then
                    item:SetData("durability", math.max(0, currentPower - 1))

                    if (item:GetData("durability") <= 0) then
                        ply:Notify("Your detector's battery has run out.")

                        if (item.Unequip) then
                            item:Unequip(ply, true)
                        end
                    end
                end
                timers.artdetector = curTime + artdetectorRate
            end
        end
    end

	util.AddNetworkString("ixPowerDurabilityAdjust")

	net.Receive("ixPowerDurabilityAdjust", function(len, client)
		local amount = net.ReadUInt(7)
		local id = net.ReadUInt(32)

		if (!client:GetCharacter() or !client:GetCharacter():HasFlags("N")) then return end

		local item = ix.item.instances[id]
		if (!item) then return end

		local ent = item:GetEntity()
		if (IsValid(ent) or item:GetOwner() == client) then
			(ent or client):EmitSound("buttons/combine_button1.wav", 50, 170)
			amount = math.Clamp(amount, 0, 100)

			if (item.isBattery) then
				item:SetData("power", amount)
			else
				item:SetData("durability", amount)
			end
		end
	end)
end

if (CLIENT) then
	local PANEL = {}

	function PANEL:Init()
	    self.slider = self:Add("DNumSlider")
		self.slider:SetText("Power Durability")
		self.slider:SetMin(0)
		self.slider:SetMax(100)
		self.slider:SetDecimals(0)
		self.slider:Dock(FILL)
		
		self:SetTitle("Set Power Durability")
		self:SetSize(400, 150)
		self:Center()
		self:MakePopup()

		self.submit = self:Add("DButton")
		self.submit:Dock(BOTTOM)
		self.submit:DockMargin(0, 5, 0, 0)
		self.submit:SetTall(25)
		self.submit:SetText("Confirm")
		self.submit.DoClick = function()
		    local dura = self.slider:GetValue()
			net.Start("ixPowerDurabilityAdjust")
				net.WriteUInt(dura, 7)
				net.WriteUInt(self.itemID, 32)
			net.SendToServer()
			self:Close()
		end
	end

	vgui.Register("PowerDurabilityAdjust", PANEL, "DFrame")

	net.Receive("ixPowerDurabilityAdjust", function()
		local amount = net.ReadUInt(7)
		local id = net.ReadUInt(32)
		local panel = vgui.Create("PowerDurabilityAdjust")
		panel.slider:SetValue(amount)
		panel.itemID = id
	end)
end