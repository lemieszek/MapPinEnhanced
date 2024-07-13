---@class MapPinEnhanced
local MapPinEnhanced = select(2, ...)

---@class MapPinEnhancedEditorMixin : Frame
---@field TitleContainer Frame
---@field SetTitle function
MapPinEnhancedEditorMixin = {}




function MapPinEnhancedEditorMixin:OnLoad()
    self:SetTitle("Map Pin Enhanced")
    self:SetScript("OnMouseDown", function()
        if (not self:IsMovable()) then
            return
        end
        if (not self.TitleContainer:IsMouseOver()) then
            return
        end
        self:StartMoving()
    end)

    self:SetScript("OnMouseUp", function()
        self:StopMovingOrSizing()
    end)
end
