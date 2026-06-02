/*

    arma3mercenaries\tasks\HVT_1\HVT_task_1.sqf
    Author: BrianV1981
    Description:
    This script creates an HVT (high-value target) task for the player to eliminate.
    A helicopter inserts the HVT at a remote location, and a military composition is spawned nearby.
    If ALIVE composition fails after multiple attempts and a guaranteed attempt, a fallback group is spawned.
    Upon elimination, players from the same faction are rewarded with money and score.
	
	notes:
	
	
	You need to explicitly launch your HVT_task_1.sqf script in its own scheduled environment.
	The standard way to do this is using spawn. Find where you are calling HVT_task_1.sqf
	
	Change this:

// Example of how you might be calling it now (WRONG for suspension)
[] execVM "arma3mercenaries\tasks\HVT_1\HVT_task_1.sqf";
Use code with caution.
Sqf
or this:

call compileScript ["arma3mercenaries\tasks\HVT_1\HVT_task_1.sqf"];
Use code with caution.
Sqf
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
_taskEnemyFaction = "OPF_F"; // This is the faction CLASSNAME used for ALIVE attempts and fallback group

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

// --- START OF COMPOSITION LOGIC WITH RETRY, VERIFICATION & GUARANTEED ATTEMPT ---

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
private _factions = [_taskEnemyFaction]; // Use the defined enemy faction CLASSNAME here for ALIVE
private _sizes = ["Large", "Medium", "Small", "ANY"];
private _infantryGroups = [1, 2, 3, 4];

// --- Call ALIVE composition function with Verification, Retry (up to 10 attempts), Guaranteed Attempt, and Fallback ---

private ["_success", "_attempts", "_maxAttempts", "_spawnedUnits", "_verificationRadius", "_aliveAttemptSucceeded"];
_success = false; // Flag for VERIFIED success (units detected)
_attempts = 0;
_maxAttempts = 10;
_verificationRadius = 150;

// --- Random Attempts Loop ---
while {!_success && _attempts < _maxAttempts} do {
    _attempts = _attempts + 1;
    _aliveAttemptSucceeded = false; // Reset flag for this attempt
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
    diag_log format ["DEBUG HVT_task_1: Attempt %1 ALIVE call completed. Returned: %2", _attempts, _compositionPositionResult];

    // --- Check ALIVE's return value FIRST ---
    if (!isNil "_compositionPositionResult" && {_compositionPositionResult}) then {
        diag_log format ["DEBUG HVT_task_1: ALIVE returned TRUE on Attempt %1. Proceeding to verification.", _attempts];
        _aliveAttemptSucceeded = true; // Mark that ALIVE *claimed* success for this attempt
    } else {
        diag_log format ["DEBUG HVT_task_1: ALIVE returned NIL/FALSE on Attempt %1. Skipping verification and retrying.", _attempts];
        continue; // Skip sleep & verification, go to next iteration immediately
    };

    // --- Verification Stage (Only if ALIVE returned true) ---
    diag_log format ["DEBUG HVT_task_1: Pausing for %1 seconds before verification...", 5];
    sleep 5; // Increased pause

    private _initialHVTGroupUnits = units _HVTGroup;
    _spawnedUnits = _taskLocation nearEntities [["Man", "LandVehicle", "Air"], _verificationRadius];
    _spawnedUnits = _spawnedUnits - _initialHVTGroupUnits;

    if (count _spawnedUnits > 0) then {
        _success = true; // Verification confirmed units! Set final success flag.
        diag_log format ["DEBUG HVT_task_1: VERIFIED (Attempt %1) - Found %2 units. Setting final success flag TRUE.", _attempts, count _spawnedUnits];
    } else {
        // ALIVE returned true, but verification failed. Log it.
        diag_log format ["DEBUG HVT_task_1: WARNING - VERIFICATION FAILED (Attempt %1) despite ALIVE returning TRUE.", _attempts];
        // Do NOT set _success = true here, allow guaranteed attempt if this happens on last random try.
    };

    // Exit loop if verification succeeded OR if ALIVE returned true (prevent overlaps from further random tries)
    if (_success || _aliveAttemptSucceeded) exitWith {
         diag_log format ["DEBUG HVT_task_1: Exiting RANDOM loop after Attempt %1. Verified Success: %2, ALIVE Returned True: %3", _attempts, _success, _aliveAttemptSucceeded];
    };

}; // End of while loop

diag_log format ["DEBUG HVT_task_1: Finished random attempts. Final Verified Success: %1", _success];

// --- START: Guaranteed ALIVE Attempt (Only run if VERIFICATION never succeeded) ---
if (!_success) then {
    diag_log format ["DEBUG HVT_task_1: Random attempts finished without VERIFIED success. Trying guaranteed parameters."];
    _aliveAttemptSucceeded = false; // Reset flag

    // --- Define your GUARANTEED parameters here --- (<<<<< CUSTOMIZE THESE!)
    private _guaranteedType = "Military";
    private _guaranteedCategory = "camps";       // Example
    private _guaranteedFaction = _taskEnemyFaction;
    private _guaranteedSize = "Small";        // Example
    private _guaranteedInfGroups = 2;         // Example
    // --- End Guaranteed Parameters ---

    diag_log format [
        "DEBUG HVT_task_1: Guaranteed Params: Location=%1 | Type=%2 | Category=%3 | Faction=%4 | Size=%5 | InfGroups=%6",
        _taskLocation, _guaranteedType, _guaranteedCategory, _guaranteedFaction, _guaranteedSize, _guaranteedInfGroups
    ];

    // Call ALIVE with guaranteed params
    private _guaranteedResult = [_taskLocation, _guaranteedType, _guaranteedCategory, _guaranteedFaction, _guaranteedSize, _guaranteedInfGroups] call ALIVE_fnc_spawnRandomPopulatedComposition;
    diag_log format ["DEBUG HVT_task_1: Guaranteed ALIVE call completed. Returned: %1", _guaranteedResult];

    // Check ALIVE return value for guaranteed attempt
    if (!isNil "_guaranteedResult" && {_guaranteedResult}) then {
         diag_log format ["DEBUG HVT_task_1: ALIVE returned TRUE on Guaranteed Attempt. Proceeding to verification."];
         _aliveAttemptSucceeded = true; // Mark potential success
    } else {
         diag_log format ["DEBUG HVT_task_1: ALIVE returned NIL/FALSE on Guaranteed Attempt."];
    };

    // --- Verification for GUARANTEED attempt (only if ALIVE returned true) ---
    if (_aliveAttemptSucceeded) then {
        diag_log format ["DEBUG HVT_task_1: Pausing for %1 seconds before verification (Guaranteed)...", 5];
        sleep 5; // Pause

        private _initialHVTGroupUnitsGuaranteed = units _HVTGroup;
        _spawnedUnits = _taskLocation nearEntities [["Man", "LandVehicle", "Air"], _verificationRadius];
        _spawnedUnits = _spawnedUnits - _initialHVTGroupUnitsGuaranteed;

        if (count _spawnedUnits > 0) then {
            _success = true; // Verification confirmed! Final success.
            diag_log format ["DEBUG HVT_task_1: VERIFIED (Guaranteed Attempt) - Found %1 units. Setting final success flag TRUE.", count _spawnedUnits];
        } else {
            diag_log format ["DEBUG HVT_task_1: WARNING - VERIFICATION FAILED (Guaranteed Attempt) despite ALIVE returning TRUE."];
            // _success remains false here, allowing fallback
        };
    };
};
// --- END: Guaranteed ALIVE Attempt ---

diag_log format ["DEBUG HVT_task_1: Finished guaranteed attempt. Final Verified Success: %1", _success];

// --- FINAL Fallback Logic: Only executes if VERIFICATION ultimately failed ---
if (!_success) then {
    diag_log format ["DEBUG HVT_task_1: ALIVE attempts finished without VERIFIED success. Spawning fallback vanilla group."];

    private _fallbackGroup = createGroup EAST; // Use Side keyword EAST
    private _fallbackUnitTypes = ["O_Soldier_F", "O_Soldier_lite_F", "O_Soldier_GL_F", "O_Soldier_AR_F"];
    private _numFallbackUnits = 3 + random 2; // 3-4 units

    diag_log format ["DEBUG HVT_task_1: Fallback - Creating group %1 with %2 units.", groupID _fallbackGroup, _numFallbackUnits]; // Log groupID for clarity

    for "_i" from 1 to _numFallbackUnits do {
        private _unitType = selectRandom _fallbackUnitTypes;
        private _spawnPos = _taskLocation getPos [random 20, random 360]; // Spawn dispersed
        private _unit = _fallbackGroup createUnit [_unitType, _spawnPos, [], 0, "NONE"];
        sleep 0.1; // Small delay
    };

    private _wp = _fallbackGroup addWaypoint [_taskLocation, 0];
    _wp setWaypointType "DEFEND";
    _wp setWaypointCompletionRadius 75; // Defend area radius
    _wp setWaypointCombatMode "RED";
    _wp setWaypointBehaviour "AWARE";

    // Optional: Add _fallbackGroup to cleanup array if needed for later deletion
};

// --- END OF COMPOSITION LOGIC ---


// Create the helicopter for HVT insertion, start it in the air at 300m
private _heli = createVehicle ["O_Heli_Light_02_F", _remotePosition, [], 0, "FLY"];

_heliGroup = createGroup EAST; // Use Side keyword EAST
private _heliPilot = _heliGroup createUnit ["O_Helipilot_F", getPosATL _heli, [], 0, "NONE"]; // Spawn pilot near heli
_heliPilot moveInDriver _heli;
_HVT moveInCargo _heli; // Move HVT into Cargo now

// Set the first waypoint for the helicopter to land at the task location
private _wp1 = _heliGroup addWaypoint [_taskLocation, 0];
_wp1 setWaypointType "TR UNLOAD";
_wp1 setWaypointSpeed "FULL";

// Define a second position 1km-2km away from the task location for the helicopter to fly to after unloading
_secondLocation = [_taskLocation, 1000, 2000, 20, 0, 1, 0, [], []] call BIS_fnc_findSafePos;

// Set the second waypoint for the helicopter to move to the second position
private _wp2 = _heliGroup addWaypoint [_secondLocation, 0];
_wp2 setWaypointType "MOVE";
_wp2 setWaypointSpeed "FULL";

// Use setWaypointStatements to trigger a hint when the second waypoint is completed
_wp2 setWaypointStatements ["true", "hint 'HVT dropped off. Helicopter RTB.';"];

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

// Add Killed event handler to the HVT
_HVT addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator", "_useEffects"];

    diag_log "HVT killed event handler triggered.";

    private _taskID = _unit getVariable ["taskID", ""];
    private _hvtActualGroup = group _unit;

    if (_taskID == "") exitWith { diag_log "Task ID is invalid, cannot proceed."; };

    diag_log format ["Task ID: %1 marked as SUCCEEDED", _taskID];

    [_taskID, "SUCCEEDED"] call BIS_fnc_taskSetState;

    // --- TEMPORARILY REMOVED FOR TESTING (Using // comments) ---
    // if (!isNull _hvtActualGroup) then {
    //     diag_log format ["HVT Killed EH: Deleting HVT's current group: %1", groupID _hvtActualGroup]; // Log groupID
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


    // Reward players
    private _taskCompletingSide = side _killer;
    {
        if (side _x == _taskCompletingSide) then {
            _x addScore 1000;
            [_x, 500000] call grad_moneymenu_fnc_addFunds;
        };
    } forEach allPlayers;
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

// --- End of HVT_task_1.sqf ---