local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
require "os"

local PopupDialogScreen = require "screens/popupdialog"
local LoadGameScreen = require "screens/loadgamescreen"
local CreditsScreen = require "screens/creditsscreen"
local BigPopupDialogScreen = require "screens/bigpopupdialog"
local RateDialogScreen = require "screens/ratedialog"
local MovieDialog = require "screens/moviedialog"

local LanguageScreen = require "screens/languagescreen"

local ControlsScreen = nil
local OptionsScreen = nil
if PLATFORM == "iOS" or PLATFORM == "Android" then
    ControlsScreen = require "screens/controlsscreen_ios"
    OptionsScreen = require "screens/optionsscreen"
else
    ControlsScreen = require "screens/controlsscreen_ps4"
    OptionsScreen = require "screens/optionsscreen_ps4"
end

local RoGUpgrade = require "widgets/rogupgrade"

local rcol = RESOLUTION_X/2 -200
local lcol = -RESOLUTION_X/2 +200
local bottom_offset = 60

local MainScreen = Class(Screen, function(self, profile)
    Screen._ctor(self, "MainScreen")
    self.profile = profile
    self.log = true
    self:DoInit() 
    self.default_focus = self.menu
    self.music_playing = false

    self.top_root = self:AddChild(Widget("root"))
    self.top_root:SetVAnchor(ANCHOR_TOP)
    self.top_root:SetHAnchor(ANCHOR_LEFT)
    self.top_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.version = self.top_root:AddChild(Text(TITLEFONT, RESOLUTION_Y * 0.05))
    self.version:SetString("v"..APP_VERSION)
    self.version:SetPosition(45, -25, 0)
    self.version:Show()
end)


function MainScreen:DoInit( )
    STATS_ENABLE = false
    TheFrontEnd:GetGraphicsOptions():DisableStencil()
    TheFrontEnd:GetGraphicsOptions():DisableLightMapComponent()
    
    TheInputProxy:SetCursorVisible(true)

    if IsDLCInstalled(REIGN_OF_GIANTS) then
--        if TheSim:IsiPhone4S() then
--            self.bg = self:AddChild(Image("images/iphone4_menu.xml", "mainmenu_bg.tex"))
--        elseif IPHONE_VERSION then
--            self.bg = self:AddChild(Image("images/iphone_menu.xml", "mainmenu_bg.tex"))
--        else
            self.bg = self:AddChild(Image("images/ios_menu.xml", "mainmenu_bg.tex"))
--        end
    elseif IsDLCInstalled(CAPY_DLC) then
--        if TheSim:IsiPhone4S() then
--            self.bg = self:AddChild(Image("images/ps4_dlc0002.xml", "ps4_mainmenu.tex"))
--        elseif IPHONE_VERSION then
--            self.bg = self:AddChild(Image("images/ps4_dlc0002.xml", "ps4_mainmenu.tex"))
--        else
            self.bg = self:AddChild(Image("images/ps4_dlc0002.xml", "ps4_mainmenu.tex"))
--        end
    else
        self.bg = self:AddChild(Image("images/ps4.xml", "ps4_mainmenu.tex"))
    end

    --self.bg:SetTint(BGCOLOURS.RED[1],BGCOLOURS.RED[2],BGCOLOURS.RED[3], 1)
    self.bg:SetTint(BGCOLOURS.TEAL[1],BGCOLOURS.TEAL[2],BGCOLOURS.TEAL[3], 1)

    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    
    
    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
if APP_REGION ~= "SCEC" then
    self.anim = self.fixed_root:AddChild(UIAnim())
    -- if IPHONE_VERSION then
    --     self.anim:GetAnimState():SetBuild("animated_title_")
    -- else
    --     self.anim:GetAnimState():SetBuild("animated_title")
    -- end
    -- self.anim:GetAnimState():SetBank("animated_title")
    -- self.anim:GetAnimState():PlayAnimation("anim", true)
    -- --self.anim:SetScaleMode(SCALEMODE_PROPORTIONAL)
    -- self.anim:SetScale(1.6)
    -- self.anim:SetVAnchor(ANCHOR_MIDDLE)
    -- self.anim:SetHAnchor(ANCHOR_MIDDLE)
    -- self.anim:GetAnimState():OverrideSymbol("willow_title_fire", "title_fire", "willow_title_fire")
    -- self.anim:GetAnimState():OverrideSymbol("wilson_title_fire", "title_fire", "wilson_title_fire")
    -- self.anim:SetPosition(0, -100)


    self.anim:GetAnimState():SetBuild("sw_title_shield")
    self.anim:GetAnimState():SetBank("sw_title_shield")
    self.anim:GetAnimState():PlayAnimation("idle", true)
    self.anim:SetScale(2, 1.92)
    self.anim:SetVAnchor(ANCHOR_MIDDLE)
    self.anim:SetHAnchor(ANCHOR_MIDDLE)
    self.anim:SetPosition(-30,-590,0)
