local ItemSlot = require "widgets/itemslot"

local EquipSlot = Class(ItemSlot, function(self, equipslot, atlas, bgim, owner)
    ItemSlot._ctor(self, atlas, bgim, owner)
    self.owner = owner
    self.equipslot = equipslot
    self.highlight = false

    self.inst:ListenForEvent("newactiveitem", function(inst, data)
        if data.item and data.item.components.equippable and data.item.components.equippable.equipslot == self.equipslot then
            self:ScaleTo(1, 1.3, .125)
            self.highlight = true
        elseif self.highlight then
            self.highlight = false
            self:ScaleTo(1.3, 1, .125)
        end
    end, self.owner)
end)

function EquipSlot:Click()
    self:DoControl(CONTROL_ACCEPT)
end

function EquipSlot:DoControl(control)
    if control == CONTROL_ACCEPT then
        local active_item = GetPlayer().components.inventory:GetActiveItem()
        if active_item and active_item.components.equippable and active_item.components.equippable.equipslot == self.equipslot then
            local inventory = GetPlayer().components.inventory
            GetPlayer().components.inventory:Equip(active_item, false)
        elseif self.tile and not active_item then
            self.owner.components.inventory:SelectActiveItemFromEquipSlot(self.equipslot)
            self.owner.components.inventory.activeitemcontainer = nil
            self.owner.components.inventory.activeitemslot = nil
        end

        return true
    elseif control == CONTROL_SECONDARY and self.tile and self.tile.item then
        GetPlayer().components.inventory:UseItemFromInvTile(self.tile.item)
        return true
    end
end

return EquipSlot