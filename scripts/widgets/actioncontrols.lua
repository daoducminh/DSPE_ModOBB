local Text = require "widgets/text"
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Button = require "widgets/button"
local ImageButton = require "widgets/imagebutton"

require("constants")

local X = 10
local Y = 0
--local X = 680
--local Y = 650
local ActionControls = Class(Widget, function(self, owner)
    Widget._ctor(self, "ActionControls")
    self.owner = owner
    self.isFE = true
    self:SetClickable(false)
    --self:MakeNonClickable()
    self.bg = self:AddChild(Image("images/hud.xml", "pick.tex"))
    self.bg:SetPosition(X, Y, 0)
    self.bg:SetScale(0.95)
    self.bg:SetTint(1, 1, 1, 1)

    self.bg2 = self:AddChild(Image("images/hud.xml", "punch.tex"))
    self.bg2:SetPosition(X-120, Y, 0)
    self.bg2:SetScale(0.95)
    self.bg2:SetTint(1, 1, 1, 1)

    if IPHONE_VERSION then
        self.bg:SetPosition(X, Y-60, 0)
        self.bg:SetScale(0.80)
        self.bg2:SetPosition(X, Y+20, 0)
        self.bg2:SetScale(0.80)
    end

    self.wasInPlantMode = false
    self.pressedCancelButton = false

    self.x = 0
    self.y = 0

    self.currentAction = 0

    self:StartUpdating()
end)

function ActionControls:OnUpdate()
    local hover = self.owner.components.playercontroller.inst.HUD.controls.hover
    local usingVirtualStick = self.owner.components.playercontroller.directwalking
    if hover.inMenu then
        self.bg:SetTint(0.25, 0.25, 0.25, 0.75)
        self.bg2:SetTint(0.25, 0.25, 0.25, 0.75)
        self.currentAction = 0
        return
    end

    local controller = self.owner.components.playercontroller
    local cancelPlantModeAction = BufferedAction(GetPlayer(), nil, ACTIONS.CANCEL_PLANT_MODE)
    local action = controller.plant_mode and cancelPlantModeAction or controller:GetActionButtonAction()

    local attackTarget = controller:GetAttackTarget(true)

    if controller.plant_mode then
        self.bg:SetTexture("images/hud.xml", "cancel.tex")
    else
        self.bg:SetTexture("images/hud.xml", "pick.tex")
    end

    --if attackTarget then 
        self.bg2:SetTint(1, 1, 1, 1) 
    --else self.bg2:SetTint(0.25, 0.25, 0.25, 0.75) end
    if action then self.bg:SetTint(1, 1, 1, 1) else self.bg:SetTint(0.25, 0.25, 0.25, 0.75) end

    if not TheInput:IsTouchDown() then
        self.pressedCancelButton = false
    end

    if TheInput:IsTouchDown()  then -- and not self.pressedCancelButton
        local pos = TheInput:GetScreenPosition()
        local index = self:GetActionIndex(pos.x, pos.y)

        if self.currentAction == 0 and index == 0 and (not Profile:GetVirtualStickEnabled()) then
            self.lock = true
        end

        local vstick = controller.inst.HUD.controls.virtualstick
        --if not self.lock then
            if index == 1 then
                if not vstick.dragging then
                    if action then
                        if controller.plant_mode then
                            controller:DoAction(cancelPlantModeAction)
                            self.pressedCancelButton = true
                        else
                            controller:DoActionButton()
                        end

                        self.currentAction = 1
                        self.bg:SetTint(0.75, 0.75, 0.75, 1)
                        --controller.inst.HUD.controls.virtualstick:ResetStick()
                    else
                        self.bg:SetTint(0.15, 0.15, 0.15, 0.75)
                    end
                end
            elseif index == 2 then
                if not vstick.dragging then
                    if attackTarget and controller.inst.components.combat.target ~= attackTarget then
                        local action = BufferedAction(controller.inst, attackTarget, ACTIONS.ATTACK)
                        controller.inst.components.locomotor:PushAction(action, true)
                        --self.currentAction = 2
                        self.bg2:SetTint(0.75, 0.75, 0.75, 1)
                        --controller.inst.HUD.controls.virtualstick:ResetStick()
                    --elseif attackTarget then
                        --local action = BufferedAction(controller.inst, attackTarget, ACTIONS.ATTACK)
                        --controller.inst.components.locomotor:PushAction(action, true)
                        --self.currentAction = 2
                        --self.bg2:SetTint(0.75, 0.75, 0.75, 1)
                        --controller.inst.HUD.controls.virtualstick:ResetStick()
                    elseif not attackTarget and not controller.inst.components.combat.target then
                        local action = BufferedAction(controller.inst, nil, ACTIONS.FORCEATTACK)
                        controller.inst.components.locomotor:PushAction(action, true)
                        --self.currentAction = 2
                        self.bg2:SetTint(0.75, 0.75, 0.75, 1)
                    else
                        self.bg2:SetTint(0.75, 0.75, 0.75, 1)
                    end
                else
                    if attackTarget and controller.inst.components.combat.target ~= attackTarget then
                        local action = BufferedAction(controller.inst, attackTarget, ACTIONS.FORCEATTACK)
                        controller.inst.components.locomotor:PushAction(action, true)
                        --self.currentAction = 2
                        self.bg2:SetTint(0.75, 0.75, 0.75, 1)
                    elseif not attackTarget and not controller.inst.components.combat.target then
                        local action = BufferedAction(controller.inst, nil, ACTIONS.FORCEATTACK)
                        controller.inst.components.locomotor:PushAction(action, true)
                        self.bg2:SetTint(0.75, 0.75, 0.75, 1)
                    else
                        self.bg2:SetTint(0.75, 0.75, 0.75, 1)
                    end
                end
            end
        --end
    else
        self.currentAction = 0
        self.lock = false
    end
end

function ActionControls:GetActionIndex(x, y)
    
    if self.currentAction == 1 then
        return 1
    end

    if self.currentAction == 2 then
        return 2
    end

    local w0, h0 = self.bg:GetSize()
    w0 = w0*self.bg:GetScale().x
    h0 = h0*self.bg:GetScale().y
    w0 = w0*1.1
    h0 = h0*1.1
    local pos0 = self.bg:GetWorldPosition()

    local minx0, maxx0 = (pos0.x - w0/2), (pos0.x + w0/2)
    local miny0, maxy0 = (pos0.y - h0/2), (pos0.y + h0/2)
    if not (x < minx0 or x > maxx0 or y < miny0 or y > maxy0) then
        return 1
    end

    w0, h0 = self.bg2:GetSize()
    w0 = w0*self.bg2:GetScale().x
    h0 = h0*self.bg2:GetScale().y
    w0 = w0*1.1
    h0 = h0*1.1
    local pos0 = self.bg2:GetWorldPosition()

    local minx0, maxx0 = (pos0.x - w0/2), (pos0.x + w0/2)
    local miny0, maxy0 = (pos0.y - h0/2), (pos0.y + h0/2)
    if not (x < minx0 or x > maxx0 or y < miny0 or y > maxy0) then
        return 2
    end

    return 0
end

return ActionControls