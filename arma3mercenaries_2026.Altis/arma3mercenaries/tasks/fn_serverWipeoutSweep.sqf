/*
    arma3mercenaries\tasks\fn_serverDroneSweep.sqf
    Executes on the dedicated server to securely find the HVT, spawn the Greyhawk UAV, and hand off remote control.
*/
params ["_taskId", "_client", "_cost"];

if (!isServer) exitWith {};

private _exactPos = [0,0,0];
private _isPlayerTarget = false;

if (_taskId select [0, 7] == "PLAYER_") then {
    _isPlayerTarget = true;
    private _uid = _taskId select [7];
    {
        if (getPlayerUID _x == _uid) exitWith { _exactPos = getPosASL _x; };
    } forEach allPlayers;
} else {
    private _hvtTarget = objNull;
    if (!isNil "A3M_ActiveTasks") then {
        private _taskData = A3M_ActiveTasks getOrDefault [_taskId, []];
        if (count _taskData > 0) then {
            _hvtTarget = _taskData select 0;
        };
    };
    if (!isNull _hvtTarget && alive _hvtTarget) then {
        _exactPos = getPosATL _hvtTarget;
        [_taskId, _exactPos] remoteExec ["BIS_fnc_taskSetDestination", 0, "JIP_id_" + _taskId];
    };
};

if (_exactPos isEqualTo [0,0,0]) exitWith {
    private _msg = "<t align='left'><t size='0.8' color='#FF0000'>STRIKE FAILED</t><br/><t size='0.6' color='#FFFFFF'>Target signal lost or KIA.</t></t>";
    [_msg, 0.0, 0.1, 5, 0.5, 0, 795] remoteExec ["BIS_fnc_dynamicText", _client];
};

// Deduct Funds from the specific client
[_client, -_cost, true] remoteExecCall ["grad_moneymenu_fnc_addFunds", _client];

// Create A-164 Wipeout CAS
private _spawnPos2D = _exactPos getPos [3000, random 360];
private _spawnPos = [_spawnPos2D select 0, _spawnPos2D select 1, 1000];
private _vehArray = [_spawnPos, _spawnPos getDir _exactPos, "B_Plane_CAS_01_dynamicLoadout_F", civilian] call BIS_fnc_spawnVehicle;
private _drone = _vehArray select 0;
private _crew = _vehArray select 1;
private _grp = _vehArray select 2;

// Configure AI to prioritize engaging
_grp setBehaviour "COMBAT";
_grp setCombatMode "RED";
_drone flyInHeight 500; // Lower altitude for better strafing runs

// Replace useless Anti-Air (AA) missiles on wingtips with extra 82mm HE Rocket Pods
_drone setPylonLoadout [1, "PylonRack_7Rnd_Rocket_04_HE_F", true];
_drone setPylonLoadout [10, "PylonRack_7Rnd_Rocket_04_HE_F", true];

// Dynamic Targeting Thread to force continuous strafing runs
[_drone, _grp, _exactPos] spawn {
    params ["_drone", "_grp", "_exactPos"];
    private _endTime = time + 300; // 5 minutes
    
    while {alive _drone && time < _endTime} do {
        private _enemies = (_exactPos nearEntities [["Man", "Car", "Tank", "StaticWeapon"], 800]) select {side _x != civilian && side _x != side _grp && alive _x};
        
        // Clear old waypoints to force fresh pathing
        while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
        
        if (count _enemies > 0) then {
            // Sort by distance to exactPos so it focuses on the objective area
            _enemies = _enemies apply { [_x distance2D _exactPos, _x] };
            _enemies sort true;
            private _target = (_enemies select 0) select 1;
            
            _grp reveal [_target, 4];
            
            // Attach a literal DESTROY waypoint to the unit to force an attack run
            private _wp = _grp addWaypoint [getPos _target, 0];
            _wp waypointAttachVehicle _target;
            _wp setWaypointType "DESTROY";
            _wp setWaypointCombatMode "RED";
            _wp setWaypointBehaviour "COMBAT";
        } else {
            // No targets left, loiter low to look for more
            private _wp = _grp addWaypoint [_exactPos, 0];
            _wp setWaypointType "LOITER";
            _wp setWaypointLoiterRadius 1000;
        };
        
        sleep 25; // Re-evaluate and trigger a new pass every 25 seconds
    };
};

// Provide cinematic camera feed to the client
[_drone, _taskId, _exactPos] remoteExec ["A3M_fnc_clientCameraFeed", _client];
// Server-Side Cleanup Thread
[_drone, _crew, _grp] spawn {
    params ["_drone", "_crew", "_grp"];
    sleep 305; // 5 minute duration + 5 seconds for connection sequence
    
    if (alive _drone) then {
        // Tell the drone to fly away
        _grp setBehaviour "CARELESS";
        private _rtbPos = (getPos _drone) getPos [5000, random 360];
        private _wpRTB = _grp addWaypoint [_rtbPos, 0];
        _grp setCurrentWaypoint _wpRTB;
        
        sleep 60; // Let it fly away off-screen
    };
    
    {deleteVehicle _x} forEach _crew;
    if (!isNull _drone) then { deleteVehicle _drone; };
    if (!isNull _grp) then { deleteGroup _grp; };
};
