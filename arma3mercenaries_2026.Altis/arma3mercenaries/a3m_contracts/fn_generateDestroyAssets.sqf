/*
    arma3mercenaries\a3m_contracts\fn_generateDestroyAssets.sqf
    Description: Generates a contract to destroy hidden OPFOR weapons caches inside a TAOR.
    Architecture: Uses ALiVE Profile Virtualization for guards and CBA PFH for tracking.
*/
if (!isServer) exitWith {};
waitUntil {!(isNil "BIS_fnc_init") && !(isNil "ALIVE_profileSystemInit")};

private _taskID = format ["contract_assets_%1_%2", floor(diag_tickTime * 10), floor(random 99999)];
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
private _taskLocation = [_randomTaorPos, 1, 300, 5, 0, 0.1, 0] call BIS_fnc_findSafePos;
if (_taskLocation isEqualTo []) then { _taskLocation = _randomTaorPos; };

// --- 2. Spawn the Weapon Caches as physical objects (Zero FPS cost, allows players to loot before destroying) ---
private _cacheClasses = ["Land_Pallet_MilBoxes_F", "CargoNet_01_box_F", "Box_Syndicate_Wps_F", "Box_East_AmmoVeh_F"];
private _targetCaches = [];
private _numCaches = (floor random 3) + 1; // 1 to 3 caches

for "_i" from 1 to _numCaches do {
    private _cachePos = [_taskLocation, 0, 30, 2, 0, 0.2, 0] call BIS_fnc_findSafePos;
    if (_cachePos isEqualTo []) then { _cachePos = _taskLocation getPos [random 20, random 360]; };
    
    private _cache = createVehicle [selectRandom _cacheClasses, _cachePos, [], 0, "NONE"];
    _cache setDir (random 360);
    _targetCaches pushBack _cache;
};

// --- 3. Spawn a Guard Detail as an ALiVE Virtual Profile ---
private _guardGroupConfig = ["OIA_InfTeam", "OIA_InfSquad"] call BIS_fnc_selectRandom;
private _guardProfiles = [_guardGroupConfig, _taskLocation, random 360, false, "OPF_F"] call ALIVE_fnc_createProfilesFromGroupConfig;

if (count _guardProfiles > 0) then {
    private _guardProfileEntity = _guardProfiles select 0;
    private _wpPatrol = [_taskLocation, 40, "MOVE", "SAFE", 10, [0,0,0], "WEDGE", "YELLOW", "AWARE", "Cache Guard Patrol"] call ALIVE_fnc_createProfileWaypoint;
    [_guardProfileEntity, "addWaypoint", _wpPatrol] call ALIVE_fnc_profileEntity;
};

// --- 4. Create the Task ---
private _fuzzyLocation = _taskLocation getPos [80 + random 150, random 360];
[
    [_taskSide, independent],
    _taskID,
    [
        format ["Local informants have reported %1 OPFOR weapons cache(s) hidden near grid %2. Locate the crates and destroy them with explosives to cripple their supply lines.", _numCaches, mapGridPosition _taskLocation],
        "Contract: Destroy Caches",
        "Destroy_Marker"
    ],
    _fuzzyLocation,
    "ASSIGNED",
    1,
    true,
    "destroy",
    true
] call BIS_fnc_taskCreate;

if (isNil "A3M_ActiveContracts") then { A3M_ActiveContracts = [] call ALiVE_fnc_hashCreate; };

private _dummyTarget = createVehicle ["Land_HelipadEmpty_F", _taskLocation, [], 0, "CAN_COLLIDE"];
if (!isNil "A3M_ActiveTasks") then {
    A3M_ActiveTasks set [_taskID, [_dummyTarget, _fuzzyLocation, "DestroyAssets"]];
    publicVariable "A3M_ActiveTasks";
};

[A3M_ActiveContracts, _taskID, [_targetCaches select 0, "DestroyAssets"]] call ALiVE_fnc_hashSet;

// --- 5. The CBA Per-Frame Handler Tracking Logic ---
[{
    params ["_args", "_handle"];
    _args params ["_taskID", "_targetCaches", "_fuzzyLocation", "_lastAliveCount", "_dummyTarget"];

    // 1. Task State Check (Prevents PFH from running forever if task is cancelled externally)
    private _taskState = [_taskID] call BIS_fnc_taskState;
    if (_taskState == "SUCCEEDED" || _taskState == "CANCELED" || _taskState == "FAILED") exitWith {
        if (!isNil "A3M_ActiveTasks") then { A3M_ActiveTasks deleteAt _taskID; publicVariable "A3M_ActiveTasks"; deleteVehicle _dummyTarget; };
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    private _currentAliveCount = {alive _x} count _targetCaches;
    
    if (_currentAliveCount < _lastAliveCount && _currentAliveCount > 0) then {
        private _destroyedMsg = format ["CACHE DESTROYED\n\nThere are %1 remaining in the target area. Keep searching.", _currentAliveCount];
        [_destroyedMsg] remoteExec ["hint", 0];
        _args set [3, _currentAliveCount];
    };

    if (_currentAliveCount == 0) then {
        [_taskID, 'SUCCEEDED', true] call BIS_fnc_taskSetState;
        
        // Payout to all players within 500m of the objective
        private _reward = 110000;
        {
            if (isPlayer _x && {alive _x} && {_x distance2D _fuzzyLocation < 500}) then {
                [_x, _reward] remoteExecCall ['grad_moneymenu_fnc_addFunds', _x];
                ['Contract Complete', format ['Transferred %1c for destroying the caches.', _reward]] remoteExec ['BIS_fnc_showSubtitle', _x];
            };
        } forEach playableUnits;
        
        diag_log format ['[A3M Contracts] Task %1 SUCCEEDED (CBA PFH Tracker).', _taskID];
        
        if (!isNil "A3M_ActiveContracts") then {
            [A3M_ActiveContracts, _taskID] call ALIVE_fnc_hashRemove;
        };
        
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
}, 5, [_taskID, _targetCaches, _fuzzyLocation, _numCaches, _dummyTarget]] call CBA_fnc_addPerFrameHandler;
