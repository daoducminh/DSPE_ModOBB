local freqency_descriptions
if PLATFORM ~= "iOS" and PLATFORM ~= "Android" then
	freqency_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN, data = "often" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEALWAYS, data = "always" },
	}
else
	freqency_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN, data = "often" }
	}
	freqency_descriptions_ps4_exceptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN, data = "often" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEALWAYS, data = "always" },
	}
end

local speed_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYSLOW, data = "veryslow" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESLOW, data = "slow" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEFAST, data = "fast" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYFAST, data = "veryfast" },
}

local day_descriptions = {

	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },

	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.DAY, data = "longday" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.DUSK, data = "longdusk" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.NIGHT, data = "longnight" },

	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.DAY, data = "noday" },
	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.DUSK, data = "nodusk" },
	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.NIGHT, data = "nonight" },

	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.DAY, data = "onlyday" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.DUSK, data = "onlydusk" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.NIGHT, data = "onlynight" },
}

local season_length_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "noseason" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYSHORT, data = "veryshortseason" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESHORT, data = "shortseason" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG, data = "longseason" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYLONG, data = "verylongseason" },
	{ text = STRINGS.UI.SANDBOXMENU.RANDOM, data = "random"},
}

-- local season_mode_descriptions = {
-- 	{ text = STRINGS.UI.SANDBOXMENU.ALLSEASONS, data = "default" },

-- 	{ text = STRINGS.UI.SANDBOXMENU.CLASSIC, data = "classic" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.DLC, data = "dlc" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.EXTREMETEMPS, data = "extreme" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.STATICTEMPS, data = "static" },	

-- 	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.AUTUMN, data = "onlyautumn" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.WINTER, data = "onlywinter" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.SPRING, data = "onlyspring" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.SUMMER, data = "onlysummer" },

-- 	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.AUTUMN, data = "noautumn" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.WINTER, data = "nowinter" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.SPRING, data = "nospring" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.SUMMER, data = "nosummer" },	
-- }

local season_start_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.DEFAULT, data = "default"},-- 	image = "season_start_autumn.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.AUTUMN, data = "autumn"},-- 	image = "season_start_autumn.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.WINTER, data = "winter"},-- 	image = "season_start_winter.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.SPRING, data = "spring"},-- 	image = "season_start_spring.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.SUMMER, data = "summer"},-- 	image = "season_start_summer.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.RANDOM, data = "random"},-- 	image = "season_start_summer.tex" },
}

local size_descriptions = nil
if PLATFORM == "iOS" or PLATFORM == "Android" then
	size_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMALL, data = "default"},-- 	image = "world_size_small.tex"}, 	--350x350
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMEDIUM, data = "medium"},-- 	image = "world_size_medium.tex"},	--450x450
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESLARGE, data = "large"},-- 	image = "world_size_large.tex"},	--550x550
	}
else
	size_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMALL, data = "default"},-- 	image = "world_size_small.tex"}, 	--350x350
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMEDIUM, data = "medium"},-- 	image = "world_size_medium.tex"},	--450x450
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESLARGE, data = "large"},-- 	image = "world_size_large.tex"},	--550x550
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESHUGE, data = "huge"},-- 		image = "world_size_huge.tex"},	--800x800
	}
end


local branching_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGNEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGLEAST, data = "least" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGANY, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGMOST, data = "most" },
}

local loop_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.LOOPNEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.LOOPRANDOM, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.LOOPALWAYS, data = "always" },
}

local complexity_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYSIMPLE, data = "verysimple" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESIMPLE, data = "simple" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDECOMPLEX, data = "complex" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYCOMPLEX, data = "verycomplex" },	
}

-- Read this from the levels.lua
local preset_descriptions = {
}

