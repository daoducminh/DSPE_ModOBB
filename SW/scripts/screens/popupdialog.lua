local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"

local PopupDialogScreen = Class(Screen, function(self, title, text, buttons, maxTitleWidth)
    self.maxTitleWidth = maxTitleWidth or 0
	Screen._ctor(self, "PopupDialogScreen")

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

    local factor = 1
    if IPHONE_VERSION then
        factor = 1.5
    end

	--throw up the background
    self.bg = self.proot:AddChild(Image("images/globalpanels.xml", "small_dialog.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetScale(1.2*factor,1.2*factor,1.2*factor)
	
	if #buttons >2 then
		self.bg:SetScale(2*factor,1.2*factor,1.2*factor)
	end
	
	--title	
    self.title = self.proot:AddChild(Text(TITLEFONT, 50*factor))
    self.title:SetPosition(0, 70*factor, 0)
    self.title:SetString(title)
    if self.maxTitleWidth > 0 then
        self.title:AdjustToWidth(self.maxTitleWidth)
    end

	--text
    self.text = self.proot:AddChild(Text(BODYTEXTFONT, 30*factor))

    self.text:SetPosition(0, 5*factor, 0)
    self.text:SetString(text)
    self.text:EnableWordWrap(true)
    self.text:SetRegionSize(500*factor, 80*factor)
  
    local spacing = 200

	self.menu = self.proot:AddChild(Menu(buttons, spacing, true))
	self.menu:SetPosition(-(spacing*(#buttons-1))/2*factor, -70*factor, 0)
    self.menu:SetScale(factor)
	self.buttons = buttons
	self.default_focus = self.menu
end)

function PopupDialogScreen:SetTitleTextSize(size)
	self.title:SetSize(size)
end

function PopupDialogScreen:SetButtonTextSize(size)
	self.menu:SetTextSize(size)
end

function PopupDialogScreen:OnControl(control, down)
    if PopupDialogScreen._base.OnControl(self,control, down) then return true end
    
    if control == CONTROL_CANCEL and not down then    
        if #self.buttons > 1 and self.buttons[#self.buttons] then
            self.buttons[#self.buttons].cb()
            return true
        end
    end
end


function PopupDialogScreen:Close()
	TheFrontEnd:PopScreen(self)
end

function PopupDialogScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
	if #self.buttons > 1 and self.buttons[#self.buttons] then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)	
    end
	return table.concat(t, "  ")
end

return PopupDialogScreen