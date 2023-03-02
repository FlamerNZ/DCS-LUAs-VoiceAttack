dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")

local t_start = 0.0
local t_stop = 0.0
local dt = 0.2 -- Default interval between commands in the stack.
local mto = 3.0 -- Default message timeout time.
local start_sequence_time = 3.0 * 60 -- Quick startup takes about 3m00s (orignal was 3m20s)
local stop_sequence_time = 60.0 -- TODO: timeout

start_sequence_full = {}
stop_sequence_full = {}

function push_command(sequence, run_t, command)
sequence[#sequence + 1] = command
sequence[#sequence]["time"] = run_t
end

function push_start_command(delta_t, command)
t_start = t_start + delta_t
push_command(start_sequence_full,t_start, command)
end

function push_stop_command(delta_t, command)
t_stop = t_stop + delta_t
push_command(stop_sequence_full,t_stop, command)
end

NO_FUEL = 1
COLLECTIVE = 2
BATTERY_LOW	= 3
APU_START_FAULT = 4
FUEL_PUMP_FAULT = 5
LEFT_ENGINE_START_FAULT = 6
RIGHT_ENGINE_START_FAULT = 7

alert_messages = {}
alert_messages[COLLECTIVE] = { message = _("SET THE COLLECTIVE STICK DOWN"), message_timeout = 10}
alert_messages[NO_FUEL] = 	 { message = _("CHECK FUEL QUANTITY"), message_timeout = 10}
alert_messages[BATTERY_LOW] = { message = _("POWER SUPPLY FAULT. CHECK THE BATTERY"), message_timeout = 10}
alert_messages[APU_START_FAULT] = { message = _("AI-9 NOT READY TO START ENGINE"), message_timeout = 10}
alert_messages[FUEL_PUMP_FAULT] = { message = _("FEEDING FUEL TANK PUMP FAULT"), message_timeout = 10}
alert_messages[LEFT_ENGINE_START_FAULT] = { message = _("LEFT ENGINE START FAULT"), message_timeout = 10}
alert_messages[RIGHT_ENGINE_START_FAULT] = { message = _("RIGHT ENGINE START FAULT"), message_timeout = 10}


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Function to collect all the start sequence commands.
local function doStartSequence()
push_start_command(dt, {message = _("HAVOC/Yushin/FlamerNZ QUICK AUTOSTART SEQUENCE IS RUNNING"), message_timeout = start_sequence_time})

-- removing Cockpit window close so that we can rearm, and avoid a race condition with VoiceAttack
--push_start_command(dt, {message = _("LEFT COCKPIT WINDOW - CLOSE"), message_timeout = mto}) 
--push_start_command(dt, {device = devices.CPT_MECH, action = device_commands.Button_15, value = 0.0})

-- Set intercom mode knob to INT, allows rearming.
push_start_command(dt, {message = _("INTERCOM MODE KNOB - INT"), message_timeout = mto})
push_start_command(dt, {device = devices.INTERCOM, action = device_commands.Button_8, value = 0.1})

-- Power levers and throttle
push_start_command(dt, {action = Keys.iCommand_PlaneAUTDecreaseRegime})
push_start_command(dt, {action = Keys.iCommand_PlaneAUTDecreaseRegime})
push_start_command(dt, {message = _("ENGINE POWER LEVERS - AUTO"), message_timeout = mto})
push_start_command(dt, {action = Keys.iCommand_PlaneAUTIncreaseRegime})
push_start_command(dt, {message = _("THROTTLE - MINIMUM (LEFT)"), message_timeout = mto})
push_start_command(dt, {action = Keys.iCommand_ThrottleDecrease})
push_start_command(dt, {message = _("COLLECTIVE - FULL DOWN"), message_timeout = mto})
push_start_command(dt, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_69, value = -1.0})
push_start_command(dt, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_70, value = -1.0})
push_start_command(dt, {action = Keys.iCommand_ThrottleStop})

push_start_command(dt, {message = _("ROTOR BRAKE - OFF"), message_timeout = mto})
push_start_command(dt, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_11, value = 0.0})

