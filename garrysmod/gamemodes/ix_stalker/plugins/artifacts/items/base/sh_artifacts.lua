ITEM.name = "Artifact"
ITEM.model = "models/props_junk/PopCan01a.mdl"
ITEM.description = "An artifact. Valuable."
ITEM.longdesc = "Longer description here."
ITEM.category = "Artifacts"		-- No need to add this line to the item

ITEM.price = 1
ITEM.weight = 1
ITEM.width = 1		-- No need to add this line to the item
ITEM.height = 1		-- No need to add this line to the item

ITEM.flag = "A"		-- No need to add this line to the item

--These are the anomalous resistances that stack up with the armor and headgear. 0.1 = 10% = 1pt
ITEM.res = {
	["Blast"] = 0.00,
	["Bullet"] = 0.00,
	["Slash"] = 0.00,
	["Fall"] = 0.00,
	["Burn"] = 0.00,
	["Chemical"] = 0.00,
	["Shock"] = 0.00,
	["Psi"] = 0.00,
	["Radiation"] = 0.00,
}

--[[
--If any, choose the buff and/or debuff class from the lists below, but only up to one for each class.
ITEM.buff = --buff goes here
	heal
	woundheal
	endbuff
	antirad
	psi
	weight		--For weight, buffval has to be equal to the amount of kg that the artifact gives
	
ITEM.debuff = --debuff goes here
	rads
	bleeding
	endred
--]]

ITEM.buffval = 0

ITEM.debuffval = 0

ITEM.img = Material("placeholders/artifact.png")

ITEM.isArtefact = true

ITEM.equipIcon = Material("materials/vgui/ui/stalker/misc/equip.png")

function ITEM:GetDescription()
	local str = self.description
	if self.longdesc and !IsValid(self.entity) then
		str = str.."\n\n"..(self.longdesc or "")
	end

	local customData = self:GetData("custom", {})
	if(customData.desc) then
		str = customData.desc
	end
	
	if (customData.longdesc) and !IsValid(self.entity) then
		str = str.."\n\n"..(customData.longdesc or "")
	end

    return (str)
end

