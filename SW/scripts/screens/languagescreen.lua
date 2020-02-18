--TODO(mapolo): test on iPhone

require "util"
require "strings"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local BigPopupDialogScreen = require "screens/bigpopupdialog"

local text_font = UIFONT--NUMBERFONT

local titles_changeLang = {}
local bodies_changeLang = {}

local LanguageScreen = Class(Screen, function(self, in_game)
    Screen._ctor(self, "LanguageScreen")
    --TheFrontEnd:DoFadeIn(1)

    self.newLanguage = TheSim:GetUsedLanguage()

    self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
    if IsDLCEnabled(REIGN_OF_GIANTS) then
        self.bg:SetTint(BGCOLOURS.PURPLE[1],BGCOLOURS.PURPLE[2],BGCOLOURS.PURPLE[3], 1)
    elseif IsDLCEnabled(CAPY_DLC) then
        self.bg:SetTint(BGCOLOURS.TEAL[1],BGCOLOURS.TEAL[2],BGCOLOURS.TEAL[3], 1)
    else
        self.bg:SetTint(BGCOLOURS.RED[1],BGCOLOURS.RED[2],BGCOLOURS.RED[3], 1)
    end
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    
    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    
    local shield = self.root:AddChild( Image( "images/globalpanels.xml", "panel.tex" ) )
    shield:SetPosition( 0,0,0 )
    if IPHONE_VERSION then
        shield:SetSize( 1100, 700 )
    else
        shield:SetSize( 1000, 700 )
    end
    
    self.title = self.root:AddChild(Text(TITLEFONT, 70))
    self.title:SetString(STRINGS.UI.MAINSCREEN.LANGUAGE)

    local spacing = -80
    if IPHONE_VERSION then
        spacing = -80
    end

    self.cancelMenu = self.root:AddChild(Menu(nil, spacing, false))
    --[[self.menuLeft = self.root:AddChild(Menu(nil, spacing, false))
    self.menuRight = self.root:AddChild(Menu(nil, spacing, false))

    if IPHONE_VERSION then
        self.title:SetPosition(0, 210, 0)
        self.menuLeft:SetPosition(-110, 100 ,0)
        self.menuLeft:SetScale(1.3)
        self.menuRight:SetPosition(110, 100, 0)
        self.menuRight:SetScale(1.3)
        self.cancelMenu:SetPosition(0, -240, 0)
        self.cancelMenu:SetScale(1.3)
    else
        self.title:SetPosition(0, 190, 0)
        self.menuLeft:SetPosition(-110, 100 ,0)
        self.menuLeft:SetScale(1)
        self.menuRight:SetPosition(110, 100, 0)
        self.menuRight:SetScale(1)
        self.cancelMenu:SetPosition(0, -240, 0)
        self.cancelMenu:SetScale(1)
    end

    self.menuLeft:AddItem("", function() self:DoLanguageGerman() end)
    self.menuLeft:AddItem("", function() self:DoLanguageEnglish() end)
    self.menuLeft:AddItem("", function() self:DoLanguageFrench() end)
    self.menuLeft:AddItem("", function() self:DoLanguageItalian() end)

    -- "한국어"
    self.menuRight:AddItem("", function() self:DoLanguageKorean() end)
    -- "简体中文"
    self.menuRight:AddItem("", function() self:DoLanguageSimplifiedChinese() end)
    -- "簡體中文"
    self.menuRight:AddItem("", function() self:DoLanguageTraditionalChinese() end)
    -- "Русский"
    self.menuRight:AddItem("", function() self:DoLanguageRussian() end)

    self.menuLeft.items[1].atlas = "images/ios_langscreen.xml"
    self.menuLeft.items[1].normal = "button_long_de.tex"
    self.menuLeft.items[1].focus = "button_long_over_de.tex"]]--
    local atlas = "images/ios_langscreen.xml"
    local langs = {"de", "en", "fr", "it", "es", "pl", "pt", "kor", "chi_sim", "chi_trad", "ru"}
    local funcs = { "german", "english", "french", "italian", "spanish", "polish", "portuguese",
                    "korean", "simplified_chinese", "traditional_chinese", "russian" }

    -- Language change dialog
    titles_changeLang["english"] = "WARNING!"
    titles_changeLang["french"] = "AVERTISSEMENT!"
    titles_changeLang["german"] = "WARNUNG!"
    titles_changeLang["italian"] = "ATTENZIONE!"
    titles_changeLang["spanish"] = "¡ADVERTENCIA!"
    titles_changeLang["polish"] = "OSTRZEŻENIE!"
    titles_changeLang["portuguese"] = "AVISO!"
    titles_changeLang["korean"] = "경고!"
    titles_changeLang["simplified_chinese"] = "警告！"
    titles_changeLang["traditional_chinese"] = "警告！"
    titles_changeLang["japanese"] = "注意！"
    titles_changeLang["russian"] = "Внимание!"

    bodies_changeLang["german"] = "Um die Sprache zu ändern, ist ein Neustart nötig. Bitte schließe das Spiel und starte es erneut."
    bodies_changeLang["english"] = "Game needs to restart to change language. Please close the game and run it again."
    bodies_changeLang["french"] = "Le jeu doit être redémarré pour changer de langue. Veuillez fermer le jeu et le redémarrer."
    bodies_changeLang["italian"] = "Il gioco deve essere riavviato per cambiare la lingua. Esci dal gioco ed eseguilo di nuovo."
    bodies_changeLang["spanish"] = "Es necesario reiniciar el juego para cambiar el idioma. Cierra el juego y vuelve a iniciarlo."
    bodies_changeLang["polish"] = "Zmiana języka wymaga restartu gry. Zamknij grę i uruchom ją ponownie."
    bodies_changeLang["portuguese"] = "O jogo precisa ser reiniciado para alterar o idioma. Feche o jogo e execute-o novamente."
    bodies_changeLang["korean"] = "언어를 변경하려면 게임을 다시 시작해야 합니다. 게임을 종료했다가 다시 실행하세요."
    bodies_changeLang["simplified_chinese"] = "需要重启游戏以更改语言。请关闭游戏，然后再次运行。"
    bodies_changeLang["traditional_chinese"] = "需要重啟遊戲以變更語言。請關閉遊戲，然後再次執行。"
    bodies_changeLang["japanese"] = "言語を変更するには、ゲームを再スタートする必要があります。ゲームを閉じ、再起動して下さい。"
    bodies_changeLang["russian"] = "Для смены языка требуется перезагрузка. Закройте и снова запустите игру."

    self.buttonList = {}
    self.languageCounter = 0
    for i,v in ipairs(langs) do 
        local button = self.root:AddChild(ImageButton(atlas, 
                                        "button_long_"..v..".tex",
                                        "button_long_over_"..v..".tex"))
        button:SetOnClick(function() self:DoLanguage(funcs[i]) end)
        if i < 5 then
            button:SetPosition(-240, 100+(i-1)*spacing ,0)
        elseif i < 9 then
            button:SetPosition(0, 100+(i-5)*spacing ,0)
        else
            button:SetPosition(240, 100+(i-9)*spacing ,0)
        end

        if IPHONE_VERSION then
            button:SetScale(1.3)
        end
        self.languageCounter = self.languageCounter + 1
        table.insert(self.buttonList, button)
    end
    
    if IPHONE_VERSION then
        self.title:SetPosition(0, 210, 0)
        self.cancelMenu:SetPosition(0, -240, 0)
        self.cancelMenu:SetScale(1.3)
    else
        self.title:SetPosition(0, 190, 0)
        self.cancelMenu:SetPosition(0, -240, 0)
        self.cancelMenu:SetScale(1)
    end
    


    self.cancelMenu:AddItem(STRINGS.UI.MAINSCREEN.CANCEL, function() self:Cancel() end)

    self.default_focus = self.cancelMenu

    self:DoFocusHookups()

    self:DoInit()

end)

