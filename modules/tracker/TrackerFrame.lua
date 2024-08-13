-- Template: file://./TrackerFrame.xml
---@class MapPinEnhanced
local MapPinEnhanced = select(2, ...)

---@class MapPinEnhancedTrackerScrollBar : Frame
---@field Update fun(self:MapPinEnhancedTrackerScrollBar)

---@class MapPinEnhancedTrackerScrollFrameChild : Frame
---@field importButton MousePropagatableButton
---@field importEditBox ScrollableTextarea
---@field cancelButton MousePropagatableButton

---@class MapPinEnhancedTrackerScrollFrame : ScrollFrame
---@field Child MapPinEnhancedTrackerScrollFrameChild
---@field SetPanExtent fun(self:MapPinEnhancedTrackerScrollFrame, extent:number)
---@field ScrollBar MapPinEnhancedTrackerScrollBar


---@class MapPinEnhancedTrackerHeader : Frame
---@field title FontString
---@field viewToggle Button
---@field editorToggle Button
---@field closebutton Button
---@field headerTexture Texture


---@alias TrackerView 'Pins' | 'Sets' | 'Import'

---@class MapPinEnhancedTrackerFrameMixin : Frame
---@field entries table<number, MapPinEnhancedTrackerSetEntryMixin> | table<number, MapPinEnhancedTrackerPinEntryMixin>
---@field scrollFrame MapPinEnhancedTrackerScrollFrame
---@field activeView TrackerView
---@field header MapPinEnhancedTrackerHeader
---@field blackBackground Texture
---@field showNumbering boolean?
MapPinEnhancedTrackerFrameMixin = {}
MapPinEnhancedTrackerFrameMixin.entries = {}

local ENTRY_GAP = 5
local DEFAULT_ENTRY_HEIGHT = 37
function MapPinEnhancedTrackerFrameMixin:RestorePosition()
    local trackerPosition = MapPinEnhanced:GetVar("trackerPosition") ---@as table
    if trackerPosition then
        self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", trackerPosition.x, trackerPosition.y)
    else
        local defaultPosition = MapPinEnhanced:GetDefault("trackerPosition")
        if not defaultPosition then
            defaultPosition = {
                ["x"] = (GetScreenWidth() / 2) - self:GetWidth() / 2,
                ["y"] = -(GetScreenHeight() / 2) - self:GetHeight() / 2
            }
        end
        self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", defaultPosition.x, defaultPosition.y)
        MapPinEnhanced:SaveVar("trackerPosition", defaultPosition)
    end
end

function MapPinEnhancedTrackerFrameMixin:SetTrackerTitle(title)
    self.header.title:SetText(title)
end

function MapPinEnhancedTrackerFrameMixin:ClearEntries()
    for _, entry in ipairs(self.entries) do
        entry:Hide()
        entry:ClearAllPoints()
        entry:SetParent(nil)
    end
    self.entries = {}
end

function MapPinEnhancedTrackerFrameMixin:GetActiveView()
    return self.activeView
end

function MapPinEnhancedTrackerFrameMixin:UpdateVisibility()
    if self:GetActiveView() ~= "Pins" then return end
    local autoVisibility = MapPinEnhanced:GetVar("Tracker", "autoVisibility") --[[@as 'none' | 'autoHide' | 'autoShow' | 'both']]
    local entryCount = self:GetEntryCount()
    if autoVisibility == "none" then return end
    if (autoVisibility == "autoHide" or autoVisibility == "both") and entryCount == 0 then
        self:Close()
        return
    end
    if (autoVisibility == "autoShow" or autoVisibility == "both") and entryCount > 0 then
        self:Open()
        return
    end
end

---@param forceUpdate? boolean force an update
function MapPinEnhancedTrackerFrameMixin:SetPinView(forceUpdate)
    if self.activeView == "Pins" and not forceUpdate then return end
    self:ClearEntries()
    MapPinEnhanced.UnregisterCallback(self, 'UpdateSetList')
    local PinManager = MapPinEnhanced:GetModule("PinManager")
    local pins = PinManager:GetPinsByOrder()
    ---@type number
    for _, pin in pairs(pins) do
        table.insert(self.entries, pin.trackerPinEntry)
    end
    self:UpdatePinNumberingVisibility()
    self.activeView = "Pins"
    self:UpdateEntriesPosition()
end

