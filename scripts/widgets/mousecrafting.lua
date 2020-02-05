require "class"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local CraftSlot = require "widgets/craftslot"
local Crafting = require "widgets/crafting"

require "widgets/widgetutil"

local numSlots = 9
local scale = 0.72

if IPHONE_VERSION and TheInput:IsZoomHudEnabled() then
    numSlots = 7
    scale = 0.90
end

local MouseCrafting = Class(Crafting, function(self)
    Crafting._ctor(self, numSlots)
    if IPHONE_VERSION and TheInput:IsZoomHudEnabled() then
        self:SetOrientation(true)
        self:SetScale(scale)
        self.in_pos = Vector3(480,200,0)
        self.out_pos = Vector3(-2000,200,0)
    else
        self:SetOrientation(false)
        self.in_pos = Vector3(145,0,0)
        self.out_pos = Vector3(0,0,0)
    end
    self.craftslots:EnablePopups()
end)


return MouseCrafting