local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local PauseScreen = require "screens/pausescreen"

--require "screens/mapscreen"

--base class for imagebuttons and animbuttons. 
local MapControls = Class(Widget, function(self)
	Widget._ctor(self, "Map Controls")
    local MAPSCALE = .5
	self.minimapBtn = self:AddChild(ImageButton(HUD_ATLAS, "map_button.tex"))
    self.minimapBtn:SetScale(MAPSCALE,MAPSCALE,MAPSCALE)
	self.minimapBtn:SetPosition( Point( 0,20,0 ) )
	self.minimapBtn:SetOnClick( function() self:ToggleMap() end )
	self.minimapBtn:SetTooltip(STRINGS.UI.HUD.MAP)


	
	self.pauseBtn = self:AddChild(ImageButton(HUD_ATLAS, "pause.tex"))
	self.pauseBtn:SetTooltip(STRINGS.UI.HUD.PAUSE)
	self.pauseBtn:SetScale(.5,.5,.5)
	self.pauseBtn:SetPosition( Point( 0,-40,0 ) )
	
    self.pauseBtn:SetOnClick(
		function()
			if not IsPaused() then
				TheFrontEnd:PushScreen(PauseScreen())
			end
		end )

    if not IPHONE_VERSION then
		self.rotleft = self:AddChild(ImageButton(HUD_ATLAS, "turnarrow_icon.tex"))
	    self.rotleft:SetPosition(-52,-40,0)
	    self.rotleft:SetScale(-.84,.84,.84)
	    self.rotleft:SetOnClick(function() GetPlayer().components.playercontroller:RotLeft() end)
	    self.rotleft:SetTooltip(STRINGS.UI.HUD.ROTLEFT)

		self.rotright = self:AddChild(ImageButton(HUD_ATLAS, "turnarrow_icon.tex"))
	    self.rotright:SetPosition(52,-40,0)
	    self.rotright:SetScale(.84,.84,.84)
	    self.rotright:SetOnClick(function() GetPlayer().components.playercontroller:RotRight() end)
		self.rotright:SetTooltip(STRINGS.UI.HUD.ROTRIGHT)
	else
		self.minimapBtn:SetPosition( Point( 0,30,0 ) )
		self.pauseBtn:SetPosition( Point( 0,-40,0 ) )
		self.pauseBtn:SetScale(.6)
	end

end)

function MapControls:ToggleMap()
	GetPlayer().HUD.controls:ToggleMap()
end

return MapControls
