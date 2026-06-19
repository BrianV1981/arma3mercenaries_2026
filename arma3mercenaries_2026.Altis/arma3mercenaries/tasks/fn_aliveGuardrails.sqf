/*
    Author: A.I.M.
    File: fn_aliveGuardrails.sqf
    Description:
    The "A3M Sovereign Commander" Daemon (Soft Guardrails Version).
    Periodically sweeps active ALiVE tasks and identifies AI groups of the attacking/defending side.
    Selectively disables VCOM's "Call for Backup" so they stay on objective, 
    and issues tactical waypoint nudges to keep them focused on the task.
*/

if (!isServer) exitWith {};

[] spawn {
    waitUntil {!isNil "ALIVE_taskHandler"};
    
    diag_log "[A3M SOVEREIGN] Soft Guardrails Daemon initialized. Waiting for tasks...";
    
    while {true} do {
        sleep 60; // Sweep every 60 seconds
        
        if (!isNil "ALIVE_taskHandler") then {
            private _tasks = [ALIVE_taskHandler, "tasks"] call ALIVE_fnc_hashGet;
            if (!isNil "_tasks") then {
                {
                    private _taskID = _x;
                    private _taskData = [_tasks, _taskID] call ALIVE_fnc_hashGet;
                    if (!isNil "_taskData") then {
                        private _taskSideStr = _taskData param [2, ""];
                        private _taskPos = _taskData param [3, [0,0,0]];
                        private _taskTitle = _taskData param [5, ""];
                        private _taskState = _taskData param [8, ""];
                        
                        if (_taskState == "Assigned" || _taskState == "Created") then {
                            
                            // Convert ALiVE side string to native Arma 3 side
                            private _taskSide = sideUnknown;
                            if (_taskSideStr == "WEST") then { _taskSide = west; };
                            if (_taskSideStr == "EAST") then { _taskSide = east; };
                            if (_taskSideStr == "GUER") then { _taskSide = independent; };
                            
                            if (_taskSide != sideUnknown) then {
                                // Find all groups of this side within 2000m of the objective
                                private _nearGroups = allGroups select {
                                    side _x == _taskSide 
                                    && {alive leader _x}
                                    && {isPlayer (leader _x) == false} // Don't hijack player groups!
                                    && {(leader _x distance2D _taskPos) < 2000}
                                };
                                
                                {
                                    private _group = _x;
                                    
                                    // 1. SELECTIVE VCOM OVERRIDE (Soft Guardrail)
                                    // Disable their ability to respond to distant calls for backup from other squads
                                    _group setVariable ["VCM_NORESCUE", true, true];
                                    
                                    // Disable fleeing so they fight to the death on objective
                                    { _x allowFleeing 0; } forEach (units _group);
                                    
                                    // 2. THE TACTICAL NUDGE
                                    // If they have wandered more than 300m from the objective, wipe waypoints and nudge them back
                                    if ((leader _group distance2D _taskPos) > 300) then {
                                        
                                        while {(count (waypoints _group)) > 0} do {
                                            deleteWaypoint ((waypoints _group) select 0);
                                        };
                                        
                                        private _wp = _group addWaypoint [_taskPos, 0];
                                        
                                        private _isDefend = (["Defend", _taskTitle] call BIS_fnc_inString) || (["Hold", _taskTitle] call BIS_fnc_inString);
                                        
                                        if (_isDefend) then {
                                            _wp setWaypointType "GUARD";
                                            _wp setWaypointBehaviour "AWARE";
                                        } else {
                                            _wp setWaypointType "SAD"; // Search and Destroy
                                            _wp setWaypointBehaviour "AWARE";
                                        };
                                        
                                        if (!(_group getVariable ["A3M_NudgeLogged", false])) then {
                                            diag_log format ["[A3M SOVEREIGN] Nudged Group %1 back to Task %2. VCM_NORESCUE activated.", _group, _taskID];
                                            _group setVariable ["A3M_NudgeLogged", true];
                                        };
                                    };
                                    
                                } forEach _nearGroups;
                            };
                        };
                    };
                } forEach (_tasks select 1);
            };
        };
    };
};
