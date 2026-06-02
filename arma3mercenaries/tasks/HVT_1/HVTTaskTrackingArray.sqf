/*
    arma3mercenaries\tasks\HVT_1\HVTTaskTrackingArray.sqf
    Author: BrianV1981 / Gemini 2.5
    Description:
	A global array initialized on the server
*/

// initServer.sqf (or similar server-only init script)
if (isNil "server_activeHvtTasks") then {
    server_activeHvtTasks = [];
    // No need to publicVariable this array, as only the server needs to write/read it directly.
    // Client task updates happen via BIS_fnc_taskSetDestination.
    diag_log "SERVER: Initialized server_activeHvtTasks array.";
};