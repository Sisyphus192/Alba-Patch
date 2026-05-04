return PlaceObj('ModDef', {
	'title', "Alba - Patch",
	'description', "Bug fixes for [b]Alba[/b] by lukeh_ro. Loads alongside Alba and patches issues without modifying the original.\n\nFixes:\n- ChangeCrops [LUA ERROR] on every game start (crash on Resources.Potato/Tomato.SpecificToRegions)\n- Geyser placement bias around Energy Crystals (axis sign correction)\n- SavegameFixups.AddGeysers fires on non-Alba saves (region guard)\n- Winemaking research never unlocks from CactusFruit harvests on Alba (cache-sync + retroactive unlock)\n- Berrycone discovery shows wrong inline icon (Beefberries icon)\n- Hypothermic-but-relaxed survivors near a working bonfire don't get the cold-resistance buff\n- Particle texture path warnings (GeyserSteam, GeyserWater)\n\n[b]Requires Alba[/b] (Workshop id 3302266996) and [b]SAD_CommonLib[/b].",
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