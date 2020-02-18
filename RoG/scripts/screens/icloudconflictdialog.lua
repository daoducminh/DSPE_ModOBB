local BigPopupDialogScreen = require "screens/bigpopupdialog"

local iCloudConflictDialog = Class(BigPopupDialogScreen, function(self, deviceName)
	local body = STRINGS.ICLOUD.CONFLICT_BODY1..STRINGS.ICLOUD.CONFLICT_BODY2
	if deviceName then
		body = STRINGS.ICLOUD.CONFLICT_BODY1.." ("..deviceName..")"..STRINGS.ICLOUD.CONFLICT_BODY2
	end
	BigPopupDialogScreen._ctor(self, STRINGS.ICLOUD.TITLE, body, 
	{
		{text=STRINGS.ICLOUD.CONFLICT_YES, cb = function() 
			TheSim:SyncWithiCloud(function() 
				Profile:Load( function() 
					SaveGameIndex:Load( function ()
                        Morgue:Load( function()
                            TheFrontEnd:PopScreen()
                        end )
					end )
				end )
			end )
		end},
		{text=STRINGS.ICLOUD.CONFLICT_NO, cb = function() 
			TheSim:UploadToiCloud(function() 
					TheFrontEnd:PopScreen() 
			end )
		end}
	})

end)



function iCloudConflictDialog:OnUpdate( dt )

	return true
end

return iCloudConflictDialog
