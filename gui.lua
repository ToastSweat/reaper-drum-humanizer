-- gui.lua
package.path = reaper.ImGui_GetBuiltinPath() .. '/?.lua'

-- Required Modules
--local ImGui = require 'imgui' '0.9.3'
local ImGui = require('imgui')

-- Global Variables
local Module = {}


local function GuiInit()
    -- Log
    reaper.ShowConsoleMsg("Initializing ReaImGui\n\n")

    if not reaper.ImGui then
        reaper.ShowMessageBox("ReaImGui is not installed! Install it via ReaPack.", "Error", 0)
        return
    end

    ctx = reaper.ImGui_CreateContext('Item Sequencer') -- Add VERSION TODO
    FONT = reaper.ImGui_CreateFont('sans-serif', 15) -- Create the fonts you need
    reaper.ImGui_AttachFont(ctx, FONT)-- Attach the fonts you need
end

function InputWindowGuiLoop()
    local window_flags = reaper.ImGui_WindowFlags_MenuBar() 
    reaper.ImGui_SetNextWindowSize(ctx, 250, 300, reaper.ImGui_Cond_Once())-- Set the size of the windows.  Use in the 4th argument reaper.ImGui_Cond_FirstUseEver() to just apply at the first user run, so ImGUI remembers user resize s2
    reaper.ImGui_PushFont(ctx, FONT) -- Says you want to start using a specific font

    local visible, open  = reaper.ImGui_Begin(ctx, 'Robert Green Blue ', true, window_flags)

    if visible then
        --------
        --YOUR GUI HERE
        --------
        reaper.ImGui_End(ctx)
    end 


    reaper.ImGui_PopFont(ctx) -- Pop Font

    if open then
        reaper.defer(loop)
    else
        reaper.ImGui_DestroyContext(ctx)
    end
end

local function InputWindowGuiLoop()
    local ctx = ImGui.CreateContext('gui')

    local visible, open = ImGui.Begin(ctx, 'My window', true)

    if visible then
        reaper.ShowConsoleMsg("Visible!")
        ImGui.Text(ctx, 'Hello World!')
        ImGui.End(ctx)
    else
        reaper.ShowConsoleMsg("ERROR: NOT Visible!")
    end

    if open then
        reaper.defer(loop)

        reaper.ShowConsoleMsg("Open!")
    else
        reaper.ShowConsoleMsg("ERROR: NOT Open!")
    end
end

function Module.ShowInputWindow()
    -- Log
    reaper.ShowConsoleMsg("Showing Input Window\n\n")

    GuiInit()
    InputWindowGuiLoop()
end


return Module 




