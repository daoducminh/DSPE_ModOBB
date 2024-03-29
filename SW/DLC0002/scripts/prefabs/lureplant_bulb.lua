require "prefabutil"
local assets =
{
	Asset("ANIM", "anim/eyeplant_bulb.zip"),
    Asset("ANIM", "anim/eyeplant_trap.zip"),
}

local function ondeploy(inst, pt) 
    local lp = SpawnPrefab("lureplant") 
    if lp then 
        lp.Transform:SetPosition(pt.x, pt.y, pt.z) 
        inst.components.stackable:Get():Remove()
        lp.sg:GoToState("spawn")
        inst.components.burnable:MakeDragonflyBait(1)
    end 
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.HEAVY, TUNING.WINDBLOWN_SCALE_MAX.HEAVY)

    inst.AnimState:SetBank("eyeplant_bulb")
    inst.AnimState:SetBuild("eyeplant_bulb")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL
    
	MakeSmallBurnable(inst, TUNING.LARGE_BURNTIME)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("deployable")

    inst.components.deployable.test = function(inst, pt, deployer) 
        local invalidTyles = {-1, 1, 0, 52, 55, 56, 57, 58, 59, 60, 61, 62, 63}
        local tile = GetVisualTileType(pt.x, pt.y, pt.z)
        
        for k,v in pairs(invalidTyles) do
            if v == tile then
                return false
            end
        end

        return true
    end

    inst.components.deployable.ondeploy = ondeploy

    return inst
end

return Prefab( "common/inventory/lureplantbulb", fn, assets),
MakePlacer( "common/lureplantbulb_placer", "eyeplant_trap", "eyeplant_trap", "idle_hidden" )

