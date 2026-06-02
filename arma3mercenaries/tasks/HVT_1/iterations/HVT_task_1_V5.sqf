/*

    arma3mercenaries\tasks\HVT_1\HVT_task_1.sqf
    Author: BrianV1981
    Description:
    This script creates an HVT (high-value target) task for the player to eliminate.
    A helicopter inserts the HVT at a remote location, and a military composition is spawned nearby.
    If ALIVE composition fails after multiple random attempts, a specific ALIVE composition is attempted as fallback.
    The helicopter (randomized type) and crew remain at the LZ as guards after drop-off.
    Upon elimination, players from the same faction are rewarded with money and score, and notified via dynamic text.

	notes:


	You need to explicitly launch your HVT_task_1.sqf script in its own scheduled environment.
	The standard way to do this is using spawn. Find where you are calling HVT_task_1.sqf

	Change this:

// Example of how you might be calling it now (WRONG for suspension)
[] execVM "arma3mercenaries\tasks\HVT_1\HVT_task_1.sqf";

or this:

call compileScript ["arma3mercenaries\tasks\HVT_1\HVT_task_1.sqf"];

To this:

// Correct way to execute this script using spawn
nul = [] spawn {
    // Optional: Add parameters if your script needs them using _this
    // e.g., _this execVM "arma3mercenaries\tasks\HVT_1\HVT_task_1.sqf";
    [] execVM "arma3mercenaries\tasks\HVT_1\HVT_task_1.sqf";
};

*/

// Ensure BIS functions are initialized
waitUntil {!(isNil "BIS_fnc_init")};

// Task Initialization
private ["_taskID", "_taskSide", "_taskFaction", "_taskLocation", "_taskEnemyFaction", "_HVTGroup", "_heliGroup", "_remotePosition", "_HVT"];

// Use diag_tickTime to create a unique Task ID
_taskID = format ["task_assassination_%1", diag_tickTime];
_taskSide = west;
_taskFaction = "BLU_F"; // Player faction
_taskEnemyFaction = "OPF_F"; // This is the faction CLASSNAME used for ALIVE attempts

// Find safe location for the task center
_taskLocation = [getMarkerPos "red_taor_1", 1, 5000, 20, 0, 0.1, 0] call BIS_fnc_findSafePos;
diag_log format ["DEBUG HVT_task_1: findSafePos result for _taskLocation: %1", _taskLocation];

// Define the remote insertion point (1km from task location)
_remotePosition = [_taskLocation, 1000, 2000, 20, 0, 1, 0, [], []] call BIS_fnc_findSafePos;
diag_log format ["DEBUG HVT_task_1: findSafePos result for _remotePosition: %1", _remotePosition];

// Create the HVT group at the remote position (will be moved into heli later)
_HVTGroup = createGroup EAST; // Use Side keyword EAST
_HVT = _HVTGroup createUnit ["O_officer_F", _remotePosition, [], 0, "FORM"];

// Add cash to the officer
[_HVT, 100000] call grad_moneymenu_fnc_addFunds;

// Set the first waypoint for the HVT Group (Tells HVT where to go AFTER disembarking)
private _HVTwp1 = _HVTGroup addWaypoint [_taskLocation, 0];
_HVTwp1 setWaypointType "MOVE";
_HVTwp1 setWaypointSpeed "NORMAL";

// --- START OF COMPOSITION LOGIC (Trusting ALIVE Return) ---

// Parameter Arrays for ALIVE spawning
private _compositionTypes = ["Civilian", "Military", "Guerrilla"];
private _militaryCategories = [
    "airports", "camps", "checkpointsbarricades", "constructionsupplies",
    "communications", "crashsites", "fieldhq", "fort", "fuel", "heliports",
    "hq", "marine", "medical", "outposts", "power", "supports", "supplies"
];
private _civilianCategories = [
    "airports", "checkpointsbarricades", "construction", "constructionSupplies",
    "communications", "fuel", "general", "heliports", "industrial", "marine",
    "mining_oil", "power", "rail", "settlements"
];
private _guerrillaCategories = [
    "camps", "checkpointsbarricades", "constructionsupplies", "commnunications", // Potential typo "commnunications" kept as per doc example
    "fieldhq", "fort", "fuel", "hq", "marine", "medical", "outposts", "power", "supports"
];
private _factions = [_taskEnemyFaction];
private _sizes = ["Large", "Medium", "Small", "ANY"];
private _infantryGroups = [1, 2, 3, 4];

