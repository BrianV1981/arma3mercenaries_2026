/*

    arma3mercenaries\tasks\HVT_1\HVT_task_1.sqf
    Author: BrianV1981
    Description:
    This script creates an HVT (high-value target) task for the player to eliminate.
    The HVT's role (in the task description) now influences the actual unit type spawned.
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

// --- Define HVT Immersion Elements ---
private _codenames = ["Viper", "Ghost", "Hammer", "Spectre", "Warden", "Azrael", "Cyclops", "Reaper", "Serpent", "Jackal"];
// Refined roles for better mapping potential
private _targetRoles = [
    "Field Commander", "Logistics Officer", "Propagandist", "Intel Analyst",
    "Artillery Spotter", "Special Forces Advisor", "Comms Specialist", "Ordnance Expert",
    "Political Commissar", "Technical Specialist", "Medical Specialist" // Added specific roles
];
// All possible unit types (will be filtered based on selected role)
private _allHvtUnitTypes = [
    "O_officer_F", "O_Soldier_SL_F", "O_Soldier_TL_F", "O_medic_F",
    "O_engineer_F", "O_Soldier_exp_F", "O_Soldier_LAT_F", "O_soldier_UAV_06_F" // Added UAV Op as potential tech/intel
];

private _hvtCodename = selectRandom _codenames;
private _hvtRole = selectRandom _targetRoles; // Select the role FIRST

// --- Determine appropriate Unit Types based on the selected Role ---
private _possibleUnitTypes = [];
switch (_hvtRole) do {
    case "Field Commander":          { _possibleUnitTypes = ["O_officer_F", "O_Soldier_SL_F"]; };
    case "Political Commissar":      { _possibleUnitTypes = ["O_officer_F"]; };
    case "Special Forces Advisor":   { _possibleUnitTypes = ["O_Soldier_SL_F", "O_Soldier_TL_F", "O_officer_F"]; }; // Could be leader types
    case "Logistics Officer":        { _possibleUnitTypes = ["O_officer_F", "O_engineer_F"]; }; // Officer or Engineer makes sense
    case "Intel Analyst":            { _possibleUnitTypes = ["O_officer_F", "O_soldier_UAV_06_F"]; }; // Officer or maybe UAV op
    case "Comms Specialist":         { _possibleUnitTypes = ["O_officer_F", "O_soldier_UAV_06_F", "O_Soldier_TL_F"]; }; // Officer, UAV op, maybe TL
    case "Technical Specialist":     { _possibleUnitTypes = ["O_engineer_F", "O_soldier_UAV_06_F"]; };
    case "Ordnance Expert":          { _possibleUnitTypes = ["O_Soldier_exp_F", "O_engineer_F"]; };
    case "Artillery Spotter":        { _possibleUnitTypes = ["O_Soldier_TL_F", "O_soldier_UAV_06_F"]; }; // TL or UAV op often spot
    case "Medical Specialist":       { _possibleUnitTypes = ["O_medic_F", "O_officer_F"]; }; // Medic or an Officer overseeing medical ops
    case "Propagandist":             { _possibleUnitTypes = ["O_officer_F"]; }; // Often an officer/political figure

    default {
        diag_log format ["DEBUG HVT_task_1: WARNING - Role '%1' not explicitly mapped. Defaulting HVT type to Officer.", _hvtRole];
        _possibleUnitTypes = ["O_officer_F"]; // Fallback if a role isn't listed
    };
};

// --- Select the final HVT unit type from the filtered list ---
if (count _possibleUnitTypes == 0) then { // Safety check in case a case block fails
     diag_log format ["DEBUG HVT_task_1: ERROR - No possible unit types determined for role '%1'. Defaulting to Officer.", _hvtRole];
     _possibleUnitTypes = ["O_officer_F"];
};
private _selectedHvtUnitType = selectRandom _possibleUnitTypes;

diag_log format ["DEBUG HVT_task_1: Selected Role: '%1' -> Possible Units: %2 -> Selected Unit Type: %3", _hvtRole, _possibleUnitTypes, _selectedHvtUnitType];
// --- End HVT Immersion Elements & Unit Selection ---


// Find safe location for the task center
_taskLocation = [getMarkerPos "red_taor_1", 1, 5000, 20, 0, 0.1, 0] call BIS_fnc_findSafePos;
diag_log format ["DEBUG HVT_task_1: findSafePos result for _taskLocation: %1", _taskLocation];

// Define the remote insertion point (1km from task location)
_remotePosition = [_taskLocation, 1000, 2000, 20, 0, 1, 0, [], []] call BIS_fnc_findSafePos;
diag_log format ["DEBUG HVT_task_1: findSafePos result for _remotePosition: %1", _remotePosition];

// Create the HVT group at the remote position (will be moved into heli later)
_HVTGroup = createGroup EAST; // Use Side keyword EAST
// *** Use the role-appropriate, randomly selected HVT unit type ***
_HVT = _HVTGroup createUnit [_selectedHvtUnitType, _remotePosition, [], 0, "FORM"];

// Add cash to the HVT unit
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

// --- Placeholders for final composition type/category for task description ---
private ["_finalCompType", "_finalCompCategory"];
_finalCompType = "Unknown"; // Default if everything fails
_finalCompCategory = "Location"; // Default if everything fails

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
        // *** Store the successful type/category for the task description ***
        _finalCompType = _selectedType;
        _finalCompCategory = _selectedCategory;
        diag_log format ["DEBUG HVT_task_1: Stored final Comp Type/Category for description: %1 / %2", _finalCompType, _finalCompCategory];

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
         // *** Store the fallback type/category for the task description ***
         _finalCompType = _fallbackType;
         _finalCompCategory = _fallbackCategory;
         diag_log format ["DEBUG HVT_task_1: Stored FALLBACK final Comp Type/Category for description: %1 / %2", _finalCompType, _finalCompCategory];
    } else {
         diag_log format ["DEBUG HVT_task_1: Fallback ALIVE attempt returned NIL/FALSE."];
         // Keep default "Unknown Location" if fallback also fails
         diag_log format ["DEBUG HVT_task_1: Keeping default Comp Type/Category for description: %1 / %2", _finalCompType, _finalCompCategory];
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


// --- *** Define Immersive Task Description Pool (Reversed Order) *** ---
// Structure: [Detailed Description (using _hvtRole), Short Title (using _hvtCodename), Marker Name]
private _taskDescriptions = [
    // Option 1: SIGINT Focus
    [
        format ["SIGINT confirms OPFOR %1, codename '%2', is operating near %3. Target is likely coordinating from a %4 %5. Neutralize the HVT to disrupt enemy C2.", _hvtRole, _hvtCodename, mapGridPosition _taskLocation, _finalCompType, _finalCompCategory], // Detailed Description (Element 0 - Uses Role)
        format ["Eliminate HVT: %1", _hvtCodename], // Short Title (Element 1 - Uses Codename)
        "HVT_Marker" // Marker Name (Element 2)
    ],
    // Option 2: HUMINT Focus
    [
        format ["Asset reports enemy %1, designated '%2', is located within a %3 %4 structure near %5. Command authorizes elimination. Proceed with extreme caution, expect resistance.", _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation], // Detailed Description (Element 0)
        format ["Terminate Target: %1", _hvtCodename], // Short Title (Element 1)
        "HVT_Marker" // Marker Name (Element 2)
    ],
    // Option 3: Direct Action Order
    [
        format ["Priority Tasking: Neutralize OPFOR %1, '%2'. Last known location vicinity %3, within a suspected %4 %5 complex. Lethal force authorized. Execute decisively.", _hvtRole, _hvtCodename, mapGridPosition _taskLocation, _finalCompType, _finalCompCategory], // Detailed Description (Element 0)
        format ["TASKORD: Neutralize %1", _hvtCodename], // Short Title (Element 1)
        "HVT_Marker" // Marker Name (Element 2)
    ],
    // Option 4: More Ambiguous/Urgent
    [
        format ["Urgent intel update: High-priority enemy %1, '%2', momentarily vulnerable near %3. Appears to be operating from a %4 %5. Window is closing fast. Engage and eliminate.", _hvtRole, _hvtCodename, mapGridPosition _taskLocation, _finalCompType, _finalCompCategory], // Detailed Description (Element 0)
        format ["Priority Target: %1", _hvtCodename], // Short Title (Element 1)
        "HVT_Marker" // Marker Name (Element 2)
    ],
    // Option 5: Focus on Target Impact
    [
        format ["Intel identifies crucial OPFOR %1, '%2', operating from a %3 %4 near %5. Their removal will severely impact enemy effectiveness in this AO. Sanctioned for termination.", _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation], // Detailed Description (Element 0)
        format ["Operation Decapitate: %1", _hvtCodename], // Short Title (Element 1)
        "HVT_Marker" // Marker Name (Element 2)
    ]
];

// --- Select one immersive description randomly ---
private _selectedDescription = selectRandom _taskDescriptions;
// Note: The log now shows Element 0 (Detailed) as 'Title' and Element 1 (Short) as 'Text' based on function params
diag_log format ["DEBUG HVT_task_1: Selected Task Description Array - [0]Title Param: '%1', [1]Description Param: '%2'", _selectedDescription select 0, _selectedDescription select 1];
// --- *** End Immersive Task Description Logic *** ---


// Create Task
[
    [_taskSide],            // Task owner(s)
    _taskID,                // Task ID
    _selectedDescription,   // *** USE THE SELECTED IMMERSIVE DESCRIPTION ARRAY HERE ***
    _taskLocation,          // Task destination
    "ASSIGNED",             // Task state
    1,                      // Task priority
    true,                   // Show notification
    "kill",                 // Task type
    true                    // Visible in 3D
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
    diag_log format ["SERVER: Added HVT task %1 (HVT: %2, Role: '%3', Type: %4) to tracking. Total tracked: %5", _taskID, _HVT, _hvtRole, typeOf _HVT, count server_activeHvtTasks]; // Added Role and Type to log
};


// --- REMOVED HELICOPTER CLEANUP BLOCK ---


// --- End of HVT_task_1.sqf ---