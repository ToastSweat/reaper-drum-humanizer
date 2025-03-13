-- AnalyzeMidi.lua
local scriptDirectory = debug.getinfo(1, "S").source:match("@(.*[\\|/])"):gsub("\\", "/")

-- Global Variables
local Module = {}

local midiNotes = {}


-- Check that Midi file is selected and log file name
local function checkForMidi()
    -- Get the selected media item
    local item = reaper.GetSelectedMediaItem(0, 0)
    if not item then 
        reaper.ShowConsoleMsg("No MIDI item selected!\n") 
        return 
    end  

    -- Get the active take from the item
    local take = reaper.GetTake(item, 0)
    if not take then
        reaper.ShowConsoleMsg("Selected item has no take!\n")
        return
    end

    -- Get the name of the take
    local takeName = reaper.GetTakeName(take)
    reaper.ShowConsoleMsg("Processing MIDI Take: " .. takeName .. "\n")

    return take
end

-- Check if current timestamp has more than 4 notes
local function possibilityCheck(startTime)
    -- Table to track simultaneous notes
    local notesAtTime = {}

    -- Track simultaneous notes
    notesAtTime[startTime] = (notesAtTime[startTime] or 0) + 1

    -- Check if 4 or more notes are played at the same time
    if notesAtTime[startTime] > 4 then
        reaper.ShowConsoleMsg("\n**Impossible Drum Part Detected!**\n")
        reaper.ShowConsoleMsg("More than 4 notes played at the same time (Time: " .. string.format("%.3f", startTime) .. "s)\n")
        return  -- Stop execution
    end
end

-- Check for MIDI notes not on a STANDARD drum kit
local function bannedNotesCheck(bannedNotes, pitch, drumMap)
    -- Check if the pitch is in the banned notes list and the value is true
    if bannedNotes[pitch] == true then
        local drumName = drumMap[pitch] or "Unknown (" .. pitch .. ")"
        reaper.ShowConsoleMsg("\n**Banned Note Encountered!**\n")
        reaper.ShowConsoleMsg("Pitch: " .. pitch .. " (" .. drumName .. ")\n")
        reaper.ShowConsoleMsg("This note is banned and needs to be removed or replaced in the MIDI file.\n")
        return  -- Stop the script if a banned note is found
    end
end

-- Incriment note count
local function countNotes(noteCounts, pitch)
    -- Track note occurrences
    noteCounts[pitch] = (noteCounts[pitch] or 0) + 1
end

-- Log MIDI note distribution data
local function logNoteCount(drumMap, noteCounts)
    -- Log the note distribution with drum names
    reaper.ShowConsoleMsg("\n  Note Distribution:\n")
    for pitch, count in pairs(noteCounts) do
        local drumName = drumMap[pitch] or "Unknown (" .. pitch .. ")"
        reaper.ShowConsoleMsg("    " .. drumName .. "[" .. pitch .. "]: " .. count .. "\n")
    end
end

-- Log MIDI Data
local function logMidiNoteData(midiNotes)
    -- Log the processed MIDI notes
    reaper.ShowConsoleMsg("\nProcessed MIDI Data:\n")
    for time, notes in pairs(midiNotes) do
        reaper.ShowConsoleMsg(string.format("Time: %.3f\n", time))
        for _, note in ipairs(notes) do
            reaper.ShowConsoleMsg(string.format("  Pitch: %d (%s) | Velocity: %d | Limb: %s\n",
                note.pitch, note.name, note.velocity, note.limb))
        end
    end
end

-- Function to alternate limbs in sequences of similar notes
local function alternateLimbSequence(notes)
    if #notes < 2 then return end  -- No need to alternate if there's only one note

    local isHandSequence = (notes[1].limb == "DH" or notes[1].limb == "NDH")
    local isFootSequence = (notes[1].limb == "DF" or notes[1].limb == "NDF")

    -- If it's neither a pure hand nor foot sequence, do nothing
    if not isHandSequence and not isFootSequence then return end

    local currentLimb = notes[1].limb  -- Start with the first note's limb

    for i = 2, #notes do
        if isHandSequence then
            -- Ensure it stays within DH/NDH
            if notes[i].limb ~= "DH" and notes[i].limb ~= "NDH" then break end
            currentLimb = (currentLimb == "DH") and "NDH" or "DH"
        elseif isFootSequence then
            -- Ensure it stays within DF/NDF
            if notes[i].limb ~= "DF" and notes[i].limb ~= "NDF" then break end
            currentLimb = (currentLimb == "DF") and "NDF" or "DF"
        end
        
        -- Apply the alternating limb
        notes[i].limb = currentLimb
    end
