/*
    arma3mercenaries\tasks\fn_serverDroneSweep.sqf
    Executes on the dedicated server to securely find the HVT, spawn the Greyhawk UAV, and hand off remote control.
*/
params ["_taskId", "_client", "_cost"];

if (!isServer) exitWith {};

// Find the HVT object natively using Arma 3's task system instead of the HashMap
private _hvtTarget = objNull;

{
    private _group = _x;
    {
        private _unit = _x;
        if (!isNil "A3M_ActiveTasks") then {
            private _taskData = A3M_ActiveTasks getOrDefault [_taskId, []];
            if (count _taskData > 0) then {
                _hvtTarget = _taskData select 0;
            };
        };
    } forEach units _group;
} forEach allGroups;

if (!isNil "A3M_ActiveTasks") then {
    private _taskData = A3M_ActiveTasks getOrDefault [_taskId, []];
    if (count _taskData > 0) then {
        _hvtTarget = _taskData select 0;
    };
};

if (isNull _hvtTarget || !alive _hvtTarget) exitWith {
    private _msg = "<t align='left'><t size='0.8' color='#FF0000'>STRIKE FAILED</t><br/><t size='0.6' color='#FFFFFF'>Target signal lost or KIA.</t></t>";
    [_msg, 0.0, 0.1, 5, 0.5, 0, 795] remoteExec ["BIS_fnc_dynamicText", _client];
};

// Get the actual exact position from the server where the object is guaranteed to be known
private _exactPos = getPosATL _hvtTarget;

// Update the task destination to the exact position for everyone
[_taskId, _exactPos] remoteExec ["BIS_fnc_taskSetDestination", 0, "JIP_id_" + _taskId];

// Deduct Funds from the specific client
[_client, -_cost, true] remoteExecCall ["grad_moneymenu_fnc_addFunds", _client];

// Create A-164 Wipeout CAS
private _spawnPos = [_exactPos select 0, _exactPos select 1, 1000];
private _vehArray = [_spawnPos, random 360, "B_Plane_CAS_01_dynamicLoadout_F", civilian] call BIS_fnc_spawnVehicle;
private _drone = _vehArray select 0;
private _crew = _vehArray select 1;
private _grp = _vehArray select 2;

// Configure AI to prioritize flying over engaging
_grp setBehaviour "COMBAT";
_grp setCombatMode "RED";
_drone flyInHeight 1000;

// Create Loiter Waypoint
private _wp = _grp addWaypoint [_exactPos, 0];
_wp setWaypointType "LOITER";
_wp setWaypointLoiterRadius 1500;
_wp setWaypointLoiterType "CIRCLE_L";

// Tell the client to remote control the AI Pilot
private _gunner = driver _drone;
[_drone, _gunner, _taskId, _exactPos] remoteExec ["A3M_fnc_clientDroneFeed", _client];

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