// --- Call ALIVE composition function with Retry (up to 10 attempts) ---

private ["_success", "_attempts", "_maxAttempts"];
_success = false; // Flag based purely on ALIVE returning true
_attempts = 0;
_maxAttempts = 10;

// --- Random Attempts Loop ---
while {!_success && _attempts < _maxAttempts} do {
    _attempts = _attempts + 1;
    diag_log format ["DEBUG HVT_task_1: Attempt %1/%2 to spawn random ALIVE composition.", _attempts, _maxAttempts];

    // --- Select Random Parameters ---
    private _selectedType = selectRandom _compositionTypes;
    private _categoryArrayToUse = [];
    switch (_selectedType) do {
        case "Military": { _categoryArrayToUse = _militaryCategories; };
        case "Civilian": { _categoryArrayToUse = _civilianCategories; };
        case "Guerrilla": { _categoryArrayToUse = _guerrillaCategories; };
    };
    if (count _categoryArrayToUse == 0) then {
         diag_log format ["DEBUG HVT_task_1: WARNING - No category array found for type '%1'. Skipping attempt %2.", _selectedType, _attempts];
         continue; // Skip to next attempt
    };
    private _selectedCategory = selectRandom _categoryArrayToUse;
    private _selectedFaction = selectRandom _factions;
    private _selectedSize = selectRandom _sizes;
    private _selectedInfantryGroups = selectRandom _infantryGroups;
    // --- End Parameter Selection ---

    diag_log format [
        "DEBUG HVT_task_1: Attempt %1 Params: Location=%2 | Type=%3 | Category=%4 | Faction=%5 | Size=%6 | InfGroups=%7",
        _attempts, _taskLocation, _selectedType, _selectedCategory, _selectedFaction, _selectedSize, _selectedInfantryGroups
    ];

    // Call ALIVE function
    private _compositionPositionResult = [_taskLocation, _selectedType, _selectedCategory, _selectedFaction, _selectedSize, _selectedInfantryGroups] call ALIVE_fnc_spawnRandomPopulatedComposition;

    // --- Safely log the result ---
    private _resultValueStr = str _compositionPositionResult; // Convert to string safely
    if (isNil "_compositionPositionResult") then { _resultValueStr = "<null>"; }; // Explicitly show <null>
    diag_log format ["DEBUG HVT_task_1: Attempt %1 ALIVE call completed. Returned: %2", _attempts, _resultValueStr]; // SAFE LOG
    // --- End safe log ---

    // --- TRUST ALIVE's return value ---
    if (!isNil "_compositionPositionResult" && {_compositionPositionResult}) then {
        diag_log format ["DEBUG HVT_task_1: ALIVE returned TRUE on Attempt %1. Setting success = true and exiting loop.", _attempts];
        _success = true; // Set success immediately based on ALIVE return
    } else {
        diag_log format ["DEBUG HVT_task_1: ALIVE returned NIL/FALSE on Attempt %1. Retrying.", _attempts];
        // Loop continues
    };

    // Exit loop immediately if success was set
    if (_success) exitWith {
         diag_log format ["DEBUG HVT_task_1: Exiting RANDOM loop after Attempt %1 due to ALIVE success.", _attempts];
    };

}; // End of while loop

diag_log format ["DEBUG HVT_task_1: Finished random attempts. Success based on ALIVE return: %1", _success];


// --- *** FALLBACK LOGIC: Attempt Specific ALIVE Composition *** ---
// --- Runs ONLY if ALL random attempts failed/returned nil ---
if (!_success) then {
    diag_log format ["DEBUG HVT_task_1: ALL random ALIVE attempts failed/returned nil. Attempting specific fallback ALIVE composition."];

    // --- Define the Specific Fallback Parameters (from example) ---
    private _fallbackType = "Military";
    private _fallbackCategory = "Fort";
    private _fallbackFaction = _taskEnemyFaction; // Use existing variable
    private _fallbackSize = "Small";
    private _fallbackInfGroups = 2;
    // --- End Specific Parameters ---

    diag_log format [
        "DEBUG HVT_task_1: Fallback ALIVE Params: Location=%1 | Type=%2 | Category=%3 | Faction=%4 | Size=%5 | InfGroups=%6",
        _taskLocation, _fallbackType, _fallbackCategory, _fallbackFaction, _fallbackSize, _fallbackInfGroups
    ];

    // Call ALIVE with specific fallback parameters
    private _fallbackResult = [_taskLocation, _fallbackType, _fallbackCategory, _fallbackFaction, _fallbackSize, _fallbackInfGroups] call ALIVE_fnc_spawnRandomPopulatedComposition;

    // --- Safely log the fallback result ---
    private _fallbackResultValueStr = str _fallbackResult; // Convert to string safely
    if (isNil "_fallbackResult") then { _fallbackResultValueStr = "<null>"; }; // Explicitly show <null>
    diag_log format ["DEBUG HVT_task_1: Fallback ALIVE call completed. Returned: %1", _fallbackResultValueStr]; // SAFE LOG
    // --- End safe log ---

    if (!isNil "_fallbackResult" && {_fallbackResult}) then {
         diag_log format ["DEBUG HVT_task_1: Fallback ALIVE attempt returned TRUE."];
    } else {
         diag_log format ["DEBUG HVT_task_1: Fallback ALIVE attempt returned NIL/FALSE."];
    };
};
// --- *** END OF FALLBACK LOGIC *** ---


