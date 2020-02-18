local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
--local TEMPLATES = require "widgets/templates"

local WaitingPopup = Class(Screen, function(self, message)
	Screen._ctor(self, "WaitingPopup")

	self.message = message

	--darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)	
    
	self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

	--throw up the background
--	self.bg = self.proot:AddChild(TEMPLATES.CurlyWindow(30, 100, .7, .7, 47, -28))
--    self.bg.fill = self.proot:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tiny.tex"))
--	self.bg.fill:SetScale(.54, .45)
--	self.bg.fill:SetPosition(6, 8)
	self.bg = self.proot:AddChild(Image("images/globalpanels.xml", "small_dialog.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetScale(1.2,1.2,1.2)
		
	--title	
	local title = ""
    self.title = self.proot:AddChild(Text(TITLEFONT, 50))
    self.title:SetPosition(0, 70, 0)
    self.title:SetString(title)

	--text
    self.text = self.proot:AddChild(Text(BUTTONFONT, 55))
    local text = self.message
    self.text:SetPosition(0, 5, 0)
    self.text:SetSize(35)
    self.text:SetString(text)
    -- self.text:SetRegionSize(140, 100)
	self.text:SetHAlign(ANCHOR_LEFT)
--	self.text:SetColour(0,0,0,1)
  

	self.time = 0
	self.progress = 0
end)

function WaitingPopup:OnUpdate( dt )
	self.time = self.time + dt
	if self.time > 0.3 then
	    self.progress = self.progress + 1
	    if self.progress > 3 then
	        self.progress = 1
	    end
	    
	    local text = self.message
	    for k = 1, self.progress, 1 do
	        text = text .. "."
	    end
        self.text:SetString(text)
	    self.time = 0
	end
end

function WaitingPopup:OnControl(control, down)
    if WaitingPopup._base.OnControl(self,control, down) then 
        return true 
    end
 
end

return WaitingPopup