---@param forceUpdate? boolean force an update
function MapPinEnhancedTrackerFrameMixin:SetSetView(forceUpdate)
    if self.activeView == "Sets" and not forceUpdate then return end
    self:ClearEntries()
    MapPinEnhanced.UnregisterCallback(self, 'UpdateSetList')
    local SetManager = MapPinEnhanced:GetModule("SetManager")
    local importButton = self.scrollFrame.Child.importButton
    importButton:Enable()
    importButton:SetScript("OnClick", function()
        self:SetImportView()
    end)
    table.insert(self.entries, importButton)
    local sets = SetManager:GetSets() ---@type table<string, SetObject | Button>
    --MapPinEnhanced.SetManager:GetAllSetEntries()
    for _, set in pairs(sets) do
        table.insert(self.entries, set.trackerSetEntry)
    end
    MapPinEnhanced.RegisterCallback(self, 'UpdateSetList', function()
        if self.activeView ~= "Sets" then return end
        self:SetSetView(true)
    end)
    self.activeView = "Sets"
    self:UpdateEntriesPosition()
end

---@param forceUpdate? boolean force an update
function MapPinEnhancedTrackerFrameMixin:SetImportView(forceUpdate)
    if self.activeView == "Import" and not forceUpdate then return end
    self:ClearEntries()
    local cancelButton = self.scrollFrame.Child.cancelButton
    local importEditBox = self.scrollFrame.Child.importEditBox
    local importButton = self.scrollFrame.Child.importButton

    cancelButton:SetScript("OnClick", function()
        self:SetSetView()
    end)
    table.insert(self.entries, cancelButton)
    table.insert(self.entries, importEditBox)

    importEditBox.editBox:SetScript("OnTextChanged", function()
        local text = importEditBox.editBox:GetText()
        if text and text ~= "" then
            importButton:Enable()
        else
            importButton:Disable()
        end
    end)
    importButton:SetScript("OnClick", function()
        local PinProvider = MapPinEnhanced:GetModule("PinProvider")
        local wayString = importEditBox.editBox:GetText()
        PinProvider:ImportFromWayString(wayString)
        self:SetPinView()
    end)
    importButton:Disable()
    table.insert(self.entries, importButton)
    self.activeView = "Import"
    self:UpdateEntriesPosition()
end

function MapPinEnhancedTrackerFrameMixin:Close()
    self:Hide()
    MapPinEnhanced:SaveVar("trackerVisible", false)
end

function MapPinEnhancedTrackerFrameMixin:Open()
    self:Show()
    MapPinEnhanced:SaveVar("trackerVisible", true)
end

function MapPinEnhancedTrackerFrameMixin:Toggle()
    if self:IsShown() then
        self:Close()
    else
        self:Open()
    end
end

function MapPinEnhancedTrackerFrameMixin:UpdatePinNumberingVisibility()
    local showNumbering = MapPinEnhanced:GetVar("Tracker", "showNumbering") --[[@as boolean]]
    if showNumbering == self.showNumbering then return end
    for _, entry in ipairs(self.entries) do
        if entry.SetEntryIndexVisibility then
            ---@cast entry MapPinEnhancedTrackerPinEntryMixin
            entry:SetEntryIndexVisibility(showNumbering)
        end
    end
    self.showNumbering = showNumbering
end

