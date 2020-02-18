local Text = require "widgets/text"
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Button = require "widgets/button"
local ImageButton = require "widgets/imagebutton"

require("constants")

local X = 0
local Y = 0
local RADIUS = 200
--local X = 680
--local Y = 650
local VirtualStick = Class(Widget, function(self, owner)
    Widget._ctor(self, "VirtualStick")
    self.owner = owner
    self.isFE = true
    self:SetClickable(false)
    --self:MakeNonClickable()
    self.bg = self:AddChild(Image("images/hud.xml", "stick_background.tex"))
    self.bg:SetPosition(X, Y, 0)
    self.bg:SetScale(0.4)
    self.bg:SetTint(1, 1, 1, 1)

    self.stick = self:AddChild(Image("images/hud.xml", "stick.tex"))
    self.stick:SetPosition(X, Y, 0)
    self.stick:SetScale(0.25)
    self.stick:SetTint(1, 1, 1, 1)
    self.oPos = nil
    self:StartUpdating()
    self.dirX = 0
    self.dirY = 0
    self.dragging = false
    self.touchStartedOutside = false
end)

function VirtualStick:OnUpdate()
    local controller = self.owner.components.playercontroller

    if (not Profile:GetVirtualStickEnabled()) or (not controller.inst.HUD.controls.isShowingVS) then
        self.dirX = 0
        self.dirY = 0
        return
    end
 
    local pos = TheInput:GetScreenPositionMove()
    self.oPos = self.bg:GetWorldPosition()

    pos.x = (pos.x - self.oPos.x)
    pos.y = (pos.y - self.oPos.y)

    local length = pos:Length()
    pos:Normalize()
    local normPos = pos
    
    local touchOutside = false

    if length > RADIUS then
        length = RADIUS
        touchOutside = true
    end

    pos = pos * length * 0.5

    if TheInput:IsTouchDownZero() then
        if (self.dragging or not touchOutside) and not self.touchStartedOutside then
            self.stick:SetPosition(X + pos.x, Y + pos.y)
            self.dirX = normPos.x
            self.dirY = normPos.y
            self.dragging = true
        end
        if not self.dragging and touchOutside then
            self.touchStartedOutside = true
        end
    else
        self.stick:SetPosition(X, Y, 0)
        self.dirX = 0
        self.dirY = 0
        self.dragging = false
        self.touchStartedOutside = false
    end
end

function VirtualStick:ResetStick()
    self.touchStartedOutside = true
    self.dirX = 0
    self.dirY = 0
    self.stick:SetPosition(X, Y, 0)
end


return VirtualStick 
