require "class"
require "bufferedaction"


Action = Class(function(self, priority, instant, rmb, distance) 
    self.priority = priority or 0
    self.fn = function() return false end
    self.strfn = nil
    self.testfn = nil
    self.instant = instant or false
    self.rmb = rmb or nil
    self.distance = distance or nil
end)

ACTIONS=
{
	REPAIR = Action(),
    READ = Action(),
    DROP = Action(-1),
    TRAVEL = Action(),
    CHOP = Action(),
    ATTACK = Action(2, true),
    WHACK = Action(2, true),
    FORCEATTACK = Action(2, true),
    EAT = Action(),
    PICK = Action(),
    PICKUP = Action(1),
    MINE = Action(),
    DIG = Action(nil, nil, true),
    GIVE = Action(),
    COOK = Action(),
    DRY = Action(),
    ADDFUEL = Action(),
    ADDWETFUEL = Action(),
    LIGHT = Action(-4),
    EXTINGUISH = Action(0),
    LOOKAT = Action(-3, true),
    TALKTO = Action(3, true),
    WALKTO = Action(-4),
    BAIT = Action(),
    CHECKTRAP = Action(2),
    BUILD = Action(0, true),
    PLANT = Action(),
    HARVEST = Action(0, true),
    GOHOME = Action(),
    SLEEPIN = Action(),
    EQUIP = Action(0,true),
    UNEQUIP = Action(-2,true),
    --OPEN_SHOP = Action(),
    SHAVE = Action(),
    STORE = Action(),
    STORE_HALF = Action(),
    RUMMAGE = Action(-1),
    DEPLOY = Action(),
    PLAY = Action(),
    NET = Action(3),
    CATCH = Action(3, true),
    FISH = Action(),
    REEL = Action(0, true),
    POLLINATE = Action(),
    FERTILIZE = Action(),
    SMOTHER = Action(),
    MANUALEXTINGUISH = Action(),
    RANGEDSMOTHER = Action(0, true),
    RANGEDLIGHT = Action(-4, true),
    LAYEGG = Action(),
    HAMMER = Action(3),
    TERRAFORM = Action(),
	JUMPIN = Action(),
	RESETMINE = Action(3),
    ACTIVATE = Action(),
    MURDER = Action(0),
    HEAL = Action(),
    INVESTIGATE = Action(),
    UNLOCK = Action(),
    TEACH = Action(),
    TURNON = Action(2),
    TURNOFF = Action(2),
    SEW = Action(),
    STEAL = Action(),
    USEITEM = Action(1, true),
    TAKEITEM = Action(),
    MAKEBALLOON = Action(),
    CASTSPELL = Action(0, false, true, 20),
    BLINK = Action(10, false, true, 36),
    COMBINESTACK = Action(),
    TOGGLE_DEPLOY_MODE = Action(0, true),
    TOGGLE_PLANT_MODE = Action(0, true),
    CANCEL_PLANT_MODE = Action(0, true),
    DROP_HALF = Action(-1),
    SPLITSTACK = Action(0, true),
        
    SUMMONGUARDIAN = Action(0, false, false, 5),
    LAVASPIT = Action(0, false, false, 2),
    HAIRBALL = Action(0, false, false, 3),
    CATPLAYGROUND = Action(0, false, false, 1),
    CATPLAYAIR = Action(0, false, false, 2),
    STEALMOLEBAIT = Action(0, false, false, .75),
    MAKEMOLEHILL = Action(4, false, false, 0),
    MOLEPEEK = Action(0, false, false, 1),
    BURY = Action(0, false, false),
    FEED = Action(0, false, true),
    FAN = Action(0, false, true),
    UPGRADE = Action(0, false, true),
}

for k,v in pairs(ACTIONS) do
    v.str = STRINGS.ACTIONS[k] or "ACTION"
    v.id = k
end

----set up the action functions!
ACTIONS.EAT.fn = function(act)
    local obj = act.target or act.invobject
    if act.doer.components.eater and obj and obj.components.edible then
    	return act.doer.components.eater:Eat(obj) 
    end
end

ACTIONS.STEAL.fn = function(act)
    local obj = act.target
    local attack = false
    if act.attack then attack = act.attack end    

    if (obj.components.inventoryitem and obj.components.inventoryitem:IsHeld()) then
        return act.doer.components.thief:StealItem(obj.components.inventoryitem.owner, obj, attack)
    end
end

ACTIONS.MAKEBALLOON.fn = function(act)
    if act.doer and act.invobject and act.invobject.components.balloonmaker then
        if act.doer.components.sanity then
            act.doer.components.sanity:DoDelta(-TUNING.SANITY_TINY)
        end
        local x,y,z = act.doer.Transform:GetWorldPosition()
        local angle = TheCamera.headingtarget + math.random()*10*DEGREES-5*DEGREES
        x = x + .5*math.cos(angle)
        z = z + .5*math.sin(angle)
        act.invobject.components.balloonmaker:MakeBalloon(x,y,z)
    end
    return true