function MapPinEnhancedTrackerFrameMixin:AddOptions()
    local Options = MapPinEnhanced:GetModule("Options")
    Options:RegisterSelect({
        category = "Tracker",
        label = "Automatic Visibility",
        default = MapPinEnhanced:GetDefault("Tracker", "autoVisibility") --[[@as string]],
        init = MapPinEnhanced:GetVar("Tracker", "autoVisibility") --[[@as string]],
        options = {
            { label = "None",      value = "none",     type = "radio" },
            { label = "Auto hide", value = "autoHide", type = "radio" },
            { label = "Auto show", value = "autoShow", type = "radio" },
            { label = "Both",      value = "both",     type = "radio" }
        },
        onChange = function(value)
            MapPinEnhanced:SaveVar("Tracker", "autoVisibility", value)
        end
    })

    Options:RegisterCheckbox({
        category = "Tracker",
        label = "Lock Tracker",
        default = MapPinEnhanced:GetDefault("Tracker", "lockTracker") --[[@as boolean]],
        init = MapPinEnhanced:GetVar("Tracker", "lockTracker") --[[@as boolean]],
        onChange = function(value)
            MapPinEnhanced:SaveVar("Tracker", "lockTracker", value)
        end
    })

    Options:RegisterSlider({
        category = "Tracker",
        label = "Scale",
        default = MapPinEnhanced:GetDefault("Tracker", "trackerScale") --[[@as number]],
        init = MapPinEnhanced:GetVar("Tracker", "trackerScale") --[[@as number]],
        min = 0.5,
        max = 2,
        step = 0.05,
        onChange = function(value)
            MapPinEnhanced:SaveVar("Tracker", "trackerScale", value)
            self:SetScale(value)
        end
    })

    Options:RegisterSlider({
        category = "Tracker",
        label = "Background Opacity",
        default = MapPinEnhanced:GetDefault("Tracker", "backgroundOpacity") --[[@as number]],
        init = MapPinEnhanced:GetVar("Tracker", "backgroundOpacity") --[[@as number]],
        min = 0,
        max = 1,
        step = 0.1,
        onChange = function(value)
            MapPinEnhanced:SaveVar("Tracker", "backgroundOpacity", value)
            self.blackBackground:SetAlpha(value)
        end
    })

    Options:RegisterCheckbox({
        category = "Tracker",
        label = "Show Numbering",
        default = MapPinEnhanced:GetDefault("Tracker", "showNumbering") --[[@as boolean]],
        init = MapPinEnhanced:GetVar("Tracker", "showNumbering") --[[@as boolean]],
        onChange = function(value)
            MapPinEnhanced:SaveVar("Tracker", "showNumbering", value)
            self:UpdatePinNumberingVisibility()
        end
    })

    Options:RegisterSlider({
        category = "Tracker",
        label = "Entry Height",
        default = MapPinEnhanced:GetDefault("Tracker", "trackerHeight") --[[@as number]],
        init = MapPinEnhanced:GetVar("Tracker", "trackerHeight") --[[@as number]],
        min = 1,
        max = 14,
        step = 1,
        onChange = function(value)
            MapPinEnhanced:SaveVar("Tracker", "trackerHeight", value)
            self:UpdateEntriesPosition()
        end
    })
end

function MapPinEnhancedTrackerFrameMixin:OnLoad()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RestorePosition()
    self.scrollFrame:SetPanExtent(DEFAULT_ENTRY_HEIGHT + ENTRY_GAP)

    self.header.viewToggle:SetScript("OnClick", function()
        if self.activeView == "Pins" then
            self:SetSetView()
        else
            self:SetPinView()
        end
    end)
    -- set default view
    self:SetPinView()

    self.header.editorToggle:SetScript("OnClick", function()
        MapPinEnhanced:ToggleEditorWindow()
    end)
    self.scrollFrame.ScrollBar:SetAlpha(0)
    self:AddOptions()
end

function MapPinEnhancedTrackerFrameMixin:GetEntryCount()
    local currentView = self:GetActiveView()
    if currentView == "Pins" then
        return #self.entries
    elseif currentView == "Sets" then
        return #self.entries - 1
    end
end

function MapPinEnhancedTrackerFrameMixin:OnMouseDown(button)
    if button ~= "LeftButton" then return end
    if not self.header.title:IsMouseOver() then return end
    local isLocked = MapPinEnhanced:GetVar("Tracker", "lockTracker") --[[@as boolean]]
    if isLocked then
        MapPinEnhanced:Print("Tracker is locked. Unlock it in the options.")
        return
    end
    self:StartMoving()
    SetCursor("Interface/CURSOR/UI-Cursor-Move.crosshair")
end

function MapPinEnhancedTrackerFrameMixin:OnMouseUp(button)
    if button ~= "LeftButton" then return end
    local _, _, _, left, top = self:GetPoint()
    self:StopMovingOrSizing()
    MapPinEnhanced:SaveVar("trackerPosition", { x = left, y = top })
    self:ClearAllPoints()
    self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left, top)
    SetCursor(nil)
end

---@param scrollFrameHeight number?
function MapPinEnhancedTrackerFrameMixin:UpdateFrameHeight(scrollFrameHeight)
    local headerHeight = self.header:GetHeight()
    local newHeight = headerHeight + (scrollFrameHeight or 0)
    if self:GetActiveView() == "Import" then
        self:SetHeight(newHeight)
        return
    end
    local maxEntryCount = MapPinEnhanced:GetVar("Tracker", "trackerHeight")
    local maxHeight = (DEFAULT_ENTRY_HEIGHT + ENTRY_GAP) * maxEntryCount + ENTRY_GAP + headerHeight
    if newHeight > maxHeight then
        newHeight = maxHeight
    end
    self:SetHeight(newHeight)
    self.scrollFrame.ScrollBar:Update()
end

