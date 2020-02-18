require "prefabutil"
local assets =
{
	Asset("ANIM", "anim/jungletreeseed.zip"),
}

local function growtree(inst)
	-- print ("GROWTREE")
    inst.growtask = nil
    inst.growtime = nil
	local tree = SpawnPrefab("jungletree_short") 
    if tree then 
		tree.Transform:SetPosition(inst.Transform:GetWorldPosition() ) 
        tree:growfromseed()--PushEvent("growfromseed")
        inst:Remove()
	end
end

local function plant(inst, growtime)

    --[[if not SaveGameIndex:IsModeShipwrecked() then
        inst.AnimState:PlayAnimation("idle_planted")
        inst.AnimState:PushAnimation("idle_planted")
        inst.AnimState:PushAnimation("idle_planted")
        inst.AnimState:PushAnimation("idle_planted")
        inst.AnimState:PushAnimation("death", false)
        inst:ListenForEvent("animqueueover", function()
            local player = GetPlayer()
            if player and player.components.talker then
                player.components.talker:Say(GetString(player.prefab, "ANNOUNCE_OTHER_WORLD_PLANT"))
            end
            local time_to_erode = 4
            local tick_time = TheSim:GetTickTime()
            inst:StartThread( function()
                local ticks = 0
                while ticks * tick_time < time_to_erode do
                    local erode_amount = ticks * tick_time / time_to_erode
                    inst.AnimState:SetErosionParams( erode_amount, 0.1, 1.0 )
                    ticks = ticks + 1
                    Yield()
                end
                inst:Remove()
            end)
        end)
        return
    end]]
    
    inst:RemoveComponent("inventoryitem")
    inst:RemoveComponent("locomotor")
    RemovePhysicsColliders(inst)
    RemoveBlowInHurricane(inst)
    inst.AnimState:PlayAnimation("idle_planted")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    inst.growtime = GetTime() + growtime
    -- print ("PLANT", growtime)
    inst.growtask = inst:DoTaskInTime(growtime, growtree)
end

local function ondeploy (inst, pt) 
    inst = inst.components.stackable:Get()
    inst.Transform:SetPosition(pt:Get() )
    local timeToGrow = GetRandomWithVariance(TUNING.JUNGLETREESEED_GROWTIME.base, TUNING.JUNGLETREESEED_GROWTIME.random)
    plant(inst, timeToGrow)
	
end

local function stopgrowing(inst)
    if inst.growtask then
        inst.growtask:Cancel()
        inst.growtask = nil
    end
    inst.growtime = nil
end

local function restartgrowing(inst)
    if inst and not inst.growtask then
        local growtime = GetRandomWithVariance(TUNING.JUNGLETREESEED_GROWTIME.base, TUNING.JUNGLETREESEED_GROWTIME.random)
        inst.growtime = GetTime() + growtime
        inst.growtask = inst:DoTaskInTime(growtime, growtree)
    end
end


local notags = {'NOBLOCK', 'player', 'FX'}
local function test_ground(inst, pt)
	local tiletype = GetGroundTypeAtPosition(pt)
	local ground_OK = tiletype ~= GROUND.ROCKY and tiletype ~= GROUND.ROAD and tiletype ~= GROUND.IMPASSABLE and tiletype ~= GROUND.MAGMAFIELD and
						tiletype ~= GROUND.UNDERROCK and tiletype ~= GROUND.WOODFLOOR and tiletype ~= GROUND.BEACH and 
						tiletype ~= GROUND.CARPET and tiletype ~= GROUND.LEAKPROOFCARPET and tiletype ~= GROUND.CHECKER and tiletype < GROUND.UNDERGROUND and
                        tiletype ~= GROUND.ASH and tiletype ~= GROUND.VOLCANO and tiletype ~= GROUND.VOLCANO_ROCK and tiletype ~= GROUND.BRICK_GLOW and
                        inst:IsPosSurroundedByLand(pt.x, pt.y, pt.z, 1)
	
	if ground_OK then
	    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 4, nil, notags) -- or we could include a flag to the search?
		local min_spacing = inst.components.deployable.min_spacing or 2

	    for k, v in pairs(ents) do
			if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
				if distsq( Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing*min_spacing then
					return false
				end
			end
		end
		return true
	end
	return false
end

local function describe(inst)
    if inst.growtime then
        return "PLANTED"
    end
end

local function displaynamefn(inst)
    if inst.growtime then
        return STRINGS.NAMES.JUNGLE_TREE_SAPLING
    end
    return STRINGS.NAMES.JUNGLE_TREE_SEED
end

local function OnSave(inst, data)
    if inst.growtime then
        data.growtime = inst.growtime - GetTime()
    end
end

local function OnLoad(inst, data)
    if data and data.growtime then
        plant(inst, data.growtime)
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)

    inst.AnimState:SetBank("jungletreeseed")
    inst.AnimState:SetBuild("jungletreeseed")
    inst.AnimState:PlayAnimation("idle")
    

    --inst:AddComponent("edible")
    --inst.components.edible.foodtype = "WOOD"
    --inst.components.edible.woodiness = 2

    inst:AddTag("cattoy")
    inst:AddComponent("tradable")

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = describe
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL
    
	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
	inst:ListenForEvent("onignite", stopgrowing)
    inst:ListenForEvent("onextinguish", restartgrowing)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("deployable")
    inst.components.deployable.test = test_ground
    inst.components.deployable.ondeploy = ondeploy
    
    inst.displaynamefn = displaynamefn

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab( "common/inventory/jungletreeseed", fn, assets),
	   MakePlacer( "common/jungletreeseed_placer", "jungletreeseed", "jungletreeseed", "idle_planted" ) 


