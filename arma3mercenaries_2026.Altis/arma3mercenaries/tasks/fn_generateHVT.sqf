/*
    arma3mercenaries\tasks\fn_generateHVT.sqf
    Description: Scheduled generation of HVT tasks, compositions, and logic.
    Executes in a scheduled environment via 'spawn' from fn_requestTask.
    Restores the original 10-attempt ALiVE composition loop and fallback mechanics.
*/
if (!isServer) exitWith {};

// Ensure BIS functions are initialized
waitUntil {!(isNil "BIS_fnc_init")};

// Task Initialization
private _taskID = format ["task_assassination_%1", diag_tickTime];
private _taskSide = west;
private _taskFaction = "BLU_F"; // Player faction
private _taskEnemyFaction = "OPF_F"; // This is the faction CLASSNAME used for ALIVE attempts

// --- Expanded HVT Codenames ---
private _codenames = [
    "Viper", "Ghost", "Hammer", "Spectre", "Warden", "Azrael", "Cyclops", "Reaper", "Serpent", "Jackal",
    "Cobra", "Manticore", "Griffin", "Wolf", "Tiger", "Shark", "Raven", "Kestrel", "Falcon", "Condor",
    "Hyena", "Scorpion", "Dragon", "Wyvern", "Kraken", "Badger", "Wolverine", "Panther", "Gator", "Python",
    "Basilisk", "Gorgon", "Harpy", "Phoenix", "Sphinx",
    "Dagger", "Sabre", "Scythe", "Anvil", "Javelin", "Pincer", "Scalpel", "Chisel", "Breaker", "Trident",
    "Lance", "Glaive", "Mace", "Claymore", "Cutlass", "Hatchet", "Pickaxe", "Crowbar", "Warhammer", "Bolt",
    "Arrow", "Crossbow", "Tomahawk", "Kris", "Rapier",
    "Charon", "Hades", "Cerberus", "Minotaur", "Odin", "Loki", "Janus", "Caesar", "Nero", "Khan",
    "Atlas", "Orion", "Goliath", "Samson", "Zeus", "Thor", "Ares", "Mars", "Pluto", "Neptune",
    "Apollo", "Hermes", "Achilles", "Hector", "Leonidas",
    "Shadow", "Wraith", "Phantom", "Oracle", "Cipher", "Enigma", "Overlord", "Juggernaut", "Nemesis", "Nexus",
    "Vector", "Apex", "Nadir", "Zenith", "Zero", "Void", "Abyss", "Mirage", "Echo", "Static",
    "Rogue", "Maverick", "Outlaw", "Bandit", "Corsair",
    "Anchor", "Beacon", "Carbon", "Domino", "Granite", "Indigo", "Jupiter", "Keystone", "Lima",
    "Metro", "Nickel", "Oscar", "Platinum", "Quebec", "Romeo", "Sierra", "Tango", "Umber", "Victor",
    "Whiskey", "XRay", "Yankee", "Zulu", "Argus", "Bravo", "Charlie", "Delta", "Foxtrot", "Golf",
    "Hotel", "India", "Kilo", "Mike", "November", "Papa"
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
    "Foreign Dignitary", "Scientist", "Engineer Lead"
];

// --- Selection Process ---
private _hvtOpName = selectRandom _operationNames;    // Select Operation Name
private _hvtCodename = selectRandom _codenames;      // Select HVT Codename
private _hvtRole = selectRandom _targetRoles;        // Select HVT Role

