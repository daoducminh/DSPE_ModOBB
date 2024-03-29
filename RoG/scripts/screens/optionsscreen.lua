require "util"
require "strings"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Spinner = require "widgets/spinner"
local NumericSpinner = require "widgets/numericspinner"
local Widget = require "widgets/widget"

local PopupDialogScreen = require "screens/popupdialog"


local show_graphics = PLATFORM ~= "NACL" and PLATFORM ~= "iOS" and PLATFORM ~= "Android"
local text_font = UIFONT--NUMBERFONT

local enableDisableOptions = { { text = STRINGS.UI.OPTIONS.DISABLED, data = false }, { text = STRINGS.UI.OPTIONS.ENABLED, data = true } }
local spinnerFont = { font = BUTTONFONT, size = 30 }

local function GetResolutionString( w, h )
	--return string.format( "%dx%d @ %dHz", w, h, hz )
	return string.format( "%d x %d", w, h )
end

local function SortKey( data )
	local key = data.w * 16777216 + data.h * 65536-- + data.hz
	return key 
end

local function ValidResolutionSorter( a, b )
	return SortKey( a.data ) < SortKey( b.data )
end

local function GetDisplays()
	local gOpts = TheFrontEnd:GetGraphicsOptions()
	local num_displays = gOpts:GetNumDisplays()
	local displays = {}
	for i = 0, num_displays - 1 do
		local display_name = gOpts:GetDisplayName( i )
		table.insert( displays, { text = display_name, data = i } )
	end
	
	return displays
end

local function GetRefreshRates( display_id, mode_idx )
	local gOpts = TheFrontEnd:GetGraphicsOptions()
	
	local w, h, hz = gOpts:GetDisplayMode( display_id, mode_idx )
	local num_refresh_rates = gOpts:GetNumRefreshRates( display_id, w, h )
	
	local refresh_rates = {}
	for i = 0, num_refresh_rates - 1 do
		local refresh_rate = gOpts:GetRefreshRate( display_id, w, h, i )
		table.insert( refresh_rates, { text = string.format( "%d", refresh_rate ), data = refresh_rate } )
	end
	
	return refresh_rates
end


local function GetDisplayModes( display_id )
	local gOpts = TheFrontEnd:GetGraphicsOptions()
	local num_modes = gOpts:GetNumDisplayModes( display_id )
	
	local res_data = {}
	for i = 0, num_modes - 1 do
		local w, h, hz = gOpts:GetDisplayMode( display_id, i )
		local res_str = GetResolutionString( w, h )
		res_data[ res_str ] = { w = w, h = h, hz = hz, idx = i }
	end

	local valid_resolutions = {}
	for res_str, data in pairs( res_data ) do
		table.insert( valid_resolutions, { text = res_str, data = data } )
	end

	table.sort( valid_resolutions, ValidResolutionSorter )

	local result = {}
	for k, v in pairs( valid_resolutions ) do
		table.insert( result, { text = v.text, data = v.data } )
	end

	return result
end

local function GetDisplayModeIdx( display_id, w, h, hz )
	local gOpts = TheFrontEnd:GetGraphicsOptions()
	local num_modes = gOpts:GetNumDisplayModes( display_id )
	
	for i = 0, num_modes - 1 do
		local tw, th, thz = gOpts:GetDisplayMode( display_id, i )
		if tw == w and th == h and thz == hz then
			return i
		end
	end
	
	return nil
end

local function GetDisplayModeInfo( display_id, mode_idx )
	local gOpts = TheFrontEnd:GetGraphicsOptions()
	local w, h, hz = gOpts:GetDisplayMode( display_id, mode_idx )

	return w, h, hz
end

