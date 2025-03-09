-- Mapping.lua
local scriptDirectory = debug.getinfo(1, "S").source:match("@(.*[\\|/])"):gsub("\\", "/")

-- Global Variables
local Module = {}


--[[Set the script directory and load configuration files.]]
function Module.LoadMapping()
    reaper.ShowConsoleMsg("Initializing Mapping\n")

    -- Load the drum map
    local drumMap = dofile(scriptDirectory .. "drum_map.lua")
    if drumMap then
        reaper.ShowConsoleMsg("  Drum Map File Loaded\n")
    else
        reaper.ShowConsoleMsg("ERROR: Drum Map File Missing!\n")
        return
    end

    -- Load the banned notes
    local bannedNotes = dofile(scriptDirectory .. "banned_notes.lua")
    if bannedNotes then
        reaper.ShowConsoleMsg("  Banned Notes File Loaded\n")
    else
        reaper.ShowConsoleMsg("ERROR: Banned Notes File Missing!\n")
        return
    end

    -- Load the limb assignments
    local limbAssignments = dofile(scriptDirectory .. "limb_assignments.lua")
    if limbAssignments then 
        reaper.ShowConsoleMsg("  Limb Assignment File Loaded\n\n")
    else
        reaper.ShowConsoleMsg("ERROR: Limb Assignment File Missing!\n")
        return
    end

    return drumMap, bannedNotes, limbAssignments
end


return Module