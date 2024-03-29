local Hunger = Class(function(self, inst)
    self.inst = inst
    self.max = 100
    self.current = self.max

    self.hungerrate = 1
    self.hurtrate = 1
    
    self.burning = true
    --100% burn rate. Currently used only by belt of hunger, will have to change unequip if use in something else
    self.burn_rate_modifiers = {}
    self.period = 1
    
    self.task = self.inst:DoPeriodicTask(self.period, function() self:DoDec(self.period) end)
	self.inst:ListenForEvent("respawn", function(inst) self:OnRespawn() end)
    self.onStarve = nil 
	
end)

function Hunger:AddBurnRateModifier(key, mod)
    self.burn_rate_modifiers[key] = mod
end

function Hunger:RemoveBurnRateModifier(key)
    self.burn_rate_modifiers[key] = nil
end

function Hunger:GetBurnRate()
    local mod = 1
    for k,v in pairs(self.burn_rate_modifiers) do
        mod = mod + v
    end
    return mod
end

function Hunger:SetOnStarve(fn)
    self.onStarve = fn
end 

function Hunger:OnRespawn()
	
end

function Hunger:OnSave()
    if self.current ~= self.max then
        return {hunger = self.current}
    end
end

function Hunger:OnLoad(data)
    if data.hunger then
        self.current = data.hunger
        self:DoDelta(0)
    end
end

function Hunger:LongUpdate(dt)
	self:DoDec(dt, true)
end

function Hunger:Pause()
    self.burning = false
end

function Hunger:Resume()
    self.burning = true
end

function Hunger:GetDebugString()
    return string.format("%2.2f / %2.2f", self.current, self.max)
end

function Hunger:SetMax(amount)
    self.max = amount
    self.current = amount
end


function Hunger:IsStarving() 
    return self.current <= 0
end

function Hunger:DoDelta(delta, overtime, ignore_invincible)
    
    if self.redirect then
        self.redirect(self.inst, delta, overtime)
        return
    end

    if not ignore_invincible and self.inst.components.health.invincible == true or self.inst.is_teleporting == true then
        return
    end

    local old = self.current
    self.current = self.current + delta

    if self.current <= 0 and old > 0 then 
        if self.onStarve then 
            self.onStarve(self.inst)
        end 
    end 

    if self.current < 0 then 
        self.current = 0
    elseif self.current > self.max then
        self.current = self.max
    end
    
    self.inst:PushEvent("hungerdelta", {oldpercent = old/self.max, newpercent = self.current/self.max, overtime = overtime})

    if old > 0 and self.current <= 0 then
        self.inst:PushEvent("startstarving")
        ProfileStatsSet("started_starving", true)
    elseif old <= 0 and self.current > 0 then
        self.inst:PushEvent("stopstarving")
        ProfileStatsSet("stopped_starving", true)
    end
    
end

function Hunger:GetPercent(p)
    return self.current / self.max
end

function Hunger:SetPercent(p)
    local old = self.current
    self.current  = p*self.max
    self.inst:PushEvent("hungerdelta", {oldpercent = old/self.max, newpercent = p})

    if old > 0 and self.current <= 0 then
        self.inst:PushEvent("startstarving")
        ProfileStatsSet("started_starving", true)
    elseif old <= 0 and self.current > 0 then
        self.inst:PushEvent("stopstarving")
        ProfileStatsSet("stopped_starving", true)
    end
end

function Hunger:DoDec(dt, ignore_damage)
	
    local old = self.current
    
    if self.burning then
        if self.current <= 0 and self.hurtrate > 0 then
			if not ignore_damage then
				self.inst.components.health:DoDelta(-self.hurtrate*dt, true, "hunger") --  ich haber hunger
			end
        else
            self:DoDelta(self:GetBurnRate()*(-self.hungerrate*dt), true)
        end
    end
    
    --self.task = self.inst:DoTaskInTime(self.period, function() self:DoDec() end)
end

function Hunger:SetKillRate(rate)
    self.hurtrate = rate
end

function Hunger:SetRate(rate)
    self.hungerrate = rate
end

function Hunger:GetCurrent()
    return self.current
end 


return Hunger
