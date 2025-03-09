-- Init.lua
local scriptDirectory = debug.getinfo(1, "S").source:match("@(.*[\\|/])"):gsub("\\", "/")

-- Required Modules
local configurationModule = dofile(scriptDirectory .. "Configuration.lua")

-- Global Variables
local Module = {}


-- Initialization function
function Module.Initialize() 
    -- Log Start
    reaper.ShowConsoleMsg("Drum Humanizer " .. configurationModule.programVersion .. " Starting!\n\n")

    retval = reaper.ShowMessageBox("Do you have the drum Midi selected?", "Error", 4)

    if retval == 6 then
        reaper.ShowConsoleMsg("User confirmed drum tack selected.\n\n")
        return true
    elseif retval ==  7 then
        reaper.ShowConsoleMsg("Exiting: User does not have drum tack selected.")
        return false
    end 
end


return Module 