# DrumHumanizer
 Humanize MIDI drum parts by imparting dynamics to velocity and timing based off of parameters that can dial in a specific drummers feel. I made this program to make my MIDI drum parts written in GuitarPro more realistic by adding human elements. This is intended to work within Reaper and be a one-click solution to finalize my MIDI files for audio production.

## Program
### Overview
 This program has 4 main Modules, called sequentially by `Main.lua`. Eithin the this file is the Main() function, which serves as this programs entry point.
 * `Init.lua`
 * `Mapping.lua`
 * `AnalyzeMidi.lua`
 * `ProcessMidi.lua`

### Details
`Main.lua`
 Loads the 4 above listed modules sequentially. There are 4 corresponding functions which handle the programs flow based on returns of the Modules, these are called within the Main() function.
 * initialize()
 * loadMapping()
 * analyze()
 * process()

`Init.lua`
 Logs the program start then prompts the user with a Message Box, asking if they have selected the MIDID track they wish to process. Program will exit if there is not MIDI part selected after confirmation, or if user selects No. Otherwise program will continue to mapping.

`Mapping.lua`
 Within LoadMapping() the 3 map/config files needed for processesing are loaded. Note there is a seperate config file `Configuration.lua`, this handles the 'feel' of the emulated human player. The 3 files loaded:
 * `drum_map.lua`
 * `banned_notes.lua`
 * `limb_assignments.lua`

`AnalyzeMidi.lua`
checkForMidi -- Check that Midi file is selected and log file name
possibilityCheck -- Check if current timestamp has more than 4 notes
bannedNotesCheck -- Check for MIDI notes not on a STANDARD drum kit
countNotes -- Incriment note count
logNoteCount -- Log MIDI note distribution data
logMidiNoteData -- Log MIDI Data
alternateLimbSequence -- Function to alternate limbs in sequences of similar notes
limbValidation -- Validate temporay MIDI data, change limb if in conflict or notify if error
iterateMidiData -- Iterate through all midi data for analyzing and preprocessing

AnalyzeMidi -- Analyze MIDI data for errors and preprocess

`ProcessMidi.lua`
randomFloat -- Generate a random float
getRandomVariation -- Generate a random number within a given range
adjustVelocity -- Adjust velocity while preserving dynamics
applyMidiChanges -- Apply velocity and timing changes to Midi file and save
augmentMidi -- Process all MIDI notes in midiNotesData table
logProcessedMidiData -- Log the processed MIDI notes

ProcessMidi -- Set the script directory, load configuration files and apply Midi changes

## Configuration
### Overview
 Customization of this program is handled by 4 main files, listed below.

 * `Configuration.lua`
 * `banned_notes.lua`
 * `drum_map.lua`
 * `limb_assignment.lua`

### Details
 `Configuration.lua`

 Settings of the emulated human player.

 `banned_notes.lua`
 
 List of notes that are not allowed to be played, the program will notify the user then exit if one of these values is encountered. These are standard drum kit pieces and probably should not be changed.

 `drum_map.lua`
 
 Map of MIDI note names, this is used internally for development and will server you little or no function to change. These are based off of MIDI name standards.
 
 `limb_assignment.lua`
 
 Mapping of limb to drum piece. This file should not be changed unless you only play cymbals with your feet, or more realisticly, if you play toms mainly with your nondominant hand.