end

ACTIONS.EQUIP.fn = function(act)
    if act.doer.components.inventory then
        return act.doer.components.inventory:Equip(act.invobject)
    end
end

ACTIONS.UNEQUIP.fn = function(act)
    if act.doer.components.inventory and act.invobject and act.invobject.components.inventoryitem.cangoincontainer then
		act.doer.components.inventory:GiveItem(act.invobject)
    	--return act.doer.components.inventory:Unequip(act.invobject)
    	return true
    elseif act.doer.components.inventory and act.invobject and not act.invobject.components.inventoryitem.cangoincontainer then
        act.doer.components.inventory:DropItem(act.invobject, true, true)
        return true
    end
end

ACTIONS.PICKUP.fn = function(act)
    if act.doer.components.inventory and act.target and act.target.components.inventoryitem and not act.target:IsInLimbo() then    
	    act.doer:PushEvent("onpickup", {item = act.target})

        --special case for trying to carry two backpacks
        if not act.target.components.inventoryitem.cangoincontainer and act.target.components.equippable and act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot) then
            local item = act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot)
            if item.components.inventoryitem and item.components.inventoryitem.cangoincontainer then
                
                --act.doer.components.inventory:SelectActiveItemFromEquipSlot(act.target.components.equippable.equipslot)
                act.doer.components.inventory:GiveItem(act.doer.components.inventory:Unequip(act.target.components.equippable.equipslot))
            else
                act.doer.components.inventory:DropItem(act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot))
            end
            act.doer.components.inventory:Equip(act.target)
            return true
        end

        if act.doer:HasTag("player") and act.target.components.equippable and not act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot) then
            act.doer.components.inventory:Equip(act.target)
        else
	       act.doer.components.inventory:GiveItem(act.target, nil, Vector3(TheSim:GetScreenPos(act.target.Transform:GetWorldPosition())))
        end
        return true 
	end
end



ACTIONS.REPAIR.fn = function(act)
	if act.target and act.target.components.repairable and act.invobject and act.invobject.components.repairer then
		return act.target.components.repairable:Repair(act.doer, act.invobject)
	end
end

ACTIONS.SEW.fn = function(act)
	if act.target and act.target.components.fueled and act.invobject and act.invobject.components.sewing then
		return act.invobject.components.sewing:DoSewing(act.target, act.doer)
	end
end


ACTIONS.RUMMAGE.fn = function(act)
    local targ = act.target or act.invobject
    
    if act.doer.HUD and targ.components.container then
        if targ.components.container:IsOpen() then
			targ.components.container:Close(act.doer)
            act.doer:PushEvent("closecontainer", {container=targ})
        else
            act.doer:PushEvent("opencontainer", {container=targ})
			targ.components.container:Open(act.doer)
        end
        return true
    end
end

ACTIONS.RUMMAGE.strfn = function(act)
    local targ = act.target or act.invobject
    
    if targ and targ.components.container and targ.components.container:IsOpen() then
        return "CLOSE"
    end
end

ACTIONS.DROP.fn = function(act) 
    if act.doer.components.inventory then
		local wholestack = act.options.wholestack
		if act.invobject and act.invobject.components.stackable and act.invobject.components.stackable.forcedropsingle then
			wholestack = false	
		end
    	return act.doer.components.inventory:DropItem(act.invobject, wholestack, false, act.pos) 
   	end
end

ACTIONS.DROP.strfn = function(act)
    if act.invobject and act.invobject.components.trap then
        return "SETTRAP"
    elseif act.invobject and act.invobject:HasTag("mine") then
        return "SETMINE"
    elseif act.invobject and act.invobject.prefab == "pumpkin_lantern" then
        return "PLACELANTERN"
    end
end

ACTIONS.DROP_HALF.fn = function(act) 
    if act.doer.components.inventory then
        if act.invobject and act.invobject.components.stackable then
            local half = act.invobject.components.stackable:Get(math.floor(act.invobject.components.stackable:StackSize() / 2))
            return act.doer.components.inventory:DropItem(half, false, false, act.pos) 
        else
            return act.doer.components.inventory:DropItem(act.invobject, true, false, act.pos) 
        end
    end
end

ACTIONS.LOOKAT.fn = function(act)
    local targ = act.target or act.invobject
    if targ and targ.components.inspectable then
	    local desc = targ.components.inspectable:GetDescription(act.doer)
	    if desc then
	        act.doer.components.locomotor:Stop()

	        act.doer.components.talker:Say(desc, 2.5, targ.components.inspectable.noanim)
	        return true
	    end
	end
end


ACTIONS.READ.fn = function(act)
    local targ = act.target or act.invobject
    if targ and targ.components.book and act.doer and act.doer.components.reader then
        return act.doer.components.reader:Read(targ)
    end
end

