#include "script_component.hpp"

if (!isServer) exitWith {};

private _missionTag = [] call FUNC(getMissionTag);
private _varsTag = _missionTag + "_vars";

// --- A.I.M. v812+ Architecture: SQLite Per-Entity Loading ---
private _indexKey = format ["%1_INDEX", _varsTag];
private _dbIndexList = [_indexKey, []] call A3M_fnc_dbGetSecure;

private _varsData = [];

if (count _dbIndexList > 0) then {
    {
        private _uniqueEntityKey = _x;
        // Fetch native HashMap. Note the 'true' parameter for HashMap reconstruction.
        private _entityHash = [_uniqueEntityKey, createHashMap, true] call A3M_fnc_dbGetSecure;
        
        if (count _entityHash > 0) then {
            _varsData pushBack _entityHash;
        };
    } forEach _dbIndexList;
};

{
    private _thisVarsHash = _x;
    private _varName = _thisVarsHash getOrDefault ["varName", ""];
    private _value = _thisVarsHash getOrDefault ["value", nil];
    private _isPublic = _thisVarsHash getOrDefault ["public", false];

    if (_varName != "" && !isNil "_value") then {
        missionNamespace setVariable [_varName,_value,_isPublic];
    };

} forEach _varsData;