local OptionsScreen = Class(Screen, function(self, in_game)
	Screen._ctor(self, "OptionsScreen")
	self.in_game = in_game
	--TheFrontEnd:DoFadeIn(2)

	local graphicsOptions = TheFrontEnd:GetGraphicsOptions()

	self.options = {
		fxvolume = TheMixer:GetLevel( "set_sfx" ) * 10,
		musicvolume = TheMixer:GetLevel( "set_music" ) * 10,
		ambientvolume = TheMixer:GetLevel( "set_ambience" ) * 10,
		bloom = graphicsOptions:IsBloomEnabled(),
		smalltextures = graphicsOptions:IsSmallTexturesMode(),
		distortion = graphicsOptions:IsDistortionEnabled(),
		screenshake = Profile:IsScreenShakeEnabled(),
		hudSize = Profile:GetHUDSize(),
		netbookmode = TheSim:IsNetbookMode(),
		vibration = Profile:GetVibrationEnabled(),
		--sendstats = Profile:GetSendStatsEnabled(),
	}

	self.closebutton = nil
	self.applybutton = nil
	self.cancelbutton = nil

	if IsDLCInstalled(REIGN_OF_GIANTS) then
		self.options.wathgrithrfont = Profile:IsWathgrithrFontEnabled()
	end

	if PLATFORM == "iOS" or PLATFORM == "Android" then
		if not self.in_game and not PLATFORM == "Android" then
			self.options.enableiCloud = TheSim:IsiCloudEnabled()
		else
			self.options.gamma = Profile:GetGamma()
            self.options.actionButtons = Profile:GetActionButtonsEnabled()
            if TheInput:IsZoomHudEnabled() then
                  self.options.virtualStick = Profile:GetVirtualStickEnabled()
            else
                  self.options.virtualStick = TheSim:GetSetting("graphics", "virtualstick") == "true"
            end
            self.options.HD = Profile:GetHD() == "true"
            self.options.recordButtons = Profile:GetRecordButtonsEnabled()
		end
	end

	--[[if PLATFORM == "WIN32_STEAM" and not self.in_game then
		self.options.steamcloud = TheSim:GetSetting("STEAM", "DISABLECLOUD") ~= "true"
	end--]]

	if show_graphics then

		self.options.display = graphicsOptions:GetFullscreenDisplayID()
		self.options.refreshrate = graphicsOptions:GetFullscreenDisplayRefreshRate()
		self.options.fullscreen = graphicsOptions:IsFullScreen()
		self.options.mode_idx = graphicsOptions:GetCurrentDisplayModeID( self.options.display )
	end

	self.working = deepcopy( self.options )
	
	
	self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))

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
    self.title:SetString(STRINGS.UI.MAINSCREEN.SETTINGS)

    local spacing = -80
    if IPHONE_VERSION then
    	spacing = -60
    end
	self.menu = self.root:AddChild(Menu(nil, spacing, false))
	if IsDLCEnabled(REIGN_OF_GIANTS) then
		if show_graphics then
			self.menu:SetPosition(260, -220 ,0)
		else
            if self.in_game and TheSim:SupportsRecording() then
                if IPHONE_VERSION then
                    self.menu:SetPosition(310, -310 ,0)
                else
                    self.menu:SetPosition(260, -380 ,0)
                end
            else
                if IPHONE_VERSION then
                    self.menu:SetPosition(310, -230 ,0)
                else
                    self.menu:SetPosition(260, -235 ,0)
                end
            end
		end
		self.title:SetPosition(0, 190, 0)
	else
		if show_graphics then
			self.menu:SetPosition(260, -235 ,0)
		else
            if self.in_game and TheSim:SupportsRecording() then
                if IPHONE_VERSION then
                    self.menu:SetPosition(310, -310 ,0)
                else
                    self.menu:SetPosition(260, -380 ,0)
                end
            else
                if IPHONE_VERSION then
                    self.menu:SetPosition(310, -230 ,0)
                else
                    self.menu:SetPosition(260, -205 ,0)
                end
            end
        end
		self.title:SetPosition(0, 190, 0)
	end

    if IPHONE_VERSION then
        self.title:SetPosition(0, 210, 0)
        self.menu:SetScale(1.3)
    else
        self.menu:SetScale(1)
    end

	self.grid = self.root:AddChild(Grid())

	if show_graphics then
		self.grid:InitSize(2, 9, 400, -63)
	else
        if IPHONE_VERSION then
            self.grid:InitSize(2, 6, 360, -60)
        else
            self.grid:InitSize(2, 5, 400, -83)
        end
	end

	if IsDLCEnabled(REIGN_OF_GIANTS) then
		if show_graphics then
			self.grid:SetPosition(-250, 210, 0)
		else
			self.grid:SetPosition(-210, 110, 0)
		end
	else
		if show_graphics then
			self.grid:SetPosition(-250, 195, 0)
		else
			self.grid:SetPosition(-210, 110, 0)
		end
	end

    if IPHONE_VERSION then
        self.grid:SetPosition(-220, 130, 0)
    end

	if show_graphics then
        if IsDLCEnabled(REIGN_OF_GIANTS) then
            self.grid:SetScale(1,.9)
        else
            self.grid:SetScale(1,.9)
        end
    else
        if IPHONE_VERSION then
            self.grid:SetScale(1.2)
        end
	end

	self:DoInit()
	self:InitializeSpinners()

	self.default_focus = self.grid

end)


function OptionsScreen:OnControl(control, down)
    if OptionsScreen._base.OnControl(self, control, down) then return true end
    
    if not down then
	    if control == CONTROL_CANCEL then
			if self:IsDirty() then
				self:ConfirmRevert() --revert and go back, or stay
			else
				self:Back() --just go back
			end
			return true
	    elseif control == CONTROL_ACCEPT and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
	    	if self:IsDirty() then
	    		self:ApplyChanges() --apply changes and go back, or stay
	    	end
	    end
	end
end


function OptionsScreen:ApplyChanges()
	if self:IsDirty() then
		if self:IsGraphicsDirty() then
			self:ConfirmGraphicsChanges()
		else
			self:ConfirmApply()
		end
	end
