/*
    arma3mercenaries\a3m_contracts\fn_generateRemoveIED.sqf
    Description: Generates a contract to locate and neutralize IEDs inside a TAOR.
    Architecture: Uses ALiVE Profile Virtualization for guards and CBA PFH for tracking.
*/
if (!isServer) exitWith {};
waitUntil {!(isNil "BIS_fnc_init") && !(isNil "ALIVE_profileSystemInit")};

private _taskID = format ["contract_eod_%1_%2", floor(diag_tickTime * 10), floor(random 99999)];
private _taskSide = west;

// --- 1. Define Location strictly within a Friendly/Contested TAOR ---
private _enemyTaorMarkers = ["red_taor_1", "red_taor_2", "red_taor_3", "red_taor_4", "red_taor_5"];
private _selectedTaor = selectRandom _enemyTaorMarkers;
if (getMarkerColor _selectedTaor == "") exitWith {
    private _msg = format ["A3M FATAL ERROR: Contract aborted. TAOR marker '%1' does not exist on the map!", _selectedTaor];
    diag_log _msg;
    _msg remoteExec ["systemChat", 0];
};
private _randomTaorPos = _selectedTaor call BIS_fnc_randomPosTrigger;

// Attempt to find a road nearby
private _roads = _randomTaorPos nearRoads 400;
private _taskLocation = [];
if (count _roads > 0) then {
    _taskLocation = getPos (selectRandom _roads);
} else {
    _taskLocation = [_randomTaorPos, 1, 300, 5, 0, 0.1, 0] call BIS_fnc_findSafePos;
    if (_taskLocation isEqualTo []) then { _taskLocation = _randomTaorPos; };
};

// --- 2. Spawn the IEDs as physical objects (Zero FPS cost, needed for EOD interaction) ---
private _iedClasses = ["IEDUrbanBig_F", "IEDLandBig_F", "IEDLandSmall_F"];
private _targetIEDs = [];
private _numIEDs = (floor random 3) + 2; // 2 to 4 IEDs

for "_i" from 1 to _numIEDs do {
    private _iedPos = _taskLocation getPos [random 20, random 360];
    private _ied = createMine [selectRandom _iedClasses, _iedPos, [], 0];
    _targetIEDs pushBack _ied;
};

// --- 3. Spawn an Ambush Detail as an ALiVE Virtual Profile ---
private _guardGroupConfig = ["OIA_InfTeam", "OIA_InfSquad"] call BIS_fnc_selectRandom;
private _guardProfiles = [_guardGroupConfig, _taskLocation, random 360, false, "OPF_F"] call ALIVE_fnc_createProfilesFromGroupConfig;

if (count _guardProfiles > 0) then {
    private _guardProfileEntity = _guardProfiles select 0;
    private _wpPatrol = [_taskLocation, 50, "MOVE", "SAFE", 10, [0,0,0], "WEDGE", "YELLOW", "AWARE", "Ambush Patrol"] call ALIVE_fnc_createProfileWaypoint;
    [_guardProfileEntity, "addWaypoint", _wpPatrol] call ALIVE_fnc_profileEntity;
};

// --- 4. Create the Task ---
private _fuzzyLocation = _taskLocation getPos [50 + random 100, random 360];
[
    [_taskSide, independent],
    _taskID,
    [
        format ["Intel reports that %1 IED(s) have been planted near grid %2. Send an EOD specialist to locate and either defuse or safely detonate them. Watch out for ambushes.", _numIEDs, mapGridPosition _taskLocation],
        "Contract: EOD Clearance",
        "Minefield_Marker"
    ],
    _fuzzyLocation,
    "ASSIGNED",
    1,
    true,
    "mine",
    true
] call BIS_fnc_taskCreate;

if (isNil "A3M_ActiveContracts") then { A3M_ActiveContracts = [] call ALiVE_fnc_hashCreate; };
[A3M_ActiveContracts, _taskID, [_targetIEDs select 0, "RemoveIED"]] call ALiVE_fnc_hashSet;

// --- 5. The CBA Per-Frame Handler Tracking Logic ---
[{
    params ["_args", "_handle"];
    _args params ["_taskID", "_targetIEDs", "_fuzzyLocation"];

    // 1. Task State Check (Prevents PFH from running forever if task is cancelled externally)
    private _taskState = [_taskID] call BIS_fnc_taskState;
    if (_taskState == "SUCCEEDED" || _taskState == "CANCELED" || _taskState == "FAILED") exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    // A mine is considered removed if it is destroyed (!alive) OR defused (!mineActive)
    private _allRemoved = true;
    {
        if (alive _x && {mineActive _x}) then {
            _allRemoved = false;
        };
    } forEach _targetIEDs;

    if (_allRemoved) then {
        [_taskID, 'SUCCEEDED', true] call BIS_fnc_taskSetState;
        
        // Payout to all players within 500m of the objective
        private _reward = 80000;
        {
            if (isPlayer _x && {alive _x} && {_x distance2D _fuzzyLocation < 500}) then {
                [_x, _reward] remoteExecCall ['grad_moneymenu_fnc_addFunds', _x];
                ['Contract Complete', format ['Transferred %1c for clearing the IEDs.', _reward]] remoteExec ['BIS_fnc_showSubtitle', _x];
            };
        } forEach playableUnits;
        
        diag_log format ['[A3M Contracts] Task %1 SUCCEEDED (CBA PFH Tracker).', _taskID];
        
        if (!isNil "A3M_ActiveContracts") then {
            [A3M_ActiveContracts, _taskID] call ALIVE_fnc_hashRemove;
        };
        
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
}, 5, [_taskID, _targetIEDs, _fuzzyLocation]] call CBA_fnc_addPerFrameHandler;
