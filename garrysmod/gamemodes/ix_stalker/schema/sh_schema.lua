
-- The shared init file. You'll want to fill out the info for your schema and include any other files that you need.

-- Schema info
Schema.name = "S.T.A.L.K.E.R. RP"
Schema.author = "Zeta"
Schema.description = "Shouldn't have come here, Stalker..."
--Schema.logo = "vgui/background/wallpaper.jpg"

ix.util.Include("libs/thirdparty/sh_netstream2.lua")

-- Additional files that aren't auto-included should be included here. Note that ix.util.Include will take care of properly
-- using AddCSLuaFile, given that your files have the proper naming scheme.

-- You could technically put most of your schema code into a couple of files, but that makes your code a lot harder to manage -
-- especially once your project grows in size. The standard convention is to have your miscellaneous functions that don't belong
-- in a library reside in your cl/sh/sv_schema.lua files. Your gamemode hooks should reside in cl/sh/sv_hooks.lua. Logical
-- groupings of functions should be put into their own libraries in the libs/ folder. Everything in the libs/ folder is loaded
-- automatically.
ix.util.Include("cl_schema.lua")
ix.util.Include("sv_schema.lua")

ix.util.Include("cl_skin.lua")

ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_hooks.lua")
ix.util.Include("sv_hooks.lua")

-- You'll need to manually include files in the meta/ folder, however.
ix.util.Include("meta/sh_character.lua")
ix.util.Include("meta/sh_player.lua")
ix.util.Include("meta/sh_inventory.lua")
ix.util.Include("meta/sh_item.lua")

-- Define Flags
ix.flag.Add("A", "Admin")
ix.flag.Add("N", "Event/Customization")
ix.flag.Add("1", "T1 Trade.")
ix.flag.Add("2", "T2 Trade.")
ix.flag.Add("3", "T3 Trade.")
ix.flag.Add("5", "Consumables")
ix.flag.Add("6", "Armor Technician")
ix.flag.Add("7", "Weapon Technician")

ix.flag.Add("B", "Bandit trade")
ix.flag.Add("D", "Duty trade")
ix.flag.Add("E", "Ecologist/Malachite trade")
ix.flag.Add("K", "Mercenaries trade")
ix.flag.Add("M", "Monolith trade")
ix.flag.Add("U", "UKM/Military trade")
ix.flag.Add("V", "Freedom trade")


ALWAYS_RAISED["weapon_flashlight"] = true
ALWAYS_RAISED["stalker_bolt"] = true
ALWAYS_RAISED["detector_echo"] = true
ALWAYS_RAISED["detector_bear"] = true
ALWAYS_RAISED["detector_veles"] = true
ALWAYS_RAISED["guitar"] = true

ix.currency.symbol = "Ꝁ"
ix.currency.singular = "koupon"
ix.currency.plural = "koupons"


