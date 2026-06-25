/*
    arma3mercenaries\a3m_contracts\fn_generateDestroyInfantry.sqf
    Description: Generates a contract to wipe out a specific enemy platoon inside a TAOR.
    Architecture: Uses 100% ALiVE Profile Virtualization and CBA Per-Frame Handlers.
*/
if (!isServer) exitWith {};
waitUntil {!(isNil "BIS_fnc_init") && !(isNil "ALIVE_profileSystemInit")};

private _taskID = format ["contract_wipeout_%1_%2", floor(diag_tickTime * 10), floor(random 99999)];
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
private _taskLocation = [_randomTaorPos, 1, 300, 5, 0, 0.1, 0] call BIS_fnc_findSafePos;
if (_taskLocation isEqualTo []) then { _taskLocation = _randomTaorPos; };

// --- 2. Spawn the Target Platoon as an ALiVE Virtual Profile ---
private _platoonGroupConfig = ["OIA_InfSquad", "OIA_ARTeam", "OIA_InfTeam"] call BIS_fnc_selectRandom;
private _platoonProfiles = [_platoonGroupConfig, _taskLocation, random 360, false, "OPF_F"] call ALIVE_fnc_createProfilesFromGroupConfig;

// Extract the Entity Profile ID (Index 0 is the infantry squad entity)
if (count _platoonProfiles == 0) exitWith { diag_log format["[A3M Contracts] ERROR: Failed to generate ALiVE Profile for %1", _taskID]; };

private _platoonProfileEntity = _platoonProfiles select 0;
private _targetProfileID = [_platoonProfileEntity, "profileID"] call ALIVE_fnc_profileEntity;

// Assign a virtual patrol waypoint so they move around the TAOR
private _wpPatrol = [_taskLocation, 100, "MOVE", "SAFE", 15, [0,0,0], "WEDGE", "YELLOW", "AWARE", "Platoon Patrol"] call ALIVE_fnc_createProfileWaypoint;
[_platoonProfileEntity, "addWaypoint", _wpPatrol] call ALIVE_fnc_profileEntity;


// --- 3. Create the Task ---
private _fuzzyLocation = _taskLocation getPos [50 + random 100, random 360];
[
    [_taskSide, independent],
    _taskID,
    [
        format ["A heavily armed OPFOR platoon is operating near grid %1. Track them down and wipe out the entire squad. Payment wired upon confirmed elimination of all targets.", mapGridPosition _taskLocation],
        "Contract: Platoon Wipeout",
        "Target_Marker"
    ],
    _fuzzyLocation,
    "ASSIGNED",
    1,
    true,
    "target",
    true
] call BIS_fnc_taskCreate;

if (isNil "A3M_ActiveContracts") then { A3M_ActiveContracts = [] call ALiVE_fnc_hashCreate; };
[A3M_ActiveContracts, _taskID, [[_targetProfileID], "DestroyInfantry"]] call ALiVE_fnc_hashSet;

// --- 4. The CBA Per-Frame Handler Tracking Logic ---
[{
    params ["_args", "_handle"];
    _args params ["_taskID", "_targetProfileID", "_fuzzyLocation"];

    // 1. Task State Check (Prevents PFH from running forever if task is cancelled externally)
    private _taskState = [_taskID] call BIS_fnc_taskState;
    if (_taskState == "SUCCEEDED" || _taskState == "CANCELED" || _taskState == "FAILED") exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    private _allDestroyed = false;
    private _profile = [ALIVE_profileHandler, "getProfile", _targetProfileID] call ALIVE_fnc_profileHandler;
    
    // ALiVE Garbage Collector removes profiles from the handler when all units are dead virtually
    if (isNil "_profile") then {
        _allDestroyed = true;
    } else {
        // Safe check for physically spawned units
        private _physicalGroup = [_profile, "entity"] call ALIVE_fnc_profileEntity;
        if (!isNil "_physicalGroup" && {typeName _physicalGroup == "GROUP" && !isNull _physicalGroup}) then {
            if ({alive _x} count (units _physicalGroup) == 0) then {
                _allDestroyed = true;
                // Force delete the profile to clean up memory since physical units are wiped
                [ALIVE_profileHandler, "removeProfile", _targetProfileID] call ALIVE_fnc_profileHandler;
            };
        };
    };

    if (_allDestroyed) then {
        [_taskID, 'SUCCEEDED', true] call BIS_fnc_taskSetState;
        
        // Payout to all players within 800m of the objective
        private _reward = 100000;
        {
            if (isPlayer _x && {alive _x} && {_x distance2D _fuzzyLocation < 800}) then {
                [_x, _reward] remoteExecCall ['grad_moneymenu_fnc_addFunds', _x];
                ['Contract Complete', format ['Transferred %1c for wiping out the platoon.', _reward]] remoteExec ['BIS_fnc_showSubtitle', _x];
            };
        } forEach playableUnits;
        
        diag_log format ['[A3M Contracts] Task %1 SUCCEEDED (ALiVE Virtual Tracker).', _taskID];
        
        if (!isNil "A3M_ActiveContracts") then {
            [A3M_ActiveContracts, _taskID] call ALIVE_fnc_hashRemove;
        };
        
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
}, 5, [_taskID, _targetProfileID, _fuzzyLocation]] call CBA_fnc_addPerFrameHandler;
