require "class"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local MouseCrafting = require "widgets/mousecrafting"
local ControllerCrafting = require "widgets/controllercrafting"

local base_scale = .75
if IPHONE_VERSION then
    base_scale = .58
end
local selected_scale = .9
local HINT_UPDATE_INTERVAL = 2.0 -- once per second
local SCROLL_REPEAT_TIME = .15
local MOUSE_SCROLL_REPEAT_TIME = 0

local CLOSED_MENU_TOP = 122
local OPEN_MENU_TOP = 170
local SCROLL_LIMIT_START = 90
local SCROLL_LIMIT_END = -210

local wasTouching = true

local tab_bg = 
{
    normal = "tab_normal.tex",
    selected = "tab_selected.tex",
    highlight = "tab_highlight.tex",
    bufferedhighlight = "tab_place.tex",
    overlay = "tab_researchable.tex",
}


local CraftTabs = Class(Widget, function(self, owner, top_root)
    
    Widget._ctor(self, "CraftTabs")
    self.owner = GetPlayer()    
	self.owner = owner


	self.craft_idx_by_tab = {}

    self:SetPosition(0,25,0)

    --[[self.craftroot = self:AddChild(Widget("craftroot"))
	self.craftroot:SetVAnchor(ANCHOR_TOP)
    self.craftroot:SetHAnchor(ANCHOR_MIDDLE)
    self.craftroot:SetScaleMode(SCALEMODE_PROPORTIONAL)
    
    self.controllercrafting = self.craftroot:AddChild(ControllerCrafting())
    --]]
    self.controllercrafting = self:AddChild(ControllerCrafting())
	self.controllercrafting:Hide()

    self.crafting = self:AddChild(MouseCrafting(self))
    self.crafting:Hide()
    self.bg = self:AddChild(Image("images/hud.xml", "craft_bg.tex"))      
    
    self.bg_cover = self:AddChild(Image("images/hud.xml", "craft_bg_cover.tex"))
    self.bg_cover:SetPosition(-38, 0, 0)
    self.bg_cover:SetClickable(false)

    self.tabs = self:AddChild(TabGroup())
    self.tabs:SetPosition(-16,0,0)

    self.tabs.onopen = function() self.owner.SoundEmitter:PlaySound("dontstarve/HUD/craft_open") end
    self.tabs.onchange = function() self.owner.SoundEmitter:PlaySound("dontstarve/HUD/craft_open") end
    self.tabs.onclose = function() self.owner.SoundEmitter:PlaySound("dontstarve/HUD/craft_close") end
    self.tabs.onhighlight = function() self.owner.SoundEmitter:PlaySound("dontstarve/HUD/recipe_ready") return .2 end
    self.tabs.onalthighlight = function() end
    self.tabs.onoverlay = function() self.owner.SoundEmitter:PlaySound("dontstarve/HUD/research_available") return .2 end
    
    local is_shipwrecked = SaveGameIndex:IsModeShipwrecked()

    local tabnames = {}
    for k,v in pairs(RECIPETABS) do
    	if (is_shipwrecked and v.str ~= "ANCIENT") or (not is_shipwrecked and v.str ~= "NAUTICAL" and v.str ~= "OBSIDIAN") then
    		table.insert(tabnames, v)
    	end
    end

    for k,v in pairs(owner.components.builder.custom_tabs) do
        table.insert(tabnames, v)
    end

    table.sort(tabnames, function(a,b) return a.sort < b.sort end)
    
    self.tab_order = {}

    self.tabs.spacing = 750/#tabnames
    
    self.tabbyfilter = {}
    for k,v in ipairs(tabnames) do
        local tab = self.tabs:AddTab(STRINGS.TABS[v.str], resolvefilepath("images/hud.xml"), v.icon_atlas or resolvefilepath("images/hud.xml"), v.icon, tab_bg.normal, tab_bg.selected, tab_bg.highlight, tab_bg.bufferedhighlight, tab_bg.overlay,
            
            function() --select fn
                if not self.controllercraftingopen then
	                
            		if self.craft_idx_by_tab[k] then
            			self.crafting.idx = self.craft_idx_by_tab[k]
            		end

	                self.crafting:SetFilter( 
	                    function(recipe)
	                        local rec = GetRecipe(recipe)
	                        return rec and rec.tab == v
	                    end)
                
															                
					self.crafting:Open()
                end
            end, 

            function() --deselect fn
            	self.craft_idx_by_tab[k] = self.crafting.idx
                if not IPHONE_VERSION then
                    self.crafting:Close()
                end
            end)
        tab.filter = v
        tab.icon = v.icon
        tab.icon_atlas = v.icon_atlas or resolvefilepath("images/hud.xml")
        tab.tabname = STRINGS.TABS[v.str]
        self.tabbyfilter[v] = tab
        
        table.insert(self.tab_order, tab)
    end
    
    self.inst:ListenForEvent("techtreechange", function(inst, data) self:UpdateRecipes() end, self.owner)
    self.inst:ListenForEvent("itemget", function(inst, data) self:UpdateRecipes() end, self.owner)
    self.inst:ListenForEvent("itemlose", function(inst, data) self:UpdateRecipes() end, self.owner)
    self.inst:ListenForEvent("stacksizechange", function(inst, data) self:UpdateRecipes() end, self.owner)
    self.inst:ListenForEvent("unlockrecipe", function(inst, data) self:UpdateRecipes() end, self.owner)
    self:DoUpdateRecipes()
    self:SetScale(base_scale, base_scale, base_scale)
    self:StartUpdating()
    
	self.openhint = self:AddChild(Text(UIFONT, 40))
	self.openhint:SetPosition(10+150, 430, 0)
	self.openhint:SetRegionSize(300, 45, 0)
	self.openhint:SetHAlign(ANCHOR_LEFT)

    self.hint_update_check = HINT_UPDATE_INTERVAL
    
    local pos = self:GetPosition()
    self.originalY = pos.y -- Original position of the inventory

    if IPHONE_VERSION then
        
        self.scrollY = 0 -- Total offset in the X axis from the original position
        self.baseScroll = 0 -- The scroll offset when the scroll started
        self.startScrollY = 0 -- The touch position when the scroll started
        self.scrollHoldTime = 0 -- Time the user holds the scroll without moving
        self.scrollState = SCROLL_NONE -- see constants.luatiles from scaling
    end

end)


