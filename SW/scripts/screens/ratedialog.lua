local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"


local RateDialog = Class(Screen, function(self, buttons, timeout)
	Screen._ctor(self, "RateDialogDialogScreen")

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
    self.bg = self.proot:AddChild(Image("images/ios_rateus.xml", "panel_upsell_small_blk.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetScale(1.6)
	
	--if #buttons >2 then
	--	self.bg:SetScale(2,1.2,1.2)
	--end
	


    self.image = self.proot:AddChild(Image("images/ios_rateus.xml", "dsios_rateus_image.tex"))
    self.image:SetVRegPoint(ANCHOR_MIDDLE)
    self.image:SetHRegPoint(ANCHOR_MIDDLE)
    self.image:SetScale(0.7)

        --title 
    self.title = self.proot:AddChild(Text(TITLEFONT, 65))
    self.title:SetPosition(0, 210, 0)
    self.title:SetString(STRINGS.UI.FEEDBACK.TITLE)

	--create the menu itself
	local button_w = 200
	local space_between = 20
	local spacing = button_w + space_between
	
	
    local spacing = 200

	self.menu = self.proot:AddChild(Menu(buttons, spacing, true))
	self.menu:SetPosition(-(spacing*(#buttons-1))/2, -230, 0) 
    self.menu:SetScale(1.2)
	self.buttons = buttons
	self.default_focus = self.menu
end)



function RateDialog:OnUpdate( dt )
	if self.timeout then
		self.timeout.timeout = self.timeout.timeout - dt
		if self.timeout.timeout <= 0 then
			self.timeout.cb()
		end
	end
	return true
end

function RateDialog:OnControl(control, down)
    if RateDialog._base.OnControl(self,control, down) then
        return true 
    else
        -- CONTROL_ACCEPT is the input when touchDown...
        if not down and (control == CONTROL_CANCEL or control == CONTROL_ACCEPT) then
            TheFrontEnd:PopScreen() return true
        end
    end
end

function RateDialog:GetHelpText()
    local t = {}
    local controller_id = TheInput:GetControllerID()

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    return table.concat(t, "  ")
end

return RateDialog
