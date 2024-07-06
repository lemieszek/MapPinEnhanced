---@class MapPinEnhanced
local MapPinEnhanced = select(2, ...)



---@class MapPinEnhancedTrackerScrollFrame : ScrollFrame
---@field Child Frame
---@field SetPanExtent fun(self:MapPinEnhancedTrackerScrollFrame, extent:number)


---@alias TrackerView 'pins' | 'sets'


---@class MapPinEnhancedTrackerMixin : Frame
---@field title FontString
---@field entries table<number, MapPinEnhancedTrackerSetEntryMixin> | table<number, MapPinEnhancedTrackerPinEntryMixin>
---@field scrollFrame MapPinEnhancedTrackerScrollFrame
---@field activeView TrackerView
---@field viewToggle Button
MapPinEnhancedTrackerMixin = {}
MapPinEnhancedTrackerMixin.entries = {}


local ENTRY_GAP = 5
local ENTRY_HEIGHT = 40
function MapPinEnhancedTrackerMixin:RestorePosition()
    local trackerPosition = MapPinEnhanced:GetVar("trackerPosition") ---@as table
    if trackerPosition then
        self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", trackerPosition.x, trackerPosition.y)
    else
        local defaultPosition = MapPinEnhanced:GetDefault("trackerPosition")
        if not defaultPosition then
            defaultPosition = {
                ["x"] = (GetScreenWidth() / 2) - 200,
                ["y"] = (GetScreenHeight() / 2) - 200
            }
        end
        self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", defaultPosition.x, defaultPosition.y)
    end
end

function MapPinEnhancedTrackerMixin:SetTrackerTitle(title)
    self.title:SetText(title)
end

function MapPinEnhancedTrackerMixin:ClearEntries()
    for _, entry in ipairs(self.entries) do
        entry:Hide()
        entry:ClearAllPoints()
    end
    self.entries = {}
end

function MapPinEnhancedTrackerMixin:GetActiveView()
    return self.activeView
end

---comment
---@param viewType TrackerView
function MapPinEnhancedTrackerMixin:SetActiveView(viewType)
    if self.activeView == viewType then
        return
    end
    self:ClearEntries()
    if viewType == "pins" then
        ---@class PinManager : Module
        local PinManager = MapPinEnhanced:GetModule("PinManager")
        local pins = PinManager:GetPins()
        for _, pin in pairs(pins) do
            table.insert(self.entries, pin.TrackerPinEntry)
        end
        self:SetTrackerTitle("Pins")
    elseif viewType == "sets" then
        -- self:AddMultipleEntries(MapPinEnhanced.SetManager:GetAllSetEntries())
        self:SetTrackerTitle("Sets")
    end
    self.activeView = viewType
    self:UpdateEntriesPosition()
end

function MapPinEnhancedTrackerMixin:Close()
    self:Hide()
    MapPinEnhanced:SaveVar("trackerVisible", false)
end

function MapPinEnhancedTrackerMixin:Open()
    self:Show()
    MapPinEnhanced:SaveVar("trackerVisible", true)
end

function MapPinEnhancedTrackerMixin:Toggle()
    if self:IsShown() then
        self:Close()
    else
        self:Open()
    end
end

function MapPinEnhancedTrackerMixin:OnLoad()
    self:RestorePosition()
    self.scrollFrame:SetPanExtent(ENTRY_HEIGHT + ENTRY_GAP)

    self.viewToggle:SetScript("OnClick", function()
        if self.activeView == "pins" then
            self:SetActiveView("sets")
        else
            self:SetActiveView("pins")
        end
    end)
    -- set default view
    self:SetActiveView("pins")
end

function MapPinEnhancedTrackerMixin:OnMouseDown()
    self:StartMoving()
end

function MapPinEnhancedTrackerMixin:OnMouseUp()
    self:StopMovingOrSizing()
    local top = self:GetTop()
    local left = self:GetLeft()
    MapPinEnhanced:SaveVar("trackerPosition", { x = left, y = top })
end

function MapPinEnhancedTrackerMixin:UpdateEntriesPosition()
    local height = 0
    for i, entry in ipairs(self.entries) do
        entry:ClearAllPoints()
        entry:SetParent(self.scrollFrame.Child)
        if i == 1 then
            entry:SetPoint("TOPLEFT", self.scrollFrame.Child, "TOPLEFT", 0, 0)
        else
            entry:SetPoint("TOPLEFT", self.entries[i - 1], "BOTTOMLEFT", 0, -ENTRY_GAP)
        end
        height = height + ENTRY_HEIGHT + ENTRY_GAP --[[@as number]]
        entry:Show()
    end
    self.scrollFrame.Child:SetHeight(height)
end

---@param entry Frame
function MapPinEnhancedTrackerMixin:AddEntry(entry)
    table.insert(self.entries, entry)
    local scollChildHeight = self.scrollFrame.Child:GetHeight()
    entry:ClearAllPoints()
    if #self.entries == 1 then
        entry:SetPoint("TOPLEFT", self.scrollFrame.Child, "TOPLEFT", 0, 0)
    else
        entry:SetPoint("TOPLEFT", self.entries[#self.entries - 1], "BOTTOMLEFT", 0, -ENTRY_GAP)
    end
    entry:SetParent(self.scrollFrame.Child)
    entry:Show()
    self.scrollFrame.Child:SetHeight(scollChildHeight + ENTRY_HEIGHT + ENTRY_GAP)
end
