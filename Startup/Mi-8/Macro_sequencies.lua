dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")

std_message_timeout = 15

local t_start = 0.0
local t_stop = 0.0
local delta_t_com = 2.0

start_sequence_full = {}
stop_sequence_full = {}

function push_command(sequence, run_t, command)
	sequence[#sequence + 1] =  command
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
FUEL_PUMP_FAUL = 5
LEFT_ENGINE_START_FAULT = 6
RIGHT_ENGINE_START_FAULT = 7

alert_messages = {}
alert_messages[COLLECTIVE] = { message = _("SET THE COLLECTIVE STICK DOWN"), message_timeout = 10}
alert_messages[NO_FUEL] = 	 { message = _("CHECK FUEL QUANTITY"), message_timeout = 10}
alert_messages[BATTERY_LOW] = { message = _("POWER SUPPLY FAULT. CHECK THE BATTERY"), message_timeout = 10}
alert_messages[APU_START_FAULT] = { message = _("AI-9 NOT READY TO START ENGINE"), message_timeout = 10}
alert_messages[FUEL_PUMP_FAUL] = { message = _("FEEDING FUEL TANK PUMP FAULT"), message_timeout = 10}
alert_messages[LEFT_ENGINE_START_FAULT] = { message = _("LEFT ENGINE START FAULT"), message_timeout = 10}
alert_messages[RIGHT_ENGINE_START_FAULT] = { message = _("RIGHT ENGINE START FAULT"), message_timeout = 10}

push_start_command(2.0,{message = _("AUTOSTART SEQUENCE IS RUNNING"),message_timeout = std_message_timeout})

push_start_command(0.1,{device = devices.ENGINE_INTERFACE,action = device_commands.Button_9, value = 1.0, message = _("LEFT ENGINE UNLOCK"),message_timeout = std_message_timeout})
push_start_command(2.0,{device = devices.ENGINE_INTERFACE,action = device_commands.Button_10, value = 1.0, message = _("RIGHT ENGINE UNLOCK"),message_timeout = std_message_timeout})
push_start_command(2.0,{device = devices.ENGINE_INTERFACE,action = device_commands.Button_11, value = 0.0, message = _("ROTOR BRAKE OFF"),message_timeout = std_message_timeout})

push_start_command(2.0,{action = Keys.iCommand_PlaneAUTDecreaseRegime})
push_start_command(0.1,{action = Keys.iCommand_PlaneAUTDecreaseRegime})
push_start_command(0.1,{action = Keys.iCommand_PlaneAUTIncreaseRegime,		message = _("ENGINES THROTTLES SET TO AUTO"),message_timeout = 10})
push_start_command(1.0,{action = Keys.iCommand_ThrottleDecrease,			message = _("CORRECTION SET TO LEFT"),message_timeout = 10})
push_start_command(1.0,{device = devices.ENGINE_INTERFACE, action = device_commands.Button_69, value = -1.0, message = _("COLLECTIVE SET TO FULL DOWN"),message_timeout = 10})
push_start_command(0.1,{device = devices.ENGINE_INTERFACE, action = device_commands.Button_70, value = -1.0})
push_start_command(4.0,{action = Keys.iCommand_ThrottleStop})

push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_2, value = 1.0})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_3, value = 1.0})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_12, value = -1.0})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_13, value = -1.0})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_20, value = 1.0})

for i = 0.1, 0.4, 0.1 do
	push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_8, value = i})
end

push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_25, value = 1.0})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_25, value = 0.0})

push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_26, value = 1.0})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_26, value = 0.0})

push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_27, value = 1.0})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_27, value = 0.0})

push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_28, value = 1.0})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_28, value = 0.0})

push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_29, value = 1.0})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_29, value = 0.0})

push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_30, value = 1.0})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_30, value = 0.0})

-- гидросистема
push_start_command(0.1,{device = devices.HYDRO_SYS_INTERFACE,action =  device_commands.Button_1, value = 1.0})
push_start_command(0.1,{device = devices.HYDRO_SYS_INTERFACE,action =  device_commands.Button_9, value = 0.0})


