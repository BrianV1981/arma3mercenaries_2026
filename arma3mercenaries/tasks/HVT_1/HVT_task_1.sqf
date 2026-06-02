/*

    arma3mercenaries\tasks\HVT_1\HVT_task_1.sqf
    Author: BrianV1981
    Description:
    This script creates an HVT (high-value target) task for the player to eliminate.
    Features expanded HVT codenames and randomized Operation Names inspired by real-world conventions.
    The HVT's role influences the actual unit type spawned.
    *** HVT now patrols the area using standard MOVE/CYCLE waypoints after reaching the destination. ***
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

// --- Expanded HVT Codenames ---
private _codenames = [
    // Original
    "Viper", "Ghost", "Hammer", "Spectre", "Warden", "Azrael", "Cyclops", "Reaper", "Serpent", "Jackal",
    // Animals (Predators/Mythical)
    "Cobra", "Manticore", "Griffin", "Wolf", "Tiger", "Shark", "Raven", "Kestrel", "Falcon", "Condor",
    "Hyena", "Scorpion", "Dragon", "Wyvern", "Kraken", "Badger", "Wolverine", "Panther", "Gator", "Python",
    "Basilisk", "Gorgon", "Harpy", "Phoenix", "Sphinx",
    // Weapons/Tools
    "Dagger", "Sabre", "Scythe", "Anvil", "Javelin", "Pincer", "Scalpel", "Chisel", "Breaker", "Trident",
    "Lance", "Glaive", "Mace", "Claymore", "Cutlass", "Hatchet", "Pickaxe", "Crowbar", "Warhammer", "Bolt",
    "Arrow", "Crossbow", "Tomahawk", "Kris", "Rapier",
    // Mythology/History
    "Charon", "Hades", "Cerberus", "Minotaur", "Odin", "Loki", "Janus", "Caesar", "Nero", "Khan",
    "Atlas", "Orion", "Goliath", "Samson", "Zeus", "Thor", "Ares", "Mars", "Pluto", "Neptune",
    "Apollo", "Hermes", "Achilles", "Hector", "Leonidas",
    // Abstract/Intimidating
    "Shadow", "Wraith", "Phantom", "Oracle", "Cipher", "Enigma", "Overlord", "Juggernaut", "Nemesis", "Nexus",
    "Vector", "Apex", "Nadir", "Zenith", "Zero", "Void", "Abyss", "Mirage", "Echo", "Static",
    "Rogue", "Maverick", "Outlaw", "Bandit", "Corsair",
    // Neutral/Military Style
    "Anchor", "Beacon", "Carbon", "Domino", "Granite", "Indigo", "Jupiter", "Keystone", "Lima",
    "Metro", "Nickel", "Oscar", "Platinum", "Quebec", "Romeo", "Sierra", "Tango", "Umber", "Victor",
    "Whiskey", "XRay", "Yankee", "Zulu", "Argus", "Bravo", "Charlie", "Delta", "Foxtrot", "Golf",
    "Hotel", "India", "Kilo", "Mike", "November", "Papa" // Added more phonetic alphabet
];

// --- Operation Names (Inspired by Real-World Conventions) ---
private _operationNames = [
    "Silent Dagger", "Iron Gauntlet", "Crimson Spear", "Obsidian Shield", "Tempest Fury", "Final Sentinel",
    "Cyclone Hammer", "Anvil Strike", "Vigilant Sword", "Keystone Watch", "Desert Viper", "Arctic Wolf",
    "Mountain Hammer", "Coastal Serpent", "Urban Phantom", "Nightfall Reaper", "Urgent Fury", "Gothic Serpent",
    "Eagle Claw", "Just Cause", "Red Dawn", "Market Garden", "Rolling Thunder", "Steel Rain", "Blinding Sun",
    "Frozen Gate", "Whispering Wind", "Burning Sand", "Broken Arrow", "Goldeneye", "Phoenix Fire", "Serpent Coil",
    "Griffin Talon", "Iron Resolve", "Storm Breaker", "Vanguard Shield", "Echo Point", "Delta Watch", "Winter Sun",
    "Autumn Gale", "Spring Tide", "Summer Thunder", "Black Shield", "White Knight", "Grey Ghost", "Blue Falcon",
    "Green Light", "Red River", "Silver Spear", "Bronze Star", "Platinum Edge", "Titan Fist", "Oracle Lens"
];

// Refined HVT roles
private _targetRoles = [
    "Field Commander", "Logistics Officer", "Propagandist", "Intel Analyst",
    "Artillery Spotter", "Special Forces Advisor", "Comms Specialist", "Ordnance Expert",
    "Political Commissar", "Technical Specialist", "Medical Specialist", "Weapon Runner", "Recruiter",
    "Foreign Dignitary", "Scientist", "Engineer Lead" // Added more VIP/Specialist types
];

// All possible unit types (will be filtered based on selected role)
private _allHvtUnitTypes = [
    "O_officer_F", "O_Soldier_SL_F", "O_Soldier_TL_F", "O_medic_F",
    "O_engineer_F", "O_Soldier_exp_F", "O_Soldier_LAT_F", "O_soldier_UAV_06_F",
    "O_soldier_F", "O_ghillie_ard_F", "O_Story_Colonel_F" // Added Colonel for higher rank roles
];

// --- Selection Process ---
private _hvtOpName = selectRandom _operationNames;    // Select Operation Name
private _hvtCodename = selectRandom _codenames;      // Select HVT Codename
private _hvtRole = selectRandom _targetRoles;        // Select HVT Role

// Determine appropriate Unit Types based on the selected Role
private _possibleUnitTypes = [];
switch (_hvtRole) do {
    case "Field Commander":          { _possibleUnitTypes = ["O_officer_F", "O_Soldier_SL_F", "O_Story_Colonel_F"]; }; // Added Colonel
    case "Political Commissar":      { _possibleUnitTypes = ["O_officer_F", "O_Story_Colonel_F"]; }; // Added Colonel
    case "Special Forces Advisor":   { _possibleUnitTypes = ["O_Soldier_SL_F", "O_Soldier_TL_F", "O_ghillie_ard_F", "O_officer_F"]; };
    case "Logistics Officer":        { _possibleUnitTypes = ["O_officer_F", "O_engineer_F"]; };
    case "Intel Analyst":            { _possibleUnitTypes = ["O_officer_F", "O_soldier_UAV_06_F"]; };
    case "Comms Specialist":         { _possibleUnitTypes = ["O_officer_F", "O_soldier_UAV_06_F", "O_Soldier_TL_F"]; };
    case "Technical Specialist":     { _possibleUnitTypes = ["O_engineer_F", "O_soldier_UAV_06_F"]; };
    case "Engineer Lead":            { _possibleUnitTypes = ["O_engineer_F", "O_officer_F"]; }; // Engineer or Officer
    case "Ordnance Expert":          { _possibleUnitTypes = ["O_Soldier_exp_F", "O_engineer_F"]; };
    case "Artillery Spotter":        { _possibleUnitTypes = ["O_Soldier_TL_F", "O_soldier_UAV_06_F", "O_ghillie_ard_F"]; };
    case "Medical Specialist":       { _possibleUnitTypes = ["O_medic_F", "O_officer_F"]; };
    case "Propagandist":             { _possibleUnitTypes = ["O_officer_F", "O_soldier_F"]; };
    case "Weapon Runner":            { _possibleUnitTypes = ["O_Soldier_LAT_F", "O_Soldier_exp_F", "O_soldier_F"]; };
    case "Recruiter":                { _possibleUnitTypes = ["O_officer_F", "O_Soldier_SL_F", "O_soldier_F"]; };
    case "Foreign Dignitary":        { _possibleUnitTypes = ["O_officer_F", "O_Story_Colonel_F"]; }; // Officer/Colonel
    case "Scientist":                { _possibleUnitTypes = ["O_officer_F", "O_engineer_F"]; }; // Represented by Officer/Engineer

    default {
        diag_log format ["DEBUG HVT_task_1: WARNING - Role '%1' not explicitly mapped. Defaulting HVT type to Officer.", _hvtRole];
        _possibleUnitTypes = ["O_officer_F"];
    };
};

// Select the final HVT unit type from the filtered list
if (count _possibleUnitTypes == 0) then {
     diag_log format ["DEBUG HVT_task_1: ERROR - No possible unit types determined for role '%1'. Defaulting to Officer.", _hvtRole];
     _possibleUnitTypes = ["O_officer_F"];
};
private _selectedHvtUnitType = selectRandom _possibleUnitTypes;

diag_log format ["DEBUG HVT_task_1: Operation: '%1' | Selected Role: '%2' | HVT Codename: '%3' | Possible Units: %4 | Selected Unit Type: %5", _hvtOpName, _hvtRole, _hvtCodename, _possibleUnitTypes, _selectedHvtUnitType];
// --- End HVT Immersion Elements & Unit Selection ---


// Find safe location for the task center
_taskLocation = [getMarkerPos "red_taor_1", 1, 5000, 20, 0, 0.1, 0] call BIS_fnc_findSafePos;
diag_log format ["DEBUG HVT_task_1: findSafePos result for _taskLocation: %1", _taskLocation];

// Define the remote insertion point (1km from task location)
_remotePosition = [_taskLocation, 1000, 2000, 20, 0, 1, 0, [], []] call BIS_fnc_findSafePos;
diag_log format ["DEBUG HVT_task_1: findSafePos result for _remotePosition: %1", _remotePosition];

// Create the HVT group at the remote position (will be moved into heli later)
_HVTGroup = createGroup EAST; // Use Side keyword EAST
_HVT = _HVTGroup createUnit [_selectedHvtUnitType, _remotePosition, [], 0, "FORM"];

// Add cash to the HVT unit
[_HVT, 100000] call grad_moneymenu_fnc_addFunds;

// --- HVT Waypoint Setup (Initial Move + Patrol Cycle) ---
// Waypoint 1: Initial move to the task location center
private _HVTwp1 = _HVTGroup addWaypoint [_taskLocation, 0]; // Index 0 relative to group start (index 1 in editor terms)
_HVTwp1 setWaypointType "MOVE";
_HVTwp1 setWaypointSpeed "NORMAL";
_HVTwp1 setWaypointBehaviour "AWARE"; // Be aware upon arrival
_HVTwp1 setWaypointCompletionRadius 25; // Complete when reasonably close
diag_log format ["HVT Patrol Setup: WP1 (Index %1) set to MOVE to %2.", 1, _taskLocation]; // Log using editor index

// --- Define patrol area ---
private _patrolRadius = 75; // How far HVT might wander
private _patrolPoints = 3; // Number of random points in the patrol loop

// --- Add Patrol Waypoints ---
private _lastPatrolWpIndex = 1; // Track the index of the last added waypoint (starts after WP1)
for "_i" from 1 to _patrolPoints do {
    private _patrolPos = [_taskLocation, 0, _patrolRadius * 0.8, 10, 0, 0.3, 0, [], [_taskLocation]] call BIS_fnc_findSafePos; // Find safe pos around center
    if (count _patrolPos == 0) then {_patrolPos = _taskLocation getPos [_patrolRadius * (0.5 + random 0.5), random 360]; diag_log format ["HVT Patrol Setup: findSafePos failed for patrol point %1, using simple offset.", _i];}; // Fallback

    _lastPatrolWpIndex = _lastPatrolWpIndex + 1; // Increment index for the new waypoint
    private _wpPatrol = _HVTGroup addWaypoint [_patrolPos, _lastPatrolWpIndex - 1]; // Add waypoint sequentially
    _wpPatrol setWaypointType "MOVE";
    _wpPatrol setWaypointBehaviour "AWARE";
    _wpPatrol setWaypointSpeed "LIMITED";
    _wpPatrol setWaypointCompletionRadius 15;
    diag_log format ["HVT Patrol Setup: Added patrol WP%1 (Index %2) at %3.", _i, _lastPatrolWpIndex, _patrolPos];
};

// --- Add CYCLE Waypoint ---
// This waypoint tells the group to loop back after completing the last patrol point.
// By default, CYCLE loops back to the waypoint *before* the first MOVE waypoint in the cycle sequence, which is _HVTwp1 in this setup.
// To loop back to the *first patrol point* (index 2), we need to explicitly set it.
private _cycleWpIndex = _lastPatrolWpIndex + 1;
private _wpCycle = _HVTGroup addWaypoint [_taskLocation, _cycleWpIndex - 1]; // Position doesn't matter, add after last patrol WP
_wpCycle setWaypointType "CYCLE";
// According to documentation, CYCLE waypoints cause a loop. The default target might be sufficient,
// but we can try explicitly setting the target waypoint if needed.
// Let's rely on default CYCLE behavior first. If it doesn't loop A->B->C->A, uncomment the next line.
// _wpCycle setWaypointStatements ["true", format["(_this select 0) setCurrentWaypoint [_this select 0, %1];", 2]]; // 2 is the index of the first patrol waypoint (_HVTwpPatrol1 equivalent)
diag_log format ["HVT Patrol Setup: Added CYCLE WP (Index %1).", _cycleWpIndex];
// --- *** End of HVT Waypoint Setup *** ---


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

    // --- Call ALIVE function ---
    private _compositionPositionResult = nil; // Initialize to nil
    try {
        _compositionPositionResult = [_taskLocation, _selectedType, _selectedCategory, _selectedFaction, _selectedSize, _selectedInfantryGroups] call ALIVE_fnc_spawnRandomPopulatedComposition;
    } catch {
        diag_log format ["DEBUG HVT_task_1: ERROR during ALIVE_fnc_spawnRandomPopulatedComposition call: %1", _exception];
    };
    // --- End ALIVE call ---


    // --- Safely log the result ---
    private _resultValueStr = "<error>"; // Default if logging fails
    if (isNil "_compositionPositionResult") then {
         _resultValueStr = "<null>";
    } else {
        try { // Add try/catch around str just in case
             _resultValueStr = str _compositionPositionResult;
        } catch {
             diag_log format ["DEBUG HVT_task_1: Error converting ALIVE result to string: %1", _exception];
        };
    };
    diag_log format ["DEBUG HVT_task_1: Attempt %1 ALIVE call completed. Returned: %2", _attempts, _resultValueStr];
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
        diag_log format ["DEBUG HVT_task_1: ALIVE returned NIL/FALSE or Error on Attempt %1. Retrying.", _attempts];
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

    // --- Call ALIVE with fallback ---
    private _fallbackResult = nil;
    try {
         _fallbackResult = [_taskLocation, _fallbackType, _fallbackCategory, _fallbackFaction, _fallbackSize, _fallbackInfGroups] call ALIVE_fnc_spawnRandomPopulatedComposition;
    } catch {
        diag_log format ["DEBUG HVT_task_1: ERROR during FALLBACK ALIVE_fnc_spawnRandomPopulatedComposition call: %1", _exception];
    };
    // --- End Fallback ALIVE call ---

    // --- Safely log the fallback result ---
    private _fallbackResultValueStr = "<error>";
     if (isNil "_fallbackResult") then {
         _fallbackResultValueStr = "<null>";
    } else {
        try {
             _fallbackResultValueStr = str _fallbackResult;
        } catch {
             diag_log format ["DEBUG HVT_task_1: Error converting fallback ALIVE result to string: %1", _exception];
        };
    };
    diag_log format ["DEBUG HVT_task_1: Fallback ALIVE call completed. Returned: %1", _fallbackResultValueStr]; // SAFE LOG
    // --- End safe log ---

    if (!isNil "_fallbackResult" && {_fallbackResult}) then {
         diag_log format ["DEBUG HVT_task_1: Fallback ALIVE attempt returned TRUE."];
         // *** Store the fallback type/category for the task description ***
         _finalCompType = _fallbackType;
         _finalCompCategory = _fallbackCategory;
         diag_log format ["DEBUG HVT_task_1: Stored FALLBACK final Comp Type/Category for description: %1 / %2", _finalCompType, _finalCompCategory];
    } else {
         diag_log format ["DEBUG HVT_task_1: Fallback ALIVE attempt returned NIL/FALSE or Error."];
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

// --- Helicopter Waypoints ---
// Waypoint 1: Land at Task Location to unload HVT
private _heliWp1 = _heliGroup addWaypoint [_taskLocation, 0];
_heliWp1 setWaypointType "TR UNLOAD";
_heliWp1 setWaypointSpeed "FULL";
_heliWp1 setWaypointCompletionRadius 30; // Complete when close enough to unload

// Waypoint 2: Guard the LZ after dropoff
private _heliWp2 = _heliGroup addWaypoint [_taskLocation, 1]; // Point back to LZ, index 1
_heliWp2 setWaypointType "GUARD";                             // Change type to GUARD
_heliWp2 setWaypointCompletionRadius 50;                     // Radius for guarding area
_heliWp2 setWaypointCombatMode "RED";                         // Engage targets freely
_heliWp2 setWaypointBehaviour "COMBAT";                       // Actively seek/engage
_heliWp2 setWaypointSpeed "LIMITED";                         // Slow down near LZ
// --- End Helicopter Waypoint Setup ---


// --- *** Define Immersive Task Description Pool (Incorporating Operation Names) *** ---
// Structure: [Detailed Description (using Role & Op Name), Short Title (using Op Name & Codename), Marker Name]
private _taskDescriptions = [
    // Option 1: Standard Tasking
    [
        format ["OPERATION %1 // Tasking: Neutralize enemy %2, designated '%3'. Intel places target operating from %4 %5 near grid %6. Eliminate this asset to achieve operational objectives.", _hvtOpName, _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation], // Detailed Description
        format ["Op %1: Eliminate '%2'", _hvtOpName, _hvtCodename], // Short Title
        "HVT_Marker" // Marker Name
    ],
    // Option 2: SIGINT Focused
    [
        format ["OPERATION %1 // SIGINT DETECT: Confirmed hostile %2 ('%3') active at %4 %5, vicinity %6. High probability target is key to enemy activity in this sector. Action authorized.", _hvtOpName, _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation], // Detailed Description
        format ["Op %1: Target '%2'", _hvtOpName, _hvtCodename], // Short Title
        "HVT_Marker"
    ],
    // Option 3: HUMINT Focused
    [
        format ["OPERATION %1 // HUMINT REPORT: Source indicates OPFOR %2, callsign '%3', is currently located at a %4 %5 near %6. Subject is deemed high-value. Execute removal.", _hvtOpName, _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation], // Detailed Description
        format ["Op %1: Neutralize '%2'", _hvtOpName, _hvtCodename], // Short Title
        "HVT_Marker"
    ],
    // Option 4: Time Sensitive
    [
        format ["OPERATION %1 // FLASH TRAFFIC: Limited window to engage enemy %2 '%3' near %6. Location appears to be %4 %5. Target is crucial to current enemy ops. Strike immediately.", _hvtOpName, _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation], // Detailed Description
        format ["Op %1: Urgent - '%2'", _hvtOpName, _hvtCodename], // Short Title
        "HVT_Marker"
    ],
    // Option 5: Impact Focused
    [
        format ["OPERATION %1 // OBJECTIVE: Removal of OPFOR %2 '%3' is critical to degrading enemy capabilities. Last known position %4 %5 near %6. Confirm elimination.", _hvtOpName, _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation], // Detailed Description
        format ["Op %1: Disrupt - '%2'", _hvtOpName, _hvtCodename], // Short Title
        "HVT_Marker"
    ],
    // Option 6: Direct Action Framing
    [
        format ["OPERATION %1 // DIRECT ACTION ORDER: Prosecute target '%3', identified as OPFOR %2, operating from %4 %5 near %6. Target is disrupting friendly forces. Terminate with extreme prejudice.", _hvtOpName, _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation], // Detailed Description
        format ["Op %1: DA on '%2'", _hvtOpName, _hvtCodename], // Short Title (DA = Direct Action)
        "HVT_Marker"
    ],
    // Option 7: Interdiction Framing
    [
        format ["OPERATION %1 // INTERDICTION TASK: Intercept and eliminate enemy %2 ('%3'). Subject is facilitating hostile actions from %4 %5 near %6. Prevent further activity.", _hvtOpName, _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation], // Detailed Description
        format ["Op %1: Interdict '%2'", _hvtOpName, _hvtCodename], // Short Title
        "HVT_Marker"
    ]
];

// --- Select one immersive description randomly ---
private _selectedDescription = selectRandom _taskDescriptions;
diag_log format ["DEBUG HVT_task_1: Selected Task Desc Array - [0]Title Param: '%1', [1]Description Param: '%2'", _selectedDescription select 0, _selectedDescription select 1];
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
    "Asset removal successful. Job well done. Your payment is authorized.",
    // Added Op Name / Codename specific ones - Note: _hvtOpName and _hvtCodename might be stale if used directly here long after task creation
    // It's better practice to retrieve these from the task/unit if needed in the EH, but for simple random text, adding variations is okay.
    "Operation successful. Target confirmed eliminated. Excellent work.", // More generic successful op message
    "Objective Secured. High-value asset neutralized. Standby for exfil." // Another variation
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
        if (isNil "server_activeHvtTasks") then { server_activeHvtTasks = [];}; // Ensure array exists on server
        private _foundIndex = -1;
        {
            // Adjust check if structure of server_activeHvtTasks changes
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
// Optionally store OpName/Codename on HVT if needed by other scripts/EH later
// _HVT setVariable ["HVT_OpName", _hvtOpName];
// _HVT setVariable ["HVT_Codename", _hvtCodename];


// --- Add task to server tracking array ---
if (isServer) then {
    // Ensure the array exists
    if (isNil "server_activeHvtTasks") then { server_activeHvtTasks = []; };

    // Store Task ID, HVT Unit, Op Name, Codename, and Task Side
    // Structure: [TaskID, HVT Object, OpName, Codename, Side]
    server_activeHvtTasks pushBack [_taskID, _HVT, _hvtOpName, _hvtCodename, _taskSide];
    diag_log format ["SERVER: Added HVT task %1 (Op: '%2', HVT: %3, Codename: '%4', Role: '%5', Type: %6) to tracking. Total tracked: %7", _taskID, _hvtOpName, _HVT, _hvtCodename, _hvtRole, typeOf _HVT, count server_activeHvtTasks]; // Added Role and Type to log
};


// --- REMOVED HELICOPTER CLEANUP BLOCK ---


// --- End of HVT_task_1.sqf ---