// Determine appropriate Unit Types based on the selected Role
private _possibleUnitTypes = [];
switch (_hvtRole) do {
    case "Field Commander":          { _possibleUnitTypes = ["O_officer_F", "O_Soldier_SL_F", "O_Story_Colonel_F"]; };
    case "Political Commissar":      { _possibleUnitTypes = ["O_officer_F", "O_Story_Colonel_F"]; };
    case "Special Forces Advisor":   { _possibleUnitTypes = ["O_Soldier_SL_F", "O_Soldier_TL_F", "O_ghillie_ard_F", "O_officer_F"]; };
    case "Logistics Officer":        { _possibleUnitTypes = ["O_officer_F", "O_engineer_F"]; };
    case "Intel Analyst":            { _possibleUnitTypes = ["O_officer_F", "O_soldier_UAV_06_F"]; };
    case "Comms Specialist":         { _possibleUnitTypes = ["O_officer_F", "O_soldier_UAV_06_F", "O_Soldier_TL_F"]; };
    case "Technical Specialist":     { _possibleUnitTypes = ["O_engineer_F", "O_soldier_UAV_06_F"]; };
    case "Engineer Lead":            { _possibleUnitTypes = ["O_engineer_F", "O_officer_F"]; };
    case "Ordnance Expert":          { _possibleUnitTypes = ["O_Soldier_exp_F", "O_engineer_F"]; };
    case "Artillery Spotter":        { _possibleUnitTypes = ["O_Soldier_TL_F", "O_soldier_UAV_06_F", "O_ghillie_ard_F"]; };
    case "Medical Specialist":       { _possibleUnitTypes = ["O_medic_F", "O_officer_F"]; };
    case "Propagandist":             { _possibleUnitTypes = ["O_officer_F", "O_soldier_F"]; };
    case "Weapon Runner":            { _possibleUnitTypes = ["O_Soldier_LAT_F", "O_Soldier_exp_F", "O_soldier_F"]; };
    case "Recruiter":                { _possibleUnitTypes = ["O_officer_F", "O_Soldier_SL_F", "O_soldier_F"]; };
    case "Foreign Dignitary":        { _possibleUnitTypes = ["O_officer_F", "O_Story_Colonel_F"]; };
    case "Scientist":                { _possibleUnitTypes = ["O_officer_F", "O_engineer_F"]; };
    default {
        _possibleUnitTypes = ["O_officer_F"];
    };
};

private _selectedHvtUnitType = selectRandom _possibleUnitTypes;

// Find safe location for the task center
private _taskLocation = [getMarkerPos "red_taor_1", 1, 5000, 20, 0, 0.1, 0] call BIS_fnc_findSafePos;
diag_log format ["DEBUG HVT_task_1: findSafePos result for _taskLocation: %1", _taskLocation];

// --- START OF COMPOSITION LOGIC ---
private _compositionTypes = ["Civilian", "Military", "Guerrilla"];
private _militaryCategories = ["airports", "camps", "checkpointsbarricades", "constructionsupplies", "communications", "crashsites", "fieldhq", "fort", "fuel", "heliports", "hq", "marine", "medical", "outposts", "power", "supports", "supplies"];
private _civilianCategories = ["airports", "checkpointsbarricades", "construction", "constructionSupplies", "communications", "fuel", "general", "heliports", "industrial", "marine", "mining_oil", "power", "rail", "settlements"];
private _guerrillaCategories = ["camps", "checkpointsbarricades", "constructionsupplies", "commnunications", "fieldhq", "fort", "fuel", "hq", "marine", "medical", "outposts", "power", "supports"];
private _factions = [_taskEnemyFaction];
private _sizes = ["Large", "Medium", "Small", "ANY"];
private _infantryGroups = [1, 2, 3, 4];

private _finalCompType = "Unknown";
private _finalCompCategory = "Location";

private _success = false;
private _attempts = 0;
private _maxAttempts = 10;

