dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")

local std_message_timeout = 15

local t_start = 0.0
local t_stop = 0.0
local dt = 0.2
local dt_mto = 10.0
local dt_awt = 235.0 -- alignment waiting time, 3m55s
local alignment_timer = 0 -- Initialize timer for alignment process.
local dt_1es = 30 -- first engine start time
local dt_2es = 40 -- second engine start time
local dt_es = dt_1es + dt_2es + 5

-- Set a couple of local variables used to track whether a given command push is for start or stop.  Exact values don't matter, as long as they are different.
local start = 'start'
local stop = 'stop'

--
start_sequence_full = {}
stop_sequence_full = {}
cockpit_illumination_full = {}

function push_command(sequence, run_t, command)
	sequence[#sequence + 1] = command
	sequence[#sequence]["time"] = run_t
end

--function push_start_command(delta_t, command)
--	t_start = t_start + delta_t
--	push_command(start_sequence_full,t_start, command)
--end
--
--function push_stop_command(delta_t, command)
--	t_stop = t_stop + delta_t
--	push_command(stop_sequence_full,t_stop, command)
--end

-- New function that allows pushing either a start or a stop command, depending on the first parameter.  This allows re-use of functions that are applicable to both start and stop, such as Master Warning/Caution reset.
--local startMinute = 1
function push_combined(seq, delta_t, command)
	if seq == start then
		t_start = t_start + delta_t
		push_command(start_sequence_full, t_start, command)
	else
		t_stop = t_stop + delta_t
		push_command(stop_sequence_full, t_stop, command)
	end
end

-- Function that pushes a start or stop command at an absolute time during the sequence.
--function push_combined_abs
--	TODO
--end

--
local count = -1
local function counter()
	count = count + 1
	return count
end


AH64_AD_NO_FAILURE = counter()
AH64_AD_ERROR = counter()

AH64_AD_COLLECTIVE_SET_DOWN = counter()
AH64_AD_COLLECTIVE_AT_DOWN = counter()

AH64_AD_L_PCL_SET_TO_OFF = counter()
AH64_AD_L_PCL_AT_OFF = counter()
AH64_AD_L_PCL_SET_TO_IDLE = counter()
AH64_AD_L_PCL_AT_IDLE = counter()
AH64_AD_L_PCL_SET_TO_FLY = counter()
AH64_AD_L_PCL_AT_FLY = counter()
AH64_AD_L_PCL_DOWN_TO_IDLE = counter()

AH64_AD_R_PCL_SET_TO_OFF = counter()
AH64_AD_R_PCL_AT_OFF = counter()
AH64_AD_R_PCL_SET_TO_IDLE = counter()
AH64_AD_R_PCL_AT_IDLE = counter()
AH64_AD_R_PCL_SET_TO_FLY = counter()
AH64_AD_R_PCL_AT_FLY = counter()
AH64_AD_R_PCL_DOWN_TO_IDLE = counter()

AH64_AD_APU_READY = counter()
AH64_AD_NpNr_VERIFY = counter()

AH64_AD_TAIL_WHEEL_LOCK = counter()
AH64_AD_TAIL_WHEEL_UNLOCK = counter()

AH64_AD_BLEED_AIR_1_ON = counter()
AH64_AD_BLEED_AIR_2_ON = counter()

AH64_AD_EMERG_HYDRAULIC_OFF = counter()

AH64_AD_PNVS_OFF = counter()
AH64_AD_TADS_OFF = counter()
AH64_AD_FCR_OFF = counter()



--
alert_messages = {}

alert_messages[AH64_AD_ERROR] = {message = _("FM MODEL ERROR"), message_timeout = std_message_timeout}

alert_messages[AH64_AD_COLLECTIVE_SET_DOWN] = {message = _("COLLECTIVE - REDUCE TO FLAT PITCH"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_COLLECTIVE_AT_DOWN] = {message = _("COLLECTIVE MUST BE REDUCED TO FLAT PITCH"), message_timeout = std_message_timeout}

alert_messages[AH64_AD_L_PCL_SET_TO_OFF] = {message = _("LEFT POWER CONTROL LEVER - TO OFF"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_L_PCL_AT_OFF] = {message = _("LEFT POWER CONTROL LEVER MUST BE AT OFF"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_L_PCL_SET_TO_IDLE] = {message = _("LEFT POWER CONTROL LEVER - TO IDLE"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_L_PCL_AT_IDLE] = {message = _("LEFT POWER CONTROL LEVER MUST BE AT IDLE"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_L_PCL_SET_TO_FLY] = {message = _("LEFT POWER CONTROL LEVER - TO FLY"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_L_PCL_AT_FLY] = {message = _("LEFT POWER CONTROL LEVER MUST BE AT FLY"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_L_PCL_DOWN_TO_IDLE] = {message = _("LEFT POWER CONTROL LEVER - TO IDLE"), message_timeout = std_message_timeout}

alert_messages[AH64_AD_R_PCL_SET_TO_OFF] = {message = _("RIGHT POWER CONTROL LEVER - TO OFF"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_R_PCL_AT_OFF] = {message = _("RIGHT POWER CONTROL LEVER MUST BE AT OFF"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_R_PCL_SET_TO_IDLE] = {message = _("RIGHT POWER CONTROL LEVER - TO IDLE"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_R_PCL_AT_IDLE] = {message = _("RIGHT POWER CONTROL LEVER MUST BE AT IDLE"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_R_PCL_SET_TO_FLY] = {message = _("RIGHT POWER CONTROL LEVER - TO FLY"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_R_PCL_AT_FLY] = {message = _("RIGHT POWER CONTROL LEVER MUST BE AT FLY"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_R_PCL_DOWN_TO_IDLE] = {message = _("RIGHT POWER CONTROL LEVER - TO IDLE"), message_timeout = std_message_timeout}

alert_messages[AH64_AD_APU_READY] = {message = _("APU ON LIGHT MUST BE ON WITHIN 20 SEC"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_NpNr_VERIFY] = {message = _("Np AND Nr MUST BE 101%"), message_timeout = std_message_timeout}

alert_messages[AH64_AD_TAIL_WHEEL_LOCK] = {message = _("TAIL WHEEL - LOCK"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_TAIL_WHEEL_UNLOCK] = {message = _("TAIL WHEEL - UNLOCK"), message_timeout = std_message_timeout}

alert_messages[AH64_AD_BLEED_AIR_1_ON] = {message = _("BLEED AIR 1 - ON"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_BLEED_AIR_2_ON] = {message = _("BLEED AIR 2 - ON"), message_timeout = std_message_timeout}

alert_messages[AH64_AD_EMERG_HYDRAULIC_OFF] = {message = _("EMERGENCY HYDRAULIC - OFF"), message_timeout = std_message_timeout}

alert_messages[AH64_AD_PNVS_OFF] = {message = _("PNVS - OFF"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_TADS_OFF] = {message = _("TADS - OFF"), message_timeout = std_message_timeout}
alert_messages[AH64_AD_FCR_OFF] = {message = _("FCR - OFF"), message_timeout = std_message_timeout}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Function to reset Master Warning and Master Caution for both PLT and CPG.
local function resetMasterCautionWarning(startStop)
	-- Reset Master Caution and Master Warning
	push_combined(startStop, dt, {message = _("PLT - MASTER WARNING - Reset"), message_timeout = dt_mto})
	push_combined(startStop, dt, {device = devices.CPTLIGHTS_SYSTEM, action = intlights_commands.MasterWarningPLT, value = 1.0}) -- MSTR WARN
	push_combined(startStop, dt, {device = devices.CPTLIGHTS_SYSTEM, action = intlights_commands.MasterWarningPLT, value = 0.0}) -- release
	push_combined(startStop, dt, {message = _("PLT - MASTER CAUTION - Reset"), message_timeout = dt_mto})
	push_combined(startStop, dt, {device = devices.CPTLIGHTS_SYSTEM, action = intlights_commands.MasterCautionPLT, value = 1.0}) -- MSTR CAUT
	push_combined(startStop, dt, {device = devices.CPTLIGHTS_SYSTEM, action = intlights_commands.MasterCautionPLT, value = 0.0}) -- release
	push_combined(startStop, dt, {message = _("CPG - MASTER WARNING - Reset"), message_timeout = dt_mto})
	push_combined(startStop, dt, {device = devices.CPTLIGHTS_SYSTEM, action = intlights_commands.MasterWarningCPG, value = 1.0}) -- MSTR WARN
	push_combined(startStop, dt, {device = devices.CPTLIGHTS_SYSTEM, action = intlights_commands.MasterWarningCPG, value = 0.0}) -- release
	push_combined(startStop, dt, {message = _("CPG - MASTER CAUTION - Reset"), message_timeout = dt_mto})
	push_combined(startStop, dt, {device = devices.CPTLIGHTS_SYSTEM, action = intlights_commands.MasterCautionCPG, value = 1.0}) -- MSTR CAUT
	push_combined(startStop, dt, {device = devices.CPTLIGHTS_SYSTEM, action = intlights_commands.MasterCautionCPG, value = 0.0}) -- release
end

-- Function to set all the PLT TSD SHOW options.
local function setPltTsdShowOptions(startStop)
	-- TSD SHOW options
	push_combined(startStop, dt, {message = _("PLT - TSD SHOW options - Set all ON (turn off as needed later)"), message_timeout = dt_mto})
	push_combined(startStop, dt, {message = _("Setting up NAV PHASE"), message_timeout = dt_mto})
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.TSD, value = 1.0}) -- TSD
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.TSD, value = 0.0}) -- release
	
	-- NAV PHASE
	-- SHOW page
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T3, value = 1.0}) -- SHOW
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T3, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L3, value = 1.0}) -- INACTIVE ZONES
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L3, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L5, value = 1.0}) -- CPG CURSOR
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L5, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L6, value = 1.0}) -- CURSOR INFO
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L6, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.R4, value = 1.0}) -- HSI
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.R4, value = 0.0}) -- release
	-- THRT SHOW page
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T5, value = 1.0}) -- THRT SHOW
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T5, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.R5, value = 1.0}) -- THREATS
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.R5, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.R6, value = 1.0}) -- TARGETS
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.R6, value = 0.0}) -- release
	-- COORD SHOW page
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T6, value = 1.0}) -- COORD SHOW
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T6, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L3, value = 1.0}) -- FRIENDLY UNITS
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L3, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L4, value = 1.0}) -- ENEMY UNITS
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L4, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L5, value = 1.0}) -- PLANNED TGTS/THREATS
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L5, value = 0.0}) -- release
	
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T6, value = 1.0}) -- COORD SHOW
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T6, value = 0.0}) -- release
	-- now we're back to the TSD > SHOW page
	
	-- ATK PHASE
	push_combined(startStop, dt, {message = _("Setting up ATK PHASE"), message_timeout = dt_mto})
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.B2, value = 1.0}) -- PHASE (to ATK)
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.B2, value = 0.0}) -- release
	-- SHOW page
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L2, value = 1.0}) -- CURRENT ROUTE
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L2, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L6, value = 1.0}) -- CURSOR INFO
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L6, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.R4, value = 1.0}) -- HSI
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.R4, value = 0.0}) -- release
	-- THRT SHOW (already set from the NAV phase)
	-- no action needed
	-- COORD SHOW
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T6, value = 1.0}) -- COORD SHOW
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T6, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L4, value = 1.0}) -- ENEMY UNITS
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.L4, value = 0.0}) -- release
	
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T3, value = 1.0}) -- SHOW
	push_combined(startStop, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T3, value = 0.0}) -- release
	-- End TSD SHOW options, should now be back on the main TSD page.