// --- END OF COMPOSITION LOGIC ---


// --- *** Define & Select Helicopter Type *** ---
private _heliTypes = ["O_Heli_Light_02_F", "O_Heli_Attack_02_F"]; // Kajman, Orca, Taru Transport , "O_Heli_Transport_04_F"
private _selectedHeliType = selectRandom _heliTypes;
diag_log format ["DEBUG HVT_task_1: Selected helicopter type: %1", _selectedHeliType];
// --- *** End Helicopter Selection *** ---

// Create the helicopter for HVT insertion, start it in the air at 300m
private _heli = createVehicle [_selectedHeliType, _remotePosition, [], 0, "FLY"]; // Use selected type

_heliGroup = createGroup EAST; // Use Side keyword EAST
private _heliPilot = _heliGroup createUnit ["O_Helipilot_F", getPosATL _heli, [], 0, "NONE"]; // Spawn pilot near heli
_heliPilot moveInDriver _heli;

// --- *** Add Gunner (Conditional) *** ---
if (_selectedHeliType in ["O_Heli_Light_02_F", "O_Heli_Attack_02_F"]) then { // Kajman or Orca
    diag_log format ["DEBUG HVT_task_1: Adding gunner for %1", _selectedHeliType];
    private _heliGunner = _heliGroup createUnit ["O_crew_F", getPosATL _heli, [], 0, "NONE"]; // Use Crewman class
    _heliGunner moveInTurret [_heli, [0]]; // Assign to main gunner turret (index 0)
} else {
    diag_log format ["DEBUG HVT_task_1: Skipping gunner for %1 (no suitable default turret)", _selectedHeliType];
};
// --- *** End Add Gunner *** ---

_HVT moveInCargo _heli; // Move HVT into Cargo now

// Set the first waypoint for the helicopter to land at the task location
private _wp1 = _heliGroup addWaypoint [_taskLocation, 0];
_wp1 setWaypointType "TR UNLOAD";
_wp1 setWaypointSpeed "FULL";

// --- Set second waypoint to GUARD the landing zone ---
private _wp2 = _heliGroup addWaypoint [_taskLocation, 0]; // Point back to LZ
_wp2 setWaypointType "GUARD";                             // Change type to GUARD
_wp2 setWaypointCompletionRadius 50;                     // Radius for guarding area
_wp2 setWaypointCombatMode "RED";                         // Engage targets freely
_wp2 setWaypointBehaviour "COMBAT";                       // Actively seek/engage
_wp2 setWaypointSpeed "LIMITED";                         // Slow down near LZ
// --- End Guard Waypoint Setup ---

// --- REMOVED Waypoint Statements for cleanup ---

// Create Task
[
    [_taskSide],  // Task owner(s)
    _taskID,  // Task ID
    ["Eliminate the HVT", "HVT Elimination", "HVT_Marker"],  // Task description
    _taskLocation,  // Task destination
    "ASSIGNED",  // Task state
    1,  // Task priority
    true,  // Show notification
    "kill",  // Task type
    true  // Visible in 3D
] call BIS_fnc_taskCreate;

