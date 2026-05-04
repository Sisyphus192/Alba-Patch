# Alba - Patch

A patch mod for [**Alba**](https://steamcommunity.com/sharedfiles/filedetails/?id=3302266996) by lukeh_ro, for *Stranded: Alien Dawn*. Loads alongside Alba and applies behavioral bug fixes without modifying any of the upstream mod's files.

## What's fixed

- **`ChangeCrops` [LUA ERROR] on every game start.** Upstream's `Code/AlbaVegetation.lua:ChangeCrops` indexes `Resources.Potato.SpecificToRegions` and `.Tomato.SpecificToRegions`, but vanilla `Resource.SpecificToRegions` defaults to `false` (boolean) — the index crashes with `attempt to index a boolean value` and aborts the rest of the function on every `GameTimeStart` and `PostLoadGame`.
- **Winemaking research never unlocks from CactusFruit harvests on Alba** (Steam: Omega13 2025-09-30). Upstream adds `CactusFruit -> Fruits` to live tables but doesn't sync `ResourceInGroupIds` (a frozen cache built by `PreProcessResources` at `DataLoaded` time). The harvest-cascade unlock walks that cache, so it never reaches `Fruits` and Winemaking stays gated.
- **Berrycone discovery shows the wrong inline icon** (Steam: sirbuche 2025-04-06). `Tech.FieldBerrycone` Description used `res_heptagonian_honey`; should be `res_tomatoes` (matches the Beefberries display name and the TradeDescription line, which was already correct).
- **Geyser placement bias around Energy Crystals.** Upstream's `Alba_AddGeysers` uses `(-1 * geyser_random(2))` which always evaluates to {-1, 0}, biasing all new geysers toward negative axes (or to origin); correct form is `(-1 + 2 * geyser_random(2))` ({-1, +1}).
- **`SavegameFixups.AddGeysers` fires on non-Alba saves.** Upstream registers the geyser-placement confirmation dialog without a region check, so loading any non-Alba save with the mod installed prompts the player to add geysers.
- **Hypothermic-but-relaxed survivors near a working bonfire don't get the cold-resistance buff** (Steam: MommyDearest 2025-03-04). Upstream's `BonfireWarmUp` relaxation routine only fires when the survivor's Relaxation need is low enough to seek one out, stranding survivors who are hypothermic AND already relaxed (just slept, just kicked a snowman, etc.).

## Why a patch (not a fork)

lukeh_ro is the active maintainer of Alba; their Workshop entry stays canonical. This patch sits alongside Alba and applies fixes via:

1. `ModItemChangeProp` (CommonLib's stack-composing preset edit) for the Berrycone icon.
2. Top-level reassignment of globals (`Alba_AddGeysers`, `SavegameFixups.AddGeysers`).
3. Additive `OnMsg` handlers for crash prevention, the unlock cascade, and bonfire warmth.

None of these touch Alba's source files. lukeh_ro can merge any fix upstream later without forcing a republish or coordinating with this patch.

## Installation

1. Subscribe via Steam Workshop, **or** clone this repo into:
   ```
   %APPDATA%\Stranded - Alien Dawn\Mods\Alba - Patch\
   ```
   (Windows path; on Linux/Proton, `~/.steam/steam/steamapps/compatdata/1324130/pfx/drive_c/users/steamuser/AppData/Roaming/Stranded - Alien Dawn/Mods/`.)
2. Enable **Alba - Patch** in the in-game Mod Manager.

### Required dependencies

- **[Alba](https://steamcommunity.com/sharedfiles/filedetails/?id=3302266996)** by lukeh_ro — the mod this patches. The Mod Manager will warn if it's missing.
- **[SAD_CommonLib](https://steamcommunity.com/sharedfiles/filedetails/?id=3115193939)** — provides the `ModItemChangeProp` helper this patch uses.

## Compatibility notes

- **Composition-safe.** The patch never modifies upstream Alba's files and uses only additive primitives, so it composes cleanly with any other mod that touches the same buildings or presets.
- **Load order.** The patch declares Alba as a `ModDependency`, so the Mod Manager loads it after Alba; the additive `OnMsg.GameTimeStart` / `PostLoadGame` handlers run after Alba's matching handlers (which is what the post-fix logic relies on).
- **Achievements.** Subscribers running this patch alongside Alba still earn Steam achievements normally.

## Known limitations

- The two `[Warning] Invalid location of particle texture` lines that upstream Alba produces (for `Mod/LH_Alba/GeyserSteam.dds` and `GeyserWater.dds`) are emitted at preset-load time, before any `OnMsg` handler runs. A patch mod cannot silence them. They're cosmetic — the particle effects still play correctly. Fix has to come from upstream moving the textures into `Textures/Particles/` and updating the `texture` field paths.
- The `OnMsg.ModsReloaded` operator-precedence bug in upstream's `const_PlantTempDamagePerDay` recapture guard (`AlbaVegetation.lua:307` in the pre-fix version) is not patched here. It only affects mid-session region switches between Alba and non-Alba games, an edge case.

## Credits

- **lukeh_ro** — Alba mod, all gameplay/content design.
- **Sisyphus192** — bug investigation and patch implementation.
- **injto4ka and the SAD modding community** — [SAD_CommonLib](https://gitlab.com/injto4ka/sad_commonlib), which provides the `ModItemChangeProp` composition primitive this patch relies on.
- **Steam community** — Omega13, sirbuche, MommyDearest, who reported the issues this patch addresses.

## License

Code authored in this patch is released under the same terms as the upstream Alba mod. The patch does not redistribute any of Alba's content; it only references public preset ids and method names. Do not redistribute outside of Steam Workshop without contacting the upstream Alba author.
