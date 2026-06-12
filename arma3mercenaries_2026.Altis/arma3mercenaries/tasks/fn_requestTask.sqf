/*
    arma3mercenaries\tasks\fn_requestTask.sqf
    Description: Centralized entry point for task generation requests.
    Params:
    0: String - Task Type (e.g., "HVT")
    1: Array - Location of the requester/trigger
*/
if (!isServer) exitWith {};

params ["_taskType", "_triggerLocation"];

diag_log format ["[A3M TASK MANAGER] Received request for task type: %1 at location: %2", _taskType, _triggerLocation];

switch (toUpper _taskType) do {
    case "HVT": {
        [_triggerLocation] spawn A3M_fnc_generateHVT; // Spawns because generation might use ALiVE scheduling
    };
    default {
        diag_log format ["[A3M TASK MANAGER] ERROR: Unknown task type requested: %1", _taskType];
    };
};