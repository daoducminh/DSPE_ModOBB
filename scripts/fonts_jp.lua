DEFAULTFONT = "jp_1"
DIALOGFONT = "jp_1"
TITLEFONT = "jp_1"
UIFONT = "jp_1"
BUTTONFONT="jp_0"
NUMBERFONT = "stint-ucr"
TALKINGFONT = "jp_1"
TALKINGFONT_WATHGRITHR = "jp_1"
SMALLNUMBERFONT = "stint-small"
BODYTEXTFONT = "jp_0"

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
	{ filename = "fonts/jp_1"..font_posfix..".zip", alias = "jp_1" },
	{ filename = "fonts/stint-ucr50"..font_posfix..".zip", alias = "stint-ucr" },
	{ filename = "fonts/stint-ucr20"..font_posfix..".zip", alias = "stint-small" },
	{ filename = "fonts/jp_0"..font_posfix..".zip", alias = "jp_0" },	
}
