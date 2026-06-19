/*
    Author: A.I.M.
    File: fn_initALiVERewards.sqf
    Description:
    Listens to ALiVE task events and handles reward distribution securely by verifying player participation.
    Also tracks kills to reward players for artillery and drone strikes that complete the task.
*/

if (!isServer) exitWith {};

// Wait for ALiVE to initialize
[] spawn {
    waitUntil {!isNil "ALiVE_eventLog" && !isNil "ALIVE_taskHandler"};

    if (isNil "A3M_PaidTasks") then { A3M_PaidTasks = []; };
    if (isNil "A3M_TaskContributions") then { A3M_TaskContributions = []; };

    // 1. THE COMBAT ATTRIBUTION TRACKER
    // Tracks when a player (or their drone/artillery) kills an entity inside an active task zone
    addMissionEventHandler ["EntityKilled", {
        params ["_killed", "_killer", "_instigator"];
        
        // Was the killer a human? (Checks direct fire, artillery, and UAV control)
        private _isPlayerKill = false;
        if (isPlayer _instigator) then { _isPlayerKill = true; };
        if (!_isPlayerKill && isPlayer _killer) then { _isPlayerKill = true; };
        if (!_isPlayerKill && {!isNull _killer && {UAVControl vehicle _killer select 1 != ""}}) then { _isPlayerKill = true; };
        
        if (_isPlayerKill) then {
            private _killPos = getPosATL _killed;
            
            // Loop through active ALiVE tasks and flag them if the kill was inside
            private _tasks = [ALIVE_taskHandler, "tasks"] call ALIVE_fnc_hashGet;
            if (!isNil "_tasks") then {
                {
                    private _taskID = _x;
                    private _taskData = [_tasks, _taskID] call ALIVE_fnc_hashGet;
                    if (!isNil "_taskData") then {
                        private _taskPos = _taskData select 3;
                        if (_taskPos isEqualType [] && {count _taskPos >= 2}) then {
                            // If player kills something within 600m of the objective, flag it!
                            if (_killPos distance2D _taskPos <= 600) then {
                                A3M_TaskContributions pushBackUnique _taskID;
                            };
                        };
                    };
                } forEach (_tasks select 1);
            };
        };
    }];

    // 2. THE REWARD DISPATCHER
    private _fnc_customReward = {
        params ["_logic","_operation","_args"];
        if (_operation == "handleEvent") then {
            _args params ["_id", "_eventData"];
            
            // AGGRESSIVE DEBUG: Log every TASK_UPDATE event to see exactly what ALiVE sends
            diag_log format ["[A3M REWARD DEBUG] Event: %1 | Raw Data: %2", _id, _eventData];
            
            if (_id == "TASK_UPDATE") then {
                
                private _taskID = _eventData param [0, ""];
                private _taskSide = _eventData param [2, ""];
                private _taskPos = _eventData param [3, [0,0,0]];
                private _taskState = _eventData param [8, ""];

                diag_log format ["[A3M REWARD DEBUG] Task %1 State is now: %2", _taskID, _taskState];

                if (_taskState == "Succeeded" && {!(_taskID in A3M_PaidTasks)}) then {
                    
                    // Did a player get near it, OR did a player drop bombs on it?
                    private _playersPresent = allPlayers select { alive _x && {(_x distance2D _taskPos) <= 1000} };
                    private _playerContributed = (_taskID in A3M_TaskContributions);

                    diag_log format ["[A3M REWARD DEBUG] Task %1 Succeeded! Players Present: %2 | Player Contributed: %3", _taskID, count _playersPresent, _playerContributed];

                    if ((count _playersPresent > 0) || _playerContributed) then {
                        
                        A3M_PaidTasks pushBack _taskID;
                        publicVariable "A3M_PaidTasks";
                        
                        private _rewardAmount = missionNamespace getVariable ["A3M_ALiVE_RewardAmount", 10000];
                        private _rewardDist = missionNamespace getVariable ["A3M_ALiVE_RewardDistribution", 0];

                        diag_log format ["[A3M REWARD DEBUG] Distributing $%1 to eligible players...", _rewardAmount];
                        
                        {
                            if (isPlayer _x && alive _x) then {
                                private _eligible = false;
                                
                                switch (_rewardDist) do {
                                    case 0: {
                                        // Reward Side
                                        if (str(side _x) == _taskSide) then { _eligible = true; };
                                    };
                                    case 1: {
                                        // Reward Side + Allies (Treats WEST and GUER as allies for Syndikat/FIA)
                                        private _pSide = str(side _x);
                                        if (_pSide == _taskSide) then { _eligible = true; }
                                        else {
                                            if ((_taskSide == "WEST" && _pSide == "GUER") || (_taskSide == "GUER" && _pSide == "WEST")) then { _eligible = true; };
                                        };
                                    };
                                    case 2: {
                                        // Players Involved Only
                                        if (_x in _playersPresent) then { _eligible = true; }
                                        else {
                                            private _assignedPlayers = _eventData param [7, []]; // [[UIDs], [Names]]
                                            private _assignedUIDs = _assignedPlayers param [0, []];
                                            if (getPlayerUID _x in _assignedUIDs) then { _eligible = true; };
                                        };
                                    };
                                };

                                if (_eligible) then {
                                    diag_log format ["[A3M REWARD DEBUG] Paying Player: %1", name _x];
                                    [_x, _rewardAmount, false] call grad_moneymenu_fnc_addFunds;
                                    
                                    // A3M Dynamic Text HUD Notification
                                    private _formattedReward = [_rewardAmount, 1, 0, true] call CBA_fnc_formatNumber;
                                    private _msg = format [
                                        "<t align='center'><t size='1.0' color='#FFFFFF'>ALiVE TASK COMPLETED</t><br/><t size='0.8' color='#FFFFFF'>Mercenary Payout: </t><t size='0.8' color='#00FF00'>$%1</t></t>",
                                        _formattedReward
                                    ];
                                    [_msg, -1, 0.8, 5, 0.5, 0, 789] remoteExec ["BIS_fnc_dynamicText", _x];
                                };
                            };
                        } forEach playableUnits;

                    } else {
                        diag_log format ["[A3M REWARD DEBUG] ALiVE Task %1 succeeded by AI. No player presence or combat attribution. Reward denied.", _taskID];
                    };
                };
            };
        };
    };

    // Register listener for TASK_UPDATE
    _listener = [nil,"create"] call ALiVE_fnc_baseClass;
    _listener setVariable ["class", _fnc_customReward];
    [ALiVE_eventLog, "addListener", [_listener, ["TASK_UPDATE"]]] call ALIVE_fnc_eventLog;
    
    // --- 3. THE FALLBACK TASK MONITOR ---
    // If ALiVE_eventLog is dropping events, this loop catches task successes directly from the hashmap.
    [_listener, _fnc_customReward] spawn {
        params ["_listener", "_fnc_customReward"];
        while {true} do {
            sleep 10;
            if (!isNil "ALIVE_taskHandler") then {
                private _tasks = [ALIVE_taskHandler, "tasks"] call ALIVE_fnc_hashGet;
                if (!isNil "_tasks") then {
                    {
                        private _taskID = _x;
                        if (!(_taskID in A3M_PaidTasks)) then {
                            private _taskData = [_tasks, _taskID] call ALIVE_fnc_hashGet;
                            if (!isNil "_taskData") then {
                                private _taskState = _taskData param [8, ""];
                                if (_taskState == "Succeeded") then {
                                    diag_log format ["[A3M REWARD FALLBACK] Caught SUCCESS state for Task %1 directly from Hashmap! Data: %2", _taskID, _taskData];
                                    // Trigger the event manually if the listener missed it
                                    [_listener, "handleEvent", ["TASK_UPDATE", _taskData]] call _fnc_customReward;
                                };
                            };
                        };
                    } forEach (_tasks select 1);
                };
            };
        };
    };
    
    diag_log "[A3M DEBUG] ALiVE Reward Listener Initialized with Fallback Monitor!";
};
