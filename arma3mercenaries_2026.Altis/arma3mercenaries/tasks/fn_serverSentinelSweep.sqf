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

// Create UCAV Sentinel High Above Target
private _spawnPos = [_exactPos select 0, _exactPos select 1, 800];
private _vehArray = [_spawnPos, random 360, "B_UAV_05_F", civilian] call BIS_fnc_spawnVehicle;
private _drone = _vehArray select 0;
private _crew = _vehArray select 1;
private _grp = _vehArray select 2;

createVehicleCrew _drone; // Ensure Arma 3 UAV AI is properly linked to the vehicle terminal

// Equip Sentinel with 6x Scalpel AGMs so the Gunner can fire them directly! (Fixes the GBU release issue)
_drone setPylonLoadOut [1, "PylonRack_3Rnd_LG_scalpel"];
_drone setPylonLoadOut [2, "PylonRack_3Rnd_LG_scalpel"];

// Configure AI to prioritize flying over engaging
_grp setBehaviour "CARELESS";
_grp setCombatMode "BLUE";
_drone flyInHeight 800;

// Create Loiter Waypoint
private _wp = _grp addWaypoint [_exactPos, 0];
_wp setWaypointType "LOITER";
_wp setWaypointLoiterRadius 600;
_wp setWaypointLoiterType "CIRCLE_L";

// Tell the client to remote control the AI Gunner
private _gunner = gunner _drone;
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
