local Inspectable = Class(function(self, inst)
    self.inst = inst
    self.description = nil
end)


--can be a string, a table of strings, or a function
function Inspectable:SetDescription(desc)
    self.description = desc
end

function Inspectable:RecordViews(state)
    self.recordview = state or true
end

function Inspectable:CollectSceneActions(doer, actions)
    if not self.onlyforcedinspect and GetPlayer():CanExamine() then
        if not (doer.sg and doer.sg:HasStateTag("moving")) then
            table.insert(actions, ACTIONS.LOOKAT)
        end
    end
end

function Inspectable:CollectInventoryActions(doer, actions)
    if not self.onlyforcedinspect and GetPlayer():CanExamine() then
        table.insert(actions, ACTIONS.LOOKAT)
    end
end

function Inspectable:GetStatus(viewer)
    local status = self.getstatus and self.getstatus(self.inst, viewer)
    if not status then
        if self.inst.components.health and self.inst.components.health:IsDead() then
            status = "DEAD"
        elseif self.inst.components.sleeper and self.inst.components.sleeper:IsAsleep() then
            status = "SLEEPING"
        elseif self.inst.components.burnable and self.inst.components.burnable:IsBurning() then
            status = "BURNING"
		elseif (self.inst.components.pickable and self.inst.components.pickable:IsWithered()) or
               (self.inst.components.crop and self.inst.components.crop:IsWithered()) then
            status = "WITHERED"
        elseif self.inst.components.pickable and self.inst.components.pickable:IsBarren() then
            status = "BARREN"
        elseif self.inst.components.pickable and not self.inst.components.pickable:CanBePicked() then
            status = "PICKED"
        elseif self.inst.components.inventoryitem and self.inst.components.inventoryitem:IsHeld() then
            status = "HELD"
        elseif self.inst.components.occupiable and self.inst.components.occupiable:IsOccupied() then
            status = "OCCUPIED"
        elseif self.inst.components.floodable and self.inst.components.floodable.flooded then
            status = "FLOODED"
        elseif self.inst:HasTag("burnt") then
            status = "BURNT"
        end
    end
    if self.recordview then
        dprint("++++++++++++++++++STATUSVIEW")
        ProfileStatsSet(self.inst.prefab .. "_examined", true)
    end
    return status
end

function Inspectable:GetDescription(viewer)
    local desc = nil
    if type(self.description) == "function" then
        desc = self.description(self.inst, viewer)
    else
        desc = self.description
    end

    if desc == nil then
        desc = GetDescription(string.upper(viewer.prefab), self.inst, self:GetStatus(viewer))
    end

    if TheSim:GetLightAtPoint(self.inst.Transform:GetWorldPosition()) < TUNING.DARK_CUTOFF then
        desc = GetString(viewer.prefab, "DESCRIBE_TOODARK")
    end

    if self.inst.components.burnable and self.inst.components.burnable:IsSmoldering() then
        desc = GetString(viewer.prefab, "DESCRIBE_SMOLDERING")
    end
        
    return desc
end


function Inspectable:GetDebugString()
    return self.description or "Blank"
end



return Inspectable