end

-- Validate temporay MIDI data, change limb if in conflict or notify if error
local function limbValidation(midiNotes, drumMap)
    -- Log
    --reaper.ShowConsoleMsg("Applying Multilimb Humanization\n")

    -- Process the stored MIDI notes for limb conflicts and alternation
    for time, notes in pairs(midiNotes) do
        local handNotes, footNotes = {}, {}

        for _, note in ipairs(notes) do
            if note.limb == "DH" or note.limb == "NDH" then
                table.insert(handNotes, note)
            elseif note.limb == "DF" or note.limb == "NDF" then
                table.insert(footNotes, note)
            end
        end
        
        -- Apply alternation to long sequences of hands or feet
        alternateLimbSequence(handNotes)
        alternateLimbSequence(footNotes)

        -- Existing logic for limb conflicts (checking DH/NDH and DF/NDF conflicts)
        local handCount, footCount, hasNDF = 0, 0, false

        for _, note in ipairs(notes) do
            local drumName = drumMap[note.pitch] -- Use drum_map.lua for naming

            -- Hand conflict resolution
            if note.limb == "DH" then
                handCount = handCount + 1
                if handCount == 2 then
                    note.limb = "NDH"
                    --reaper.ShowConsoleMsg(string.format("  Adjusted: %s at %.3f - Changed DH → NDH\n", drumName, time))
                elseif handCount > 2 then
                    reaper.ShowConsoleMsg("\nERROR: Impossible Hand Combination!**\n")
                    return
                end
            end

            -- Foot conflict resolution
            if note.limb == "DF" then
                footCount = footCount + 1
                if not hasNDF then
                    note.limb = "NDF"
                    hasNDF = true
                    --reaper.ShowConsoleMsg(string.format("  Adjusted: %s at %.3f - Changed DF → NDF\n", drumName, time))
                elseif footCount > 2 then
                    reaper.ShowConsoleMsg("\nERROR: Impossible Foot Combination!**\n")
                    return
                end
            elseif note.limb == "NDF" then
                hasNDF = true
                footCount = footCount + 1
                if footCount > 2 then
                    reaper.ShowConsoleMsg("\nERROR: Impossible Foot Combination!**\n")
                    return
                end
            end
        end
    end
end

-- Iterate through all midi data for analyzing and preprocessing
local function iterateMidiData(notecnt, take, bannedNotes, noteCounts, limbAssignments, drumMap)
    -- Iterate through all notes
    for i = 0, notecnt - 1 do
        local _, _, _, startPPQ, endPPQ, _, pitch, velocity = reaper.MIDI_GetNote(take, i)
        
        -- Convert PPQ to time in seconds
        local startTime = reaper.MIDI_GetProjTimeFromPPQPos(take, startPPQ)
        local endTime = reaper.MIDI_GetProjTimeFromPPQPos(take, endPPQ)
        local length = endTime - startTime

        possibilityCheck(startTime)
        bannedNotesCheck(bannedNotes, pitch, drumMap)
        countNotes(noteCounts, pitch)
        
        -- Assign a limb to the note
        local limb = limbAssignments[pitch] or "Unknown"
        
        -- Store the note in the table indexed by time
        if not midiNotes[startTime] then
            midiNotes[startTime] = {}  -- Create a new table for this time if not exists
        end

        table.insert(midiNotes[startTime], { pitch = pitch, velocity = velocity, limb = limb, length = length, startTime = startTime, startPPQ = startPPQ, endPPQ = endPPQ })

        -- Log details
        --reaper.ShowConsoleMsg("[" .. i .. "] " .. string.format("Time: %.3f | Pitch: %d | Limb: %s | Velocity: %d\n", startTime, pitch, limb, velocity))
    end
end

-- Analyze MIDI data for errors and preprocess
function Module.AnalyzeMidi(drumMap, bannedNotes, limbAssignments)
    local take = checkForMidi()

    if not take then
        reaper.ShowConsoleMsg("ERROR: No Midi File Found!\n")
        return
    end

    -- Table to store note counts by pitch
    local noteCounts = {}

    -- Count all MIDI notes
    local _, notecnt, _, _ = reaper.MIDI_CountEvts(take)
    --reaper.ShowConsoleMsg("  Total MIDI Notes: " .. notecnt .. "\n\n")
    
    iterateMidiData(notecnt, take, bannedNotes, noteCounts, limbAssignments, drumMap)
    limbValidation(midiNotes, drumMap)
    --logMidiNoteData(midiNotes)
    logNoteCount(drumMap, noteCounts)

    return midiNotes, take
end


return Module