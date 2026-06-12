#include "script_component.hpp"

if (!isServer) exitWith {};

private _missionTag = [] call FUNC(getMissionTag);
private _tasksTag = _missionTag + "_tasks";

// find all tasks - also, wtf BIS
private _allTasks = [];
private _maybeTaskVars = (allVariables missionNamespace) select {(_x find "@") == 0 && {_x find ".0" == (count _x) - 2}};
{
    _maybeTaskID = missionNamespace getVariable [_x,false];
    if (
        _maybeTaskID isEqualType "" &&
        {[_maybeTaskID] call BIS_fnc_taskExists}
    ) then {
        _allTasks pushBack _maybeTaskID
    };
} forEach _maybeTaskVars;

// select all tasks that are global and owned by side or everyone
private _allGlobalTasks = _allTasks select {
    _taskOwners = missionNamespace getVariable [format [
        "%1.3",[_x] call BIS_fnc_taskVar
    ],[]];

    (
        _taskOwners isEqualTo true ||
        (
            _taskOwners isEqualType [] &&
            {count (_taskOwners arrayIntersect [WEST,EAST,INDEPENDENT,CIVILIAN]) > 0}
        )
    )
};

// --- A.I.M. v812+ Architecture: DB Index Tracking ---
private _savedTasksCount = 0;

// save tasks
{
    _taskVar = [_x] call BIS_fnc_taskVar;
    _owners = missionNamespace getVariable [format ["%1.3",_taskVar],[]];
    _priority = missionNamespace getVariable [format ["%1.5",_taskVar],[]];

    private _thisTaskData = [
        [_x,_x call BIS_fnc_taskParent],
        _owners,
        [_x] call BIS_fnc_taskDescription,
        [_x] call BIS_fnc_taskDestination,
        [_x] call BIS_fnc_taskState,
        _priority,
        false,
        true,
        [_x] call BIS_fnc_taskType,
        false
    ];

    // --- A.I.M. Per-Entity Save Pipeline ---
    private _uniqueEntityKey = format ["%1_task_%2", _tasksTag, _savedTasksCount];
    [_uniqueEntityKey, _thisTaskData] call A3M_fnc_dbSetSecure;
    
    _savedTasksCount = _savedTasksCount + 1;
} forEach _allGlobalTasks;

// --- Save the COUNT integer ---
private _countKey = format ["%1_COUNT", _tasksTag];
[_countKey, _savedTasksCount] call A3M_fnc_dbSetSecure;

// ALSO delete the old INDEX array so we don't duplicate logic if mixing load systems
private _indexKey = format ["%1_INDEX", _tasksTag];
[_indexKey, []] call A3M_fnc_dbSetSecure;