end

-- Function to set all the CPG TSD SHOW options.
local function setCpgTsdShowOptions(startStop)
	-- TSD SHOW options
	push_combined(startStop, dt, {message = _("CPG - TSD SHOW options - Set all ON (turn off as needed later)"), message_timeout = dt_mto})
	push_combined(startStop, dt, {message = _("Setting up NAV PHASE"), message_timeout = dt_mto})
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.TSD, value = 1.0}) -- TSD
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.TSD, value = 0.0}) -- release
	
	-- NAV PHASE
	-- SHOW page
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.T3, value = 1.0}) -- SHOW
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.T3, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L3, value = 1.0}) -- INACTIVE ZONES
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L3, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L5, value = 1.0}) -- CPG CURSOR
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L5, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L6, value = 1.0}) -- CURSOR INFO
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L6, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.R4, value = 1.0}) -- HSI
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.R4, value = 0.0}) -- release
	-- THRT SHOW page
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.T5, value = 1.0}) -- THRT SHOW
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.T5, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.R5, value = 1.0}) -- THREATS
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.R5, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.R6, value = 1.0}) -- TARGETS
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.R6, value = 0.0}) -- release
	-- COORD SHOW
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.T6, value = 1.0}) -- COORD SHOW
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.T6, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L3, value = 1.0}) -- FRIENDLY UNITS
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L3, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L4, value = 1.0}) -- ENEMY UNITS
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L4, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L5, value = 1.0}) -- PLANNED TGTS/THREATS
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L5, value = 0.0}) -- release
	
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.T6, value = 1.0}) -- COORD SHOW
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.T6, value = 0.0}) -- release
	-- now we're back to the TSD > SHOW page
	
	-- ATK PHASE
	push_combined(startStop, dt, {message = _("Setting up ATK PHASE"), message_timeout = dt_mto})
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.B2, value = 1.0}) -- PHASE (to ATK)
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.B2, value = 0.0}) -- release
	-- SHOW page
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L2, value = 1.0}) -- CURRENT ROUTE
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L2, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L6, value = 1.0}) -- CURSOR INFO
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L6, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.R4, value = 1.0}) -- HSI
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.R4, value = 0.0}) -- release
	-- THRT SHOW (already set from the NAV phase)
	-- no action needed
	-- COORD SHOW
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.T6, value = 1.0}) -- COORD SHOW
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.T6, value = 0.0}) -- release
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L4, value = 1.0}) -- ENEMY UNITS
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L4, value = 0.0}) -- release
	
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.T3, value = 1.0}) -- SHOW
	push_combined(startStop, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.T3, value = 0.0}) -- release
	-- End TSD SHOW options, should now be back on the main TSD page.
