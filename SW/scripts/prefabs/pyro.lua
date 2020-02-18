
local MakePlayerCharacter = require "prefabs/player_common"

local assets = 
{
    Asset("ANIM", "anim/pyro.zip"),
    Asset("ANIM", "anim/player_pyro.zip"),
	Asset("SOUND", "sound/wyro.fsb"),
    Asset("ANIM", "anim/vig_pyro.zip"), 
    Asset("IMAGE", "images/colour_cubes/insane_pyro_day_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/insane_pyro_dusk_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/insane_pyro_night_cc.tex"),
}

local prefabs = 
{
	"pyro_flare_gun",
	"pyro_axe",
	"balloonicorn",
	"balloonicorn_lollipop",
}

local start_inv = 
{
	"pyro_axe",	
	"pyro_flare_gun",
}

--Overwrite the functions in the default vig to use pyro insane.
local function GoSane(self)
	self.vig:GetAnimState():SetBank("vig")
	self.vig:GetAnimState():SetBuild("vig")
    self.vig:GetAnimState():PlayAnimation("basic", true)
    self.vig:GetAnimState():SetLayer(LAYER_PRE_FRONTEND)
end

local function GoInsane(self)
	self.vig:GetAnimState():SetBank("vig")
	self.vig:GetAnimState():SetBuild("vig_pyro")
	self.vig:GetAnimState():PlayAnimation("insane_pyro", true)
    self.vig:GetAnimState():SetLayer(LAYER_PRE_FRONTEND)
end

local function HUDPostInit(hud)
    hud.GoSane = GoSane
    hud.GoInsane = GoInsane

    if GetPlayer().components.sanity:IsCrazy() then
    	GoInsane(hud)
    end
end
-----------------

local function ReplaceEyebone()
	local eyebone = TheSim:FindFirstEntityWithTag("chester_eyebone")

	if eyebone and not eyebone:HasTag("balloonicorn_lollipop") then
		local lolli = SpawnPrefab("balloonicorn_lollipop")
		lolli.Transform:SetPosition(eyebone:GetPosition():Get())
		eyebone:Remove()
	end
end

local function custom_init(inst)
	inst.soundsname = "wyro"

	inst:AddTag("pyro")

	inst.components.health.fire_damage_scale = 0
	inst.components.health:SetMaxHealth(TUNING.PYRO_HEALTH)

	inst.components.hunger:SetMax(TUNING.PYRO_HUNGER)

	inst.components.sanity:SetMax(TUNING.PYRO_SANITY)
	inst.components.sanity.dapperness_mult = TUNING.PYRO_DAPPERNESS_MULT

	inst.components.talker.special_speech = true

    local axe_recipe = Recipe("pyro_axe", {Ingredient("axe", 1), Ingredient("rope", 1), Ingredient("stinger", 2),}, RECIPETABS.WAR, {SCIENCE = 0, MAGIC = 0, ANCIENT = 0})
	local gun_recipe = Recipe("pyro_flare_gun", {Ingredient("tentaclespots", 2), Ingredient("horn", 1), Ingredient("gunpowder", 2),}, RECIPETABS.WAR, {SCIENCE = 0, MAGIC = 0, ANCIENT = 0})	

    axe_recipe.sortkey = 1
	gun_recipe.sortkey = 2

    inst.HUDPostInit = HUDPostInit

    inst:DoTaskInTime(0, ReplaceEyebone)

    --Change the sanity sound to be the pyro sanity sound!
	GetWorld().SoundEmitter:KillSound("SANITY")
	GetWorld().SoundEmitter:PlaySound("dontstarve/characters/wyro/pyro_sanity", "SANITY")
	GetWorld().components.colourcubemanager.INSANITY_CCS = 
	{
		DAY = "images/colour_cubes/insane_pyro_day_cc.tex",
		DUSK = "images/colour_cubes/insane_pyro_dusk_cc.tex",
		NIGHT = "images/colour_cubes/insane_pyro_night_cc.tex",
		FULL_MOON = "images/colour_cubes/insane_pyro_night_cc.tex",
	}

end

return MakePlayerCharacter("pyro", prefabs, assets, custom_init, start_inv) 
