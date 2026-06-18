/*
    arma3mercenaries\tasks\fn_serverSatelliteSweep.sqf
    Executes on the dedicated server to securely find the HVT and send the feed back to the client.
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

// Tell the client to start the visual drone feed and teleport their physical body to trigger ALiVE
[_exactPos, _taskId] remoteExec ["A3M_fnc_clientSatelliteFeed", _client];
