local Widget = require "widgets/widget"
local HoverText = require "widgets/hoverer"

local ItemSlot = Class(Widget, function(self, atlas, bgim, owner)
    Widget._ctor(self, "ItemSlot")
    self.owner = owner
    self.bgimage = self:AddChild(Image(atlas, bgim))
    self.tile = nil
    self.prevTile = nil
    self.controlDownTime = 0.0
end)

function ItemSlot:Highlight()
	if not self.big then
		self:ScaleTo(1, 1.3, .125)
		self.big = true	
	end
end

function ItemSlot:DeHighlight()
    if self.big then    
        self:ScaleTo(1.3, 1, .25)
        self.big = false
    end
end

function ItemSlot:OnGainFocus()
    if GetPlayer().HUD.controls.inv.disableChildFocus then
        return
    end

	self:Highlight()

end

function ItemSlot:OnLoseFocus()
	self:DeHighlight()
    self.prevTile = nil
end

function ItemSlot:DoControl(control)
end

function ItemSlot:OnControl(control, down)
    if ItemSlot._base.OnControl(self, control, down) then return true end

    local hover = self.owner.HUD.controls.hover

    if down then
        self.prevTile = self.tile
        self.controlDownTime = GetTime()

        -- Set as active slot to be able of retrieve near actions
        self.owner.HUD.controls.inv:SelectSlot(self)

        return self:DoControl(control)
    else

        local checkActions = false
        local hadTile = true
        if not self.tile then
            hadTile = false
            self:DoControl(CONTROL_ACCEPT)
            if self.tile and self.prevTile and self.tile.item == self.prevTile.item then
                checkActions = true
            end
        elseif self.prevTile or GetPlayer().components.inventory:GetActiveItem() then
            checkActions = true
        end

        if checkActions then
            if TheInput:IsZoomHudEnabled() or (not TheInput:IsControlPressed(CONTROL_MOVE_LEFT) and not TheInput:IsControlPressed(CONTROL_MOVE_RIGHT) and not TheInput:IsControlPressed(CONTROL_MOVE_UP) and not TheInput:IsControlPressed(CONTROL_MOVE_DOWN)) then
                local act1, act2 = self.tile:GetActions()
                if act1 or act2 then
                    if act2 and not act1 then
                        act1 = act2
                        act2 = nil
                    end

    				local numElements = 1

                    hover.item = self
                    hover.highlightedAction = -1
                    local pos = self:GetWorldPosition()


                    if act1 then
                        hover.menuFirstAction = act1
                    end

                    if act2 then
                        hover.menuSecondAction = act2
                        if act2.action == ACTIONS.CASTSPELL then
                            hover.menuSecondAction = nil
                        end
    					numElements = 2
                    end

                    GetPlayer().components.playercontroller:UpdateControllerInteractionTarget(.2)
                    local act3 = nil
                    local is_equip = self.tile and self.tile.item and self.tile.item.components.equippable and self.tile.item.components.equippable:IsEquipped()
                    if not is_equip then
                        act3 = GetPlayer().components.playercontroller:GetItemUseActionRecursive(self.tile.item)
                        if not act3 then
                            print("sadly no add fuel found")
                        end
                    end
                    local plantAct = nil
                    if self.tile.item.components.deployable then
                        plantAct = BufferedAction(GetPlayer(), nil, ACTIONS.TOGGLE_PLANT_MODE, self.tile.item)
                        plantAct.plantTile = self.tile
                    end
                    plantAct = nil -- plant mode was deprecated

                    local splitAct = nil
                    if self.tile.item.components.stackable and self.tile.item.components.stackable:StackSize() > 1 then
                        splitAct = BufferedAction(GetPlayer(), nil, ACTIONS.SPLITSTACK, self.tile.item)
                    end

    				
    				
                    if act3 then
                        if act2 then
                            hover.menuThirdAction = act3
    						numElements = 2
                        else
                            hover.menuSecondAction = act3
                            hover.menuThirdAction = splitAct
    						numElements = 3
                        end
                    elseif splitAct then
                        if act2 then
                            hover.menuThirdAction = splitAct
    						numElements = 3
                        else
                            hover.menuSecondAction = splitAct
    						numElements = 2
                        end
                    end
                    hover:StartMenu(self.tile.item.name)
    				
    				if numElements == 3 and pos.y > 306 then
    					hover:UpdatePosition(pos.x, 306)
    				elseif numElements == 2 and pos.y > 386 then
    					hover:UpdatePosition(pos.x, 386)
    				elseif numElements == 1 and pos.y > 483 then
    					hover:UpdatePosition(pos.x, 483)
    				else
    					hover:UpdatePosition(pos.x, pos.y)
    				end
                    
                elseif hadTile then
                    self:DoControl(CONTROL_ACCEPT)
                end
            end
        else
            print("this situation")
            if not TheInput:IsZoomHudEnabled() then
                GetPlayer().HUD.controls.inv:ClosePhoneInventory()
                GetPlayer().HUD.controls.inv:ClearFocus()
            end
        end

        self.OnLoseFocus(self)
        return true
    end
end

function ItemSlot:DoMenu()

    local hover = self.owner.HUD.controls.hover
    if hover.highlightedAction == 0 then
        if hover.menuFirstAction then
            GetPlayer().components.locomotor:PushAction(hover.menuFirstAction, true)
            return true
        else
            self:DoControl(CONTROL_ACCEPT)
        end
    elseif hover.highlightedAction == 1 then
        if hover.menuSecondAction then
            GetPlayer().components.locomotor:PushAction(hover.menuSecondAction, true)
            return true
        end
    elseif hover.highlightedAction == 2 then
        if hover.menuThirdAction then
            GetPlayer().components.locomotor:PushAction(hover.menuThirdAction, true)
            return true
        end
    else
        -- canceled action, return item to inventory (if any)
        local active_item = self.owner.components.inventory:GetActiveItem()
        if active_item and active_item.components.inventoryitem and active_item.components.inventoryitem.owner then
            self.owner.components.inventory:ReturnActiveItem()
        end
    end
end

function ItemSlot:GetMenuStrings()
    local str = nil
    local secondarystr = nil
    local name = nil
    if self.tile then
        name, str, secondarystr = self.tile:GetDescriptionStrings()
        if not str then
            str = secondarystr
            secondarystr = nil
        end
    end

    return str, secondarystr
end

function ItemSlot:SetTile(tile)
    if self.tile and tile ~= self.tile then
        self.tile = self.tile:Kill()
    end

    if tile then
        self.tile = self:AddChild(tile)
    end
end

function ItemSlot:Inspect()
    if self.tile and self.tile.item then
        GetPlayer().components.locomotor:PushAction(BufferedAction(GetPlayer(), self.tile.item, ACTIONS.LOOKAT), true)
    end
end

return ItemSlot