-- Buffs and debuffs dynamic descriptions
if (CLIENT) then
    function ITEM:PopulateTooltip(tooltip)
        if not self.entity then
            -- Buffs
			local buffval = "+" .. self.buffval or 0	-- Adds a "+" symbol before the buff value
			local buffcolor = Color(0, 135, 0)	-- Buff value and the symbol will be displayed in green

            if self.buff == "antirad" then
                ix.util.PropertyDesc4(tooltip, "Radiation: ", Color(255, 255, 255), buffval, buffcolor, "materials/stalkerCoP/ui/icons/armorupgrades/rad.png")
            end

            if self.buff == "heal" then
                ix.util.PropertyDesc4(tooltip, "Healing regeneration: ", Color(255, 255, 255), buffval, buffcolor, "materials/stalkerCoP/ui/icons/armorupgrades/hpregen.png")
            end

            if self.buff == "woundheal" then
                ix.util.PropertyDesc4(tooltip, "Wound healing: ", Color(255, 255, 255), buffval, buffcolor, "materials/stalkerCoP/ui/icons/armorupgrades/bleeding.png")
            end

            if self.buff == "endbuff" then
                ix.util.PropertyDesc4(tooltip, "Energy recovery: ", Color(255, 255, 255), buffval, buffcolor, "materials/stalkerCoP/ui/icons/armorupgrades/stamina.png")
            end

			local weightbuffval = self.buffval or 0
            if self.buff == "weight" then
                ix.util.PropertyDesc4(tooltip, "Weight capacity: ", Color(255, 255, 255), "+" .. ix.weight.WeightString(weightbuffval, ix.option.Get("imperial", false)), buffcolor, "materials/stalkerCoP/ui/icons/armorupgrades/carryweightinc.png")
            end

            -- Resistances
            local resistances = {
                {"Impact", self.res["Fall"]},      -- Fall expressed as Impact
                {"Thermal", self.res["Burn"]},     -- Burn expressed as Thermal
                {"Chemical", self.res["Chemical"]}, -- Chemical remains unchanged
                {"Electrical", self.res["Shock"]},  -- Shock expressed as Electrical
            }

            local resbuffColor = Color(0, 128, 0)	-- Green for buffs
			local resdebuffColor = Color(235, 0, 0)	-- Red for debuffs

            for _, resistance in ipairs(resistances) do
                local resType, resValue = resistance[1], resistance[2]

				-- Resistances buffs
                local resbuffval = "+" .. math.floor(resValue * 10)
				if resValue > 0 then
                    if resType == "Impact" then
                        ix.util.PropertyDesc4(tooltip, "Impact: ", Color(255, 255, 255), resbuffval, resbuffColor, "materials/stalkerCoP/ui/icons/armorupgrades/armor.png")
                    elseif resType == "Thermal" then
                        ix.util.PropertyDesc4(tooltip, "Thermal: ", Color(255, 255, 255), resbuffval, resbuffColor, "materials/stalkerCoP/ui/icons/armorupgrades/thermprot.png")
                    elseif resType == "Chemical" then
                        ix.util.PropertyDesc4(tooltip, "Chemical: ", Color(255, 255, 255), resbuffval, resbuffColor, "materials/stalkerCoP/ui/icons/armorupgrades/chemprot.png")
                    elseif resType == "Electrical" then
                        ix.util.PropertyDesc4(tooltip, "Electrical: ", Color(255, 255, 255), resbuffval, resbuffColor, "materials/stalkerCoP/ui/icons/armorupgrades/elect.png")
                    end
				end

				-- Resistances debuffs
				local resdebuffval = math.floor(resValue * 10)
				if resValue < 0 then
                    if resType == "Impact" then
                        ix.util.PropertyDesc4(tooltip, "Impact: ", Color(255, 255, 255), resdebuffval, resdebuffColor, "materials/stalkerCoP/ui/icons/armorupgrades/armor.png")
                    elseif resType == "Thermal" then
                        ix.util.PropertyDesc4(tooltip, "Thermal: ", Color(255, 255, 255), resdebuffval, resdebuffColor, "materials/stalkerCoP/ui/icons/armorupgrades/thermprot.png")
                    elseif resType == "Chemical" then
                        ix.util.PropertyDesc4(tooltip, "Chemical: ", Color(255, 255, 255), resdebuffval, resdebuffColor, "materials/stalkerCoP/ui/icons/armorupgrades/chemprot.png")
                    elseif resType == "Electrical" then
                        ix.util.PropertyDesc4(tooltip, "Electrical: ", Color(255, 255, 255), resdebuffval, resdebuffColor, "materials/stalkerCoP/ui/icons/armorupgrades/elect.png")
                    end
				end
            end

			-- Debuffs
			local debuffval = "-" .. self.debuffval or 0
			local debuffcolor = Color(235, 0, 0)

            if self.debuff == "rads" then
                ix.util.PropertyDesc4(tooltip, "Radiation: ", Color(255, 255, 255), debuffval, debuffcolor, "materials/stalkerCoP/ui/icons/armorupgrades/rad.png")
            end

            if self.debuff == "endred" then
                ix.util.PropertyDesc4(tooltip, "Energy recovery: ", Color(255, 255, 255), debuffval, debuffcolor, "materials/stalkerCoP/ui/icons/armorupgrades/stamina.png")
            end

            if self.debuff == "bleeding" then
                ix.util.PropertyDesc4(tooltip, "Bleeding: ", Color(255, 255, 255), debuffval, debuffcolor, "materials/stalkerCoP/ui/icons/armorupgrades/bleeding2.png")
            end
        end

        tooltip:SizeToContents()
    end
end


function ITEM:OnLoadout()
	if self:GetData("equip") then
		self:SetData("equip", false)
	end
end
 
ITEM:Hook("drop", function(item)
    local client = item.player;
    local character = client:GetChar();

    if (item:GetData("equip")) then
        
        if item.buff == "heal" then 
            local curheal = character:GetData("ArtiHealAmt") or 0
            local newheal = (curheal - item.buffval)
            character:SetData("ArtiHealAmt", newheal)
        end
        
        if item.buff == "woundheal" then
            local curwheal = character:GetData("WoundHeal") or 0
            local newwheal = (curwheal - item.buffval)
            character:SetData("WoundHeal", newwheal)
        end
        
        if item.buff == "antirad" then
            local curantirad = character:GetData("AntiRads") or 0
            local newantirad = (curantirad - item.buffval)
            character:SetData("AntiRads", newantirad)
        end
        
        if item.buff == "endbuff" then
            client:RemoveBuff("buff_staminarestore")
        end

        if item.buff == "weight" then
           local curweight = character:GetData("WeightBuff") or 0
           local newweight = (curweight - item.buffval)
           character:SetData("WeightBuff",newweight)
        end
        
        if item.debuff == "rads" then
            local currads = character:GetData("Rads") or 0
            local newrads = (currads - item.debuffval) or 0
            character:SetData("Rads", newrads)
        end
        
        item:SetData("equip", nil);
    end;
end);

