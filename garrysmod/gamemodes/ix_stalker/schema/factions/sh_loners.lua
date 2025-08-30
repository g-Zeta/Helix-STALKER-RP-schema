
-- You can define factions in the factions/ folder. You need to have at least one faction that is the default faction - i.e the
-- faction that will always be available without any whitelists and etc.

FACTION.name = "Loners"
FACTION.description = "Stalkers exploring the Zone on their own. Most stalkers work this way since being a member of a group takes precious time, and part of the loot. Then there are some who simply prefer solitude and independence."
FACTION.isDefault = true
FACTION.color = Color(160, 130, 60)
FACTION.models = {
	{"models/nasca/stalker/male_anorak.mdl", 0, "000002"},
	{"models/nasca/stalker/female_anorak.mdl", 0, "000002"},

}

-- You should define a global variable for this faction's index for easy access wherever you need. FACTION.index is
-- automatically set, so you can simply assign the value.

-- Note that the player's team will also have the same value as their current character's faction index. This means you can use
-- client:Team() == FACTION_CITIZEN to compare the faction of the player's current character.
FACTION_STALKERS = FACTION.index

FACTION.patch = "stalker2/ui/faction patches/loners.png"