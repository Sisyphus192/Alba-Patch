# Publishing to Steam Workshop

The in-game Mod Editor handles packing and uploading in one step. There is no separate `hpk.exe` step — the Mod Editor builds the `.hpk` and pushes it to Steam Workshop when you click Upload.

## Prerequisites

- Stranded: Alien Dawn installed via Steam.
- Steam logged in to the account that should own the Workshop submission.
- The mod folder lives at `%APPDATA%\Stranded - Alien Dawn\Mods\Alba - Patch\` (this clone — local mods override Workshop subscriptions of the same id).

## First-time publish

1. Launch *Stranded: Alien Dawn*.
2. Main menu → **Mod Manager** → **Mod Editor**. The game loads a sandbox map and the companion editor window opens.
3. In the editor's left column, double-click **Alba - Patch** to open the per-mod view.
4. Verify metadata: id `LH_Alba_patch`, title `Alba - Patch`, no `steam_id` set, dependencies on `LH_Alba` and `sad_commonlib`.
5. Click **Test** to validate the mod loads cleanly (watch the **Messages** pane for `[LUA ERROR]` lines).
6. From the per-mod menu, choose **Upload to Steam Workshop**. The dialog asks for visibility, tags (Gameplay/Other already set in metadata), and accepts the Steam Workshop legal agreement.
7. Confirm. Steam packs the folder into a `.hpk`, uploads it, and writes the assigned Workshop file id back into `metadata.lua` as `steam_id`.
8. Commit the metadata change (the new `steam_id` line, plus the editor's `version` bump / `saved` / `code_hash` updates) so the next push lines up the local repo with the live Workshop submission.

## Updating an existing Workshop submission

1. Make changes locally and commit.
2. Open the Mod Editor as above.
3. Click **Test** to validate.
4. The editor auto-bumps `version` in `metadata.lua` on Save (the `1.0-XXX` scheme is `version_major.version_minor-version`).
5. **Upload to Steam Workshop** — because `steam_id` is now set, the editor updates the existing submission rather than creating a new one.
6. Commit any metadata changes the editor wrote (`saved` timestamp, `version` bump, `code_hash`, occasionally `saved_with_revision` if the game build changed).

## Caveats

- **Local version overrides Workshop.** While you're iterating, this folder's version is what loads — useful, but remember to unsubscribe from the Workshop copy if you want to test a clean install.
- **`steam_id` ties this folder to a specific Workshop submission.** If you ever need to publish as a brand-new submission (e.g., transfer to a different account), delete the `steam_id` line first.
- **Don't ship compiled Lua.** Keep `.lua` files as plain text; the engine's packer handles the rest. Compiled `.luac` files in the source tree can confuse the loader.
- **Patch architecture.** This mod never modifies upstream Alba's files. All fixes are additive (`ModItemChangeProp`, top-level reassignment of globals, additive `OnMsg` handlers). If a future Mod Editor save introduces an unexpected `Building/<X>.lua` file or a large `changed_props = { ... }` blob in `items.lua`, that means the editor captured live merged class state from another mod's `AppendClass` injection — investigate before uploading. (See `general_modding_information.md` §2.7 on Mod Editor save-time write-back behaviors.)
- **`items.lua` syntax.** The patch's `items.lua` must be a single `return { ... }` containing the `PlaceObj` entries — bare `PlaceObj(...)` calls separated by commas are not valid Lua at the top level and will cause `[mod] Failed to load mod items` with a `syntax error near ','`. The Mod Editor preserves the `return { ... }` wrapper on Save.
- **Description drift.** Editing the Workshop description on Steam's "Edit item" page does *not* write back to `metadata.lua`. The next upload from the Mod Editor silently overwrites the Steam-side description with the local metadata version. Keep description edits in `metadata.lua` and let Upload propagate them.
- **`mod-tools/hpk.exe` is separate.** The general modding reference mentions `hpk create --cripple-lua-files --dont-compress-files` — that's for advanced workflows like extracting and repacking the vanilla `Lua.hpk`. It is *not* the publish path. Workshop publishing goes through the Mod Editor.
- **Achievements.** Subscribers playing this mod still earn Steam achievements normally.
