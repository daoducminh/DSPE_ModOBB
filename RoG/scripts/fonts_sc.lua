DEFAULTFONT = "sc_1"
DIALOGFONT = "sc_1"
TITLEFONT = "sc_1"
UIFONT = "sc_1"
BUTTONFONT="sc_0"
NUMBERFONT = "stint-ucr"
TALKINGFONT = "sc_1"
TALKINGFONT_WATHGRITHR = "sc_1"
SMALLNUMBERFONT = "stint-small"
BODYTEXTFONT = "sc_0"

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
	{ filename = "fonts/sc_1"..font_posfix..".zip", alias = "sc_1" },
	{ filename = "fonts/stint-ucr50"..font_posfix..".zip", alias = "stint-ucr" },
	{ filename = "fonts/stint-ucr20"..font_posfix..".zip", alias = "stint-small" },
	{ filename = "fonts/sc_0"..font_posfix..".zip", alias = "sc_0" },	
}
