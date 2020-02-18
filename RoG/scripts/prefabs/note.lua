local assets = 
{
	Asset("ANIM", "anim/papyrus.zip"),
}

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("papyrus")
    inst.AnimState:SetBuild("papyrus")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("note")

	inst:AddComponent("inspectable")
	inst.components.inspectable:SetDescription(TheSim:GetBirdsong())

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:ChangeImageName("papyrus")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

	return inst
end

return Prefab("common/inventory/note", fn, assets)