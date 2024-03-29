require "brains/oxbrain"
require "stategraphs/SGox"

local assets=
{
	Asset("ANIM", "anim/ox_basic.zip"),
	Asset("ANIM", "anim/ox_actions.zip"),
	Asset("ANIM", "anim/ox_build.zip"),
    Asset("ANIM", "anim/ox_shaved_build.zip"),

	Asset("ANIM", "anim/ox_basic_water.zip"),
	Asset("ANIM", "anim/ox_actions_water.zip"),

	Asset("ANIM", "anim/ox_heat_build.zip"),
	Asset("SOUND", "sound/beefalo.fsb"),
}

local prefabs =
{
	"meat",
	"poop",
	"ox_horn",
	--"horn",
}

SetSharedLootTable( 'ox',
{
	{'meat',            1.00},
	{'meat',            1.00},
	{'meat',            1.00},
	{'meat',            1.00},
	{'ox_horn',         1.00},
})

local sounds =
{
	angry = "dontstarve_DLC002/creatures/OX/angry",
	curious = "dontstarve_DLC002/creatures/OX/curious",

	attack_whoosh = "dontstarve_DLC002/creatures/OX/attack_whoosh",
	chew = "dontstarve_DLC002/creatures/OX/chew",
	grunt = "dontstarve_DLC002/creatures/OX/bellow",
	hairgrow_pop = "dontstarve_DLC002/creatures/OX/hairgrow_pop",
	hairgrow_vocal = "dontstarve_DLC002/creatures/OX/hairgrow_vocal",
	sleep = "dontstarve_DLC002/creatures/OX/sleep",
	tail_swish = "dontstarve_DLC002/creatures/OX/tail_swish",
	walk_land = "dontstarve_DLC002/creatures/OX/walk_land",
	walk_water = "dontstarve_DLC002/creatures/OX/walk_water",

	death = "dontstarve_DLC002/creatures/OX/death",
	mating_call = "dontstarve_DLC002/creatures/OX/mating_call",

	emerge = "dontstarve_DLC002/creatures/seacreature_movement/water_emerge_med",
	submerge = "dontstarve_DLC002/creatures/seacreature_movement/water_submerge_med",
}

local function OnEnterMood(inst)
	if inst.components.beard and inst.components.beard.bits > 0 then
		inst.AnimState:SetBuild("ox_heat_build")
		inst.AnimState:SetBank("ox")
		inst:AddTag("scarytoprey")
	end
end

local function OnLeaveMood(inst)
	if inst.components.beard and inst.components.beard.bits > 0 then
		inst.AnimState:SetBuild("ox_build")
		inst.AnimState:SetBank("ox")
		inst:RemoveTag("scarytoprey")
	end
end

local function Retarget(inst)
	local notags = {"FX", "NOCLICK","INLIMBO", "ox", "aquatic", "wall"}

	if inst.components.herdmember
	   and inst.components.herdmember:GetHerd()
	   and inst.components.herdmember:GetHerd().components.mood
	   and inst.components.herdmember:GetHerd().components.mood:IsInMood() then
		return FindEntity(inst, TUNING.OX_TARGET_DIST, function(guy)
			return inst.components.combat:CanTarget(guy)
		end, nil, notags)
	end
end

local function KeepTarget(inst, target)

	if inst.components.herdmember
	   and inst.components.herdmember:GetHerd()
	   and inst.components.herdmember:GetHerd().components.mood
	   and inst.components.herdmember:GetHerd().components.mood:IsInMood() then
		local herd = inst.components.herdmember and inst.components.herdmember:GetHerd()
		if herd and herd.components.mood and herd.components.mood:IsInMood() then
			return distsq(Vector3(herd.Transform:GetWorldPosition() ), Vector3(inst.Transform:GetWorldPosition() ) ) < TUNING.OX_CHASE_DIST*TUNING.OX_CHASE_DIST
		end
	end

	return true
end

local function OnNewTarget(inst, data)
	if inst.components.follower and data and data.target and data.target == inst.components.follower.leader then
		inst.components.follower:SetLeader(nil)
	end
end

local function OnAttacked(inst, data)
	inst.components.combat:SetTarget(data.attacker)
	inst.components.combat:ShareTarget(data.attacker, 30,function(dude)
		return dude:HasTag("ox") and not dude:HasTag("player") and not dude.components.health:IsDead()
	end, 5)
end

local function GetStatus(inst)
	if inst.components.follower.leader ~= nil then
		return "FOLLOWER"
	end
end

