---@class MapPinEnhanced
local MapPinEnhanced = select(2, ...)
---@class Blizz
local Blizz = MapPinEnhanced:GetModule("Blizz")

local CreateUIMapPointFromCoordinates = UiMapPoint.CreateFromCoordinates
local SetUserWaypoint = C_Map.SetUserWaypoint
local CanSetUserWaypointOnMap = C_Map.CanSetUserWaypointOnMap
local TimerAfter = C_Timer.After
local SuperTrackSetSuperTrackedUserWaypoint = C_SuperTrack.SetSuperTrackedUserWaypoint

---------------------------------------------------------------------------

---Wrapper for the current map the player is on
---@return number? mapID
function Blizz:GetPlayerMap()
    return C_Map.GetBestMapForUnit("player")
end

---Wrapper for the current map position of the player
---@return number x, number y, number currentPlayerUIMapID, Enum.UIMapType currentPlayerUIMapType
function Blizz:GetPlayerMapPosition()
    return MapPinEnhanced.HBD:GetPlayerZonePosition()
end

---Method to create the blizzard waypoint at a specific position
---@param x number
---@param y number
---@param mapID number
function Blizz:SetBlizzardWaypoint(x, y, mapID)
    if not CanSetUserWaypointOnMap(mapID) then
        local mapInfo = C_Map.GetMapInfo(mapID)
        MapPinEnhanced:Notify("Cannot set waypoint on " .. mapInfo.name, "ERROR")
        return
    end
    local uiMapPoint = CreateUIMapPointFromCoordinates(mapID, x, y, 0)
    SetUserWaypoint(uiMapPoint)
    TimerAfter(0.1, function()
        SuperTrackSetSuperTrackedUserWaypoint(true)
    end)
end

---Method to override the alpha state of the super tracked frame -> create unlimited distance
---@param enable boolean
function Blizz:OverrideSuperTrackedAlphaState(enable)
    if enable then
        SuperTrackedFrameMixin:SetTargetAlphaForState(Enum.NavigationState.Invalid, 1)
        SuperTrackedFrameMixin:SetTargetAlphaForState(Enum.NavigationState.Occluded, 1)
        return
    end
    SuperTrackedFrameMixin:SetTargetAlphaForState(Enum.NavigationState.Invalid, 0)
    SuperTrackedFrameMixin:SetTargetAlphaForState(Enum.NavigationState.Occluded, 0)
end

---------------------------------------------------------------------------

---Hide default world map Pin
function Blizz:HideBlizzardPin()
    hooksecurefunc(WaypointLocationPinMixin, "OnAcquired", function(waypointSelf) -- hide default blizzard waypoint
        waypointSelf:SetAlpha(0)
        waypointSelf:EnableMouse(false)
    end)
end

MapPinEnhanced:RegisterEvent("PLAYER_LOGIN", Blizz.HideBlizzardPin)

local countSinceLastTrackedPin = 0
---Method to handle the super tracking change event and track the last tracked pin
function Blizz:OnSuperTrackingChanged()
    ---@type boolean
    local isSuperTracking = C_SuperTrack.IsSuperTrackingAnything()
    local isSuperTrackingUserWaypoint = C_SuperTrack.IsSuperTrackingUserWaypoint()
    MapPinEnhanced:SaveVar("SuperTrackingOther", isSuperTracking and not isSuperTrackingUserWaypoint)
    if not isSuperTracking then
        if countSinceLastTrackedPin <= 2 then
            local PinManager = MapPinEnhanced:GetModule("PinManager")
            PinManager:TrackLastTrackedPin()
        end
        return
    end
    if not isSuperTrackingUserWaypoint then
        countSinceLastTrackedPin = countSinceLastTrackedPin + 1
        local PinManager = MapPinEnhanced:GetModule("PinManager")
        PinManager:UntrackTrackedPin()
    else
        countSinceLastTrackedPin = 0
    end
end

MapPinEnhanced:RegisterEvent("SUPER_TRACKING_CHANGED", Blizz.OnSuperTrackingChanged)
MapPinEnhanced:RegisterEvent("USER_WAYPOINT_UPDATED", Blizz.OnSuperTrackingChanged)
