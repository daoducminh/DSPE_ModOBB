MAIN_GAME = 0
REIGN_OF_GIANTS = 1

NO_DLC_TABLE = {REIGN_OF_GIANTS=false}
ALL_DLC_TABLE = {REIGN_OF_GIANTS=true}
DLC_LIST = {REIGN_OF_GIANTS}

RegisteredDLC = {}
ActiveDLC = {}

-----------------------  locals ------------------------------------------

local function AddPrefab(prefabName)
   for i,v in pairs(PREFABFILES) do
      if v==prefabName then
         return
      end
   end
   PREFABFILES[#PREFABFILES+1] = prefabName
end


local function GetDLCPrefabFiles(filename)
    print("Load "..filename)
    local fn, r = loadfile(filename)
    assert(fn, "Could not load file ".. filename)
    if type(fn) == "string" then
        assert(false, "Error loading file "..filename.."\n"..fn)
    end
    assert( type(fn) == "function", "Prefab file doesn't return a callable chunk: "..filename)
    local ret = fn()
    return ret
end


local function RegisterPrefabs(index)
    local dlcPrefabFilename = string.format("scripts/DLC%03d_prefab_files",index)
    local dlcprefabfiles = GetDLCPrefabFiles(dlcPrefabFilename)
    for i,v in pairs(dlcprefabfiles) do   
        AddPrefab(v)
    end
end

-- Load the base prefablist and merge in all additional prefabs for the DLCs
local function ReloadPrefabList()
    for i,v in pairs(RegisteredDLC) do
            RegisterPrefabs(i)
    end
end


-----------------------  globals ------------------------------------------

function RegisterAllDLC()
    for i=1,10 do
        local filename = string.format("scripts/DLC%04d",i)
        local fn, r = loadfile(filename)
        if (type(fn) == "function") then
             local ret = fn()
             RegisteredDLC[i] = ret
        else
             RegisteredDLC[i] = nil
        end
    end
    ReloadPrefabList()
end

-- This one is somewhat important, it can be used to load prefabs that are not referenced by any prefab and thus not loaded
function InitAllDLC()
    for i,v in pairs(RegisteredDLC) do
        if v.Setup then
            v.Setup()
        end
    end
end

function GetOfficialCharacterList()
    local list = MAIN_CHARACTERLIST
    if IsDLCEnabled(REIGN_OF_GIANTS) then
        list = JoinArrays(list, ROG_CHARACTERLIST)
    end
    return list    
end

function GetActiveCharacterList()
    return JoinArrays(GetOfficialCharacterList(), MODCHARACTERLIST)
end

function DisableDLC(index)
    TheSim:SetDLCEnabled(index,false)
end

function EnableDLC(index)
    TheSim:SetDLCEnabled(index,true)
end

function IsDLCEnabled(index)
    return TheSim:IsDLCEnabled(index)
end

function IsDLCInstalled(index)
    return TheSim:IsDLCInstalled(index)
end

function EnableAllDLC()
    for i,v in pairs(DLC_LIST) do
        EnableDLC(v)
    end
end

function DisableAllDLC()
    print("DisableAllDLC")
    for i,v in pairs(DLC_LIST) do
        DisableDLC(v)
    end 
end