end


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Start sequence
local function doStartSequence()
	local seq = start
	
	-- Start sequence
	push_combined(start, 0, {message = _("HAVOC'S QUICK AUTOSTART IS RUNNING"), message_timeout = dt_mto}) -- Message text and timeout will be modified by insertTimeRemaining function below.

	-- Interior check
	-- PLT
	push_combined(seq, dt, {message = _("Parking Brake - SET"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.GEAR_INTERFACE, action = gear_commands.AH64_ParkingBrake, value = 1.0})
	push_combined(seq, dt, {message = _("RTR BRK switch - OFF"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.HYDRO_INTERFACE, action = hydraulic_commands.Rotor_Brake, value = 1.0})
	
	-- Starting APU - PILOT
	push_combined(seq, dt, {message = _("MSTR IGN switch - BATT"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.ELEC_INTERFACE, action = electric_commands.MIK, value = 0.5})
	push_combined(seq, dt, {message = _("Starting APU (20s)"), message_timeout = 21.0})
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.APU_StartBtnCover, value = 1.0})
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.APU_StartBtn, value = 1.0})
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.APU_StartBtn, value = 0.0})
	push_combined(seq, 20.0, {check_condition = AH64_AD_APU_READY, message_timeout = dt_mto})
	push_combined(seq, dt, {message = _("Waiting for EGI alignment, shows TSD chart background when finished (3m55s) ..."), message_timeout = dt_awt})
	local alignment_timer = t_start -- Start a timer for the alignment process at the current t_start value.

	-- After starting APU
	
	-- Radio volumes and squelch
	-- PLT
	push_combined(seq, dt, {message = _("PLT Radio squelch switches - ON (also squelches CPG radios)"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.VHF_SQL_ON, value = 1.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.VHF_SQL_ON, value = 0.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.UHF_SQL_ON, value = 1.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.UHF_SQL_ON, value = 0.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.FM1_SQL_ON, value = 1.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.FM1_SQL_ON, value = 0.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.FM2_SQL_ON, value = 1.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.FM2_SQL_ON, value = 0.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.HF_SQL_ON, value = 1.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.HF_SQL_ON, value = 0.0})
	push_combined(seq, dt, {message = _("PLT Radio RLWR volume - 75%"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.RLWR_volume, value = 0.75})
	---- CPG
	--push_combined(seq, dt, {message = _("CPG Radio squelch switches - ON"), message_timeout = dt_mto})
	--push_combined(seq, dt, {device = devices.COMM_PANEL_CPG, action = comm_commands.VHF_SQL, value = 1.0})
	--push_combined(seq, dt, {device = devices.COMM_PANEL_CPG, action = comm_commands.UHF_SQL, value = 1.0})
	--push_combined(seq, dt, {device = devices.COMM_PANEL_CPG, action = comm_commands.FM1_SQL, value = 1.0})
	--push_combined(seq, dt, {device = devices.COMM_PANEL_CPG, action = comm_commands.FM2_SQL, value = 1.0})
	--push_combined(seq, dt, {device = devices.COMM_PANEL_CPG, action = comm_commands.HF_SQL, value = 1.0})
	push_combined(seq, dt, {message = _("CPG Radio RLWR volume - 75%"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.COMM_PANEL_CPG, action = comm_commands.RLWR_volume, value = 0.75})
	
	-- Canopy close
	push_combined(seq, dt, {message = _("Canopy Door - Close"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.CPT_MECH, action = cpt_mech_commands.PLT_Door_Lock, value = 0.0})
	push_combined(seq, dt, {device = devices.CPT_MECH, action = cpt_mech_commands.CPG_Door_Lock, value = 0.0})

	-- Internal lights
	push_combined(seq, dt, {message = _("PLT Internal Lights - ON"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.CPTLIGHTS_SYSTEM, action = intlights_commands.SignalPLT, value = 1.0})
	push_combined(seq, dt, {device = devices.CPTLIGHTS_SYSTEM, action = intlights_commands.PrimaryPLT, value = 1.0})
	push_combined(seq, dt, {device = devices.CPTLIGHTS_SYSTEM, action = intlights_commands.StbyInstPLT, value = 1.0})
	push_combined(seq, dt, {message = _("CPG Internal Lights - ON"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.CPTLIGHTS_SYSTEM, action = intlights_commands.SignalCPG, value = 1.0})
	push_combined(seq, dt, {device = devices.CPTLIGHTS_SYSTEM, action = intlights_commands.PrimaryCPG, value = 1.0})
	push_combined(seq, dt, {device = devices.CPTLIGHTS_SYSTEM, action = intlights_commands.StbyInstCPG, value = 1.0})

	-- TEDAC
	push_combined(seq, dt, {message = _("CPG TEDAC TDU power knob - ON"), message_timeout = dt_mto})
	-- FIXME: TDU power knob is a little weird... "TDU_MODE_KNOB" command seems to set it to DAY no matter what value is used.  "TDU_MODE_KNOB_ITER" command allows changing the knob one position at a time (positive value for right/CW rotation, negative value for left/CCW), but this command only works if the command executes while you're sitting in the CPG seat.  Therefore, I'm using "TDU_MODE_KNOB".  The shutdown sequence will not turn it off (because every value sets it to DAY), but it doesn't really matter.
	push_combined(seq, dt, {device = devices.TEDAC, action = tedac_commands.TDU_MODE_KNOB, value = 0.2})
	
	-- Use local time
	push_combined(seq, dt, {message = _("TIME - LOCAL"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.TSD, value = 1.0}) -- TSD
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.TSD, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T6, value = 1.0}) -- UTIL
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T6, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.R2, value = 1.0}) -- TIME
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.R2, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T6, value = 1.0}) -- UTIL
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.T6, value = 0.0}) -- release

	-- TSD SHOW options
	setPltTsdShowOptions(seq)
	setCpgTsdShowOptions(seq)

	-- CMWS
	push_combined(seq, dt, {message = _("CMWS PWR knob - ON"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.CMWS, action = CMWS_commands.CMWS_PWR, value = 0.0})
	push_combined(seq, dt, {message = _("CMWS ARM/SAFE switch - ARM"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.CMWS, action = CMWS_commands.CMWS_ARM_SAFE_SW, value = 1.0})
	push_combined(seq, dt, {message = _("CMWS CMWS/NAV switch - CMWS"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.CMWS, action = CMWS_commands.CMWS_CMWS_NAV_SW, value = 1.0})
	push_combined(seq, dt, {message = _("CMWS BYPASS/AUTO switch - BYPASS"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.CMWS, action = CMWS_commands.CMWS_BYPASS_AUTO_SW, value = 1.0})

	-- ASE CHAFF
	push_combined(seq, dt, {message = _("ASE CHAFF - ARM"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.B1, value = 1.0}) -- MENU
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.B1, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.L3, value = 1.0}) -- ASE
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.L3, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.T1, value = 1.0}) -- CHAFF (to ARM)
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.T1, value = 0.0}) -- release

	-- RLWS enable
	push_combined(seq, dt, {message = _("RLWR - ON"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.B1, value = 1.0}) -- MENU
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.B1, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.L3, value = 1.0}) -- ASE
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.L3, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.T6, value = 1.0}) -- UTIL
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.T6, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.R4, value = 1.0}) -- RLWR
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.R4, value = 0.0}) -- release

	-- SAI
	push_combined(seq, dt, {message = _("Standby Attitude Indicator - Uncage and center"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.SAI, action = sai_commands.CageKnobRotate_ITER, value = -1.8}) -- Turn left to unlock, note "CageKnobRotate" does not seem to work, only "CageKnobRotate_ITER" and "CageKnobRotate_AXIS"
	push_combined(seq, dt, {device = devices.SAI, action = sai_commands.CageKnobPull, value = 0.0}) -- Press knob in to uncage
	push_combined(seq, dt, {device = devices.SAI, action = sai_commands.CageKnobRotate_AXIS, value = 0.0}) -- Center SAI

	-- Starting engines - PILOT
	push_combined(seq, dt, {message = _("Starting engines (1m25s)"), message_timeout = dt_es})
	push_combined(seq, dt, {message = _("POWER levers - OFF"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.PLT_BothPowerLevers_EXT, value = 0})
	push_combined(seq, dt, {check_condition = AH64_AD_L_PCL_AT_OFF, message_timeout = dt_mto})
	push_combined(seq, dt, {check_condition = AH64_AD_R_PCL_AT_OFF, message_timeout = dt_mto})
	push_combined(seq, dt, {message = _("Collective - Flat pitch"), message_timeout = dt_mto})
	push_combined(seq, dt, {check_condition = AH64_AD_COLLECTIVE_SET_DOWN, message_timeout = dt_mto})
	push_combined(seq, 2.0, {check_condition = AH64_AD_COLLECTIVE_AT_DOWN, message_timeout = dt_mto})

	push_combined(seq, dt, {message = _("ENG page - Select"), message_timeout = dt_es})
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.AC, value = 1.0}) -- A/C (goes directly to ENG page)
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.AC, value = 0.0}) -- release

	push_combined(seq, dt, {message = _("FIRST ENGINE (30s)"), message_timeout = dt_1es})
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.Eng1StartSw, value = 1.0})
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.Eng1StartSw, value = 0.0})
	push_combined(seq, 2.0, {check_condition = AH64_AD_L_PCL_SET_TO_IDLE, message_timeout = dt_mto})
	push_combined(seq, 1.0, {check_condition = AH64_AD_L_PCL_AT_IDLE, message_timeout = dt_mto})
	-- TODO: check engine params
	push_combined(seq, dt_1es, {message = _("SECOND ENGINE (40s)"), message_timeout = dt_2es})
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.Eng2StartSw, value = 1.0})
	push_combined(seq, 45, {device = devices.ENGINE_INTERFACE, action = engine_commands.Eng2StartSw, value = 0.0})
	push_combined(seq, 2.0, {check_condition = AH64_AD_R_PCL_SET_TO_IDLE, message_timeout = dt_mto})
	push_combined(seq, 1.0, {check_condition = AH64_AD_R_PCL_AT_IDLE, message_timeout = dt_mto})
	-- TODO: check engine params
	
	push_combined(seq, dt_2es, {message = _("POWER levers - Smoothly to FLY"), message_timeout = 10.0})
	local SMOOTHLY_TO_FLY_N = 100
	for i = 1, SMOOTHLY_TO_FLY_N, 1 do
		local PCL_IDLE = 0.25
		local PCL_FLY = 0.9
		local PCL_IDLE_TO_FLY = PCL_FLY - PCL_IDLE
		local rel_pos = i / SMOOTHLY_TO_FLY_N
		local SMOOTHLY_TIME = 10.0
		local dt_SMOOTHLY = SMOOTHLY_TIME / SMOOTHLY_TO_FLY_N
		push_combined(seq, dt_SMOOTHLY, {device = devices.ENGINE_INTERFACE, action = engine_commands.PLT_BothPowerLevers_EXT, value = PCL_IDLE + PCL_IDLE_TO_FLY * rel_pos})
	end
	push_combined(seq, dt, {check_condition = AH64_AD_L_PCL_AT_FLY, message_timeout = dt_mto})
	push_combined(seq, dt, {check_condition = AH64_AD_L_PCL_AT_FLY, message_timeout = dt_mto})
	push_combined(seq, 7.0, {message = _("Np and Nr - Verify 101%"), message_timeout = dt_mto})
	push_combined(seq, dt, {check_condition = AH64_AD_NpNr_VERIFY, message_timeout = dt_mto})
	push_combined(seq, dt, {message = _("APU - OFF"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.APU_StartBtn, value = 1.0})
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.APU_StartBtn, value = 0.0})
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.APU_StartBtnCover, value = 0.0})
	-- Engine start complete

	--After engine start
	-- AUX tank
	push_combined(seq, dt, {message = _("AUX fuel tank - ON"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.AC, value = 1.0}) -- A/C (goes directly to ENG page)
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.AC, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.T3, value = 1.0}) -- FUEL
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.T3, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.L2, value = 1.0}) -- C AUX
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.L2, value = 0.0}) -- release

	-- WCA reset
	push_combined(seq, dt, {message = _("WCA - Reset"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.B1, value = 1.0}) -- MENU
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.B1, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.B1, value = 1.0}) -- DMS
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.B1, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.B6, value = 1.0}) -- WCA
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.B6, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.B4, value = 1.0}) -- RESET
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.B4, value = 0.0}) -- release

	-- PLT ACQ to TADS
	push_combined(seq, dt, {message = _("PLT ACQ (Acquisition Source) - TADS"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.TSD, value = 1.0}) -- TSD
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.TSD, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.R6, value = 1.0}) -- ACQ
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.R6, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.B6, value = 1.0}) -- TADS
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.B6, value = 0.0}) -- release
	
	-- CPG ACQ to TADS
	push_combined(seq, dt, {message = _("CPG ACQ (Acquisition Source) - TADS"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.TSD, value = 1.0}) -- TSD
	push_combined(seq, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.TSD, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.R6, value = 1.0}) -- ACQ
	push_combined(seq, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.R6, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.B6, value = 1.0}) -- TADS
	push_combined(seq, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.B6, value = 0.0}) -- release
	
	-- PLT Weapon MAN RNG to 800 m (a more useful default)
	push_combined(seq, dt, {message = _("PLT Weapon MAN RNG - 800 m"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.WPN, value = 1.0}) -- WPN
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.WPN, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.B6, value = 1.0}) -- MAN RNG>
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.B6, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.KU_PLT, action = KU_commands.key8, value = 1.0}) -- KU key press
	push_combined(seq, dt, {device = devices.KU_PLT, action = KU_commands.key8, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.KU_PLT, action = KU_commands.key0, value = 1.0}) -- KU key press
	push_combined(seq, dt, {device = devices.KU_PLT, action = KU_commands.key0, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.KU_PLT, action = KU_commands.key0, value = 1.0}) -- KU key press
	push_combined(seq, dt, {device = devices.KU_PLT, action = KU_commands.key0, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.KU_PLT, action = KU_commands.keyEnter, value = 1.0}) -- KU key press
	push_combined(seq, dt, {device = devices.KU_PLT, action = KU_commands.keyEnter, value = 0.0}) -- release
	-- Return to TSD.
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.TSD, value = 1.0}) -- TSD
	push_combined(seq, dt, {device = devices.MFD_PLT_RIGHT, action = mpd_commands.TSD, value = 0.0}) -- release
	
	-- CPG Weapon MAN RNG to 800 m (a more useful default)
	push_combined(seq, dt, {message = _("CPG Weapon MAN RNG - 800 m"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_CPG_LEFT, action = mpd_commands.WPN, value = 1.0}) -- WPN
	push_combined(seq, dt, {device = devices.MFD_CPG_LEFT, action = mpd_commands.WPN, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_CPG_LEFT, action = mpd_commands.B6, value = 1.0}) -- MAN RNG>
	push_combined(seq, dt, {device = devices.MFD_CPG_LEFT, action = mpd_commands.B6, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.KU_CPG, action = KU_commands.key8, value = 1.0}) -- KU key press
	push_combined(seq, dt, {device = devices.KU_CPG, action = KU_commands.key8, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.KU_CPG, action = KU_commands.key0, value = 1.0}) -- KU key press
	push_combined(seq, dt, {device = devices.KU_CPG, action = KU_commands.key0, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.KU_CPG, action = KU_commands.key0, value = 1.0}) -- KU key press
	push_combined(seq, dt, {device = devices.KU_CPG, action = KU_commands.key0, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.KU_CPG, action = KU_commands.keyEnter, value = 1.0}) -- KU key press
	push_combined(seq, dt, {device = devices.KU_CPG, action = KU_commands.keyEnter, value = 0.0}) -- release
	-- CPG enable laser (start from WPN page)
	push_combined(seq, dt, {message = _("CPG LASER - ON"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_CPG_LEFT, action = mpd_commands.T6, value = 1.0}) -- UTIL
	push_combined(seq, dt, {device = devices.MFD_CPG_LEFT, action = mpd_commands.T6, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_CPG_LEFT, action = mpd_commands.L6, value = 1.0}) -- LASER
	push_combined(seq, dt, {device = devices.MFD_CPG_LEFT, action = mpd_commands.L6, value = 0.0}) -- release-
	push_combined(seq, dt, {device = devices.MFD_CPG_LEFT, action = mpd_commands.T6, value = 1.0}) -- UTIL
	push_combined(seq, dt, {device = devices.MFD_CPG_LEFT, action = mpd_commands.T6, value = 0.0}) -- release
	-- leaves CPG on WPN page on left MFD
	
	-- PLT Show TADS video on left MFD
	push_combined(seq, dt, {message = _("PLT Show TADS video"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.VID, value = 1.0}) -- VID
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.VID, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.R1, value = 1.0}) -- TADS
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.R1, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.T6, value = 1.0}) -- TADS
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.T6, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.L3, value = 1.0}) -- Z (zooms view)
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.L3, value = 0.0}) -- release
	
	push_combined(seq, dt, {message = _("Manual steps remaining while waiting for alignment:"), message_timeout = 90.0})
	push_combined(seq, dt, {message = _("Boresight IHADSS (WPN > BORESIGHT > IHADSS > align reticles > B/S NOW)"), message_timeout = 90.0})
	push_combined(seq, dt, {message = _("Set Hellfire seeker and laser designator codes (WPN > CHAN and CODE)"), message_timeout = 90.0})
	push_combined(seq, dt, {message = _("Tune radios (COM > MAN)"), message_timeout = 90.0})
	push_combined(seq, dt, {message = _("Set baro altitude (A/C > FLT  > SET > ALT or PRESS)"), message_timeout = 90.0})
	
	-- Wait until the alignment is complete (total process time minus the difference between now and when the process started).
	push_combined(seq, dt_awt - (t_start - alignment_timer), {message = _("HAVOC'S QUICK AUTOSTART IS COMPLETE"), message_timeout = 60.0})
