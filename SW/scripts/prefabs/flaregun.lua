local assets=
{
	Asset("ANIM", "anim/swap_pyro_flare_gun.zip"),
    Asset("ANIM", "anim/pyro_flare_gun.zip"),
}

local function onfinished(inst)
    inst:Remove()
end

local function onattack(inst, attacker, target)

    if target.components.burnable and not target.components.burnable:IsBurning() then
        if target.components.freezable and target.components.freezable:IsFrozen() then           
            target.components.freezable:Unfreeze()            
        else            
            target.components.burnable:Ignite(true)
        end   
    end

    if target.components.freezable then
        target.components.freezable:AddColdness(-1)
        if target.components.freezable:IsFrozen() then
            target.components.freezable:Unfreeze()            
        end
    end

    if target.components.sleeper and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end

    if target.components.combat then
        target.components.combat:SuggestTarget(attacker)
        if target.sg and target.sg.sg.states.hit then
            target.sg:GoToState("hit")
        end
    end

    if attacker and attacker.components.sanity then
        attacker.components.sanity:DoDelta(-TUNING.SANITY_SUPERTINY)
    end

    attacker.SoundEmitter:PlaySound("dontstarve/wilson/fireball_explo")
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_pyro_flare_gun", "swap_pyro_flare_gun")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("pyro_flare_gun")
    anim:SetBuild("pyro_flare_gun")
    anim:PlayAnimation("anim")

    inst:AddTag("gun")
    inst:AddTag("rangedlighter")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)
    inst.components.weapon:SetOnAttack(onattack)
    inst.components.weapon:SetProjectile("fire_projectile")
    
    -------
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.FLAREGUN_USES)
    inst.components.finiteuses:SetUses(TUNING.FLAREGUN_USES)    
    inst.components.finiteuses:SetOnFinished( onfinished )

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
        
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )    

    return inst
end

return Prefab( "pyro/inventory/pyro_flare_gun", fn, assets) 