end


function OptionsScreen:Back()
	TheFrontEnd:PopScreen()					
end

function OptionsScreen:ConfirmRevert()

	TheFrontEnd:PushScreen(
		PopupDialogScreen( STRINGS.UI.OPTIONS.BACKTITLE, STRINGS.UI.OPTIONS.BACKBODY,
		  { 
		  	{ 
		  		text = STRINGS.UI.OPTIONS.YES, 
		  		cb = function()
					self:RevertChanges()
					TheFrontEnd:PopScreen()
					self:Back()
				end
			},
			
			{ 
				text = STRINGS.UI.OPTIONS.NO, 
				cb = function()
					TheFrontEnd:PopScreen()					
				end
			}
		  }
		)
	)		
end

function OptionsScreen:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()
	if self:IsDirty() then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.APPLY)
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
	else
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
	end
	return table.concat(t, "  ")
end


function OptionsScreen:Accept()
	self:Save(function() self:Close() end )
end

function OptionsScreen:Save(cb)
	self.options = deepcopy( self.working )

	Profile:SetVolume( self.options.ambientvolume, self.options.fxvolume, self.options.musicvolume )
--	Profile:SetBloomEnabled( self.options.bloom )
--	Profile:SetDistortionEnabled( self.options.distortion )
	Profile:SetScreenShakeEnabled( self.options.screenshake )
	if IsDLCInstalled(REIGN_OF_GIANTS) then Profile:SetWathgrithrFontEnabled( self.options.wathgrithrfont ) end
	Profile:SetHUDSize( self.options.hudSize )
--	Profile:SetVibrationEnabled( self.options.vibration )
--	Profile:SetSendStatsEnabled( self.options.sendstats )
	if PLATFORM == "iOS" or PLATFORM == "Android" then
		if not self.in_game and not PLATFORM == "Android" then
			TheSim:SetiCloudEnabled(self.options.enableiCloud)
		else
			Profile:SetGamma( self.options.gamma )
			TheSim:SetGamma(self.options.gamma)
            if (Profile:GetHD() == 'true' and not self.options.HD) or (Profile:GetHD() ~= 'true' and self.options.HD) then
            	self.hd_changed = true
            end
			Profile:SetHD( self.options.HD )
			TheSim:SetHDGraphics(self.options.HD)
            Profile:SetActionButtonsEnabled(self.options.actionButtons)
            Profile:SetVirtualStickEnabled(self.options.virtualStick)
            Profile:SetRecordButtonsEnabled(self.options.recordButtons)
		end
	end
	Profile:Save( function() if cb then cb() end end, true)
	if self.hd_changed then
		--TheSim:ChangeHDDialog(STRINGS.UI.OPTIONS.HD, STRINGS.UI.OPTIONS.HDPOPUP);
	end
	self.hd_changed = false
end

function OptionsScreen:RevertChanges()
	self.working = deepcopy( self.options )
	self:Apply()
	self:InitializeSpinners()
	self:UpdateMenu()							
end

function OptionsScreen:IsDirty()
	for k,v in pairs(self.working) do
		if v ~= self.options[k] then
			return true	
		end
	end
	return false
end

function OptionsScreen:IsGraphicsDirty()
	return self.working.display ~= self.options.display or
		self.working.w ~= self.options.w or
		self.working.h ~= self.options.h or
		self.working.fullscreen ~= self.options.fullscreen
end

function OptionsScreen:ChangeGraphicsMode()
	if show_graphics then
		local gOpts = TheFrontEnd:GetGraphicsOptions()
		local w, h, hz = gOpts:GetDisplayMode( self.working.display, self.working.mode_idx )
		local mode_idx = GetDisplayModeIdx( self.working.display, w, h, self.working.refreshrate) or 0
		gOpts:SetDisplayMode( self.working.display, mode_idx, self.working.fullscreen )
	end

end

function OptionsScreen:ConfirmGraphicsChanges(fn)

	if not self.applying then
		self:ChangeGraphicsMode()

		TheFrontEnd:PushScreen(
			PopupDialogScreen( STRINGS.UI.OPTIONS.ACCEPTGRAPHICSTITLE, STRINGS.UI.OPTIONS.ACCEPTGRAPHICSBODY,
			  { { text = STRINGS.UI.OPTIONS.ACCEPT, cb =
					function()

						self:Apply()
						self:Save(
							function() 
								self.applying = false
								self:UpdateMenu()
								TheFrontEnd:PopScreen()
							end)
					end
				},
				{ text = STRINGS.UI.OPTIONS.CANCEL, cb =
					function()
						self.applying = false
						self:RevertChanges()
						self:ChangeGraphicsMode()
						TheFrontEnd:PopScreen()					
					end
				}
			  },
			  { timeout = 10, cb =
				function()
					self.applying = false
					self:RevertChanges()
					self:ChangeGraphicsMode()
					TheFrontEnd:PopScreen()
				end
			  }
			)
		)
	end


