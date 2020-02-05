local assets =
{
	Asset("PKGREF", "sound/dontstarve.fev"),
	--Asset("PKGREF", "sound/dontstarve_DLC001.fev"),

    Asset("ATLAS", "images/global.xml"),
    Asset("IMAGE", "images/global.tex"),
    Asset("IMAGE", "images/visited.tex"),
    Asset("ANIM", "anim/scroll_arrow.zip"),
	
	Asset("SHADER", "shaders/anim_bloom.ksh"),
	Asset("SHADER", "shaders/wall_bloom.ksh"),
	Asset("SHADER", "shaders/road.ksh"),

	Asset("IMAGE", "images/shadow.tex"),
	Asset("IMAGE", "images/erosion.tex"),
	Asset("IMAGE", "images/circle.tex"),
	Asset("IMAGE", "images/square.tex"),
	
    Asset("ATLAS", "images/fepanels.xml"),
    Asset("IMAGE", "images/fepanels.tex"),
    Asset("ATLAS", "images/chromebook_controls.xml"),
    Asset("IMAGE", "images/chromebook_controls.tex"),

    --Asset("ATLAS", "images/fepanels_DLC.xml"), // Unused?
    --Asset("IMAGE", "images/fepanels_DLC.tex"), // Unused?

    --Asset("ATLAS", "images/fepanels_DSTbeta.xml"), // Unused?
    --Asset("IMAGE", "images/fepanels_DSTbeta.tex"), // Unused?
	
	--Asset("IMAGE", "images/river_bed.tex"),
	--Asset("IMAGE", "images/water_river.tex"),
	Asset("IMAGE", "images/pathnoise.tex"),
	Asset("IMAGE", "images/mini_pathnoise.tex"),
	Asset("IMAGE", "images/roadnoise.tex"),
	Asset("IMAGE", "images/roadedge.tex"),
	Asset("IMAGE", "images/roadcorner.tex"),
	Asset("IMAGE", "images/roadendcap.tex"),
	
	Asset("ATLAS", "images/fx.xml"),
	Asset("IMAGE", "images/fx.tex"),

	Asset("IMAGE", "images/colour_cubes/identity_colourcube.tex"),

	Asset("SHADER", "shaders/anim.ksh"),
    Asset("SHADER", "shaders/anim_fade.ksh"),
	Asset("SHADER", "shaders/anim_bloom.ksh"),
	Asset("SHADER", "shaders/blurh.ksh"),
	Asset("SHADER", "shaders/blurv.ksh"),
	Asset("SHADER", "shaders/creep.ksh"),
	Asset("SHADER", "shaders/debug_line.ksh"),
	Asset("SHADER", "shaders/debug_tri.ksh"),
	Asset("SHADER", "shaders/render_depth.ksh"),
	Asset("SHADER", "shaders/font.ksh"),
	Asset("SHADER", "shaders/ground.ksh"),
    Asset("SHADER", "shaders/ground_overlay.ksh"),
	Asset("SHADER", "shaders/ground_lights.ksh"),
    Asset("SHADER", "shaders/ceiling.ksh"),
    -- Asset("SHADER", "shaders/triplanar.ksh"),
    -- Asset("SHADER", "shaders/triplanar_bg.ksh"),
    -- Asset("SHADER", "shaders/triplanar_alpha_wall.ksh"),
    -- Asset("SHADER", "shaders/triplanar_alpha_ceiling.ksh"),
	Asset("SHADER", "shaders/lighting.ksh"),
	Asset("SHADER", "shaders/minimap.ksh"),
	Asset("SHADER", "shaders/minimapfs.ksh"),
	Asset("SHADER", "shaders/clean.ksh"),
	Asset("SHADER", "shaders/particle.ksh"),
	Asset("SHADER", "shaders/road.ksh"),
	Asset("SHADER", "shaders/river.ksh"),
	Asset("SHADER", "shaders/splat.ksh"),
	Asset("SHADER", "shaders/texture.ksh"),
	Asset("SHADER", "shaders/ui.ksh"),
	Asset("SHADER", "shaders/ui_anim.ksh"),
    Asset("SHADER", "shaders/combine_colour_cubes.ksh"),
	Asset("SHADER", "shaders/postprocess.ksh"),
	Asset("SHADER", "shaders/postprocessbloom.ksh"),
	Asset("SHADER", "shaders/postprocessdistort.ksh"),
	Asset("SHADER", "shaders/postprocessbloomdistort.ksh"),

	Asset("SHADER", "shaders/waves.ksh"),
	Asset("SHADER", "shaders/overheat.ksh"),

    --common UI elements that we will always need
    Asset("ATLAS", "images/ui.xml"),
    Asset("IMAGE", "images/ui.tex"),
    Asset("ANIM", "anim/build_status.zip"),
    Asset("ANIM", "anim/generating_world.zip"),
    Asset("ANIM", "anim/generating_cave.zip"),
    Asset("ANIM", "anim/creepy_hands.zip"),    
    Asset("ANIM", "anim/saving_indicator.zip"),    
    
    --oft-used panel bgs
    Asset("ATLAS", "images/globalpanels.xml"),
    Asset("IMAGE", "images/globalpanels.tex"),

	--character portraits
	Asset("ATLAS", "images/saveslot_portraits.xml"),
    Asset("IMAGE", "images/saveslot_portraits.tex"),
    Asset("ATLAS", "images/saveslot_portraits.xml"),
    Asset("IMAGE", "images/saveslot_portraits.tex"),
}

if PLATFORM == "PS4" then
    table.insert(assets, Asset("ATLAS", "images/ps4_controllers.xml"))
    table.insert(assets, Asset("IMAGE", "images/ps4_controllers.tex"))
end

if PLATFORM == "iOS" or PLATFORM == "Android" then
    table.insert(assets, Asset("ATLAS", "images/ios_gestures.xml"))
    table.insert(assets, Asset("IMAGE", "images/ios_gestures.tex"))
    table.insert(assets, Asset("ATLAS", "images/ios_controllers.xml"))
    table.insert(assets, Asset("IMAGE", "images/ios_controllers.tex"))
    table.insert(assets, Asset("ATLAS", "images/ios_rateus.xml"))
    table.insert(assets, Asset("IMAGE", "images/ios_rateus.tex"))
end

require "fonts"
for i, font in ipairs( FONTS ) do
	table.insert( assets, Asset( "FONT", font.filename ) )
end

local function fn(Sim)
    return nil
end

return Prefab( "common/global", fn, assets ) 
