package.path = package.path .. ";scripts/?.lua"
--package.path = "data\\DLC0002\\scripts\\?.lua;" .. package.path --necessary for mapgenviewer


-- [Vicent] measure time of the level generation process
local startClock = os.clock()

--local BAD_CONNECT = 219000 -- 
--SEED = 372000 -- Force roads test level 3
if SEED == nil then
	SEED = getrealtime()
end

-- [Vicent] hack the seed to test
-- SEED = getblithackedseed()


MODS_ENABLED = PLATFORM ~= "PS4" and PLATFORM ~= "NACL" and PLATFORM ~= "iOS" and PLATFORM ~= "Android"
DEBUGSIGNS_ENABLED = false

math.randomseed(SEED)

--print ("worldgen_main.lua MAIN = 1")

WORLDGEN_MAIN = 1

--install our crazy loader! MUST BE HERE FOR NACL
local loadfn = function(modulename)
    local errmsg = ""
    local modulepath = string.gsub(modulename, "%.", "/")
    for path in string.gmatch(package.path, "([^;]+)") do
        local filename = string.gsub(path, "%?", modulepath)
        filename = string.gsub(filename, "\\", "/")
        local result = kleiloadlua(filename)
        if result ~= nil then
            return result
        end
        errmsg = errmsg.."\n\tno file '"..filename.."' (checked with custom loader)"
    end
  return errmsg    
end
table.insert(package.loaders, 1, loadfn)

local basedir = "./"
--patch this function because NACL has no fopen
if TheSim then
    basedir = "scripts/"
    function loadfile(filename)
        return kleiloadlua(filename)
    end
end



require("simutil")

require("strict")
require("debugprint")

-- add our print loggers
AddPrintLogger(function(...) WorldSim:LuaPrint(...) end)

require("json")
require("vector3")
require("tuning")
require("languages/language")
require("dlcsupport_worldgen")
require("strings")
require("dlcsupport_strings")
require("constants")
require("class")
require("debugtools")
require("util")
require("prefabs")
require("profiler")
require("dumper")

require("mods")
require("modindex")

local moddata = json.decode(GEN_MODDATA)
if moddata then
	KnownModIndex:RestoreCachedSaveData(moddata.index)
	ModManager:LoadMods(true)
end

require("map/tasks")

print ("running worldgen_main.lua DLC0002\n")

print ("SEED = ", SEED)

local basedir = "./"

local last_tick_seen = -1





------TIME FUNCTIONS

function GetTickTime()
    return 0
end

local ticktime = GetTickTime()
function GetTime()
    return 0
end

function GetTick()
    return 0
end

function GetTimeReal()
    return getrealtime()
end

---SCRIPTING
local Scripts = {}

function LoadScript(filename)
    if not Scripts[filename] then
        local scriptfn = loadfile("scripts/" .. filename)
        Scripts[filename] = scriptfn()
    end
    return Scripts[filename]
end


function RunScript(filename)
    local fn = LoadScript(filename)
    if fn then
        fn()
    end
end

function GetDebugString()
    return tostring(scheduler)
end
------------------------------

--- non-user-facing Tracking stats  ---
TrackingEventsStats = {}
TrackingTimingStats = {}
function IncTrackingStat(stat, subtable)

    local t = TrackingEventsStats
    if subtable then
        t = TrackingEventsStats[subtable]

        if not t then
            t = {}
            TrackingEventsStats[subtable] = t
        end
    end

    t[stat] = 1 + (t[stat] or 0)
end

function SetTimingStat(subtable, stat, value)

    local t = TrackingTimingStats
    if subtable then
        t = TrackingTimingStats[subtable]

        if not t then
            t = {}
            TrackingTimingStats[subtable] = t
        end
    end

    t[stat] = math.floor(value/1000)
end

--- GAME Stats and details to be sent to server on game complete ---
ProfileStats = {}

function GetProfileStats()
	if GetTableSize(ProfileStats) then
    	return json.encode({
    						stats = ProfileStats
    						})
    else
    	return json.encode({})
    end
end

