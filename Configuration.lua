local Module = {}

Module.programVersion = "0.9"

-- Strength of limbs (0 - 120) [This correlates with Midi Velocity]
Module.dominateHandStrength = 99
Module.nondominateHandStrength = 91
Module.dominateFootStrength = 93
Module.nondominateFootStrength = 87

-- Timing of limbs (-25 - 25) [This is time in ms]
Module.dominateHandTiming = 0.05 -- 5
Module.nondominateHandTiming = -5.45 -- -3
Module.dominateFootTiming = -8.91 -- 3
Module.nondominateFootTiming = -9.23 -- -1

-- Bounds of Midi Velocity [This correlates with Midi Velocity]
Module.midiVelocityBoundLower = 25
Module.midiVelocityBoundUpper = 120

-- Randomization Ranges
Module.velocityRandomRange = 10  -- Random variation for velocity (-10 to 10)
Module.timingRandomRange = 2     -- Random variation for timing (-2 to 2)


return Module 

-- Rseearch
--[[
60bpm       120bpm      200bpm

Right Hand
-2.49       0           10.07
Left Hand
-10.98     -5.45        0.22
Right Foot
-12.91     -8.91       -0.70
Left Foot
(-14.50)  (-10.00)	  (-1.00)
]]