while {!_success && _attempts < _maxAttempts} do {
    _attempts = _attempts + 1;
    
    private _selectedType = selectRandom _compositionTypes;
    private _categoryArrayToUse = [];
    switch (_selectedType) do {
        case "Military": { _categoryArrayToUse = _militaryCategories; };
        case "Civilian": { _categoryArrayToUse = _civilianCategories; };
        case "Guerrilla": { _categoryArrayToUse = _guerrillaCategories; };
    };
    if (count _categoryArrayToUse == 0) then { continue; };
    
    private _selectedCategory = selectRandom _categoryArrayToUse;
    private _selectedFaction = selectRandom _factions;
    private _selectedSize = selectRandom _sizes;
    private _selectedInfantryGroups = selectRandom _infantryGroups;

    private _compositionPositionResult = nil;
    try {
        _compositionPositionResult = [_taskLocation, _selectedType, _selectedCategory, _selectedFaction, _selectedSize, _selectedInfantryGroups] call ALIVE_fnc_spawnRandomPopulatedComposition;
    } catch {
        diag_log format ["DEBUG HVT_task_1: ERROR during ALIVE_fnc_spawnRandomPopulatedComposition call: %1", _exception];
    };

    if (!isNil "_compositionPositionResult" && {_compositionPositionResult}) then {
        _success = true;
        _finalCompType = _selectedType;
        _finalCompCategory = _selectedCategory;
    };

    if (_success) exitWith {};
};

// --- FALLBACK LOGIC ---
if (!_success) then {
    diag_log "DEBUG HVT_task_1: ALL random ALIVE attempts failed. Attempting fallback composition.";
    
    private _fallbackType = "Military";
    private _fallbackCategory = "Fort";
    private _fallbackFaction = _taskEnemyFaction;
    private _fallbackSize = "Small";
    private _fallbackInfGroups = 2;

    private _fallbackResult = nil;
    try {
         _fallbackResult = [_taskLocation, _fallbackType, _fallbackCategory, _fallbackFaction, _fallbackSize, _fallbackInfGroups] call ALIVE_fnc_spawnRandomPopulatedComposition;
    } catch {
        diag_log format ["DEBUG HVT_task_1: ERROR during FALLBACK ALIVE_fnc_spawnRandomPopulatedComposition call: %1", _exception];
    };

    if (!isNil "_fallbackResult" && {_fallbackResult}) then {
         _finalCompType = _fallbackType;
         _finalCompCategory = _fallbackCategory;
    };
};
// --- END OF COMPOSITION LOGIC ---

// Create the HVT group directly at the task location (no helicopter)
private _HVTGroup = createGroup EAST;
private _HVT = _HVTGroup createUnit [_selectedHvtUnitType, _taskLocation, [], 0, "FORM"];

// Add cash to the HVT unit
[_HVT, 100000] call grad_moneymenu_fnc_addFunds;

// --- HVT Waypoint Setup (Initial Move + Patrol Cycle) ---
private _HVTwp1 = _HVTGroup addWaypoint [_taskLocation, 0];
_HVTwp1 setWaypointType "MOVE";
_HVTwp1 setWaypointSpeed "NORMAL";
_HVTwp1 setWaypointBehaviour "AWARE";
_HVTwp1 setWaypointCompletionRadius 25;

private _patrolRadius = 75;
private _patrolPoints = 3;
private _lastPatrolWpIndex = 1;

for "_i" from 1 to _patrolPoints do {
    private _patrolPos = [_taskLocation, 0, _patrolRadius * 0.8, 10, 0, 0.3, 0, [], [_taskLocation]] call BIS_fnc_findSafePos;
    if (count _patrolPos == 0) then { _patrolPos = _taskLocation getPos [_patrolRadius * (0.5 + random 0.5), random 360]; };

    _lastPatrolWpIndex = _lastPatrolWpIndex + 1;
    private _wpPatrol = _HVTGroup addWaypoint [_patrolPos, _lastPatrolWpIndex - 1];
    _wpPatrol setWaypointType "MOVE";
    _wpPatrol setWaypointBehaviour "AWARE";
    _wpPatrol setWaypointSpeed "LIMITED";
    _wpPatrol setWaypointCompletionRadius 15;
};

