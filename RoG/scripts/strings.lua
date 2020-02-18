if PLATFORM == "iOS" or PLATFORM == "Android" then
    local usedLanguage = TheSim:GetUsedLanguage()
    if usedLanguage == "english" then
        --package.loaded['strings_en'] = nil
        require "strings_en"
        print(" ++++++ ENGLISH STRINGS LOADED")
    elseif usedLanguage == "french" then
        require "strings_fr"
        print(" ++++++ FRENCH STRINGS LOADED")
    elseif usedLanguage == "german" then
        require "strings_de"
        print(" ++++++ GERMAN STRINGS LOADED")
    elseif usedLanguage == "italian" then
        require "strings_it"
        print(" ++++++ ITALIAN STRINGS LOADED")
    elseif usedLanguage == "spanish" then
        require "strings_es"
        print(" ++++++ SPANISH STRINGS LOADED")
    elseif usedLanguage == "polish" then
        require "strings_pl"
        print(" ++++++ POLISH STRINGS LOADED")
    elseif usedLanguage == "portuguese" then
        require "strings_pt"
        print(" ++++++ PORTUGUESE STRINGS LOADED")
    elseif usedLanguage == "russian" then
        require "strings_ru"
        print(" ++++++ RUSSIAN STRINGS LOADED")
    elseif usedLanguage == "korean" then
        require "strings_ko"
        print(" ++++++ KOREAN STRINGS LOADED")
    elseif usedLanguage == "simplified_chinese" then
        require "strings_sc"
        print(" ++++++ SIMPLIFIED CHINESE STRINGS LOADED")
    elseif usedLanguage == "traditional_chinese" then
        require "strings_tc"
        print(" ++++++ TRADITIONAL CHINESE STRINGS LOADED")
    elseif usedLanguage == "japanese" then
        require "strings_jp"
        print(" ++++++ JAPANESE STRINGS LOADED")
    else
        -- Unsupported language, falling back to english
        TheSim:SetUsedLanguage("english")
        require "strings_en"
        print(" ++++++ UNSUPPORTED LANGUAGE: " .. usedLanguage .. ". FALLING BACK TO ENGLISH!")
    end
else
    require "strings_en"
end