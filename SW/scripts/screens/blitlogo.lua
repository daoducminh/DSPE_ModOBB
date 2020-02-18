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



local BlitScreen = Class(Screen, function(self, cb)
	Screen._ctor(self, "BlitScreen")
	self.cb = cb

	self.bg = self:AddChild(Image("images/blit_ios.xml", "BlitSplash.tex"))
	self.bg:SetVRegPoint(ANCHOR_MIDDLE)
	self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetVAnchor(ANCHOR_MIDDLE)
	self.bg:SetHAnchor(ANCHOR_MIDDLE)
	self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)

	TheFrontEnd:Fade(true,1)
	self.state = "FADEIN"
	self.time = 0
	if PLATFORM == "WIIU" then
		TheFrontEnd:HideSubDisplaySwitch()
	end
end)

function BlitScreen:OnUpdate( dt )
	if self.state == "FADEIN" then
		self.time = self.time + dt
	
		if self.time > 3 then
			self.state = "FADEOUT"
			TheFrontEnd:Fade(false,1)
		end
	elseif self.state == "FADEOUT" then
		self.time = self.time + dt

		if self.time > 4 then
			TheFrontEnd:PopScreen()
			if PLATFORM == "WIIU" then
				TheFrontEnd:ShowSubDisplaySwitch()
			end
			self.cb()
		end
	end

end

return BlitScreen


