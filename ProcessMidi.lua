-- ProcessMidi.lua
local scriptDirectory = debug.getinfo(1, "S").source:match("@(.*[\\|/])"):gsub("\\", "/")

-- Required Modules
local configurationModule = dofile(scriptDirectory .. "Configuration.lua")

-- Global Variables
local Module = {}


-- Generate a random float
local function randomFloat(lower, greater)
    return lower + math.random() * (greater - lower);
end

-- Generate a random number within a given range
local function getRandomVariation(range)
    return math.random(-range, range)
end

-- Adjust velocity while preserving dynamics
local function adjustVelocity(originalVelocity, limbStrength)
    local alpha = 1.0 --0.6
    local randomizedStrength = limbStrength + getRandomVariation(configurationModule.velocityRandomRange)
    local newVelocity = originalVelocity + (randomizedStrength - originalVelocity) * alpha

    -- Ensure velocity is an integer
    return math.floor(math.max(configurationModule.midiVelocityBoundLower, math.min(newVelocity, configurationModule.midiVelocityBoundUpper)) + 0.5)
end

-- Apply velocity and timing changes to Midi file and save
local function applyMidiChanges(take, processedMidiNotes, drumMap)
    if not take then
        reaper.ShowConsoleMsg("ERROR: take Not Found!\n")
        return
    end

    if not reaper.TakeIsMIDI(take) then
        reaper.ShowConsoleMsg("ERROR: take Not MIDI File!\n")
        return
    end

    if not processedMidiNotes then
        reaper.ShowConsoleMsg("ERROR: processedMidiNotes Not Found!\n")
        return
    end

    --[[if #processedMidiNotes <= 0 then
        reaper.ShowConsoleMsg("ERROR: processedMidiNotes length = 0!\n")
    end]]

    -- Get the number of MIDI notes
    local note_count = reaper.MIDI_CountEvts(take)
    --reaper.ShowConsoleMsg("note_count: " .. note_count .. "\n")

    -- Loop through all MIDI notes and delete them
    for i = note_count - 1, 0, -1 do
        reaper.MIDI_DeleteNote(take, i)  -- Deletes note at index i
    end

    -- Update the take after deleting the notes
    reaper.MIDI_Sort(take)
    reaper.UpdateArrange()  -- Updates the arrange view

    -- Loop through all MIDI notes and modify
    local index = 0
    for time, notes in pairs(processedMidiNotes) do
        index = index + 1
        --reaper.ShowConsoleMsg("[" .. index .. "] Processing\n")

        --reaper.ShowConsoleMsg(string.format("  Time: %.3f\n", time))
        for _, note in ipairs(notes) do
            
            --reaper.ShowConsoleMsg(string.format("    Pitch: %d (%s) | Velocity: %d | Limb: %s | Length: " .. note.length .. "\n", note.pitch, drumMap[note.pitch], note.velocity, note.limb))

            reaper.MIDI_InsertNote(take, true, false, note.startPPQ, note.stopPPQ, 1, note.pitch, note.velocity)
        end
    end
    --reaper.ShowConsoleMsg("count: " .. index)

    -- Sort and update the take after modifying the notes
    reaper.MIDI_Sort(take)
    reaper.UpdateArrange() -- Updates the arrange view

    reaper.ShowConsoleMsg("\nHumanization Complete!")
end

-- Process all MIDI notes in midiNotesData table
local function augmentMidi(midiNotesData, drumMap)
    if not midiNotesData then
        reaper.ShowConsoleMsg("ERROR: No midiNotesData!")
        return
    end

    -- Log
    reaper.ShowConsoleMsg("\nPerforming Final Haminization:\n")

    local processedMidiNotes = midiNotesData
    for time, notes in pairs(processedMidiNotes) do
        for _, note in ipairs(notes) do
            local originalVelocity = note.velocity
            local limb = note.limb
            local newVelocity = originalVelocity
            local startTime = note.startPPQ
            local newStartTime = startTime
            local endTime = note.endPPQ
            local newEndTime = endTime
            local length = note.length
            local newLength = length
            

            -- Apply limb-specific strength and timing adjustments with randomization
            if limb == "DH" then
                newVelocity = adjustVelocity(originalVelocity, configurationModule.dominateHandStrength)
                newStartTime = startTime + configurationModule.dominateHandTiming + getRandomVariation(configurationModule.timingRandomRange)
                newEndTime = endTime + configurationModule.dominateHandTiming + getRandomVariation(configurationModule.timingRandomRange)
            elseif limb == "NDH" then
                newVelocity = adjustVelocity(originalVelocity, configurationModule.nondominateHandStrength)
                newStartTime = startTime + configurationModule.nondominateHandTiming + getRandomVariation(configurationModule.timingRandomRange)
                newEndTime = endTime + configurationModule.nondominateHandTiming + getRandomVariation(configurationModule.timingRandomRange)
            elseif limb == "DF" then
                newVelocity = adjustVelocity(originalVelocity, configurationModule.dominateFootStrength)
                newStartTime = startTime + configurationModule.dominateFootTiming + getRandomVariation(configurationModule.timingRandomRange)
                newEndTime = endTime + configurationModule.dominateFootTiming + getRandomVariation(configurationModule.timingRandomRange)
            elseif limb == "NDF" then
                newVelocity = adjustVelocity(originalVelocity, configurationModule.nondominateFootStrength)
                newStartTime = startTime + configurationModule.nondominateFootTiming + getRandomVariation(configurationModule.timingRandomRange)
                newEndTime = endTime + configurationModule.nondominateFootTiming + getRandomVariation(configurationModule.timingRandomRange)
            end
            
            -- Randomize length
            local newLength = note.length * randomFloat(note.length * 0.85, note.length * 1.25) 

            -- Apply the new velocity and timing to the note
            note.velocity = newVelocity
            note.startPPQ = newStartTime
            note.stopPPQ = newEndTime
            note.length = newLength

            -- Logging for debugging
            local drumName = drumMap[note.pitch] or "Unknown Drum"

            -- Log
            --reaper.ShowConsoleMsg(string.format("  Adjusted: %s at %.3f → %.3f - Velocity %d → %d\n", drumName, time, newStartTime, originalVelocity, newVelocity))
        end
    end

    return processedMidiNotes
end

-- Log the processed MIDI notes
local function logProcessedMidiData(midiNotesData, drumMap)
    reaper.ShowConsoleMsg("\nProcessed MIDI Data:\n")
    for time, notes in pairs(midiNotesData) do
        reaper.ShowConsoleMsg(string.format("Time: %.3f\n", time))
        for _, note in ipairs(notes) do
            reaper.ShowConsoleMsg(string.format("  Pitch: %d (%s) | Velocity: %d | Limb: %s | Length: " .. note.length .. "\n",
                note.pitch, drumMap[note.pitch], note.velocity, note.limb))
        end
    end
end

-- Set the script directory and load configuration files
function Module.ProcessMidi(midiNotesData, drumMap, take)
    --logProcessedMidiData(midiNotesData, drumMap)
    
    local processedMidiNotes = augmentMidi(midiNotesData, drumMap)

    --logProcessedMidiData(midiNotesData, drumMap)

    applyMidiChanges(take, processedMidiNotes, drumMap)
end


return Module