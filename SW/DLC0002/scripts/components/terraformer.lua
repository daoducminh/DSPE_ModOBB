local Terraformer = Class(function(self, inst)
    self.inst = inst
end)


local GROUND_TURFS =
{
	[GROUND.ROCKY]		= "turf_rocky",
	[GROUND.ROAD]		= "turf_road",
	[GROUND.DIRT]		= "turf_dirt",
	[GROUND.SAVANNA]	= "turf_savanna",
	[GROUND.GRASS]		= "turf_grass",
	[GROUND.FOREST]		= "turf_forest",
	[GROUND.MARSH]		= "turf_marsh",
	[GROUND.WOODFLOOR]	= "turf_woodfloor",
	[GROUND.CARPET]		= "turf_carpetfloor",
	[GROUND.CHECKER]	= "turf_checkerfloor",
	
	[GROUND.CAVE]		= "turf_cave",
	[GROUND.FUNGUS]		= "turf_fungus",
	[GROUND.FUNGUSRED]	= "turf_fungus_red",
	[GROUND.FUNGUSGREEN]= "turf_fungus_green",
	
	[GROUND.SINKHOLE]	= "turf_sinkhole",
	[GROUND.UNDERROCK]	= "turf_underrock",
	[GROUND.MUD]		= "turf_mud",

	[GROUND.DESERT_DIRT]= "turf_desertdirt",
	[GROUND.DECIDUOUS]	= "turf_deciduous",

	[GROUND.BEACH]		= "turf_beach",
	[GROUND.JUNGLE]		= "turf_jungle",
	[GROUND.SWAMP]		= "turf_swamp",

	[GROUND.MAGMAFIELD] = "turf_magmafield",
	[GROUND.TIDALMARSH] = "turf_tidalmarsh",
	[GROUND.MEADOW]		= "turf_meadow",
	[GROUND.VOLCANO]	= "turf_volcano",
	[GROUND.ASH]		= "turf_ash",
	[GROUND.SNAKESKIN]  = "turf_snakeskinfloor",
	webbing				= "turf_webbing",
}

local function getbasetile(ground)
	local basetile = GROUND.DIRT
	if ground:HasTag("shipwrecked") then
		basetile = GROUND.BEACH
	elseif ground:HasTag("volcano") then
		basetile = GROUND.VOLCANO_ROCK
	end
	return basetile
end

function Terraformer:CanTerraformPoint(pt)
    local ground = GetWorld()
    if ground then
    	local basetile = getbasetile(ground)
		local tile = ground.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
		return tile ~= GROUND.IMPASSIBLE and tile ~= basetile and tile ~= GROUND.BRICK_GLOW and tile < GROUND.UNDERGROUND and not ground.Map:IsWater(tile)
	end
	return false
end

function Terraformer:CollectPointActions(doer, pos, actions, right)
    if right then
		local valid = true
		-- if RoadManager then
		-- 	valid = not RoadManager:IsOnRoad( pos.x, 0, pos.z )
		-- end
		
		if valid and self:CanTerraformPoint(pos) then
			table.insert(actions, ACTIONS.TERRAFORM)
		end
	end
end

local function SpawnTurf( turf, pt )
	if turf then
		local loot = SpawnPrefab(turf)
		loot.Transform:SetPosition(pt.x, pt.y, pt.z)
		if loot.Physics then
			local angle = math.random()*2*PI
			loot.Physics:SetVel(2*math.cos(angle), 10, 2*math.sin(angle))
		end
	end
end

local function setTileBlocking(block, pt)
	local ground = GetWorld()
	local px,py,pz = ground.Map:GetTileCenterPoint(pt.x, pt.y, pt.z)			
	for ix=0,1 do
		for iy =0,1 do
			local modx =-1
			local mody =-1
			if ix == 1 then
				modx = modx+2
			end
			if iy == 1 then
				mody = mody+2
			end			
			print("Altering tile",px+modx,pz+mody)
			ground.Flooding:SetIsPositionBlocked(px+modx,0,pz+mody, block, false)
		end
	end
end

function Terraformer:Terraform(pt)
	if self:CanTerraformPoint(pt) == false then
		return false
	end

    local ground = GetWorld()
    if ground then
    	local basetile = getbasetile(ground)
		local original_tile_type = ground.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
		if original_tile_type ~= basetile then
			if original_tile_type == GROUND.LEAKPROOFCARPET then

				local range = 1
				if #TheSim:FindEntities(pt.x, pt.y, pt.z, range, {"floodblocker"}) <= 0 then
					ground.Flooding:SetIsPositionBlocked(pt.x, 0, pt.z, false)
				end

				if #TheSim:FindEntities(pt.x, pt.y, pt.z + 2, range, {"floodblocker"}) then
					ground.Flooding:SetIsPositionBlocked(pt.x, 0, pt.z + 2, false)
				end

				if #TheSim:FindEntities(pt.x, pt.y, pt.z - 2, range, {"floodblocker"}) then
					ground.Flooding:SetIsPositionBlocked(pt.x, 0, pt.z - 2, false)
				end

				--Plus 2 X
				if #TheSim:FindEntities(pt.x + 2, pt.y, pt.z, range, {"floodblocker"}) <= 0 then
					ground.Flooding:SetIsPositionBlocked(pt.x + 2, 0, pt.z, false)
				end

				if #TheSim:FindEntities(pt.x + 2, pt.y, pt.z + 2, range, {"floodblocker"}) then
					ground.Flooding:SetIsPositionBlocked(pt.x + 2, 0, pt.z + 2, false)
				end

				if #TheSim:FindEntities(pt.x + 2, pt.y, pt.z - 2, range, {"floodblocker"}) then
					ground.Flooding:SetIsPositionBlocked(pt.x + 2, 0, pt.z - 2, false)
				end

				--Minus 2 X
				if #TheSim:FindEntities(pt.x - 2, pt.y, pt.z, range, {"floodblocker"}) <= 0 then
					ground.Flooding:SetIsPositionBlocked(pt.x - 2, 0, pt.z, false)
				end

				if #TheSim:FindEntities(pt.x - 2, pt.y, pt.z + 2, range, {"floodblocker"}) then
					ground.Flooding:SetIsPositionBlocked(pt.x - 2, 0, pt.z + 2, false)
				end

				if #TheSim:FindEntities(pt.x - 2, pt.y, pt.z - 2, range, {"floodblocker"}) then
					ground.Flooding:SetIsPositionBlocked(pt.x - 2, 0, pt.z - 2, false)
				end

			end
			
			local x, y = ground.Map:GetTileCoordsAtPoint(pt.x, pt.y, pt.z)

			ground.Map:SetTile( x, y, basetile )
			ground.Map:RebuildLayer( original_tile_type, x, y )
			ground.Map:RebuildLayer( basetile, x, y )

			if GetWorld().components.flooding and GetWorld().components.flooding.mode == "tides" then
				setTileBlocking(false, pt)
			end
			
			local minimap = TheSim:FindFirstEntityWithTag("minimap")
			if minimap then
				minimap.MiniMap:RebuildLayer( original_tile_type, x, y )
				minimap.MiniMap:RebuildLayer( basetile, x, y )
			end
			
			SpawnTurf( GROUND_TURFS[original_tile_type], pt )
			return true		
		else			
			if GetWorld().components.flooding.mode == "tides" then
				setTileBlocking(true, pt)			
			end
			
		end
	end
end


return Terraformer
