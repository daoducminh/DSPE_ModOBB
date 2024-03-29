-- Override the package.path in luaconf.h because it is impossible to find
--package.path = "DLC0001\\scripts\\?.lua;scripts\\?.lua;scriptlibs\\?.lua"
package.path = "scripts\\?.lua;scriptlibs\\?.lua"
if jit then
	jit.off()
end

print("STARTING Android VERSION")

--defines
MAIN = 1
ENCODE_SAVES = BRANCH ~= "dev"
CHEATS_ENABLED = true -- BRANCH == "dev" or (PLATFORM == "PS4" and CONFIGURATION ~= "PRODUCTION")
SOUNDDEBUG_ENABLED = false
MODS_ENABLED = false -- PLATFORM ~= "PS4" and PLATFORM ~= "NACL" and PLATFORM ~= "iOS"
ACCOMPLISHMENTS_ENABLED = PLATFORM == "PS4"
DEBUG_MENU_ENABLED = true -- BRANCH == "dev" or (PLATFORM == "PS4" and CONFIGURATION ~= "PRODUCTION") or (PLATFORM == "iOS" and CONFIGURATION ~= "PRODUCTION")
METRICS_ENABLED = PLATFORM ~= "PS4"
--debug.setmetatable(nil, {__index = function() return nil end})  -- Makes  foo.bar.blat.um  return nil if table item not present   See Dave F or Brook for details
CONSOLE_ENABLED = true
SHOWLOG_ENABLED = true
DEBUGRENDER_ENABLED = true
SKIP_MAXWELL_INTRO = false
IPHONE_VERSION = true  -- TheSim:IsiPhone()
IOS_DEVICE_PHYSICAL_MEMORY = 780 -- TheSim:GetDevicePhysicalMemory()

print("IOS_DEVICE_PHYSICAL_MEMORY: "..IOS_DEVICE_PHYSICAL_MEMORY)

ExecutingLongUpdate = false
ExecutingCaveCatchup = false

local servers =
{
	release = "http://dontstarve-release.appspot.com",
	dev = "http://dontstarve-dev.appspot.com",
	staging = "http://dontstarve-staging.appspot.com",
}
GAME_SERVER = servers[BRANCH]


TheSim:SetReverbPreset("default")

if PLATFORM == "NACL" then
	VisitURL = function(url, notrack)
		if notrack then
			TheSim:SendJSMessage("VisitURLNoTrack:"..url)
		else
			TheSim:SendJSMessage("VisitURL:"..url)
		end
	end
end

package.path = package.path .. ";scripts/?.lua"

if PLATFORM == "WIN32" then
	package.path = package.path .. ";scriptlibs/?.lua"
	--this is done strangely, because we statically link to luasocket. We statically link to lusocket because we statically link to lua. We statically link to lua because of NaCl. Boo.
	--anyway, you should be able to use luasocket as you would expect from this point forward (on windows at least).
	dofile("scriptlibs/socket.lua")
	dofile("scriptlibs/mime.lua")
end

--used for A/B testing and preview features. Gets serialized into and out of save games
GameplayOptions = 
{
}


--install our crazy loader!
local loadfn = function(modulename)
	--print (modulename, package.path)
    local errmsg = ""
    local modulepath = string.gsub(modulename, "%.", "/")
    for path in string.gmatch(package.path, "([^;]+)") do
        local filename = string.gsub(path, "%?", modulepath)
        filename = string.gsub(filename, "\\", "/")
        local result = kleiloadlua(filename)
        if result then
            return result
        end
        errmsg = errmsg.."\n\tno file '"..filename.."' (checked with custom loader)"
    end
  return errmsg    
end
table.insert(package.loaders, 1, loadfn)

--patch this function because NACL has no fopen
if TheSim then
    function loadfile(filename)
        filename = string.gsub(filename, ".lua", "")
        filename = string.gsub(filename, "scripts/", "")
        return loadfn(filename)
    end
end

if PLATFORM == "NACL" then
    package.loaders[2] = nil
elseif PLATFORM == "WIN32" then
end

require("strict")
require("debugprint")
-- add our print loggers
AddPrintLogger(function(...) TheSim:LuaPrint(...) end)

require("config")

require("mainfunctions")
require("preloadsounds")

require("mods")
require("json")
require("vector3")
require("tuning")
require("languages/language")
require("strings")
require("stringutil")
require("dlcsupport_strings")
require("constants")
require("class")
require("actions")
require("debugtools")
require("simutil")
require("util")
require("scheduler")
require("stategraph")
require("behaviourtree")
require("prefabs")
require("entityscript")
require("profiler")
require("recipes")
require("brain")
require("emitters")
require("dumper")
require("input")
require("upsell")
require("stats")
require("frontend")