-- TODO: Read this from the tasks.lua
local yesno_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.YES, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.NO, data = "never" },
}
-- TODO: Read this from the tasks.lua
local damage_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.DAMAGENORMAL, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.DAMAGEREDUCED, data = "reduced" },
}
local GROUP = {
	["monsters"] = 	{	-- These guys come after you	
						order = 5,
						text = STRINGS.UI.SANDBOXMENU.CHOICEMONSTERS, 
						desc = freqency_descriptions,
						enable = false,
						items={
							["spiders"] = {value = "default", enable = false, spinner = nil, image = "spiders.tex", order = 1, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.SPIDERS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.SPIDERS}, 
							["tentacles"] = {value = "default", enable = false, spinner = nil, image = "tentacles.tex", order = 5, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.TENTACLES, name = STRINGS.UI.CUSTOMIZATIONSCREEN.TENTACLES}, 
							["lureplants"] = {value = "default", enable = false, spinner = nil, image = "lureplant.tex", order = 7, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.LUREPLANTS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.LUREPLANTS}, 
							["walrus"] = {value = "default", enable = false, spinner = nil, image = "mactusk.tex", order = 8, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.WALRUS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.WALRUS}, 
							["hounds"] = {value = "default", enable = false, spinner = nil, image = "hounds.tex", order = 2, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.HOUNDS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.HOUNDS}, 
							["houndmound"] = {value = "default", enable = false, spinner = nil, image = "houndmound.tex", order = 3, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.HOUNDMOUND, name = STRINGS.UI.CUSTOMIZATIONSCREEN.HOUNDMOUND}, 
							["liefs"] = {value = "default", enable = false, spinner = nil, image = "liefs.tex", order = 9, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.LIEFS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.LIEFS}, 
							["merm"] = {value = "default", enable = false, spinner = nil, image = "merms.tex", order = 4, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.MERM, name = STRINGS.UI.CUSTOMIZATIONSCREEN.MERM}, 
							["krampus"] = {value = "default", enable = false, spinner = nil, image = "krampus.tex", order = 11, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.KRAMPUS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.KRAMPUS},
							["deerclops"] = {value = "default", enable = false, spinner = nil, image = "deerclops.tex", order = 13, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.DEERCLOPS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.DEERCLOPS},
							["bearger"] = {value = "default", enable = false, spinner = nil, image = "bearger.tex", order = 12, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.BEARGER, name = STRINGS.UI.CUSTOMIZATIONSCREEN.BEARGER},
							["goosemoose"] = {value = "default", enable = false, spinner = nil, image = "goosemoose.tex", order = 14, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.GOOSEMOOSE, name = STRINGS.UI.CUSTOMIZATIONSCREEN.GOOSEMOOSE},
							["dragonfly"] = {value = "default", enable = false, spinner = nil, image = "dragonfly.tex", order = 15, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.DRAGONFLY, name = STRINGS.UI.CUSTOMIZATIONSCREEN.DRAGONFLY},
							["deciduousmonster"] = {value = "default", enable = false, spinner = nil, image = "deciduouspoison.tex", order = 10, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.DECIDUOUSMONSTER, name = STRINGS.UI.CUSTOMIZATIONSCREEN.DECIDUOUSMONSTER},
							["chess"] = {value = "default", enable = false, spinner = nil, image = "chess_monsters.tex", order = 6, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.CHESS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.CHESS},
							--["mactusk"] = {value = "default", enable = false, spinner = nil, image = "mactusk.tex"}, 
						}
					},
	["animals"] =  	{	-- These guys live and let live
						order= 4,
						text = STRINGS.UI.SANDBOXMENU.CHOICEANIMALS, 
						desc = freqency_descriptions,
						enable = false,
						items={
							["pigs"] = {value = "default", enable = false, spinner = nil, image = "pigs.tex", order = 9, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.PIGS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.PIGS}, 
							["tallbirds"] = {value = "default", enable = false, spinner = nil, image = "tallbirds.tex", order = 19, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.TALLBIRDS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.TALLBIRDS}, 
							["rabbits"] = {value = "default", enable = false, spinner = nil, image = "rabbits.tex", order = 2, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.RABBITS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.RABBITS}, 
							["beefalo"] = {value = "default", enable = false, spinner = nil, image = "beefalo.tex", order = 11, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.BEEFALO, name = STRINGS.UI.CUSTOMIZATIONSCREEN.BEEFALO}, 
							["beefaloheat"] = {value = "default", enable = false, spinner = nil, image = "beefaloheat.tex", order = 12, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.BEEFALOHEAT, name = STRINGS.UI.CUSTOMIZATIONSCREEN.BEEFALOHEAT}, 
							["hunt"] = {value = "default", enable = false, spinner = nil, image = "tracks.tex", order = 13, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.HUNT, name = STRINGS.UI.CUSTOMIZATIONSCREEN.HUNT}, 
							["warg"] = {value = "default", enable = false, spinner = nil, image = "warg.tex", order = 14, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.WARG, name = STRINGS.UI.CUSTOMIZATIONSCREEN.WARG}, 
							["bees"] = {value = "default", enable = false, spinner = nil, image = "beehive.tex", order = 17, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.BEES, name = STRINGS.UI.CUSTOMIZATIONSCREEN.BEES}, 
							["angrybees"] = {value = "default", enable = false, spinner = nil, image = "wasphive.tex", order = 18, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.ANGRYBEES, name = STRINGS.UI.CUSTOMIZATIONSCREEN.ANGRYBEES}, 
							["birds"] = {value = "default", enable = false, spinner = nil, image = "birds.tex", order = 5, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.BIRDS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.BIRDS}, 
							["perd"] = {value = "default", enable = false, spinner = nil, image = "perd.tex", order = 8, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.PERD, name = STRINGS.UI.CUSTOMIZATIONSCREEN.PERD}, 
							["ponds"] = {value = "default", enable = false, spinner = nil, image = "ponds.tex", order = 16, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.PONDS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.PONDS}, 
							["moles"] = {value = "default", enable = false, spinner = nil, image = "mole.tex", order = 3, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.MOLES, name = STRINGS.UI.CUSTOMIZATIONSCREEN.MOLES}, 
							["lightninggoat"] = {value = "default", enable = false, spinner = nil, image = "lightning_goat.tex", order = 10, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.LIGHTNINGGOAT, name = STRINGS.UI.CUSTOMIZATIONSCREEN.LIGHTNINGGOAT}, 
							["catcoon"] = {value = "default", enable = false, spinner = nil, image = "catcoon.tex", order = 7, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.CATCOON, name = STRINGS.UI.CUSTOMIZATIONSCREEN.CATCOON}, 
							["buzzard"] = {value = "default", enable = false, spinner = nil, image = "buzzard.tex", order = 6, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.BUZZARD, name = STRINGS.UI.CUSTOMIZATIONSCREEN.BUZZARD}, 
							["butterfly"] = {value = "default", enable = false, spinner = nil, image = "butterfly.tex", order = 4, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.BUTTERFLY, name = STRINGS.UI.CUSTOMIZATIONSCREEN.BUTTERFLY}, 
							["penguins"] = {value = "default", enable = false, spinner = nil, image = "pengull.tex", order = 15, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.PENGUINS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.PENGUINS}, 
							["mandrake"] = {value = "default", enable = false, spinner = nil, image = "mandrake.tex", order = 1, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.MANDRAKE, name = STRINGS.UI.CUSTOMIZATIONSCREEN.MANDRAKE}, 
						}
					},
	["resources"] = {
						order= 2,
						text = STRINGS.UI.SANDBOXMENU.CHOICERESOURCES, 
						desc = freqency_descriptions,
						enable = false,
						items={
							["grass"] = {value = "default", enable = false, spinner = nil, image = "grass.tex", order = 2, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.GRASS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.GRASS}, 
							["rock"] = {value = "default", enable = false, spinner = nil, image = "rock.tex", order = 9, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.ROCK, name = STRINGS.UI.CUSTOMIZATIONSCREEN.ROCK}, 
							["rock_ice"] = {value = "default", enable = false, spinner = nil, image = "iceboulder.tex", order = 10, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.ROCK_ICE, name = STRINGS.UI.CUSTOMIZATIONSCREEN.ROCK_ICE}, 
							["sapling"] = {value = "default", enable = false, spinner = nil, image = "sapling.tex", order = 3, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.SAPLING, name = STRINGS.UI.CUSTOMIZATIONSCREEN.SAPLING}, 
							["reeds"] = {value = "default", enable = false, spinner = nil, image = "reeds.tex", order = 6, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.REEDS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.REEDS}, 
							["trees"] = {value = "default", enable = false, spinner = nil, image = "trees.tex", order = 7, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.TREES, name = STRINGS.UI.CUSTOMIZATIONSCREEN.TREES}, 
							["tumbleweed"] = {value = "default", enable = false, spinner = nil, image = "tumbleweeds.tex", order = 5, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.TUMBLEWEED, name = STRINGS.UI.CUSTOMIZATIONSCREEN.TUMBLEWEED}, 
							["marshbush"] = {value = "default", enable = false, spinner = nil, image = "marsh_bush.tex", order = 4, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.MARSHBUSH, name = STRINGS.UI.CUSTOMIZATIONSCREEN.MARSHBUSH}, 
							["flowers"] = {value = "default", enable = false, spinner = nil, image = "flowers.tex", order = 1, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.FLOWERS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.FLOWERS},
							["flint"] = {value = "default", enable = false, spinner = nil, image = "flint.tex", order = 8, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.FLINT, name = STRINGS.UI.CUSTOMIZATIONSCREEN.FLINT},
							-- ["rocks"] = {value = "default", enable = false, spinner = nil, image = "rocks.tex", order = 9},
						}
					},
	["unprepared"] ={
						order= 3,
						text = STRINGS.UI.SANDBOXMENU.CHOICEFOOD, 
						desc = freqency_descriptions,
						enable = true,
						items={
							["carrot"] = {value = "default", enable = true, spinner = nil, image = "carrot.tex", order = 2
--											images ={
--												"carrot_never.tex",
--												"carrot_rare.tex",
--												"carrot_default.tex",
--												"carrot_often.tex",
--												"carrot_always.tex",
--											}
										, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.CARROT, name = STRINGS.UI.CUSTOMIZATIONSCREEN.CARROT}, 
							["berrybush"] = {value = "default", enable = true, spinner = nil, image = "berrybush.tex", order = 1, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.BERRYBUSH, name = STRINGS.UI.CUSTOMIZATIONSCREEN.BERRYBUSH}, 
							["mushroom"] = {value = "default", enable = false, spinner = nil, image = "mushrooms.tex", order = 3, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.MUSHROOM, name = STRINGS.UI.CUSTOMIZATIONSCREEN.MUSHROOM}, 
							["cactus"] = {value = "default", enable = false, spinner = nil, image = "cactus.tex", order = 4, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.CACTUS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.CACTUS}, 
						}
					},
	["misc"] =		{
						order= 1,
						text = STRINGS.UI.SANDBOXMENU.CHOICEMISC, 
						desc = nil,
						enable = true,
						items={
							["day"] = {value = "default", enable = false, spinner = nil, image = "day.tex", desc = day_descriptions, order = 9, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.DAY, name = STRINGS.UI.CUSTOMIZATIONSCREEN.DAY}, 
							["autumn"] = {value = "default", enable = true, spinner = nil, image = "autumn.tex", desc = season_length_descriptions, order = 4, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.AUTUMN, name = STRINGS.UI.CUSTOMIZATIONSCREEN.AUTUMN},
							["winter"] = {value = "default", enable = true, spinner = nil, image = "winter.tex", desc = season_length_descriptions, order = 5, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.WINTER, name = STRINGS.UI.CUSTOMIZATIONSCREEN.WINTER},
							["spring"] = {value = "default", enable = true, spinner = nil, image = "spring.tex", desc = season_length_descriptions, order = 6, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.SPRING, name = STRINGS.UI.CUSTOMIZATIONSCREEN.SPRING},
							["summer"] = {value = "default", enable = true, spinner = nil, image = "summer.tex", desc = season_length_descriptions, order = 7, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.SUMMER, name = STRINGS.UI.CUSTOMIZATIONSCREEN.SUMMER},
							["season_start"] = {value = "default", enable = false, spinner = nil, image = "season_start.tex", desc = season_start_descriptions, order = 8, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.SEASON_START, name = STRINGS.UI.CUSTOMIZATIONSCREEN.SEASON_START}, 
							["weather"] = {value = "default", enable = false, spinner = nil, image = "rain.tex", desc = freqency_descriptions, order = 11, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.WEATHER, name = STRINGS.UI.CUSTOMIZATIONSCREEN.WEATHER}, 
							["lightning"] = {value = "default", enable = false, spinner = nil, image = "lightning.tex", desc = freqency_descriptions, order = 12, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.LIGHTNING, name = STRINGS.UI.CUSTOMIZATIONSCREEN.LIGHTNING}, 
							["world_size"] = {value = "default", enable = false, spinner = nil, image = "world_size.tex", desc = size_descriptions, order = 1, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.WORLD_SIZE, name = STRINGS.UI.CUSTOMIZATIONSCREEN.WORLD_SIZE}, 
							["branching"] = {value = "default", enable = false, spinner = nil, image = "world_branching.tex", desc = branching_descriptions, order = 2, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.BRANCHING, name = STRINGS.UI.CUSTOMIZATIONSCREEN.BRANCHING}, 
							["loop"] = {value = "default", enable = false, spinner = nil, image = "world_loop.tex", desc = loop_descriptions, order = 3, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.LOOP, name = STRINGS.UI.CUSTOMIZATIONSCREEN.LOOP}, 
--							["world_complexity"] = {value = "default", enable = false, spinner = nil, image = "world_complexity.tex", desc = complexity_descriptions}, 
							["boons"] = {value = "default", enable = false, spinner = nil, image = "skeletons.tex", desc = freqency_descriptions, order = 16, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.BOONS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.BOONS}, 
							["touchstone"] = {value = "default", enable = false, spinner = nil, image = "resurrection.tex", desc = freqency_descriptions, order = 15, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.TOUCHSTONE, name = STRINGS.UI.CUSTOMIZATIONSCREEN.TOUCHSTONE}, 
							["cave_entrance"] = {value = "default", enable = false, spinner = nil, image = "caves.tex", desc = yesno_descriptions, order = 10, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.CAVE_ENTRANCE, name = STRINGS.UI.CUSTOMIZATIONSCREEN.CAVE_ENTRANCE},
							["frograin"] = {value = "default", enable = false, spinner = nil, image = "frog_rain.tex", desc = freqency_descriptions, order = 13, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.FROGRAIN, name = STRINGS.UI.CUSTOMIZATIONSCREEN.FROGRAIN}, 
							["wildfires"] = {value = "default", enable = false, spinner = nil, image = "smoke.tex", desc = freqency_descriptions, order = 14, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.WILDFIRES, name = STRINGS.UI.CUSTOMIZATIONSCREEN.WILDFIRES}, 
							["grue"] = {value = "default", enable = false, spinner = nil, image = "bright_night.tex", desc = yesno_descriptions, order = 17, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.GRUE, name = STRINGS.UI.CUSTOMIZATIONSCREEN.GRUE}, 
							["death_by_hunger"] = {value = "default", enable = false, spinner = nil, image = "death_by_hunger.tex", desc = yesno_descriptions, order = 18, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.DEATH_BY_HUNGER, name = STRINGS.UI.CUSTOMIZATIONSCREEN.DEATH_BY_HUNGER}, 
							["aggressive_nightmare_creatures"] = {value = "default", enable = false, spinner = nil, image = "aggressive_shadow_creatures.tex", desc = yesno_descriptions, order = 19, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.AGGRESSIVE_NIGHTMARE_CREATURES, name = STRINGS.UI.CUSTOMIZATIONSCREEN.AGGRESSIVE_NIGHTMARE_CREATURES}, 
							["sanity_visual_effects"] = {value = "default", enable = false, spinner = nil, image = "insanity.tex", desc = yesno_descriptions, order = 20, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.SANITY_VISUAL_EFFECTS, name = STRINGS.UI.CUSTOMIZATIONSCREEN.SANITY_VISUAL_EFFECTS}, 
							["damage"] = {value = "default", enable = false, spinner = nil, image = "damage.tex", desc = damage_descriptions, order = 21, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.DAMAGE, name = STRINGS.UI.CUSTOMIZATIONSCREEN.DAMAGE}, 
							["death_by_cold"] = {value = "default", enable = false, spinner = nil, image = "death_by_cold.tex", desc = yesno_descriptions, order = 22, text = STRINGS.UI.EN_CUSTOMIZATIONSCREEN.DEATH_BY_COLD, name = STRINGS.UI.CUSTOMIZATIONSCREEN.DEATH_BY_COLD}, 
						}
					},
}