end

function OptionsScreen:ConfirmApply( )
	
	TheFrontEnd:PushScreen(
		PopupDialogScreen( STRINGS.UI.OPTIONS.ACCEPTTITLE, STRINGS.UI.OPTIONS.ACCEPTBODY,
		  { 
		  	{ 
		  		text = STRINGS.UI.OPTIONS.ACCEPT, 
		  		cb = function()
					self:Apply()
					self:Save(function() TheFrontEnd:PopScreen() self:Back() end)
				end
			},
			
			{ 
				text = STRINGS.UI.OPTIONS.CANCEL, 
				cb = function()
					TheFrontEnd:PopScreen()					
				end
			}
		  }
		)
	)	
end



function OptionsScreen:ApplyVolume()
	TheMixer:SetLevel("set_sfx", self.working.fxvolume / 10 )
	TheMixer:SetLevel("set_music", self.working.musicvolume / 10 )
	TheMixer:SetLevel("set_ambience", self.working.ambientvolume / 10 )
end

function OptionsScreen:Apply( )
	self:ApplyVolume()
	
--	TheInputProxy:EnableVibration(self.working.vibration)
	
	local gopts = TheFrontEnd:GetGraphicsOptions()
--	gopts:SetBloomEnabled( self.working.bloom )
--	gopts:SetDistortionEnabled( self.working.distortion )
	gopts:SetSmallTexturesMode( self.working.smalltextures )
	Profile:SetScreenShakeEnabled( self.working.screenshake )
--	Profile:SetSendStatsEnabled( self.working.sendstats )
	if PLATFORM == "iOS" or PLATFORM == "Android" then
		if not self.in_game and not PLATFORM == "Android" then
			TheSim:SetiCloudEnabled(self.working.enableiCloud)
		else
			TheSim:SetGamma(self.working.gamma)
			--TheSim:SetHDGraphics(self.working.HD)
            Profile:SetActionButtonsEnabled( self.working.actionButtons )
            Profile:SetVirtualStickEnabled(self.options.virtualStick)
            Profile:SetHD(self.options.HD)
            Profile:SetRecordButtonsEnabled( self.working.recordButtons )
		end
	end
	if IsDLCInstalled(REIGN_OF_GIANTS) then Profile:SetWathgrithrFontEnabled( self.working.wathgrithrfont ) end
	TheSim:SetNetbookMode(self.working.netbookmode)
end

function OptionsScreen:Close()
	--TheFrontEnd:DoFadeIn(2)
	TheFrontEnd:PopScreen()
end	


local function MakeMenu(offset, menuitems)
	local menu = Widget("OptionsMenu")	
	local pos = Vector3(0,0,0)
	for k,v in ipairs(menuitems) do
		local button = menu:AddChild(ImageButton())
	    button:SetPosition(pos)
	    button:SetText(v.text)
	    button.text:SetColour(0,0,0,1)
	    button:SetOnClick( v.cb )
	    button:SetFont(BUTTONFONT)
	    button:SetTextSize(40)    
	    pos = pos + offset  
	end
	return menu
end

function OptionsScreen:CreateSpinnerGroup( text, spinner )
	local label_width = 220
	spinner:SetTextColour(0,0,0,1)
	local group = Widget( "SpinnerGroup" )
	local label = group:AddChild( Text( BUTTONFONT, 35, text ) )
	label:SetPosition( -label_width/2 + 30, 0, 0 )
	label:SetRegionSize( label_width, 50 )
	label:SetHAlign( ANCHOR_RIGHT )
	spinner:AdjustText()
	group:AddChild( spinner )
	spinner:SetPosition( 125, 0, 0 )
	
	--pass focus down to the spinner
	group.focus_forward = spinner
	return group
end


