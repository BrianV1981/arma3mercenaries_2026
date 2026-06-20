/*
    Author: A.I.M.
    File: fn_aliveGuardrails.sqf
    Description:
    The "A3M Sovereign Commander" Daemon (Geofenced Tether Version).
    Periodically sweeps active ALiVE tasks and identifies AI groups of the attacking/defending side.
    Implements a strict 300m Geofence around the objective:
    - Inside 300m: Vcom is FULLY ACTIVE. The AI will flank, suppress, and use advanced movement.
    - Outside 300m: Vcom is DISABLED. The AI drops everything and sprints directly back to the objective.
*/

if (!isServer) exitWith {};

[] spawn {
    waitUntil {!isNil "ALIVE_taskHandler"};
    
    diag_log "[A3M SOVEREIGN] Geofenced Tether Daemon initialized. Waiting for tasks...";
    
    while {true} do {
        sleep 30; // Increased sweep rate to 30s to catch them before they get too far
        
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
                                // Find all groups of this side within 1500m of the objective
                                private _nearGroups = allGroups select {
                                    side _x == _taskSide 
                                    && {alive leader _x}
                                    && {isPlayer (leader _x) == false} // Don't hijack player groups
                                    && {(leader _x distance2D _taskPos) < 1500}
                                };
                                
                                {
                                    private _group = _x;
                                    private _distance = (leader _group) distance2D _taskPos;
                                    
                                    // Always lock down fleeing and radio rescue
                                    _group setVariable ["VCM_NORESCUE", true, true];
                                    { _x allowFleeing 0; } forEach (units _group);
                                    
                                    // ============================================
                                    // THE GEOFENCED TETHER LOGIC
                                    // ============================================
                                    if (_distance <= 300) then {
                                        // 🟢 INSIDE THE SAFE ZONE: Vcom Active
                                        if (_group getVariable ["Vcm_Disable", false]) then {
                                            _group setVariable ["Vcm_Disable", false, true];
                                            diag_log format ["[A3M SOVEREIGN] Group %1 entered Safe Zone for Task %2. Vcom tactical systems RE-ENGAGED.", _group, _taskID];
                                        };
                                        
                                        // We don't mess with their waypoints here, let Vcom handle the close-quarters fight
                                        
                                    } else {
                                        // 🔴 OUTSIDE THE SAFE ZONE: Vcom Lobotomized
                                        if (!(_group getVariable ["Vcm_Disable", false])) then {
                                            _group setVariable ["Vcm_Disable", true, true];
                                            diag_log format ["[A3M SOVEREIGN] Group %1 breached 300m Tether for Task %2! Vcom DISABLED. Forcing retreat to objective.", _group, _taskID];
                                        };
                                        
                                        // Force them back
                                        while {(count (waypoints _group)) > 0} do {
                                            deleteWaypoint ((waypoints _group) select 0);
                                        };
                                        
                                        private _wp = _group addWaypoint [_taskPos, 0];
                                        _wp setWaypointType "MOVE"; // Just sprint back, ignore enemies if possible
                                        _wp setWaypointBehaviour "AWARE";
                                        _wp setWaypointCombatMode "YELLOW"; // Fire back, but keep moving
                                        _wp setWaypointSpeed "FULL";
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