ACTIONS.TALKTO.fn = function(act)
    local targ = act.target or act.invobject
    if targ and targ.components.talkable then
        act.doer.components.locomotor:Stop()

        if act.target.components.maxwelltalker then
            if not act.target.components.maxwelltalker:IsTalking() then
                act.target:PushEvent("talkedto")
                act.target.task = act.target:StartThread(function() act.target.components.maxwelltalker:DoTalk(act.target) end)
            end
        end
        return true
    end
end

ACTIONS.BAIT.fn = function(act)
    if act.target.components.trap then
	    act.target.components.trap:SetBait(act.doer.components.inventory:RemoveItem(act.invobject))
	    return true
	end
end

ACTIONS.DEPLOY.fn = function(act)
    if act.invobject and act.invobject.components.deployable and act.invobject.components.deployable:CanDeploy(act.pos) then
	    local obj = (act.doer.components.inventory and act.doer.components.inventory:RemoveItem(act.invobject)) or 
        (act.doer.components.container and act.doer.components.container:RemoveItem(act.invobject))
	    if obj then
			if obj.components.deployable:Deploy(act.pos, act.doer) then
				return true
			else
				act.doer.components.inventory:GiveItem(obj)
			end
		end
    end
end

ACTIONS.DEPLOY.strfn = function(act)
	if act.invobject and act.invobject:HasTag("groundtile") then
		return "GROUNDTILE"
	elseif act.invobject and act.invobject:HasTag("wallbuilder") then
		return "WALL"
	elseif act.invobject and act.invobject:HasTag("eyeturret") then
        return "TURRET"
    end
end

ACTIONS.TOGGLE_DEPLOY_MODE.strfn = function(act)
    if act.invobject and act.invobject:HasTag("groundtile") then
        return "GROUNDTILE"
    elseif act.invobject and act.invobject:HasTag("wallbuilder") then
        return "WALL"
    elseif act.invobject and act.invobject:HasTag("eyeturret") then
        return "TURRET"
    end
end

ACTIONS.TOGGLE_PLANT_MODE.fn = function(act)
    GetPlayer().components.playercontroller:StartPlantMode(act.plantTile)
end

ACTIONS.TOGGLE_PLANT_MODE.strfn = function(act)
    if act.invobject and act.invobject:HasTag("groundtile") then
        return "GROUNDTILE"
    elseif act.invobject and act.invobject:HasTag("wallbuilder") then
        return "WALL"
    elseif act.invobject and act.invobject:HasTag("eyeturret") then
        return "TURRET"
    end
end

ACTIONS.CANCEL_PLANT_MODE.fn = function(act)
    GetPlayer().components.playercontroller:CancelPlantMode()
end


ACTIONS.CHECKTRAP.fn = function(act)
    if act.target.components.trap then
	    act.target.components.trap:Harvest(act.doer)
	    return true
    end
end

ACTIONS.CHOP.fn = function(act)
    if act.target.components.workable and act.target.components.workable.action == ACTIONS.CHOP then
        local numworks = 1

        if act.invobject and act.invobject.components.tool then
            numworks = act.invobject.components.tool:GetEffectiveness(ACTIONS.CHOP)
        elseif act.doer and act.doer.components.worker then
            numworks = act.doer.components.worker:GetEffectiveness(ACTIONS.CHOP)
        end
        act.target.components.workable:WorkedBy(act.doer, numworks)
    end
    return true
end

ACTIONS.FERTILIZE.fn = function(act)
    if act.target and act.target.components.crop and not act.target.components.crop:IsReadyForHarvest() and not act.target.components.crop:IsWithered() and act.invobject and act.invobject.components.fertilizer then
        local obj = act.invobject

        if act.target.components.crop:Fertilize(obj) then
			return true
		else
			return false
		end
    elseif act.target.components.grower and act.target.components.grower:IsEmpty() and act.invobject and act.invobject.components.fertilizer then
        local obj = act.invobject
        act.target.components.grower:Fertilize(obj)
	elseif act.target.components.pickable and act.target.components.pickable:CanBeFertilized() and act.invobject and act.invobject.components.fertilizer then
        local obj = act.invobject
        act.target.components.pickable:Fertilize(obj)
		return true		
	end
end

ACTIONS.SMOTHER.fn = function(act)
    if act.target.components.burnable and act.target.components.burnable:IsSmoldering() then
        local smotherer = act.invobject or act.doer
        act.target.components.burnable:SmotherSmolder(smotherer)
        return true
    end
end

ACTIONS.MANUALEXTINGUISH.fn = function(act)
    if act.invobject:HasTag("frozen") and act.target.components.burnable and act.target.components.burnable:IsBurning() then
        act.target.components.burnable:Extinguish(true, TUNING.SMOTHERER_EXTINGUISH_HEAT_PERCENT, act.invobject)
        return true
    end
end

ACTIONS.RANGEDSMOTHER.fn = function(act)
    if act.target.components.burnable and 
        (act.target.components.burnable:IsSmoldering() or act.target.components.burnable:IsBurning()) then

        act.doer.components.combat:SetTarget(act.target)
        return true
    end
end

