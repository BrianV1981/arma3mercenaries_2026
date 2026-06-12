#include "script_component.hpp"

params ["_allVariableClasses"];

private _missionTag = [] call FUNC(getMissionTag);
private _varsTag = _missionTag + "_vars";

// --- A.I.M. v812+ Architecture: DB Index Tracking ---
private _dbIndexList = [];

{
    private _varNamespace = [_x,"varNamespace",false] call BIS_fnc_returnConfigEntry;

    if (_varNamespace isEqualType "" && {_varNamespace == "mission"}) then {

        private _varName = [_x,"varName",""] call BIS_fnc_returnConfigEntry;
        private _isPublic = ([_x,"public",0] call BIS_fnc_returnConfigEntry) == 1;
        private _currentValue = missionNamespace getVariable _varName;

        if (!isNil "_currentValue") then {
            private _thisVarsHash = createHashMap;
            _thisVarsHash set ["varName",_varName];
            _thisVarsHash set ["public",_isPublic];
            _thisVarsHash set ["value",_currentValue];

            // --- A.I.M. Per-Entity Save Pipeline ---
            private _uniqueEntityKey = format ["%1_var_%2", _varsTag, _forEachIndex];
            [_uniqueEntityKey, _thisVarsHash] call A3M_fnc_dbSetSecure;
            
            _dbIndexList pushBack _uniqueEntityKey;
        };
    };
} forEach _allVariableClasses;

// --- Save the INDEX array ---
private _indexKey = format ["%1_INDEX", _varsTag];
[_indexKey, _dbIndexList] call A3M_fnc_dbSetSecure;
