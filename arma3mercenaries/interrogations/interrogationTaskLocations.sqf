// initServer.sqf - Runs only on the server machine at mission start.

// Ensure this script runs only on the server machine.
if (!isServer) exitWith {};

diag_log "TASK DEBUG: initServer.sqf started.";

// --- Task Definitions ---

// Wait until ALL target objects actually exist (important for dedicated servers)
// Assumes interrogation_bodybag_1, _2, and _3 are variable names set in the editor.
private _timeout = diag_tickTime + 60;
waitUntil {
    sleep 0.5; // Brief pause to allow objects to potentially initialize
    private _obj1 = missionNamespace getVariable ["interrogation_bodybag_1", objNull];
    private _obj2 = missionNamespace getVariable ["interrogation_bodybag_2", objNull];
    private _obj3 = missionNamespace getVariable ["interrogation_bodybag_3", objNull];
    // Check if all objects are non-null OR if timeout has been reached
    (!isNull _obj1 && !isNull _obj2 && !isNull _obj3) || (diag_tickTime > _timeout)
};

diag_log "TASK DEBUG: All target objects found, creating tasks.";

// --- Task 1: Interrogation Point Alpha ---
private _taskIDAlpha = "task_InterrogateAlpha";
private _titleAlpha = "Interrogation Point Alpha";
private _descAlpha = "Command wants intel, and they don't care how we get it. Bring any captured civilians to this primary 'processing' point. Use the action menu on the nearby bodybag container once they're secured. Standard extraction protocols yield cash rewards, but be thorough – high-value information could expose a key HVT and lead to a substantial bonus payout.";
private _targetObjAlpha = missionNamespace getVariable ["interrogation_bodybag_1", objNull]; // Get the object reference

// Create task for BLUFOR (west)
if (!isNull _targetObjAlpha) then {
    [west, _taskIDAlpha, [_descAlpha, _titleAlpha, ""], _targetObjAlpha, false, 0, true, "default"] call BIS_fnc_taskCreate;
    diag_log format ["TASK DEBUG: Created task '%1' for WEST at %2", _taskIDAlpha, _targetObjAlpha];
} else {
    diag_log format ["TASK ERROR: Could not create task '%1' for WEST - target object interrogation_bodybag_1 is missing!", _taskIDAlpha];
};

// Create the same task for Independent (resistance)
if (!isNull _targetObjAlpha) then {
    [resistance, _taskIDAlpha, [_descAlpha, _titleAlpha, ""], _targetObjAlpha, false, 0, true, "default"] call BIS_fnc_taskCreate;
    diag_log format ["TASK DEBUG: Created task '%1' for RESISTANCE at %2", _taskIDAlpha, _targetObjAlpha];
} else {
     diag_log format ["TASK ERROR: Could not create task '%1' for RESISTANCE - target object interrogation_bodybag_1 is missing!", _taskIDAlpha];
};


// --- Task 2: Interrogation Point Bravo ---
private _taskIDBravo = "task_InterrogateBravo";
private _titleBravo = "Interrogation Point Bravo";
private _descBravo = "This secondary site is authorized for extracting information from civilian assets. Secure the targets near the container and initiate interrogation via the bodybag container. Payment is issued upon successful processing. Stay alert – valuable intel leading to an HVT might surface, triggering follow-on operations and a significant reward.";
private _targetObjBravo = missionNamespace getVariable ["interrogation_bodybag_2", objNull]; // Get the object reference

// Create task for BLUFOR (west)
if (!isNull _targetObjBravo) then {
    [west, _taskIDBravo, [_descBravo, _titleBravo, ""], _targetObjBravo, false, 0, true, "default"] call BIS_fnc_taskCreate;
    diag_log format ["TASK DEBUG: Created task '%1' for WEST at %2", _taskIDBravo, _targetObjBravo];
} else {
    diag_log format ["TASK ERROR: Could not create task '%1' for WEST - target object interrogation_bodybag_2 is missing!", _taskIDBravo];
};

// Create the same task for Independent (resistance)
if (!isNull _targetObjBravo) then {
    [resistance, _taskIDBravo, [_descBravo, _titleBravo, ""], _targetObjBravo, false, 0, true, "default"] call BIS_fnc_taskCreate;
    diag_log format ["TASK DEBUG: Created task '%1' for RESISTANCE at %2", _taskIDBravo, _targetObjBravo];
} else {
    diag_log format ["TASK ERROR: Could not create task '%1' for RESISTANCE - target object interrogation_bodybag_2 is missing!", _taskIDBravo];
};


// --- Task 3: Interrogation Point Charlie --- // NEW TASK
private _taskIDCharlie = "task_InterrogateCharlie";
private _titleCharlie = "Interrogation Point Charlie";
private _descCharlie = "Charlie Point serves as an additional facility for intel extraction. Bring captives to the bodybag location and initiate the process using the object's action menu. Financial rewards are standard, with significant bonuses possible for HVT identification.";
private _targetObjCharlie = missionNamespace getVariable ["interrogation_bodybag_3", objNull]; // Get the object reference

// Create task for BLUFOR (west)
if (!isNull _targetObjCharlie) then {
    [west, _taskIDCharlie, [_descCharlie, _titleCharlie, ""], _targetObjCharlie, false, 0, true, "default"] call BIS_fnc_taskCreate;
    diag_log format ["TASK DEBUG: Created task '%1' for WEST at %2", _taskIDCharlie, _targetObjCharlie];
} else {
    diag_log format ["TASK ERROR: Could not create task '%1' for WEST - target object interrogation_bodybag_3 is missing!", _taskIDCharlie];
};

// Create the same task for Independent (resistance)
if (!isNull _targetObjCharlie) then {
    [resistance, _taskIDCharlie, [_descCharlie, _titleCharlie, ""], _targetObjCharlie, false, 0, true, "default"] call BIS_fnc_taskCreate;
    diag_log format ["TASK DEBUG: Created task '%1' for RESISTANCE at %2", _taskIDCharlie, _targetObjCharlie];
} else {
    diag_log format ["TASK ERROR: Could not create task '%1' for RESISTANCE - target object interrogation_bodybag_3 is missing!", _taskIDCharlie];
};


diag_log "TASK DEBUG: Server-side task creation complete.";