ITEM.functions.Equip = 
{
    name = "Equip",
    tip = "equipTip",
    icon = "icon16/tick.png",

    OnRun = function(item)
        local client = item.player
		local character = client:GetCharacter()
        
        if item.buff == "heal" then
            local curheal = character:GetData("ArtiHealAmt") or 0
			curheal = math.Clamp(curheal,0,1000)
            local newheal = (curheal + item.buffval)
            character:SetData("ArtiHealAmt", newheal)
        end
        
        if item.buff == "woundheal" then
            local curwheal = character:GetData("WoundHeal") or 0
			curwheal = math.Clamp(curwheal,0,1000)
            local newwheal = (curwheal + item.buffval)
            character:SetData("WoundHeal", newwheal)
        end
        
        if item.buff == "antirad" then
            local curantirad = character:GetData("AntiRads") or 0
			curantirad = math.Clamp(curantirad,0,1000)
            local newantirad = (curantirad + item.buffval)
            character:SetData("AntiRads", newantirad)
        end
        
        if item.buff == "endbuff" then
			client:AddBuff("buff_staminarestore", -1, { amount = item.buffval })
        end

        if item.buff == "weight" then
           local curweight = character:GetData("WeightBuff") or 0
		   curweight = math.Clamp(curweight,0,1000)
           local newweight = (curweight + item.buffval)
           character:SetData("WeightBuff",newweight)
        end

        if item.debuff == "rads" then
            local currads = character:GetData("Rads") or 0
			currads = math.Clamp(currads,0,1000)
            local newrads = (currads + item.debuffval)
            character:SetData("Rads", newrads)
        end
        
		if item.debuff == "bleeding" then
            local curbleed = character:GetData("Bleeding") or 0
			curbleed = math.Clamp(curbleed,0,1000)
            local newbleed = (curbleed + item.debuffval)
            character:SetData("Bleeding", newbleed)
			client:Notify("You are bleeding.")	-- Notify the player
		end

        item:SetData("equip", true)
        item:OnEquipped()
        return false
    end;
    
    OnCanRun = function(item)
        local client = item.player
		local character = client:GetCharacter()
		local artislots = character:GetData("ArtiSlots") or "0"
        local cap = util.StringToType(artislots, "int")
        local char = client:GetChar()
        local inv = char:GetInv()
        local items = inv:GetItems()
        local curr = 0
        
        for k, invItem in pairs(items) do
            if invItem.isArtefact and invItem:GetData("equip",false) then
                curr = curr + 1
            end
        end
        
        if cap > curr then
            return (!IsValid(item.entity) and !item:GetData("equip",false))
        else
            return false
        end
    end;
}

ITEM.functions.UnEquip =
{
    name = "Unequip",
    tip = "unequipTip",
    icon = "icon16/cross.png",

    OnRun = function(item)
        local client = item.player
		local character = client:GetCharacter()
        
        if item.buff == "heal" then
           local curheal = character:GetData("ArtiHealAmt") or 0
            local newheal = (curheal - item.buffval)
            character:SetData("ArtiHealAmt", newheal)
        end
        
        if item.buff == "woundheal" then
            local curwheal = character:GetData("WoundHeal") or 0
            local newwheal = (curwheal - item.buffval)
            character:SetData("WoundHeal", newwheal)
        end
        
        if item.buff == "antirad" then
            local curantirad = character:GetData("AntiRads") or 0
            local newantirad = (curantirad - item.buffval)
            character:SetData("AntiRads", newantirad)
        end
        
        if item.buff == "endbuff" then
            client:RemoveBuff("buff_staminarestore")
        end

        if item.buff == "weight" then
           local curweight = character:GetData("WeightBuff") or 0
           local newweight = (curweight - item.buffval)
           character:SetData("WeightBuff",newweight)
        end

        if item.debuff == "rads" then
            local currads = character:GetData("Rads") or 0
            local newrads = (currads - item.debuffval) or 0
            character:SetData("Rads", newrads)
        end
        
        item:SetData("equip", false)
		item:OnUnequipped()
        return false
    end;
    
    OnCanRun = function(item)
        return (!IsValid(item.entity) and item:GetData("equip") == true)
    end;
}

function ITEM:GetName()
    local name = self.name
    
    local customData = self:GetData("custom", {})
    if(customData.name) then
        name = customData.name
    end
    
    return name
end

