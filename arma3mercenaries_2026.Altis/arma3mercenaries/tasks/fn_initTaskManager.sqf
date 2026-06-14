/*
    arma3mercenaries\tasks\fn_initTaskManager.sqf
    Description: Initializes the global Task State Machine and PFH loop.
*/
if (!isServer) exitWith {};

if (isNil "A3M_ActiveTasks") then {
    A3M_ActiveTasks = createHashMap;
    diag_log "[A3M TASK MANAGER] Initialized A3M_ActiveTasks HashMap.";
};

// Start the unscheduled Task Tracker PFH
// Ticks every 1800 seconds (30 minutes) to update task destinations and prune dead/completed tasks without spamming players
[{
    params ["_args", "_handle"];
    
    private _tasksToRemove = [];
    
    {
        private _taskId = _x;
        private _taskData = _y; // [HVT Object, Task Type]
        
        _taskData params ["_hvtObj", "_taskType"];
        
        // Validity Check
        if (isNull _hvtObj || {!alive _hvtObj}) then {
            _tasksToRemove pushBack _taskId;
        } else {
            // Task State Check
            private _taskState = _taskId call BIS_fnc_taskState;
            if (!(_taskState in ["ASSIGNED", "CREATED"])) then {
                _tasksToRemove pushBack _taskId;
            } else {
                // Update Destination
                [_taskId, getPosATL _hvtObj] call BIS_fnc_taskSetDestination;
            };
        };
    } forEach A3M_ActiveTasks;
    
    // Cleanup Phase
    {
        A3M_ActiveTasks deleteAt _x;
        diag_log format ["[A3M TASK MANAGER] Cleaned up task %1.", _x];
    } forEach _tasksToRemove;
    
}, 1800, []] call CBA_fnc_addPerFrameHandler;