/*
    Author: A.I.M.
    File: fn_aliveGuardrails.sqf
    Description:
    The "A3M Sovereign Commander" Daemon.
    Periodically sweeps active ALiVE tasks, identifies near AI groups of the attacking/defending side,
    seizes control of them from VCOM and OPCOM, and aggressively forces them to the objective.
*/

if (!isServer) exitWith {};

[] spawn {
    waitUntil {!isNil "ALIVE_taskHandler"};
    
    diag_log "[A3M SOVEREIGN] Guardrails Daemon initialized. Waiting for tasks...";
    
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
                                    
                                    // 1. SEIZE CONTROL (Vcom Disable)
                                    _group setVariable ["Vcm_Disable", true, true];
                                    
                                    // Disable fleeing so they don't break off the attack
                                    { _x allowFleeing 0; } forEach (units _group);
                                    
                                    // 2. PURGE WAYPOINTS (Overwrite OPCOM)
                                    while {(count (waypoints _group)) > 0} do {
                                        deleteWaypoint ((waypoints _group) select 0);
                                    };
                                    
                                    // 3. FORCE AGGRESSIVE MANEUVER
                                    private _wp = _group addWaypoint [_taskPos, 0];
                                    
                                    // Determine tactics based on task title
                                    private _isDefend = (["Defend", _taskTitle] call BIS_fnc_inString) || (["Hold", _taskTitle] call BIS_fnc_inString);
                                    
                                    if (_isDefend) then {
                                        _wp setWaypointType "GUARD";
                                        _wp setWaypointBehaviour "AWARE";
                                        _wp setWaypointCombatMode "YELLOW";
                                    } else {
                                        _wp setWaypointType "SAD"; // Search and Destroy
                                        _wp setWaypointBehaviour "AWARE";
                                        _wp setWaypointCombatMode "RED"; // Fire at will, aggressive
                                        _wp setWaypointSpeed "FULL"; // Rush the objective!
                                    };
                                    
                                    // We don't spam the log for every group every 60s, but we can log unique seizures
                                    if (!(_group getVariable ["A3M_GuardrailLogged", false])) then {
                                        diag_log format ["[A3M SOVEREIGN] Seized Group %1. VCOM Disabled. Forced %2 Waypoint on Task %3.", _group, waypointType _wp, _taskID];
                                        _group setVariable ["A3M_GuardrailLogged", true];
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
