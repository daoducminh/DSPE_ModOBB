
local volcano_prefabs =
{
	"world",
	"ground_chunks_breaking",
    "obsidian",
    "volcano_exit",
    "volcano_altar",
    "obsidian_workbench",
    "ashfx",
    "volcanolavafx",
    "rock_obsidian",
    "rock_charcoal",
    "volcano_shrub",
    "elephantcactus",
    "coffeebush",
    "splash_lava_drop",
    "splash_cloud_drop"
}

local assets =
{	
	Asset("IMAGE", "images/colour_cubes/sw_volcano_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/sw_volcano_active_cc.tex"),

    Asset("IMAGE", "images/volcano_cloud.tex"),
    Asset("IMAGE", "images/lava_active.tex"),
}

local function fn(Sim)
	local inst = SpawnPrefab("world")
    inst:AddTag("volcano")

	inst.prefab = "volcanolevel"

	--volcano specifics
    local waves = inst.entity:AddWaveComponent()
    waves:SetRegionSize( 40, 20 )
    waves:SetRegionNumWaves( 8 )
    waves:SetWaveTexture( "images/volcano_cloud.tex" )
    --waves:SetWaveTexture( "images/lava_active.tex" )
    -- See source\game\components\WaveRegion.h
    waves:SetWaveEffect( "shaders/waves.ksh" )
    waves:SetWaveSize( 2048, 512 )

    inst:AddComponent("clock")
    inst:AddComponent("worldwind")
	inst:AddComponent("seasonmanager")
    inst.components.seasonmanager:Tropical()
    inst:AddComponent("volcanomanager")
	inst:AddComponent("colourcubemanager")
    inst:AddComponent("volcanowave")
    inst.components.volcanowave.waves = waves
    inst:AddComponent("volcanoambience")
    inst:AddComponent("debugger")

	inst.components.ambientsoundmixer:SetReverbPreset("volcanolevel")

    return inst
end

return Prefab( "worlds/volcanolevel", fn, assets, volcano_prefabs) 

