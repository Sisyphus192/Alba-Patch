-- Alba - Patch: bug fixes for the Alba mod (LH_Alba) by lukeh_ro.
-- Loads after LH_Alba via the metadata.lua dependency declaration; every patch here is
-- additive (additive OnMsg handlers) or last-wins reassignment of globals.

----------------------------------------------------------------------------------------
-- ALBA-1: prevent crash in upstream Alba's ChangeCrops, and (STEAM-1) finish the
-- CactusFruit -> Fruits unlock cascade that gates Winemaking research.
--
-- Upstream Alba's `local function ChangeCrops()` (Code/AlbaVegetation.lua) does:
--     Resources.Potato.SpecificToRegions.Alba = true
--     Resources.Tomato.SpecificToRegions.Alba = true
-- Vanilla `Resource.SpecificToRegions` defaults to `false` (boolean, not a set), so
-- indexing crashes with "attempt to index a boolean value" on every GameTimeStart and
-- PostLoadGame. The crash aborts the rest of ChangeCrops, so the CactusFruit -> Fruits
-- group registration that gates Winemaking unlock never runs (Steam: Omega13 2025-09-30).
--
-- Strategy:
--   1. Pre-init Resources.Potato/Tomato.SpecificToRegions to {} so upstream's broken
--      `false.Alba = true` index becomes a regular table write. We re-assert the
--      pre-init on every event that fires before upstream ChangeCrops can run:
--      DataLoaded/ModsReloaded (initial load) and NewGame/LoadGame (each subsequent
--      game start, since our post-fix below resets to `false` after upstream completes).
--   2. After upstream ChangeCrops runs (additive OnMsg.GameTimeStart / PostLoadGame
--      registration loads after upstream's), reset Potato/Tomato.SpecificToRegions to
--      `false` so they're available everywhere again, and apply the STEAM-1 cache-sync
--      + retroactive unlock.
----------------------------------------------------------------------------------------

local function PreventCropsCrash()
	for _, id in ipairs({"Potato", "Tomato"}) do
		local res = Resources and Resources[id]
		if res and res.SpecificToRegions == false then
			res.SpecificToRegions = {}
		end
	end
end

local function FixCropsAfterUpstream()
	if not Resources then return end

	-- Restore vanilla "available everywhere" on Potato/Tomato (upstream's broken lines
	-- otherwise leave SpecificToRegions = {Alba = true}, making them Alba-only).
	if Resources.Potato then Resources.Potato.SpecificToRegions = false end
	if Resources.Tomato then Resources.Tomato.SpecificToRegions = false end

	-- STEAM-1: ResourceInGroupIds is a frozen cache built by PreProcessResources at
	-- DataLoaded time. Upstream Alba's ChangeCrops adds CactusFruit to in_groups and
	-- to GroupResourceIds.Fruits but doesn't update this cache, so harvest-cascade
	-- unlock (Player:UnlockResource walks ResourceInGroupIds[res]) never reaches Fruits
	-- and Winemaking stays gated.
	if not ResourceInGroupIds then return end
	if Game and Game.region == "Alba" then
		ResourceInGroupIds.CactusFruit = ResourceInGroupIds.CactusFruit or {}
		if not ResourceInGroupIds.CactusFruit.Fruits then
			table.insert_unique(ResourceInGroupIds.CactusFruit, "Fruits")
			ResourceInGroupIds.CactusFruit.Fruits = true
		end
		if UIPlayer and UIPlayer:IsResUnlocked("CactusFruit") then
			UIPlayer:UnlockResource("Fruits")
		end
	elseif ResourceInGroupIds.CactusFruit then
		table.remove_value(ResourceInGroupIds.CactusFruit, "Fruits")
		ResourceInGroupIds.CactusFruit.Fruits = nil
	end
end

function OnMsg.DataLoaded() PreventCropsCrash() end
function OnMsg.ModsReloaded() PreventCropsCrash() end
function OnMsg.NewGame() PreventCropsCrash() end
function OnMsg.LoadGame() PreventCropsCrash() end

OnMsg.GameTimeStart = FixCropsAfterUpstream
OnMsg.PostLoadGame = FixCropsAfterUpstream

----------------------------------------------------------------------------------------
-- ALBA-2: fix axis-sign bias in Alba_AddGeysers.
--
-- Upstream uses `(-1 * geyser_random(2))` which evaluates to {0, -1}, biasing all geyser
-- placement toward negative axes (or to origin); correct form is `(-1 + 2 * geyser_random(2))`
-- which evaluates to {-1, +1}.
--
-- `Alba_AddGeysers` is a global; redefining it after upstream Code loads makes the new
-- version the active one. The function is called from items.lua (RegionDef effects) and
-- from SavegameFixups.AddGeysers; both happen after mod load, so the override wins.
----------------------------------------------------------------------------------------

function Alba_AddGeysers(settings)
	local geyser_random = BraidRandomCreate(settings.seed_text)
	if (PersistableGlobals.TerrainRestoreSuspended) then
		TerrainRestoreSuspended = true
	end
	MapForEach("map", "Rock", function(obj)
		if not obj:IsKindOf("MineableRock") then
			obj:delete()
		end
	end)
	MapForEach("map", "Plant", function(obj)
		if obj:GetPlantDef().id == "EnergyCrystals" then
			local pos = obj:GetPos()
			if not MapFindNearest(pos, pos, 5000, "Geyser") then
				local dx = geyser_random(3000)
				local dy = geyser_random(3000)
				local new_pos = pos:SetX(pos:x() + (-1 + 2 * geyser_random(2)) * (1100 + dx)):SetY(pos:y() + (-1 + 2 * geyser_random(2)) * (1100 + dy))
				if not MapFindNearest(new_pos, new_pos, 4000, "Geyser") then
					PlaceGeyser(new_pos, geyser_random)
				end
			end
		end
	end)
	MapForEach("map", "Plant", function(obj)
		if obj:GetPlantDef().id == "EnergyCrystals" then
			if MapFindNearest(obj, obj, 1000, "Geyser") or not MapFindNearest(obj, obj, 5000, "Geyser") then
				obj:delete()
			end
		end
	end)
	MapForEach("map", "Geyser", function(obj)
		local box = obj:GetSurfacesBBox(EntitySurfaces.Collision)
		MapForEach(obj, 6000, "Rock", function(obj)
			if obj:IsObstructing(box) then
				obj:delete()
			end
		end)
	end)
	if (PersistableGlobals.TerrainRestoreSuspended) then
		TerrainRestoreSuspended = false
	end
end

----------------------------------------------------------------------------------------
-- ALBA-3: region-guard SavegameFixups.AddGeysers.
--
-- Upstream registration prompts the geyser-placement dialog on every save load, including
-- non-Alba saves. SavegameFixups is a regular table; reassigning the named entry replaces
-- upstream's registration.
----------------------------------------------------------------------------------------

function SavegameFixups.AddGeysers()
	if not Game or Game.region ~= "Alba" then return end
	CreateRealTimeThread(function()
		if WaitQuestion(terminal.desktop, T("Alba Update: Geysers"),
				T("Add geysers to the current map?\n(around Energy Crystals)"),
				T("Yes"), T("No")) == "ok"
		then
			Alba_AddGeysers(Game)
		end
	end)
end

----------------------------------------------------------------------------------------
-- Bonfire passive warmth (Steam: MommyDearest 2025-03-04).
--
-- Upstream's BonfireWarmUp relaxation routine only fires when the survivor needs
-- relaxation, stranding hypothermic-but-already-relaxed survivors. Sweep working
-- bonfires every 15 in-game minutes and apply BonfireColdResistance (StackLimit=1) to
-- any human in range with any Hypothermia_* health condition.
----------------------------------------------------------------------------------------

PeriodicRepeatInfo["Alba_BonfireWarmth"] = false
MapGameTimeRepeat("Alba_BonfireWarmth", const.HourDuration / 4, function(dt)
	if not Game or Game.region ~= "Alba" then return end
	MapForEach("map", "Bonfire", function(bonfire)
		if not bonfire.working then return end
		local range = bonfire.RadiationRange or 6000
		MapForEach(bonfire, range, "Human", function(unit)
			if not IsValid(unit) then return end
			if unit:HasHealthConditionById("Hypothermia_1_Mild")
				or unit:HasHealthConditionById("Hypothermia_2_Moderate")
				or unit:HasHealthConditionById("Hypothermia_3_Severe")
				or unit:HasHealthConditionById("Hypothermia_4_Extreme")
			then
				unit:AddHappinessFactor("BonfireColdResistance", "passive_warmth")
			end
		end)
	end)
end)

----------------------------------------------------------------------------------------
-- Particle texture path correction.
--
-- Upstream Alba ships GeyserSteam.dds and GeyserWater.dds at the mod root, but the
-- engine warns ("Invalid location of particle texture") because particle textures are
-- expected under /Textures/Particles/. We ship our own copies under Mod/LH_Alba_patch/
-- Textures/Particles/ and rewrite the texture path on the ParticleSystemPreset emitters
-- at ClassesBuilt to silence the warning.
----------------------------------------------------------------------------------------

function OnMsg.ClassesBuilt()
	local presets = Presets and Presets.ParticleSystemPreset
	if not presets then return end
	local rewrites = {
		["Mod/LH_Alba/GeyserSteam.dds"] = "Mod/LH_Alba_patch/Textures/Particles/GeyserSteam.dds",
		["Mod/LH_Alba/GeyserWater.dds"] = "Mod/LH_Alba_patch/Textures/Particles/GeyserWater.dds",
	}
	for _, group in pairs(presets) do
		for _, id in ipairs({"GeyserSteam", "GeyserWater"}) do
			local preset = group[id]
			if preset then
				for _, child in ipairs(preset) do
					if child.texture and rewrites[child.texture] then
						child.texture = rewrites[child.texture]
					end
				end
			end
		end
	end
end