function OptionsScreen:UpdateMenu()
	self.menu:Clear()
	if TheInput:ControllerAttached() then return end
	if self:IsDirty() then
		if IPHONE_VERSION and not TheSim:SupportsRecording() then
			self.menu.horizontal = false
			self.applybutton = self.menu:AddItem(STRINGS.UI.OPTIONS.APPLY, function() self:ApplyChanges() end, Vector3(0, 0, 0))
			self.cancelbutton = self.menu:AddItem(STRINGS.UI.OPTIONS.REVERT, function() self:RevertChanges() end,  Vector3(0, 0, 0))

			self.applybutton:SetFocusChangeDir(MOVE_UP, self.grid:GetItemInSlot(2,4))
			self.applybutton:SetFocusChangeDir(MOVE_LEFT, self.grid:GetItemInSlot(1,6))
			self.applybutton:SetFocusChangeDir(MOVE_DOWN, self.cancelbutton)

			self.cancelbutton:SetFocusChangeDir(MOVE_UP, self.applybutton)
			self.cancelbutton:SetFocusChangeDir(MOVE_LEFT, self.grid:GetItemInSlot(1,6))

			self.grid:DoFocusOnButton(1,5,MOVE_RIGHT, self.applybutton)
			self.grid:DoFocusOnButton(1,6,MOVE_RIGHT, self.applybutton)
			self.grid:DoFocusOnButton(2,4,MOVE_DOWN, self.applybutton)
		else
			self.menu.horizontal = true
			self.applybutton = self.menu:AddItem(STRINGS.UI.OPTIONS.APPLY, function() self:ApplyChanges() end, Vector3(50, 0, 0))
			self.cancelbutton = self.menu:AddItem(STRINGS.UI.OPTIONS.REVERT, function() self:RevertChanges() end,  Vector3(-50, 0, 0))

			self.applybutton:SetFocusChangeDir(MOVE_UP, self.grid:GetItemInSlot(2,4))
			self.applybutton:SetFocusChangeDir(MOVE_LEFT, self.grid:GetItemInSlot(1,6))
			self.applybutton:SetFocusChangeDir(MOVE_DOWN, self.cancelbutton)

			self.cancelbutton:SetFocusChangeDir(MOVE_UP, self.applybutton)
			self.cancelbutton:SetFocusChangeDir(MOVE_LEFT, self.grid:GetItemInSlot(1,6))

			self.grid:DoFocusOnButton(1,5,MOVE_RIGHT, self.applybutton)
			self.grid:DoFocusOnButton(1,6,MOVE_RIGHT, self.applybutton)
			self.grid:DoFocusOnButton(2,4,MOVE_DOWN, self.applybutton)
		end

	else
		self.menu.horizontal = false
		self.closebutton = self.menu:AddItem(STRINGS.UI.OPTIONS.CLOSE, function() self:Accept() end)

		self.closebutton:SetFocusChangeDir(MOVE_UP, self.grid:GetItemInSlot(2,4))
		self.closebutton:SetFocusChangeDir(MOVE_LEFT, self.grid:GetItemInSlot(1,6))

		self.grid:DoFocusOnButton(1,5,MOVE_RIGHT, self.closebutton)
		self.grid:DoFocusOnButton(1,6,MOVE_RIGHT, self.closebutton)
		self.grid:DoFocusOnButton(2,4,MOVE_DOWN, self.closebutton)
	end
end


function OptionsScreen:DoInit()
	self:UpdateMenu()
	--self.menu:SetScale(.8,.8,.8)

	local this = self
	
	if show_graphics then
		local gOpts = TheFrontEnd:GetGraphicsOptions()
	
		self.fullscreenSpinner = Spinner( enableDisableOptions )
		
		self.fullscreenSpinner.OnChanged =
			function( _, data )
				this.working.fullscreen = data
				this:UpdateResolutionsSpinner()
				self:UpdateMenu()				
			end
		
		if gOpts:IsFullScreenEnabled() then
			self.fullscreenSpinner:Enable()
		else
			self.fullscreenSpinner:Disable()
		end

		local valid_displays = GetDisplays()
		self.displaySpinner = Spinner( valid_displays )
		self.displaySpinner.OnChanged =
			function( _, data )
				this.working.display = data
				this:UpdateResolutionsSpinner()
				this:UpdateRefreshRatesSpinner()
				self:UpdateMenu()
			end
		
		local refresh_rates = GetRefreshRates( self.working.display, self.working.mode_idx )
		self.refreshRateSpinner = Spinner( refresh_rates) 
		self.refreshRateSpinner.OnChanged =
			function( _, data )
				this.working.refreshrate = data
				self:UpdateMenu()
			end

		local modes = GetDisplayModes( self.working.display )
		self.resolutionSpinner = Spinner( modes )
		self.resolutionSpinner.OnChanged =
			function( _, data )
				this.working.mode_idx = data.idx
				this:UpdateRefreshRatesSpinner()
				self:UpdateMenu()
			end			
			
		self.netbookModeSpinner = Spinner( enableDisableOptions )
		self.netbookModeSpinner.OnChanged =
			function( _, data )
				this.working.netbookmode = data
				--this:Apply()
				self:UpdateMenu()
			end
			
		self.smallTexturesSpinner = Spinner( enableDisableOptions )
		self.smallTexturesSpinner.OnChanged =
			function( _, data )
				this.working.smalltextures = data
				--this:Apply()
				self:UpdateMenu()
			end
						
	end
	
