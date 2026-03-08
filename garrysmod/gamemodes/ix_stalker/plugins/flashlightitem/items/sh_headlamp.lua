ITEM.name = "Headlamp"
ITEM.model = "models/jerry/items/headtorch.mdl"
ITEM.description = "A standard flashlight that can be mounted on the head or a helmet."

ITEM.width = 1
ITEM.height = 1

ITEM.flag = "1"
ITEM.price = 2000

ITEM.category = "Electronics"

ITEM.repairCost = ITEM.price/100*1
ITEM.weight = 0.25
ITEM.isFlashlight = true

ITEM.pacData = {
[1] = {
	["children"] = {
		[1] = {
			["children"] = {
				[1] = {
					["children"] = {
						[1] = {
							["children"] = {
								[1] = {
									["children"] = {
									},
									["self"] = {
										["DynamicsStartAlpha"] = 1,
										["UniqueID"] = "97c374798baba01e8eb862a7a27ca8166cb485b19eabb23845827540d5449c0d",
										["SizeFadeSpeed"] = 1,
										["AimPartName"] = "",
										["IgnoreZ"] = false,
										["DynamicsEndSizeMultiplier"] = 1,
										["AimPartUID"] = "",
										["Notes"] = "",
										["Name"] = "",
										["NoTextureFiltering"] = false,
										["PositionOffset"] = Vector(0, 0, 0),
										["IsDisturbing"] = false,
										["Translucent"] = true,
										["DrawOrder"] = 0,
										["TargetEntityUID"] = "",
										["Alpha"] = 1,
										["SizeX"] = 1,
										["SizeY"] = 1,
										["Bone"] = "head",
										["AlphaFadePower"] = 1,
										["SizeFadePower"] = 1,
										["EnableDynamics"] = false,
										["Position"] = Vector(0, 0, 0),
										["SpritePath"] = "sprites/physg_glow1",
										["BlendMode"] = "",
										["Hide"] = false,
										["AngleOffset"] = Angle(0, 0, 0),
										["Color"] = Vector(255, 255, 255),
										["ClassName"] = "sprite",
										["EditorExpand"] = false,
										["Size"] = 7,
										["EyeAngles"] = false,
										["AlphaFadeSpeed"] = 1,
										["Angles"] = Angle(0, 0, 0),
										["DynamicsEndAlpha"] = 1,
										["DynamicsStartSizeMultiplier"] = 1,
									},
								},
								[2] = {
									["children"] = {
									},
									["self"] = {
										["AffectChildrenOnly"] = false,
										["DrawOrder"] = 0,
										["UniqueID"] = "6cd894b2c20521e5907d959521e96c64b37c33be01cca9e6adf7c9c788c56720",
										["TargetEntityUID"] = "",
										["Arguments"] = "",
										["EditorExpand"] = false,
										["ClassName"] = "event",
										["Notes"] = "",
										["Hide"] = false,
										["Name"] = "",
										["Invert"] = true,
										["RootOwner"] = true,
										["Event"] = "is_flashlight_on",
										["DestinationPartUID"] = "",
										["MultipleTargetParts"] = "",
										["IsDisturbing"] = false,
										["Operator"] = "find simple",
										["ZeroEyePitch"] = false,
										["TargetPartUID"] = "",
									},
								},
							},
							["self"] = {
								["Skin"] = 0,
								["UniqueID"] = "4ed42841373cee4f5a87646bc3333e3d35c9b77e1b84e12d16a282bd9928fb98",
								["NoLighting"] = false,
								["AimPartName"] = "",
								["IgnoreZ"] = false,
								["AimPartUID"] = "",
								["Notes"] = "",
								["Materials"] = "",
								["Name"] = "light source",
								["LevelOfDetail"] = 0,
								["NoTextureFiltering"] = false,
								["PositionOffset"] = Vector(0, 0, 0),
								["IsDisturbing"] = false,
								["EyeAngles"] = true,
								["DrawOrder"] = 0,
								["TargetEntityUID"] = "",
								["Alpha"] = 0,
								["Material"] = "",
								["Invert"] = false,
								["ForceObjUrl"] = false,
								["Bone"] = "head",
								["Color"] = Vector(1, 1, 1),
								["AngleOffset"] = Angle(0, 0, 0),
								["BoneMerge"] = false,
								["Angles"] = Angle(-180, 0, 0),
								["Position"] = Vector(-7, 3, 0.80000001192093),
								["ClassName"] = "model2",
								["NoCulling"] = false,
								["Hide"] = false,
								["Brightness"] = 1,
								["Scale"] = Vector(1, 1, 1),
								["LegacyTransform"] = false,
								["EditorExpand"] = true,
								["Size"] = 0,
								["Translucent"] = false,
								["BlendMode"] = "",
								["ModelModifiers"] = "",
								["EyeTargetUID"] = "",
								["Model"] = "models/pac/default.mdl",
							},
						},
					},
					["self"] = {
						["Skin"] = 0,
						["UniqueID"] = "90f03f3b7500e10510a44bb9706ea36f3f5fd3fafcc6f3a08cbb33a091c2f23c",
						["NoLighting"] = false,
						["AimPartName"] = "",
						["IgnoreZ"] = false,
						["AimPartUID"] = "",
						["Notes"] = "",
						["Materials"] = "",
						["Name"] = "",
						["LevelOfDetail"] = 0,
						["NoTextureFiltering"] = false,
						["PositionOffset"] = Vector(0, 0, 0),
						["IsDisturbing"] = false,
						["EyeAngles"] = false,
						["DrawOrder"] = 0,
						["TargetEntityUID"] = "",
						["Alpha"] = 1,
						["Material"] = "",
						["Invert"] = false,
						["ForceObjUrl"] = false,
						["Bone"] = "head",
						["Color"] = Vector(1, 1, 1),
						["AngleOffset"] = Angle(0, 0, 0),
						["BoneMerge"] = false,
						["Angles"] = Angle(0, 100, 90),
						["Position"] = Vector(5, -2, 0),
						["ClassName"] = "model2",
						["NoCulling"] = false,
						["Hide"] = false,
						["Brightness"] = 1,
						["Scale"] = Vector(1, 1, 1),
						["LegacyTransform"] = false,
						["EditorExpand"] = true,
						["Size"] = 0.9,
						["Translucent"] = false,
						["BlendMode"] = "",
						["ModelModifiers"] = "",
						["EyeTargetUID"] = "",
						["Model"] = "models/jerry/headtorch.mdl",
					},
				},
			},
			["self"] = {
				["UniqueID"] = "6785126e2a0ed0f8088dfe43a39913b2c7980d48b332eef68dc6ff27017be173",
				["Name"] = "headlamp",
				["EditorExpand"] = true,
				["ClassName"] = "group",
			},
		},
		[2] = {
			["children"] = {
				[1] = {
					["children"] = {
					},
					["self"] = {
						["AffectChildrenOnly"] = false,
						["DrawOrder"] = 0,
						["UniqueID"] = "0e75fdcfdd0dc016febb04190a60cf0b6994d10c6169744e52069242bca332c6",
						["TargetEntityUID"] = "",
						["Arguments"] = "",
						["EditorExpand"] = true,
						["ClassName"] = "event",
						["Notes"] = "",
						["Hide"] = false,
						["Name"] = "",
						["Invert"] = true,
						["RootOwner"] = true,
						["Event"] = "is_flashlight_on",
						["DestinationPartUID"] = "",
						["MultipleTargetParts"] = "",
						["IsDisturbing"] = false,
						["Operator"] = "find simple",
						["ZeroEyePitch"] = false,
						["TargetPartUID"] = "",
					},
				},
				[2] = {
					["children"] = {
					},
					["self"] = {
						["FollowAnglesOnly"] = false,
						["DrawOrder"] = 0,
						["UniqueID"] = "5cabb1e25e75882fbde5d9c63248bf58791832b067ecd2ba9a3b4fee58fb66e3",
						["TargetEntityUID"] = "",
						["AimPartName"] = "",
						["FollowPartUID"] = "9fce1e0c87fc3e7d4505e950662a17729fdacd077c79aa3cff9114d2dce5db94",
						["Bone"] = "attach right hand",
						["InvertHideMesh"] = false,
						["ScaleChildren"] = false,
						["MoveChildrenToOrigin"] = false,
						["Angles"] = Angle(90, 0, 0),
						["Position"] = Vector(0, 0, 0),
						["AimPartUID"] = "",
						["Notes"] = "",
						["Hide"] = false,
						["Name"] = "",
						["Scale"] = Vector(1, 1, 1),
						["EditorExpand"] = true,
						["AngleOffset"] = Angle(0, 0, 0),
						["Size"] = 1,
						["PositionOffset"] = Vector(0, 0, 0),
						["IsDisturbing"] = false,
						["ClassName"] = "bone3",
						["EyeAngles"] = false,
						["HideMesh"] = false,
					},
				},
				[3] = {
					["children"] = {
						[1] = {
							["children"] = {
							},
							["self"] = {
								["NoTextureFiltering"] = false,
								["DrawOrder"] = 0,
								["UniqueID"] = "a940014a7b63da023b3e539fc3bf4d08c741023d97201025ec54e7fbffd367db",
								["Translucent"] = false,
								["IgnoreZ"] = false,
								["IsDisturbing"] = false,
								["TargetEntityUID"] = "",
								["VerticalFOV"] = 90,
								["Texture"] = "effects/flashlight/soft",
								["FOV"] = 90,
								["FarZ"] = 800,
								["AimPartName"] = "",
								["TextureFrame"] = 0,
								["Bone"] = "head",
								["BlendMode"] = "",
								["Orthographic"] = false,
								["EditorExpand"] = false,
								["NearZ"] = 1,
								["Position"] = Vector(0, -18, 0),
								["AimPartUID"] = "",
								["Notes"] = "",
								["Hide"] = false,
								["Name"] = "",
								["EyeAngles"] = false,
								["AngleOffset"] = Angle(0, 0, 0),
								["ClassName"] = "projected_texture",
								["HorizontalFOV"] = 90,
								["PositionOffset"] = Vector(0, 0, 0),
								["Color"] = Vector(1, 0.95686274766922, 0.839215695858),
								["Angles"] = Angle(0, 0, 0),
								["Brightness"] = 1,
								["Shadows"] = true,
							},
						},
					},
					["self"] = {
						["Skin"] = 0,
						["UniqueID"] = "9fce1e0c87fc3e7d4505e950662a17729fdacd077c79aa3cff9114d2dce5db94",
						["NoLighting"] = false,
						["AimPartName"] = "",
						["IgnoreZ"] = false,
						["AimPartUID"] = "",
						["Notes"] = "",
						["Materials"] = "",
						["Name"] = "light bone",
						["LevelOfDetail"] = 0,
						["NoTextureFiltering"] = false,
						["PositionOffset"] = Vector(0, 0, 0),
						["IsDisturbing"] = false,
						["EyeAngles"] = true,
						["DrawOrder"] = 0,
						["TargetEntityUID"] = "",
						["Alpha"] = 1,
						["Material"] = "",
						["Invert"] = false,
						["ForceObjUrl"] = false,
						["Bone"] = "head",
						["Color"] = Vector(1, 1, 1),
						["AngleOffset"] = Angle(0, 0, 0),
						["BoneMerge"] = false,
						["Angles"] = Angle(0, 0, 0),
						["Position"] = Vector(6.9000000953674, -8.1999998092651, 3.0999999046326),
						["ClassName"] = "model2",
						["NoCulling"] = false,
						["Hide"] = false,
						["Brightness"] = 1,
						["Scale"] = Vector(1, 1, 1),
						["LegacyTransform"] = false,
						["EditorExpand"] = true,
						["Size"] = 0,
						["Translucent"] = false,
						["BlendMode"] = "",
						["ModelModifiers"] = "",
						["EyeTargetUID"] = "",
						["Model"] = "models/pac/default.mdl",
					},
				},
			},
			["self"] = {
				["UniqueID"] = "2f0c31d3b8725ffdc4170275da7f8fa48518a584d3b885dbcf79fb10b3085f63",
				["Name"] = "bone",
				["EditorExpand"] = true,
				["ClassName"] = "group",
			},
		},
	},
	["self"] = {
		["UniqueID"] = "fe6fb3bece4ad0d0168398cff82dfe5e8db4ad04b2d4fd39cb25f3c9d86eb556",
		["EditorExpand"] = true,
		["ClassName"] = "group",
	},
},
}

