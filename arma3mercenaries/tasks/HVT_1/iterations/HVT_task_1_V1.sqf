/*

    arma3mercenaries\tasks\HVT_1\HVT_task_1.sqf
    Author: BrianV1981
    Description:
    This script creates an HVT (high-value target) task for the player to eliminate.
    A helicopter inserts the HVT at a remote location, and a military composition is spawned nearby.
    Upon elimination, players from the same faction are rewarded with money and score.

    *** CHANGE LOG ***
    - Added helicopter and group cleanup via setWaypointStatements on _wp2.
    - Corrected syntax error related to assignToGroup command.

*/

// Ensure BIS functions are initialized
waitUntil {!(isNil "BIS_fnc_init")};

// Task Initialization
private ["_taskID", "_taskSide", "_taskFaction", "_taskLocation", "_taskEnemyFaction", "_HVTGroup", "_heliGroup", "_remotePosition", "_HVT", "_compositionPosition", "_compositionData"]; // Added _compositionData

// Use diag_tickTime to create a unique Task ID
_taskID = format ["task_assassination_%1", diag_tickTime];
_taskSide = west;
_taskFaction = "BLU_F";
_taskEnemyFaction = "OPF_F";

// Check if marker exists before trying to use it
if (getMarkerPos "red_taor_1" isEqualTo [0,0,0]) exitWith {
    diag_log "ERROR HVT_task_1: Marker 'red_taor_1' not found or invalid. Aborting task creation.";
};
_taskLocation = [getMarkerPos "red_taor_1", 1, 5000, 20, 0, 0.1, 0] call BIS_fnc_findSafePos;

// Define the remote insertion point (1km-2km from task location)
_remotePosition = [_taskLocation, 1000, 2000, 20, 0, 1, 0, [], []] call BIS_fnc_findSafePos;

// Create the HVT group at the remote position (initially)
_HVTGroup = createGroup EAST; // This group will be empty after HVT moves to heli group
_HVT = _HVTGroup createUnit ["O_officer_F", _remotePosition, [], 0, "FORM"];

// Check if HVT was created successfully
if (isNull _HVT) exitWith {
    diag_log "ERROR HVT_task_1: Failed to create HVT unit. Aborting task.";
};

// Add cash to the officer (Check if function exists)
if (isClass (configFile >> "CfgFunctions" >> "grad_moneymenu_fnc_addFunds")) then {
    [_HVT, 100000] call grad_moneymenu_fnc_addFunds;
} else {
    diag_log "WARNING HVT_task_1: grad_moneymenu_fnc_addFunds function not found. Skipping HVT cash.";
};


// Random parameters for composition spawning
private _compositionTypes = ["Civilian", "Military"]; // , "Guerrilla"
private _militaryCategories = ["airports", "camps", "checkpointsbarricades", "fieldhq", "fort", "fuel", "outposts"];
private _civilianCategories = ["airports", "construction", "communications", "fuel", "settlements"];
private _guerrillaCategories = ["camps", "fieldhq", "fort", "outposts", "medical"];
private _factions = ["OPF_F"]; // , "BLU_F", "IND_F"
private _sizes = ["Large", "Medium", "Small"];
private _infantryGroups = [1, 2, 3, 4];

// Randomly select the composition type
private _selectedType = selectRandom _compositionTypes;

// Define which category array to use based on _selectedType
private _categoryArrayToUse = []; // Initialize empty

// Log the input value (_selectedType) just BEFORE the switch
diag_log format ["DEBUG HVT_task_1: _selectedType before switch is: %1 (Type: %2)", _selectedType, typeName _selectedType];

// Switch only to determine WHICH array to use
switch (_selectedType) do {
    case "Military": {
        _categoryArrayToUse = _militaryCategories;
    };
    case "Civilian": {
        _categoryArrayToUse = _civilianCategories;
    };
    //case "Guerrilla": {
    //    _categoryArrayToUse = _guerrillaCategories;
    //};
    default { // Add a default case for safety
        diag_log format ["WARNING HVT_task_1: Unknown _selectedType '%1'. Defaulting to Military categories.", _selectedType];
        _categoryArrayToUse = _militaryCategories;
    };
};

