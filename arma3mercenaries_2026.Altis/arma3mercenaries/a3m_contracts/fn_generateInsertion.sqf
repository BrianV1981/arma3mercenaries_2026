/*
    arma3mercenaries\a3m_contracts\fn_generateInsertion.sqf
    Description: Generates a Combat Drop (Insertion) contract. Players must pick up an AI Assault Team
    at base and hot-drop them into an active enemy TAOR.
    Refactored to ALiVE Virtualization and CBA PFH standard.
*/
if (!isServer) exitWith {};
waitUntil {!(isNil "BIS_fnc_init")};

private _taskID = format ["contract_insertion_%1_%2", floor(diag_tickTime * 10), floor(random 99999)];
private _taskSide = west;

// --- 1. Define the Drop Zone (DZ) strictly within an OPFOR TAOR ---
private _enemyTaorMarkers = ["red_taor_1", "red_taor_2", "red_taor_3", "red_taor_4", "red_taor_5"];
private _selectedTaor = selectRandom _enemyTaorMarkers;
if (getMarkerColor _selectedTaor == "") exitWith {
    private _msg = format ["A3M FATAL ERROR: Contract aborted. TAOR marker '%1' does not exist on the map!", _selectedTaor];
    diag_log _msg;
    _msg remoteExec ["systemChat", 0];
};
private _randomTaorPos = _selectedTaor call BIS_fnc_randomPosTrigger;
private _dropZonePos = [_randomTaorPos, 1, 300, 10, 0, 0.1, 0] call BIS_fnc_findSafePos;
if (_dropZonePos isEqualTo []) then { _dropZonePos = _randomTaorPos; };

// --- 2. Define the Pickup Point (Friendly Base) ---
private _pickupPos = getMarkerPos "respawn_west";
if (_pickupPos isEqualTo [0,0,0]) then { _pickupPos = [worldSize/2, worldSize/2, 0]; };
private _spawnPos = _pickupPos getPos [20 + random 20, random 360];

// --- 3. Spawn the AI Assault Team ---
private _assaultGroup = createGroup [west, true];
private _infantryClasses = ["B_Soldier_SL_F", "B_Soldier_F", "B_Soldier_LAT_F", "B_medic_F", "B_Soldier_AR_F", "B_Soldier_GL_F"];
for "_i" from 1 to 6 do {
    private _unit = _assaultGroup createUnit [selectRandom _infantryClasses, _spawnPos, [], 5, "FORM"];
    _unit setVariable ["A3M_isAssaultTeam", true, true];
};
_assaultGroup setBehaviour "SAFE";

// --- VIRTUALIZE THE ASSAULT TEAM IMMEDIATELY ---
private _groupProfile = ["ADD", units _assaultGroup] call ALIVE_fnc_createProfilesFromUnits;
private _profileID = [_groupProfile, "profileID"] call ALIVE_fnc_profileEntity;