--топливная система
push_start_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_6, value = 1.0})
push_start_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_3, value = 1.0})
push_start_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_5, value = 1.0})
push_start_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_9, value = 1.0})
push_start_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_10, value = 1.0})
push_start_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_1, value = 1.0})
push_start_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_2, value = 1.0})
push_start_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_9, value = 0.0})
push_start_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_10, value = 0.0})
push_start_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_11, value = 1.0})
push_start_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_4, value = 1.0})
push_start_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_11, value = 0.0})
push_start_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_12, value = 0.0})

push_start_command(1.0,{device = devices.FIRE_EXTING_INTERFACE, action =  device_commands.Button_10, value = 1.0, message = _("EXTINGUISHING"), message_timeout = std_message_timeout})

--панель запуска двигателей
push_start_command(0.1,{device = devices.ENGINE_INTERFACE,action =  device_commands.Button_12, value = 1.0, check_condition = FUEL_PUMP_FAUL})
push_start_command(0.1,{device = devices.ENGINE_INTERFACE,action =  device_commands.Button_26, value = 1.0, message = _("APU START"), message_timeout = std_message_timeout})
push_start_command(3.0,{device = devices.ENGINE_INTERFACE,action =  device_commands.Button_26, value = 0.0})

push_start_command(1.0,{device = devices.CPT_MECH, action =  device_commands.Button_15, value = 1.0})

push_start_command(25.0,{device = devices.ENGINE_INTERFACE,action =  device_commands.Button_27, value = 1.0, check_condition = APU_START_FAULT})
push_start_command(0.1,{device = devices.ENGINE_INTERFACE,action =  device_commands.Button_8, value = -1.0, check_condition = COLLECTIVE})
push_start_command(0.1,{device = devices.ENGINE_INTERFACE,action =  device_commands.Button_5, value = 1.0, message = _("LEFT ENGINE START"), message_timeout = std_message_timeout})
push_start_command(5.0,{device = devices.ENGINE_INTERFACE,action =  device_commands.Button_5, value = 0.0})

push_start_command(55.0,{device = devices.ENGINE_INTERFACE,action =  device_commands.Button_8, value = 1.0, check_condition = LEFT_ENGINE_START_FAULT})
push_start_command(0.1,{device = devices.ENGINE_INTERFACE,action =  device_commands.Button_5, value = 1.0, message = _("RIGHT ENGINE START"), message_timeout = std_message_timeout})
push_start_command(5.0,{device = devices.ENGINE_INTERFACE,action =  device_commands.Button_5, value = 0.0})

push_start_command(55.0,{action = Keys.iCommand_ThrottleIncrease,message = _("CORRECTION SET TO RIGHT"),message_timeout = 10, check_condition = RIGHT_ENGINE_START_FAULT})
push_start_command(4.0,{action = Keys.iCommand_ThrottleStop})

push_start_command(10.0,{message = _("TURN ON GENERATORS"),message_timeout = std_message_timeout})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action = device_commands.Button_15, value = 1.0})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action = device_commands.Button_16, value = 1.0})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action = device_commands.Button_5, value = 1.0, message = _("VU-2"), message_timeout = std_message_timeout})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action = device_commands.Button_6, value = 1.0, message = _("VU-3"), message_timeout = std_message_timeout})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action = device_commands.Button_7, value = 1.0, message = _("VU-1"), message_timeout = std_message_timeout})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action = device_commands.Button_8, value = 0.5})
push_start_command(0.1,{device = devices.ELEC_INTERFACE,action = device_commands.Button_17, value = 1.0})

push_start_command(1.0,{device = devices.ENGINE_INTERFACE,action =  device_commands.Button_7, value = 1.0, message = _("APU STOP"), message_timeout = std_message_timeout})