function CraftTabs:Close()
	self.crafting:Close()
	self.controllercrafting:Close()

	self.tabs:DeselectAll()
	self.controllercraftingopen = false
    self.phonecraftingopen = false
end

function CraftTabs:CloseControllerCrafting()
    if self.controllercraftingopen then
        --self:ScaleTo(selected_scale, base_scale, .15)
        --self.blackoverlay:Hide()
        self.controllercraftingopen = false
        self.open = false
        self.tabs:DeselectAll()
        self.controllercrafting:Close()
    end
end

function CraftTabs:OpenControllerCrafting()
    --self.parent:AddChild(self.controllercrafting)
    
    if not self.open then
        --self:ScaleTo(base_scale, selected_scale, .15)
        --self.blackoverlay:Show()
        self.controllercraftingopen = true
        self.open = true
        self.crafting:Close()   
        self.controllercrafting:Open()  
    end
end

function CraftTabs:OnUpdate(dt)
    if IPHONE_VERSION and not TheInput:ControllerAttached() then
        self:UpdateScrolling(dt)
    end
	
	self.hint_update_check = self.hint_update_check - dt
	if 0 > self.hint_update_check then	
	   	if not TheInput:ControllerAttached() then
			self.openhint:Hide()
		else
			self.openhint:Show()
		    self.openhint:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_OPEN_CRAFTING))
		end
	    self.hint_update_check = HINT_UPDATE_INTERVAL
	end

    if IPHONE_VERSION and not TheInput:ControllerAttached() then
        local hudEntity = TheInput:GetHUDEntityUnderMouse()
        local y = TheInput:GetScreenPosition().y
        if not hudEntity and not self.scrolling then
            if not TheInput:IsTouchDown() and wasTouching then
                self:ClosePhoneCraftTabs()
            end
        end
    else
        local hudEntity = TheInput:GetHUDEntityUnderMouse()
        if self.crafting.open then
            local x = TheInput:GetScreenPosition().x
            local w,h = TheSim:GetScreenSize()
            if not hudEntity then
                self.crafting:Close()
                self.tabs:DeselectAll()
            end
        end
    end

	if self.needtoupdate then
		self:DoUpdateRecipes()
	end
	
    wasTouching = TheInput:IsTouchDown()
end

function CraftTabs:OpenTab(idx)
	return self.tabs:OpenTab(idx)
end


function CraftTabs:GetCurrentIdx()
	return self.tabs:GetCurrentIdx()
end

function CraftTabs:GetNextIdx()
	return self.tabs:GetNextIdx()
end

function CraftTabs:GetPrevIdx()
	return self.tabs:GetPrevIdx()
end


function CraftTabs:UpdateRecipes()
    self.needtoupdate = true
end