end

    
    --center stuff
    if IsDLCInstalled(REIGN_OF_GIANTS) then
        if IPHONE_VERSION then
            self.shield = self.fixed_root:AddChild(Image("images/iphone_shield.xml", "mainmenu_titleshield.tex"))
        else
            self.shield = self.fixed_root:AddChild(Image("images/ios_shield.xml", "mainmenu_titleshield.tex"))
        end
    elseif IsDLCInstalled(CAPY_DLC) then
        if APP_REGION == "SCEC" then
            self.shield = self.fixed_root:AddChild(Image("images/tencent_shield_sw.xml", "shipwrecked_shield_tencent.tex"))
        else
            self.shield = self.fixed_root:AddChild(Image())
        end
    else
        self.shield = self.fixed_root:AddChild(Image("images/ps4.xml", "ps4_mainmenu_title.tex"))
    end

    self.shield:SetVRegPoint(ANCHOR_MIDDLE)
    self.shield:SetHRegPoint(ANCHOR_MIDDLE)
    self.shield:SetPosition(0,60,0)
    self.shield:SetScale(0.52, 0.52)

    self.bannerroot = self.shield:AddChild(Widget("bann"))
    self.bannerroot:SetScale(1)

    if JapaneseOnPS4() then
        self.bannerroot:SetPosition(0, -175, 0)
    else
        self.bannerroot:SetPosition(0, -155, 0)
    end

    --[[self.banner = self.bannerroot:AddChild(Image("images/ui.xml", "update_banner.tex"))
    self.banner:SetVRegPoint(ANCHOR_MIDDLE)
    self.banner:SetHRegPoint(ANCHOR_MIDDLE)
    if JapaneseOnPS4() then
        self.banner:SetScale(0.9, 1.4 )
    else
        self.banner:SetScale(1, 1.3)
    end

    
    self.updatename = self.bannerroot:AddChild(Text(BUTTONFONT, 40))
    if JapaneseOnPS4() then
        self.updatename:SetPosition(0,12,0)
        self.updatename:SetRegionSize(120,90)
        self.updatename:EnableWordWrap(true)
    else
        self.updatename:SetPosition(0,8,0)
    end

    if PLATFORM == "iOS" then
        self.updatename:SetString(STRINGS.UI.MAINSCREEN.PORTABLE_EDITION_TEXT)
    else
        self.updatename:SetString(STRINGS.UI.MAINSCREEN.CONSOLE_EDITION_TEXT)
    end
    self.updatename:SetColour(0,0,0,1)]]

    --RIGHT COLUMN

    self.right_col = self.fixed_root:AddChild(Widget("right"))
    self.right_col:SetPosition(0, 0)

    if IPHONE_VERSION then
        self.menu = self.right_col:AddChild(Menu(nil, 220, true))
    else
        self.menu = self.right_col:AddChild(Menu(nil, -70))
    end
    if JapaneseOnPS4() then
        self.menu:SetPosition(0, -202, 0)
    else
        if IPHONE_VERSION then
            self.menu:SetPosition(-310, -300, 0)
        elseif TheSim:IsUnsupportedDevice() then
            self.menu:SetPosition(10, -210, 0)
        else
            self.menu:SetPosition(10, -240, 0)
        end
    end

    if IPHONE_VERSION then
        self.menu:SetScale(1.4)
--        if TheSim:IsiPhone4S() then
--            self.anim:SetScale(0.43)
--            self.anim:SetPosition(-185, 155)
--            self.shield:SetPosition(-10,-40,0)
--            self.shield:SetScale(0.73)
--        elseif TheSim:IsiPhonePlus() then
--            self.anim:SetScale(2.0)
--            self.anim:SetPosition(0, 10)
--            self.anim:SetPosition(-30,-750,0)
--            self.shield:SetScale(0.73)
--        else
            if APP_REGION ~= "SCEC" then
                self.anim:SetScale(0.9)
                self.anim:SetPosition(0, 10)
                self.anim:SetPosition(-30,-300,0)
            end
            self.shield:SetScale(0.73)