// --- Define HVT Success Messages ---
private _hvtSuccessMessagesLocal = [ // Renamed to avoid potential conflicts if script runs multiple times
    "Target neutralized. Good kill. Collect your pay.",
    "Scratch one HVT. Management sends its regards... and your cash.",
    "Hostile VIP down. Guess they weren't so important after all. Payment processed.",
    "Confirmed kill on the high-value target. Try not to spend the bonus all in one place.",
    "HVT eliminated. That's one less headache for command. Transferring funds now.",
    "Package secured... permanently. Nice work. Credits incoming.",
    "Objective complete. The target won't be causing any more trouble. Check your account balance.",
    "They picked the wrong side. HVT down. You've been paid.",
    "Asset removal successful. Job well done. Your payment is authorized."
];
// --- Store messages in missionNamespace for EH access ---
missionNamespace setVariable ["HVT_SuccessMessagesArray", _hvtSuccessMessagesLocal, true];
// --- End HVT Success Messages ---


// Add Killed event handler to the HVT
_HVT addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator", "_useEffects"];

    diag_log "HVT killed event handler triggered.";

    private _taskID = _unit getVariable ["taskID", ""];
    private _hvtActualGroup = group _unit;
    // Retrieve messages correctly from missionNamespace
    private _successMessages = missionNamespace getVariable ["HVT_SuccessMessagesArray", ["Task Complete."]]; // Provide simpler fallback

    if (_taskID == "") exitWith { diag_log "Task ID is invalid, cannot proceed."; };

    diag_log format ["Task ID: %1 marked as SUCCEEDED", _taskID];

    [_taskID, "SUCCEEDED"] call BIS_fnc_taskSetState;

    // --- TEMPORARILY REMOVED FOR TESTING (Using // comments) ---
    // if (!isNull _hvtActualGroup) then {
    //     diag_log format ["HVT Killed EH: Deleting HVT's current group: %1", groupID _hvtActualGroup];
    //     deleteGroup _hvtActualGroup;
    // };
    // --- END TEMPORARY REMOVAL ---


    // --- Server-side cleanup in tracking array ---
    if (isServer) then {
        private _foundIndex = -1;
        {
            if ((_x select 0) == _taskID) exitWith { _foundIndex = _forEachIndex; };
        } forEach server_activeHvtTasks;

        if (_foundIndex != -1) then {
            server_activeHvtTasks deleteAt _foundIndex;
            diag_log format ["SERVER HVT Killed EH: Removed task %1 from tracking array. Current count: %2", _taskID, count server_activeHvtTasks];
        } else {
            diag_log format ["SERVER HVT Killed EH: Task %1 not found in tracking array.", _taskID];
        };
    };
     // --- End server tracking cleanup ---


    // --- Reward players AND Send Dynamic Text Message ---
    private _taskCompletingSide = side _killer;
    {
        if (side _x == _taskCompletingSide) then {
            private _playerToSend = _x; // Local variable for clarity
            // Reward Score & Money
            _playerToSend addScore 1000;
            [_playerToSend, 500000] call grad_moneymenu_fnc_addFunds;

            // --- Send Dynamic Text via remoteExec ---
            if (count _successMessages > 0) then { // Safety check
                private _message = selectRandom _successMessages; // Select a random message
                private _textParams = [
                    format ["<t color='#FFFFFF' size='1.0'>%1</t>", _message], // Format with white text, size 1.0
                    -1, -1, // Center position (-1, -1 uses BIS default center)
                    10,     // Duration (seconds)
                    1,      // Fade Time (seconds)
                    0,      // Offset (usually 0)
                    799     // Unique ID for HVT messages (change if needed)
                ];

                // Use remoteExec, targeting the specific player
                _textParams remoteExec ["BIS_fnc_dynamicText", _playerToSend];

                diag_log format ["HVT Killed EH: Sent dynamicText '%1' to player %2 via remoteExec", _message, name _playerToSend];
            };
            // --- End Dynamic Text Execution ---
        };
    } forEach allPlayers;
    // --- End Reward / Message Loop ---

}]; // End Killed EH

// Store references
_HVT setVariable ["taskID", _taskID];

// --- Add task to server tracking array ---
if (isServer) then {
    // Ensure the array exists
    if (isNil "server_activeHvtTasks") then { server_activeHvtTasks = []; };

    // Store Task ID, HVT Unit, and the Task Side
    server_activeHvtTasks pushBack [_taskID, _HVT, _taskSide];
    diag_log format ["SERVER: Added HVT task %1 (HVT: %2) to tracking. Total tracked: %3", _taskID, _HVT, count server_activeHvtTasks];
};


// --- REMOVED HELICOPTER CLEANUP BLOCK ---


// --- End of HVT_task_1.sqf ---