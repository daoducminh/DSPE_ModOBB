require("constants")
local Screen = require "widgets/screen"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"

local LEFT_SIDE = -440
local RIGHT_SIDE = 440

local LABEL_WIDTH = 500
local LABEL_HEIGHT = 50

local LABELS = {
        { x = -340,        y = 345,  anchor = ANCHOR_MIDDLE, text = STRINGS.UI.CONTROLSSCREEN.PS4.TOUCHPAD },
        { x = -160,        y = 345,  anchor = ANCHOR_MIDDLE,  text = STRINGS.UI.CONTROLSSCREEN.PS4.OPTIONS },

        { x = LEFT_SIDE, y = 280,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L2 },
        { x = LEFT_SIDE, y = 145,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L1 },

        { x = LEFT_SIDE, y = -115,   anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_UP },
        { x = LEFT_SIDE, y = -170,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_LEFT },
        { x = LEFT_SIDE, y = -225,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_BOTTOM },
        { x = LEFT_SIDE, y = -278, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_RIGHT },

        { x = LEFT_SIDE, y = 20, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L3 },

        { x = RIGHT_SIDE, y = 280,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R2 },
        { x = RIGHT_SIDE, y = 145,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R1 },

        { x = RIGHT_SIDE, y = 10,   anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.TRIANGLE },
        { x = RIGHT_SIDE, y = -50,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.CIRCLE },
        { x = RIGHT_SIDE, y = -110,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.CROSS },
        { x = RIGHT_SIDE, y = -175, anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.SQUARE },

        { x = RIGHT_SIDE, y = -295, anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R3 },
}



