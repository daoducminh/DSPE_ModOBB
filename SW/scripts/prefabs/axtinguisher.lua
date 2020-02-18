local assets=
{
    Asset("ANIM", "anim/pyro_axe.zip"),
    Asset("ANIM", "anim/swap_pyro_axe.zip"),
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_pyro_axe", "swap_pyro_axe")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function onattack(weapon, attacker, target)
   -- print(weapon)
    if target.components.burnable and target.components.burnable:IsBurning() then
        target.components.health:DoDelta(-TUNING.AXTINGUISHER_BONUS_DAMAGE)
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("pyro_axe")
    anim:SetBuild("pyro_axe")
    anim:PlayAnimation("anim")
    
    inst:AddTag("sharp")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.AXTINGUISHER_DAMAGE)
    inst.components.weapon:SetAttackCallback(onattack)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP)

    -------
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.AXTINGUISHER_USES)
    inst.components.finiteuses:SetUses(TUNING.AXTINGUISHER_USES)
    inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)    
    inst.components.finiteuses:SetOnFinished( onfinished )

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    

    return inst
end

return Prefab( "pyro/inventory/pyro_axe", fn, assets) 
