DEFAULTFONT = "ko_1"
DIALOGFONT = "ko_1"
TITLEFONT = "ko_1"
UIFONT = "ko_1"
BUTTONFONT="ko_0"
NUMBERFONT = "stint-ucr"
TALKINGFONT = "ko_1"
TALKINGFONT_WATHGRITHR = "ko_1"
SMALLNUMBERFONT = "stint-small"
BODYTEXTFONT = "ko_0"

require "translator"

local font_posfix = ""

if LanguageTranslator then	-- This gets called from the build pipeline too
    local lang = LanguageTranslator.defaultlang 

    -- Some languages need their own font
    local specialFontLangs = {"jp"}

    for i,v in pairs(specialFontLangs) do
        if v == lang then
            font_posfix = "__"..lang
        end
    end
end

FONTS = {
	{ filename = "fonts/ko_1"..font_posfix..".zip", alias = "ko_1" },
	{ filename = "fonts/stint-ucr50"..font_posfix..".zip", alias = "stint-ucr" },
	{ filename = "fonts/stint-ucr20"..font_posfix..".zip", alias = "stint-small" },
	{ filename = "fonts/ko_0"..font_posfix..".zip", alias = "ko_0" },	
}