local ControlsScreen = Class(Screen, function(self, in_game)
    Widget._ctor(self, "ControlsScreen")

    local resizeTexts = TheSim:GetUsedLanguage() == "russian" -- and IPHONE_VERSION


    if not TheInput:IsZoomHudEnabled() then
      self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
      self.bg:AddChild(Image("images/chromebook_controls.xml", "background.tex"))
    else
      self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
    end

    if IsDLCEnabled(REIGN_OF_GIANTS) then
    	self.bg:SetTint(BGCOLOURS.PURPLE[1],BGCOLOURS.PURPLE[2],BGCOLOURS.PURPLE[3], 1)
    else
        self.bg:SetTint(BGCOLOURS.RED[1],BGCOLOURS.RED[2],BGCOLOURS.RED[3], 1)
    end

    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    
	self.scaleroot = self:AddChild(Widget("scaleroot"))
    self.scaleroot:SetVAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetHAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetPosition(0,0,0)
    self.scaleroot:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root = self.scaleroot:AddChild(Widget("root"))
    self.root:SetScale(.9)


    local left_col = -RESOLUTION_X*.5
    
    if not TheInput:IsZoomHudEnabled() then
      -- CONTENT
    
        self.layoutTouch = self.root:AddChild(Widget("layout"))
        self.layoutTouch.closeButton = self.layoutTouch:AddChild(ImageButton())
        self.layoutTouch.closeButton:SetPosition(551.6, -400.4)
        self.layoutTouch.closeButton:SetText(STRINGS.UI.CONTROLSSCREEN.CLOSE)
        self.layoutTouch.closeButton.text:SetColour(0,0,0,1)
        self.layoutTouch.closeButton:SetOnClick( function() self:Close() end )
        self.layoutTouch.closeButton:SetFont(BUTTONFONT)
        self.layoutTouch.closeButton:SetTextSize(40)
    
        self.layoutTouch.title = self.layoutTouch:AddChild(Text(TITLEFONT, 100))
        self.layoutTouch.title:SetString("Tactil")
        self.layoutTouch.title:SetPosition(0, 360)
        
        self.layoutTouch.title = self.layoutTouch:AddChild(Text(TITLEFONT, 100))
        self.layoutTouch.title:SetString("Keyboard")
        self.layoutTouch.title:SetPosition(-300, 0)
        
        self.layoutTouch.title = self.layoutTouch:AddChild(Text(TITLEFONT, 100))
        self.layoutTouch.title:SetString("Mouse")
        self.layoutTouch.title:SetPosition(425, 0)
      
        -- TOUCH LAYOUT
      
        self.layoutTouch.title = self.layoutTouch:AddChild(Text(TITLEFONT, 50))
        self.layoutTouch.title:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.TAP_TITLE)
        self.layoutTouch.title:SetPosition(-540, 235)
        self.layoutTouch.title:AdjustToWidth(150)
        local text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 32))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.TAP_BODY)
        text:SetPosition(-518, 176)
        text:AdjustToWidth(140)

        self.layoutTouch.title = self.layoutTouch:AddChild(Text(TITLEFONT, 50))
        self.layoutTouch.title:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.ROT_TITLE)
        self.layoutTouch.title:SetPosition(-275, 235)
        self.layoutTouch.title:AdjustToWidth(175)
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 32))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.ROT_BODY)
        text:SetPosition(-270, 165)
        text:AdjustToWidth(200)
        
        self.layoutTouch.title = self.layoutTouch:AddChild(Text(TITLEFONT, 50))
        self.layoutTouch.title:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.HOLD_TITLE)
        self.layoutTouch.title:SetPosition(0, 235)
        self.layoutTouch.title:AdjustToWidth(150)
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 32))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.HOLD_BODY)
        text:SetPosition(20, 175)
        text:AdjustToWidth(125)

        self.layoutTouch.title = self.layoutTouch:AddChild(Text(TITLEFONT, 50))
        self.layoutTouch.title:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.DRAG_TITLE)
        self.layoutTouch.title:SetPosition(285, 235)
        self.layoutTouch.title:AdjustToWidth(175)
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 32))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.DRAG_BODY)
        text:SetPosition(295, 175)
        text:AdjustToWidth(150)
        
        self.layoutTouch.title = self.layoutTouch:AddChild(Text(TITLEFONT, 50))
        self.layoutTouch.title:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.PINCH_TITLE)
        self.layoutTouch.title:SetPosition(545, 235)
        self.layoutTouch.title:AdjustToWidth(150)
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 32))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.PINCH_BODY)
        text:SetPosition(560, 165)
        text:AdjustToWidth(125)

        -- First colum
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 48))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.OPTIONS.ACCEPT)
        text:SetPosition(-560, -117)
        text:AdjustToWidth(200)
        
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 48))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.CONTROLS[14])
        text:SetPosition(-560, -205)
        text:AdjustToWidth(200)
        
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 48))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.CONTROLS[15])
        text:SetPosition(-560, -289)
        text:AdjustToWidth(200)
        
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 48))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.CONTROLS[58])
        text:SetPosition(-560, -384)
        text:AdjustToWidth(200)
        
        -- Second colum
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 48))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.CONTROLS[57])
        text:SetPosition(-280, -140)
        text:AdjustToWidth(200)
        
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 48))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.CONTROLS[12])
        text:SetPosition(-280, -235)
        text:AdjustToWidth(200)
        
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 48))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.CONTROLS[13])
        text:SetPosition(-280, -330)
        text:AdjustToWidth(200)
        
        -- Third colum
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 48))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.INPUTS[1][273])
        text:SetPosition(40, -108)
        text:AdjustToWidth(200)
        
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 48))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.INPUTS[1][274])
        text:SetPosition(40, -205)
        text:AdjustToWidth(200)
        
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 48))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.INPUTS[1][275])
        text:SetPosition(40, -292)
        text:AdjustToWidth(200)
        
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 48))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.INPUTS[1][276])
        text:SetPosition(40, -386)
        text:AdjustToWidth(200)
        
        -- Fourth colum
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 64))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.CONTROLS[10])
        text:SetPosition(365, -135)
        text:AdjustToWidth(200)
        
        text = self.layoutTouch:AddChild(Text(BODYTEXTFONT, 64))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.CONTROLS[10])
        text:SetPosition(365, -305)
        text:AdjustToWidth(200)
    else
      -- CONTENT

      -- TOUCH LAYOUT

        self.layoutTouch = self.root:AddChild(Widget("layout"))
        self.layoutTouch.tapPanel = self.layoutTouch:AddChild(Image("images/fepanels.xml", "panel_controls.tex"))
        self.layoutTouch.tapPanel:SetPosition(-422.8, 117.6)
        self.layoutTouch.tapPanel:SetScale(0.7)
        self.layoutTouch.title = self.layoutTouch.tapPanel:AddChild(Text(TITLEFONT, 100))
        self.layoutTouch.title:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.TAP_TITLE)
        self.layoutTouch.title:SetPosition(0, 150)
        self.layoutTouch.title:AdjustToWidth(550)

        self.layoutTouch.closeButton = self.layoutTouch:AddChild(ImageButton())
        self.layoutTouch.closeButton:SetPosition(551.6, -428.4)
        self.layoutTouch.closeButton:SetText(STRINGS.UI.CONTROLSSCREEN.CLOSE)
        self.layoutTouch.closeButton.text:SetColour(0,0,0,1)
        self.layoutTouch.closeButton:SetOnClick( function() self:Close() end )
        self.layoutTouch.closeButton:SetFont(BUTTONFONT)
        self.layoutTouch.closeButton:SetTextSize(40)

        local gesture = self.layoutTouch.tapPanel:AddChild(Image("images/ios_gestures.xml", "tap.tex"))
        gesture:SetPosition(-160,-50)
        local text = self.layoutTouch.tapPanel:AddChild(Text(BODYTEXTFONT, 65))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.TAP_BODY)
        text:SetPosition(85, -60)
        text:AdjustToWidth(400)

        self.layoutTouch.rotatePanel = self.layoutTouch:AddChild(Image("images/fepanels.xml", "panel_mod2.tex"))
        self.layoutTouch.rotatePanel:SetPosition(5.6, 134.4)
        self.layoutTouch.rotatePanel:SetScale(0.7)
        self.layoutTouch.title = self.layoutTouch.rotatePanel:AddChild(Text(TITLEFONT, 100))
        self.layoutTouch.title:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.ROT_TITLE)
        self.layoutTouch.title:SetPosition(0, 80)
        self.layoutTouch.title:AdjustToWidth(350)
        gesture = self.layoutTouch.rotatePanel:AddChild(Image("images/ios_gestures.xml", "rotate.tex"))
        gesture:SetPosition(-110,-105)
        text = self.layoutTouch.rotatePanel:AddChild(Text(BODYTEXTFONT, 65))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.ROT_BODY)

        if resizeTexts then
            text:SetPosition(100, -75)
            text:AdjustToWidth(255)
        else
            text:SetPosition(80, -75)
            text:AdjustToWidth(280)
        end

        self.layoutTouch.holdPanel = self.layoutTouch:AddChild(Image("images/fepanels.xml", "panel_controls.tex"))
        self.layoutTouch.holdPanel:SetPosition(425.6, 174.3)
        self.layoutTouch.holdPanel:SetScale(0.7)
        self.layoutTouch.title = self.layoutTouch.holdPanel:AddChild(Text(TITLEFONT, 100))
        self.layoutTouch.title:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.HOLD_TITLE)
        self.layoutTouch.title:SetPosition(0, 150)
        self.layoutTouch.title:AdjustToWidth(550)
        gesture = self.layoutTouch.holdPanel:AddChild(Image("images/ios_gestures.xml", "hold.tex"))
        gesture:SetPosition(-160,-50)
        text = self.layoutTouch.holdPanel:AddChild(Text(BODYTEXTFONT, 65))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.HOLD_BODY)
        text:SetPosition(50, -55)
        text:AdjustToWidth(400)

        self.layoutTouch.dragPanel = self.layoutTouch:AddChild(Image("images/fepanels.xml", "biobox.tex"))
        self.layoutTouch.dragPanel:SetPosition(-236.6, -263.9)
        self.layoutTouch.dragPanel:SetScale(0.7)
        self.layoutTouch.title = self.layoutTouch.dragPanel:AddChild(Text(TITLEFONT, 100))
        self.layoutTouch.title:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.DRAG_TITLE)
        self.layoutTouch.title:SetPosition(0, 60)
        self.layoutTouch.title:AdjustToWidth(450)
        gesture = self.layoutTouch.dragPanel:AddChild(Image("images/ios_gestures.xml", "drag.tex"))
        gesture:SetPosition(-140,0)
        text = self.layoutTouch.dragPanel:AddChild(Text(BODYTEXTFONT, 65))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.DRAG_BODY)
        if resizeTexts then
            text:SetPosition(45, -40)
            text:AdjustToWidth(380)
        else
            text:SetPosition(25, -40)
            text:AdjustToWidth(400)
        end

        self.layoutTouch.pinchPanel = self.layoutTouch:AddChild(Image("images/fepanels.xml", "panel_mod2.tex"))
        self.layoutTouch.pinchPanel:SetPosition(201.6, -280.7)
        self.layoutTouch.pinchPanel:SetScale(0.7)
        self.layoutTouch.title = self.layoutTouch.pinchPanel:AddChild(Text(TITLEFONT, 100))
        self.layoutTouch.title:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.PINCH_TITLE)
        self.layoutTouch.title:SetPosition(0, 80)
        self.layoutTouch.title:AdjustToWidth(350)
        gesture = self.layoutTouch.pinchPanel:AddChild(Image("images/ios_gestures.xml", "pinch.tex"))
        gesture:SetPosition(-120,-40)
        text = self.layoutTouch.pinchPanel:AddChild(Text(BODYTEXTFONT, 65))
        text:SetHAlign(ANCHOR_LEFT)
        text:SetString(STRINGS.UI.CONTROLSSCREEN.IOS.PINCH_BODY)
        if resizeTexts then
            text:SetPosition(80, -70)
            text:AdjustToWidth(265)
        else
            text:SetPosition(65, -70)
            text:AdjustToWidth(280)
        end

        if IPHONE_VERSION then
            self.layoutTouch.closeButton:SetPosition(551.6, -300.4)
            self.layoutTouch.closeButton:SetScale(1.5)
            self.layoutTouch.pinchPanel:SetPosition(201.6, -250.7)
        end
    end
        self.default_focus = self.layoutTouch.closeButton

    -- CONTROLLER LAYOUT
        self.layoutController = self.root:AddChild(Widget("layout"))

        local image = self.layoutController:AddChild( Image( "images/ios_controllers.xml", "gamepad.tex" ) )
        image:SetPosition( 0,0,0 )

        local fontsize = 32

        for _, v in pairs(LABELS) do
            local label
            --if JapaneseOnPS4() then
                --label = layout:AddChild(Text(TITLEFONT, 35 * 0.7))
            --else
                label = self.layoutController:AddChild(Text(TITLEFONT, fontsize))
            --end
            label:SetString(v.text)
            label:SetRegionSize( LABEL_WIDTH, LABEL_HEIGHT )
            label:SetHAlign(v.anchor)
            if v.anchor == ANCHOR_RIGHT then
                label:SetPosition(v.x - LABEL_WIDTH/2, v.y, 0)
            else
                label:SetPosition(v.x + LABEL_WIDTH/2, v.y, 0)
            end
        end

