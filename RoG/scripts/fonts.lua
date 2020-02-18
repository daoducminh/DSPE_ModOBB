if PLATFORM == "iOS"  or PLATFORM == "Android" then
	local usedLanguage = TheSim:GetUsedLanguage()
	if usedLanguage == "english" or usedLanguage == "french" or usedLanguage == "german" or usedLanguage == "italian" or usedLanguage == "spanish" or usedLanguage == "polish" or usedLanguage == "portuguese" then
		require "fonts_eur"
		print(" ++++++ Configured EUR fonts")
    	elseif usedLanguage == "russian" then
    		require "fonts_ru"
        	print(" ++++++ Configured RU fonts")
	elseif usedLanguage == "korean" then
		require "fonts_ko"
		print(" ++++++ Configured KO fonts")
	elseif usedLanguage == "simplified_chinese" then
		require "fonts_sc"
		print(" ++++++ Configured SIMPLIFIED CHINESE fonts")
	elseif usedLanguage == "traditional_chinese" then
		require "fonts_tc"
		print(" ++++++ Configured TRADITIONAL CHINESE fonts")
	elseif usedLanguage == "japanese" then
		require "fonts_jp"
		print(" ++++++ Configured JAPANESE fonts")
	else
		print(" ERROR! No font configured. Check all supported languages are taken into account in fonts.lua")
	end
else
	require "fonts_eur"
end
