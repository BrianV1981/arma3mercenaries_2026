// arma3mercenaries\interrogations\civs\initGatherCivsTask.sqf
// MODIFIED: Corrected BIS_fnc_taskCreate parameters

// --- Task Constants ---
TASK_ID_GATHER_CIVS = "GatherCivs"; // Ensure this matches CfgTaskDescriptions class name
GATHER_CIVS_SIDES = [west, independent]; // Sides who get the task

diag_log "--- Starting initGatherCivsTask.sqf ---";

// --- Interrogation Location Setup ---
diag_log "[Interrogation Task] Waiting for bodybag objects...";
waitUntil {sleep 0.5; !isNull interrogation_bodybag_1 && {!isNull interrogation_bodybag_2}};
diag_log "[Interrogation Task] Bodybag objects are not null.";

// Store positions globally (optional but useful)
interrogation_loc_1_pos = getPosATL interrogation_bodybag_1;
interrogation_loc_2_pos = getPosATL interrogation_bodybag_2;
diag_log format ["[Interrogation Task] Bodybag Pos1: %1, Pos2: %2", interrogation_loc_1_pos, interrogation_loc_2_pos];

// --- Function to Create/Assign the Task ---
fnc_createOrAssignGatherTask = {
    params ["_side"];
    private _taskState = [TASK_ID_GATHER_CIVS, _side] call BIS_fnc_taskState;

    diag_log format ["[Interrogation Task] Checking task '%1' for side %2. Current State: %3", TASK_ID_GATHER_CIVS, _side, _taskState]; // Added state log

    // Only create if it doesn't exist or failed/cancelled
    if (_taskState in ["NONE", "FAILED", "CANCELLED"]) then {
        if (_taskState != "NONE") then {
             diag_log format ["[Interrogation Task] Deleting previous task '%1' locally for side %2 before recreation.", TASK_ID_GATHER_CIVS, _side];
             // Clean up old task markers/destinations if resetting
            [TASK_ID_GATHER_CIVS, _side] remoteExecCall ["BIS_fnc_deleteTask", _side]; // Tell side to delete local task info
            sleep 0.1; // Brief pause
        };

        diag_log format ["[Interrogation Task] Creating/Assigning task '%1' for side %2", TASK_ID_GATHER_CIVS, _side];

        // --- CORRECTED BIS_fnc_taskCreate Call ---
        private _taskResult = [
            _side,                                  // Owner side(s)
            TASK_ID_GATHER_CIVS,                    // Task ID
            "",                                     // Description: Use "" to lookup in CfgTaskDescriptions by Task ID
            [interrogation_loc_1_pos, interrogation_loc_2_pos], // Destinations (Array of positions)
            "CREATED",                              // Initial state
            5,                                      // Priority
            true,                                   // Show notification
            "default",                              // Type: Use "default" or "" or a specific type string
            false                                   // Visible in 3D: false = not always visible, true = always visible
        ] call BIS_fnc_taskCreate;
        // --- End Corrected Call ---

        diag_log format ["[Interrogation Task] BIS_fnc_taskCreate called for side %1. Result: %2", _side, _taskResult]; // Log result

        // Optional checks/logging based on result (BIS_fnc_taskCreate returns Boolean)
        if (!_taskResult) then {
            diag_log format ["[Interrogation Task] WARNING: BIS_fnc_taskCreate returned false for side %1. Task may not have been created correctly.", _side];
        };

        // Ensure task exists before setting parent/type (optional)
        // waitUntil { !isNil { missionNamespace getVariable (format ["bis_task_%1", TASK_ID_GATHER_CIVS]) } };
        // [TASK_ID_GATHER_CIVS, _side] call BIS_fnc_taskSetType ["default"]; // Already set type in create call

        // Set custom map markers if desired (optional)
        // [TASK_ID_GATHER_CIVS, _side, 0] call BIS_fnc_taskSetDestination; // Sets first destination active
        // private _marker1 = format ["%1_marker_%2_0", side _side, TASK_ID_GATHER_CIVS];
        // private _marker2 = format ["%1_marker_%2_1", side _side, TASK_ID_GATHER_CIVS];
        // [_marker1, "loc_Pickup"] remoteExecCall ["setMarkerTypeLocal", _side];
        // [_marker2, "loc_Pickup"] remoteExecCall ["setMarkerTypeLocal", _side];

    } else {
        diag_log format ["[Interrogation Task] Task '%1' already active or succeeded for side %2 (State: %3). No action taken.", TASK_ID_GATHER_CIVS, _side, _taskState];
    };
};

// --- Initial Task Creation for Allowed Sides ---
diag_log "[Interrogation Task] Starting initial task creation loop...";
{
    diag_log format ["[Interrogation Task] Processing side: %1 for initial task creation", _x];
    [_x] call fnc_createOrAssignGatherTask;
} forEach GATHER_CIVS_SIDES;
diag_log "[Interrogation Task] Finished initial task creation loop.";


// --- Task Reset Loop ---
// This loop checks if the task is completed and resets it after a delay
[] spawn {
    diag_log "[Interrogation Task] Task Reset Loop Spawned.";
    // Wait a bit initially for mission setup
    sleep 120; // Initial delay before first check
    diag_log "[Interrogation Task] Task Reset Loop starting checks.";

    while {true} do {
        sleep 60; // Check every minute

        {
            private _sideToCheck = _x;
            // Check task state on the server
            private _taskState = [TASK_ID_GATHER_CIVS, _sideToCheck] call BIS_fnc_taskState;

            // If task is succeeded, reset it for that side
            if (_taskState == "SUCCEEDED") then {
                diag_log format ["[Interrogation Task] Task '%1' SUCCEEDED for side %2. Resetting.", TASK_ID_GATHER_CIVS, _sideToCheck];
                // Delete old task state server-side first
                 [TASK_ID_GATHER_CIVS, _sideToCheck] call BIS_fnc_deleteTask; // Server deletes its record
                 diag_log format ["[Interrogation Task] Server deleted task state for side %1.", _sideToCheck];
                 sleep 0.1;
                // Recreate/Assign (which will also remoteExec a client delete)
                diag_log format ["[Interrogation Task] Re-running task creation for side %1.", _sideToCheck];
                [_x] call fnc_createOrAssignGatherTask; // Use _x directly here, same as _sideToCheck
            };
        } forEach GATHER_CIVS_SIDES;
    };
};

diag_log "[Interrogation Task] Server initialization script (initGatherCivsTask.sqf) complete.";