ACTIONS.RANGEDLIGHT.fn = function(act)
    if act.target.components.burnable and not act.target.components.burnable:IsBurning() and not act.target:HasTag("burnt") then
        act.doer.components.combat:SetTarget(act.target)
        return true
    end
end

ACTIONS.MINE.fn = function(act)
    if act.target.components.workable and act.target.components.workable.action == ACTIONS.MINE then
        local numworks = 1

        if act.invobject and act.invobject.components.tool then
            numworks = act.invobject.components.tool:GetEffectiveness(ACTIONS.MINE)
        elseif act.doer and act.doer.components.worker then
            numworks = act.doer.components.worker:GetEffectiveness(ACTIONS.MINE)
        end
        act.target.components.workable:WorkedBy(act.doer, numworks)
    end
    return true
end

ACTIONS.HAMMER.fn = function(act)
    if act.target.components.workable and act.target.components.workable.action == ACTIONS.HAMMER then
        local numworks = 1

        if act.invobject and act.invobject.components.tool then
            numworks = act.invobject.components.tool:GetEffectiveness(ACTIONS.HAMMER)
        elseif act.doer and act.doer.components.worker then
            numworks = act.doer.components.worker:GetEffectiveness(ACTIONS.HAMMER)
        end
        act.target.components.workable:WorkedBy(act.doer, numworks)
    end
    return true
end

ACTIONS.NET.fn = function(act)
    if act.target.components.workable and act.target.components.workable.action == ACTIONS.NET then
        act.target.components.workable:WorkedBy(act.doer)
    end
    return true
end

ACTIONS.CATCH.fn = function(act)
    if act.doer.components.catcher then
        act.doer.components.catcher:PrepareToCatch()
    elseif act.target.components.catcher then
		act.target.components.catcher:PrepareToCatch()
    end
    return true
end

ACTIONS.FISH.fn = function(act)
    local fishingrod = act.invobject.components.fishingrod
    if fishingrod then
        fishingrod:StartFishing(act.target, act.doer)
    end
    return true
end

ACTIONS.REEL.fn = function(act)
    local fishingrod = act.invobject.components.fishingrod
    if fishingrod and fishingrod:IsFishing() then
        if fishingrod:HasHookedFish() then
            fishingrod:Reel()
        elseif fishingrod:FishIsBiting() then
            fishingrod:Hook()
        else
            fishingrod:StopFishing()
        end
    end
    return true
end

ACTIONS.REEL.strfn = function(act)
    local fishingrod = act.invobject.components.fishingrod
    if fishingrod and fishingrod:IsFishing() then
        if fishingrod:HasHookedFish() then
            return "REEL"
        elseif fishingrod:FishIsBiting() then
            return "HOOK"
        else
            return "CANCEL"
        end
    end
end

ACTIONS.DIG.fn = function(act)
    if act.target.components.workable and act.target.components.workable.action == ACTIONS.DIG then
        local numworks = 1

        if act.invobject and act.invobject.components.tool then
            numworks = act.invobject.components.tool:GetEffectiveness(ACTIONS.DIG)
        elseif act.doer and act.doer.components.worker then
            numworks = act.doer.components.worker:GetEffectiveness(ACTIONS.DIG)
        end
        act.target.components.workable:WorkedBy(act.doer, numworks)
    end
    return true
end

ACTIONS.PICK.fn = function(act)
    if act.target.components.pickable then
        act.target.components.pickable:Pick(act.doer)
        return true
    end
end

ACTIONS.FORCEATTACK.fn = function(act)
    act.doer.components.combat:SetTarget(act.target)
    act.doer.components.combat:ForceAttack()
    return true
end

ACTIONS.ATTACK.fn = function(act)
    if act.target.components.combat then
        act.doer.components.combat:SetTarget(act.target)
        --act.doer.components.combat:TryAttack()
        return true
    end
end

ACTIONS.WHACK.fn = function(act)
    if act.target.components.combat then
        act.doer.components.combat:SetTarget(act.target)
        --act.doer.components.combat:TryAttack()
        return true
    end
end

ACTIONS.ATTACK.strfn = function(act)
    local targ = act.target or act.invobject
    
    if targ and targ:HasTag("smashable") then
        return "SMASHABLE"
    end
    
    if GetPlayer():HasTag("pyro") then
        return "PYRO"
    end
end

ACTIONS.COOK.fn = function(act)
	if act.target.components.cooker then
	    local ingredient = act.doer.components.inventory:RemoveItem(act.invobject)
	    
        if ingredient.components.health and ingredient.components.combat then
            act.doer:PushEvent("killed", {victim = ingredient})
        end
        
	    local product = act.target.components.cooker:CookItem(ingredient, act.doer)
	    if product then
	        act.doer.components.inventory:GiveItem(product,nil, Vector3(TheSim:GetScreenPos(act.target.Transform:GetWorldPosition()) ))
	        return true
	    end
    elseif act.target.components.stewer then
		act.target.components.stewer:StartCooking()
		return true
    end
end

