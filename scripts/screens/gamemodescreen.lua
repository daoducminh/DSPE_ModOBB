local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local PopupDialogScreen = require "screens/popupdialog"
local BigPopupDialogScreen = require "screens/bigpopupdialog"
local ControlsScreen = nil
local OptionsScreen = nil

ControlsScreen = require "screens/controlsscreen"
OptionsScreen = require "screens/optionsscreen"

local NewGameScreen = require "screens/newgamescreen"

local GameModeScreen = Class(Screen, function(self, slotnum)
	Screen._ctor(self, "GameModeScreen")
	self.active = true
	
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
    self.bg = self.proot:AddChild(Image("images/globalpanels.xml", "small_dialog.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetScale(2,2.2,2.2)
	
	

    --captions
    self.survivalcaption = self.proot:AddChild(Text(UIFONT, 30))
    self.survivalcaption:SetPosition(-230, -170, 0)
    self.survivalcaption:SetString(STRINGS.UI.GAMEMODEMENU.CLASSIC_DESC)
    self.survivalcaption:EnableWordWrap(true)
    self.survivalcaption:SetRegionSize(400,100)

    self.easycaption = self.proot:AddChild(Text(UIFONT, 30))
    self.easycaption:SetPosition(240, -155, 0)
    self.easycaption:SetString(STRINGS.UI.GAMEMODEMENU.NOSWEAT_DESC)

    self.survivaltitle = self.proot:AddChild(Text(UIFONT, 45))
    self.survivaltitle:SetPosition(-240,-120, 0)
    self.survivaltitle:SetString(STRINGS.UI.GAMEMODEMENU.CLASSIC)

    self.easytitle = self.proot:AddChild(Text(UIFONT, 45))
    self.easytitle:SetPosition(240,-120, 0)
    self.easytitle:SetString(STRINGS.UI.GAMEMODEMENU.NOSWEAT)

    --images
    self.survivalbutton = self.proot:AddChild(ImageButton("images/ui.xml", "playstyle_survival.tex"))
    self.survivalbutton:SetOnClick(
    	function()
			TheFrontEnd:PopScreen(self) 
			local screen = NewGameScreen(slotnum)
			screen:SetSavedCustomOptions({preset="SURVIVAL_DEFAULT", tweak={}}, true)
            screen:SetNoSweatEnabled(false)
			TheFrontEnd:PushScreen(screen)    		
    	end
    )
    self.survivalbutton:SetPosition(-240,50)
    self.survivalbutton:SetScale(0.7,0.7,0.7)

    self.easybutton = self.proot:AddChild(ImageButton("images/ui.xml", "playstyle_easy.tex"))
    self.easybutton:SetOnClick(
        function()

            local skip_warning = function()
                TheFrontEnd:PopScreen(self) 
                local screen = NewGameScreen(slotnum)
                screen:SetSavedCustomOptions({preset="NOSWEAT", tweak={}}, true)
                screen:SetNoSweatEnabled(true)
                TheFrontEnd:PushScreen(screen)          
            end

            if not Profile:HaveWarnedCasual() then

                local popup = BigPopupDialogScreen(STRINGS.UI.NEWGAMESCREEN.NOSWEAT_WARNING_TITLE, STRINGS.UI.NEWGAMESCREEN.NOSWEAT_WARNING_BODY, 
                    {{text=STRINGS.UI.NEWGAMESCREEN.YES, 
                        cb = function() 
                            Profile:SetHaveWarnedCasual()
                            TheFrontEnd:PopScreen()
                            skip_warning()
                        end},
                    {text=STRINGS.UI.NEWGAMESCREEN.NO, 
                        cb = function() 
                            TheFrontEnd:PopScreen()
                            TheFrontEnd:PopScreen() 
                        end}  
                    })
                local factor = 1
                if IPHONE_VERSION then
                    factor = 1.5
                end
                popup.text:SetSize(28*factor)
                TheFrontEnd:PushScreen(popup)

            else
                skip_warning()
            end
        end
    )
    self.easybutton:SetPosition(240,50)
    self.easybutton:SetScale(0.7,0.7,0.7)


    -- [blit-vicent] moved here to avoid button images to be drawn over the title
    --title 
    self.title = self.proot:AddChild(Text(TITLEFONT, 60))
    self.title:SetPosition(0, 150, 0)
    self.title:SetString(STRINGS.UI.GAMEMODEMENU.TITLE)

    self.default_focus = self.survivalbutton

end)

function GameModeScreen:OnUpdate(dt)
end

function GameModeScreen:OnControl(control, down)
	if (control == CONTROL_MOVE_RIGHT or control == CONTROL_FOCUS_RIGHT) and not down and self.survivalbutton.focus then
		self.survivalbutton.focus = false
		self.survivalbutton:OnLoseFocus()
		self.easybutton.focus = true
		self.easybutton:OnGainFocus()
		return true
	elseif (control == CONTROL_MOVE_LEFT or control == CONTROL_FOCUS_LEFT) and not down and self.easybutton.focus then
		self.survivalbutton.focus = true
		self.survivalbutton:OnGainFocus()
		self.easybutton.focus = false
		self.easybutton:OnLoseFocus()
		return true
	end

	if GameModeScreen._base.OnControl(self,control, down) then return true end

end


return GameModeScreen
