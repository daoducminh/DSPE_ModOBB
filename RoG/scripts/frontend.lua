local easing = require("easing")
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Image = require "widgets/image"
local HoverText = require "widgets/hoverer"
local ConsoleScreen = require "screens/consolescreen"
local DebugMenuScreen = require "screens/DebugMenuScreen"
local PopupDialogScreen = require "screens/popupdialog"
require "constants"


local REPEAT_TIME = .25
local PAGE_REPEAT_TIME = .25

local save_fade_time = .5

FrontEnd = Class(function(self, name)
	self.screenstack = {}
	self.touchwidget = {}

	self.screenroot = Widget("screenroot")
	self.overlayroot = Widget("overlayroot")

	self.ignoreups	= {}
	------ CONSOLE -----------	
	
	self.consoletext = Text(BODYTEXTFONT, 20, "CONSOLE TEXT")
	self.consoletext:SetVAlign(ANCHOR_BOTTOM)
	self.consoletext:SetHAlign(ANCHOR_LEFT)
    self.consoletext:SetVAnchor(ANCHOR_MIDDLE)
    self.consoletext:SetHAnchor(ANCHOR_MIDDLE)
	self.consoletext:SetScaleMode(SCALEMODE_PROPORTIONAL)

	self.consoletext:SetRegionSize(900, 400)
	self.consoletext:SetPosition(0,0,0)
	self.consoletext:Hide()
    -----------------



    self.blackoverlay = Image("images/global.xml", "square.tex")
    self.blackoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.blackoverlay:SetTint(0,0,0,0)
	self.blackoverlay:SetClickable(false)
	self.blackoverlay:Hide()


    self.topblackoverlay = Image("images/global.xml", "square.tex")
    self.topblackoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.topblackoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.topblackoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.topblackoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.topblackoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.topblackoverlay:SetTint(0,0,0,0)
	self.topblackoverlay:SetClickable(false)
	self.topblackoverlay:Hide()

	self.helptext = self.overlayroot:AddChild(Widget("HelpText"))
	self.helptext:SetScaleMode(SCALEMODE_FIXEDPROPORTIONAL)
    self.helptext:SetHAnchor(ANCHOR_MIDDLE)
    self.helptext:SetVAnchor(ANCHOR_BOTTOM)

	local help_height = 80

    self.helptextbg = self.helptext:AddChild(Image("images/global.xml", "square.tex"))
	self.helptextbg:SetScale(RESOLUTION_X/63 + 8, 2*help_height/63)
	self.helptextbg:SetPosition(0, -help_height/2)
--	self.helptextbg:SetClickable(false)
	self.helptextbg:SetTint(0,0,0,.75)
	
	self.helptexttext = self.helptext:AddChild(Text(UIFONT, 30))
    --self.helptexttext:SetVAnchor(ANCHOR_BOTTOM)
    --self.helptexttext:SetHAnchor(ANCHOR_MIDDLE)
	self.helptexttext:SetRegionSize(RESOLUTION_X*.9, help_height)
	self.helptexttext:SetPosition(0, -5)
	self.helptexttext:SetHAlign(ANCHOR_RIGHT)
	self.helptexttext:SetVAlign(ANCHOR_TOP)

	self.overlayroot:AddChild(self.topblackoverlay)
	self.screenroot:AddChild(self.blackoverlay)
	
    self.alpha = 0.0
    
    self.title = Text(TITLEFONT, 100)
    self.title:SetPosition(0, -30, 0)
    self.title:Hide()
    self.title:SetVAnchor(ANCHOR_MIDDLE)
    self.title:SetHAnchor(ANCHOR_MIDDLE)
	self.overlayroot:AddChild(self.title)
	
    self.subtitle = Text(TITLEFONT, 70)
    self.subtitle:SetPosition(0, 70, 0)
    self.subtitle:Hide()
    self.subtitle:SetVAnchor(ANCHOR_MIDDLE)
    self.subtitle:SetHAnchor(ANCHOR_MIDDLE)
	self.overlayroot:AddChild(self.subtitle)

	self.saving_indicator = UIAnim()
    self.saving_indicator:GetAnimState():SetBank("saving_indicator")
    self.saving_indicator:GetAnimState():SetBuild("saving_indicator")
    self.saving_indicator:GetAnimState():PlayAnimation("save_loop", true)
    self.saving_indicator:SetVAnchor(ANCHOR_BOTTOM)
    self.saving_indicator:SetHAnchor(ANCHOR_RIGHT)
	self.saving_indicator:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.saving_indicator:SetPosition(-10, 40)
	self.saving_indicator:Hide()

	self:HideTitle()

	self.gameinterface = CreateEntity()
	self.gameinterface.entity:AddSoundEmitter()
	self.gameinterface.entity:AddGraphicsOptions()
	self.gameinterface.entity:AddBroadcastingOptions()

	TheInput:AddKeyHandler(function(key, down) self:OnRawKey(key, down) end )
	TheInput:AddTextInputHandler(function(text) self:OnTextInput(text) end )

	self.displayingerror = false

	self.tracking_mouse = true
	self.repeat_time = REPEAT_TIME
	self.page_repeat_time = PAGE_REPEAT_TIME

	self.topFadeHidden = false

	self.updating_widgets = setmetatable({}, {__mode="k"})
	self.num_pending_saves = 0
	self.save_indicator_time_left = 0
	self.save_indicator_fade_time = 0
	self.save_indicator_fade = nil
	self.autosave_enabled = true
end)