--[[
	self.bloomSpinner = Spinner( enableDisableOptions )
	self.bloomSpinner.OnChanged =
		function( _, data )
			this.working.bloom = data
			--this:Apply()
			self:UpdateMenu()
		end

		
	self.distortionSpinner = Spinner( enableDisableOptions )
	self.distortionSpinner.OnChanged =
		function( _, data )
			this.working.distortion = data
			--this:Apply()
			self:UpdateMenu()
		end
]]--

	self.screenshakeSpinner = Spinner( enableDisableOptions )
    self.screenshakeSpinner.text:SetSize(40)
    self.screenshakeSpinner.text:SetPosition(0, -4, 0)
	self.screenshakeSpinner.OnChanged =
		function( _, data )
			this.working.screenshake = data
			--this:Apply()
			self:UpdateMenu()
		end

	self.fxVolume = NumericSpinner( 0, 10 )
    self.fxVolume.text:SetSize(40)
    self.fxVolume.text:SetPosition(0, -4, 0)
	self.fxVolume.OnChanged =
		function( _, data )
			this.working.fxvolume = data
			this:ApplyVolume()
			self:UpdateMenu()
		end

	self.musicVolume = NumericSpinner( 0, 10 )
    self.musicVolume.text:SetSize(40)
    self.musicVolume.text:SetPosition(0, -4, 0)
	self.musicVolume.OnChanged =
		function( _, data )
			this.working.musicvolume = data
			this:ApplyVolume()
			self:UpdateMenu()
		end

	self.ambientVolume = NumericSpinner( 0, 10 )
    self.ambientVolume.text:SetSize(40)
    self.ambientVolume.text:SetPosition(0, -4, 0)
	self.ambientVolume.OnChanged =
		function( _, data )
			this.working.ambientvolume = data
			this:ApplyVolume()
			self:UpdateMenu()
		end

	if PLATFORM == "iOS" or PLATFORM == "Android" then
		if not self.in_game and not PLATFORM == "Android" then
			self.enableiCloud = Spinner( enableDisableOptions )
		    self.enableiCloud.text:SetSize(40)
		    self.enableiCloud.text:SetPosition(0, -4, 0)
			self.enableiCloud.OnChanged =
				function( _, data )
					this.working.enableiCloud = data
					self:UpdateMenu()
				end
		else
			self.gamma = NumericSpinner( 0, 10 )
		    self.gamma.text:SetSize(40)
		    self.gamma.text:SetPosition(0, -4, 0)
			self.gamma.OnChanged =
				function( _, data )
					this.working.gamma = data
					self:UpdateMenu()
				end

            self.actionButtonsSpinner = Spinner( enableDisableOptions )
            self.actionButtonsSpinner.text:SetSize(40)
            self.actionButtonsSpinner.text:SetPosition(0, -4, 0)
            self.actionButtonsSpinner.OnChanged =
                function( _, data )
                    this.working.actionButtons = data
                    --this:Apply()
                    self:UpdateMenu()
                end

            self.virtualStickSpinner = Spinner( enableDisableOptions )
            self.virtualStickSpinner.text:SetSize(40)
            self.virtualStickSpinner.text:SetPosition(0, -4, 0)
            self.virtualStickSpinner.OnChanged =
                function( _, data )
                    this.working.virtualStick = data
                    --this:Apply()
                    self:UpdateMenu()
                end
            self.HDSpinner = Spinner( enableDisableOptions )
            self.HDSpinner.text:SetSize(40)
            self.HDSpinner.text:SetPosition(0, -4, 0)
            self.HDSpinner.OnChanged =
                function( _, data )
                    this.working.HD = data
                    --this:Apply()
                    self:UpdateMenu()
                end
            if TheSim:SupportsRecording() then
                self.recordButtonsSpinner = Spinner( enableDisableOptions )
                self.recordButtonsSpinner.text:SetSize(40)
                self.recordButtonsSpinner.text:SetPosition(0, -4, 0)
                self.recordButtonsSpinner.OnChanged =
                    function( _, data )
                        this.working.recordButtons = data
                        --this:Apply()
                        self:UpdateMenu()
                    end
            end
		end
	end

	local max_hud_size = 0
	if PLATFORM == "iOS" or PLATFORM == "Android" then
		max_hud_size = 5
	end
	self.hudSize = NumericSpinner( 0, max_hud_size )
    self.hudSize.text:SetSize(40)
    self.hudSize.text:SetPosition(0, -4, 0)
	self.hudSize.OnChanged =
		function( _, data )
			this.working.hudSize = data
			--this:Apply()
			self:UpdateMenu()
		end

--[[
	self.vibrationSpinner = Spinner( enableDisableOptions )
    self.vibrationSpinner.text:SetSize(40)
    self.vibrationSpinner.text:SetPosition(0, -4, 0)
	self.vibrationSpinner.OnChanged =
		function( _, data )
			this.working.vibration = data
			--this:Apply()
			self:UpdateMenu()
		end
]]--

