
local SKIP_GEN_CHECKS = false

local function tree()
    return "evergreen"--trees[math.random(#trees)]
end

require "map/terrain"
require "map/water"
require "map/treasurehunt"
local function pickspawnprefab(items_in, ground_type)
--	if ground_type == GROUND.ROAD then
--		return
--	end
	local items = {}
	if ground_type ~= nil then		
		-- Filter the items
	    for item,v in pairs(items_in) do
	    	items[item] = items_in[item]
	        if terrain.filter[item]~= nil then
--	        	if ground_type == GROUND.ROAD then
--	        		print ("Filter", item, terrain.filter.Print(terrain.filter[item]), GROUND_NAMES[ground_type])
--	        	end
	        	
	            for idx,gt in ipairs(terrain.filter[item]) do
        			if gt == ground_type then
        				items[item] = nil
        				--print ("Filtered", item, GROUND_NAMES[ground_type], " (".. terrain.filter.Print(terrain.filter[item])..")")
        			end
   				end        
	        end 
	    end
	end
    local total = 0
    for k,v in pairs(items) do
        total = total + v
    end
    if total > 0 then
        local rnd = math.random()*total
        for k,v in pairs(items) do
            rnd = rnd - v
            if rnd <= 0 then
                return k
            end
        end
    end
end

local function pickspawngroup(groups)
    for k,v in pairs(groups) do
        if math.random() < v.percent then
            return v
        end
    end
end

local MULTIPLY = {
		["never"] = 0,
		["rare"] = 0.5,
		["default"] = 1,
		["often"] = 1.125,
		["mostly"] = 1.67, -- Not sure this is getting used...?
		["always"] = 2,		
	}

local level_type = ""
if rawget(_G, "GEN_PARAMETERS") ~= nil then
	local params = json.decode(GEN_PARAMETERS)
	level_type = params.level_type
end

local merm = { "mermhouse" }
local trees = {"evergreen", "evergreen_sparse", "deciduoustree", "marsh_tree"}
local rocks = {"rocks", "rock1", "rock2", "rock_flintless"}
local grass = {"grass"}

if level_type == "shipwrecked" or level_type == "volcano" then
	merm = {"mermhouse_fisher"}
	trees = {"jungletree", "palmtree", "mangrovetree"}
	rocks = {"rocks", "rock1", "rock2", "rock_flintless", "magmarock", "magmarock_gold"}
	grass = {"grass", "grass_water"}
end

	
local TRANSLATE_TO_PREFABS = {
		["spiders"] = 			{"spiderden"},
		["tentacles"] = 		{"tentacle"},
		["tallbirds"] = 		{"tallbirdnest"},
		["pigs"] = 				{"pighouse"},
		["ballphins"] = 		{"ballphin", "ballphinhouse"},
		["rabbits"] = 			{"rabbithole"},
		["moles"] =				{"molehill"},
		["beefalo"] = 			{"beefalo"},
		["ponds"] = 			{"pond", "pond_mos"},
		["bees"] = 				{"beehive", "bee"},
		["grass"] = 			grass,
		["rock"] = 				rocks, 
		["rock_ice"] = 			{"rock_ice"}, 
		["sapling"] = 			{"sapling"},
		["reeds"] = 			{"reeds"},	
		["trees"] = 			trees,
		["evergreen"] = 		{"evergreen"},	
		["carrot"] = 			{"carrot_planted"},
		["berrybush"] = 		{"berrybush", "berrybush2", "berrybush2_snake"},
		["maxwelllight"] = 		{"maxwelllight"},
		["maxwelllight_area"] = {"maxwelllight_area"},
		["fireflies"] = 		{"fireflies"},
		["cave_entrance"] = 	{"cave_entrance"},
		["tumbleweed"] = 		{"tumbleweedspawner"},
		["cactus"] = 			{"cactus"},
		["lightninggoat"] = 	{"lightninggoat"},
		["catcoon"] = 			{"catcoonden"},
		["merm"] = 				merm,
		["buzzard"] = 			{"buzzardspawner"},
		["mushroom"] =			{"red_mushroom", "green_mushroom", "blue_mushroom"},
		["marshbush"] = 		{"marsh_bush"},
		["flint"] = 			{"flint"},
		["mandrake"] = 			{"mandrake"},
		["angrybees"] = 		{"wasphive", "killerbee"},
		["houndmound"] = 		{"houndmound"},
		["chess"] = 			{"knight", "bishop", "rook"},
		["walrus"] = 			{"walrus_camp"},

		["crabhole"] =			{"crabhole"},
		["ox"] =				{"ox"},
		["solofish"] =			{"solofish"},
		["jellyfish"] =			{"jellyfish_planted", "jellyfish_spawner"},
		["fishinhole"] =		{"fishinhole"},
		["seashell"] =			{"seashell_beached"},
		["seaweed"] =			{"seaweed_planted"},
		["obsidian"] =			{"obsidian"},
		["limpets"] =			{"limpetrock"},
		["coral"] =				{"coralreef"},
		["coral_brain_rock"] =	{"coral_brain_rock"},
		--["bermudatriangle"] =	{"bermudatriangle_MARKER"},
		["flup"] =				{"flup", "flupspawner", "flupspawner_sparse", "flupspawner_dense"},
		["sweet_potato"] =		{"sweet_potato_planted"},
		["wildbores"] =			{"wildborehouse"},
		["bush_vine"] =			{"bush_vine", "snakeden"},
		["bamboo"] =			{"bamboo", "bambootree"},
		["crate"] =				{"crate"},
		["tidalpool"] =			{"tidalpool"},
		["sandhill"] =			{"sandhill"},
		["poisonhole"] =		{"poisonhole"},
		["mussel_farm"] =		{"mussel_farm"},
		["doydoy"] =			{"doydoy", "doydoybaby"},
		["lobster"] =			{"lobster", "lobsterhole"},
		["primeape"] =			{"primeape", "primeapebarrel"},
		["bioluminescence"] =	{"bioluminescence", "bioluminescence_spawner"},
		["ballphin"] =			{"ballphin", "ballphin_spawner"},
		["swordfish"] =			{"swordfish", "swordfish_spawner"},
		["stungray"] =			{"stungray", "stungray_spawner"},
	}

local TRANSLATE_AND_OVERRIDE = { --These are entities that should be translated to prefabs for world gen but also have a postinit override to do
		["flowers"] =			{"flower", "flower_evil"},
		["volcano"]=			{"volcano"},
		["seagull"] =			{"seagullspawner"},
	}

local customise = require("map/customise")
local function TranslateWorldGenChoices(world_gen_choices)
	if world_gen_choices == nil or GetTableSize(world_gen_choices["tweak"]) == 0 then
		return nil, nil
	end
	
	local translated = {}
	local runtime_overrides = {}
	
	for group, items in pairs(world_gen_choices["tweak"]) do
		for selected, v in pairs(items) do
			if v ~= "default" then
				if TRANSLATE_AND_OVERRIDE[selected] ~= nil then --Override and Translate
					--print("Worldgen Choice, Translate and Override", selected, v)
					local area = customise.GetGroupForItem(selected) --Override
					if runtime_overrides[area] == nil then
						runtime_overrides[area] = {}
					end
					table.insert(runtime_overrides[area], {selected, v})

					for i,prefab in ipairs(TRANSLATE_AND_OVERRIDE[selected]) do --Translate
						translated[prefab] = MULTIPLY[v]
					end	
				elseif TRANSLATE_TO_PREFABS[selected] == nil then --Override only
					--print("Worldgen Choice, Override only", selected, v)
					local area = customise.GetGroupForItem(selected)
					if runtime_overrides[area] == nil then
						runtime_overrides[area] = {}
					end
					table.insert(runtime_overrides[area], {selected, v})
				else --Translate only
					--print("Worldgen Choice, Translate only", selected, v)
					for i,prefab in ipairs(TRANSLATE_TO_PREFABS[selected]) do
						translated[prefab] = MULTIPLY[v]
					end	
				end	
			end	
		end
	end
	
	if GetTableSize(translated) == 0 then
		translated = nil
	end

	if GetTableSize(runtime_overrides) == 0 then
		runtime_overrides = nil
	end

	return translated, runtime_overrides
end
	
local function UpdatePercentage(distributeprefabs, world_gen_choices)
	for selected, v in pairs(world_gen_choices) do
		if v ~= "default" then		
			for i, prefab in ipairs(TRANSLATE_TO_PREFABS[selected]) do
				if distributeprefabs[prefab] ~= nil then
					distributeprefabs[prefab] = distributeprefabs[prefab] * MULTIPLY[v]
				end
			end
		end
	end
end
	
local function UpdateTerrainValues(world_gen_choices)
	if world_gen_choices == nil or GetTableSize(world_gen_choices) == 0 then
		return
	end
	
	for name,val in pairs(terrain.rooms) do
		if val.contents.distributeprefabs ~= nil then
			UpdatePercentage(val.contents.distributeprefabs, world_gen_choices)
		end
	end
end


-- [vicent] Custom Table Print for debuging
local function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    local formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))      
    elseif type(v) ~= 'function' then
      print(formatting .. v)
    end
  end