// Check if category array is populated (should be unless logic error above)
if (count _categoryArrayToUse == 0) exitWith {
    diag_log format ["ERROR HVT_task_1: _categoryArrayToUse is empty for _selectedType '%1'. Aborting task.", _selectedType];
};

// Log which array was chosen AFTER the switch
diag_log format ["DEBUG HVT_task_1: Category array chosen after switch: %1 (Count: %2)", _categoryArrayToUse, count _categoryArrayToUse];

// Now, select the category from the chosen array
private _selectedCategory = selectRandom _categoryArrayToUse;

// Log the final selected category
diag_log format ["DEBUG HVT_task_1: Final _selectedCategory after selection: %1 (Type: %2)", _selectedCategory, typeName _selectedCategory];

// Randomly select faction, size, and number of infantry groups
private _selectedFaction = selectRandom _factions;
private _selectedSize = selectRandom _sizes;
private _selectedInfantryGroups = selectRandom _infantryGroups;

// Spawn a random populated composition based on the selected parameters (Check if function exists)
if (!isNil "ALIVE_fnc_spawnRandomPopulatedComposition") then {
     _compositionData = [_taskLocation, _selectedType, _selectedCategory, _selectedFaction, _selectedSize, _selectedInfantryGroups] call ALIVE_fnc_spawnRandomPopulatedComposition;
     diag_log format ["Spawning composition with Type: %1, Category: %2, Faction: %3, Size: %4, Infantry Groups: %5. Return data: %6", _selectedType, _selectedCategory, _selectedFaction, _selectedSize, _selectedInfantryGroups, _compositionData];
} else {
    diag_log "ERROR HVT_task_1: ALIVE_fnc_spawnRandomPopulatedComposition function not found. Cannot spawn composition. Aborting task.";
    // Cleanup HVT and initial group if we abort here
    deleteVehicle _HVT;
    deleteGroup _HVTGroup;
    exitWith {};
};


// Create the helicopter for HVT insertion, start it in the air at 300m
private _heli = createVehicle ["O_Heli_Light_02_F", _remotePosition, [], 0, "FLY"];
_heli setPos [_remotePosition select 0, _remotePosition select 1, 300]; // Ensure it starts flying high

// Check if heli was created successfully
if (isNull _heli) exitWith {
    diag_log "ERROR HVT_task_1: Failed to create helicopter. Aborting task.";
    // Cleanup HVT and initial group if we abort here
    deleteVehicle _HVT;
    deleteGroup _HVTGroup;
    // Potentially cleanup ALiVE composition if needed/possible based on _compositionData
    exitWith {};
};

_heliGroup = createGroup EAST;
// Spawn pilot near the helicopter
private _pilotPos = getPosATL _heli; // Use heli pos for pilot spawn
private _heliPilot = _heliGroup createUnit ["O_Helipilot_F", _pilotPos, [], 0, "NONE"]; // Spawn pilot near heli, initial state NONE

// Check if pilot was created successfully
if (isNull _heliPilot) exitWith {
    diag_log "ERROR HVT_task_1: Failed to create helicopter pilot. Aborting task.";
    deleteVehicle _heli; // Cleanup heli
    deleteVehicle _HVT; // Cleanup HVT
    deleteGroup _HVTGroup;
    deleteGroup _heliGroup;
    // Potentially cleanup ALiVE composition
    exitWith {};
};

_heliPilot moveInDriver _heli;
_HVT moveInCargo _heli;

// Assign pilot and HVT to the helicopter's group after creation
// Ensure semicolon is present and correct on the first line.
_heliPilot assignToGroup _heliGroup;
// Ensure this line is also correct.
_HVT assignToGroup _heliGroup;