ACTIONS.DRY.fn = function(act)
	if act.target.components.dryer then
	    local ingredient = act.doer.components.inventory:RemoveItem(act.invobject)
	    
	    if not act.target.components.dryer:StartDrying(ingredient) then
	        act.doer.components.inventory:GiveItem(product,nil, Vector3(TheSim:GetScreenPos(act.target.Transform:GetWorldPosition()) ))
	        return false
	    end
        return true
    end
end

ACTIONS.ADDFUEL.fn = function(act)
    if act.doer.components.inventory then
	    local fuel = act.doer.components.inventory:RemoveItem(act.invobject)
	    if fuel then
	        if act.target.components.fueled:TakeFuelItem(fuel) then
	            return true
	        else
                print("False")
	            act.doer.components.inventory:GiveItem(fuel)
	        end
	    end
    end
end

ACTIONS.ADDWETFUEL.fn = function(act)
    if act.doer.components.inventory then
        local fuel = act.doer.components.inventory:RemoveItem(act.invobject)
        if fuel then
            if act.target.components.fueled:TakeFuelItem(fuel) then
                return true
            else
                print("False")
                act.doer.components.inventory:GiveItem(fuel)
            end
        end
    end
end

ACTIONS.GIVE.fn = function(act)
    if act.target.components.trader then
		act.target.components.trader:AcceptGift(act.doer, act.invobject)
	    return true
    end
end

ACTIONS.GIVE.strfn = function(act)
    local targ = act.target or act.invobject
    
    if targ and targ:HasTag("altar") then
        if targ.enabled then
            return "READY"
        else
            return "NOTREADY"
        end
    end
end

ACTIONS.STORE.fn = function(act)
    if act.target.components.container and act.invobject.components.inventoryitem and act.doer.components.inventory then
        
        if not act.target.components.container:CanTakeItemInSlot(act.invobject) then
            return false, "NOTALLOWED"
        end

        local item = act.invobject.components.inventoryitem:RemoveFromOwner(act.target.components.container.acceptsstacks)
        if item then
            if not act.target.components.inventoryitem then
                act.target.components.container:Open(act.doer)
            end
            
            if not act.target.components.container:GiveItem(item,nil,nil,false) then
                if TheInput:ControllerAttached() then
                    act.doer.components.inventory:GiveItem(item)
                else
                    act.doer.components.inventory:GiveActiveItem(item)
                end
                return false
            end
            return true            
        end
    elseif act.target.components.occupiable and act.invobject and act.invobject.components.occupier and act.target.components.occupiable:CanOccupy(act.invobject) then
        local item = act.invobject.components.inventoryitem:RemoveFromOwner()
        return act.target.components.occupiable:Occupy(item)
    end
end

ACTIONS.STORE.strfn = function(act)
    if act.target and act.target.components.stewer then
        return "COOK"
    elseif act.target and act.target.components.occupiable then
        return "IMPRISON"
    end
end

ACTIONS.STORE_HALF.fn = function(act)
    if act.target.components.container and act.invobject.components.inventoryitem and act.doer.components.inventory then
        if not act.target.components.container:CanTakeItemInSlot(act.invobject) then
            return false, "NOTALLOWED"
        end

        local item = act.invobject.components.inventoryitem:RemoveFromOwner(act.target.components.container.acceptsstacks)
        -- 'half' is the part that will remain in the player's inventory, item is the part that will be stored in the new container
        local half = item.components.stackable:Get(math.ceil(act.invobject.components.stackable:StackSize() / 2))
        act.doer.components.inventory:GiveItem(half)
        if item then
            if not act.target.components.inventoryitem then
                act.target.components.container:Open(act.doer)
            end
            if not act.target.components.container:GiveItem(item,nil,nil,false) then
                if TheInput:ControllerAttached() then
                    act.doer.components.inventory:GiveItem(item)
                else
                    act.doer.components.inventory:GiveActiveItem(item)
                end
                return false
            end
            return true            
        end
    elseif act.target.components.occupiable and act.invobject and act.invobject.components.occupier and act.target.components.occupiable:CanOccupy(act.invobject) then
        local item = act.invobject.components.inventoryitem:RemoveFromOwner()
        return act.target.components.occupiable:Occupy(item)
    end
end



ACTIONS.BUILD.fn = function(act)
    if act.doer.components.builder then
	    if act.doer.components.builder:DoBuild(act.recipe, act.pos) then
	        return true
	    end
	end
end

ACTIONS.PLANT.fn = function(act)
    if act.doer.components.inventory then
	    local seed = act.doer.components.inventory:RemoveItem(act.invobject)
	    if seed then
	        if act.target.components.grower:PlantItem(seed) then
	            return true
	        else
	            act.doer.components.inventory:GiveItem(seed)
	        end
	    end
   end
end