ITEM.functions.Custom = {
    name = "Customize",
    tip = "Customize this item",
    icon = "icon16/wrench.png",
    OnRun = function(item)      
        ix.plugin.list["customization"]:startCustom(item.player, item)
        
        return false
    end,
    
    OnCanRun = function(item)
        local client = item.player
        return client:GetCharacter():HasFlags("N") and !IsValid(item.entity)
    end
}

ITEM.functions.Clone = {
    name = "Clone",
    tip = "Clone this item",
    icon = "icon16/wrench.png",
    OnRun = function(item)
        local client = item.player  
    
        client:requestQuery("Are you sure you want to clone this item?", "Clone", function(text)
            if text then
                local inventory = client:GetCharacter():GetInventory()
                
                if(!inventory:Add(item.uniqueID, 1, item.data)) then
                    client:Notify("Inventory is full")
                end
            end
        end)
        return false
    end,
    OnCanRun = function(item)
        local client = item.player
        return client:GetCharacter():HasFlags("N") and !IsValid(item.entity)
    end
}

if (CLIENT) then
	game.AddParticles("particles/vortigaunt_fx.pcf")
	PrecacheParticleSystem("vortigaunt_charge_token_d")
	
    function ITEM:DrawEntity(entity, item)
        if LocalPlayer():GetPos():Distance(entity:GetPos()) > 150 then
            entity:SetMaterial("models/shadertest/predator.vmt")
            entity:DrawShadow(false)
			entity:StopAndDestroyParticles()
        else
            entity:SetMaterial(null)
            entity:DrawShadow(true)
			local visualeffect = CreateParticleSystem(entity,"vortigaunt_charge_token_d",1)
			timer.Simple(3, function() if entity:IsValid() then entity:StopAndDestroyParticles() end end)
        end

        entity:DrawModel()
    end
    function ITEM:PaintOver(item, w, h)
        if (item:GetData("equip")) then
            surface.SetDrawColor(110, 255, 110, 255)
        else
            surface.SetDrawColor(255, 110, 110, 255)
        end

        surface.SetMaterial(item.equipIcon)
        surface.DrawTexturedRect(w-23,h-23,19,19)
    end
end

ITEM.functions.Sell = {
    icon = "icon16/coins.png",
    sound = "physics/metal/chain_impact_soft2.wav",
    OnRun = function(item)
        local client = item.player
		local character = client:GetCharacter()
		
        client:Notify( "Sold for "..(item.price/1.25).." rubles." )
        character:GiveMoney(item.price/1.25)
		
        if (item:GetData("equip")) then
			
			if item.buff == "heal" then
				local curheal = character:GetData("ArtiHealAmt") or 0
				local newheal = (curheal - item.buffval)
				character:SetData("ArtiHealAmt", newheal)
			end
			
			if item.buff == "woundheal" then
				local curwheal = character:GetData("WoundHeal") or 0
				local newwheal = (curwheal - item.buffval)
				character:SetData("WoundHeal", newwheal)
			end
			
			if item.buff == "antirad" then
				local curantirad = character:GetData("AntiRads") or 0
				local newantirad = (curantirad - item.buffval)
				character:SetData("AntiRads", newantirad)
			end
			
			if item.buff == "endbuff" then
				client:RemoveBuff("buff_staminarestore")
			end

			if item.buff == "weight" then
			   local curweight = character:GetData("WeightBuff") or 0
			   local newweight = (curweight - item.buffval)
			   character:SetData("WeightBuff",newweight)
			end
			
			if item.debuff == "rads" then
				local currads = character:GetData("Rads") or 0
				local newrads = (currads - item.debuffval) or 0
				character:SetData("Rads", newrads)
			end
			
			if item.debuff == "bleeding" then
				local curbleed = character:GetData("Bleeding") or 0
				local newbleed = (curbleed - item.debuffval)
				character:SetData("Bleeding", newbleed)
			end

			item:SetData("equip", nil);
		end;
    end,
    OnCanRun = function(item)
        return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1")
    end
}

ITEM.functions.Value = {
    icon = "icon16/help.png",
    sound = "physics/metal/chain_impact_soft2.wav",
    OnRun = function(item)
        local client = item.player
        client:Notify( "Item is sellable for "..(item.price/1.25).." rubles." )
        return false
    end,
    OnCanRun = function(item)
        return !IsValid(item.entity) and item:GetOwner():GetChar():HasFlags("1")
    end
}

function ITEM:OnEquipped()
    self.player:EmitSound("stalker/interface/inv_lead_open.ogg")
end

function ITEM:OnUnequipped()
    self.player:EmitSound("stalker/interface/inv_lead_close.ogg")
end