--        end
    elseif TheSim:IsUnsupportedDevice() then

        self.menu:SetScale(0.95)
        if APP_REGION ~= "SCEC" then
            self.anim:SetScale(0.8)
            self.anim:SetPosition(0, -50)
        end
        self.shield:SetScale(0.45)
    else
        self.menu:SetScale(1)
    end
    

    if PLATFORM ~= "iOS" and PLATFORM ~= "Android" and not IsDLCInstalled(REIGN_OF_GIANTS) then
        self.RoGUpgrade = self.fixed_root:AddChild(RoGUpgrade())
        self.RoGUpgrade:SetScale(.8)
        self.RoGUpgrade:SetPosition(-445, 205, 0)
    end


    self:MainMenu()
    self.menu:SetFocus()

    self.askForiCloud = false -- TheSim:ShouldAskForiCloud()
    self.moviePlayed = false

    TheSim:SetHDGraphics(Profile:GetHD() == 'true')

end

function MainScreen:OnControl(control, down)
    -- don't do anything until we have space to save
--    if not TheSystemService:IsStorageAvailable() then return end
    
    if MainScreen._base.OnControl(self, control, down) then return true end
    
    if not down and control == CONTROL_CANCEL then
        if not self.mainmenu then
            self:MainMenu()
            return true
        end
    end
end


-- SUBSCREENS

function MainScreen:Settings()
    TheFrontEnd:PushScreen(OptionsScreen(false))
end

function MainScreen:OnControlsButton()
    TheFrontEnd:PushScreen(ControlsScreen())
end

function MainScreen:Forums()
    VisitURL("http://forums.kleientertainment.com/index.php?/forum/5-dont-starve/")
end

function MainScreen:Refresh()
    self:MainMenu()
    TheFrontEnd:GetSound():PlaySound("dontstarve_DLC002/music/music_FE","FEMusic")
    if IsDLCInstalled(REIGN_OF_GIANTS) then
        if self.RoGUpgrade then self.RoGUpgrade:Hide() end
    else
        if self.RoGUpgrade then self.RoGUpgrade:Show() end
    end
end

function MainScreen:ShowMenu(menu_items)
    self.mainmenu = false
    self.menu:Clear()
    
    for k = #menu_items, 1, -1  do
        local v = menu_items[k]
        if v.widestring then
            local button = self.menu:AddItem(v.text, v.cb, nil, nil, .9)
            button.image:SetScale(1.3,1,1)
        else
            local button = self.menu:AddItem(v.text, v.cb)
            button.image:SetScale(1.3,1,1)
        end
    end

    self.menu:SetFocus()
end


function MainScreen:DoOptionsMenu()

    inOptions = true

    local menu_items = {}
    table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.CANCEL, cb= function() self:MainMenu() end})
    table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.CREDITS, cb= function() self:OnCreditsButton() end})
    table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.CONTROLS, cb= function() self:OnControlsButton() end})
    table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.SETTINGS, cb= function() self:Settings() end})
    self:ShowMenu(menu_items)
--    if TheSim:IsiPhone4S() then
--        self.menu:SetPosition(-450, -340, 0)
--    elseif TheSim:IsiPhonePlus() then
--        self.menu:SetPosition(-450, -330, 0)
--    elseif IPHONE_VERSION then
        self.menu:SetPosition(-450, -280, 0)
--    end
end

function MainScreen:DoLanguageMenu()
    TheFrontEnd:PushScreen(LanguageScreen(false))
end

function MainScreen:DoFeedbackDialog()
    local popup = RateDialogScreen(
            {
                {text=STRINGS.UI.FEEDBACK.FORUMS, cb = function () VisitURL("http://forums.kleientertainment.com/forum/5-dont-starve/") end},
                {text=STRINGS.UI.FEEDBACK.RATE_US, cb = function () OpenRateApp() end}
            }
        )
    TheFrontEnd:PushScreen(popup)    
end