local stalker_models = {
--Admin models
	["models/nasca/stalker/admin_degtyarev.mdl"] = true,
	["models/nasca/stalker/admin_strelok.mdl"] = true,

--Male models
	["models/nasca/stalker/male_anorak.mdl"] = true, --Leather Jacket

	["models/nasca/stalker/male_trenchcoat.mdl"] = true, --Trenchcoat

	["models/nasca/stalker/male_sunrise_lone.mdl"] = true, --Sunrise
	["models/nasca/stalker/male_sunrise_eco.mdl"] = true,
	["models/silver/stalker/male_sunrise_bandit.mdl"] = true,
	["models/silver/stalker/male_sunrise_merc.mdl"] = true,

	["models/nasca/stalker/male_sunrise_mono.mdl"] = true, --Monolith Suit

	["models/nasca/stalker/male_midnight_lone.mdl"] = true, --Midnight Suit
	["models/nasca/stalker/male_psz9d_duty.mdl"] = true, --PSZ-5M Suit
	["models/nasca/stalker/male_psz9d_eco.mdl"] = true,
	["models/nasca/stalker/male_psz9d_free.mdl"] = true,

	["models/nasca/stalker/male_wind_free.mdl"] = true, --Wind of Freedom
	["models/nasca/stalker/male_wind_lone.mdl"] = true,

	["models/nasca/stalker/male_hawk_merc.mdl"] = true, --Mercenary Suit
	["models/nasca/stalker/male_hawk_bandit.mdl"] = true,
	["models/nasca/stalker/male_hawk_eco.mdl"] = true,
	["models/nasca/stalker/male_hawk_lone.mdl"] = true,
	["models/nasca/stalker/male_hawk_duty.mdl"] = true,

	["models/nasca/stalker/male_berill1.mdl"] = true, --Soldier Uniform

	["models/nasca/stalker/male_cs1a.mdl"] = true, --CS-1A
	["models/silver/stalker/male_cs1a_bandit.mdl"] = true,
	["models/silver/stalker/male_cs1a_duty.mdl"] = true,
	["models/silver/stalker/male_cs1a_free.mdl"] = true,
	["models/silver/stalker/male_cs1a_lone.mdl"] = true,

	["models/nasca/stalker/male_cs1b.mdl"] = true, --CS-1B
	["models/silver/stalker/male_cs1b_lone.mdl"] = true,
	["models/nasca/stalker/male_cs2.mdl"] = true, --CS-2
	["models/nasca/stalker/male_cs3a.mdl"] = true, --CS-3A
	["models/nasca/stalker/male_cs3b.mdl"] = true, --CS-3B

	["models/nasca/stalker/male_berill5m_mili.mdl"] = true, --Berill-5M
	["models/nasca/stalker/male_berill5m_free.mdl"] = true, --Guardian of Freedom
	["models/nasca/stalker/male_berill5m_duty.mdl"] = true,
	["models/nasca/stalker/male_berill5m_eco.mdl"] = true,
	["models/nasca/stalker/male_berill5m_lone.mdl"] = true,

	["models/nasca/stalker/male_seva_eco.mdl"] = true,  --SEVA Suit
	["models/nasca/stalker/male_seva_free.mdl"] = true,
	["models/nasca/stalker/male_seva_duty.mdl"] = true,
	["models/nasca/stalker/male_seva_merc.mdl"] = true,
	["models/nasca/stalker/male_seva_mono.mdl"] = true, --Monolith Scientific

	["models/nasca/stalker/male_ssp_eco.mdl"] = true, --SSP-99/SSP-99M

	["models/nasca/stalker/male_stingray9_mili.mdl"] = true, --Stingray-9
	["models/nasca/stalker/male_stingray9_eco.mdl"] = true,
	["models/nasca/stalker/male_stingray9_free.mdl"] = true,
	["models/nasca/stalker/male_stingray9_lone.mdl"] = true,
	["models/nasca/stalker/male_stingray9_mono.mdl"] = true,

	["models/nasca/stalker/male_stingray9m.mdl"] = true, --Stingray-9M

	["models/nasca/stalker/male_psz12d_duty.mdl"] = true, --PSZ-12
	["models/nasca/stalker/male_psz12d_lone.mdl"] = true,

	["models/nasca/stalker/male_exo_lone.mdl"] = true, --Radiation Suit/Exoskeleton
	["models/nasca/stalker/male_exo_free.mdl"] = true,
	["models/nasca/stalker/male_exo_eco.mdl"] = true,
	["models/nasca/stalker/male_exo_duty.mdl"] = true,
	["models/nasca/stalker/male_exo_merc.mdl"] = true,
	["models/nasca/stalker/male_exo_mili.mdl"] = true,
	["models/nasca/stalker/male_exo_mono.mdl"] = true,
	["models/nasca/stalker/male_exo_bandit.mdl"] = true,

	["models/nasca/stalker/male_dusk_duty.mdl"] = true, --Dusk Suit
	["models/nasca/stalker/male_dusk_eco.mdl"] = true,
	["models/nasca/stalker/male_dusk_free.mdl"] = true,
	["models/nasca/stalker/male_dusk_lone.mdl"] = true,
	["models/nasca/stalker/male_dusk_lone2.mdl"] = true,
	["models/nasca/stalker/male_dusk_mono.mdl"] = true,

	["models/nasca/stalker/male_eagle_merc.mdl"] = true, --Eagle Suit
	["models/nasca/stalker/male_eagle_lone.mdl"] = true,
	["models/nasca/stalker/male_eagle_free.mdl"] = true,
	["models/nasca/stalker/male_eagle_duty.mdl"] = true,
	["models/nasca/stalker/male_eagle_bandit.mdl"] = true,

	["models/nasca/stalker/male_expedition.mdl"] = true, --Expedition Suit

	["models/nasca/stalker/male_gagarin.mdl"] = true, --Gagarin

	["models/nasca/stalker/male_jupiter_duty.mdl"] = true, --Jupiter
	["models/nasca/stalker/male_jupiter_eco.mdl"] = true,

	["models/nasca/stalker/male_nbc_duty.mdl"] = true, --NBC Suit
	["models/nasca/stalker/male_nbc_free.mdl"] = true,
	["models/nasca/stalker/male_nbc_lone.mdl"] = true,
	["models/nasca/stalker/male_nbc_mono.mdl"] = true,
	["models/silver/stalker/male_nbc_eco.mdl"] = true,
	["models/silver/stalker/male_nbc_bandit.mdl"] = true,

	["models/nasca/stalker/male_sunset_duty.mdl"] = true, --Sunset Suit
	["models/nasca/stalker/male_sunset_eco.mdl"] = true,
	["models/nasca/stalker/male_sunset_free.mdl"] = true,
	["models/nasca/stalker/male_sunset_lone.mdl"] = true,
	["models/nasca/stalker/male_sunset_mono.mdl"] = true,

--Female models
	["models/nasca/stalker/female_anorak.mdl"] = true, --Fem Leather Jacket

	["models/nasca/stalker/female_expedition.mdl"] = true, --Fem Expedition Suit

	["models/nasca/stalker/female_midnight_lone.mdl"] = true, --Fem Midnight Suit
	["models/nasca/stalker/female_psz9d_duty.mdl"] = true, --Fem PS5-M Suit
	["models/nasca/stalker/female_psz9d_eco.mdl"] = true,
	["models/nasca/stalker/female_psz9d_free.mdl"] = true,

	["models/nasca/stalker/female_sunrise_eco.mdl"] = true, --Fem Sunrise Suit
	["models/nasca/stalker/female_sunrise_lone.mdl"] = true,
	["models/nasca/stalker/female_sunrise_mono.mdl"] = true,
	["models/silver/stalker/female_sunrise_bandit.mdl"] = true,
	["models/silver/stalker/female_sunrise_merc.mdl"] = true,

	["models/nasca/stalker/female_wind_free.mdl"] = true, --Fem Wind of Freedom
	["models/nasca/stalker/female_wind_lone.mdl"] = true,

	["models/silver/stalker/female_dusk_mono.mdl"] = true, -- Fem Dusk Suit
	["models/silver/stalker/female_dusk_lone2.mdl"] = true,
	["models/silver/stalker/female_dusk_lone.mdl"] = true,
	["models/silver/stalker/female_dusk_free.mdl"] = true,
	["models/silver/stalker/female_dusk_duty.mdl"] = true,
	["models/silver/stalker/female_dusk_eco.mdl"] = true,

	["models/silver/stalker/female_cs1a_bandit.mdl"] = true, --Fem CS-1A
	["models/silver/stalker/female_cs1a_duty.mdl"] = true,
	["models/silver/stalker/female_cs1a_free.mdl"] = true,
	["models/silver/stalker/female_cs1a_lone.mdl"] = true,

	["models/silver/stalker/female_cs1b_lone.mdl"] = true, --Fem CS-1B
	["models/silver/stalker/female_cs2_lone.mdl"] = true, --Fem CS-2
	["models/silver/stalker/female_cs3a_lone.mdl"] = true, --Fem CS-3A

	["models/silver/stalker/female_nbc_bandit.mdl"] = true, --Fem NBC Suit
	["models/silver/stalker/female_nbc_duty.mdl"] = true,
	["models/silver/stalker/female_nbc_eco.mdl"] = true,
	["models/silver/stalker/female_nbc_free.mdl"] = true,
	["models/silver/stalker/female_nbc_lone.mdl"] = true,
	["models/silver/stalker/female_nbc_mono.mdl"] = true,

	["models/silver/stalker/female_seva_duty.mdl"] = true, --Fem SEVA Suit
	["models/silver/stalker/female_seva_eco.mdl"] = true,
	["models/silver/stalker/female_seva_free.mdl"] = true,
	["models/silver/stalker/female_seva_lone.mdl"] = true,
	["models/silver/stalker/female_seva_merc.mdl"] = true,
	["models/silver/stalker/female_seva_mono.mdl"] = true,

	["models/silver/stalker/female_ssp_eco.mdl"] = true, --Fem SSP-9

	["models/silver/stalker/female_sunset_duty.mdl"] = true, --Fem Sunset Suit
	["models/silver/stalker/female_sunset_eco.mdl"] = true,
	["models/silver/stalker/female_sunset_free.mdl"] = true,
	["models/silver/stalker/female_sunset_lone.mdl"] = true,
	["models/silver/stalker/female_sunset_mono.mdl"] = true,
}

for k, v in pairs(stalker_models) do
	player_manager.AddValidModel("stalker_default", k)
	ix.anim.SetModelClass(k, "player")
	util.PrecacheModel(k)
end

player_manager.AddValidHands( "stalker_default", "models/weapons/c_arms_refugee.mdl", 0, "01" )