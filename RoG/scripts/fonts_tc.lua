DEFAULTFONT = "tc_1"
DIALOGFONT = "tc_1"
TITLEFONT = "tc_1"
UIFONT = "tc_1"
BUTTONFONT="tc_0"
NUMBERFONT = "stint-ucr"
TALKINGFONT = "tc_1"
TALKINGFONT_WATHGRITHR = "tc_1"
SMALLNUMBERFONT = "stint-small"
BODYTEXTFONT = "tc_0"

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
	{ filename = "fonts/tc_1"..font_posfix..".zip", alias = "tc_1" },
	{ filename = "fonts/stint-ucr50"..font_posfix..".zip", alias = "stint-ucr" },
	{ filename = "fonts/stint-ucr20"..font_posfix..".zip", alias = "stint-small" },
	{ filename = "fonts/tc_0"..font_posfix..".zip", alias = "tc_0" },	
}