--Left Panel
push_start_command(1.0,{device = devices.AGB_3K_LEFT, action =  device_commands.Button_4, value = 1.0, message = _("LEFT ADI"), message_timeout = std_message_timeout})
push_start_command(1.0,{device = devices.CORRECTION_INTERRUPT, action =  device_commands.Button_1, value = 1.0, message = _("VK-53"), message_timeout = std_message_timeout})
push_start_command(1.0,{device = devices.SPUU_52, action =  device_commands.Button_5, value = 1.0, message = _("SPUU-52"), message_timeout = std_message_timeout})
push_start_command(1.0,{device = devices.RADAR_ALTIMETER, action =  device_commands.Button_3, value = 1.0, message = _("RADAR ALTIMETER"), message_timeout = std_message_timeout})
push_start_command(1.0,{device = devices.VMS, action = device_commands.Button_6, value = 1.0, message = _("RI-65"), message_timeout = std_message_timeout})

--Right Panel
push_start_command(1.0,{device = devices.DISS_15, action =  device_commands.Button_1, value = 1.0, message = _("DISS-15"), message_timeout = std_message_timeout})
push_start_command(1.0,{device = devices.GMK1A, action =  device_commands.Button_1, value = 1.0, message = _("GMC-1A"), message_timeout = std_message_timeout})
push_start_command(1.0,{device = devices.AGB_3K_RIGHT, action =  device_commands.Button_4, value = 1.0, message = _("RIGHT ADI"), message_timeout = std_message_timeout})
push_start_command(1.0,{device = devices.JADRO_1A, action =  device_commands.Button_13, value = 1.0, message = _("JADRO-1A"), message_timeout = std_message_timeout})

--[[
FLASHER
--]]
push_start_command(1.0,{device = devices.SYS_CONTROLLER, action =  device_commands.Button_5, value = 1.0, message = _("FLASHER"), message_timeout = std_message_timeout})

push_start_command(1.0,{device = devices.AUTOPILOT, action =  device_commands.Button_2, value = 1.0, message = _("AUTOPILOT ROLL/PITCH CHANNEL"), message_timeout = std_message_timeout})
push_start_command(1.0,{device = devices.AUTOPILOT, action =  device_commands.Button_2, value = 0.0})

push_start_command(5.0,{message = _("AUTOSTART COMPLETE"),message_timeout = std_message_timeout})

---------------------------------
--- Stop sequence
push_stop_command(2.0,{message = _("AUTOSTOP SEQUENCE IS RUNNING"),message_timeout = std_message_timeout})

--Left Panel
push_stop_command(0.5,{device = devices.AGB_3K_LEFT, action =  device_commands.Button_4, value = 0.0, message = _("LEFT ADI"), message_timeout = std_message_timeout})
push_stop_command(0.5,{device = devices.CORRECTION_INTERRUPT, action =  device_commands.Button_1, value = 0.0, message = _("VK-53"), message_timeout = std_message_timeout})
push_stop_command(0.5,{device = devices.SPUU_52, action =  device_commands.Button_5, value = 0.0, message = _("SPUU-52"), message_timeout = std_message_timeout})
push_stop_command(0.5,{device = devices.RADAR_ALTIMETER, action =  device_commands.Button_3, value = 0.0, message = _("RADAR ALTIMETER"), message_timeout = std_message_timeout})
push_stop_command(0.5,{device = devices.VMS, action =  device_commands.Button_6, value = 0.0, message = _("RI-65"), message_timeout = std_message_timeout})

--Right Panel
push_stop_command(0.5,{device = devices.DISS_15, action =  device_commands.Button_1, value = 0.0, message = _("DISS-15"), message_timeout = std_message_timeout})
push_stop_command(0.5,{device = devices.GMK1A, action =  device_commands.Button_1, value = 0.0, message = _("GMC-1A"), message_timeout = std_message_timeout})
push_stop_command(0.5,{device = devices.AGB_3K_RIGHT, action =  device_commands.Button_4, value = 0.0, message = _("RIGHT ADI"), message_timeout = std_message_timeout})
push_stop_command(0.5,{device = devices.JADRO_1A, action =  device_commands.Button_1, value = 0.0, message = _("JADRO-1A"), message_timeout = std_message_timeout})