function MapPinEnhancedTrackerFrameMixin:UpdateEntriesPosition()
    if not self:IsVisible() then return end
    local height = ENTRY_GAP
    for i, entry in ipairs(self.entries) do
        entry:ClearAllPoints()
        entry:SetParent(self.scrollFrame.Child)
        if i == 1 then
            entry:SetPoint("TOPLEFT", self.scrollFrame.Child, "TOPLEFT", 35, -ENTRY_GAP)
            entry:SetPoint("TOPRIGHT", self.scrollFrame.Child, "TOPRIGHT", 25, -ENTRY_GAP)
        else
            entry:SetPoint("TOPLEFT", self.entries[i - 1], "BOTTOMLEFT", 0, -ENTRY_GAP)
            entry:SetPoint("TOPRIGHT", self.entries[i - 1], "BOTTOMRIGHT", 0, -ENTRY_GAP)
        end
        height = height + entry:GetHeight() + ENTRY_GAP --[[@as number]]
        entry:Show()
        if entry.SetEntryIndex then
            entry:SetEntryIndex(i)
        end
    end
    -- set the height of the scroll child so the scroll bar gets resized correctly
    if height < 1 then
        height = 1
    end
    self.scrollFrame.Child:SetHeight(height)
    self:SetTrackerTitle(string.format("%s %s", self.activeView,
        self:GetEntryCount() and string.format("(%d)", self:GetEntryCount()) or ""))
    self:UpdateFrameHeight(height)
    self:UpdateVisibility()
end

---@param entry MapPinEnhancedTrackerSetEntryMixin | MapPinEnhancedTrackerPinEntryMixin
function MapPinEnhancedTrackerFrameMixin:AddEntry(entry)
    table.insert(self.entries, entry)
    local scollChildHeight = self.scrollFrame.Child:GetHeight()
    entry:ClearAllPoints()
    if #self.entries == 1 then
        entry:SetPoint("TOPLEFT", self.scrollFrame.Child, "TOPLEFT", 30, -ENTRY_GAP)
        entry:SetPoint("TOPRIGHT", self.scrollFrame.Child, "TOPRIGHT", 25, -ENTRY_GAP)
    else
        entry:SetPoint("TOPLEFT", self.entries[#self.entries - 1], "BOTTOMLEFT", 0, -ENTRY_GAP)
        entry:SetPoint("TOPRIGHT", self.entries[#self.entries - 1], "BOTTOMRIGHT", 0, -ENTRY_GAP)
    end
    entry:SetParent(self.scrollFrame.Child)
    entry:Show()
    local newHeight = scollChildHeight + entry:GetHeight() + ENTRY_GAP
    self.scrollFrame.Child:SetHeight(newHeight)
    self:SetTrackerTitle(string.format("%s (%d)", self.activeView, self:GetEntryCount()))
    self:UpdateFrameHeight(newHeight)
    if entry.SetEntryIndex then
        entry:SetEntryIndex(#self.entries)
    end
    if entry.SetEntryIndexVisibility then
        ---@cast entry MapPinEnhancedTrackerPinEntryMixin
        entry:SetEntryIndexVisibility(self.showNumbering)
    end
    self:UpdateVisibility()
end

function MapPinEnhancedTrackerFrameMixin:RemoveEntry(entry)
    for i, e in ipairs(self.entries) do
        if e == entry then
            table.remove(self.entries, i)
            entry:Hide()
            entry:ClearAllPoints()
            self:UpdateEntriesPosition()
            return
        end
    end
end

function MapPinEnhancedTrackerFrameMixin:OnEnter()
    self.scrollFrame.ScrollBar:SetAlpha(1)
    self.header.closebutton:Show()
    self.header.viewToggle:Show()
    self.header.editorToggle:Show()
end

function MapPinEnhancedTrackerFrameMixin:OnLeave()
    self.scrollFrame.ScrollBar:SetAlpha(0)
    self.header.closebutton:Hide()
    self.header.viewToggle:Hide()
    self.header.editorToggle:Hide()
end

local function RestorePinTrackerVisibility()
    local trackerVisibility = MapPinEnhanced:GetVar("trackerVisible") --[[@as boolean]]
    if trackerVisibility == nil then
        trackerVisibility = MapPinEnhanced:GetDefault("trackerVisible") --[[@as boolean]]
    end
    MapPinEnhanced:TogglePinTracker(trackerVisibility)
end

MapPinEnhanced:RegisterEvent("PLAYER_ENTERING_WORLD", RestorePinTrackerVisibility)