-- Fixup for frequency spinners that are _actually_ frequency (not density)
if PLATFORM == "PS4" then
	-- GROUP["monsters"].items["lureplants"] = {value = "default", enable = false, spinner = nil, image = "lureplant.tex", desc = freqency_descriptions_ps4_exceptions, order = 7} 
	-- GROUP["monsters"].items["hounds"] = {value = "default", enable = false, spinner = nil, image = "hounds.tex", desc = freqency_descriptions_ps4_exceptions, order = 2}
	GROUP["monsters"].items["liefs"] = {value = "default", enable = false, spinner = nil, image = "liefs.tex", desc = freqency_descriptions_ps4_exceptions, order = 9}
	GROUP["monsters"].items["krampus"] = {value = "default", enable = false, spinner = nil, image = "krampus.tex", desc = freqency_descriptions_ps4_exceptions, order = 11}
	GROUP["monsters"].items["deerclops"] = {value = "default", enable = false, spinner = nil, image = "deerclops.tex", desc = freqency_descriptions_ps4_exceptions, order = 13}
	GROUP["monsters"].items["bearger"] = {value = "default", enable = false, spinner = nil, image = "bearger.tex", desc = freqency_descriptions_ps4_exceptions, order = 12}
	GROUP["monsters"].items["goosemoose"] = {value = "default", enable = false, spinner = nil, image = "goosemoose.tex", desc = freqency_descriptions_ps4_exceptions, order = 14}
	GROUP["monsters"].items["dragonfly"] = {value = "default", enable = false, spinner = nil, image = "dragonfly.tex", desc = freqency_descriptions_ps4_exceptions, order = 15}
	GROUP["monsters"].items["deciduousmonster"] = {value = "default", enable = false, spinner = nil, image = "deciduouspoison.tex", desc = freqency_descriptions_ps4_exceptions, order = 10}

	-- GROUP["animals"].items["beefaloheat"] = {value = "default", enable = false, spinner = nil, image = "beefaloheat.tex", desc = freqency_descriptions_ps4_exceptions, order = 12}
	GROUP["animals"].items["hunt"] = {value = "default", enable = false, spinner = nil, image = "tracks.tex", desc = freqency_descriptions_ps4_exceptions, order = 13}
	GROUP["animals"].items["warg"] = {value = "default", enable = false, spinner = nil, image = "warg.tex", desc = freqency_descriptions_ps4_exceptions, order = 14}
	-- GROUP["animals"].items["birds"] = {value = "default", enable = false, spinner = nil, image = "birds.tex", desc = freqency_descriptions_ps4_exceptions, order = 5}
	-- GROUP["animals"].items["perd"] = {value = "default", enable = false, spinner = nil, image = "perd.tex", desc = freqency_descriptions_ps4_exceptions, order = 8}
	-- GROUP["animals"].items["butterfly"] = {value = "default", enable = false, spinner = nil, image = "butterfly.tex", desc = freqency_descriptions_ps4_exceptions, order = 4}
	-- GROUP["animals"].items["penguins"] = {value = "default", enable = false, spinner = nil, image = "pengull.tex", desc = freqency_descriptions_ps4_exceptions, order = 15}

	-- GROUP["resources"].items["flowers"] = {value = "default", enable = false, spinner = nil, image = "flowers.tex", desc = freqency_descriptions_ps4_exceptions, order = 1}

	GROUP["misc"].items["weather"] = {value = "default", enable = false, spinner = nil, image = "rain.tex", desc = freqency_descriptions_ps4_exceptions, order = 11}
	GROUP["misc"].items["lightning"] = {value = "default", enable = false, spinner = nil, image = "lightning.tex", desc = freqency_descriptions_ps4_exceptions, order = 12}
	GROUP["misc"].items["frograin"] = {value = "default", enable = false, spinner = nil, image = "frog_rain.tex", desc = freqency_descriptions_ps4_exceptions, order = 13} 
	GROUP["misc"].items["wildfires"] = {value = "default", enable = false, spinner = nil, image = "smoke.tex", desc = freqency_descriptions_ps4_exceptions, order = 14}
end

local function GetGroupForItem(target)
	for area,items in pairs(GROUP) do
		for name,item in pairs(items.items) do
			if name == target then
				return area
			end
		end
	end
	return "misc"
end

return {GetGroupForItem=GetGroupForItem, GROUP=GROUP, preset_descriptions=preset_descriptions}
