ITEM.name = "PDA base"
ITEM.model = "models/deadbodies/dead_male_civilian_radio.mdl"
ITEM.description = "A PDA used for communicating with other people."
ITEM.width = 1
ITEM.height = 1
ITEM.price = 150
ITEM.category = "Electronics"
ITEM.flag = "1"
ITEM.isPDA = true
ITEM.weaponCategory = "PDA"

ITEM.equipIcon = Material("materials/vgui/ui/stalker/misc/equip.png")

if (CLIENT) then
    function ITEM:PaintOver(item, w, h)
        if (item:GetData("equip")) then
            surface.SetDrawColor(110, 255, 110, 255)
        else
            surface.SetDrawColor(255, 110, 110, 255)
        end

        surface.SetMaterial(item.equipIcon)
        surface.DrawTexturedRect(w-23,h-23,19,19)
    end

    -- Cache materials to avoid re-creating on each paint
    local matCache = {}
    local function safeMaterial(path)
        local m = matCache[path]
        if m then return m, not m:IsError() end
        m = Material(path)
        matCache[path] = m
        return m, not m:IsError()
    end

    -- Define faction folders and known image files (fill in your actual file names)
    local FACTION_FOLDERS = {
        loners       = "stalker/ui/avatars/loners/",
        bandits      = "stalker/ui/avatars/bandits/",
        freedom      = "stalker/ui/avatars/freedom/",
        monolith     = "stalker/ui/avatars/monolith/",
        duty         = "stalker/ui/avatars/duty/",
        military     = "stalker/ui/avatars/military/",
        mercenaries  = "stalker/ui/avatars/mercenaries/",
        ecologists   = "stalker/ui/avatars/ecologists/",
        clearsky     = "stalker/ui/avatars/clearsky/"
    }

	-- Config for the pattern
	local FACE_BASENAME = "face"
	local FACE_EXTS = { ".png", ".vmt" } -- try common possibilities; keep ".png" first if your assets are PNG
	local PROBE_MAX = 30                -- hard upper bound so we don't loop forever
	local GAP_STOP_AFTER = 1             -- stop after this many consecutive misses. If all files are exactly face1..faceN.png with no gaps, set GAP_STOP_AFTER to 1 for faster probing.
	local ZERO_PAD = false               -- set true if your files are face01, face02, etc.

	local function makeFaceName(i)
		if ZERO_PAD then
			return string.format("%s%02d", FACE_BASENAME, i)
		else
			return FACE_BASENAME .. i
		end
	end

	local function tryResolveMaterialPath(basePathNoExt)
		-- try each extension and return the first that loads successfully
		for _, ext in ipairs(FACE_EXTS) do
			local p = basePathNoExt .. ext
			local _, ok = safeMaterial(p) -- uses your cache
			if ok then
				return p
			end
		end
		return nil
	end

	local function probeFactionPaths(fname)
		local folder = FACTION_FOLDERS[fname]
		if not folder then return {} end

		local out, misses = {}, 0
		for i = 1, PROBE_MAX do
			local face = makeFaceName(i)
			local found = tryResolveMaterialPath(folder .. face)
			if found then
				out[#out+1] = found
				misses = 0
			else
				misses = misses + 1
				if misses >= GAP_STOP_AFTER then
					break
				end
			end
		end
		return out
	end

	local function buildPathsForFaction(fname)
		return probeFactionPaths(fname)
	end

	local function collectAllFactionPaths()
		local all = {}
		for fname, _ in pairs(FACTION_FOLDERS) do
			local list = probeFactionPaths(fname)
			for _, p in ipairs(list) do
				all[#all+1] = p
			end
		end
		return all
	end

    local function OpenAvatarPicker(item)
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Select PDA Avatar")
        frame:SetSize(410, 460)
        frame:Center()
        frame:MakePopup()

        local current = item:GetData("avatar", "stalker/ui/avatars/nodata.png")

        -- Top bar with faction buttons
        local top = vgui.Create("DScrollPanel", frame)
        top:Dock(TOP)
        top:SetTall(60)
        top:DockMargin(4, 0, 0, 0)

        local btnRow = vgui.Create("DIconLayout", top)
        btnRow:Dock(FILL)
        btnRow:SetSpaceX(6)

        -- Main scroll area with icons
        local scroll = vgui.Create("DScrollPanel", frame)
        scroll:Dock(FILL)
        scroll:DockMargin(4, 8, 0, 8)

        local list = vgui.Create("DIconLayout", scroll)
        list:Dock(FILL)
        list:SetSpaceY(5)
        list:SetSpaceX(5)
        list:DockMargin(0, 0, 0, 0)

        local function addAvatarButton(path)
            local m, ok = safeMaterial(path)
            if not ok then return end

            local pnl = list:Add("DButton")
            pnl:SetSize(123, 87)
            pnl:SetText("")

            pnl.Paint = function(self, w, h)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(m)
                surface.DrawTexturedRect(0, 0, w, h)

                surface.SetDrawColor(0, 0, 0, 150)
                surface.DrawOutlinedRect(0, 0, w, h)

                if path == current then
                    surface.SetDrawColor(80, 200, 120, 180)
                    surface.DrawOutlinedRect(1, 1, w-2, h-2)
                    surface.DrawOutlinedRect(2, 2, w-4, h-4)
                end
            end

            pnl.DoClick = function()
                net.Start("ixPDASetAvatar")
                    net.WriteUInt(item:GetID() or item.id or 0, 32)
                    net.WriteString(path)
                net.SendToServer()
                frame:Close()
            end

            pnl:SetTooltip(path)
        end

        local function populateList(paths)
            list:Clear()
            for _, p in ipairs(paths) do
                addAvatarButton(p)
            end
            list:InvalidateLayout(true)
        end

        -- Build the buttons
        local function addFactionButton(label, onClick)
            local b = btnRow:Add("DButton")
            b:SetSize(90, 30)
            b:SetText(label)
            b.DoClick = onClick
            return b
        end

        -- "All" first
        addFactionButton("All", function()
            populateList(collectAllFactionPaths())
        end)

        -- Each faction
        local ordered = {
            "loners","bandits","freedom","monolith","duty","military","mercenaries","ecologists","clearsky"
        }
        for _, fname in ipairs(ordered) do
            addFactionButton(string.upper(string.sub(fname, 1, 1)) .. string.sub(fname, 2), function()
                populateList(buildPathsForFaction(fname))
            end)
        end

        -- Default view: All
        populateList(collectAllFactionPaths())

        -- Keep "Custom path..." button
        local custom = vgui.Create("DButton", frame)
        custom:Dock(BOTTOM)
        custom:DockMargin(4, 0, 4, 8)
        custom:SetTall(28)
        custom:SetText("Custom path...")
        custom.DoClick = function()
            frame:Close()
            local def = current

            if ix and ix.util and ix.util.PromptString then
                ix.util.PromptString("Set Avatar", "Enter a material path", def, function(text)
                    text = string.Trim(text or "")
                    if text == "" then return end

                    local _, ok = safeMaterial(text)
                    if not ok then
                        LocalPlayer():Notify("Invalid material path.")
                        return
                    end

                    net.Start("ixPDASetAvatar")
                        net.WriteUInt(item:GetID() or item.id or 0, 32)
                        net.WriteString(text)
                    net.SendToServer()
                end)
            else
                local ask = vgui.Create("DFrame")
                ask:SetTitle("Set Avatar")
                ask:SetSize(360, 120)
                ask:Center()
                ask:MakePopup()

                local lbl = vgui.Create("DLabel", ask)
                lbl:Dock(TOP)
                lbl:DockMargin(8, 8, 8, 4)
                lbl:SetText("Enter a material path")

                local entry = vgui.Create("DTextEntry", ask)
                entry:Dock(TOP)
                entry:DockMargin(8, 0, 8, 8)
                entry:SetText(def or "")

                local btn = vgui.Create("DButton", ask)
                btn:Dock(BOTTOM)
                btn:DockMargin(8, 0, 8, 8)
                btn:SetTall(26)
                btn:SetText("OK")
                btn.DoClick = function()
                    local text = string.Trim(entry:GetText() or "")
                    if text ~= "" then
                        local _, ok = safeMaterial(text)
                        if not ok then
                            LocalPlayer():Notify("Invalid material path.")
                        else
                            net.Start("ixPDASetAvatar")
                                net.WriteUInt(item:GetID() or 0, 32)
                                net.WriteString(text)
                            net.SendToServer()
                        end
                    end
                    ask:Close()
                end
            end
        end
    end

    net.Receive("ixPDAOpenAvatarPicker", function()
        local _invID = net.ReadUInt(32)
        local itemID = net.ReadUInt(32)
        local item = ix.item.instances[itemID]
        if item then
            OpenAvatarPicker(item)
        end
    end)
end

if SERVER then
    util.AddNetworkString("ixPDAOpenAvatarPicker")
	util.AddNetworkString("ixPDASetAvatar")
	util.AddNetworkString("ixItemDataUpdated")

    net.Receive("ixPDASetAvatar", function(_, ply)
        local itemID = net.ReadUInt(32)
        local path = string.Trim(net.ReadString() or "")

        if not IsValid(ply) then return end
        local item = ix.item.instances[itemID]
        if not item then return end

        item:SetData("avatar", path)

        local char = ply:GetCharacter()
        if char and item:GetData("equip") then
            -- sync to character only if the PDA is equipped
            char:SetData("pdaavatar", path)
        end

        ply:Notify("PDA avatar updated.")

        -- Optional: push a small net message to client to refresh UI
        -- This helps inventory UIs that cache values.
        if ix and ix.item and ix.item.instances[itemID] then
            net.Start("ixItemDataUpdated")
                net.WriteUInt(itemID, 32)
            net.Send(ply)
        end
    end)
end

function ITEM:CanTransfer(oldInventory, newInventory)
	if (newInventory and self:GetData("equip")) then
		return false
	end

	return true
end

ITEM.functions.Equip = { -- sorry, for name order.
	name = "Equip",
	tip = "useTip",
	icon = "icon16/stalker/equip.png",
	sound = "stalkersound/inv_dozimetr.ogg",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local items = character:GetInventory():GetItems()
		local wepslots = character:GetData("wepSlots",{})

		for _, v in pairs(items) do
			if (v.id ~= item.id) and (v.weaponCategory == item.weaponCategory) and v:GetData("equip") then
				item.player:Notify("You are already equipping a PDA.")
				return false
			end
		end

		wepslots[item.weaponCategory] = item.Name
		character:SetData("wepSlots",wepslots)
		character:SetData("pdaavatar", item:GetData("avatar", "stalker/ui/avatars/nodata.png"))
		character:SetData("pdausername", item:GetData("username", item.player:GetName()))
		item:SetData("equip", true)
		character:SetData("pdaequipped", true)

		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and
			hook.Run("CanPlayerUnequipItem", client, item) != false and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}

ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/stalker/unequip.png",
	sound = "cw/switch1.wav",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local wepslots = character:GetData("wepSlots",{})
		item:SetData("equip", false)
		character:SetData("pdaequipped", false)
		character:SetData("pdausername", "NIL")
		wepslots[item.weaponCategory] = nil
		character:SetData("wepSlots",wepslots)
		return false 
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true
	end
}

ITEM.functions.Sell = {
	name = "Sell",
	icon = "icon16/stalker/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item.price
		sellprice = math.Round(sellprice*0.75)
		client:Notify( "Sold for "..(sellprice).." rubles." )
		client:GetCharacter():GiveMoney(sellprice)
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1") and !item:GetData("equip")
	end
}

ITEM.functions.Value = {
	name = "Value",
	icon = "icon16/help.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item:GetData("RealPrice") or item.price
		sellprice = math.Round(sellprice*0.75)
		client:Notify( "Item is sellable for "..(sellprice).." rubles." )
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1") and !item:GetData("equip")
	end
}

ITEM.functions.setavatar = {
    name = "Select Avatar",
    tip = "useTip",
    icon = "icon16/stalker/customize.png",
    OnRun = function(item)
        if SERVER then
            net.Start("ixPDAOpenAvatarPicker")
                net.WriteUInt(item.invID or 0, 32)
                net.WriteUInt(item.id or item:GetID() or 0, 32)
            net.Send(item.player)
        end
        return false
    end,
    OnCanRun = function(item)
        return not IsValid(item.entity) and IsValid(item.player)
    end
}

ITEM.functions.setusername = {
	name = "Set your PDA username",
	tip = "useTip",
	icon = "icon16/stalker/customize.png",
	OnRun = function(item)
		item.player:RequestString("Set username", "What username do you want to use with this PDA?", function(text)
			item:SetData("username", text)
			item:GetOwner():GetCharacter():SetData("pdausername", text)
		end, item:GetData("username", item.player:Name()))
		return false
	end,
}

function ITEM:OnEquipped()
	self.player:GetCharacter():SetData("pdaavatar", self:GetData("avatar", "lutz"))
	self.player:GetCharacter():SetData("pdausername", self:GetData("username", "lutz"))
end

function ITEM:OnUnEquipped(client, slot, data)
    local character = client:GetCharacter()
    if not character then return end
    character:SetData("RankPublic", false)
    character:SetData("RankPrivate", false)
    character:SetData("pdaavatar", "stalker/ui/avatars/nodata.png")
    netstream.Start(client, "ProfileStatusChanged", {
        public = false,
        private = false,
        avatar = "stalker/ui/avatars/nodata.png",
        hasPDA = false,
    })
end

function ITEM:OnInstanced()
	self:SetData("avatar", "stalker/ui/avatars/nodata.png")
	self:SetData("username", "NEW_USER")
end
