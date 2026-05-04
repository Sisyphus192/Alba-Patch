return PlaceObj('ModDef', {
	'title', "Alba - Patch",
	'image', "Mod/LH_Alba_patch/UI/Alba.png",
	'description', "Bug fixes for [b]Alba[/b] by lukeh_ro. Loads alongside Alba and patches issues without modifying the original.\n\n[h2]For players[/h2]- Fixes a Lua error that appeared every time you started or loaded an Alba save\n- [b]Winemaking research now unlocks[/b] after harvesting CactusFruit on Alba (applies retroactively to existing saves where you've already harvested some)\n- [b]Berrycone (Green tube plant) research[/b] now shows the correct fruit icon (Beefberries) instead of Heptagonian Honey\n- [b]Geysers spawn evenly around Energy Crystals[/b] instead of biasing toward one side\n- The \"Add geysers to the current map?\" popup no longer appears when loading non-Alba saves\n- [b]Working bonfires now keep nearby hypothermic survivors warm[/b] even when those survivors aren't actively seeking relaxation, fixes survivors freezing next to a working bonfire after they just finished a relaxing activity\n\n[b]Known unpatchable (needs upstream fix in Alba):[/b]\n- Particle texture path warnings (GeyserSteam, GeyserWater): Mod/LH_Alba/*.dds paths are validated at preset-load time, before any OnMsg can run, so a dependent patch can't silence them. Cosmetic only — the effects still play. Upstream fix is to move the .dds files into Textures/Particles/ and update the texture field paths in items.lua.\n\n[b]Requires[/b] [url=https://steamcommunity.com/sharedfiles/filedetails/?id=3302266996]Alba[/url] and [url=https://steamcommunity.com/sharedfiles/filedetails/?id=3115193939]SAD_CommonLib[/url].",
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
	'version', 3,
	'lua_revision', 233360,
	'saved_with_revision', 373414,
	'code', {
		"Code/AlbaPatch.lua",
	},
	'has_data', true,
	'saved', 1777923226,
	'code_hash', 2376068425946428255,
	'steam_id', "3720041593",
	'TagGameplay', true,
	'TagOther', true,
})