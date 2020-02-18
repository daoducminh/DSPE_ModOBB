local BigPopupDialogScreen = require "screens/bigpopupdialog"
local iCloudConflictDialog = require "screens/icloudconflictdialog"
local PopupDialogScreen = require "screens/popupdialog"

local iCloudSyncDialog = Class(BigPopupDialogScreen, function(self)
	BigPopupDialogScreen._ctor(self, STRINGS.ICLOUD.TITLE, STRINGS.ICLOUD.LOADING_BODY,
	{
		--{text=STRINGS.UI.MAINSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end}
	})

	TheSim:CheckConflictsFromiCloud(function(conflictExists, deviceName)
		local textSize = 33
		if conflictExists then
			local popup = iCloudConflictDialog(deviceName)
			popup.text:SetSize(textSize)
			TheFrontEnd:PushScreen( popup )
			self.shouldPopScreen = true
		else
			TheSim:SyncWithiCloud(function(success)
				if success then 
					Profile:Load( function() 
						SaveGameIndex:Load( function ()
							-- [vicent] activate this for cloud cross-save
							--ImportSaveGameIndex:Load( function ()
	                          Morgue:Load( function()
    	                            TheFrontEnd:PopScreen()
	                          end )
                            -- end )
						end )
					end )
				else
					local popup = BigPopupDialogScreen( STRINGS.ICLOUD.ERROR_TITLE, STRINGS.ICLOUD.ERROR_BODY,
						  { 
						  	{ 
						  		text = STRINGS.UI.MAINSCREEN.OK, 
						  		cb = function()
									TheFrontEnd:PopScreen()					
								end
							},
						  }
						)
					popup.text:SetSize(textSize)
					TheFrontEnd:PushScreen(popup)	
					self.shouldPopScreen = true
				end
			end )
		end
	end)

	self.shouldPopScreen = false
	
end)

function iCloudSyncDialog:OnBecomeActive()
	if self.shouldPopScreen then
		TheFrontEnd:PopScreen()
	end
end

function iCloudSyncDialog:OnUpdate( dt )

	return true
end

return iCloudSyncDialog