local function OnWaterChange(inst, onwater)
	if onwater then
		inst.sg:GoToState("submerge")
	else
		inst.sg:GoToState("emerge")
	end
end

local function OnPooped(inst, poop)
	local heading_angle = -(inst.Transform:GetRotation()) + 180

	local pos = Vector3(inst.Transform:GetWorldPosition())
	pos.x = pos.x + (math.cos(heading_angle*DEGREES))
	pos.y = pos.y + 0.9
	pos.z = pos.z + (math.sin(heading_angle*DEGREES))
	poop.Transform:SetPosition(pos.x, pos.y, pos.z)

	if poop.components.inventoryitem then
		poop.components.inventoryitem:OnStartFalling()
	end
end

local function OnEntityWake(inst)
	inst.components.tiletracker:Start()
end

local function OnEntitySleep(inst)
	inst.components.tiletracker:Stop()
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	inst.sounds = sounds
	inst.walksound = sounds.walk_land
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 6, 2 )
	inst.Transform:SetSixFaced()


	MakeAmphibiousCharacterPhysics(inst, 100, .5)
	MakePoisonableCharacter(inst)

	inst:AddTag("ox")
	anim:SetBank("ox")
	anim:SetBuild("ox_build")
	anim:PlayAnimation("idle_loop", true)

	inst:AddTag("animal")
	inst:AddTag("largecreature")
    
    local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "ox.png" )
    minimap:SetPriority( 1 )

	local hair_growth_days = 3
--[[
    inst:AddComponent("beard")
    -- assume the beefalo has already grown its hair
    inst.components.beard.bits = 3
    inst.components.beard.daysgrowth = hair_growth_days + 1
    inst.components.beard.onreset = function()
        inst.sg:GoToState("shaved")
    end

    inst.components.beard.canshavetest = function() if not inst.components.sleeper:IsAsleep() then return false, "AWAKEBEEFALO" end return true end

    inst.components.beard.prize = "oxwool"
    inst.components.beard:AddCallback(0, function()
        if inst.components.beard.bits == 0 then
            anim:SetBuild("ox_shaved_build")
        end
    end)
    inst.components.beard:AddCallback(hair_growth_days, function()
        if inst.components.beard.bits == 0 then
            inst.hairGrowthPending = true
        end
    end)
]]
	inst:AddComponent("eater")
	inst.components.eater:SetVegetarian()

	inst:AddComponent("combat")
	inst.components.combat.hiteffectsymbol = "beefalo_body"
	inst.components.combat:SetDefaultDamage(TUNING.OX_DAMAGE)
	inst.components.combat:SetRetargetFunction(1, Retarget)
	inst.components.combat:SetKeepTargetFunction(KeepTarget)

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.OX_HEALTH)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable('ox')

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

	inst:AddComponent("knownlocations")
	inst:AddComponent("herdmember")
	inst.components.herdmember.herdprefab = "oxherd"

	inst:ListenForEvent("entermood", OnEnterMood)
	inst:ListenForEvent("leavemood", OnLeaveMood)

	inst:AddComponent("leader")
	inst:AddComponent("follower")
	inst.components.follower.maxfollowtime = TUNING.OX_FOLLOW_TIME
	inst.components.follower.canaccepttarget = false
	inst:ListenForEvent("newcombattarget", OnNewTarget)
	inst:ListenForEvent("attacked", OnAttacked)

	inst:AddComponent("periodicspawner")
	inst.components.periodicspawner:SetPrefab("poop")
	inst.components.periodicspawner:SetRandomTimes(40, 60)
	inst.components.periodicspawner:SetDensityInRange(20, 2)
	inst.components.periodicspawner:SetMinimumSpacing(8)
	inst.components.periodicspawner:SetOnSpawnFn(OnPooped)
	inst.components.periodicspawner:Start()

	MakeLargeBurnableCharacter(inst, "swap_fire")
	MakeLargeFreezableCharacter(inst, "beefalo_body")

	inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
	inst.components.locomotor.walkspeed = 1.5
	inst.components.locomotor.runspeed = 7

	--inst.components.locomotor:SetStopOffscreen(true)

	inst:AddComponent("sleeper")
	inst.components.sleeper:SetResistance(3)

	inst:AddComponent("tiletracker")
	inst.components.tiletracker:SetOnWaterChangeFn(OnWaterChange)

	local brain = require "brains/oxbrain"
	inst:SetBrain(brain)
	inst:SetStateGraph("SGox")

	inst.OnEntityWake = OnEntityWake
	inst.OnEntitySleep = OnEntitySleep

	return inst
end

return Prefab( "forest/animals/ox", fn, assets, prefabs)