--[[
	self.sendstatsSpinner = Spinner( enableDisableOptions )
    self.sendstatsSpinner.text:SetSize(40)
    self.sendstatsSpinner.text:SetPosition(0, -4, 0)
	self.sendstatsSpinner.OnChanged =
		function( _, data )
			this.working.sendstats = data
			--this:Apply()
			self:UpdateMenu()
]]--		end


	if IsDLCInstalled(REIGN_OF_GIANTS) then
		self.wathgrithrfontSpinner = Spinner( enableDisableOptions )
    self.wathgrithrfontSpinner.text:SetSize(40)
    self.wathgrithrfontSpinner.text:SetPosition(0, -4, 0)
		self.wathgrithrfontSpinner.OnChanged =
			function( _, data )
				this.working.wathgrithrfont = data
				--this:Apply()
				self:UpdateMenu()
			end
	end
		
	local left_spinners = {}
	local right_spinners = {}
	
	if show_graphics then
--		table.insert( left_spinners, { STRINGS.UI.OPTIONS.BLOOM, self.bloomSpinner } )
--		table.insert( left_spinners, { STRINGS.UI.OPTIONS.DISTORTION, self.distortionSpinner } )
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.SCREENSHAKE, self.screenshakeSpinner } )
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.FULLSCREEN, self.fullscreenSpinner } )
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.DISPLAY, self.displaySpinner } )
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.RESOLUTION, self.resolutionSpinner } )
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.REFRESHRATE, self.refreshRateSpinner } )
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.SMALLTEXTURES, self.smallTexturesSpinner } )

		if IsDLCInstalled(REIGN_OF_GIANTS) then
			table.insert( left_spinners, { STRINGS.UI.OPTIONS.NETBOOKMODE, self.netbookModeSpinner} )
		else
			table.insert( right_spinners, { STRINGS.UI.OPTIONS.NETBOOKMODE, self.netbookModeSpinner} )
		end
		
		table.insert( right_spinners, { STRINGS.UI.OPTIONS.FX, self.fxVolume } )
		table.insert( right_spinners, { STRINGS.UI.OPTIONS.MUSIC, self.musicVolume } )
		table.insert( right_spinners, { STRINGS.UI.OPTIONS.AMBIENT, self.ambientVolume } )
		table.insert( right_spinners, { STRINGS.UI.OPTIONS.HUDSIZE, self.hudSize} )
--      table.insert( right_spinners, { STRINGS.UI.OPTIONS.VIBRATION, self.vibrationSpinner} )
--		table.insert( right_spinners, { STRINGS.UI.OPTIONS.SENDSTATS, self.sendstatsSpinner} )
		if IsDLCInstalled(REIGN_OF_GIANTS) then
			table.insert( right_spinners, { STRINGS.UI.OPTIONS.WATHGRITHRFONT, self.wathgrithrfontSpinner} )
		end

	else
--		table.insert( left_spinners, { STRINGS.UI.OPTIONS.BLOOM, self.bloomSpinner } )
--		table.insert( left_spinners, { STRINGS.UI.OPTIONS.DISTORTION, self.distortionSpinner } )
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.SCREENSHAKE, self.screenshakeSpinner } )
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.HUDSIZE, self.hudSize} )
--		table.insert( left_spinners, { STRINGS.UI.OPTIONS.VIBRATION, self.vibrationSpinner} )
--		table.insert( left_spinners, { STRINGS.UI.OPTIONS.SENDSTATS, self.sendstatsSpinner} )
if IsDLCInstalled(REIGN_OF_GIANTS) then
        table.insert( left_spinners, { STRINGS.UI.OPTIONS.WATHGRITHRFONT, self.wathgrithrfontSpinner} )
end

		table.insert( right_spinners, { STRINGS.UI.OPTIONS.FX, self.fxVolume } )
		table.insert( right_spinners, { STRINGS.UI.OPTIONS.MUSIC, self.musicVolume } )
		table.insert( right_spinners, { STRINGS.UI.OPTIONS.AMBIENT, self.ambientVolume } )
if PLATFORM == "iOS" or PLATFORM == "Android" then
		if not self.in_game and not PLATFORM == "Android" then
			table.insert( right_spinners, { STRINGS.UI.OPTIONS.ICLOUD, self.enableiCloud } )
		else
			table.insert( right_spinners, { STRINGS.UI.OPTIONS.GAMMA, self.gamma } )
            table.insert( left_spinners, { STRINGS.UI.OPTIONS.ACTION_BUTTONS, self.actionButtonsSpinner } )
            if APP_REGION == "SCEC" then
	            table.insert( left_spinners, {STRINGS.UI.OPTIONS.VIRTUAL_STICK, self.virtualStickSpinner } )
	        else
	        	table.insert( left_spinners, { "Virtual Stick", self.virtualStickSpinner } )
	        end
	        table.insert( left_spinners, {STRINGS.UI.OPTIONS.HD, self.HDSpinner } )
            if TheSim:SupportsRecording() then
                table.insert( right_spinners, { STRINGS.UI.OPTIONS.RECORD_BUTTONS, self.recordButtonsSpinner } )
            end
		end