function CraftTabs:DoUpdateRecipes()
	if self.needtoupdate then

		self.needtoupdate = false	
		local tabs_to_highlight = {}
		local tabs_to_alt_highlight = {}
		local tabs_to_overlay = {}
		local valid_tabs = {}
	    
		for k,v in pairs(self.tabbyfilter) do
			tabs_to_highlight[v] = 0
			tabs_to_alt_highlight[v] = 0
			tabs_to_overlay[v] = 0
			valid_tabs[v] = false
		end
	    
		if self.owner.components.builder then
			local current_research_level = self.owner.components.builder.accessible_tech_trees or NO_TECH
			
			local recipes = GetAllRecipes(true)
			for k,rec in pairs(recipes) do

				-- Shipwrecked recipes are still created, but their tabs are skipped
				-- That's why this check is here
				if self.tabbyfilter[rec.tab] ~= nil then

					local tab = self.tabbyfilter[rec.tab]
					local has_researched = self.owner.components.builder:KnowsRecipe(rec.name)
					
					local can_see = has_researched or CanPrototypeRecipe(rec.level, current_research_level)
					local can_build = self.owner.components.builder:CanBuild(rec.name)
					local buffered_build = self.owner.components.builder:IsBuildBuffered(rec.name)
					local can_research = false
					
					can_research = not has_researched and can_build and CanPrototypeRecipe(rec.level, current_research_level)
		            
		            valid_tabs[tab] = valid_tabs[tab] or can_see

		            if buffered_build and has_researched then
						if tab then
							tabs_to_alt_highlight[tab] = 1 + (tabs_to_alt_highlight[tab] or 0)
						end
		            end
		            
					if can_build and has_researched then
						if tab then
							tabs_to_alt_highlight[tab] = 0 -- Highlight takes precedence
							tabs_to_highlight[tab] = 1 + (tabs_to_highlight[tab] or 0)
						end
					end
		            
					if can_research then
						if tab then
							tabs_to_overlay[tab] = 1 + (tabs_to_overlay[tab] or 0)
						end
					end
				end
			end
		end

		local to_select = nil
		local current_open = nil

		
		for k,v in pairs(valid_tabs) do
			if v then
				self.tabs:ShowTab(k)
			else
				self.tabs:HideTab(k)
			end
		end
		

		for k,v in pairs(tabs_to_highlight) do    
			if v > 0 and (not self.tabs_to_highlight or v ~= self.tabs_to_highlight[k]) then
				k:Highlight(v)
			end 
		end

		for k,v in pairs(tabs_to_alt_highlight) do
			if v > 0 and tabs_to_highlight[k] <= 0 then
				k:UnHighlight(true)
				k:AlternateHighlight(v)
			end 
		end

		for k,v in pairs(tabs_to_highlight) do
			for m,n in pairs(tabs_to_alt_highlight) do
				if k == m then
					if v <= 0 and n <= 0 then
						k:UnHighlight()
					end
				end
			end
		end
	    
		for k,v in pairs(tabs_to_overlay) do    
			if v > 0 then
				k:Overlay()
			else
				k:HideOverlay()
			end
		end    
	    
		if self.crafting and self.crafting.shown then
			self.crafting:UpdateRecipes()
		end

		self.tabs_to_highlight = tabs_to_highlight
	end
end

function CraftTabs:IsCraftingOpen()
    return self.crafting.open or self.controllercraftingopen
end

function CraftTabs:OnControl(control, down)
    if IPHONE_VERSION and not TheInput:ControllerAttached()then
        if not self.open and down and not self.owner.HUD.controls.virtualstick.dragging then
            self:OpenPhoneCraftTabs()
            return
        end

        if self.open and down then
            self.autoScroll = false
        end

        if self.open and not down and (self.scrollState == SCROLL_HOLD or self.scrollState == SCROLL_INVALID) then
            self.scrollState = SCROLL_INVALID
            -- We don't want to lose the down interaction
            CraftTabs._base.OnControl(self, control, true)
        elseif self.scrollState == SCROLL_HOLD or self.scrollState == SCROLL_MOVING or self:WillScroll() then
            return
        end
    end

    if not IPHONE_VERSION or self.open then
        if CraftTabs._base.OnControl(self, control, down) then return true end
    end
end





function CraftTabs:OpenPhoneCraftTabs()
    if IPHONE_VERSION and not TheInput:ControllerAttached()then
        if self.crafting.parent == self then
            self.parent:AddChild(self.crafting)
        end
    end
    if not self.open then
        self.owner.HUD.isLastOpenInventory = false
        GetPlayer().HUD:CloseInventory()
        self:HideHUD()

        self.owner.HUD.controls:SetDark(true)
        SetPause(true, "craft")
        self.opening = true

        self:ScaleTo(base_scale,selected_scale,.2)

        self.scrollHoldTime = 0.0

        local touchPos = TheInput:GetScreenPosition()
        local inventoryPos = self:GetWorldPosition()

        -- The scroll starts where the touch is! TODO: Is not 100% accurate
        local dist = touchPos.y - inventoryPos.y
        local scaledDist = dist * (selected_scale / base_scale)

        self.scrollY = -(scaledDist - dist)
        self.scrollY = math.max(SCROLL_LIMIT_END, self.scrollY)
        self.scrollY = math.min(SCROLL_LIMIT_START, self.scrollY)
        self:MoveTo(self:GetPosition(), self:GetPosition() + Vector3(0, self.scrollY, 0), .2, function() self.open = true self.phonecraftingopen = true self.opening = false end)

        self.baseScroll = self.scrollY
        GetPlayer().components.talker:ShutUp()
    end