// Set the first waypoint for the helicopter to land at the task location
private _wp1 = _heliGroup addWaypoint [_taskLocation, 0];
_wp1 setWaypointType "TR UNLOAD";
_wp1 setWaypointBehaviour "CARELESS"; // Less likely to engage targets en route
_wp1 setWaypointCombatMode "BLUE"; // Never fire
_wp1 setWaypointSpeed "NORMAL"; // Land more carefully

// Define a second position 1km-2km away from the task location for the helicopter to fly to after unloading
_secondLocation = [_taskLocation, 1000, 2000, 20, 0, 1, 0, [], []] call BIS_fnc_findSafePos;

// Set the second waypoint for the helicopter to move to the second position
private _wp2 = _heliGroup addWaypoint [_secondLocation, 0];
_wp2 setWaypointType "MOVE";
_wp2 setWaypointSpeed "FULL";
_wp2 setWaypointBehaviour "AWARE"; // Can react if needed after drop-off
_wp2 setWaypointCombatMode "GREEN"; // Engage at will after drop-off

// --- START HELICOPTER CLEANUP ---
// Use setWaypointStatements to trigger a hint AND spawn a delayed cleanup script when the second waypoint is completed
_wp2 setWaypointStatements ["true", "
    hint format ['HVT Task %1: Heli RTB', (_this#0 getVariable ['taskID',''])]; \
    _this call BIS_fnc_execVM; \
    ", {
        params ["_group", "_waypointIndex"]; // Arguments passed by setWaypointStatements execution context

        // Attempt to get heli and task ID safely
        private _leader = leader _group;
        private _heli = objNull;
        if (!isNull _leader) then { _heli = vehicle _leader; };
        private _taskIDForLog = "UNKNOWN";
        if (!isNull _heli) then { _taskIDForLog = _heli getVariable ["taskID", "UNKNOWN"]; };

        // Check if heli is valid before proceeding
        if (isNull _heli) exitWith {
            diag_log format ['HVT Task Cleanup Warning: Could not find valid helicopter for group %1 at waypoint %2.', _group, _waypointIndex];
        };

        diag_log format ['HVT Task %1: Helicopter cleanup sequence started for group %2, vehicle %3.', _taskIDForLog, _group, _heli];

        // Pass group and vehicle to the spawned cleanup code
        [_group, _heli, _taskIDForLog] spawn {
            params ['_spawnedGroup', '_spawnedHeli', '_spawnedTaskID'];

            sleep 60; // Wait 60 seconds after reaching the WP

            diag_log format ['HVT Task %1: Executing cleanup for group %2, vehicle %3.', _spawnedTaskID, _spawnedGroup, _spawnedHeli];

            // Check if group exists before trying to delete units/group
            if (!isNull _spawnedGroup) then {
                 diag_log format ['HVT Task %1: Deleting units of group %2.', _spawnedTaskID, _spawnedGroup];
                 { if (!isNull _x) then { deleteVehicle _x }; } forEach units _spawnedGroup; // Delete crew safely
                 diag_log format ['HVT Task %1: Deleting group %2.', _spawnedTaskID, _spawnedGroup];
                deleteGroup _spawnedGroup;
            };

            // Check if vehicle exists (might be deleted with group leader, but good practice)
            if (!isNull _spawnedHeli) then {
                diag_log format ['HVT Task %1: Deleting vehicle %2.', _spawnedTaskID, _spawnedHeli];
                deleteVehicle _spawnedHeli;
            };
        };
    }
];
// --- END HELICOPTER CLEANUP ---


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

    // Log that the Killed event handler was triggered
    diag_log "DEBUG HVT Killed EH: Triggered.";

    // Retrieve the task ID and group references stored in the HVT
    private _taskID = _unit getVariable ["taskID", ""];
    private _originalHVTGroup = _unit getVariable ["originalHVTGroup", groupNull];

    // Check if the taskID is valid
    if (_taskID == "") exitWith { diag_log "ERROR HVT Killed EH: Task ID on unit is invalid, cannot proceed."; };

    // Log task completion for debugging
    diag_log format ["DEBUG HVT Killed EH: Task ID: %1 marked as SUCCEEDED", _taskID];

    // Task Completion
    [_taskID, "SUCCEEDED"] call BIS_fnc_taskSetState;

    // --- START: Server Tracking Removal ---
    // Remove from server tracking array immediately (Only server needs to do this)
    if (isServer) then {
        // Ensure array exists just in case
        if (isNil "server_activeHvtTasks") then { server_activeHvtTasks = []; };

        private _foundIndex = server_activeHvtTasks findIf { (_x select 0) == _taskID }; // More efficient find

        if (_foundIndex != -1) then {
            server_activeHvtTasks deleteAt _foundIndex;
            diag_log format ["SERVER HVT Killed EH: Removed task %1 from tracking array. Current count: %2", _taskID, count server_activeHvtTasks];
        } else {
            diag_log format ["SERVER HVT Killed EH: Task %1 not found in tracking array (might have been removed already).", _taskID];
        };
    };
    // --- END: Server Tracking Removal ---

    // Cleanup HVT's original group (if it exists and hasn't been deleted/reassigned AND is empty)
    if (!isNull _originalHVTGroup) then {
        // Check group emptiness on server to avoid locality issues maybe? Or just run deleteGroup, it handles null groups.
        if (count units _originalHVTGroup == 0) then {
             diag_log format ["DEBUG HVT Killed EH: Deleting empty original HVT group %1", _originalHVTGroup];
             deleteGroup _originalHVTGroup;
        } else {
             // This case should technically not happen anymore if HVT was successfully moved to heli group
             diag_log format ["WARNING HVT Killed EH: Original HVT group %1 still has %2 members. Not deleting.", _originalHVTGroup, count units _originalHVTGroup];
        };
    };

    // Reward players on the killer's side
    if (!isNull _killer && {isPlayer _killer || isPlayer (effectiveCommander _killer)}) then {
        private _taskCompletingSide = side _killer;
        diag_log format ["DEBUG HVT Killed EH: Rewarding players on side %1.", _taskCompletingSide];
        {
            if (side _x == _taskCompletingSide) then {
                _x addScore 1000;
                // Check grad money function exists again before calling
                if (isClass (configFile >> "CfgFunctions" >> "grad_moneymenu_fnc_addFunds")) then {
                    [_x, 500000] call grad_moneymenu_fnc_addFunds;
                } else {
                     diag_log format ["WARNING HVT Killed EH: grad_moneymenu_fnc_addFunds not found. Cannot give money reward to %1.", name _x];
                };
                 diag_log format ["DEBUG HVT Killed EH: Rewarded player %1.", name _x];
            };
        } forEach allPlayers;
    } else {
        diag_log format ["DEBUG HVT Killed EH: Killer (%1) is not a player or player-controlled unit. No rewards issued.", _killer];
    };
}];

// Store references for use in event handlers / cleanup
_heli setVariable ["taskID", _taskID, true]; // Add taskID to heli for logging in cleanup
_HVT setVariable ["taskID", _taskID, true]; // Needed by Killed EH (make public for EH)
_HVT setVariable ["originalHVTGroup", _HVTGroup, false]; // Store ORIGINAL group reference (group is now empty, locality shouldn't matter)


// --- START: Server Tracking ---
// Add task to server tracking array for periodic updates
if (isServer) then {
    if (isNil "server_activeHvtTasks") then { server_activeHvtTasks = []; };
    server_activeHvtTasks pushBack [_taskID, _HVT, _taskSide];
    // publicVariable "server_activeHvtTasks"; // Usually not needed unless clients read it directly
    diag_log format ["SERVER HVT_task_1: Added HVT task %1 (HVT: %2) to tracking. Total tracked: %3", _taskID, _HVT, count server_activeHvtTasks];
};
// --- END: Server Tracking ---

diag_log format ["HVT Task %1 initialization complete.", _taskID];