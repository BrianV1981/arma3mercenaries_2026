#include "script_component.hpp"

if (!isServer) exitWith {};

params [["_area",false],["_allVariableClasses",[]]];

if (_area isEqualType []) then {
    _area params ["_center","_a","_b",["_angle",0],["_isRectangle",false],["_c",-1]];
    if (isNil "_b") then {_b = _a};
    _area = [_center,_a,_b,_angle,_isRectangle,_c];
};

private _allStaticVariableClasses = _allVariableClasses select {
    ([_x,"varNamespace",""] call BIS_fnc_returnConfigEntry) == "static"
};

private _missionTag = [] call FUNC(getMissionTag);
private _staticsTag = _missionTag + "_statics";
private _foundStaticsVarnames = GVAR(allFoundVarNames) select 3;

private _statics = allMissionObjects "Static";
private _saveStaticsMode = [missionConfigFile >> "CfgGradPersistence", "saveStatics", 1] call BIS_fnc_returnConfigEntry;

// --- A.I.M. v812+ Architecture: DB Index Tracking ---
private _savedStaticsCount = 0;

{
    if (
            typeOf _x != "CBA_NamespaceDummy" &&
            {!([_x] call FUNC(isBlacklisted))} &&
            {
                _saveStaticsMode == 2 ||
                (_x getVariable [QGVAR(isEditorObject),false]) isEqualTo (_saveStaticsMode == 1)
            } &&
            // exclude grad-fortifications
            {isNil {_x getVariable "grad_fortifications_fortOwner"}} &&
            {if (_area isEqualType false) then {true} else {_x inArea _area}}
        ) then {

        private _thisStaticHash = createHashMap;

        private _vehVarName = vehicleVarName _x;
        if (_vehVarName != "") then {
            _thisStaticHash set ["varName",_vehVarName];
            _foundStaticsVarnames deleteAt (_foundStaticsVarnames find _vehVarName);
        };

        _thisStaticHash set ["type",typeOf _x];
        _thisStaticHash set ["posASL",getPosASL _x];
        _thisStaticHash set ["vectorDirAndUp",[vectorDir _x, vectorUp _x]];
        _thisStaticHash set ["damage",damage _x];
        _thisStaticHash set ["isGradMoneymenuStorage",_x getVariable ["grad_moneymenu_isStorage",false]];
        _thisStaticHash set ["gradMoneymenuOwner",_x getVariable ["grad_moneymenu_owner",objNull]];
        _thisStaticHash set ["gradLbmMoney",_x getVariable ["grad_lbm_myFunds",0]];

        private _thisStaticVars = [_allStaticVariableClasses,_x] call FUNC(saveObjectVars);
        _thisStaticHash set ["vars",_thisStaticVars];

        // --- A.I.M. Per-Entity Save Pipeline ---
        private _uniqueEntityKey = format ["%1_stat_%2", _staticsTag, _savedStaticsCount];
        [_uniqueEntityKey, _thisStaticHash] call A3M_fnc_dbSetSecure;
        
        _savedStaticsCount = _savedStaticsCount + 1;
    };
} forEach _statics;

// --- Save the COUNT integer ---
private _countKey = format ["%1_COUNT", _staticsTag];
[_countKey, _savedStaticsCount] call A3M_fnc_dbSetSecure;

// ALSO delete the old INDEX array so we don't duplicate logic if mixing load systems
private _indexKey = format ["%1_INDEX", _staticsTag];
[_indexKey, []] call A3M_fnc_dbSetSecure;

// --- A.I.M. v812+ Architecture: SQLite Killed Tracker ---
private _killedVarnamesKey = format ["%1_killedVarnames", _missionTag];
private _killedVarnames = [_killedVarnamesKey, [[],[],[],[]]] call A3M_fnc_dbGetSecure; // Index 3 is for statics
private _killedStaticsVarnames = _killedVarnames param [3,[]];

_killedStaticsVarnames append _foundStaticsVarnames;
_killedStaticsVarnames arrayIntersect _killedStaticsVarnames;
_killedVarnames set [3,_killedStaticsVarnames];

[_killedVarnamesKey, _killedVarnames] call A3M_fnc_dbSetSecure;