end

function CraftTabs:ClosePhoneCraftTabs()
    if self.open then
        self:ShowHUD()
        self.owner.HUD.controls:SetDark(false)
        SetPause(false)
        self.open = false
        self.opening = true
        self.phonecraftingopen = false
        self:ScaleTo(selected_scale, base_scale,.1)

        local pos = self:GetPosition()
        self:MoveTo(pos, Vector3(pos.x, self.originalY, pos.z), .1, function() self.opening = false end)

        if self.crafting.open then
            self.crafting:Close()
            self.tabs:DeselectAll()
        end
    end
end




function CraftTabs:UpdateScrolling(dt)

    local pos = self:GetPosition()
    if self.open then
        local screenPos = TheInput:GetScreenPosition()
        if TheInput:IsTouchDown() and screenPos.x < OPEN_MENU_TOP then --
            if self.scrollState == SCROLL_NONE then -- start scrolling
                self.scrollState = SCROLL_HOLD
                self.startScrollY = screenPos.y
                self.baseScroll = self.scrollY
                self.scrollHoldTime = 0.0
            end
            local delta = (screenPos.y - self.startScrollY)
            if self.scrollState == SCROLL_HOLD then
                if(delta == 0) then
                    self.scrollHoldTime = self.scrollHoldTime + dt
                else
                    self.scrollState = SCROLL_MOVING
                    self.scrollVelocity = 0
                    self.scrollAmplitude = 0
                end
            end
            if self.scrollState == SCROLL_MOVING then
                local oldScrollY = self.scrollY

                self.scrollY = self.baseScroll + delta
                if self.scrollY > SCROLL_LIMIT_START then
                    self.scrollY = SCROLL_LIMIT_START
                elseif self.scrollY < SCROLL_LIMIT_END then
                    self.scrollY = SCROLL_LIMIT_END
                end

                local frameDelta = self.scrollY - oldScrollY
                local v = 10 * frameDelta / (1 + dt);
                self.scrollVelocity = 0.8 * v + 0.2 * self.scrollVelocity;
            end
        elseif not TheInput:IsTouchDown() then

            if self.open and self.scrollState == SCROLL_MOVING then
                if self.scrollVelocity > 10 or self.scrollVelocity < -10 then
                    self.scrollAmplitude = 0.8 * self.scrollVelocity;
                    self.scrollTarget = math.floor((self.scrollY + self.scrollAmplitude) + 0.5);
                    self.autoScroll = true
                    self.autoScrollDt = 0.0
                end
            end

            if self.autoScroll and self.scrollAmplitude ~= 0 then
                self.autoScrollDt = self.autoScrollDt + dt
                local delta = -self.scrollAmplitude * math.exp(-self.autoScrollDt / 0.325)
                if delta > 0.5 or delta < -0.5 then
                    self.scrollY = self.scrollTarget + delta
                    if self.scrollY > SCROLL_LIMIT_START then
                        self.scrollY = SCROLL_LIMIT_START
                        self.autoScroll = false
                    elseif self.scrollY < SCROLL_LIMIT_END then
                        self.scrollY = SCROLL_LIMIT_END
                        self.autoScroll = false
                    end
                else
                    self.scrollY = self.scrollTarget
                    self.autoScroll = false
                end
            end

        end

        self:SetPosition(pos.x, self.originalY + self.scrollY, 0)
    elseif not self.opening then
        self:SetPosition(pos.x, self.originalY, 0)
    end

    if not TheInput:IsTouchDown() then
        self.scrollState = SCROLL_NONE
    end
end

function CraftTabs:WillScroll()
    local screenPos = TheInput:GetScreenPosition()
    if screenPos.y < OPEN_MENU_TOP and self.scrollState == SCROLL_NONE then
        return true
    end
end

function CraftTabs:ShowHUD()
    self.owner.HUD.controls.status:Show()
    if not GetWorld():IsCave() then
        self.owner.HUD.controls.clock:Show()
    end
    self.owner.HUD.controls:ShowActionControls()
    self.owner.HUD.controls:ShowRecordControls()
    self.owner.HUD.controls:ShowVirtualStick()
    self.owner.HUD.controls.mapcontrols:Show()
end

function CraftTabs:HideHUD()
    self.owner.HUD.controls.status:Hide()
    self.owner.HUD.controls.clock:Hide()
    self.owner.HUD.controls.actioncontrols:Hide()
    self.owner.HUD.controls:HideVirtualStick()
    self.owner.HUD.controls.mapcontrols:Hide()
end

return CraftTabs