end


local function GenerateVoro(prefab, map_width, map_height, tasks, world_gen_choices, level_type, level)
	--print("Generate",prefab, map_width, map_height, tasks, world_gen_choices, level_type)
	local start_time = GetTimeReal()

    local SpawnFunctions = {
        pickspawnprefab = pickspawnprefab, 
        pickspawngroup = pickspawngroup, 
    }

    local check_col = {}
    
	require "map/storygen"	
	
  	local current_gen_params = deepcopy(world_gen_choices)
	
	local start_node_override = nil
	local islandpercent = nil
	local story_gen_params = {}

  	local defalt_impassible_tile = GROUND.IMPASSABLE
  	if prefab == "cave" then
  		defalt_impassible_tile =  GROUND.WALL_ROCKY
  	elseif prefab == "shipwrecked" then
  		defalt_impassible_tile = GROUND.IMPASSABLE
  	end

  	story_gen_params.impassible_value = defalt_impassible_tile
	story_gen_params.level_type = level_type
	
	if current_gen_params["tweak"] ~=nil and current_gen_params["tweak"]["misc"] ~= nil then
		if  current_gen_params["tweak"]["misc"]["start_setpeice"] ~= nil then
			story_gen_params.start_setpeice = current_gen_params["tweak"]["misc"]["start_setpeice"]
			current_gen_params["tweak"]["misc"]["start_setpeice"] = nil
		end

		if  current_gen_params["tweak"]["misc"]["start_node"] ~= nil then
			story_gen_params.start_node = current_gen_params["tweak"]["misc"]["start_node"]
			current_gen_params["tweak"]["misc"]["start_node"] = nil
		end

		if  current_gen_params["tweak"]["misc"]["start_task"] ~= nil then
			story_gen_params.start_task = current_gen_params["tweak"]["misc"]["start_task"]
			current_gen_params["tweak"]["misc"]["start_task"] = nil
		end
		
		if  current_gen_params["tweak"]["misc"]["islands"] ~= nil then
			local percent = {always=1, never=0,default=0.2, sometimes=0.1, often=0.8}
			story_gen_params.island_percent = percent[current_gen_params["tweak"]["misc"]["islands"]]
			current_gen_params["tweak"]["misc"]["islands"] = nil
		end

		if  current_gen_params["tweak"]["misc"]["branching"] ~= nil then
			story_gen_params.branching = current_gen_params["tweak"]["misc"]["branching"]
			current_gen_params["tweak"]["misc"]["branching"] = nil
		end

		if  current_gen_params["tweak"]["misc"]["loop"] ~= nil then
			local loop_percent = { never=0, default=nil, always=1.0 }
			local loop_target = { never="any", default=nil, always="end"}
			story_gen_params.loop_percent = loop_percent[current_gen_params["tweak"]["misc"]["loop"]]
			story_gen_params.loop_target = loop_target[current_gen_params["tweak"]["misc"]["loop"]]
			current_gen_params["tweak"]["misc"]["loop"] = nil
		end
	end

    print("Creating story...")
	local topology_save
	if prefab == "shipwrecked" then
		topology_save = SHIPWRECKED_STORY(tasks, story_gen_params, level)
	elseif prefab == "volcanolevel" then
		topology_save = VOLCANO_STORY(tasks, story_gen_params, level)
	else
		topology_save = DEFAULT_STORY(tasks, story_gen_params, level)
	end

	local entities = {}
 
    local save = {}
    save.ents = {}
    

    --save out the map
    save.map = {
        revealed = "",
        tiles = "",
    }
    
    save.map.prefab = prefab  
   
	local min_size = 350
	local max_size = 750
	if current_gen_params["tweak"] ~= nil and current_gen_params["tweak"]["misc"] ~= nil and current_gen_params["tweak"]["misc"]["world_size"] ~= nil then
		local min_sizes ={
			["mini"] = 75,
			["tiny"] = 150,
			["small"] = 250,
			["default"] = 350,
			["medium"] = 400,
			["large"] = 425,
			["huge"] = 450,
			}
		local max_sizes ={
			["mini"] = 475,
			["tiny"] = 550,
			["small"] = 650,
			["default"] = 750,
			["medium"] = 800,
			["large"] = 825,
			["huge"] = 850,
			}

		local world_size = current_gen_params["tweak"]["misc"]["world_size"]
		print(" ;;; WORLD SIZE: "..world_size)
		min_size = min_sizes[world_size]
		-- [vicent-blit] iOS HACK: reduce the maximum world size avaiable
		-- max_size = max_sizes[world_size]
		max_size = max_sizes["default"]
		--print("New size:", min_size, current_gen_params["tweak"]["misc"]["world_size"])
		current_gen_params["tweak"]["misc"]["world_size"] = nil
	end
		
	map_width = min_size
	map_height = min_size
    
    WorldSim:SetWorldSize( map_width, map_height)

    local map_padding = 20
    if prefab == "shipwrecked" then
    	map_padding = TUNING.MAPEDGE_PADDING
    end
    
    print("Baking map...",min_size,max_size,map_padding)
    	
  	if WorldSim:GenerateVoronoiMap(math.random(), 0, map_padding) == false then--math.random(0,100)) -- AM: Dont use the tend
  		return nil
  	end

	topology_save.root:ApplyPoisonTag()
  		
  	if prefab == "cave" then
	  	local nodes = topology_save.root:GetNodes(true)
	  	for k,node in pairs(nodes) do
	  		-- BLAH HACK
	  		if node.data ~= nil and 
	  			node.data.type ~= nil and 
	  			string.find(k, "Room") ~= nil then

	  			WorldSim:SetNodeType(k, NODE_TYPE.Room)
	  		end
	  	end
  	end
  	WorldSim:SetImpassibleTileType(defalt_impassible_tile)
  	
	--WorldSim:ConvertToTileMap(min_size, 500)
	WorldSim:ConvertToTileMap(min_size, max_size)

	WorldSim:SeparateIslands()
    print("Map Baked!")
	map_width, map_height = WorldSim:GetWorldSize()
	
	local join_islands = prefab ~= "shipwrecked" and string.upper(level_type) ~= "ADVENTURE"
	local ground_fill = GROUND.DIRT
	if prefab == "shipwrecked" then
		ground_fill = GROUND.BEACH
	elseif prefab == "volcanolevel" then
		ground_fill = GROUND.VOLCANO
	end

	WorldSim:ForceConnectivity(join_islands, prefab == "cave", ground_fill )
    
    if prefab ~= "shipwrecked" then
		topology_save.root:SwapWormholesAndRoadsExtra(entities, map_width, map_height)
		if topology_save.root.error == true and prefab ~= "shipwrecked" then
		    print ("ERROR: Node ", topology_save.root.error_string)
		    if SKIP_GEN_CHECKS == false then
		    	return nil
		    end
		end
	end
	
	if (world_gen_choices["tweak"] == nil or world_gen_choices["tweak"]["misc"] == nil or world_gen_choices["tweak"]["misc"]["roads"] == nil) or world_gen_choices["tweak"]["misc"]["roads"] ~= "never" then
	--if prefab ~= "cave" then
	    WorldSim:SetRoadParameters(
			ROAD_PARAMETERS.NUM_SUBDIVISIONS_PER_SEGMENT,
			ROAD_PARAMETERS.MIN_WIDTH, ROAD_PARAMETERS.MAX_WIDTH,
			ROAD_PARAMETERS.MIN_EDGE_WIDTH, ROAD_PARAMETERS.MAX_EDGE_WIDTH,
			ROAD_PARAMETERS.WIDTH_JITTER_SCALE )
		
		WorldSim:DrawRoads(join_islands) 
	end
		
	-- Run Node specific functions here
	local gen_params, ro = TranslateWorldGenChoices(current_gen_params) --not ideal
	local nodes = topology_save.root:GetNodes(true)
	for k,node in pairs(nodes) do
		node:SetTilesViaFunction(entities, map_width, map_height, SpawnFunctions, gen_params)
	end

    print("Encoding...")
    
    save.map.topology = {}
    topology_save.root:SaveEncode({width=map_width, height=map_height}, save.map.topology)
    print("Encoding... DONE")

    -- TODO: Double check that each of the rooms has enough space (minimimum # tiles generated) - maybe countprefabs + %
    -- For each item in the topology list
    -- Get number of tiles for that node
    -- if any are less than minumum - restart the generation

    -- Big hacky thing here with the area < 4 which used to be area < 8

    for idx,val in ipairs(save.map.topology.nodes) do
		if string.find(save.map.topology.ids[idx], "LOOP_BLANK_SUB") == nil  then    
 	    	local area = WorldSim:GetSiteArea(save.map.topology.ids[idx])
	    	if area < 8 then
	    		print ("ERROR: Site "..save.map.topology.ids[idx].." area < 8: "..area)
	    		if SKIP_GEN_CHECKS == false then
	    			return nil
	    		end
	   		end
	   	end
	end
		
	if current_gen_params["tweak"] ~=nil and current_gen_params["tweak"]["misc"] ~= nil then
		if save.map.persistdata == nil then
			save.map.persistdata = {}
		end
		
		local day = current_gen_params["tweak"]["misc"]["day"]
		if day ~= nil then
			save.map.persistdata.clock = {}
		end
		
		if day == "onlynight" then
			save.map.persistdata.clock.phase="night"
		end
		if day == "onlydusk" then
			save.map.persistdata.clock.phase="dusk"
		end
	
		local season = current_gen_params["tweak"]["misc"]["season_start"]
		if season ~= nil then
			print("Start season", season)
			if save.map.persistdata.seasonmanager == nil then
				save.map.persistdata.seasonmanager = {}
			end

			if prefab == "shipwrecked" then
				if season == "random" then
					local rand = math.random(1,4)
					if rand == 1 then
						season = "dry"
					elseif rand == 2 then
						season = "wet"
					elseif rand == 3 then
						season = "green"
					else
						season = "mild"
					end
				end
			else
				if season == "random" then
					local rand = math.random(1,4)
					if rand == 1 then
						season = "summer"
					elseif rand == 2 then
						season = "winter"
					elseif rand == 3 then
						season = "autumn"
					else
						season = "spring"
					end
				end
			end
			save.map.persistdata.seasonmanager.current_season = season
			if season == "winter" then
				save.map.persistdata.seasonmanager.ground_snow_level = 1
				save.map.persistdata.seasonmanager.percent_season = .2 --.5
			elseif season == "summer" then
				save.map.persistdata.seasonmanager.percent_season = .2 --.5
			end
			
			current_gen_params["tweak"]["misc"]["season_start"] = nil		
		end
	end
	
	local runtime_overrides = nil

    current_gen_params, runtime_overrides = TranslateWorldGenChoices(current_gen_params)

    print("Checking Tags")
	local obj_layout = require("map/object_layout")
		
	local add_fn = {fn=function(prefab, points_x, points_y, current_pos_idx, entitiesOut, width, height, prefab_list, prefab_data, rand_offset) 
				WorldSim:ReserveTile(points_x[current_pos_idx], points_y[current_pos_idx])
		
				local x = (points_x[current_pos_idx] - width/2.0)*TILE_SCALE
				local y = (points_y[current_pos_idx] - height/2.0)*TILE_SCALE
				x = math.floor(x*100)/100.0
				y = math.floor(y*100)/100.0
				if entitiesOut[prefab] == nil then
					entitiesOut[prefab] = {}
				end
				local save_data = {x=x, z=y}
				if prefab_data then
					
					if prefab_data.data then
						if type(prefab_data.data) == "function" then
							save_data["data"] = prefab_data.data()
						else
							save_data["data"] = prefab_data.data
						end
					end
					if prefab_data.id then
						save_data["id"] = prefab_data.id
					end
					if prefab_data.scenario then
						save_data["scenario"] = prefab_data.scenario
					end
				end
				table.insert(entitiesOut[prefab], save_data)
			end,
			args={entitiesOut=entities, width=map_width, height=map_height, rand_offset = false, debug_prefab_list=nil}
		}

   	if topology_save.GlobalTags["Labyrinth"] ~= nil and GetTableSize(topology_save.GlobalTags["Labyrinth"]) >0 then
   		for task, nodes in pairs(topology_save.GlobalTags["Labyrinth"]) do

	   		local val = math.floor(math.random()*10.0-2.5)
	   		local mazetype = MAZE_TYPE.MAZE_GROWINGTREE_4WAY

	   		local xs, ys, types = WorldSim:RunMaze(mazetype, val, nodes)
	   		-- TODO: place items of interest in these locations
			if xs ~= nil and #xs >0 then
				for idx = 1,#xs do
			   		if types[idx] == 0 then	
			   			--Spawning chests within the labyrinth.
						local prefab = "pandoraschest"
						local x = (xs[idx]+1.5 - map_width/2.0)*TILE_SCALE
						local y = (ys[idx]+1.5 - map_height/2.0)*TILE_SCALE
						WorldSim:ReserveTile(xs[idx], ys[idx])
						--print(task.." Labryth Point of Interest:",xs[idx], ys[idx], x, y)

						if entities[prefab] == nil then
							entities[prefab] = {}
						end
						local save_data = {x=x, z=y, scenario = "chest_labyrinth"}
						table.insert(entities[prefab], save_data)
					end
				end
			end
	   		for i,node in ipairs(topology_save.GlobalTags["LabyrinthEntrance"][task]) do 
		   		local entrance_node = topology_save.root:GetNodeById(node)

		   		for id, edge in pairs(entrance_node.edges) do
					WorldSim:DrawCellLine( edge.node1.id, edge.node2.id, NODE_INTERNAL_CONNECTION_TYPE.EdgeSite, GROUND.BRICK)
		   		end
	   		end
	   	end
   	end

   	if topology_save.GlobalTags["Maze"] ~= nil and GetTableSize(topology_save.GlobalTags["Maze"]) >0 then

   		for task, nodes in pairs(topology_save.GlobalTags["Maze"]) do
	 		local xs, ys, types = WorldSim:GetPointsForMetaMaze(nodes)
			
			if xs ~= nil and #xs >0 then
				local closest = Vector3(9999999999, 9999999999, 0)
				local task_node = topology_save.root:GetNodeById(task)
				local choices = task_node.maze_tiles
				local c_x, c_y = WorldSim:GetSiteCentroid(topology_save.GlobalTags["MazeEntrance"][task][1])
				local centroid = Vector3(c_x, c_y, 0)
				for idx = 1,#xs do
					local current = Vector3(xs[idx], ys[idx], 0)

					local diff = centroid - current
					local best = centroid - closest

					if diff:Length() < best:Length() then
						closest = current
					end 

					if types[idx] > 0 then			
						obj_layout.Place({xs[idx], ys[idx]}, MAZE_CELL_EXITS_INV[types[idx]], add_fn, choices.rooms)
					elseif types[idx] < 0 then
						--print(task.." Maze Room of Interest:",xs[idx], ys[idx])
						obj_layout.Place({xs[idx], ys[idx]}, MAZE_CELL_EXITS_INV[-types[idx]], add_fn, choices.bosses)
					else
						print("ERROR Type:",types[idx], MAZE_CELL_EXITS_INV[types[idx]])
					end
				end
				obj_layout.Place({closest.x, closest.y}, "FOUR_WAY", add_fn, choices.rooms)

		   		for i,node in ipairs(topology_save.GlobalTags["MazeEntrance"][task]) do 
			   		local entrance_node = topology_save.root:GetNodeById(node)
			   		for id, edge in pairs(entrance_node.edges) do
						WorldSim:DrawCellLine( edge.node1.id, edge.node2.id, NODE_INTERNAL_CONNECTION_TYPE.EdgeSite, GROUND.BRICK)
			   		end
		   		end
			end
		end
   	end

	if prefab == "shipwrecked" then
		if level.water_prefill_setpieces then
			PlaceWaterSetPieces(level.water_prefill_setpieces, add_fn, function(ground) return ground == GROUND.IMPASSABLE end)
		end
		if level.water_open_setpieces then
			FillOpenWater(level.water_open_setpieces, entities, map_width, map_height)
		end
		ConvertImpassibleToWater(map_width, map_height, require("map/watergen"))
		local required_treasure_placed = WorldGenPlaceTreasures(topology_save.root:GetChildren(), entities, map_width, map_height, 4600000, level)
		if not required_treasure_placed then
			print("PANIC: Missing required treasure!")
			if SKIP_GEN_CHECKS == false then
				return nil
			end
		end
	end

    print("Populating voronoi...")


    -- [Vicent] Find Alternative Position to avoid fails in map generation
    -- If we want to speed up the generation we need to avoid map regeneration
	local find_alternative_position = function(node_id, layout, prefabs, add_entity, position, item)
		local nodes1 = topology_save.root:GetNodes(true)
		local node = nodes1[node_id]

		print("Finding alternative position for prefab",item," in ",node_id)

		if node.data ~= nil then
			local isteleportato = false

			if string.find(item,"Teleportato") ~=nil then
				isteleportato = true
				print("Teleportato")
			end
			--tprint(node.data)
			local isextra = false
			--print("pos")
			--print(node.data.position)

			local _,nodedepth = string.gsub(node_id, ":", "")

			--print("depth",nodedepth)

			-- first remove the item from this node
			-- if it's a teleportato part, need to restore ExitPiece tag (TODO)
			if node.data.terrain_contents_extra and node.data.terrain_contents_extra.static_layouts then
				local newlayouts = {}
				for i,slayout in ipairs(node.data.terrain_contents_extra.static_layouts) do
					if slayout ~= item  then
						table.insert(newlayouts,slayout)
					else
						isextra = true
						--teleportato is always extra node in a exit piece
						if isteleportato then
							table.insert(node.data.tags,"ExitPiece")
						end
					end
				end
				node.data.terrain_contents_extra.static_layouts = newlayouts
			end

			if node.data.terrain_contents and node.data.terrain_contents.static_layouts then
				local newlayouts = {}
				for i,slayout in ipairs(node.data.terrain_contents.static_layouts) do
					if slayout ~= item  then
						table.insert(newlayouts,slayout)
					else
						isextra = false
					end
				end
				node.data.terrain_contents.static_layouts = newlayouts
			end

			--print("After")
			--tprint(node.data)

			--search in all nodes for a place where it fits
			for k,newnode in pairs(nodes1) do
				local _,newdepth = string.gsub(newnode.id, ":", "")
				--try to find a node at the same level than the original

				if newdepth == nodedepth then
					if obj_layout.TryReserveAndPlaceLayout(newnode.id, layout, prefabs) then	
						local RemoveExitTag = function(node)
							local newtags = {}
							for i,tag in ipairs(node.data.tags) do
								if tag ~= "ExitPiece" then
									table.insert(newtags, tag)
								end
							end
							node.data.tags = newtags
						end

						local IsNodeAnExit = function(node)
							if not node.data.tags then
								return false
							end
							for i,tag in ipairs(node.data.tags) do
								if tag == "ExitPiece" then
									return true
								end
							end
							return false
						end

						if not isteleportato or (isteleportato and IsNodeAnExit(newnode)) then -- teleportato must be placed at exit nodes
							print("Fit found at",newnode.id)

							obj_layout.ReserveAndPlaceLayout(newnode.id, layout, prefabs, add_entity, position, nil, item)	

							if isteleportato then
								RemoveExitTag(newnode)
							end

							-- not sure if it's needed (likely not, and could cause the item to be added twice)
							--if isextra then
							--	if newnode.data.terrain_contents_extra == nil then
							--		newnode.data.terrain_contents_extra = {}
							--	end
							--
							--	if newnode.data.terrain_contents_extra.static_layouts == nil then
							--		newnode.data.terrain_contents_extra.static_layouts = {}
							--	end
							--
							--	table.insert(newnode.data.terrain_contents_extra.static_layouts,item)
							--else
							--
							--	if newnode.data.terrain_contents == nil then
							--		newnode.data.terrain_contents = {}
							--	end
							--
							--	if node.data.terrain_contents.static_layouts == nil then
							--		newnode.data.terrain_contents.static_layouts = {}
							--	end
							--
							--	table.insert(newnode.data.terrain_contents.static_layouts,item)
							--end

							break
						end
					end
				end
			end
	  	end
	end




	topology_save.root:GlobalPrePopulate(entities, map_width, map_height)
    --topology_save.root:ConvertGround(SpawnFunctions, entities, map_width, map_height)
    -- [Vicent] call altenrative position if we fail
    topology_save.root:ConvertGround(SpawnFunctions, entities, map_width, map_height, find_alternative_position)


	-- Caves can be easily disconnected
 	if prefab == "cave" then
	   	local replace_count = WorldSim:DetectDisconnect()
	    if replace_count >1000 then
	    	print("PANIC: Too many disconnected tiles...",replace_count)
	    	
	    	-- This assert doesn't exist in RoG/Vanilla and it seems to be breaking cave generation
	    	--assert(false, "PANIC: Too many disconnected tiles..."..tostring(replace_count))
	    	
	    	if SKIP_GEN_CHECKS == false then
	    		return nil
	    	end
	    else
	    	print("disconnected tiles...",replace_count)
	    end
	end

   	topology_save.root:PopulateVoronoi(SpawnFunctions, entities, map_width, map_height, current_gen_params)
	if prefab == "shipwrecked" then
		RemoveSingleWaterTile(map_width, map_height)
		AddShoreline(map_width, map_height)
		PopulateWater(SpawnFunctions, entities, map_width, map_height, topology_save.water, current_gen_params)
	end
	topology_save.root:GlobalPostPopulate(entities, map_width, map_height)

	for k,ents in pairs(entities) do
		for i=#ents, 1, -1 do
			local x = ents[i].x/TILE_SCALE + map_width/2.0 
			local y = ents[i].z/TILE_SCALE + map_height/2.0 

			local tiletype = WorldSim:GetVisualTileAtPosition(x,y)
			local ground_OK = tiletype > GROUND.IMPASSABLE and tiletype < GROUND.UNDERGROUND
			if ground_OK == false then
				table.remove(entities[k], i)
			end
		end
	end

    save.map.tiles, save.map.nav, save.map.adj = WorldSim:GetEncodedMap(join_islands)

   	local double_check = level.required_prefabs or {}
   	
	for i,k in ipairs(double_check) do
		if entities[k] == nil then
			print("PANIC: missing required prefab! ",k)
			--assert(false, "PANIC: missing a required prefab ["..tostring(k).."] double check that it's in a required room.")
			if SKIP_GEN_CHECKS == false then
				return nil
			end
		end			
	end

	if level.required_prefab_count then
		for k,n in pairs(level.required_prefab_count) do
			if entities[k] == nil or #entities[k] < n then
				print("PANIC: missing required prefab count!", k, n)
				if SKIP_GEN_CHECKS == false then
					return nil
				end
			end
		end
	end
   	
   	save.map.topology.overrides = runtime_overrides
	if save.map.topology.overrides == nil then
		save.map.topology.overrides = {}
	end
   	save.map.topology.overrides.original = world_gen_choices
   	
   	if current_gen_params ~= nil then
	   	-- Filter out any etities over our overrides
		for prefab,amt in pairs(current_gen_params) do
			if amt < 1 and entities[prefab] ~= nil and #entities[prefab] > 0 then
				local new_amt = math.floor(#entities[prefab]*amt)
				if new_amt == 0 then
					entities[prefab] = nil
				else
					entities[prefab] = shuffleArray(entities[prefab])
					while #entities[prefab] > new_amt do
						table.remove(entities[prefab], 1)
					end
				end
			end
		end	
	end
   	
   	
    save.ents = entities
    
    -- TODO: Double check that the entities are all existing in the world
    -- For each item in each room of the room list
	--
    
    save.map.width, save.map.height = map_width, map_height

    save.playerinfo = {}
	if save.ents.spawnpoint == nil or #save.ents.spawnpoint == 0 then
    	print("PANIC: No start location!")
    	--assert(false, "PANIC: No start location!")
    	if SKIP_GEN_CHECKS == false then
    		return nil
    	else
    		save.ents.spawnpoint={{x=0,y=0,z=0}}
    	end
    end
    
   	save.playerinfo.x = save.ents.spawnpoint[1].x
    save.playerinfo.z = save.ents.spawnpoint[1].z
    save.playerinfo.y = 0
    
    save.ents.spawnpoint = nil

    save.playerinfo.day = 0
    save.map.roads = {}
    if prefab == "forest" then	   	

	    local current_pos_idx = 1
	    if (world_gen_choices["tweak"] == nil or world_gen_choices["tweak"]["misc"] == nil or world_gen_choices["tweak"]["misc"]["roads"] == nil) or world_gen_choices["tweak"]["misc"]["roads"] ~= "never" then
		    local num_roads, road_weight, points_x, points_y = WorldSim:GetRoad(0, join_islands)
		    local current_road = 1
		    local min_road_length = math.random(3,5)
		   	--print("Building roads... Min Length:"..min_road_length, world_gen_choices["tweak"]["misc"]["roads"])
		   	
		    
		    if #points_x>=min_road_length then
		    	save.map.roads[current_road] = {3}
				for current_pos_idx = 1, #points_x  do
						local x = math.floor((points_x[current_pos_idx] - map_width/2.0)*TILE_SCALE*10)/10.0
						local y = math.floor((points_y[current_pos_idx] - map_height/2.0)*TILE_SCALE*10)/10.0
						
						table.insert(save.map.roads[current_road], {x, y})
				end
				current_road = current_road + 1
			end
			
		    for current_road = current_road, num_roads  do
		    	
		    	num_roads, road_weight, points_x, points_y = WorldSim:GetRoad(current_road-1, join_islands)
		    	    
		    	if #points_x>=min_road_length then    	
			    	save.map.roads[current_road] = {road_weight}
				    for current_pos_idx = 1, #points_x  do
						local x = math.floor((points_x[current_pos_idx] - map_width/2.0)*TILE_SCALE*10)/10.0
						local y = math.floor((points_y[current_pos_idx] - map_height/2.0)*TILE_SCALE*10)/10.0
						
						table.insert(save.map.roads[current_road], {x, y})
					end
				end
			end
		end
	end

	print("Done "..prefab.." map gen!")

	return save
end

return {
    Generate = GenerateVoro,
	TRANSLATE_TO_PREFABS = TRANSLATE_TO_PREFABS,
	MULTIPLY = MULTIPLY,
}
