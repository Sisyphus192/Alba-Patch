return PlaceObj('ModDef', {
	'title', "Alba - Patch",
	'description', "Bug fixes for [b]Alba[/b] by lukeh_ro. Loads alongside Alba and patches issues without modifying the original.\n\n[h2]For players[/h2]- Fixes a Lua error that appeared every time you started or loaded an Alba save\n- [b]Winemaking research now unlocks[/b] after harvesting CactusFruit on Alba (applies retroactively to existing saves where you've already harvested some)\n- [b]Berrycone (Green tube plant) research[/b] now shows the correct fruit icon (Beefberries) instead of Heptagonian Honey\n- [b]Geysers spawn evenly around Energy Crystals[/b] instead of biasing toward one side\n- The \"Add geysers to the current map?\" popup no longer appears when loading non-Alba saves\n- [b]Working bonfires now keep nearby hypothermic survivors warm[/b] even when those survivors aren't actively seeking relaxation — fixes survivors freezing next to a working bonfire after they just finished a relaxing activity\n\n[h2]For developers[/h2]- ALBA-1: ChangeCrops [LUA ERROR] crash on game start — pre-init Resources.Potato/Tomato.SpecificToRegions to {} on DataLoaded/ModsReloaded/NewGame/LoadGame, reset to false in additive GameTimeStart/PostLoadGame\n- ALBA-2: Geyser placement axis-sign bias — corrected (-1 * geyser_random(2)) to (-1 + 2 * geyser_random(2)) via top-level Alba_AddGeysers reassignment\n- ALBA-3: SavegameFixups.AddGeysers region-guarded via top-level reassignment\n- STEAM-1: Winemaking unlock cascade — sync ResourceInGroupIds.CactusFruit cache + retroactive UIPlayer:UnlockResource(\"Fruits\")\n- STEAM-2: Tech.FieldBerrycone.Description via ModItemChangeProp (res_heptagonian_honey → res_tomatoes; same T-id 885630558832 to keep localizations valid)\n- Bonfire passive warmth: region-gated MapGameTimeRepeat sweep applies BonfireColdResistance to humans within RadiationRange carrying any Hypothermia_* health condition\n\n[b]Requires[/b] [url=https://steamcommunity.com/sharedfiles/filedetails/?id=3302266996]Alba[/url] and [url=https://steamcommunity.com/sharedfiles/filedetails/?id=3115193939]SAD_CommonLib[/url].",
	'last_changes', "Initial release",
	'dependencies', {
		PlaceObj('ModDependency', {
			'id', "LH_Alba",
			'title', "Alba",
			'version_major', 1,
			'version_minor', 34,
		}),
		PlaceObj('ModDependency', {
			'id', "sad_commonlib",
			'title', "SAD_CommonLib",
		}),
	},
	'id', "LH_Alba_patch",
	'author', "Sisyphus192",
	'version_major', 1,
	'version', 2,
	'lua_revision', 233360,
	'saved_with_revision', 373414,
	'code', {
		"Code/AlbaPatch.lua",
	},
	'has_data', true,
	'saved', 1777921443,
	'code_hash', 2376068425946428255,
	'TagGameplay', true,
	'TagOther', true,
})