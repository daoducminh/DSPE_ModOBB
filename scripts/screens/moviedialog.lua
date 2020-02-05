local BigPopupDialogScreen = require "screens/bigpopupdialog"
local lastTouch = false
local MovieDialog = Class(BigPopupDialogScreen, function(self, movie_path, callback)
	BigPopupDialogScreen._ctor(self, "MovieDialog", "MovieDialog", 
	{
		{text="Stop Movie", cb = function() TheSim:StopMovie(movie_path) end}
	})
    self.cb = callback
	TheSim:PlayMovie(movie_path)
end)



function MovieDialog:OnUpdate( dt )
	if not TheSim:IsMoviePlaying() then
		TheFrontEnd:DoFadeIn(2)
		TheFrontEnd:PopScreen()
		
        if self.cb then
            self.cb()
        end
	else
		if lastTouch and not TheInput:IsTouchDown() then
			TheFrontEnd:DoFadeIn(2)
			TheSim:StopMovie("")
		end
    end
    lastTouch = TheInput:IsTouchDown()
	return true
end

return MovieDialog