ACTIONS.HARVEST.fn = function(act)
    if act.target.components.crop then
    	return act.target.components.crop:Harvest(act.doer)
    elseif act.target.components.harvestable then
        return act.target.components.harvestable:Harvest(act.doer)
    elseif act.target.components.stewer then
		return act.target.components.stewer:Harvest(act.doer)
    elseif act.target.components.dryer then
		return act.target.components.dryer:Harvest(act.doer)
    elseif act.target.components.occupiable and act.target.components.occupiable:IsOccupied() then
		local item =act.target.components.occupiable:Harvest(act.doer)
		if item then
			act.doer.components.inventory:GiveItem(item)
			return true
		end
    end
end

ACTIONS.HARVEST.strfn = function(act)
    if act.target and act.target.components.occupiable then
        return "FREE"
    end
    if act.target and act.target.components.crop and act.target.components.crop:IsWithered() then
        return "WITHERED"
    end
end


ACTIONS.LIGHT.fn = function(act)
    if act.invobject and act.invobject.components.lighter then
		act.invobject.components.lighter:Light(act.target)
		return true
    end
end

ACTIONS.SLEEPIN.fn = function(act)

	local bag = nil
	if act.target and act.target.components.sleepingbag then bag = act.target end
	if act.invobject and act.invobject.components.sleepingbag then bag = act.invobject end
	
	if bag and act.doer then
		bag.components.sleepingbag:DoSleep(act.doer)
		return true
	end
	
--		TheFrontEnd:Fade(true,2)
--		act.target.components.sleepingbag:DoSleep(act.doer)
--	elseif act.doer and act.invobject and act.invobject.components.sleepingbag then
--		return true
    --end
end

ACTIONS.SHAVE.testfn = function(act)
    if act.invobject and act.invobject.components.shaver then
        local shavee = act.target or act.doer
        if shavee and shavee.components.beard then
            return shavee.components.beard:ShouldTryToShave(act.doer, act.invobject)
        end
    end
end

ACTIONS.SHAVE.fn = function(act)
    
    if act.invobject and act.invobject.components.shaver then
        local shavee = act.target or act.doer
        if shavee and shavee.components.beard then
            return shavee.components.beard:Shave(act.doer, act.invobject)
        end
    end
    
end

ACTIONS.PLAY.fn = function(act)
    if act.invobject and act.invobject.components.instrument then
        return act.invobject.components.instrument:Play(act.doer)
    end
end

ACTIONS.POLLINATE.fn = function(act)
    if act.doer.components.pollinator then
		if act.target then
			return act.doer.components.pollinator:Pollinate(act.target)
		else
			return act.doer.components.pollinator:CreateFlower()
		end
    end
end

ACTIONS.TERRAFORM.fn = function(act)
	if act.invobject and act.invobject.components.terraformer then
		return act.invobject.components.terraformer:Terraform(act.pos)
	end
end

ACTIONS.EXTINGUISH.fn = function(act)
    if act.target.components.burnable
       and act.target.components.burnable:IsBurning() then
        if act.target.components.fueled and not act.target.components.fueled:IsEmpty() then
            act.target.components.fueled:ChangeSection(-1)
        else
            act.target.components.burnable:Extinguish()
        end
        return true
    end
end

ACTIONS.LAYEGG.fn = function(act)
    if act.target.components.pickable and not act.target.components.pickable.canbepicked then
		return act.target.components.pickable:Regen()
    end
end

ACTIONS.INVESTIGATE.fn = function(act)
    local investigatePos = act.doer.components.knownlocations and act.doer.components.knownlocations:GetLocation("investigate")
    if investigatePos then
        act.doer.components.knownlocations:RememberLocation("investigate", nil)
        --try to get a nearby target
        if act.doer.components.combat then
            act.doer.components.combat:TryRetarget()
        end
		return true
    end
end


ACTIONS.GOHOME.fn = function(act)
    --this is gross. make it better later.
    if act.doer.force_onwenthome_message then
        act.doer:PushEvent("onwenthome")
    end
    if act.target.components.spawner then
        return act.target.components.spawner:GoHome(act.doer)
    elseif act.target.components.childspawner then
        return act.target.components.childspawner:GoHome(act.doer)
    elseif act.pos then
        if act.target then
            act.target:PushEvent("onwenthome", {doer = act.doer})
        end
        act.doer:Remove()
        return true
    end
end

ACTIONS.JUMPIN.fn = function(act)
    if act.target.components.teleporter then
	    act.target.components.teleporter:Activate(act.doer)
	    return true
	end
end

ACTIONS.RESETMINE.fn = function(act)
    if act.target.components.mine then
	    act.target.components.mine:Reset()
	    return true
	end
end

ACTIONS.ACTIVATE.fn = function(act)
    if act.target.components.activatable then
        act.target.components.activatable:DoActivate(act.doer)
        return true
    end
end

ACTIONS.ACTIVATE.strfn = function(act)
    if act.target.components.activatable.getverb then
        return act.target.components.activatable.getverb(act.target, act.doer)
    end
end