function ProfileStatsSet(item, value)
    ProfileStats[item] = value
end

function ProfileStatsAdd(item)
    --print ("ProfileStatsAdd", item)
    if ProfileStats[item] then
    	ProfileStats[item] = ProfileStats[item] +1
    else
    	ProfileStats[item] = 1
    end
end

function ProfileStatsAddItemChunk(item, chunk)
    if ProfileStats[item] == nil then
    	ProfileStats[item] = {}
    end

    if ProfileStats[item][chunk] then
    	ProfileStats[item][chunk] =ProfileStats[item][chunk] +1
    else
    	ProfileStats[item][chunk] = 1
    end
end




function PROFILE_world_gen(debug)
	require("profiler")
	local profiler = newProfiler("time", 100000)
	profiler:start()    
        
	local strdata = LoadParametersAndGenerate(debug)
	
	profiler:stop()
	local outfile = io.open( "profile.txt", "w+" )
	profiler:report(outfile)
	outfile:close()
	local tmp = {}
	
	profiler:lua_report(tmp)
	require("debugtools")
	dumptable(profiler)
	
	return strdata
end

function ShowDebug(savedata)
	local item_table = { }
	
	for id, locs in pairs(savedata.ents) do		
		for i, pos in ipairs(locs) do
			local misc = -1
			if string.find(id, "wormhole") ~= nil then
				if pos.data and pos.data.teleporter and pos.data.teleporter.target then
					misc = pos.data.teleporter.target - 2300000
				end
			end
			table.insert(item_table, {id, pos.x/TILE_SCALE + savedata.map.width/2.0, pos.z/TILE_SCALE + savedata.map.height/2.0, misc})
		end
	end

	-- WorldSim:ShowDebugItems(item_table)			
end

function CheckMapSaveData(savedata)
	print("Checking map...")
        
    assert(savedata.map, "Map missing from savedata on generate")
    assert(savedata.map.prefab, "Map prefab missing from savedata on generate")
    assert(savedata.map.tiles, "Map tiles missing from savedata on generate")
    assert(savedata.map.width, "Map width missing from savedata on generate")
    assert(savedata.map.height, "Map height missing from savedata on generate")
	assert(savedata.map.topology, "Map topology missing from savedata on generate")
        
	assert(savedata.playerinfo, "Playerinfo missing from savedata on generate")
	assert(savedata.playerinfo.x, "Playerinfo.x missing from savedata on generate")
	assert(savedata.playerinfo.y, "Playerinfo.y missing from savedata on generate")
	assert(savedata.playerinfo.z, "Playerinfo.z missing from savedata on generate")
	assert(savedata.playerinfo.day, "Playerinfo day missing from savedata on generate")

	assert(savedata.ents, "Entites missing from savedata on generate")
end