push_stop_command(0.1,{device = devices.NAVLIGHT_SYSTEM,action =  device_commands.Button_12, value = 0.0})
push_stop_command(0.1,{device = devices.NAVLIGHT_SYSTEM,action =  device_commands.Button_13, value = 0.0})
push_stop_command(0.1,{device = devices.NAVLIGHT_SYSTEM,action =  device_commands.Button_14, value = 0.0})
push_stop_command(0.1,{device = devices.NAVLIGHT_SYSTEM,action =  device_commands.Button_15, value = 0.0})

push_stop_command(0.1,{device = devices.ELEC_INTERFACE,action = device_commands.Button_15, value = 0.0, message = _("GENERATORS OFF"), message_timeout = std_message_timeout})
push_stop_command(0.1,{device = devices.ELEC_INTERFACE,action = device_commands.Button_16, value = 0.0})
push_stop_command(0.1,{device = devices.ELEC_INTERFACE,action = device_commands.Button_1, value = 0.0})
push_stop_command(0.1,{device = devices.ELEC_INTERFACE,action = device_commands.Button_5, value = 0.0, message = _("VU-2 OFF"), message_timeout = std_message_timeout})
push_stop_command(0.1,{device = devices.ELEC_INTERFACE,action = device_commands.Button_6, value = 0.0, message = _("VU-3 OFF"), message_timeout = std_message_timeout})
push_stop_command(0.1,{device = devices.ELEC_INTERFACE,action = device_commands.Button_7, value = 0.0, message = _("VU-1 OFF"), message_timeout = std_message_timeout})
push_stop_command(0.1,{device = devices.ELEC_INTERFACE,action = device_commands.Button_12, value = 0.0, message = _("PO-500 NEUTRAL"), message_timeout = std_message_timeout})
push_stop_command(0.1,{device = devices.ELEC_INTERFACE,action = device_commands.Button_13, value = 0.0, message = _("PT-200 NEUTRAL"), message_timeout = std_message_timeout})

push_stop_command(0.1,{action = Keys.iCommand_ThrottleDecrease,message = _("CORRECTION SET TO LEFT"),message_timeout = 10})
push_stop_command(4.0,{action = Keys.iCommand_ThrottleStop})

push_stop_command(5.0,{device = devices.ENGINE_INTERFACE,action = device_commands.Button_9, value = 0.0, message = _("LEFT ENGINE STOP"),message_timeout = std_message_timeout})
push_stop_command(2.0,{device = devices.ENGINE_INTERFACE,action = device_commands.Button_10, value = 0.0, message = _("RIGHT ENGINE STOP"),message_timeout = std_message_timeout})

push_stop_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_6, value = 0.0})
push_stop_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_3, value = 0.0})
push_stop_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_5, value = 0.0})
push_stop_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_9, value = 1.0})
push_stop_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_10, value = 1.0})
push_stop_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_1, value = 0.0})
push_stop_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_2, value = 0.0})
push_stop_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_9, value = 0.0})
push_stop_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_10, value = 0.0})
push_stop_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_11, value = 1.0})
push_stop_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_4, value = 0.0})
push_stop_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_11, value = 0.0})
push_stop_command(0.1,{device = devices.FUELSYS_INTERFACE,action =  device_commands.Button_12, value = 0.0})

push_stop_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_2, value = 0.0, message = _("BATTERIES OFF"), message_timeout = std_message_timeout})
push_stop_command(0.1,{device = devices.ELEC_INTERFACE,action =  device_commands.Button_3, value = 0.0})

push_stop_command(1.0,{device = devices.CPT_MECH, action =  device_commands.Button_15, value = 1.0})

for i = device_commands.Button_31, device_commands.Button_31+75, 1 do
	push_stop_command(0.1,{device = devices.ELEC_INTERFACE,action =  i, value = 0.0})
end

push_stop_command(65.0,{device = devices.ENGINE_INTERFACE,action = device_commands.Button_11, value = 1.0, message = _("ROTOR BRAKE ON"),message_timeout = std_message_timeout})
push_stop_command(1.0,{message = _("AUTOSTOP COMPLETE"),message_timeout = std_message_timeout})