ACTIONS.MURDER.fn = function(act)
    local murdered = act.invobject or act.target
    if murdered and murdered.components.health then
                
        murdered.components.inventoryitem:RemoveFromOwner(true)

        if murdered.components.health.murdersound then
            act.doer.SoundEmitter:PlaySound(murdered.components.health.murdersound)
        end

        local stacksize = 1
        if murdered.components.stackable then
            stacksize = murdered.components.stackable.stacksize
        end

        if murdered.components.lootdropper then
            for i = 1, stacksize do
                local loots = murdered.components.lootdropper:GenerateLoot()
                for k, v in pairs(loots) do
                    local loot = SpawnPrefab(v)
                    act.doer.components.inventory:GiveItem(loot)
                end      
            end
        end

        act.doer:PushEvent("killed", {victim = murdered})
        murdered:Remove()

        return true
    end
end

ACTIONS.HEAL.fn = function(act)
    if act.invobject and act.invobject.components.healer then
        local target = act.target or act.doer
    	return act.invobject.components.healer:Heal(target)
    end
end

ACTIONS.UNLOCK.fn = function(act)
    if act.target.components.lock then
        if act.target.components.lock:IsLocked() then
            act.target.components.lock:Unlock(act.invobject, act.doer)
        --else
            --act.target.components.lock:Lock(act.doer)
        end
        return true
    end
end

--ACTIONS.UNLOCK.strfn = function(act)
    --if act.target.components.lock and not act.target.components.lock:IsLocked() then
        --return "LOCK"
    --end
--end

ACTIONS.TEACH.fn = function(act)
    if act.invobject and act.invobject.components.teacher then
        local target = act.target or act.doer
        return act.invobject.components.teacher:Teach(target)
    end
end

ACTIONS.TURNON.fn = function(act)
    local tar = act.target or act.invobject
    if tar and tar.components.machine and not tar.components.machine:IsOn() then
        tar.components.machine:TurnOn(tar)
        return true
    end
end

ACTIONS.TURNOFF.fn = function(act)
    local tar = act.target or act.invobject
    if tar and tar.components.machine and tar.components.machine:IsOn() then
            tar.components.machine:TurnOff(tar)
        return true
    end
end

ACTIONS.USEITEM.fn = function(act)
    if act.invobject and act.invobject.components.useableitem then
        if act.invobject.components.useableitem:CanInteract() then
            act.invobject.components.useableitem:StartUsingItem()
        end
    end
end

ACTIONS.TAKEITEM.fn = function(act)
--Use this for taking a specific item as opposed to having an item be generated as it is in Pick/ Harvest
    if act.target and act.target.components.shelf and act.target.components.shelf.cantakeitem then
        act.target.components.shelf:TakeItem(act.doer)
        return true
    end
end

ACTIONS.CASTSPELL.strfn = function(act)
    local targ = act.invobject
    
    if targ and targ.components.spellcaster then
        return targ.components.spellcaster.actiontype
    end
end

ACTIONS.CASTSPELL.fn = function(act)
    --For use with magical staffs
    local staff = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

    if staff and staff.components.spellcaster and staff.components.spellcaster:CanCast(act.doer, act.target, act.pos) then
        staff.components.spellcaster:CastSpell(act.target, act.pos)
        return true
    end
end


ACTIONS.BLINK.fn = function(act)
    if act.invobject and act.invobject.components.blinkstaff then
        return act.invobject.components.blinkstaff:Blink(act.pos, act.doer)
    end
end

ACTIONS.COMBINESTACK.fn = function(act)
    local target = act.target
    local invobj = act.invobject
    if invobj and target and invobj.prefab == target.prefab and target.components.stackable and not target.components.stackable:IsFull()
    and target.components.inventoryitem and target.components.inventoryitem.canbepickedup then
        target.components.stackable:Put(invobj)
        return true
    end 
end

ACTIONS.SPLITSTACK.fn = function(act)
    local invobj = act.invobject

    local half = invobj.components.stackable:Get(
        math.ceil(act.invobject.components.stackable:StackSize() / 2))

    local container = invobj.components.inventoryitem:GetContainer()

    local slot, unused = container:GetNextEmptySlot(half)
    if slot then
        container:GiveItem(half, slot)
    else
        act.doer.components.inventory:GiveItem(half, nil, nil, nil, true)
        --act.doer.components.inventory:DropItem(half)
    end

    return true
end


ACTIONS.TRAVEL.fn = function(act)
	if act.target and act.target.travel_action_fn then
		act.target.travel_action_fn(act.doer)
		return true
	end
end

ACTIONS.SUMMONGUARDIAN.fn = function(act)
    if act.doer and act.target and act.target.components.guardian then
        act.target.components.guardian:Call()
    end
end

