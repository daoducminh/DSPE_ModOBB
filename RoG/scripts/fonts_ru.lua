DEFAULTFONT = "ru_1"
DIALOGFONT = "ru_1"
TITLEFONT = "ru_1"
UIFONT = "ru_1"
BUTTONFONT="ru_0"
NUMBERFONT = "stint-ucr"
TALKINGFONT = "ru_talking"
TALKINGFONT_WATHGRITHR = "ru_talking"
SMALLNUMBERFONT = "stint-small"
BODYTEXTFONT = "ru_0"

require "translator"

local font_posfix = ""

if LanguageTranslator then	-- This gets called from the build pipeline too
local lang = LanguageTranslator.defaultlang
end

FONTS = {
{ filename = "fonts/ru_1"..font_posfix..".zip", alias = "ru_talking" },
{ filename = "fonts/ru_0"..font_posfix..".zip", alias = "ru_1" },
{ filename = "fonts/stint-ucr50"..font_posfix..".zip", alias = "stint-ucr" },
{ filename = "fonts/stint-ucr20"..font_posfix..".zip", alias = "stint-small" },
{ filename = "fonts/ru_0"..font_posfix..".zip", alias = "ru_0" },
}