function LanguageScreen:DoFocusHookups()
    local total_columns = 3
    local total_rows = 4

    local n = 0
    local c = 0
    for i=0,(total_columns-1) do
        n = i*total_rows

        for j=1,total_rows do
            c = n+j
            if c <= self.languageCounter then
              if j < total_rows and c < self.languageCounter  then
                  self.buttonList[c]:SetFocusChangeDir(MOVE_DOWN, self.buttonList[c+1])
              else
                  self.buttonList[c]:SetFocusChangeDir(MOVE_DOWN, self.cancelMenu)
              end
              if j > 1 then
                  self.buttonList[c]:SetFocusChangeDir(MOVE_UP, self.buttonList[c-1])
              end
              if i > 0 then
                  self.buttonList[c]:SetFocusChangeDir(MOVE_LEFT, self.buttonList[c-total_rows])
              end
              if i < (total_columns-1) and c ~= 8 then
                  self.buttonList[c]:SetFocusChangeDir(MOVE_RIGHT, self.buttonList[c+total_rows])
              end
            end
        end
    end

    self.cancelMenu:SetFocusChangeDir(MOVE_UP, self.buttonList[8])
end

-- @ES: language names must be the same ones used at strings.lua
function LanguageScreen:DoLanguage(lang)
    self.newLanguage = lang
    self:SaveThenExit()
end

function LanguageScreen:OnControl(control, down)
    if LanguageScreen._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_CANCEL then self:Close() return true end
end

function LanguageScreen:GetHelpText()
    local t = {}
    local controller_id = TheInput:GetControllerID()

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    return table.concat(t, "  ")
end

function LanguageScreen:Cancel()
    self:Close()                
end

function LanguageScreen:SaveThenExit()
    if self.newLanguage ~= TheSim:GetUsedLanguage() then
        local title = titles_changeLang[self.newLanguage]
        local body = bodies_changeLang[self.newLanguage] .. "\n\n" .. bodies_changeLang[TheSim:GetUsedLanguage()]
        TheSim:SetUsedLanguage(self.newLanguage)
        TheSim:ChangeLanguageDialog(title, body);
        TheInput.controlDisabled = true
    end
end

function LanguageScreen:Close()
    TheFrontEnd:DoFadeIn(1)
    TheFrontEnd:PopScreen()
end 


function LanguageScreen:UpdateMenu()
    if TheInput:ControllerAttached() then return end
end


function LanguageScreen:DoInit()
    self:UpdateMenu()
    local this = self
end

return LanguageScreen
