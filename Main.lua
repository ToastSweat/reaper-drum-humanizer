-- Main.lua
local scriptDirectory = debug.getinfo(1, "S").source:match("@(.*[\\|/])"):gsub("\\", "/")

-- Required Modules
local initModule =    dofile(scriptDirectory .. "Init.lua")
local mapModule =     dofile(scriptDirectory .. "Mapping.lua")
local analyzeModule = dofile(scriptDirectory .. "AnalyzeMidi.lua")
local processModule = dofile(scriptDirectory .. "ProcessMidi.lua")

local guiModule = dofile(scriptDirectory .. "gui.lua")

-- Global Variables
local initSuccess
local midiNotesData
local drumMap, bannedNotes, limbAssignments, take


-- Initialization function
local function initialize()
    initSuccess = initModule.Initialize()
end

-- Initialization function
local function loadMapping()
    if not initSuccess then
        return
    end
    drumMap, bannedNotes, limbAssignments = mapModule.LoadMapping()
end

-- MIDI analysis function
local function analyze()
    if not initSuccess then
        return
    end
    midiNotesData, take = analyzeModule.AnalyzeMidi(drumMap, bannedNotes, limbAssignments)
end

-- Process MIDI function
local function process()
    if not initSuccess then
        return
    end
    processModule.ProcessMidi(midiNotesData, drumMap, take)
end


-- Main function to run the process
local function Main()
    initialize()
    loadMapping()
    analyze()
    process()
end
Main()