ACTIONS.LAVASPIT.fn = function(act)
    if act.doer and act.target and act.doer.prefab == "dragonfly" then
        local spit = SpawnPrefab("lavaspit")
        local x,y,z = act.doer.Transform:GetWorldPosition()
        local downvec = TheCamera:GetDownVec()
        local offsetangle = math.atan2(downvec.z, downvec.x) * (180/math.pi)
        if act.doer.AnimState:GetCurrentFacing() == 0 then --Facing right
            offsetangle = offsetangle + 70
        else --Facing left
            offsetangle = offsetangle - 70
        end
        while offsetangle > 180 do offsetangle = offsetangle - 360 end
        while offsetangle < -180 do offsetangle = offsetangle + 360 end
        local offsetvec = Vector3(math.cos(offsetangle*DEGREES), -.3, math.sin(offsetangle*DEGREES)) * 1.7
        spit.Transform:SetPosition(x+offsetvec.x, y+offsetvec.y, z+offsetvec.z)
        spit.Transform:SetRotation(act.doer.Transform:GetRotation())
    end
end

ACTIONS.HAIRBALL.fn = function(act)
    if act.doer and act.doer.prefab == "catcoon" then
        return true
    end
end

ACTIONS.CATPLAYGROUND.fn = function(act)
    if act.doer and act.doer.prefab == "catcoon" then
        if act.target then
            if math.random() < TUNING.CATCOON_ATTACK_CONNECT_CHANCE and act.target.components.health and act.target.components.health.maxhealth <= TUNING.PENGUIN_HEALTH and -- Only bother attacking if it's a penguin or weaker
            act.target.components.combat and act.target.components.combat:CanBeAttacked(act.doer) and
            not (act.doer.components.follower and act.target.components.follower and act.doer.components.follower.leader ~= nil and act.doer.components.follower.leader == act.target.components.follower.leader) and
            not (act.doer.components.follower and act.target.components.follower and act.doer.components.follower.leader ~= nil and act.target.components.follower.leader and act.target.components.follower.leader.components.inventoryitem and act.target.components.follower.leader.components.inventoryitem.owner and act.doer.components.follower.leader == act.target.components.follower.leader.components.inventoryitem.owner) and
            act.target ~= GetPlayer() then
                act.doer.components.combat:DoAttack(act.target, nil, nil, nil, 2) --2*25 dmg
            elseif math.random() < TUNING.CATCOON_PICKUP_ITEM_CHANCE and act.target.components.inventoryitem and act.target.components.inventoryitem.canbepickedup then
                act.target:Remove()
            end
        end
        return true
    end
end

ACTIONS.CATPLAYAIR.fn = function(act)
    if act.doer and act.doer.prefab == "catcoon" then
        if act.target and math.random() < TUNING.CATCOON_ATTACK_CONNECT_CHANCE and 
        act.target.components.health and act.target.components.health.maxhealth <= TUNING.PENGUIN_HEALTH and -- Only bother attacking if it's a penguin or weaker
        act.target.components.combat and act.target.components.combat:CanBeAttacked(act.doer) and
        not (act.doer.components.follower and act.target.components.follower and act.doer.components.follower.leader ~= nil and act.doer.components.follower.leader == act.target.components.follower.leader) and
        not (act.doer.components.follower and act.target.components.follower and act.doer.components.follower.leader ~= nil and act.target.components.follower.leader and act.target.components.follower.leader.components.inventoryitem and act.target.components.follower.leader.components.inventoryitem.owner and act.doer.components.follower.leader == act.target.components.follower.leader.components.inventoryitem.owner) then
            act.doer.components.combat:DoAttack(act.target, nil, nil, nil, 2) --2*25 dmg
        end
        act.doer.last_play_air_time = GetTime()
        return true
    end
end

ACTIONS.STEALMOLEBAIT.fn = function(act)
    if act.doer and act.target and act.doer.prefab == "mole" then
        act.target.selectedasmoletarget = false
        act.target:PushEvent("onstolen", {thief=act.doer})
        return true
    end
end

ACTIONS.MAKEMOLEHILL.fn = function(act)
    if act.doer and act.doer.prefab == "mole" then
        local molehill = SpawnPrefab("molehill")
        local pt = act.doer:GetPosition()
        molehill.Transform:SetPosition(pt.x, pt.y, pt.z)
        molehill:PushEvent("confignewhome", {mole=act.doer})
        act.doer.needs_home_time = nil
        return true
    end
end

ACTIONS.MOLEPEEK.fn = function(act)
    if act.doer and act.doer.prefab == "mole" then
        act.doer:PushEvent("peek")
        return true
    end
end

ACTIONS.BURY.fn = function(act)
    if act.doer and act.target and act.target.components.hole and act.target.components.hole.canbury then
        act.invobject.components.buryable:OnBury(act.target, act.doer)
        return true
    end
end

ACTIONS.FEED.fn = function(act)
    if act.doer and act.target and act.target.components.eater and act.target.components.eater:CanEat(act.invobject) then
        act.target.components.eater:Eat(act.invobject)
        return true
    end
end

ACTIONS.FAN.fn = function(act)
    if act.invobject and act.invobject.components.fan then
        local target = act.target or act.doer
        return act.invobject.components.fan:Fan(target)
    end
end

ACTIONS.UPGRADE.fn = function(act)
    if act.invobject and act.target then
        return act.target.components.upgradeable:Upgrade(act.invobject)
    end
end