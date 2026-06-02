// initSectorControl.sqf
// Master boot script for the A3M Sector Control State Machine
// Executed via [] call A3M_fnc_initSectorControl; in initServer.sqf

if (!isServer) exitWith {};

diag_log "A3M SECTOR CONTROL: Initializing Master State Machine...";

// 1. Establish the Global HashMaps and Arrays
if (isNil "A3M_SectorControlState") then { A3M_SectorControlState = createHashMap; };
if (isNil "A3M_PendingAI_Spawns") then { A3M_PendingAI_Spawns = []; };

// 2. Start the Master CBA Per-Frame Handlers (PFH)
// These replace the legacy while {true} spawn loops.

// A. The Economic/Reward Heartbeat (Ticks every 10 seconds)
[A3M_fnc_manageSectorsTick, 10, []] call CBA_fnc_addPerFrameHandler;
diag_log "A3M SECTOR CONTROL: manageSectorsTick PFH started (10s interval).";

// B. The AI Spawner Decoupler (Ticks every 5 seconds)
[A3M_fnc_processAIQueue, 5, []] call CBA_fnc_addPerFrameHandler;
diag_log "A3M SECTOR CONTROL: processAIQueue PFH started (5s interval).";

// C. The Unit Spawner Heartbeat (Ticks every 120 seconds)
[A3M_fnc_spawnSectorControlUnitsTick, 120, []] call CBA_fnc_addPerFrameHandler;
diag_log "A3M SECTOR CONTROL: spawnSectorControlUnitsTick PFH started (120s interval).";

diag_log "A3M SECTOR CONTROL: Initialization Complete.";