end
doStartSequence()


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Stop sequence
local function doStopSequence()
	local seq = stop
	push_combined(seq, 0, {message = _("HAVOC'S QUICK AUTOSTOP IS RUNNING"), message_timeout = dt_mto}) -- Message text and timeout will be modified by insertTimeRemaining function below.
	
	push_combined(seq, dt, {message = _("Starting APU (20s)"), message_timeout = 21.0})
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.APU_StartBtnCover, value = 1.0}) -- Cover open
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.APU_StartBtn, value = 1.0}) -- Press
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.APU_StartBtn, value = 0.0}) -- Release
	push_combined(seq, 20.0, {check_condition = AH64_AD_APU_READY, message_timeout = dt_mto})
	
	push_combined(seq, dt, {message = _("TAIL WHEEL button - LOCK"), message_timeout = dt_mto})
	push_combined(seq, dt, {check_condition = AH64_AD_TAIL_WHEEL_LOCK, message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.HYDRO_INTERFACE, action = hydraulic_commands.TailWheelUnLock_PLT, value = 0.0}) -- PLT
	push_combined(seq, dt, {device = devices.HYDRO_INTERFACE, action = hydraulic_commands.TailWheelUnLock_CPG, value = 0.0}) -- CPG
	
	push_combined(seq, dt, {message = _("Parking Brake - SET"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.GEAR_INTERFACE, action = gear_commands.AH64_ParkingBrake, value = 1.0})
	push_combined(seq, dt, {message = _("POWER Levers - Smoothly to IDLE"), message_timeout = dt_mto})
	local SMOOTHLY_TO_IDLE_N = 100
	for i = 1, SMOOTHLY_TO_IDLE_N, 1 do
		local PCL_IDLE = 0.25
		local PCL_FLY = 0.9
		local PCL_IDLE_TO_FLY = PCL_FLY - PCL_IDLE
		local rel_pos = 1.0 - i / SMOOTHLY_TO_IDLE_N
		local SMOOTHLY_TIME = 2.0
		local dt_SMOOTHLY = SMOOTHLY_TIME / SMOOTHLY_TO_IDLE_N
		push_combined(seq, dt_SMOOTHLY, {device = devices.ENGINE_INTERFACE, action = engine_commands.PLT_BothPowerLevers_EXT, value = PCL_IDLE + PCL_IDLE_TO_FLY * rel_pos})
	end
	push_combined(seq, dt, {check_condition = AH64_AD_L_PCL_AT_IDLE, message_timeout = dt_mto})
	push_combined(seq, dt, {check_condition = AH64_AD_R_PCL_AT_IDLE, message_timeout = dt_mto})
	
	resetMasterCautionWarning(stop)
	
	push_combined(seq, dt, {message = _("Standby Attitude Indicator - Cage"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.SAI, action = sai_commands.CageKnobRotate_AXIS, value = 0.0}) -- Center SAI
	push_combined(seq, dt, {device = devices.SAI, action = sai_commands.CageKnobPull, value = 1.0}) -- Pull knob out to cage
	push_combined(seq, dt, {device = devices.SAI, action = sai_commands.CageKnobRotate_ITER, value = 1.8}) -- Turn right to lock, note "CageKnobRotate" does not seem to work, only "CageKnobRotate_ITER" and "CageKnobRotate_AXIS"
	push_combined(seq, dt, {device = devices.SAI, action = sai_commands.CageKnobPull, value = 0.0}) -- Push knob back in so it will unlock if turned manually
	
	push_combined(seq, dt, {message = _("NVS MODE switch - OFF"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.ELEC_INTERFACE, action = electric_commands.NVS_MODE_PLT_KNOB, value = -1.0}) -- PLT
	push_combined(seq, dt, {device = devices.ELEC_INTERFACE, action = electric_commands.NVS_MODE_CPG_KNOB, value = -1.0}) -- CPG
	
	push_combined(seq, dt, {message = _("PNVS - OFF"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.WPN, value = 1.0}) -- WPN
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.WPN, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.T6, value = 1.0}) -- UTIL
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.T6, value = 0.0}) -- Release
	push_combined(seq, dt, {check_condition = AH64_AD_PNVS_OFF, message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.L4, value = 0.0}) -- PNVS
	
	push_combined(seq, dt, {message = _("TADS, FCR - OFF"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.WPN, value = 1.0}) -- WPN
	push_combined(seq, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.WPN, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.T6, value = 1.0}) -- UTIL
	push_combined(seq, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.T6, value = 0.0}) -- release
	push_combined(seq, dt, {check_condition = AH64_AD_TADS_OFF, message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L4, value = 0.0}) -- TADS
	push_combined(seq, dt, {check_condition = AH64_AD_FCR_OFF, message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_CPG_RIGHT, action = mpd_commands.L3, value = 0.0}) -- FCR
	
	-- TEDAC
	--push_combined(seq, dt, {message = _("CPG TEDAC TDU power knob - OFF"), message_timeout = dt_mto})
	-- FIXME: TDU power knob is a little weird... "TDU_MODE_KNOB" command seems to set it to DAY no matter what value is used.  "TDU_MODE_KNOB_ITER" command allows changing the knob one position at a time (positive value for right/CW rotation, negative value for left/CCW), but this only works if the command executes while you're sitting in the CPG seat.  Therefore, I'm using "TDU_MODE_KNOB".  The shutdown sequence will not turn it off (because every value sets it to DAY), but it doesn't really matter.
	--push_combined(seq, dt, {device = devices.TEDAC, action = tedac_commands.TDU_MODE_KNOB, value = 0.2})
	
	push_combined(seq, dt, {message = _("A/C Page - Select"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.AC, value = 1.0}) -- A/C (goes directly to ENG page)
	push_combined(seq, dt, {device = devices.MFD_PLT_LEFT, action = mpd_commands.AC, value = 0.0}) -- release
	push_combined(seq, dt, {device = devices.MFD_CPG_LEFT, action = mpd_commands.AC, value = 1.0}) -- A/C (goes directly to ENG page)
	push_combined(seq, dt, {device = devices.MFD_CPG_LEFT, action = mpd_commands.AC, value = 0.0}) -- release
	
	push_combined(seq, dt, {message = _("POWER Levers - OFF"), message_timeout = dt_mto})
	push_combined(seq, dt, {check_condition = AH64_AD_L_PCL_SET_TO_OFF, message_timeout = dt_mto})
	push_combined(seq, 1.0, {check_condition = AH64_AD_L_PCL_AT_OFF, message_timeout = dt_mto}) -- Wait one second before checking.
	push_combined(seq, dt, {check_condition = AH64_AD_R_PCL_SET_TO_OFF, message_timeout = dt_mto})
	push_combined(seq, 1.0, {check_condition = AH64_AD_R_PCL_AT_OFF, message_timeout = dt_mto}) -- Wait one second before checking.
	
	push_combined(seq, dt, {message = _("Wait for rotor to get below 50% Nr (5s)"), message_timeout = 5.0})
	push_combined(seq, 5.0, {message = _("RTR BRK switch - BRK"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.HYDRO_INTERFACE, action = hydraulic_commands.Rotor_Brake, value = 0.0})
	
	push_combined(seq, dt, {message = _("SEARCHLIGHT - OFF"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.HOTAS_PLT, action = hotas_commands.FLIGHT_SEARCHLIGHT_SW_DOWN, value = -1.0})
	push_combined(seq, 5.0, {device = devices.HOTAS_PLT, action = hotas_commands.FLIGHT_SEARCHLIGHT_SW_DOWN, value = 0.0})
	
	push_combined(seq, dt, {message = _("Wait for rotor to stop (35s)"), message_timeout = 35.0})
	push_combined(seq, 35.0, {message = _("RTR BRK SWITCH - OFF"), message_timeout = 35.0})
	push_combined(seq, dt, {device = devices.HYDRO_INTERFACE, action = hydraulic_commands.Rotor_Brake, value = 1.0})
	push_combined(seq, dt, {message = _("EXT LT/INTR LT PANEL switches - OFF"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.EXTLIGHTS_SYSTEM, action = extlights_commands.NavLights, value = 0.0})
	push_combined(seq, dt, {device = devices.EXTLIGHTS_SYSTEM, action = extlights_commands.AntiCollLights, value = 0.0})
	
	-- Radio volumes and squelch
	-- PLT
	push_combined(seq, dt, {message = _("PLT Radio squelch switches - OFF"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.VHF_SQL, value = 0.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.UHF_SQL, value = 0.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.FM1_SQL, value = 0.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.FM2_SQL, value = 0.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.HF_SQL, value = 0.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_PLT, action = comm_commands.RLWR_volume, value = 0.0})
	-- CPG
	push_combined(seq, dt, {message = _("CPG Radio squelch switches - OFF"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.COMM_PANEL_CPG, action = comm_commands.VHF_SQL, value = 0.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_CPG, action = comm_commands.UHF_SQL, value = 0.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_CPG, action = comm_commands.FM1_SQL, value = 0.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_CPG, action = comm_commands.FM2_SQL, value = 0.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_CPG, action = comm_commands.HF_SQL, value = 0.0})
	push_combined(seq, dt, {device = devices.COMM_PANEL_CPG, action = comm_commands.RLWR_volume, value = 0.0})
	
	-- CMWS
	push_combined(seq, dt, {message = _("CMWS PWR knob - ON"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.CMWS, action = CMWS_commands.CMWS_PWR, value = -1.0})
	push_combined(seq, dt, {message = _("CMWS ARM/SAFE switch - ARM"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.CMWS, action = CMWS_commands.CMWS_ARM_SAFE_SW, value = 0.0})
	push_combined(seq, dt, {message = _("CMWS CMWS/NAV switch - CMWS"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.CMWS, action = CMWS_commands.CMWS_CMWS_NAV_SW, value = 0.0})
	push_combined(seq, dt, {message = _("CMWS BYPASS/AUTO switch - BYPASS"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.CMWS, action = CMWS_commands.CMWS_BYPASS_AUTO_SW, value = 0.0})
	
	push_combined(seq, dt, {message = _("APU - OFF"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.APU_StartBtn, value = 1.0}) -- Press
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.APU_StartBtn, value = 0.0}) -- Release
	push_combined(seq, dt, {device = devices.ENGINE_INTERFACE, action = engine_commands.APU_StartBtnCover, value = 0.0}) -- Cover close
	
	push_combined(seq, dt, {message = _("MSTR IGN switch - OFF"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.ELEC_INTERFACE, action = electric_commands.MIK, value = 0.0})
	
	-- Canopy
	push_combined(seq, dt, {message = _("Canopy Door - Open"), message_timeout = dt_mto})
	push_combined(seq, dt, {device = devices.CPT_MECH, action = cpt_mech_commands.PLT_Door_Lock, value = 1.0})
	push_combined(seq, dt, {device = devices.CPT_MECH, action = cpt_mech_commands.CPG_Door_Lock, value = 1.0})
	
	push_combined(seq, dt, {message = _("HAVOC'S QUICK AUTOSTOP IS COMPLETE"), message_timeout = 60.0})
end
doStopSequence()


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Inserts messages into the sequence that show how many minutes there are remaining in the sequence.  Adds " (XmXs)" time display to the end of the first item in the sequence (which must be a message, and is by default).  Sets the message timeout of the first item to be the total time.
local function insertTimeRemaining(sequence, endingTime)
	local totalTime = math.ceil(endingTime) -- Round up to the next whole second.
	local totalTimeMins = math.floor(totalTime / 60)
	local totalTimeSecs = totalTime % 60
	-- Add the total time onto the end of the initial sequence message.
	sequence[1]['message'] = sequence[1]['message']..' ('..totalTimeMins..'m'..totalTimeSecs..'s)'
	-- Set the message timeout to be the total time.
	sequence[1]['message_timeout'] = endingTime

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