function MainScreen:OnCreditsButton()
    TheFrontEnd:GetSound():KillSound("FEMusic")
    TheFrontEnd:PushScreen( CreditsScreen() )
end

local function UnsupportedDevice()
    local popup = BigPopupDialogScreen(STRINGS.UNSUPPORTED_DEVICE.TITLE, STRINGS.UNSUPPORTED_DEVICE.BODY,
    {
        {
            text = STRINGS.UI.EMAILSCREEN.OK,
            cb = function()
                TheFrontEnd:PopScreen()
            end
        }
    }
    )
    popup.title:SetPosition(0, 188, 0)
    local usedLanguage = TheSim:GetUsedLanguage()
    if usedLanguage == "korean" or usedLanguage == "simplified_chinese" or usedLanguage == "traditional_chinese" or usedLanguage == "japanese" then
        popup.title:SetSize(42)
    end 
    popup.text:SetRegionSize(580, 400)
    popup.text:SetPosition(0, 2, 0)
    popup.text:SetSize(33)
    local pos = popup.menu:GetPosition()
    popup.menu:SetPosition(pos.x, pos.y-50, pos.z)
    return popup
end

local function CompatibilityModeAdvice()
    local popup = BigPopupDialogScreen(STRINGS.COMPATIBILITY_MODE.TITLE, STRINGS.COMPATIBILITY_MODE.BODY,
    {
        {
            text = STRINGS.UI.EMAILSCREEN.OK,
            cb = function()
            TheFrontEnd:PopScreen()
            end
        }
    }
    )
--    if TheSim:IsiPhone4S() then
--        popup.title:SetPosition(0, 208, 0)
--    else
        popup.title:SetPosition(0, 188, 0)
--    end
    popup.text:SetRegionSize(580, 400)
    local usedLanguage = TheSim:GetUsedLanguage()
    if usedLanguage == "korean" or usedLanguage == "simplified_chinese" or usedLanguage == "traditional_chinese" or usedLanguage == "japanese" then
        popup.title:SetSize(42)
    end 

    local factor = 1
    if IPHONE_VERSION then
        factor = 1.2
    end

    popup.title:AdjustToWidth(340 * factor)

--    if TheSim:IsiPhone4S() then
--        popup.text:SetPosition(0, 15, 0)
--    else
        popup.text:SetPosition(0, 2, 0)
--    end

    local fontSize = 33
    if usedLanguage == "korean" or usedLanguage == "simplified_chinese" or usedLanguage == "traditional_chinese" or usedLanguage == "japanese" then
        fontSize = 28
    end 
    popup.text:SetSize(fontSize * factor)
    local pos = popup.menu:GetPosition()
    popup.menu:SetPosition(pos.x, pos.y-50, pos.z)
    return popup
end

function MainScreen:MainMenu()

    inOptions = false

    local menu_items = {}

    local tencent_offset = 180
    if (PLATFORM == "iOS" or PLATFORM == "Android") and (APP_REGION ~= "SCEC") then
        table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.LANGUAGE, cb= function() self:DoLanguageMenu() end})
        tencent_offset = 0
    end
    table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.FEEDBACK, cb= function() self:DoFeedbackDialog() end})
    table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.OPTIONS, cb= function() self:DoOptionsMenu() end})
    table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.PLAY, cb= function() TheFrontEnd:PushScreen(LoadGameScreen()) end})

    self:ShowMenu(menu_items)
--    if TheSim:IsiPhone4S() then
--        self.menu:SetPosition(-460, -340, 0)
--    elseif TheSim:IsiPhonePlus() then
--        self.menu:SetPosition(-460, -330, 0)
--    elseif IPHONE_VERSION then
        self.menu:SetPosition(-460 + tencent_offset, -280, 0)
--    end
    self.mainmenu = true
end

function MainScreen:OnBecomeActive()
    MainScreen._base.OnBecomeActive(self)
end

function MainScreen:CheckStorage()            
    if TheSystemService:IsStorageAvailable() then    
        local operation, status = TheSystemService:GetLastOperation()
        --print("MainScreen:Saveload result", operation, status)
        if operation ~= SAVELOAD.OPERATION.NONE and status ~= SAVELOAD.STATUS.OK then
            TheFrontEnd:OnSaveLoadError(operation, "", status)        
            return
        else        
            self:CheckDisplayArea()
        end        
    else
        TheSystemService:PrepareStorage(function(success) self:CheckStorage() end)
    end