ITEM:Hook("drop", function(item)
	if (item:GetData("equip") == true) then
		local owner = item:GetOwner()
		item:SetData("equip", false)

		if (IsValid(owner)) then
			owner:RemovePart(item.uniqueID)
		end
	end
end)

ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "stalkerCoP/ui/icons/misc/equip.png",
	OnRun = function(item)
		item:SetData("equip", true)
		item.player:AddPart(item.uniqueID, item)
		item.player:EmitSound("stalker/inventory/inv_slot.mp3")
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetData("equip") != true
	end
}

ITEM.functions.EquipUn = {
	name = "Unequip",
	tip = "equipTip",
	icon = "stalkerCoP/ui/icons/misc/unequip.png",
	OnRun = function(item)
		item:SetData("equip", false)
		item.player:RemovePart(item.uniqueID)
		item.player:EmitSound("stalker/inventory/inv_slot.mp3")
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetData("equip") == true
	end
}

ITEM.functions.Sell = {
	name = "Sell",
	icon = "stalkerCoP/ui/icons/misc/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item.price/2
		sellprice = math.Round(sellprice)
		client:Notify( "Sold for "..(sellprice).." rubles." )
		client:GetCharacter():GiveMoney(sellprice)
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1")
	end
}

ITEM.functions.Value = {
	name = "Value",
	icon = "icon16/help.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item.price/2
		sellprice = math.Round(sellprice)
		client:Notify( "Item is sellable for "..(sellprice).." rubles." )
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1")
	end
}