push_start_command(dt, {message = _("BATTERY 1 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_3, value = 1.0})
push_start_command(dt, {message = _("BATTERY 2 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_2, value = 1.0})
push_start_command(dt, {message = _("115V INVERTER - AUTO (down)"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_12, value = -1.0})

push_start_command(dt, {message = _("DC VOLTMETER SELECTOR - BATT BUS"), message_timeout = mto})
for i = 0.1, 0.4, 0.1 do
	push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_8, value = i})
end

push_start_command(dt, {message = _("CIRCUIT BREAKER GROUP 1 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_22, value = 1.0})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_22, value = 0.0})

push_start_command(dt, {message = _("CIRCUIT BREAKER GROUP 2 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_23, value = 1.0})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_23, value = 0.0})

push_start_command(dt, {message = _("CIRCUIT BREAKER GROUP 3 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_24, value = 1.0})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_24, value = 0.0})

push_start_command(dt, {message = _("CIRCUIT BREAKER GROUP 4 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_25, value = 1.0})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_25, value = 0.0})

push_start_command(dt, {message = _("CIRCUIT BREAKER GROUP 5 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_26, value = 1.0})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_26, value = 0.0})

push_start_command(dt, {message = _("CIRCUIT BREAKER GROUP 6 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_27, value = 1.0})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_27, value = 0.0})

push_start_command(dt, {message = _("CIRCUIT BREAKER GROUP 7 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_28, value = 1.0})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_28, value = 0.0})

push_start_command(dt, {message = _("CIRCUIT BREAKER GROUP 8 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_29, value = 1.0})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_29, value = 0.0})

push_start_command(dt, {message = _("CIRCUIT BREAKER GROUP 9 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_30, value = 1.0})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_30, value = 0.0})

push_start_command(dt, {message = _("FIRE EXTINGUISHER - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.FIRE_EXTING_INTERFACE, action = device_commands.Button_10, value = 1.0})

push_start_command(dt, {message = _("FUEL METER - TOTAL"), message_timeout = mto})
push_start_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_8, value = 0.1})

push_start_command(dt, {message = _("LEFT SHUTOFF VALVE - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_9, value = 1.0}) -- switch cover
push_start_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_1, value = 1.0}) -- switch
push_start_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_9, value = 0.0}) -- switch cover

push_start_command(dt, {message = _("RIGHT SHUTOFF VALVE - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_10, value = 1.0}) -- switch cover
push_start_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_2, value = 1.0}) -- switch
push_start_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_10, value = 0.0}) -- switch cover

push_start_command(dt, {message = _("SERVICE TANK PUMP - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_6, value = 1.0})
push_start_command(dt, {message = _("LEFT TANK PUMP - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_3, value = 1.0})
push_start_command(dt, {message = _("RIGHT TANK PUMP - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_5, value = 1.0})

-- R-828 radio
push_start_command(dt, {message = _("R-828 RADIO POWER - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.R_828, action = device_commands.Button_5, value = 1.0})

push_start_command(dt, {message = _("Danger Alarm To 20 Meters - that's the length of your cable"), message_timeout = dt_mto})
for i = 1, 776, 1 do
	push_start_command(0.01, {device = devices.RADAR_ALTIMETER, action = device_commands.Button_1, value = -.00104})
end

-- APU
push_start_command(dt, {message = _("STARTING APU (20 SEC)"), message_timeout = 20.0})
push_start_command(dt, {message = _("APU START MODE - START"), message_timeout = mto})
push_start_command(dt, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_12, value = 1.0, check_condition = FUEL_PUMP_FAULT}) -- APU Start Mode Switch, START/COLD CRANKING/FALSE START
push_start_command(dt, {message = _("APU START BUTTON - HOLD FOR 3 SEC"), message_timeout = mto})
push_start_command(dt, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_26, value = 1.0}) -- Press
push_start_command(3.0, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_26, value = 0.0}) -- Release
push_start_command(17.0, {message = _("APU STARTED"), message_timeout = mto})

-- Backup Gen and Equip Test, so that we can tune the radios before the engines start up
push_start_command(17.0, {message = _("Stand-By Gen and Equip Test, so that we can tune the radios"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_1, value = 1.0})  -- Standby Generator Switch, ON/OFF
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_9, value = 1.0})  -- Equipment Test Switch, ON/OFF
-- Then we can tune to 30.00 FM
push_start_command(dt, {device = devices.R_828, action = device_commands.Button_1, value = 0.4})
push_start_command(dt, {device = devices.R_828, action = device_commands.Button_3, value = 1.0}) -- Press
push_start_command(3.0, {device = devices.R_828, action = device_commands.Button_3, value = 0.0}) -- Release

-- Remove for smoky
-- Left engine
push_start_command(dt, {message = _("STARTING LEFT ENGINE (47 SEC)"), message_timeout = 47.0})
push_start_command(dt, {message = _("ENGINE START MODE - START"), message_timeout = mto})
push_start_command(dt, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_27, value = 1.0, check_condition = APU_START_FAULT}) -- Engine Start Mode Switch, START/OFF/COLD CRANKING
push_start_command(dt, {message = _("ENGINE SELECTOR SWITCH - LEFT"), message_timeout = mto})
push_start_command(dt, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_8, value = -1.0, check_condition = COLLECTIVE}) --Engine Selector Switch, LEFT/OFF/RIGHT
push_start_command(dt, {message = _("ENGINE START BUTTON - HOLD FOR 3 SEC"), message_timeout = mto})
push_start_command(dt, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_5, value = 1.0}) -- Engine Start Button - Push to start engine
push_start_command(3.0, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_5, value = 0.0}) -- Release
push_start_command(3.0, {message = _("LEFT ENGINE FUEL SHUTOFF LEVER - OPEN"), message_timeout = mto})
push_start_command(3.0, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_9, value = 1})
push_start_command(38.0, {message = _("LEFT ENGINE - STARTED"), message_timeout = mto})

-- Right engine
push_start_command(dt, {message = _("STARTING RIGHT ENGINE (49 SEC)"), message_timeout = 49.0})
push_start_command(dt, {message = _("ENGINE SELECTOR SWITCH - RIGHT"), message_timeout = mto})
push_start_command(dt, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_8, value = 1.0, check_condition = LEFT_ENGINE_START_FAULT})
push_start_command(dt, {message = _("ENGINE START BUTTON - HOLD FOR 3 SEC"), message_timeout = mto})
push_start_command(dt, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_5, value = 1.0})
push_start_command(3.0, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_5, value = 0.0})
push_start_command(3.0, {message = _("RIGHT ENGINE FUEL SHUTOFF LEVER - OPEN"), message_timeout = mto})
push_start_command(3.0, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_10, value = 1})
push_start_command(40.0, {message = _("RIGHT ENGINE - STARTED"), message_timeout = mto})

-- Engines started, selector to neutral
push_start_command(dt, {message = _("ENGINE SELECTOR SWITCH - CENTER"), message_timeout = mto})
push_start_command(dt, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_8, value = 0.0})

-- Throttle up
push_start_command(dt, {message = _("THROTTLE - MAXIMUM (RIGHT)"), message_timeout = mto})
push_start_command(dt, {action = Keys.iCommand_ThrottleIncrease})
push_start_command(4.0, {action = Keys.iCommand_ThrottleStop})
push_start_command(dt, {message = _("ALLOW RPM TO STABILIZE (10 SEC)"), message_timeout = 10.0})
push_start_command(10.0, {message = _("RPM STABILIZED"), message_timeout = mto})
-- End remove for smoky

-- Generators and Rectifiers
push_start_command(dt, {message = _("TURN ON GENERATORS"), message_timeout = mto})
push_start_command(dt, {message = _("GENERATOR 1 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_15, value = 1.0})
push_start_command(dt, {message = _("GENERATOR 2 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_16, value = 1.0})
push_start_command(dt, {message = _("RECTIFIER 1 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_7, value = 1.0})
push_start_command(dt, {message = _("RECTIFIER 2 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_5, value = 1.0})
push_start_command(dt, {message = _("RECTIFIER 3 - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_6, value = 1.0})
push_start_command(dt, {message = _("DC VOLTMETER SELECTOR - RECT BUS"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_8, value = 0.5})
push_start_command(dt, {message = _("AC VOLTMETER SELECTOR - 115V"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_17, value = 1.0})

push_start_command(dt, {message = _("36V INVERTER - AUTO (down)"), message_timeout = mto})
push_start_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_13, value = -1.0})

-- Remove this as well
push_start_command(dt, {message = _("APU STOP"), message_timeout = mto})
push_start_command(dt, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_7, value = 1.0}) -- Press
push_start_command(dt, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_7, value = 0.0}) -- Release

--Pilot's triangular panel
push_start_command(dt, {message = _("LEFT ATT IND - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.AGB_3K_LEFT, action = device_commands.Button_4, value = 1.0})
push_start_command(dt, {message = _("GYRO CUT OUT - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.CORRECTION_INTERRUPT, action = device_commands.Button_1, value = 1.0})
push_start_command(dt, {message = _("PITCH LIM SYS - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.SPUU_52, action = device_commands.Button_5, value = 1.0})
push_start_command(dt, {message = _("AUDIO WARN - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.VMS, action = device_commands.Button_6, value = 1.0})

--Copilot's triangular panel
push_start_command(dt, {message = _("DOPP - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.DISS_15, action = device_commands.Button_1, value = 1.0})
push_start_command(dt, {message = _("COMP SYS - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.GMK1A, action = device_commands.Button_1, value = 1.0})
push_start_command(dt, {message = _("RIGHT ATT IND - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.AGB_3K_RIGHT, action = device_commands.Button_4, value = 1.0})
push_start_command(dt, {message = _("COMM RADIO - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.JADRO_1A, action = device_commands.Button_13, value = 1.0})

--Lights
push_start_command(dt, {message = _("Let there be lights!"), message_timeout = mto})
push_start_command(dt, {device = devices.LIGHT_SYSTEM, action = device_commands.Button_11, value = 1.0})
push_start_command(dt, {device = devices.LIGHT_SYSTEM, action = device_commands.Button_10, value = 1.0})
push_start_command(dt, {device = devices.LIGHT_SYSTEM, action = device_commands.Button_9, value = 1.0})
push_start_command(dt, {device = devices.LIGHT_SYSTEM, action = device_commands.Button_8, value = 1.0})
push_start_command(dt, {device = devices.LIGHT_SYSTEM, action = device_commands.Button_7, value = 1.0})
push_start_command(dt, {device = devices.LIGHT_SYSTEM, action = device_commands.Button_6, value = 1.0})
push_start_command(dt, {device = devices.LIGHT_SYSTEM, action = device_commands.Button_5, value = 1.0})
push_start_command(dt, {device = devices.LIGHT_SYSTEM, action = device_commands.Button_23, value = 1.0})
push_start_command(dt, {device = devices.LIGHT_SYSTEM, action = device_commands.Button_2, value = -1.0})
push_start_command(dt, {device = devices.LIGHT_SYSTEM, action = device_commands.Button_3, value = -1.0})
push_start_command(dt, {device = devices.LIGHT_SYSTEM, action = device_commands.Button_4, value = 1.0})

-- Other
push_start_command(dt, {message = _("RADAR ALTIMETER - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.RADAR_ALTIMETER, action = device_commands.Button_3, value = 1.0})
push_start_command(dt, {message = _("RADAR ALTIMETER - 20M for length of cargo cable"), message_timeout = mto})
-- push all the buttons and see what works
--push_start_command(dt, {device = devices.RADAR_ALTIMETER, action = device_commands.Button_1, value = 0.02}) -- this turns it off
push_start_command(dt, {device = devices.RADAR_ALTIMETER, action = device_commands.Button_2, value = 1.0}) -- not sure what this one does
--push_start_command(dt, {device = devices.RADAR_ALTIMETER, action = device_commands.Button_4, value = 0.02}) -- this one also turns it off
push_start_command(dt, {message = _("Caging Gyros"), message_timeout = mto})
push_start_command(2.0, {device = devices.AGB_3K_LEFT, action = device_commands.Button_2, value = 1.0}) -- Press
push_start_command(dt, {device = devices.AGB_3K_LEFT, action = device_commands.Button_2, value = 0.0}) -- Release
push_start_command(2.0, {device = devices.AGB_3K_RIGHT, action = device_commands.Button_2, value = 1.0}) -- Press
push_start_command(dt, {device = devices.AGB_3K_RIGHT, action = device_commands.Button_2, value = 0.0}) -- Release
push_start_command(dt, {message = _("Aligning Gyro...  Takes 30 seconds or so, but you can take off without it if you're not bothered."), message_timeout = 10.0})

push_start_command(dt, {message = _("Resetting Accelerometer - now let's see how many Gs you can pull..."), message_timeout = mto})
push_start_command(1.0, {device = devices.CPT_MECH, action =  device_commands.Button_6, value = 1.0}) -- Press
push_start_command(dt, {device = devices.CPT_MECH, action = device_commands.Button_6, value = 0.0}) -- Release
-- no clicking thank you!
--push_start_command(dt, {message = _("FLASHER - ON"), message_timeout = mto})
--push_start_command(dt, {device = devices.SYS_CONTROLLER, action = device_commands.Button_5, value = 1.0})

-- we have this below
--push_start_command(dt, {message = _("AUTOPILOT ROLL/PITCH CHANNEL - ON"), message_timeout = mto})
--push_start_command(dt, {device = devices.AUTOPILOT, action = device_commands.Button_2, value = 1.0}) -- Press
--push_start_command(dt, {device = devices.AUTOPILOT, action = device_commands.Button_2, value = 0.0}) -- Release

-- UV-26 countermeasures system
push_start_command(dt, {message = _("UV-26 POWER - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.UV_26, action = device_commands.Button_10, value = 1.0})
push_start_command(dt, {message = _("UV-26 DISPENSER - BOTH"), message_timeout = mto})
push_start_command(dt, {device = devices.UV_26, action = device_commands.Button_2, value = 0.5})
push_start_command(dt, {message = _("UV-26 RESET TO DEFAULT PROGRAM (110)"), message_timeout = mto})
push_start_command(dt, {device = devices.UV_26, action = device_commands.Button_8, value = 1.0}) -- Press
push_start_command(dt, {device = devices.UV_26, action = device_commands.Button_8, value = 0.0}) -- Release
push_start_command(dt, {message = _("UV-26 SET NUM SEQUENCES - 4"), message_timeout = mto})
for i = 1, 3, 1 do -- Press and release 3 times
	push_start_command(dt, {device = devices.UV_26, action = device_commands.Button_4, value = 1.0}) -- Press
	push_start_command(0.1, {device = devices.UV_26, action = device_commands.Button_4, value = 0.0}) -- Release
end
push_start_command(dt, {message = _("UV-26 SET DISPENSER INTERVAL - 1 SEC"), message_timeout = mto})
push_start_command(dt, {device = devices.UV_26, action = device_commands.Button_6, value = 1.0}) -- Press
push_start_command(0.1, {device = devices.UV_26, action = device_commands.Button_6, value = 0.0}) -- Release

-- Fans
push_start_command(dt, {message = _("PILOT'S FAN - ON - Essential for Soviet Choppers ;)"), message_timeout = 10.0})
push_start_command(dt, {device = devices.CPT_MECH, action = device_commands.Button_20, value = 1.0})
push_start_command(dt, {message = _("COPILOT'S FAN - ON"), message_timeout = mto})

-- Yushin rocket arming
push_start_command(dt, {message = _("Yushin Weapon Startup Proceeding"), message_timeout = 10})
-- closing co-pilot window (closed by default)
push_start_command(dt, {device = devices.CPT_MECH, action = device_commands.Button_21, value = 1.0})
-- Pretty lights on the outside
push_start_command(dt, {device = devices.NAVLIGHT_SYSTEM, action = device_commands.Button_14, value = 1.0})
push_start_command(dt, {device = devices.NAVLIGHT_SYSTEM, action = device_commands.Button_15, value = 1.0})
push_start_command(dt, {device = devices.NAVLIGHT_SYSTEM, action = device_commands.Button_16, value = 1.0})
push_start_command(dt, {device = devices.NAVLIGHT_SYSTEM, action = device_commands.Button_12, value = 1.0})
push_start_command(dt, {device = devices.NAVLIGHT_SYSTEM, action = device_commands.Button_13, value = 1.0})

push_start_command(dt, {device = devices.WEAPON_SYS, action = device_commands.Button_30, value = 1.0})
push_start_command(dt, {device = devices.WEAPON_SYS, action = device_commands.Button_22, value = -1.0})
push_start_command(dt, {device = devices.WEAPON_SYS, action = device_commands.Button_27, value = 1.0}) -- remove for smoky
push_start_command(dt, {message = _("BE ADVISED, IF YOU ARE CARRYING ROCKETS, YOU ARE HOT!"), message_timeout = 30})

-- TODO: figure out what this value should be set to
--push_start_command(dt, {device = devices.PKV, action = device_commands.Button_3, value = 1}) 

push_start_command(dt, {message = _("Setting cargo hook to let go automatically, no one likes a clinger"), message_timeout = 10})
push_start_command(dt, {device = devices.EXT_CARGO_EQUIPMENT, action = device_commands.Button_5, value = 1.0})

-- Tuning into Rifle FM
push_start_command(dt, {message = _("Tuning into Rifle FM!  Hope that guy isn't still hot micing..."), message_timeout = 10})
push_start_command(dt, {device = devices.R_828, action = device_commands.Button_1, value = 0.4})
push_start_command(dt, {device = devices.R_828, action = device_commands.Button_3, value = 1.0}) -- Press
push_start_command(3.0, {device = devices.R_828, action = device_commands.Button_3, value = 0.0}) -- Release
push_start_command(dt, {device = devices.JADRO_1A, action = device_commands.Button_1, value = 1.0})

-- TODO: need to adjust the volume on this rotary: 
--elements["PTR-ADDSECPLT-LVR-CHNL"].sound = {{SOUND_ROTARY_1,SOUND_ROTARY_1},{SOUND_ROTARY_1,SOUND_ROTARY_1}}
--elements["PTR-LPE-LVR-CHANNEL"].sound = {{SOUND_ROTARY_1,SOUND_ROTARY_1},{SOUND_ROTARY_1,SOUND_ROTARY_1}}

--New Stuff
-- No idea what this one does, neither does smoky - lol
-- Do we need to press ARC-UD, Lock Switch, LOCK/UNLOCK three times?
--push_start_command(dt, {device = devices.ARC_UD, action = device_commands.Button_12, value = 1.0})
--push_start_command(dt, {device = devices.ARC_UD, action = device_commands.Button_12, value = 1.0})
push_start_command(dt, {device = devices.ARC_UD, action = device_commands.Button_4, value = 0.0})
push_start_command(dt, {device = devices.ARC_UD, action = device_commands.Button_12, value = 1.0})

-- Combust heater was fun for a while - add back for cold weather
-- push_start_command(dt, {device = devices.HEATER_KO50, action = device_commands.Button_4, value = 1.0})
-- push_start_command(dt, {device = devices.HEATER_KO50, action = device_commands.Button_3, value = -1.0})
-- push_start_command(dt, {device = devices.HEATER_KO50, action = device_commands.Button_2, value = 1.0})
-- push_start_command(dt, {device = devices.HEATER_KO50, action = device_commands.Button_1, value = 1.0}) --Press
-- push_start_command(10.0, {device = devices.HEATER_KO50, action = device_commands.Button_1, value = 0.0}) -- Release
-- push_start_command(dt, {device = devices.HEATER_KO50, action = device_commands.Button_4, value = 0.0})

-- now we should be safe to close the windows
push_start_command(dt, {message = _("LEFT COCKPIT WINDOW - CLOSE"), message_timeout = mto})
push_start_command(dt, {device = devices.CPT_MECH, action = device_commands.Button_15, value = 0.0})

push_start_command(dt, {message = _("AUTOPILOT ROLL/PITCH CHANNEL - ON"), message_timeout = mto})
push_start_command(dt, {device = devices.AUTOPILOT, action = device_commands.Button_2, value = 1.0}) -- Press
push_start_command(dt, {device = devices.AUTOPILOT, action = device_commands.Button_2, value = 0.0}) -- Release

-- toot the horn!
push_start_command(0.5, {device = devices.MISC_SYSTEMS_INTERFACE, action = device_commands.Button_1, value = 1.0}) -- Press
push_start_command(0.5, {device = devices.MISC_SYSTEMS_INTERFACE, action = device_commands.Button_1, value = 0.0}) -- Release
push_start_command(0.5, {device = devices.MISC_SYSTEMS_INTERFACE, action = device_commands.Button_1, value = 1.0}) -- Press
push_start_command(dt, {device = devices.MISC_SYSTEMS_INTERFACE, action = device_commands.Button_1, value = 0.0}) -- Release

push_start_command(dt, {message = _("Ready for Take-off, good (Will) hunting!"), message_timeout = 60})
push_start_command(dt, {message = _("Manual steps remaining:"), message_timeout = 20})
--push_start_command(dt, {message = _("Lights ... As needed"), message_timeout = 60})
--push_start_command(dt, {message = _("Radios ... As needed"), message_timeout = 60})
push_start_command(dt, {message = _("Navigation ... As needed"), message_timeout = 20})
push_start_command(dt, {message = _("Altimeter ... Set to match QFE (airfield elevation) or QNH (sea level altitude) as desired"), message_timeout = 20})
push_start_command(dt, {message = _("ADF ... Set to where you want to go"), message_timeout = 20})
end
doStartSequence()


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Function to collect all the stop sequence commands.
local function doStopSequence()
-- Stop sequence
push_stop_command(0.0, {message = _("HAVOC'S QUICK AUTOSTOP SEQUENCE IS RUNNING"), message_timeout = mto})

--Left Panel
push_stop_command(dt, {message = _("LEFT ADI - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.AGB_3K_LEFT, action = device_commands.Button_4, value = 0.0})
push_stop_command(dt, {message = _("VK-53 - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.CORRECTION_INTERRUPT, action = device_commands.Button_1, value = 0.0})
push_stop_command(dt, {message = _("SPUU-52 - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.SPUU_52, action = device_commands.Button_5, value = 0.0})
push_stop_command(dt, {message = _("RADAR ALTIMETER - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.RADAR_ALTIMETER, action = device_commands.Button_3, value = 0.0})
push_stop_command(dt, {message = _("RI-65 - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.VMS, action = device_commands.Button_6, value = 0.0})

-- R-828 radio
push_stop_command(dt, {message = _("R-828 RADIO POWER - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.R_828, action = device_commands.Button_5, value = 0.0})

-- UV-26 countermeasures system
push_stop_command(dt, {message = _("UV-26 POWER - ON"), message_timeout = mto})
push_stop_command(dt, {device = devices.UV_26, action = device_commands.Button_10, value = 0.0})

--Right Panel
push_stop_command(dt, {message = _("DISS-15 - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.DISS_15, action = device_commands.Button_1, value = 0.0})
push_stop_command(dt, {message = _("GMC-1A - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.GMK1A, action = device_commands.Button_1, value = 0.0})
push_stop_command(dt, {message = _("RIGHT ADI - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.AGB_3K_RIGHT, action = device_commands.Button_4, value = 0.0})
push_stop_command(dt, {message = _("JADRO-1A MODE - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.JADRO_1A, action = device_commands.Button_1, value = 0.0})
push_stop_command(dt, {message = _("JADRO-1A POWER - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.JADRO_1A, action = device_commands.Button_13, value = 0.0})

push_stop_command(dt, {device = devices.NAVLIGHT_SYSTEM, action = device_commands.Button_12, value = 0.0})
push_stop_command(dt, {device = devices.NAVLIGHT_SYSTEM, action = device_commands.Button_13, value = 0.0})
push_stop_command(dt, {device = devices.NAVLIGHT_SYSTEM, action = device_commands.Button_14, value = 0.0})
push_stop_command(dt, {device = devices.NAVLIGHT_SYSTEM, action = device_commands.Button_15, value = 0.0})

push_stop_command(dt, {message = _("GENERATOR 1 - ON"), message_timeout = mto})
push_stop_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_15, value = 0.0})
push_stop_command(dt, {message = _("GENERATOR 2 - ON"), message_timeout = mto})
push_stop_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_16, value = 0.0})

push_stop_command(dt, {message = _("STANDBY GENERATOR - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_1, value = 0.0})
push_stop_command(dt, {message = _("VU-2 - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_5, value = 0.0})
push_stop_command(dt, {message = _("VU-3 - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_6, value = 0.0})
push_stop_command(dt, {message = _("VU-1 - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_7, value = 0.0})
push_stop_command(dt, {message = _("PO-500 - NEUTRAL"), message_timeout = mto})
push_stop_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_12, value = 0.0})
push_stop_command(dt, {message = _("PT-200 - NEUTRAL"), message_timeout = mto})
push_stop_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_13, value = 0.0})

push_stop_command(dt, {message = _("CORRECTION SET TO LEFT"), message_timeout = mto})
push_stop_command(dt, {action = Keys.iCommand_ThrottleDecrease})
push_stop_command(4.0, {action = Keys.iCommand_ThrottleStop})

push_stop_command(5.0, {message = _("LEFT ENGINE STOP"), message_timeout = mto})
push_stop_command(5.0, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_9, value = 0})
push_stop_command(2.0, {message = _("RIGHT ENGINE STOP"), message_timeout = mto})
push_stop_command(2.0, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_10, value = 0})

push_stop_command(dt, {message = _("SERVICE TANK PUMP - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_6, value = 0.0})
push_stop_command(dt, {message = _("LEFT TANK PUMP - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_3, value = 0.0})
push_stop_command(dt, {message = _("RIGHT TANK PUMP - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_5, value = 0.0})

push_stop_command(dt, {message = _("LEFT SHUTOFF VALVE - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_9, value = 1.0}) -- Cover open
push_stop_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_1, value = 0.0}) -- Switch
push_stop_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_9, value = 0.0}) -- Cover close

push_stop_command(dt, {message = _("RIGHT SHUTOFF VALVE - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_10, value = 1.0}) -- Cover open
push_stop_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_2, value = 0.0}) -- Switch
push_stop_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_10, value = 0.0}) -- Cover close

--push_stop_command(dt, {message = _("CROSSFEED SWITCH - OFF"), message_timeout = mto})
--push_stop_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_11, value = 1.0}) -- Cover open
--push_stop_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_4, value = 0.0}) -- Switch
--push_stop_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_11, value = 0.0}) -- Cover close
--
--push_stop_command(dt, {message = _("BYPASS SWITCH - OFF"), message_timeout = mto})
--push_stop_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_12, value = 1.0}) -- Cover open
--push_stop_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_8, value = 0.0}) -- Switch
--push_stop_command(dt, {device = devices.FUELSYS_INTERFACE, action = device_commands.Button_12, value = 0.0}) -- Cover close

-- Fans
push_stop_command(dt, {message = _("PILOT'S FAN - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.CPT_MECH, action = device_commands.Button_20, value = 0.0})
push_stop_command(dt, {message = _("COPILOT'S FAN - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.CPT_MECH, action = device_commands.Button_21, value = 0.0})

push_stop_command(dt, {message = _("BATTERY 1 - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_3, value = 0.0})
push_stop_command(dt, {message = _("BATTERY 2 - OFF"), message_timeout = mto})
push_stop_command(dt, {device = devices.ELEC_INTERFACE, action = device_commands.Button_2, value = 0.0})

push_stop_command(dt, {message = _("ALL CB SWITCHES - OFF"), message_timeout = mto})
for i = device_commands.Button_31, device_commands.Button_31 + 75, 1 do
	push_stop_command(0.1, {device = devices.ELEC_INTERFACE, action = i, value = 0.0})
end

-- Wait for rotor to spin down.
push_stop_command(dt, {message = _("WAIT FOR ROTOR TO SPIN DOWN (65s)"), message_timeout = mto})
push_stop_command(65.0, {message = _("ROTOR BRAKE ON"), message_timeout = mto})
push_stop_command(dt, {device = devices.ENGINE_INTERFACE, action = device_commands.Button_11, value = 1})

push_stop_command(dt, {message = _("LEFT COCKPIT WINDOW - OPEN"), message_timeout = mto})
push_stop_command(dt, {device = devices.CPT_MECH, action = device_commands.Button_15, value = 1.0})

push_stop_command(dt, {message = _("HAVOC'S QUICK AUTOSTOP COMPLETE"), message_timeout = mto})
end
doStopSequence()


-- Inserts messages into the sequence that show how many minutes there are remaining in the sequence.  Also adds " (XmXs)" time display to the end of the first item in the sequence (which must be a message, and is by default).
local function insertTimeRemaining(sequence, endingTime)
local totalTime = math.ceil(endingTime) -- Round up to the next whole second.
local totalTimeMins = math.floor(totalTime / 60)
local totalTimeSecs = totalTime % 60
-- Add the total time onto the end of the initial startup message.
sequence[1]['message'] = sequence[1]['message']..' ('..totalTimeMins..'m'..totalTimeSecs..'s)'

local minsRemaining = totalTimeMins
local i = 1
while sequence[i] do
	-- If the current array element has a time less than or equal to our current number of minutes remaining, insert an element at the current position that shows the time remaining.
	if minsRemaining ~= 0 and endingTime - sequence[i]['time'] <= minsRemaining * 60 then
		if minsRemaining == 1 then
			minutesString = 'MINUTE'
		else
			minutesString = 'MINUTES'
		end
		table.insert(sequence, i, {message = _('=== '..minsRemaining..' '..minutesString..' REMAINING ==='), message_timeout = 60})
		sequence[i]['time'] = endingTime - minsRemaining * 60.0
		--log.info('sequence[i]: '..sequence[i]['message'])
		-- Subtract 1 minute from the remaining minutes to do.
		minsRemaining = minsRemaining - 1
		-- Decrement the index counter since we just added an element.  This makes sure we don't skip one.
		i = i - 1
	end
	-- Increment the index counter to go to the next element.
	i = i + 1
end
log.info('Start/Stop sequence time: '..totalTimeMins..'m'..totalTimeSecs..'s')
end
insertTimeRemaining(start_sequence_full, t_start)
insertTimeRemaining(stop_sequence_full, t_stop)

-- Debug function to log all the timing and message data for the entire sequence.  Useful to check to make sure the right values are going in, and in the right order.
local function logSequenceData()
for i = 1, #start_sequence_full do
	local message = '(action)'
	if start_sequence_full[i]['message'] then
		message = start_sequence_full[i]['message']
	end
	log.info("start_sequence_full[i]['time']: "..start_sequence_full[i]['time']..', remaining: '..t_start-start_sequence_full[i]['time']..', message: '..message)
end
end
--logSequenceData()