private _cycleWpIndex = _lastPatrolWpIndex + 1;
private _wpCycle = _HVTGroup addWaypoint [_taskLocation, _cycleWpIndex - 1];
_wpCycle setWaypointType "CYCLE";


// --- *** Define Immersive Task Description Pool *** ---
private _taskDescriptions = [
    [
        format ["OPERATION %1 // Tasking: Neutralize enemy %2, designated '%3'. Intel places target operating from %4 %5 near grid %6. Eliminate this asset to achieve operational objectives.", _hvtOpName, _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation],
        format ["Op %1: Eliminate '%2'", _hvtOpName, _hvtCodename],
        "HVT_Marker"
    ],
    [
        format ["OPERATION %1 // SIGINT DETECT: Confirmed hostile %2 ('%3') active at %4 %5, vicinity %6. High probability target is key to enemy activity in this sector. Action authorized.", _hvtOpName, _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation],
        format ["Op %1: Target '%2'", _hvtOpName, _hvtCodename],
        "HVT_Marker"
    ],
    [
        format ["OPERATION %1 // HUMINT REPORT: Source indicates OPFOR %2, callsign '%3', is currently located at a %4 %5 near %6. Subject is deemed high-value. Execute removal.", _hvtOpName, _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation],
        format ["Op %1: Neutralize '%2'", _hvtOpName, _hvtCodename],
        "HVT_Marker"
    ],
    [
        format ["OPERATION %1 // FLASH TRAFFIC: Limited window to engage enemy %2 '%3' near %6. Location appears to be %4 %5. Target is crucial to current enemy ops. Strike immediately.", _hvtOpName, _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation],
        format ["Op %1: Urgent - '%2'", _hvtOpName, _hvtCodename],
        "HVT_Marker"
    ],
    [
        format ["OPERATION %1 // OBJECTIVE: Removal of OPFOR %2 '%3' is critical to degrading enemy capabilities. Last known position %4 %5 near %6. Confirm elimination.", _hvtOpName, _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation],
        format ["Op %1: Disrupt - '%2'", _hvtOpName, _hvtCodename],
        "HVT_Marker"
    ],
    [
        format ["OPERATION %1 // DIRECT ACTION ORDER: Prosecute target '%3', identified as OPFOR %2, operating from %4 %5 near %6. Target is disrupting friendly forces. Terminate with extreme prejudice.", _hvtOpName, _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation],
        format ["Op %1: DA on '%2'", _hvtOpName, _hvtCodename],
        "HVT_Marker"
    ],
    [
        format ["OPERATION %1 // INTERDICTION TASK: Intercept and eliminate enemy %2 ('%3'). Subject is facilitating hostile actions from %4 %5 near %6. Prevent further activity.", _hvtOpName, _hvtRole, _hvtCodename, _finalCompType, _finalCompCategory, mapGridPosition _taskLocation],
        format ["Op %1: Interdict '%2'", _hvtOpName, _hvtCodename],
        "HVT_Marker"
    ]
];

private _selectedDescription = selectRandom _taskDescriptions;

// Create Task with native JIP assignment (array of sides)
[
    [_taskSide, independent],            // Task owner(s) - west and independent
    _taskID,                // Task ID
    _selectedDescription,   // Description array
    _taskLocation,          // Task destination
    "ASSIGNED",             // Task state
    1,                      // Task priority
    true,                   // Show notification
    "kill",                 // Task type
    true                    // Visible in 3D
] call BIS_fnc_taskCreate;

// Add Killed Event Handler to handle Task Completion and Payout
_HVT setVariable ["taskID", _taskID];
// Event Handler logic migrated to arma3mercenaries_killHandler.sqf

// Register to Task Manager
if (!isNil "A3M_ActiveTasks") then {
    A3M_ActiveTasks set [_taskID, [_HVT, "HVT"]];
    diag_log format ["[A3M TASK MANAGER] Registered HVT Task: %1", _taskID];
};