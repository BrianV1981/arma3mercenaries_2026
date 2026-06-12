#include "script_component.hpp"

if (!isServer) exitWith {};

private _missionTag = [] call FUNC(getMissionTag);
private _timeAndDateTag = _missionTag + "_timeAndDate";

// --- A.I.M. v812+ Architecture: Direct SQLite Save ---
[_timeAndDateTag, date] call A3M_fnc_dbSetSecure;
