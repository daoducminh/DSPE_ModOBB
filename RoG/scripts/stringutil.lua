local function getcharacterstring(tab, item, modifier)
    if modifier then
		modifier = string.upper(modifier)
	end

    if tab then
        local topic_tab = tab[item]
        if topic_tab then
            if type(topic_tab) == "string" then
		        return topic_tab
            elseif type(topic_tab) == "table" then
                if modifier and topic_tab[modifier] then
                    return topic_tab[modifier]
                end

                if topic_tab['GENERIC'] then
                    return topic_tab['GENERIC']
                end

				if #topic_tab > 0 then
					return topic_tab[math.random(#topic_tab)]
				end
            end
        end
    end
end

function GetGenderStrings(charactername)
    if table.contains(CHARACTER_GENDERS.MALE, charactername) then
        return "MALE"
    elseif table.contains(CHARACTER_GENDERS.FEMALE, charactername) then
        return "FEMALE"
    elseif table.contains(CHARACTER_GENDERS.ROBOT, charactername) then
        return "ROBOT"
    else
        return "MALE"
    end
end



function CraftMmph()
    local function NumInRange(num, min, max)
        return (num <= max) and (num > min)
    end
    
    local MMPH_STATE = "START"

    local mmphstart = function()        
        local str = "m"
        if MMPH_STATE == "START" then
            str = string.upper(str)
        end
        local l = math.random(2, 4)
        for i = 2, l do
            local nextletter = (math.random() > 0.3 and "m") or "h"
            str = str..nextletter
        end
        return str
    end

    local endings = 
    {
        "",
        "h",
        "ph",
    }

    local mmphend = function()
        return endings[math.random(#endings)]
    end

    local mmphspace = function()
        local c = math.random()
        local str = 
        (NumInRange(c, 0.4, 1) and " ") or 
        (NumInRange(c, 0.3, 0.4) and ", ") or
        (NumInRange(c, 0.2, 0.3) and "? ") or 
        (NumInRange(c, 0.1, 0.2) and ". ") or 
        (NumInRange(c, 0, 0.1) and "! ")
        if c <= 0.3 then
            MMPH_STATE = "START"
        else
            MMPH_STATE = "MID"
        end
        return str
    end

    local length = math.random(6)
    local str = ""
    for i = 1, length do
        str = str..mmphstart()..mmphend()
        if i ~= length then
            str = str..mmphspace()
        end
    end

    local punc = {".", "?", "!"}

    str = str..punc[math.random(#punc)]

    return str
end

function GetSpecialCharacterString(character)
    character = string.lower(character)
    if character == "wilton" then

		local sayings =
		{
			"Ehhhhhhhhhhhhhh.",
			"Eeeeeeeeeeeer.",
			"Rattle.",
			"click click click click",
			"Hissss!",
			"Aaaaaaaaa.",
			"mooooooooooooaaaaan.",
			"...",
		}

		return sayings[math.random(#sayings)]
    elseif character == "wes" then
		return ""
    elseif character == "pyro" then
        return CraftMmph()
    end
end



function GetString(character, stringtype, modifier)
    character = character and string.upper(character)
    stringtype = stringtype and string.upper(stringtype)
    modifier = modifier and string.upper(modifier)
    
    local ret = GetSpecialCharacterString(character) or
			    getcharacterstring(STRINGS.CHARACTERS[character], stringtype, modifier) or
                getcharacterstring(STRINGS.CHARACTERS["GENERIC"], stringtype, modifier)
    if ret then
        return ret
    end

    return "UNKNOWN STRING: "..( character or "") .." ".. (stringtype or "") .." ".. (modifier or "")

end

function GetActionString(action, modifier)
    return getcharacterstring(STRINGS.ACTIONS, action, modifier) or "ACTION"
end

function GetDescription(character, item, modifier)
    character = character and string.upper(character)
    local itemname = item.components.inspectable.nameoverride or item.prefab
    itemname = itemname and string.upper(itemname)
    modifier = modifier and string.upper(modifier)

    local ret = GetSpecialCharacterString(character)

    if not ret then
        if STRINGS.CHARACTERS[character] then
            ret = getcharacterstring(STRINGS.CHARACTERS[character].DESCRIBE, itemname, modifier)
        end

        if not ret and STRINGS.CHARACTERS.GENERIC then
            ret = getcharacterstring(STRINGS.CHARACTERS.GENERIC.DESCRIBE, itemname, modifier)
        end

        if not ret then
            ret = STRINGS.CHARACTERS.GENERIC.DESCRIBE_GENERIC
        end
    end

    if ret and item and item.components.repairable and item.components.repairable:NeedsRepairs() and item.components.repairable.announcecanfix then
        local repair = nil
        if STRINGS.CHARACTERS[character] and STRINGS.CHARACTERS[character].DESCRIBE then
            repair = getcharacterstring(STRINGS.CHARACTERS[character], "ANNOUNCE_CANFIX", modifier)
        end
    
        if not repair and STRINGS.CHARACTERS.GENERIC then
            repair = getcharacterstring(STRINGS.CHARACTERS.GENERIC, "ANNOUNCE_CANFIX", modifier)
        end

        if repair then 
            ret = ret..repair
        end
    end  

    return ret 
end

function GetActionFailString(character, action, reason)
    local ret = nil

	local ret = GetSpecialCharacterString(character)
	if ret then
		return ret
	end

    if STRINGS.CHARACTERS[character] then
        ret = getcharacterstring(STRINGS.CHARACTERS[character].ACTIONFAIL, action, reason)
    end

    if not ret then
        ret = getcharacterstring(STRINGS.CHARACTERS.GENERIC.ACTIONFAIL, action, reason)
    end

    if ret then
       return ret
    end
    return STRINGS.CHARACTERS.GENERIC.ACTIONFAIL_GENERIC
end
