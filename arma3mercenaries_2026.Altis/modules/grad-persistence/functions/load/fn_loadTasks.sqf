#include "script_component.hpp"

if (!isServer) exitWith {};

private _missionTag = [] call FUNC(getMissionTag);
private _tasksTag = _missionTag + "_tasks";

// --- A.I.M. v812+ Architecture: SQLite Per-Entity Loading ---
private _countKey = format ["%1_COUNT", _tasksTag];
private _dbCount = [_countKey, -1, false] call A3M_fnc_dbGetSecure;

private _tasksData = [];

if (_dbCount > -1) then {
    // New Iterative Architecture
    for "_i" from 0 to (_dbCount - 1) do {
        private _uniqueEntityKey = format ["%1_task_%2", _tasksTag, _i];
        // Fetch array from SQLite
        private _entityData = [_uniqueEntityKey, [], false] call A3M_fnc_dbGetSecure;
        
        if (count _entityData > 0) then {
            _tasksData pushBack _entityData;
        };
    };
};

{
    _x call BIS_fnc_setTask;
} forEach _tasksData;
