--[[
Bees.lua

bee
Default bee type. Flies around to flowers and pollinates them, generally gets spawned out of beehives or player-made beeboxes

killerbee
Aggressive version of the bee. Doesn't pollinate anythihng, but attacks anything within range. If it has a home to go to and no target,
it should head back there. Killer bees come out to defend beehives when they, the hive or worker bees are attacked
]]--

local beecommon = require "brains/beecommon"
require "stategraphs/SGbee"

local assets=
{
	Asset("ANIM", "anim/bee.zip"),
	Asset("ANIM", "anim/bee_build.zip"),
	Asset("ANIM", "anim/bee_angry_build.zip"),
	Asset("SOUND", "sound/bee.fsb"),
}
	
	
local prefabs =
{
	"stinger",
	"honey",
}

local workersounds = 
{
	takeoff = "dontstarve/bee/bee_takeoff",
	attack = "dontstarve/bee/bee_attack",
	buzz = "dontstarve/bee/bee_fly_LP",
	hit = "dontstarve/bee/bee_hurt",
	death = "dontstarve/bee/bee_death",
}

local killersounds = 
{
	takeoff = "dontstarve/bee/killerbee_takeoff",
	attack = "dontstarve/bee/killerbee_attack",
	buzz = "dontstarve/bee/killerbee_fly_LP",
	hit = "dontstarve/bee/killerbee_hurt",
	death = "dontstarve/bee/killerbee_death",
}

local function StartDusk(inst)
	if inst:IsAsleep() and inst.components.homeseeker then
		inst.components.homeseeker:ForceGoHome()
	end
end

local function OnWorked(inst, worker)
	local owner = inst.components.homeseeker and inst.components.homeseeker.home
	if owner and owner.components.childspawner then
		owner.components.childspawner:OnChildKilled(inst)
	end
	if worker.components.inventory then
		
		if METRICS_ENABLED then
			FightStat_Caught(inst)
		end
		inst.SoundEmitter:KillSound("buzz")
		inst.SoundEmitter:KillAllSounds()
		worker.components.inventory:GiveItem(inst, nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))
	end
end

local function OnDropped(inst)
	inst.sg:GoToState("catchbreath")
	if inst.components.workable then
		inst.components.workable:SetWorkLeft(1)
	end
	if inst.brain then
		inst.brain:Start()
	end
	if inst.sg then
		inst.sg:Start()
	end
	if inst.components.stackable then
		while inst.components.stackable:StackSize() > 1 do
			local item = inst.components.stackable:Get()
			if item then
				if item.components.inventoryitem then
					item.components.inventoryitem:OnDropped()
				end
				item.Physics:Teleport(inst.Transform:GetWorldPosition() )
			end
		end
	end
end

local function OnPickedUp(inst)
	inst.sg:GoToState("idle")
	inst.SoundEmitter:KillSound("buzz")
	inst.SoundEmitter:KillAllSounds()
end

