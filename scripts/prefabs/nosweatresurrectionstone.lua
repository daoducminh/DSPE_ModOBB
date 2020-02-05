local DeathScreen = require "screens/deathscreen"

local assets = 
{
	Asset("ANIM", "anim/nosweatresurrectionstone.zip")
}

local prefabs =
{
	"rocks",
	"flint",
}

local function OnActivate(inst)
	inst.components.resurrector.active = true
	inst.AnimState:PlayAnimation("activate")
	inst.AnimState:PushAnimation("idle_activate", true)
	inst.SoundEmitter:PlaySound("dontstarve/common/resurrectionstone_activate")

	-- inst.AnimState:SetLayer( LAYER_WORLD )
	-- inst.AnimState:SetSortOrder( 0 )

	inst.Physics:CollidesWith(COLLISION.CHARACTERS)	
	inst.components.resurrector:OnBuilt()
end

local function makeactive(inst)
	inst.AnimState:PlayAnimation("repair", false)
	--inst.components.activatable.inactive = false
end

local function makeused(inst)
	inst.AnimState:PlayAnimation("idle_broken", true)
end

local function doresurrect(inst, dude)
	inst:AddTag("busy")	

	local days_survived, start_xp, reward_xp, new_xp, capped = CalculatePlayerRewards(dude)
	days_survived = days_survived - inst.components.resurrector.lastdayused

	local screen = DeathScreen(days_survived, start_xp, "nosweat", capped, function()

		dude.profile:Save()

		GetClock():MakeNextDay()
	    dude.Transform:SetPosition(inst.Transform:GetWorldPosition())
	    dude:Hide()
	    TheCamera:SetDistance(12)
		dude.components.hunger:Pause()
	
	    scheduler:ExecuteInTime(3, function()
	        dude:Show()
	        --inst:Hide()

	        GetSeasonManager():DoLightningStrike(Vector3(inst.Transform:GetWorldPosition()))

			inst.SoundEmitter:PlaySound("dontstarve/common/resurrectionstone_break")
	        inst.components.lootdropper:DropLoot()
	        makeused(inst)
	        --inst:Remove()
	        
	        if dude.components.hunger then
	            dude.components.hunger:SetPercent(2/3)
	        end

	        if dude.components.health then
	            dude.components.health:Respawn(TUNING.NOSWEAT_RESURRECT_HEALTH)
	        end
	        
	        if dude.components.sanity then
				dude.components.sanity:SetPercent(.75)
	        end
        
	        dude.components.hunger:Resume()
	        
	        dude.sg:GoToState("wakeup")
	        
	        dude:DoTaskInTime(3, function(dude) 
			            if dude.HUD then
			                dude.HUD:Show()
			            end
			            TheCamera:SetDefault()
			            inst:DoTaskInTime(2, function(inst)
			            	inst:RemoveTag("busy")
			            	makeactive(inst)
			            end)

				--SaveGameIndex:SaveCurrent(function()
				--	end)            
	        end)

	    end)        
    end)

	TheFrontEnd:PushScreen(screen)
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	MakeObstaclePhysics(inst, 0.3)
	--inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
	--inst.Physics:ClearCollisionMask()
	--inst.Physics:CollidesWith(COLLISION.WORLD)
	--inst.Physics:CollidesWith(COLLISION.ITEMS)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"rocks","flint","flint"}) 

	anim:SetBank("nosweatresurrectionstone")
	anim:SetBuild("nosweatresurrectionstone")
	anim:PlayAnimation("idle_activate")
	-- anim:SetLayer( LAYER_BACKGROUND )
	-- anim:SetSortOrder( 3 )

	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon( "nosweatresurrectionstone.png" )

	inst:AddComponent("resurrector")
	--inst.components.resurrector.makeactivefn = makeactive
	--inst.components.resurrector.makeusedfn = makeused
    inst.components.resurrector.active = true
    inst.components.resurrector.reusable = true
	inst.components.resurrector.doresurrect = doresurrect

	inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()
	return inst
end

return Prefab("forest/objects/nosweatresurrectionstone", fn, assets, prefabs) 
