local Workable = Class(function(self, inst)
    self.inst = inst
    self.onwork = nil
    self.onfinish = nil
    self.action = ACTIONS.CHOP
    self.workleft = 10
    self.maxwork = -1
    self.savestate = false
    self.destroyed = false
    self.workable = true
end)

function Workable:GetDebugString()
    return "workleft: "..self.workleft .. " maxwork:" .. self.maxwork
end


function Workable:AddStage(amount)
    table.insert(self.stages, amount)
end

function Workable:SetWorkAction(act)
    self.action = act
end

function Workable:GetWorkAction()
    return self.action
end

function Workable:Destroy(destroyer)
    if not self.destroyed then
        self:WorkedBy(destroyer, self.workleft)
        self.destroyed = true
    end
end

function Workable:SetWorkable(b)
    self.workable = b
end

function Workable:SetWorkLeft(work)
    if not self.workable then self.workable = true end
    work = work or 10
    work = (work <= 0 and 1) or work
    if self.maxwork > 0 then
        work = (work > self.maxwork and self.maxwork) or work
    end
    self.workleft = work
end

function Workable:SetOnLoadFn(fn)
    if type(fn) == "function" then
        self.onloadfn = fn
    end
end

function Workable:SetMaxWork(work)
    work = work or 10
    work = (work <= 0 and 1) or work
    self.maxwork = work
end

function Workable:OnSave()    
    if self.savestate then
        return 
            {
                maxwork = self.maxwork,
                workleft = self.workleft,
                workable = self.workable,
            }
   else
        return {}
   end
end

function Workable:OnLoad(data)
    self.workleft = data.workleft or self.workleft
    self.maxwork = data.maxwork or self.maxwork
    if data.workable ~= nil then
        self.workable = data.workable
    end
    if self.onloadfn then
        self.onloadfn(self.inst,data)
    end
end

function Workable:WorkedBy(worker, numworks)
    numworks = numworks or 1
    self.workleft = self.workleft - numworks
    self.lastworktime = GetTime()

    worker:PushEvent("working", {target = self.inst})
    self.inst:PushEvent("worked", {worker = worker, workleft = self.workleft})
    
    if self.onwork then
        self.onwork(self.inst, worker, self.workleft)
    end

    if self.workleft <= 0 then        
        if self.onfinish then self.onfinish(self.inst, worker) end        
        self.inst:PushEvent("workfinished")

        worker:PushEvent("finishedwork", {target = self.inst, action = self.action})
    end
end

function Workable:IsActionValid(action, right)
    if not self.workable then return false end

    if action == ACTIONS.HAMMER and not right then
		return false
    end
    
    return self.workleft > 0 and action == self.action
    
end

function Workable:SetOnWorkCallback(fn)
    self.onwork = fn
end

function Workable:SetOnFinishCallback(fn)
    self.onfinish = fn
end

return Workable