end)

function ControlsScreen:Close()
	TheFrontEnd:PopScreen()
end

function ControlsScreen:OnControl(control, down)

    if ControlsScreen._base.OnControl(self, control, down) then return true end

    --[[if down then
        if control == CONTROL_PAGERIGHT then
            if self.rightbutton.shown then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                self:Scroll(controls_per_scroll)
            end

        elseif control == CONTROL_PAGELEFT then
            if self.leftbutton.shown then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                self:Scroll(-controls_per_scroll)
            end
        end
    end]]

if not down and control == CONTROL_CANCEL then self:Close() return true end
end

function ControlsScreen:GetHelpText()
    local t = {}
    local controller_id = TheInput:GetControllerID()

    --[[if self.leftbutton.shown then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_PAGELEFT) .. " " .. STRINGS.UI.HELP.SCROLLBACK)
    end
    if self.rightbutton.shown then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_PAGERIGHT) .. " " .. STRINGS.UI.HELP.SCROLLFWD)
    end]]


    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    return table.concat(t, "  ")
end

function ControlsScreen:OnUpdate(dt)
    if not TheInput:ControllerAttached() then
        self.layoutController:Hide()
        self.layoutTouch:Show()

    else
        self.layoutTouch:Hide()
        self.layoutController:Show()
    end
end



return ControlsScreen
