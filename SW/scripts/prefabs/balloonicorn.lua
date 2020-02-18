--Seperating this from Chester files because Pyro won't be on all platforms.
require "stategraphs/SGballoonicorn"
require "prefabutil"
local brain = require "brains/balloonicornbrain"

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local assets = 
{
	Asset("ANIM", "anim/balloonicorn_chester.zip"),
}

local prefabs =
{
    "chester_eyebone",
}

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("open") 
    and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) 
    and GetWorld().components.clock:GetMoonPhase() ~= "full"
end

local function ShouldKeepTarget(inst, target)
    return false
end

local function OnOpen(inst)
    if not inst.components.health:IsDead() then
        if inst.MorphTask then
            inst.MorphTask:Cancel()
            inst.MorphTask = nil
        end
        inst.sg:GoToState("open")
    end
end 

local function OnClose(inst) 
    if not inst.components.health:IsDead() then
        inst.sg:GoToState("close")
    end
end 

local function OnStopFollowing(inst) 
    inst:RemoveTag("companion") 
end

local function OnStartFollowing(inst) 
    inst:AddTag("companion") 
end

local slotpos_3x3 = {}

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(slotpos_3x3, Vector3(80*x-80*2+80, 80*y-80*2+80,0))
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "balloonicorn.png" )

    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 75, .5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    
    inst.AnimState:SetBank("balloonicorn_chester")
    inst.AnimState:SetBuild("balloonicorn_chester")
    
    inst.DynamicShadow:SetSize(2, 1.5)

    inst:AddTag("companion")
    inst:AddTag("character")
    inst:AddTag("scarytoprey")
    inst:AddTag("chester")
    inst:AddTag("notraptrigger")
    inst:AddTag("cattoy")
    inst:AddTag("noauradamage")
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "chester_body"
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.CHESTER_HEALTH)
    inst.components.health:StartRegen(TUNING.CHESTER_HEALTH_REGEN_AMOUNT, TUNING.CHESTER_HEALTH_REGEN_PERIOD)

    inst:AddComponent("inspectable")

    inst:AddComponent("follower")
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)

    inst:AddComponent("knownlocations")

    inst:AddComponent("container")
    inst.components.container:SetNumSlots(#slotpos_3x3)
    
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    
    inst.components.container.widgetslotpos = slotpos_3x3
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetpos = Vector3(-125,100,0)

    inst.components.container.side_align_tip = 160

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 3
    inst.components.locomotor.runspeed = 7

    inst:SetStateGraph("SGballoonicorn")
    inst:SetBrain(brain)  

    MakeSmallBurnableCharacter(inst, "chester_body")

    return inst
end

return Prefab("balloonicorn", fn, assets, prefabs)
