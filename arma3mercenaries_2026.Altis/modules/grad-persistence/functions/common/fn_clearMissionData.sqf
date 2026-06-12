#include "script_component.hpp"

params ["_missionTag",["_worldName",worldName]];

if (!isServer) exitWith {};

private _isThisMission = false;
private _actualTag = if (isNil "_missionTag") then {
    _isThisMission = true;
    [] call FUNC(getMissionTag)
} else {
    _isThisMission = _missionTag == ([missionConfigFile >> "CfgGradPersistence", "missionTag", ""] call BIS_fnc_returnConfigEntry);
    [_missionTag] call FUNC(getMissionTag)
};

if (_isThisMission) then {
    ("Players will no longer be saved on disconnect.") remoteExec ["systemChat",0,false];
    missionNamespace setVariable [QGVAR(thisMissionCleared),true];
};

// --- A.I.M. v812+ Architecture: SQLite Full Wipe ---
// We send a special 'delete_like' command to the Rust bridge to wipe all rows 
// where the key starts with the mission tag.
private _sqlDeletePattern = format ["%1_%%", _actualTag]; 
"a3m_db_core" callExtension ["delete_like", [_sqlDeletePattern]];

INFO_1("SQLite Mission data for missiontag %1 deleted.",_actualTag);
(format ["SQLite Mission data for missiontag %1 deleted.",_actualTag]) remoteExec ["systemChat",0,false];
