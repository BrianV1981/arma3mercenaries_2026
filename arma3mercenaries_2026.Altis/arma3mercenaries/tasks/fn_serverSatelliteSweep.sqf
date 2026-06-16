/*
    arma3mercenaries\tasks\fn_serverSatelliteSweep.sqf
    Executes on the dedicated server to securely find the HVT and send the feed back to the client.
*/
params ["_taskId", "_client", "_cost"];

if (!isServer) exitWith {};

// Find the HVT object natively using Arma 3's task system instead of the HashMap
private _hvtTarget = objNull;

{
    private _group = _x;
    {
        private _unit = _x;
        // We can find the unit by checking if they are the target of the specific task
        // Or simply by checking the A3M_ActiveTasks
        if (!isNil "A3M_ActiveTasks") then {
            private _taskData = A3M_ActiveTasks getOrDefault [_taskId, []];
            if (count _taskData > 0) then {
                _hvtTarget = _taskData select 0;
            };
        };
    } forEach units _group;
} forEach allGroups;

// Wait, the A3M_ActiveTasks hashmap STILL EXISTS perfectly on the Server!
// The server has the direct pointer to the object.
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

// Get the actual exact position from the server where the object is guaranteed to be known
private _exactPos = getPosATL _hvtTarget;

// Broadcast the last sweep time for the global cooldown
missionNamespace setVariable ["A3M_HVT_Satellite_LastSweepTime", time, true];

// Update the task destination to the exact position for everyone
[_taskId, _exactPos] remoteExec ["BIS_fnc_taskSetDestination", 0, "JIP_id_" + _taskId];

// Deduct Funds from the specific client
[_client, -_cost, true] remoteExecCall ["grad_moneymenu_fnc_addFunds", _client];

// Tell the client to start the visual drone feed
[_exactPos, _taskId] remoteExec ["A3M_fnc_clientSatelliteFeed", _client];

// Force ALiVE Virtual AI to uncache the guards using the native ALiVE API
if (!isNil "ALIVE_fnc_forceSpawnRadius") then {
    [_exactPos, 800] call ALIVE_fnc_forceSpawnRadius;
};

// Spawn a timer to re-enable virtualization after the satellite sweep ends
[_exactPos] spawn {
    params ["_exactPos"];
    sleep 65; // Matches the 60s satellite duration + buffer
    if (!isNil "ALIVE_fnc_forceDespawnRadius") then {
        [_exactPos, 800] call ALIVE_fnc_forceDespawnRadius;
    };
};