end
--		table.insert( right_spinners, { STRINGS.UI.OPTIONS.SENDSTATS, self.sendstatsSpinner} )
--		if IsDLCInstalled(REIGN_OF_GIANTS) then
--			table.insert( right_spinners, { STRINGS.UI.OPTIONS.WATHGRITHRFONT, self.wathgrithrfontSpinner} )
--		end
	end

	for k,v in ipairs(left_spinners) do
		self.grid:AddItem(self:CreateSpinnerGroup(v[1], v[2]), 1, k)	
	end

	for k,v in ipairs(right_spinners) do
		self.grid:AddItem(self:CreateSpinnerGroup(v[1], v[2]), 2, k)	
	end

	self:UpdateMenu()
end

local function EnabledOptionsIndex( enabled )
	if enabled then
		return 2
	else
		return 1
	end
end

function OptionsScreen:InitializeSpinners()
	if show_graphics then
		self.fullscreenSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.fullscreen ) )
		self:UpdateDisplaySpinner()
		self:UpdateResolutionsSpinner()
		self:UpdateRefreshRatesSpinner()
		self.smallTexturesSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.smalltextures ) )
		self.netbookModeSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.netbookmode ) )
	end

	--[[if PLATFORM == "WIN32_STEAM" and not self.in_game then
		self.steamcloudSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.steamcloud ) )
	end
	--]]
	
--	self.bloomSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.bloom ) )
--	self.distortionSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.distortion ) )
	self.screenshakeSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.screenshake ) )
	if PLATFORM == "iOS" or PLATFORM == "Android" then
		if not self.in_game and not PLATFORM == "Android"then
			self.enableiCloud:SetSelectedIndex( EnabledOptionsIndex( self.working.enableiCloud ) )
		else
			local gamma = self.working.gamma or 2
			print("WORKING GAMMA: "..gamma)
			self.gamma:SetSelectedIndex( self.working.gamma )
            self.actionButtonsSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.actionButtons ) )
            self.virtualStickSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.virtualStick ) )
            self.HDSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.HD ) )
            if TheSim:SupportsRecording() then
                self.recordButtonsSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.recordButtons ) )
            end
		end
	end

	local spinners = { fxvolume = self.fxVolume, musicvolume = self.musicVolume, ambientvolume = self.ambientVolume }
	for key, spinner in pairs( spinners ) do
		local volume = self.working[ key ] or 7
		spinner:SetSelectedIndex( math.floor( volume + 0.5 ) )
	end
	
	self.hudSize:SetSelectedIndex( self.working.hudSize or 4)
--	self.vibrationSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.vibration ) )
--	self.sendstatsSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.sendstats ) )
	if IsDLCInstalled(REIGN_OF_GIANTS) then self.wathgrithrfontSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.wathgrithrfont ) ) end
end

function OptionsScreen:UpdateDisplaySpinner()
	if show_graphics then
		local graphicsOptions = TheFrontEnd:GetGraphicsOptions()
		local display_id = graphicsOptions:GetFullscreenDisplayID() + 1
		self.displaySpinner:SetSelectedIndex( display_id )
	end
end

function OptionsScreen:UpdateRefreshRatesSpinner()
	if show_graphics then
		local current_refresh_rate = self.working.refreshrate
		
		local refresh_rates = GetRefreshRates( self.working.display, self.working.mode_idx )
		self.refreshRateSpinner:SetOptions( refresh_rates )
		self.refreshRateSpinner:SetSelectedIndex( 1 )
		
		for idx, refresh_rate_data in ipairs( refresh_rates ) do
			if refresh_rate_data.data == current_refresh_rate then
				self.refreshRateSpinner:SetSelectedIndex( idx )
				break
			end
		end
		
		self.working.refreshrate = self.refreshRateSpinner:GetSelected().data		
	end
end

function OptionsScreen:UpdateResolutionsSpinner()
	if show_graphics then
		local resolutions = GetDisplayModes( self.working.display )
		self.resolutionSpinner:SetOptions( resolutions )
	
		if self.fullscreenSpinner:GetSelected().data then
			self.displaySpinner:Enable()
			self.refreshRateSpinner:Enable()
			self.resolutionSpinner:Enable()

			local spinner_idx = 1
			if self.working.mode_idx then
				local gOpts = TheFrontEnd:GetGraphicsOptions()
				local mode_idx = gOpts:GetCurrentDisplayModeID( self.options.display )
				local w, h, hz = GetDisplayModeInfo( self.working.display, mode_idx )
				
				for idx, option in pairs( self.resolutionSpinner.options ) do
					if option.data.w == w and option.data.h == h then
						spinner_idx = idx
						break
					end
				end
			end
			self.resolutionSpinner:SetSelectedIndex( spinner_idx )
		else
			self.displaySpinner:Disable()
			self.refreshRateSpinner:Disable()
			self.resolutionSpinner:Disable()
		end
	end
end

return OptionsScreen