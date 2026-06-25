/*
    arma3mercenaries\a3m_contracts\fn_generateDestroyVehicles.sqf
    Description: Generates a contract to destroy enemy high-value vehicles (Armor/Logistics) inside a TAOR.
    Architecture: Uses 100% ALiVE Profile Virtualization and CBA Per-Frame Handlers.
*/
if (!isServer) exitWith {};
waitUntil {!(isNil "BIS_fnc_init") && !(isNil "ALIVE_profileSystemInit")};

private _taskID = format ["contract_destroyveh_%1_%2", floor(diag_tickTime * 10), floor(random 99999)];
private _taskSide = west;

// --- 1. Define Location strictly within an OPFOR TAOR ---
private _enemyTaorMarkers = ["red_taor_1", "red_taor_2", "red_taor_3", "red_taor_4", "red_taor_5"];
private _selectedTaor = selectRandom _enemyTaorMarkers;
if (getMarkerColor _selectedTaor == "") exitWith {
    private _msg = format ["A3M FATAL ERROR: Contract aborted. TAOR marker '%1' does not exist on the map!", _selectedTaor];
    diag_log _msg;
    _msg remoteExec ["systemChat", 0];
};
private _randomTaorPos = _selectedTaor call BIS_fnc_randomPosTrigger;
private _taskLocation = [_randomTaorPos, 1, 300, 10, 0, 0.1, 0] call BIS_fnc_findSafePos;
if (_taskLocation isEqualTo []) then { _taskLocation = _randomTaorPos; };

// --- 2. Spawn the Target Vehicles as ALiVE Virtual Profiles ---
private _vehicleClasses = ["O_MBT_02_cannon_F", "O_APC_Tracked_02_cannon_F", "O_Truck_03_ammo_F", "O_Truck_03_fuel_F"];
private _targetProfileIDs = [];
private _numVehicles = (floor random 3) + 1; // 1 to 3 vehicles

for "_i" from 1 to _numVehicles do {
    private _vehPos = [_taskLocation, 5, 50, 5, 0, 0.2, 0] call BIS_fnc_findSafePos;
    if (_vehPos isEqualTo []) then { _vehPos = _taskLocation getPos [10 + random 20, random 360]; };
    
    // Spawn vehicle natively
    private _veh = createVehicle [selectRandom _vehicleClasses, _vehPos, [], 0, "NONE"];
    _veh setDir random 360;
    
    // Virtualize immediately
    private _profileEntity = ["ADD", [_veh]] call ALIVE_fnc_createProfilesFromUnits;
    private _profileID = [_profileEntity, "profileID"] call ALIVE_fnc_profileEntity;
    
    _targetProfileIDs pushBack _profileID;
};

// --- 3. Spawn a Guard Detail as an ALiVE Virtual Profile ---
private _guardGroupConfig = ["OIA_InfTeam", "OIA_InfSquad", "OIA_ARTeam"] call BIS_fnc_selectRandom;
private _guardProfiles = [_guardGroupConfig, _taskLocation, random 360, false, "OPF_F"] call ALIVE_fnc_createProfilesFromGroupConfig;

if (count _guardProfiles > 0) then {
    private _guardProfileEntity = _guardProfiles select 0;
    private _wpPatrol = [_taskLocation, 50, "MOVE", "SAFE", 10, [0,0,0], "WEDGE", "YELLOW", "AWARE", "Guard Patrol"] call ALIVE_fnc_createProfileWaypoint;
    [_guardProfileEntity, "addWaypoint", _wpPatrol] call ALIVE_fnc_profileEntity;
};

// --- 4. Create the Task ---
private _fuzzyLocation = _taskLocation getPos [100 + random 200, random 360];
[
    [_taskSide, independent],
    _taskID,
    [
        format ["Satellite recon has spotted %1 high-value OPFOR vehicle(s) parked near grid %2. Destroy them to cripple enemy logistics. Payment wired upon confirmed destruction.", _numVehicles, mapGridPosition _taskLocation],
        "Contract: Destroy Vehicles",
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
    A3M_ActiveTasks set [_taskID, [_dummyTarget, _fuzzyLocation, "DestroyVehicles"]];
    publicVariable "A3M_ActiveTasks";
};

[A3M_ActiveContracts, _taskID, [_targetProfileIDs, "DestroyVehicles"]] call ALIVE_fnc_hashSet;

// --- 5. The CBA Per-Frame Handler Tracking Logic ---
[{
    params ["_args", "_handle"];
    _args params ["_taskID", "_targetProfileIDs", "_fuzzyLocation", "_dummyTarget"];

    // 1. Task State Check
    private _taskState = [_taskID] call BIS_fnc_taskState;
    if (_taskState == "SUCCEEDED" || _taskState == "CANCELED" || _taskState == "FAILED") exitWith {
        if (!isNil "A3M_ActiveTasks") then { A3M_ActiveTasks deleteAt _taskID; publicVariable "A3M_ActiveTasks"; deleteVehicle _dummyTarget; };
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    private _allDestroyed = true;
    
    {
        private _profileID = _x;
        private _vehicleProfile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
        
        if (!isNil "_vehicleProfile") then {
            private _physicalVeh = [_vehicleProfile, "entity"] call ALIVE_fnc_profileEntity;
            
            if (!isNil "_physicalVeh" && {typeName _physicalVeh == "OBJECT" && !isNull _physicalVeh}) then {
                if (!alive _physicalVeh) then {
                    // Physical vehicle is dead, manually remove the ALiVE profile to garbage collect
                    [ALIVE_profileHandler, "removeProfile", _profileID] call ALIVE_fnc_profileHandler;
                } else {
                    _allDestroyed = false; // Still alive physically
                };
            } else {
                _allDestroyed = false; // Still alive virtually
            };
        };
    } forEach _targetProfileIDs;

    if (_allDestroyed) then {
        [_taskID, 'SUCCEEDED', true] call BIS_fnc_taskSetState;
        
        // Payout to all players within 500m of the objective
        private _reward = 125000;
        {
            if (isPlayer _x && {alive _x} && {_x distance2D _fuzzyLocation < 500}) then {
                [_x, _reward] remoteExecCall ['grad_moneymenu_fnc_addFunds', _x];
                ['Contract Complete', format ['Transferred %1c for vehicle destruction.', _reward]] remoteExec ['BIS_fnc_showSubtitle', _x];
            };
        } forEach playableUnits;
        
        diag_log format ['[A3M Contracts] Task %1 SUCCEEDED.', _taskID];
        
        if (!isNil "A3M_ActiveContracts") then {
            [A3M_ActiveContracts, _taskID] call ALIVE_fnc_hashRemove;
        };
        
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
}, 5, [_taskID, _targetProfileIDs, _fuzzyLocation, _dummyTarget]] call CBA_fnc_addPerFrameHandler;