local function SpringBeeRetarget(inst)
	if GetSeasonManager() and (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then
		local range = 4
		return FindEntity(inst, range, function(guy)
			return inst.components.combat:CanTarget(guy)
		end, nil, {"insect"}, {"character", "animal", "monster"})
	else
		return false
	end
end

local function KillerRetarget(inst)
	local range = 8
	if GetSeasonManager() and (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then
		range = range * TUNING.SPRING_COMBAT_MOD
	end
	return FindEntity(inst, range, function(guy)
			return inst.components.combat:CanTarget(guy)
		end, nil, {"insect"}, {"character", "animal", "monster"})
end

local function OnWake(inst)
	if not inst.components.inventoryitem:IsHeld() then
		inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
	end
end

local function OnSleep(inst)
	inst.SoundEmitter:KillSound("buzz")
	if not GetClock():IsDay() and inst.components.homeseeker then
		inst.components.homeseeker:ForceGoHome()
	end
end

local function commonfn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLightWatcher()
	inst.entity:AddDynamicShadow()
	inst.DynamicShadow:SetSize( .8, .5 )
	inst.Transform:SetFourFaced()
	
	
	----------
	
	inst:AddTag("bee")
	inst:AddTag("insect")
	inst:AddTag("smallcreature")
	inst:AddTag("cattoyairborne")
	inst:AddTag("flying")
	inst:AddComponent("tradable")

	MakePoisonableCharacter(inst)
	MakeCharacterPhysics(inst, 1, .5)
	inst.Physics:SetCollisionGroup(COLLISION.FLYERS)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.WORLD)
	inst.Physics:CollidesWith(COLLISION.FLYERS)
	
	inst.AnimState:SetBank("bee")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetRayTestOnBB(true);
	
	inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
	inst.components.locomotor:EnableGroundSpeedMultiplier(false)
	inst.components.locomotor:SetTriggersCreep(false)
	inst:SetStateGraph("SGbee")
	
	inst:AddComponent("inventoryitem")
	inst:AddComponent("stackable")
	inst.components.inventoryitem.nobounce = true
	-- inst.components.inventoryitem:SetOnDroppedFn(OnDropped) Done in MakeFeedablePet
	-- inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickedUp)
	inst.components.inventoryitem.canbepickedup = false

	---------------------
	
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:AddRandomLoot("honey", 1)
	inst.components.lootdropper:AddRandomLoot("stinger", 5)   
	inst.components.lootdropper.numrandomloot = 1
	
	 ------------------
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.NET)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(OnWorked)
   
	MakeSmallBurnableCharacter(inst, "body", Vector3(0, -1, 1))
	MakeTinyFreezableCharacter(inst, "body", Vector3(0, -1, 1))
	
	------------------
	inst:AddComponent("health")

	------------------
	
	inst:AddComponent("combat")
	inst.components.combat.hiteffectsymbol = "body"

	------------------
	
	inst:AddComponent("sleeper")
	------------------
	
	inst:AddComponent("knownlocations")

	------------------
	
	inst:AddComponent("inspectable")
	
	inst:ListenForEvent("attacked", beecommon.OnAttacked)
	inst:ListenForEvent("worked", beecommon.OnWorked)

	MakeFeedablePet(inst, TUNING.TOTAL_DAY_TIME*2, OnPickedUp, OnDropped)

	inst.OnEntityWake = OnWake
	inst.OnEntitySleep = OnSleep
	inst:ListenForEvent( "dusktime", function() StartDusk( inst ) end, GetWorld())

	return inst
end

-- local brainfn = loadfile("scripts/brains/beebrain.lua")
-- assert(type(brainfn) == "function", brainfn)

local workerbrain = require("brains/beebrain")
local killerbrain = require("brains/killerbeebrain")


-- local function ChangeToNormalBuild(inst)
--     inst.AnimState:SetBuild("bee_build")
--     inst:RemoveEventCallback("onwenthome", ChangeToNormalBuild)
-- end

local function workerbee()
	local inst = commonfn()
	inst:AddTag("worker")
	if GetSeasonManager() and (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then
		inst.AnimState:SetBuild("bee_angry_build")
	else
		inst.AnimState:SetBuild("bee_build")
	end
	inst.components.health:SetMaxHealth(TUNING.BEE_HEALTH)
	inst.components.combat:SetDefaultDamage(TUNING.BEE_DAMAGE)
	inst.components.combat:SetAttackPeriod(TUNING.BEE_ATTACK_PERIOD)
	inst.components.combat:SetRetargetFunction(2, SpringBeeRetarget)
	inst:AddComponent("pollinator")
	inst:SetBrain(workerbrain)
	inst.sounds = workersounds

	-- inst:ListenForEvent("seasonChange", function(it, data) 
	--     if data.season == SEASONS.SPRING then
	--         inst.AnimState:SetBuild("bee_angry_build")
	--     else
	--         inst.AnimState:SetBuild("bee_build")
	--     end
	-- end, GetWorld())
	
	return inst
end

local function killerbee()
	local inst = commonfn()
	inst:AddTag("killer")
	inst:AddTag("scarytoprey")
	inst.AnimState:SetBuild("bee_angry_build")
	inst.components.health:SetMaxHealth(TUNING.BEE_HEALTH)
	inst.components.combat:SetDefaultDamage(TUNING.BEE_DAMAGE)
	inst.components.combat:SetAttackPeriod(TUNING.BEE_ATTACK_PERIOD)
	inst.components.combat:SetRetargetFunction(2, KillerRetarget)
	inst:SetBrain(killerbrain)
	inst.sounds = killersounds

	return inst
end 

return Prefab( "forest/monsters/bee", workerbee, assets, prefabs),
	   Prefab( "forest/monsters/killerbee", killerbee, assets, prefabs) 
