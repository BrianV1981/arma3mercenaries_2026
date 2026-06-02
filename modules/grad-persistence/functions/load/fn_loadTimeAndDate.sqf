#include "script_component.hpp"

if (!isServer) exitWith {};

private _missionTag = [] call FUNC(getMissionTag);
private _timeAndDateTag = _missionTag + "_timeAndDate";

// --- A.I.M. v812+ Architecture: Direct SQLite Load ---
private _date = [_timeAndDateTag, []] call A3M_fnc_dbGetSecure;

if (count _date > 0) then {
    setDate _date;
};