// Ensure Hold Actions and Vcom disables are reapplied whenever ALiVE physically spawns the team leader
private _onSpawnCode = format [
"
    private _grp = group _this;
    _grp setVariable ['taskID', '%1', true];
    _grp setVariable ['Vcm_Disable', true, true]; // Disable Vcom during transport
    
    // Action 1: Mount Transport (Player must be in a vehicle)
    [
        _this,
        'Order Team: Mount Transport',
        '\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_loaddevice_ca.paa',
        '\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_loaddevice_ca.paa',
        '_this distance2D _target < 15 && vehicle _caller != _caller && (vehicle _caller) emptyPositions ''cargo'' >= count (units group _target)',
        '_caller distance2D _target < 15',
        {},
        {},
        {
            params ['_target', '_caller'];
            private _veh = vehicle _caller;
            private _grp = group _target;
            
            {
                _x assignAsCargo _veh;
                [_x] orderGetIn true;
            } forEach (units _grp);
            
            ['Transport', 'The assault team is boarding your vehicle.'] remoteExec ['BIS_fnc_showSubtitle', side (group _caller)];
            
            // CRITICAL: Prevent ALiVE from de-spawning the team while they are flying across the map in the transport
            _grp setVariable ['ALIVE_profileIgnore', true, true];
        },
        {},
        [],
        2,
        10,
        false,
        false
    ] remoteExec ['BIS_fnc_holdActionAdd', 0, _this];

    // Action 2: Dismount & Assault (Used when at the DZ)
    [
        _this,
        'Order Team: Dismount & Assault',
        '\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloaddevice_ca.paa',
        '\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloaddevice_ca.paa',
        'vehicle _target != _target && _this distance2D _target < 50',
        'true',
        {},
        {},
        {
            params ['_target', '_caller'];
            private _grp = group _target;
            
            {
                unassignVehicle _x;
                commandGetOut _x;
            } forEach (units _grp);
            
            ['Combat Drop', 'Assault team dismounting. Provide covering fire!'] remoteExec ['BIS_fnc_showSubtitle', side (group _caller)];
        },
        {},
        [],
        2,
        10,
        false,
        false
    ] remoteExec ['BIS_fnc_holdActionAdd', 0, _this];
", _taskID];

[_groupProfile, "onEachSpawn", _onSpawnCode] call ALIVE_fnc_profileEntity;


// --- 4. Create the Task ---
private _fuzzyLocation = _dropZonePos getPos [100 + random 200, random 360];
[
    [_taskSide, independent],
    _taskID,
    [
        format ["A heavily armed assault team is waiting at base. Load them into a transport vehicle and hot-drop them into the active OPFOR sector near grid %1. Payment wired upon successful insertion.", mapGridPosition _dropZonePos],
        "Contract: Combat Drop",
        "Insertion_Marker"
    ],
    _fuzzyLocation,
    "ASSIGNED",
    1,
    true,
    "land",
    true
] call BIS_fnc_taskCreate;

if (isNil "A3M_ActiveContracts") then { A3M_ActiveContracts = [] call ALiVE_fnc_hashCreate; };
[A3M_ActiveContracts, _taskID, [_taskID, "Insertion"]] call ALiVE_fnc_hashSet;

// --- 5. The CBA Per-Frame Handler (No Native Triggers) ---
[{
    params ["_args", "_handle"];
    _args params ["_taskID", "_profileID", "_dropZonePos"];

    // 1. Task State Check
    private _taskState = [_taskID] call BIS_fnc_taskState;
    if (_taskState == "SUCCEEDED" || _taskState == "CANCELED" || _taskState == "FAILED") exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    // 2. Profile Existence Check (Virtual Death)
    private _profileData = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
    if (isNil "_profileData") exitWith {
        [_taskID, 'FAILED', true] call BIS_fnc_taskSetState;
        ["Contract Failed", "The assault team was wiped out!"] remoteExec ["BIS_fnc_showSubtitle", 0];
        diag_log format ['[A3M Contracts] Insertion Task %1 FAILED (Team Killed Virtually).', _taskID];
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    // 3. Physical State & Distance Check
    private _leaderEntity = [_profileData, "entity"] call ALIVE_fnc_profileEntity;
    if (!isNil "_leaderEntity" && {!isNull _leaderEntity}) then {
        
        // Physical Death Check
        if (!alive _leaderEntity) exitWith {
             [_taskID, 'FAILED', true] call BIS_fnc_taskSetState;
             ["Contract Failed", "The assault team leader was killed in action!"] remoteExec ["BIS_fnc_showSubtitle", 0];
             diag_log format ['[A3M Contracts] Insertion Task %1 FAILED (Leader Killed Physically).', _taskID];
             [_handle] call CBA_fnc_removePerFrameHandler;
        };
        
        // Arrival Check (Leader is within 150m of Drop Zone)
        if (_leaderEntity distance2D _dropZonePos < 150) then {
            [_taskID, 'SUCCEEDED', true] call BIS_fnc_taskSetState;
            
            // Payout to all players within 300m of the drop (the pilots/escorts)
            private _reward = 150000;
            {
                if (isPlayer _x && {alive _x} && {_x distance2D _dropZonePos < 300}) then {
                    [_x, _reward] remoteExecCall ['grad_moneymenu_fnc_addFunds', _x];
                    ['Contract Complete', format ['Transferred %1c for successful insertion.', _reward]] remoteExec ['BIS_fnc_showSubtitle', _x];
                };
            } forEach playableUnits;
            
            // Force the AI to assault the sector
            private _grp = group _leaderEntity;
            {
                unassignVehicle _x;
                commandGetOut _x;
            } forEach (units _grp);
            
            // Re-enable Vcom and ALiVE Profiling so they can fight the sector natively as a virtualized force
            _grp setVariable ["Vcm_Disable", false, true];
            _grp setVariable ["ALIVE_profileIgnore", false, true];
            _grp setBehaviour 'COMBAT';
            
            private _wp = _grp addWaypoint [_dropZonePos, 0];
            _wp setWaypointType 'SAD';
            
            diag_log format ['[A3M Contracts] Insertion Task %1 SUCCEEDED.', _taskID];
            [_handle] call CBA_fnc_removePerFrameHandler;
        };
    };
}, 2, [_taskID, _profileID, _dropZonePos]] call CBA_fnc_addPerFrameHandler;
