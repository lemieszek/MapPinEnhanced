---@class MapPinEnhanced
local MapPinEnhanced = select(2, ...)

local LOCALE = MapPinEnhanced.locale

if LOCALE ~= "enUS" then return end

---@class Locale
local L = MapPinEnhanced.L
L["Set \"%s\" Loaded"] = "Set \"%s\" Loaded"
L["Accept"] = "Accept"
L["Add Pin"] = "Add Pin"
L["Add to a Set"] = "Add to a Set"
L["Are you sure you want to delete this set?"] = "Are you sure you want to delete this set?"
L["Auto Track Nearest Pin"] = "Auto Track Nearest Pin"
L["Automatic Visibility"] = "Automatic Visibility"
L["Automatic"] = "Automatic"
L["Back"] = "Back"
L["Background Opacity"] = "Background Opacity"
L["Block World Quest Tracking"] = "Block World Quest Tracking"
L["Block Automatic World Quest Tracking when a Pin is Tracked"] =
"Block Automatic World Quest Tracking when a Pin is Tracked"
L["Can't Show on Map in Combat"] = "Can't Show on Map in Combat"
L["Cancel"] = "Cancel"
L["Change Color"] = "Change Color"
L["Clear All Pins"] = "Clear All Pins"
L["Clear"] = "Clear"
L["Click to Change Color"] = "Click to Change Color"
L["Click to Load Set"] = "Click to Load Set"
L["Close Tracker"] = "Close Tracker"
L["Confirm"] = "Confirm"
L["Create a Pin at Your Current Location"] = "Create a Pin at Your Current Location"
L["Create Set"] = "Create Set"
L["Delete Set"] = "Delete Set"
L["Disabled"] = "Disabled"
L["Displayed Number of Entries"] = "Displayed Number of Entries"
L["Edit Set"] = "Edit Set"
L["Edit Set Name"] = "Edit Set Name"
L["Editor Scale"] = "Editor Scale"
L["Editor"] = "Editor"
L["Enable Unlimited Distance"] = "Enable Unlimited Distance"
L["Enter New Set Name"] = "Enter New Set Name"
L["Export as Commands"] = "Export as Commands"
L["Export Set"] = "Export Set"
L["Floating Pin"] = "Floating Pin"
L["General"] = "General"
L["Help"] = "Help"
L["Hide Minimap Button"] = "Hide Minimap Button"
L["Icon"] = "Icon"
L["Import a Set"] = "Import a Set"
L["Import Pins from Tracker"] = "Import Pins from Tracker"
L["Import Set"] = "Import Set"
L["Import"] = "Import"
L["Imported Set"] = "Imported Set"
L["Load Set"] = "Load Set"
L["Lock Tracker"] = "Lock Tracker"
L["Map ID"] = "Map ID"
L["Map Pin"] = "Map Pin"
L["Map Select"] = "Map Select"
L["Minimap Button Is Now Hidden"] = "Minimap Button Is Now Hidden"
L["Minimap Button Is Now Visible"] = "Minimap Button Is Now Visible"
L["Minimap"] = "Minimap"
L["My Way Back"] = "My Way Back"
L["New Set"] = "New Set"
L["No Pins to Export."] = "No Pins to Export."
L["Open Options"] = "Open Options"
L["Options"] = "Options"
L["Override World Quest Tracking"] = "Override World Quest Tracking"
L["Paste a String to Import a Set"] = "Paste a String to Import a Set"
L["Lock Pin"] = "Lock Pin"
L["Pins"] = "Pins"
L["Remove Pin"] = "Remove Pin"
L["Scale"] = "Scale"
L["Select a Set to Edit or Create a New One."] = "Select a Set to Edit or Create a New One."
L["Sets"] = "Sets"
L["Share to Chat"] = "Share to Chat"
L["Shift-Click to Share to Chat"] = "Shift-Click to Share to Chat"
L["Shift-Click to Load and Override All Pins"] = "Shift-Click to Load and Override All Pins"
L["Show Estimated Arrival Time"] = "Show Estimated Arrival Time"
L["Show Numbering"] = "Show Numbering"
L["Show on Map"] = "Show on Map"
L["Show Options"] = "Show Options"
L["Show Sets"] = "Show Sets"
L["Show This Help Message"] = "Show This Help Message"
L["Show Title"] = "Show Title"
L["Temporary Import"] = "Temporary Import"
L["The in-game navigation is disabled! Not all features of MapPinEnhanced will work properly. Do you want to enable it?"] =
"The in-game navigation is disabled! Not all features of MapPinEnhanced will work properly. Do you want to enable it?"
L["Title"] = "Title"
L["Toggle Editor"] = "Toggle Editor"
L["Toggle Minimap Button"] = "Toggle Minimap Button"
L["Lock Pin"] = "Lock Pin"
L["Unlock Pin"] = "Unlock Pin"
L["Toggle Tracker"] = "Toggle Tracker"
L["TomTom Is Loaded! You may experience some unexpected behavior."] =
"TomTom Is Loaded! You may experience some unexpected behavior."
L["Tracker"] = "Tracker"
L["View Pins"] = "View Pins"
L["View Sets"] = "View Sets"
L["When enabled, the floating pin will be shown even if the tracked pin is very far away."] =
"When enabled, the floating pin will be shown even if the tracked pin is very far away."
L["When enabled, the tracker will be shown/hidden automatically based on the number of active pins."] =
"When enabled, the tracker will be shown/hidden automatically based on the number of active pins."
L["X"] = "X"
L["Y"] = "Y"
L["You Are in an Instance or a Zone Where the Map Is Not Available"] =
"You Are in an Instance or a Zone Where the Map Is Not Available"
L["Invalid way command format. Please use one of the following formats (without < and >):"] =
"Invalid way command format. Please use one of the following formats (without < and >):"
L["/way <map name> <x> <y> <optional title>"] = "/way <map name> <x> <y> <optional title>"
L["/way #<mapID> <x> <y> <optional title>"] = "/way #<mapID> <x> <y> <optional title>"