if METRICS_ENABLED then
require("overseer")
end

require("fileutil")
require("screens/scripterrorscreen")
require("prefablist")
require("standardcomponents")
require("update")
require("fonts")
require("physics")
require("modindex")
require("mathutil")
require("components/lootdropper")
require("saveindex") -- Added by Altgames for Android focus lost handling
require("worldtiledefs")
require("bugreport")

function JapaneseOnPS4()
	if PLATFORM=="PS4" and APP_REGION == "SCEJ" then
		return true
	end
	return false
end

if TheConfig:IsEnabled("force_netbookmode") then
	TheSim:SetNetbookMode(true)
end


--debug key init
if CHEATS_ENABLED then
	require "debugcommands"
	require "debugkeys"
end


print ("running main.lua\n")
TheSystemService:SetStalling(true)

VERBOSITY_LEVEL = VERBOSITY.ERROR
if CONFIGURATION ~= "Production" then
	VERBOSITY_LEVEL = VERBOSITY.DEBUG
end

-- uncomment this line to override
VERBOSITY_LEVEL = VERBOSITY.WARNING

math.randomseed(TheSim:GetRealTime())

--instantiate the mixer
local Mixer = require("mixer")
TheMixer = Mixer.Mixer()
require("mixes")
TheMixer:PushMix("start")


Prefabs = {}
Ents = {}
AwakeEnts = {}
UpdatingEnts = {}
NewUpdatingEnts = {}
StopUpdatingEnts = {}

StopUpdatingComponents = {}

WallUpdatingEnts = {}
NewWallUpdatingEnts = {}
num_updating_ents = 0
NumEnts = 0


TheGlobalInstance = nil

global("TheCamera")
TheCamera = nil
global("SplatManager")
SplatManager = nil
global("ShadowManager")
ShadowManager = nil
global("RoadManager")
RoadManager = nil
global("EnvelopeManager")
EnvelopeManager = nil
global("PostProcessor")
PostProcessor = nil

global("FontManager")
FontManager = nil
global("MapLayerManager")
MapLayerManager = nil
global("Roads")
Roads = nil
global("TheFrontEnd")
TheFrontEnd = nil

inGamePlay = false
inOptions = false
inDeathScreen = false
inMaxwellDoorPopUp = false
inMaxwellDoorPopUp_inst = nil

local function ModSafeStartup()

	-- If we failed to boot last time, disable all mods
	-- Otherwise, set a flag file to test for boot success.

	---PREFABS AND ENTITY INSTANTIATION

	ModManager:LoadMods()

	-- Apply translations
	TranslateStringTable( STRINGS )

    print("Register DLC...")

    RegisterAllDLC()
	-- Register every standard prefab with the engine
    for i,file in ipairs(PREFABFILES) do -- required from prefablist.lua
        LoadPrefabFile("prefabs/"..file)
    end
    InitAllDLC()

	-- This one needs to be active from the get-go.
	--LoadPrefabFile("prefabs/global")
    LoadAchievements("achievements.lua")
    require("cameras/followcamera")
    TheCamera = FollowCamera()

	--- GLOBAL ENTITY ---
	TheGlobalInstance = CreateEntity()
	TheGlobalInstance.entity:SetCanSleep( false )
	TheGlobalInstance.entity:AddTransform()

	if RUN_GLOBAL_INIT then
		GlobalInit()
	end

	SplatManager = TheGlobalInstance.entity:AddSplatManager()
	ShadowManager = TheGlobalInstance.entity:AddShadowManager()
	ShadowManager:SetTexture( "images/shadow.tex" )
	RoadManager = TheGlobalInstance.entity:AddRoadManager()
	EnvelopeManager = TheGlobalInstance.entity:AddEnvelopeManager()

	PostProcessor = TheGlobalInstance.entity:AddPostProcessor()
	local IDENTITY_COLOURCUBE = "images/colour_cubes/identity_colourcube.tex"
	PostProcessor:SetColourCubeData( 0, IDENTITY_COLOURCUBE, IDENTITY_COLOURCUBE )
	PostProcessor:SetColourCubeData( 1, IDENTITY_COLOURCUBE, IDENTITY_COLOURCUBE )

	FontManager = TheGlobalInstance.entity:AddFontManager()
	MapLayerManager = TheGlobalInstance.entity:AddMapLayerManager()

end
if not MODS_ENABLED then
	-- No mods in nacl, and the below functions are async in nacl
	-- so they break because Main returns before ModSafeStartup has run.
	ModSafeStartup()
else
	KnownModIndex:Load(function() 
		KnownModIndex:BeginStartupSequence(function()
			ModSafeStartup()
		end)
	end)
end

require "stacktrace"
require "debughelpers"

TheSystemService:SetStalling(false)