function FrontEnd:ShowSavingIndicator()
	if PLATFORM ~= "PS4" then return end

    if TheSystemService:IsStorageEnabled() then
		if not self.saving_indicator.shown then
			self.save_indicator_time_left = 3
			self.saving_indicator:Show()
			self.saving_indicator:ForceStartWallUpdating()
			self.save_indicator_fade_time = save_fade_time
			self.saving_indicator:GetAnimState():SetMultColour(1,1,1,0)
			self.save_indicator_fade = "in"
		end

	    self.num_pending_saves = self.num_pending_saves + 1
	end
end

function FrontEnd:HideSavingIndicator()
	if PLATFORM ~= "PS4" then return end
	
	if self.num_pending_saves > 0 then
		self.num_pending_saves = self.num_pending_saves - 1
	end
end

function FrontEnd:HideTopFade()
	self.topblackoverlay:Hide()
	self.topFadeHidden = true
end

function FrontEnd:ShowTopFade()
	self.topFadeHidden = false
	self.topblackoverlay:Show()
end

function FrontEnd:GetFocusWidget()
	if #self.screenstack > 0 then
		return self.screenstack[#self.screenstack]:GetDeepestFocus()
	end
end

function FrontEnd:GetHelpText()
	local t = {}
	
	local widget = self:GetFocusWidget()
	if widget and widget.GetHelpText then
		local str = widget:GetHelpText()
		if str ~= "" then
			table.insert(t, widget:GetHelpText())
		end
	end

	if #self.screenstack > 0 and self.screenstack[#self.screenstack] ~= widget then
		local str = self.screenstack[#self.screenstack]:GetHelpText()
		if str ~= "" then
			table.insert(t, str)
		end
	end


	return table.concat(t, "  ")
end

function FrontEnd:StopTrackingMouse()
	self.tracking_mouse = false
end

function FrontEnd:OnFocusMove(dir, down)
	-- print("On Focus: ".. (self.tracking_mouse and "YES" or "NO"))
	if self.focus_locked then return true end
	if #self.screenstack > 0 then
		if self.screenstack[#self.screenstack]:OnFocusMove(dir, down) then
	   		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover_controller")
			self.tracking_mouse = false
			return true
		else
			if self.tracking_mouse and down and self.screenstack[#self.screenstack]:SetDefaultFocus() then
				self.tracking_mouse = false
				return true
			end
		end
	end
end

function FrontEnd:OnControl(control, down, isrepeat)
	--handle focus moves

	if TheInput.controlDisabled then
		return
	end

	if not isrepeat and not down and self.ignoreups[control] then
		self.ignoreups[control] = nil
		return true
	end


	if #self.screenstack > 0 then
		local screen = self.screenstack[#self.screenstack]
		if control == CONTROL_PRIMARY then control = CONTROL_ACCEPT end  --map this one for buttons
		if screen:OnControl(control, down) then return true end
	end

	if not down and control == CONTROL_OPEN_DEBUG_CONSOLE then
		self:PushScreen(ConsoleScreen())
		return true
	end

	if DEBUG_MENU_ENABLED then
		if not down and control == CONTROL_OPEN_DEBUG_MENU then
			self:PushScreen(DebugMenuScreen())
			return true
		end
	end

	if not down and control == CONTROL_TOGGLE_LOG then
		if self.consoletext.shown then 
			self:HideConsoleLog()
		else
			self:ShowConsoleLog()
		end
		return true
	end

	if not down and control == CONTROL_TOGGLE_DEBUGRENDER then
			    if TheInput:IsKeyDown(KEY_CTRL) then
				    TheSim:SetDebugPhysicsRenderEnabled(not TheSim:GetDebugPhysicsRenderEnabled())
			    else
				    TheSim:SetDebugRenderEnabled(not TheSim:GetDebugRenderEnabled())
			    end
		return true
	end


--[[
		elseif control == CONTROL_CANCEL then
			return screen:OnCancel(down)
--]]
end

function FrontEnd:ShowTitle(text,subtext)
	self.title:SetString(text)
	self.title:Show()
	self.subtitle:SetString(subtext)
	self.subtitle:Show()
	self:StartTileFadeIn()
end

local fade_time = 2

function FrontEnd:DoTitleFade(dt)
	if self.fade_title_in == true or self.fade_title_out == true then
		dt = math.min(dt, 1/30)
		if self.fade_title_in == true and self.fade_title_time <fade_time then
			self.fade_title_time = self.fade_title_time + dt
		elseif self.fade_title_out == true and self.fade_title_time >0 then
			self.fade_title_time = self.fade_title_time - dt
		end

		self.fade_title_alpha = easing.inOutCubic(self.fade_title_time, 0, 1, fade_time)

		self.title:SetAlpha(self.fade_title_alpha)
		self.subtitle:SetAlpha(self.fade_title_alpha)

		if self.fade_title_in == true and self.fade_title_time >=fade_time then
			self:StartTileFadeOut()
		end
	end
end

function FrontEnd:StartTileFadeIn()
	self.fade_title_in = true
	self.fade_title_time = 0
	self.fade_title_out = false
	self:DoTitleFade(0)
end

function FrontEnd:StartTileFadeOut()
	self.fade_title_in = false
	self.fade_title_out = true
end

function FrontEnd:HideTitle()
	self.title:Hide()
	self.subtitle:Hide()
	self.fade_title_in = false
	self.fade_title_time = 0
	self.fade_title_out = false
end

function FrontEnd:LockFocus(lock)
	self.focus_locked = lock
end

function FrontEnd:SendScreenEvent(type, message)
	if #self.screenstack > 0 then
		self.screenstack[#self.screenstack]:HandleEvent(type, message)
	end
end


function FrontEnd:GetSound()
	return self.gameinterface.SoundEmitter
end

function FrontEnd:GetGraphicsOptions()
	return self.gameinterface.GraphicsOptions
end

function FrontEnd:GetBroadcastingOptions()
	return self.gameinterface.BroadcastingOptions
end

function FrontEnd:SetFadeLevel(alpha)
	--print ("SET FADE LEVEL", alpha)
	self.alpha = alpha
	if alpha <= 0 then
		if self.blackoverlay then
			self.blackoverlay:Hide()
		end
		if self.topblackoverlay then
			self.topblackoverlay:Hide()
		end
	else
		self.blackoverlay:Show()
		self.blackoverlay:SetTint(0,0,0,alpha)
		if (not self.topFadeHidden) then
			self.topblackoverlay:Show()
		end
		self.topblackoverlay:SetTint(0,0,0,alpha)
	end
end

function FrontEnd:GetFadeLevel(alpha)
	return self.alpha
end

function FrontEnd:DoFadingUpdate(dt)
	dt = math.min(dt, 1/30)
	if self.fade_delay_time then
		self.fade_delay_time = self.fade_delay_time - dt
		if self.fade_delay_time <= 0 then
			self.fade_delay_time = nil
			if self.delayovercb then
				self.delayovercb()
				self.delayovercb = nil
			end
		end
		return
	elseif self.fadedir ~= nil then
		self.fade_time = self.fade_time + dt
		
		local alpha = 0
		if self.fadedir then
			if self.total_fade_time == 0 then
				alpha = 0
			else
				alpha = easing.inOutCubic(self.fade_time, 1, -1, self.total_fade_time)
			end
		else
			if self.total_fade_time == 0 then
				alpha = 1
			else
				alpha = easing.outCubic(self.fade_time, 0, 1, self.total_fade_time)
			end
		end
		
		self:SetFadeLevel(alpha)
		if self.fade_time >= self.total_fade_time then
			self.fadedir = nil
			if self.fadecb then
				local cb = self.fadecb
				self.fadecb = nil
				cb()
			end
		end
	end
end

function FrontEnd:UpdateConsoleOutput()
    local consolestr = table.concat(GetConsoleOutputList(), "\n") 
    consolestr = consolestr.."\n(Press CTRL+L to close this log)"
   	self.consoletext:SetString(consolestr)
end

function FrontEnd:Update(dt)

	if self.saving_indicator.shown then


		if self.save_indicator_fade then
			local alpha = 1
			self.save_indicator_fade_time = self.save_indicator_fade_time - math.min(dt, 1/60)

			if self.save_indicator_fade_time < 0 then
				if self.save_indicator_fade == "in" then
					alpha = 1
				else
					alpha = 0
					self.saving_indicator:ForceStopWallUpdating()
					self.saving_indicator:Hide()
				end
				self.save_indicator_fade = nil
			else
				if self.save_indicator_fade == "in" then
					alpha = math.max(0, 1 - self.save_indicator_fade_time/save_fade_time)
				elseif self.save_indicator_fade == "out" then
					alpha = math.min(1,self.save_indicator_fade_time/save_fade_time)
				end
			end
			self.saving_indicator:GetAnimState():SetMultColour(1,1,1,alpha)
		else
			self.save_indicator_time_left = self.save_indicator_time_left - dt
			if self.num_pending_saves <= 0 and self.save_indicator_time_left <= 0 then
				self.save_indicator_fade = "out"
				self.save_indicator_fade_time = save_fade_time
			end
		end

	end

	if self.consoletext.shown then
		self:UpdateConsoleOutput()
	end

	self:DoFadingUpdate(dt)
	self:DoTitleFade(dt)
	
	if #self.screenstack > 0 then
		self.screenstack[#self.screenstack]:OnUpdate(dt)
		--if(self.screenstack[#self.screenstack].name ~= "HUD") then
		--	self.tracking_mouse = false
		--end
	end	

	if self.repeat_time > 0 then
		self.repeat_time = self.repeat_time - dt
	end

	if TheInput:IsControlPressed(CONTROL_PREVVALUE) or
		TheInput:IsControlPressed(CONTROL_NEXTVALUE) or
		TheInput:IsControlPressed(CONTROL_PAGELEFT) or
		TheInput:IsControlPressed(CONTROL_PAGERIGHT) then
		self.page_repeat_time = self.page_repeat_time - dt
	else
		self.page_repeat_time = PAGE_REPEAT_TIME
	end

	if self.page_repeat_time <= 0 then
		self.page_repeat_time = PAGE_REPEAT_TIME
		if TheInput:IsControlPressed(CONTROL_PREVVALUE) then
			self:OnControl(CONTROL_PREVVALUE, false, true)
			self.ignoreups[CONTROL_PREVVALUE] = true
		elseif TheInput:IsControlPressed(CONTROL_NEXTVALUE) then
			self:OnControl(CONTROL_NEXTVALUE, false, true)
			self.ignoreups[CONTROL_NEXTVALUE] = true
		elseif TheInput:IsControlPressed(CONTROL_PAGELEFT) then
			self:OnControl(CONTROL_PAGELEFT, false, true)
			self.ignoreups[CONTROL_PAGELEFT] = true
		elseif TheInput:IsControlPressed(CONTROL_PAGERIGHT) then
			self:OnControl(CONTROL_PAGERIGHT, false, true)
			self.ignoreups[CONTROL_PAGERIGHT] = true
		end
	end
	
	if self.repeat_time <= 0 then
		self.repeat_time = REPEAT_TIME
		if TheInput:IsControlPressed(CONTROL_MOVE_LEFT) or TheInput:IsControlPressed(CONTROL_FOCUS_LEFT) then
			self:OnFocusMove(MOVE_LEFT, true)
		elseif TheInput:IsControlPressed(CONTROL_MOVE_RIGHT) or TheInput:IsControlPressed(CONTROL_FOCUS_RIGHT) then
			self:OnFocusMove(MOVE_RIGHT, true)
		elseif TheInput:IsControlPressed(CONTROL_MOVE_UP) or TheInput:IsControlPressed(CONTROL_FOCUS_UP) then
			self:OnFocusMove(MOVE_UP, true)
		elseif TheInput:IsControlPressed(CONTROL_MOVE_DOWN) or TheInput:IsControlPressed(CONTROL_FOCUS_DOWN) then
			self:OnFocusMove(MOVE_DOWN, true)
		else
			self.repeat_time = 0
		end
	end	

	-- [vicent] we actually do this on touch move (we need to avoid auto-focus on touch with new screen)
	-- Only if chromebook
	 if not TheInput:IsZoomHudEnabled() and TheSim:IsLastInputFromMouse() and not self.focus_locked then
	 	self.tracking_mouse = true
	 	local entitiesundermouse = TheInput:GetAllEntitiesUnderMouse()
	 	local hover_inst = entitiesundermouse[1]
	 	if hover_inst and hover_inst.widget then
	 		hover_inst.widget:SetFocus()
	 	else
	 		if #self.screenstack > 0 then
	 			self.screenstack[#self.screenstack]:SetFocus()
	 		end
	 	end
	end
	
	TheSim:ProfilerPush("update widgets")
	if not self.updating_widgets_alt then
		self.updating_widgets_alt = {}
	end

	for k,v in pairs(self.updating_widgets) do
		self.updating_widgets_alt[k] = v
	end
	
	for k,v in pairs(self.updating_widgets_alt) do
		if k.enabled then
			k:OnUpdate(dt)
		end
		self.updating_widgets_alt[k] = nil
	end


	self.helptext:Hide()
	if TheInput:ControllerAttached() then
		local str = self:GetHelpText()
		if str ~= "" then
			self.helptext:Show()
			self.helptexttext:SetString(str)
		end
	end
	
	TheSim:ProfilerPop()




end

function FrontEnd:StartUpdatingWidget(w)
	self.updating_widgets[w] = true
end

function FrontEnd:StopUpdatingWidget(w)
	self.updating_widgets[w] = nil
end


function FrontEnd:PushScreen(screen)
	self.focus_locked = false
	TheInputProxy:FlushInput()
	
	--self.tracking_mouse = false
	--jcheng: don't allow any other screens to push if we're displaying an error
	
	if not TheFrontEnd:IsDisplayingError() then
		Print(VERBOSITY.DEBUG, 'FrontEnd:PushScreen', screen.name)
		if #self.screenstack > 0 then
			self.screenstack[#self.screenstack]:OnBecomeInactive()
		end

		self.screenroot:AddChild(screen)
		table.insert(self.screenstack, screen)
		
		if not self.tracking_mouse then
			screen:SetDefaultFocus()
		end
		screen:OnBecomeActive()
		self:Update(0)

		--print("FOCUS IS", screen:GetDeepestFocus(), self.tracking_mouse)
		--self:Fade(true, 2)
	end
end

function FrontEnd:ClearScreens()

	if #self.screenstack > 0 then
		self.screenstack[#self.screenstack]:OnLoseFocus()
	end

	while #self.screenstack > 0 do
		self.screenstack[#self.screenstack]:OnDestroy()
		table.remove(self.screenstack, #self.screenstack)
	end

end

function FrontEnd:ShowConsoleLog()
	self.consoletext:Show()
end

function FrontEnd:HideConsoleLog()
	self.consoletext:Hide()
end

function FrontEnd:DoFadeIn(time_to_take)
	self:Fade(true, time_to_take)	
end

function FrontEnd:Fade(in_or_out, time_to_take, cb, fade_delay_time, delayovercb)
	
	self.fadedir = in_or_out
	self.total_fade_time = time_to_take
	self.fadecb = cb
	self.fade_time = 0
	if in_or_out then
		self:SetFadeLevel(1)
	else
		-- starting a fade out, make the top fade visible again
		-- this place it can actually be out of sync with the backfade, so make it full trans
		self.topblackoverlay:SetTint(0,0,0,0)
		self:ShowTopFade()
	end
	self.fade_delay_time = fade_delay_time
	self.delayovercb = delayovercb
end

function FrontEnd:PopScreen(screen)
	self.focus_locked = false
	TheInputProxy:FlushInput()
	--self.tracking_mouse = false

	local old_head = #self.screenstack > 0 and self.screenstack[#self.screenstack]
	if screen then
		Print(VERBOSITY.DEBUG,'FrontEnd:PopScreen', screen.name)
		for k,v in ipairs(self.screenstack) do
			if v == screen then
				if old_head == v then 
					screen:OnBecomeInactive()
				end
				table.remove(self.screenstack, k)
				screen:OnDestroy()
				self.screenroot:RemoveChild(screen)
				break
			end
		end
	else
		Print(VERBOSITY.DEBUG,'FrontEnd:PopScreen')
		if #self.screenstack > 0 then
			local screen = self.screenstack[#self.screenstack]
			table.remove(self.screenstack, #self.screenstack)
			screen:OnBecomeInactive()
			screen:OnDestroy()
			self.screenroot:RemoveChild(screen)
		end
		
	end

	if #self.screenstack > 0 and old_head ~= self.screenstack[#self.screenstack] then
		self.screenstack[#self.screenstack]:SetFocus()
		self.screenstack[#self.screenstack]:OnBecomeActive()
		self:Update(0)
		--print ("POP!", self.screenstack[#self.screenstack]:GetDeepestFocus(), self.tracking_mouse)
		--self:Fade(true, 1)
	end
end

function FrontEnd:DefaultFocusForController()
	if not self.tracking_mouse then
		self.screenstack[#self.screenstack]:SetDefaultFocus()
	end
end



function FrontEnd:ManageAndroidBack()
	self.focus_locked = false
	TheInputProxy:FlushInput()
	--self.tracking_mouse = false

	--print("ManageAndroidBack")
	
	local DoneSomething = false
	
	if inGamePlay then
		DoneSomething = true --ingame, back always does something
		--print("ManageAndroidBack - in gameplay")
		if (#self.screenstack > 2) then
			--noting to do here
		elseif (#self.screenstack == 2) then --we are either on the pause menu, deathscreen, maxwell's door pop-up, or watching the map
			--print("ManageAndroidBack - stack == 2")
			if(inDeathScreen) then
				self.screenstack[#self.screenstack]:OnMenu()
			elseif(inMaxwellDoorPopUp) then
				inMaxwellDoorPopUp = false
				TheFrontEnd:PopScreen()
				SetPause(false) 
				inMaxwellDoorPopUp_inst.components.activatable.inactive = true
				ProfileStatsSet("portal_rejected", true)
				inMaxwellDoorPopUp_inst = nil
			elseif IsPaused() then
				SetPause(false)
				--print("ManageAndroidBack - quit pause!")
			end
			-- if in the map, then just go to removing the screen form the stack
		elseif(self.screenstack[#self.screenstack]:IsPhoneControllerCraftingOpen()) then
			--print("crafting was open!")
			self.screenstack[#self.screenstack]:ClosePhoneCrafting()
		elseif(self.screenstack[#self.screenstack]:IsPhoneControllerInventoryOpen()) then
			--print("inventory was open!")
			self.screenstack[#self.screenstack]:ClosePhoneInventory()	
		elseif(not IsPaused()) then
			--print("ManageAndroidBack - pause the game!")
			local PauseScreen = require "screens/pausescreen"
			TheFrontEnd:PushScreen(PauseScreen())
			return --pausing, so skip removing stuff from the stack 
		end
		--print(#self.screenstack)
		
	--else
		--print("ManageAndroidBack - NOT inGamePlay")
	end
	
	--modified code from PopScreen
	local old_head = #self.screenstack > 0 and self.screenstack[#self.screenstack]
	
	--print("ManageAndroidBack - ELSE if (screen)")
	Print(VERBOSITY.DEBUG,'FrontEnd:PopScreen')
	if #self.screenstack > 1 then --never remove the last element on the stack!
		--print("ManageAndroidBack - ELSE if (screen) - > 0")
		local screen = self.screenstack[#self.screenstack]
		table.remove(self.screenstack, #self.screenstack)
		screen:OnBecomeInactive()
		screen:OnDestroy()
		self.screenroot:RemoveChild(screen)
		DoneSomething = true
	else
		--print("ManageAndroidBack - ELSE if (screen) - NOT > 1")
		if(inOptions) then
			--print("ManageAndroidBack - inOptions == true")
			self.screenstack[#self.screenstack]:MainMenu()
			DoneSomething = true
		end
	end

	if #self.screenstack > 0 and old_head ~= self.screenstack[#self.screenstack] then
		self.screenstack[#self.screenstack]:SetFocus()
		self.screenstack[#self.screenstack]:OnBecomeActive()
		--print("ManageAndroidBack - > 0 & no se que mes")
		self:Update(0)
		--print ("POP!", self.screenstack[#self.screenstack]:GetDeepestFocus(), self.tracking_mouse)
		--self:Fade(true, 1)
	--else
		--print("ManageAndroidBack 6")
	end
	
	if not DoneSomething then
		--print("ManageAndroidBack -- DoAndroidDefaultBack")
		TheSim:DoAndroidDefaultBack()
	end
end




function FrontEnd:ClearFocus()
	if #self.screenstack > 0 then
		self.screenstack[#self.screenstack]:SetFocus()
	end
end

function FrontEnd:GetActiveScreen()
	if #self.screenstack > 0 and self.screenstack[#self.screenstack] then
		return self.screenstack[#self.screenstack]
	else
		return nil
	end
end

function FrontEnd:ShowScreen(screen)
	self:ClearScreens()	
	if screen then
		self:PushScreen(screen)
	end
end

function FrontEnd:OnRawKey(key, down)
	local screen = self:GetActiveScreen()
    if screen then
		if not screen:OnRawKey(key, down) then
			if PLATFORM ~= "NACL" and CHEATS_ENABLED then
				DoDebugKey(key, down)
			end
		end
	end
end

function FrontEnd:OnTextInput(text)
	local screen = self:GetActiveScreen()
    if screen then
		screen:OnTextInput(text)
	end
end

function FrontEnd:DisplayError(screen)
	if self.displayingerror == false then
	    print("SCRIPT ERROR! Showing error screen")
		
		self:ShowScreen(screen)
		self.overlayroot:Hide()
		self.consoletext:Hide()
		self.blackoverlay:Hide()
		self.title:Hide()
		self.subtitle:Hide()
		
		self.displayingerror = true
	end
end

function FrontEnd:GetHUDScale()
	
	local size = Profile:GetHUDSize()
	local min_scale = .75
	local max_scale = 1.1
	local max_hud_size = 10

	if PLATFORM == "Android" then
		if IPHONE_VERSION then
			min_scale = 1.0
			max_scale = 1.425
			max_hud_size = 5
		end
	elseif PLATFORM == "iOS" then
        if not IPHONE_VERSION and (TheSim:IsiPad3() or TheSim:IsUnsupportedDevice()) then
			min_scale = 1.0
			max_scale = 1.2
			max_hud_size = 5
		else
			min_scale = 1.0
			max_scale = 1.425
			max_hud_size = 5
        end
    end
	
	--testing high res displays
	local w,h = TheSim:GetScreenSize()
	
	local res_scale_x = math.max(1, w / 1920)
	local res_scale_y = math.max(1, h / 1200)
	local res_scale = math.min(res_scale_x, res_scale_y)	
	
	local scale = easing.linear(size, min_scale, max_scale-min_scale, max_hud_size) * res_scale
	return scale
end

function FrontEnd:IsDisplayingError()
	return self.displayingerror
end

function FrontEnd:OnMouseButton(button, down, x, y)
	self.tracking_mouse = true

	if #self.screenstack > 0 then
		if self.screenstack[#self.screenstack]:OnMouseButton(button, down, x, y) then return true end
	end

	--if BRANCH ~= "release" and PLATFORM ~= "NACL" and CHEATS_ENABLED then
	--	return DoDebugMouse(button, down, x, y)
	--end
end

function FrontEnd:OnMouseMove(x,y)

	if self.lastx and self.lasty and self.lastx ~= x and self.lasty ~= y then
		self.tracking_mouse = true
	end

	self.lastx = x
	self.lasty = y
end

function FrontEnd:UpdateFocus()

    if GetPlayer() then
        local hover = GetPlayer().HUD.controls.hover
        if(hover.inMenu) then
            return
        end
    end

	local entitiesundermouse = TheInput:GetAllEntitiesUnderMouse()

	local hover_inst = entitiesundermouse[1]

	if hover_inst and hover_inst.widget then
		if not hover_inst.focus then
			hover_inst.widget:SetFocus()
		end
        return true;
	else
		if #self.screenstack > 0 then
            self.screenstack[#self.screenstack]:ClearFocus()
			self.screenstack[#self.screenstack]:SetFocus()
		end
	end
end

function FrontEnd:OnTouchStart(id, x, y)

    self.touchframecount = 0

    self.tracking_mouse = true

    if GetPlayer() then
        local hover = GetPlayer().HUD.controls.hover
        if(hover.inMenu) then
            if hover.onTouchEnd == true then
                hover.onTouchEnd = false
            end
            hover:UpdateHighlightedActions(x, y)
            return
        elseif not self.tracking_mouse then
            self.tracking_mouse = true
            self.touchwidget[id] = nil
        end
    end

	if self.touchwidget[id] == nil then
		self:UpdateFocus();	-- Make sure the proper elements are focused
		if #self.screenstack > 0 then
			self.touchwidget[id] = self.screenstack[#self.screenstack]:OnTouchStart(id, x, y)
			if self.touchwidget[id] ~= nil then
				self:OnControl(CONTROL_PRIMARY, true)	-- Simulate a click 'down'
			end
		end
	end

	

	return self.touchwidget[id]
end

function FrontEnd:OnTouchMove(id, x, y)

    if GetPlayer() then
        local hover = GetPlayer().HUD.controls.hover
        if(hover.inMenu)then
            hover:UpdateHighlightedActions(x, y)
            return
        end
    end

	if self.touchwidget[id] ~= nil then
        -- the UpdateFocus() is very expensive, avoid do it per frame in slow devices
		if PLATFORM == "iOS" then
			if TheSim:IsUnsupportedDevice() then
				if self.touchframecount > 5 then
					self.touchframecount = 0
				else
					self.touchframecount = self.touchframecount + 1
				return
				end
			end
		end

		if GetPlayer() and GetPlayer().components.playercontroller.draggingonground then
			return
		end
			
		local before = self.touchwidget[id].focus

		local focused = self:UpdateFocus();	-- Make sure the proper elements are focused
		
		-- If the touchwidget isn't focused, then NOBODY gets focus!
		if not self.touchwidget[id].focus and #self.screenstack > 0 and not focused then
			self.screenstack[#self.screenstack]:SetFocus()
		end

		if self.touchwidget[id].focus and not before then
			self:OnControl(CONTROL_PRIMARY, true)	-- Simulate a click 'down'
		end

		self.touchwidget[id]:OnTouchMove(id, x, y)
	end

end

function FrontEnd:OnTouchEnd(id)

    local player = GetPlayer()
    if player then
        local hover = player.HUD.controls.hover
        if hover.inMenu then
            hover:DoMenu()
            hover:EndMenu()
            return
        end
    end

	if self.touchwidget[id] ~= nil then
		if self.touchwidget[id]:OnTouchEnd(id) then
			if self.touchwidget[id].focus then
				self.touchwidget[id]:ClearFocus()
			end
		else
			self:OnControl(CONTROL_PRIMARY, false)	-- Simulate a click 'up'
		end
	end


	self.touchwidget[id] = nil
	if #self.screenstack > 0 then
		if(self.screenstack[#self.screenstack].name ~= "HUD") then
			self:ClearFocus()
		end
	end

end

function FrontEnd:OnTouchCancel(id)
	if self.touchwidget[id] ~= nil then
		self.touchwidget[id]:OnTouchCancel(id)
		self.touchwidget[id]:ClearFocus()
	end
	self.touchwidget[id] = nil
end

function FrontEnd:OnGesture(gesture, value, velocity, state, x0, y0, x1, y1)
	if #self.screenstack > 0 then
		self.screenstack[#self.screenstack]:OnGesture(gesture, value, velocity, state, x0, y0, x1, y1)
	end
end

function FrontEnd:OnTapGesture(gesture, x, y)
	if #self.screenstack > 0 then
		local screen = self.screenstack[#self.screenstack]
		if screen:OnTapGesture(gesture, x, y) then 
			return true 
		end
	end


	if DEBUG_MENU_ENABLED and gesture == TAP_GESTURE_3_FINGERS then
		self:PushScreen(DebugMenuScreen())
		return true
	end
end

function FrontEnd:OnSaveLoadError(operation, filename, status)
    --print("OnSaveLoadError", operation, filename, status)
    
    TheFrontEnd:HideSavingIndicator() -- in case it's still being shown for some reason
                
    local function retry()  
        TheFrontEnd:PopScreen() -- saveload error message box
        if operation == SAVELOAD.OPERATION.LOAD then
            
            local function OnSaveGameIndexLoaded(success)
                --print("OnSaveGameIndexLoaded", success)
            end     
            
            local function OnProfileLoaded(success)
                --print("OnProfileLoaded", success)
                if success then
                    SaveGameIndex:Load(OnSaveGameIndexLoaded)
                end
            end
                               
            local function OnMorgueLoaded(success)
                --print("OnMorgueloaded", success)
                if success then
                    Profile:Load(OnProfileLoaded)
                end
            end
            
            Morgue:Load(OnMorgueLoaded)
            
        elseif operation == SAVELOAD.OPERATION.SAVE then
            -- the system service knows which files are not saved and will try to save them
            TheFrontEnd:ShowSavingIndicator()
            TheSystemService:RetryOperation(operation, filename)
        elseif operation == SAVELOAD.OPERATION.DELETE then
            TheSystemService:RetryOperation(operation, filename)
        end            
    end
                        
    if status == SAVELOAD.STATUS.DAMAGED then         
        print("OnSaveLoadError", "Damaged save data popup")
        local function overwrite()   
            local function on_overwritten(success)
                TheFrontEnd:HideSavingIndicator() 
                TheSystemService:EnableAutosave(success)
            end
            
            -- OverwriteStorage will also try to resave any files found in the cache
            TheFrontEnd:ShowSavingIndicator()
            TheSystemService:OverwriteStorage(on_overwritten)
            TheFrontEnd:PopScreen() -- saveload error message box
        end
        
        local function cancel()
            TheSystemService:EnableStorage(TheSystemService:IsAutosaveEnabled())            
            TheSystemService:ClearLastOperation()        
            TheFrontEnd:PopScreen() -- saveload error message box
        end
        
        local function confirm_autosave_disable()   
               
            local function disable_autosave()
                TheSystemService:EnableStorage(false)            
                TheSystemService:EnableAutosave(false)    
                TheSystemService:ClearLastOperation()        
                TheFrontEnd:PopScreen() -- confirmation message box
                TheFrontEnd:PopScreen() -- saveload error message box
            end
            
            local function dont_disable()
                TheFrontEnd:PopScreen() -- confirmation message box
            end
            
            local confirmation = PopupDialogScreen(STRINGS.UI.SAVELOAD.DISABLE_AUTOSAVE, "",
	            {
	                {text=STRINGS.UI.SAVELOAD.YES, cb = disable_autosave},
	                {text=STRINGS.UI.SAVELOAD.NO, cb = dont_disable}  
	            }
	        )
	        confirmation.title:SetPosition(0, 40, 0)
            self:PushScreen(confirmation) 
        end
        
        local cancel_cb = cancel
        if TheSystemService:IsAutosaveEnabled() then
            cancel_cb = confirm_autosave_disable
        end
        
        local popup = PopupDialogScreen(STRINGS.UI.SAVELOAD.DATA_DAMAGED, "", 
	        {
	            {text=STRINGS.UI.SAVELOAD.RETRY, cb = retry},
	            {text=STRINGS.UI.SAVELOAD.OVERWRITE, cb = overwrite},
	            {text=STRINGS.UI.SAVELOAD.CANCEL, cb = cancel_cb}  
	        }
	    )	  
        self:PushScreen(popup) 
        
    elseif status == SAVELOAD.STATUS.FAILED then
                
        local function cancel()  
            TheSystemService:ClearLastOperation()        
            TheFrontEnd:PopScreen() -- saveload error message box
        end
    
        local text
        if operation == SAVELOAD.OPERATION.LOAD then
            text = STRINGS.UI.SAVELOAD.LOAD_FAILED
        elseif operation == SAVELOAD.OPERATION.SAVE then
            text = STRINGS.UI.SAVELOAD.SAVE_FAILED
        elseif operation == SAVELOAD.OPERATION.DELETE then
            text = STRINGS.UI.SAVELOAD.DELETE_FAILED
        end
        
        local popup = PopupDialogScreen(text, "",
	        {
	            {text=STRINGS.UI.SAVELOAD.RETRY, cb = retry},
	            {text=STRINGS.UI.SAVELOAD.CANCEL, cb = cancel}  
	        }
	    )
        self:PushScreen(popup) 
    end    
end

function OnSaveLoadError(operation, filename, status)
    TheFrontEnd:OnSaveLoadError(operation, filename, status)
end