local assets =
{
	--Asset("ANIM", "anim/arrow_indicator.zip"),
}

local prefabs = 
{
	"ballphin",
}

local function InMood(inst)
	if inst.components.periodicspawner then
		inst.components.periodicspawner:Start()
	end
	if inst.components.herd then
		for k,v in pairs(inst.components.herd.members) do
			k:PushEvent("entermood")
		end
	end
end

local function LeaveMood(inst)
	if inst.components.periodicspawner then
		inst.components.periodicspawner:Stop()
	end
	if inst.components.herd then
		for k,v in pairs(inst.components.herd.members) do
			k:PushEvent("leavemood")
		end
	end
	inst.components.mood:CheckForMoodChange()
end

local function AddMember(inst, member)
	if inst.components.mood then
		if inst.components.mood:IsInMood() then
			member:PushEvent("entermood")
		else
			member:PushEvent("leavemood")
		end
	end
end

local function CanSpawn(inst)
	local iswater = false
	local ground = GetWorld()
	local pt = inst:GetPosition()
	local tile = ground.Map:GetTileAtPoint(pt.x,pt.y,pt.z)
	if tile and GetMap():IsWater(tile) then
		iswater = true
	end
	return inst.components.herd and not inst.components.herd:IsFull() and iswater
end

local function OnSpawned(inst, newent)
	if inst.components.herd then
		inst.components.herd:AddMember(newent)
	end
end

local function OnEmpty(inst)
	inst:Remove()
end

local function OnFull(inst)
	--TODO: mark some ballphin for death
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	
	-- anim:SetBank("arrow_indicator")
	-- anim:SetBuild("arrow_indicator")
	-- anim:PlayAnimation("arrow_loop", true)

	inst:AddTag("herd")
	inst:AddTag("NOBLOCK")
	
	inst:AddComponent("herd")
	inst.components.herd:SetMemberTag("ballphin")
	inst.components.herd:SetGatherRange(40)
	inst.components.herd:SetUpdateRange(20)
	inst.components.herd:SetOnEmptyFn(OnEmpty)
	inst.components.herd:SetOnFullFn(OnFull)
	inst.components.herd:SetAddMemberFn(AddMember)
	
	inst:AddComponent("mood")
	inst.components.mood:SetMoodTimeInDays(TUNING.BEEFALO_MATING_SEASON_LENGTH, TUNING.BEEFALO_MATING_SEASON_WAIT)
	inst.components.mood:SetMoodSeason(SEASONS.MILD)
	inst.components.mood:SetInMoodFn(InMood)
	inst.components.mood:SetLeaveMoodFn(LeaveMood)
	inst.components.mood:CheckForMoodChange()
	
	inst:AddComponent("periodicspawner")
	inst.components.periodicspawner:SetRandomTimes(TUNING.BEEFALO_MATING_SEASON_BABYDELAY, TUNING.BEEFALO_MATING_SEASON_BABYDELAY_VARIANCE)
	inst.components.periodicspawner:SetPrefab("ballphin")
	inst.components.periodicspawner:SetOnSpawnFn(OnSpawned)
	inst.components.periodicspawner:SetSpawnTestFn(CanSpawn)
	inst.components.periodicspawner:SetDensityInRange(20, 6)
	inst.components.periodicspawner:SetOnlySpawnOffscreen(true)
	
	return inst
end

return Prefab( "forest/animals/ballphinpod", fn, assets, prefabs)