end

function MainScreen:CheckDisplayArea()
    local isAdjusted = TheSystemService:IsDisplaySafeAreaAdjusted()
    local sawAdjustmentPopup = Profile:SawDisplayAdjustmentPopup()
    if (not isAdjusted and not sawAdjustmentPopup) then
    
        local function adjust()  
            TheSystemService:AdjustDisplaySafeArea()
            Profile:ShowedDisplayAdjustmentPopup()
            TheFrontEnd:PopScreen() -- pop after updating settings otherwise this dialog might show again!
            Profile:Save()
        end
        
        local function nothanks()   
            Profile:ShowedDisplayAdjustmentPopup()
            TheFrontEnd:PopScreen() -- pop after updating settings otherwise this dialog might show again!
            Profile:Save()
        end
        
        local popup = BigPopupDialogScreen(STRINGS.UI.MAINSCREEN.ADJUST_DISPLAY_HEADER, STRINGS.UI.MAINSCREEN.ADJUST_DISPLAY_TEXT,
            {
                {text=STRINGS.UI.MAINSCREEN.YES, cb = adjust},
                {text=STRINGS.UI.MAINSCREEN.NO, cb = nothanks}  
            }
        )
        TheFrontEnd:PushScreen(popup)    
    end
end


function MainScreen:OnUpdate(dt)
    if TheSim:ShouldPlayIntroMovie() then
        TheFrontEnd:PushScreen( MovieDialog("movies/forbidden_knowledge.mp4", function() TheFrontEnd:GetSound():PlaySound("dontstarve_DLC002/music/music_FE","FEMusic") self:CheckStorage() self.moviePlayed = true end ) )
        self.music_playing = true
    elseif not self.music_playing then
        TheFrontEnd:GetSound():PlaySound("dontstarve_DLC002/music/music_FE","FEMusic")
        self.music_playing = true
        
        self:CheckStorage()
    end 

    if self.moviePlayed then
        if self.askForiCloud then
            local popup = BigPopupDialogScreen( STRINGS.ICLOUD.TITLE, STRINGS.ICLOUD.ASK_BODY,
                { 
                    { 
                        text = STRINGS.UI.MAINSCREEN.YES, 
                        cb = function()
                            
                            TheSim:InitiCloud(function(success)
                                if success then
                                    TheSim:SetiCloudEnabled(true)
                                else
                                    TheSim:SetiCloudEnabled(false)
                                    TheFrontEnd:PushScreen(
                                        BigPopupDialogScreen( STRINGS.ICLOUD.ERROR_TITLE, STRINGS.ICLOUD.ERROR_BODY,
                                          { 
                                            { 
                                                text = STRINGS.UI.MAINSCREEN.OK, 
                                                cb = function()
                                                    TheFrontEnd:PopScreen()                 
                                                end
                                            },
                                          }
                                        )
                                    )
                                end
                            end)
                            TheFrontEnd:PopScreen()                 
                        end
                    },
                    { 
                        text = STRINGS.UI.MAINSCREEN.NO, 
                        cb = function()
                            TheSim:SetiCloudEnabled(false)
                            TheFrontEnd:PopScreen()                 
                        end
                    },
                }
            )
            TheFrontEnd:PushScreen(popup)
            self.askForiCloud = false
        elseif TheSim:IsUnsupportedDevice() and not self.adviceShown then
            TheFrontEnd:PushScreen(CompatibilityModeAdvice())
            self.adviceShown = true

        end
        -- if not self.askForiCloud then
        --     if not TheSim:GetUsedLanguageExists() then
        --         TheFrontEnd:PushScreen(
        --         BigPopupDialogScreen( "New languages available!", "Don't Starve can now be played in a variety of different languages. Make sure you check the available options in the 'Language' menu.",
        --           { 
        --             { 
        --                 text = "Ok", 
        --                 cb = function()
        --                     TheSim:SetUsedLanguage("english")
        --                     TheFrontEnd:PopScreen()                 
        --                 end
        --             },
        --           }
        --         )
        --     )
        --     end
        -- end
    end

end

function MainScreen:GetHelpText()
    if not self.mainmenu then
        local controller_id = TheInput:GetControllerID()
        return TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK
    else
        return ""
    end
end


return MainScreen
