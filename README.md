# DrumHumanizer
Humanize MIDI drum parts by imparting dynamics to velocity and timing based off of parameters that can dial in a specific drummer's feel. I made this program to make my MIDI drum parts written in GuitarPro more realistic by adding human elements. This is intended to work within Reaper and be a one-click solution to finalize my MIDI files for audio production.

## Program
### Overview
This program has 4 main modules, called sequentially by `Main.lua`. Within this file is the `Main()` function, which serves as this program's entry point.
- `Init.lua`
- `Mapping.lua`
- `AnalyzeMidi.lua`
- `ProcessMidi.lua`

### Details
#### `Main.lua`
Loads the four listed modules sequentially. There are four corresponding functions that handle the program's flow based on returns from the modules. These are called within the `Main()` function:
- `initialize()`
- `loadMapping()`
- `analyze()`
- `process()`

#### `Init.lua`
Logs the program start, then prompts the user with a Message Box asking if they have selected the MIDI track they wish to process. The program will exit if no MIDI part is selected after confirmation, or if the user selects "No." Otherwise, the program continues to mapping.

#### `Mapping.lua`
Within `loadMapping()`, the three map/config files needed for processing are loaded. Note that there is a separate config file, `Configuration.lua`, which handles the "feel" of the emulated human player. The three loaded files are:
- `drum_map.lua`
- `banned_notes.lua`
- `limb_assignments.lua`

#### `AnalyzeMidi.lua`
Analyzes MIDI data for errors and preprocessing:
- `checkForMidi` – Checks that a MIDI file is selected and logs the file name.
- `possibilityCheck` – Checks if the current timestamp has more than four notes.
- `bannedNotesCheck` – Checks for MIDI notes not on a standard drum kit.
- `countNotes` – Increments note count.
- `logNoteCount` – Logs MIDI note distribution data.
- `logMidiNoteData` – Logs MIDI data.
- `alternateLimbSequence` – Alternates limbs in sequences of similar notes.
- `limbValidation` – Validates temporary MIDI data, changes the limb if in conflict, or notifies if there's an error.
- `iterateMidiData` – Iterates through all MIDI data for analyzing and preprocessing.

#### `ProcessMidi.lua`
Sets the script directory, loads configuration files, and applies MIDI changes:
- `randomFloat` – Generates a random float.
- `getRandomVariation` – Generates a random number within a given range.
- `adjustVelocity` – Adjusts velocity while preserving dynamics.
- `applyMidiChanges` – Applies velocity and timing changes to the MIDI file and saves them.
- `augmentMidi` – Processes all MIDI notes in the `midiNotesData` table.
- `logProcessedMidiData` – Logs the processed MIDI notes.

## Configuration
### Overview
Customization of this program is handled by four main files:
- `Configuration.lua`
- `banned_notes.lua`
- `drum_map.lua`
- `limb_assignment.lua`

### Details
#### `Configuration.lua`
Settings of the emulated human player.

#### `banned_notes.lua`
List of notes that are not allowed to be played. The program will notify the user and then exit if one of these values is encountered. These are standard drum kit pieces and should probably not be changed.

#### `drum_map.lua`
Map of MIDI note names. This is used internally for development and will serve little or no function for user modification. These are based on MIDI name standards.

#### `limb_assignment.lua`
Mapping of limb to drum piece. This file should not be changed unless you only play cymbals with your feet or, more realistically, if you play toms mainly with your non-dominant hand.