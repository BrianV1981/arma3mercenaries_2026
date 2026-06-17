/*
    arma3mercenaries\tasks\fn_serverBlackfishSweep.sqf
    Executes on the dedicated server to securely find the HVT and send the feed back to the client.
*/
params ["_taskId", "_client", "_cost"];

if (!isServer) exitWith {};

private _hvtTarget = objNull;
if (!isNil "A3M_ActiveTasks") then {
    private _taskData = A3M_ActiveTasks getOrDefault [_taskId, []];
    if (count _taskData > 0) then {
        _hvtTarget = _taskData select 0;
    };
};

if (isNull _hvtTarget || !alive _hvtTarget) exitWith {
    private _msg = "<t align='left'><t size='0.8' color='#FF0000'>SWEEP FAILED</t><br/><t size='0.6' color='#FFFFFF'>Target signal lost or KIA.</t></t>";
    [_msg, 0.0, 0.1, 5, 0.5, 0, 795] remoteExec ["BIS_fnc_dynamicText", _client];
};

private _exactPos = getPosATL _hvtTarget;
[_taskId, _exactPos] remoteExec ["BIS_fnc_taskSetDestination", 0, "JIP_id_" + _taskId];
[_client, -_cost, true] remoteExecCall ["grad_moneymenu_fnc_addFunds", _client];
[_exactPos, _taskId] remoteExec ["A3M_fnc_clientBlackfishFeed", _client];