local function OverrideTweaks(level, world_gen_choices)
	local customise = require("map/customise")
	for i,v in ipairs(level.overrides) do
		local name = v[1]
		local value = v[2]
		
		if type(name) == type({}) then
			name = name[math.random(#name)]
		end
		if type(value) == type({}) then
			value = value[math.random(#value)]
		end

		local area = customise.GetGroupForItem(name)
		-- Modify world now
		if not (world_gen_choices["tweak"] and world_gen_choices["tweak"][area] and world_gen_choices["tweak"][area][name]) then
			if world_gen_choices["tweak"] == nil then
				world_gen_choices["tweak"] = {}
			end
			if world_gen_choices["tweak"][area] == nil then
				world_gen_choices["tweak"][area] = {}
			end
			world_gen_choices["tweak"][area][name] = value
		end
	end
end

local function GetRandomFromLayouts( layouts )
	local area_keys = {}
	for k,v in pairs(layouts) do
		table.insert(area_keys, k)
	end
	local area_idx =  math.random(#area_keys)
	local area = area_keys[area_idx]
	local target = nil
	if (area == "Rare" and math.random()<0.98) or GetTableSize(layouts[area]) <1 then
		table.remove(area_keys, area_idx)
		area = area_keys[math.random(#area_keys)]
	end

	if GetTableSize(layouts[area]) <1 then
		return nil
	end

	target = {target_area=area, choice=GetRandomKey(layouts[area])} 	

	return target
end

local function GetAreasForChoice(area, level)
	local areas = {}

	for i, task_name in ipairs(level.tasks) do
		local task = tasks.GetTaskByName(task_name, tasks.sampletasks)
		if (level.name == "Shipwrecked" and area == "Shipwrecked_Any") or area == "Any" 
										or area == "Rare" or area == task.room_bg then
			table.insert(areas, task_name)
		end
	end
	if #areas ==0 then
		return nil
	end
	return areas
end

local function AddSingleSetPeice(level, choicefile)
	local choices = require(choicefile)
	assert(choices.Sandbox)

	local chosen = GetRandomFromLayouts(choices.Sandbox)
	if chosen ~= nil then
		if chosen.target_area == "Water" then
			if level.water_setpieces == nil then
				level.water_setpieces = {}
			end
			if level.water_setpieces[chosen.choice] == nil then
				level.water_setpieces[chosen.choice] = {count = 0}
			end
			level.water_setpieces[chosen.choice].count = level.water_setpieces[chosen.choice].count + 1
		else
			if level.set_pieces == nil then
				level.set_pieces = {}
			end

			local areas = GetAreasForChoice(chosen.target_area, level)
			if areas then
				local num_peices = 1
				if level.set_pieces[chosen.choice] ~= nil then
					num_peices = level.set_pieces[chosen.choice].count + 1
				end
				level.set_pieces[chosen.choice] = {count = num_peices, tasks=areas}
			end
		end
	end
end

local function AddSetPeices(level, world_gen_choices)

	local boons_override = "default"
	local touchstone_override = "default"
	local traps_override = "default"
	local poi_override = "default"
	local protected_override = "default"

	if world_gen_choices["tweak"] ~=nil and 
		world_gen_choices["tweak"]["misc"] ~= nil then

		if world_gen_choices["tweak"]["misc"]["boons"] ~= nil then
			boons_override = world_gen_choices["tweak"]["misc"]["boons"]
		end
		if world_gen_choices["tweak"]["misc"]["touchstone"] ~= nil then
			touchstone_override = world_gen_choices["tweak"]["misc"]["touchstone"]
		end
		if world_gen_choices["tweak"]["misc"]["traps"] ~= nil then
			traps_override = world_gen_choices["tweak"]["misc"]["traps"]
		end
		if world_gen_choices["tweak"]["misc"]["poi"] ~= nil then
			poi_override = world_gen_choices["tweak"]["misc"]["poi"]
		end
		if world_gen_choices["tweak"]["misc"]["protected"] ~= nil then
			protected_override = world_gen_choices["tweak"]["misc"]["protected"]
		end
	end

	if traps_override ~= "never" then
		AddSingleSetPeice(level, "map/traps")
	end
	if poi_override ~= "never" then
		AddSingleSetPeice(level, "map/pointsofinterest")
	end
	if protected_override ~= "never" then
		AddSingleSetPeice(level, "map/protected_resources")
	end

	local multiply = {
		["rare"] = 0.5,
		["default"] = 1,
		["often"] = 1.5,
		["mostly"] = 2.2,
		["always"] = 3,		
	}

	if touchstone_override ~= "default" and level.set_pieces ~= nil then
		if level.set_pieces["ResurrectionStone"] ~= nil then
			if touchstone_override == "never" then
				level.set_pieces["ResurrectionStone"] = nil
			else
				level.set_pieces["ResurrectionStone"].count = math.ceil(level.set_pieces["ResurrectionStone"].count*multiply[touchstone_override])
			end
		end
		if level.set_pieces["ResurrectionStoneSw"] ~= nil then
			if touchstone_override == "never" then
				level.set_pieces["ResurrectionStoneSw"] = nil
			else
				level.set_pieces["ResurrectionStoneSw"].count = math.ceil(level.set_pieces["ResurrectionStoneSw"].count*multiply[touchstone_override])
			end
		end
	end

	if boons_override ~= "never" then

		-- Quick hack to get the boons in
		local boons = math.random(math.floor(3*multiply[boons_override]), math.ceil(8*multiply[boons_override]))
		for idx=1, boons do
			AddSingleSetPeice(level, "map/boons")
		end
	end

end

local function FixWesUnlock(level, progress, profile)
	local should_wes = profile and profile.unlocked_characters["wes"] ~= true and progress == 3
	if not should_wes then
		print("No wes allowed on this level!")
		level.set_pieces["WesUnlock"] = nil
	else
		print("Wes setpiece allowed in this level.")
	end
end

local function GetStartTask(start_tasks)
	local last_task = nil
	local last_data = nil
	if start_tasks then
		local totalweight = 0
		for task, data in pairs(start_tasks) do
			totalweight = totalweight + (data.weight or 0)
		end
		local thres = math.random(0, totalweight)
		for task, data in pairs(start_tasks) do
			thres = thres - (data.weight or 0)
			if thres <= 0 then return task, data end
			last_task, last_data = task, data
		end
	end
	return last_task, last_data
end



function BlitPrintDebugMapInfo(savedata, title)
    local function mprint(mstr)
        print(mstr)
        -- CLS_LOG(mstr)
    end

    if title == nil then
        title = "Unkown"
    end

    mprint (" - Map Report -- "..title)
    mprint (" - Map Size: "..savedata.map.width..", "..savedata.map.height)
    mprint (" - Entity Report:")
    local c = 0
    local n = 0
    for id, locs in pairs(savedata.ents) do 
        n = #locs
        c = c + n
        mprint ("    - Entity: '"..id.."' #: "..n)
    end
    mprint(" - Entity Total Count: "..c)
end


function GenerateNew(debug, parameters)
    
    --print("Generate New map",debug, parameters.gen_type, "type: "..parameters.level_type, parameters.current_level, parameters.world_gen_choices)
	local Gen = require "map/forest_map"
	
	--if TheFrontEnd then print ("########## FRONTEND EXISTS! ###########") end

	local levels = require("map/levels")

	local level = levels.test_level


	if parameters.level_type and string.upper(parameters.level_type) == "CAVE" then
		
		if parameters.current_level == nil or parameters.current_level > #levels.cave_levels then
			parameters.current_level = 1
		end

		level = levels.cave_levels[parameters.current_level]

	elseif parameters.level_type and string.upper(parameters.level_type) == "ADVENTURE" then
		level = levels.story_levels[parameters.current_level]

		-- makes the levels loop when we are pushing testing branches
		--if parameters.adventure_progress == levels.CAMPAIGN_LENGTH then
		--	level.teleportaction = "restart"
		--end

		FixWesUnlock(level, parameters.adventure_progress, parameters.profiledata)
		print("\n#######\n#\n# Generating "..level.name.."("..parameters.current_level..")".."\n#\n#######\n")
	elseif parameters.level_type and string.upper(parameters.level_type) == "TEST" then
		print("\n#######\n#\n# Generating TEST Mode Level\n#\n#######\n")
	elseif parameters.level_type and string.upper(parameters.level_type) == "SURVIVAL" then
		if parameters.world_gen_choices.preset == nil then
			parameters.world_gen_choices.preset = "SURVIVAL_DEFAULT"
		end
		print("WORLDGEN PRESET: ",parameters.world_gen_choices.preset)
		for i,v in ipairs(levels.sandbox_levels) do
			if v.id == parameters.world_gen_choices.preset then
				parameters.world_gen_choices.level_id = i
				break
			end
		end
		
		print("WORLDGEN LEVEL ID: ", parameters.world_gen_choices.level_id )
		if parameters.world_gen_choices.level_id == nil or parameters.world_gen_choices.level_id > #levels.sandbox_levels then
			parameters.world_gen_choices.level_id = 1
		end
		
		level = levels.sandbox_levels[parameters.world_gen_choices.level_id]

		print("\n#######\n#\n# Generating Normal Mode "..level.name.." Level\n#\n#######\n")
	elseif parameters.level_type and string.upper(parameters.level_type) == "SHIPWRECKED" then
		if parameters.world_gen_choices.preset == nil then
			parameters.world_gen_choices.preset = "SHIPWRECKED_DEFAULT"
		end
		print("WORLDGEN PRESET: ",parameters.world_gen_choices.preset)
		for i,v in ipairs(levels.shipwrecked_levels) do
			if v.id == parameters.world_gen_choices.preset then
				parameters.world_gen_choices.level_id = i
				break
			end
		end
		
		print("WORLDGEN LEVEL ID: ", parameters.world_gen_choices.level_id )
		if parameters.world_gen_choices.level_id == nil or parameters.world_gen_choices.level_id > #levels.shipwrecked_levels then
			parameters.world_gen_choices.level_id = 1
		end
		
		level = levels.shipwrecked_levels[parameters.world_gen_choices.level_id]

		print("\n#######\n#\n# Generating Shipwrecked Mode "..level.name.." Level\n#\n#######\n")
	elseif parameters.level_type and string.upper(parameters.level_type) == "VOLCANO" then
		if parameters.current_level == nil or parameters.current_level > #levels.volcano_levels then
			parameters.current_level = 1
		end
		level = levels.volcano_levels[parameters.current_level]
		print("\n#######\n#\n# Generating Volcano "..level.name.." Level\n#\n#######\n")
	else
		-- Probably got here from a mod, up to the mod to tell us what to load.
		level = levels.custom_levels[parameters.world_gen_choices.level_id]
		print("\n#######\n#\n# Special: Generating "..parameters.level_type.." mode "..level.name.." Level\n#\n#######\n")
	end

	local modfns = ModManager:GetPostInitFns("LevelPreInit", level.id)
	for i,modfn in ipairs(modfns) do
		print("Applying mod to level '"..level.id.."'")
		modfn(level)
	end
	modfns = ModManager:GetPostInitFns("LevelPreInitAny")
	for i,modfn in ipairs(modfns) do
		print("Applying mod to current level")
		modfn(level)
	end

	OverrideTweaks(level, parameters.world_gen_choices)	
	local level_area_triggers = level.override_triggers or nil
	AddSetPeices(level, parameters.world_gen_choices)

	local id = level.id
	local override_level_string = level.override_level_string or false
	local name = level.name or "ERROR"
	local hideminimap = level.hideminimap or false

	local teleportaction = level.teleportaction or false
	local teleportmaxwell = level.teleportmaxwell or nil
	local nomaxwell = level.nomaxwell or false

	local prefab = "forest"
	if parameters.world_gen_choices.tweak and parameters.world_gen_choices.tweak.misc then
		prefab = parameters.world_gen_choices.tweak.misc.location or "forest"
	end

	local start_task, start_data = GetStartTask(level.start_tasks)
	if start_task then
		parameters.world_gen_choices.tweak.misc.start_task = start_task or parameters.world_gen_choices.tweak.misc.start_task
		parameters.world_gen_choices.tweak.misc.start_setpeice = start_data.start_setpiece or parameters.world_gen_choices.tweak.misc.start_setpiece
		parameters.world_gen_choices.tweak.misc.start_node = start_data.start_node or parameters.world_gen_choices.tweak.misc.start_node
		table.insert(level.tasks, start_task)
	end

	local choose_tasks = level:GetTasksForLevel(tasks.sampletasks)
	if debug == true then
	 	 choose_tasks = tasks.oneofeverything
	end
    --print ("Generating new world","forest", max_map_width, max_map_height, choose_tasks)
        
	local savedata = nil

	local max_map_width = 1024 -- 1024--256 
	local max_map_height = 1024 -- 1024--256 
	
	local try = 0
	local maxtries = 5
	
	while savedata == nil do
        try = try + 1
		savedata = Gen.Generate(prefab, max_map_width, max_map_height, choose_tasks, parameters.world_gen_choices, parameters.level_type, level)
		
		if savedata == nil then
			
			if try >= maxtries then
                print(string.format("An error occured during world gen, giving up! [try %d of %d]\n\n\n\n" , try, maxtries))
				return nil
			end
            print(string.format("An error occured during world gen, we will retry! [try %d of %d]\n\n\n\n" , try, maxtries))
			--assert(try <= maxtries, "Maximum world gen retries reached!")
			collectgarbage("collect")
			WorldSim:ResetAll()

		-- [Vicent] Measure time and errors during generation
		else
			local measuredTime = os.clock()-startClock
			print(" **** WORLD GENERATION REPORT **** ")
			print(" - SEED: "..SEED)
			print(" - TIME: "..measuredTime.." seconds --> "..(measuredTime/60.0).." minutes.")
			if try <= 1 then
				print(" - [OK] SUCCESFULL MAP CREATION!")
			else
				print(" - [FAIL] ERROR IN MAP CREATION!")			
				print(" - Retries: "..(try-1))
			end
			BlitPrintDebugMapInfo(savedata, "ON_GENERATE")
			print(" **** END of WORLD GENERATION REPORT **** ")


			if GEN_PARAMETERS == "" or parameters.show_debug == true then			
				ShowDebug(savedata)
			end

			-- [blit-vicent] temporal hack to re-create worlds for finding errors with seeds
			-- return nil
		end
	end

    print(string.format("Generated a world [try %d of %d]", try, maxtries))
	
	
	savedata.map.prefab = prefab
	
	if parameters.level_type == "cave" then
		savedata.map.prefab = "cave"
	end
		
	savedata.map.topology.level_type = parameters.level_type
	savedata.map.topology.level_number = parameters.current_level or 1
	savedata.map.override_level_string = override_level_string
	savedata.map.name = name
	savedata.map.nomaxwell = nomaxwell
	savedata.map.hideminimap = hideminimap
	savedata.map.teleportaction = teleportaction
	savedata.map.teleportmaxwell = teleportmaxwell

	--Record mod information
	ModManager:SetModRecords(savedata.mods or {})
	savedata.mods = ModManager:GetModRecords()
        
	
	savedata.map.topology.override_triggers = level_area_triggers
	
	if APP_VERSION == nil then
		APP_VERSION = "DEV_UNKNOWN"
	end

	if APP_BUILD_DATE == nil then
		APP_BUILD_DATE = "DEV_UNKNOWN"
	end

	if APP_BUILD_TIME == nil then
		APP_BUILD_TIME = "DEV_UNKNOWN"
	end

	savedata.meta = { 	
						build_version = APP_VERSION, 
						build_date = APP_BUILD_DATE,
						build_time = APP_BUILD_TIME,
						seed = SEED,
						level_id = id or "survival",
						freshly_generated = true,
					}

	CheckMapSaveData(savedata)
		
	-- Clear out scaffolding :)
	--[[for i=#savedata.map.topology.ids,1, -1 do
		local name = savedata.map.topology.ids[i]
		if string.find(name, "LOOP_BLANK_SUB") ~= nil  then
			table.remove(savedata.map.topology.ids, i)
			table.remove(savedata.map.topology.nodes, i)
			for eid=#savedata.map.topology.edges,1,-1 do
				if savedata.map.topology.edges[eid].n1 == i or savedata.map.topology.edges[eid].n2 == i then
					table.remove(savedata.map.topology.edges, eid)
				end
			end
		end
	end	]]--	
	
	print("Generation complete")

	local strdata = DataDumper(savedata, nil, true, false)
	return strdata
end

local function LoadParametersAndGenerate(debug)

	local parameters = nil
	if GEN_PARAMETERS == "" then
		print("WARNING: No parameters found, using defaults. This should only happen from the test harness!")
		parameters = { level_type="adventure", current_level=5, adventure_progress=3, profiledata={unlocked_characters={wes=true}} }
	else
		parameters = json.decode(GEN_PARAMETERS)
	end
    
    if 	parameters.world_gen_choices == nil then
		parameters.world_gen_choices = {}
    end
	SetDLCEnabled(parameters.DLCEnabled)

	return GenerateNew(debug, parameters)-- parameters.worldgen_type, parameters.level_type, parameters.current_level, parameters.world_gen_choices)
end

return LoadParametersAndGenerate(false)
