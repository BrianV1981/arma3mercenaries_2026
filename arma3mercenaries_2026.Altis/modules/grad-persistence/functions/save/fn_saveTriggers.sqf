#include "script_component.hpp"

if (!isServer) exitWith {};

params [["_area",false],["_allVariableClasses",[]]];

if (_area isEqualType []) then {
    _area params ["_center","_a","_b",["_angle",0],["_isRectangle",false],["_c",-1]];
    if (isNil "_b") then {_b = _a};
    _area = [_center,_a,_b,_angle,_isRectangle,_c];
};

private _allTriggerVariableClasses = _allVariableClasses select {
    ([_x,"varNamespace",""] call BIS_fnc_returnConfigEntry) == "trigger"
};

private _missionTag = [] call FUNC(getMissionTag);
private _triggersTag = _missionTag + "_triggers";

private _triggers = (allMissionObjects "EmptyDetector") select {!([_x] call FUNC(isBlacklisted))};
if (_area isEqualType []) then {
    _triggers = _triggers select {_x inArea _area};
};

// --- A.I.M. v812+ Architecture: DB Index Tracking ---
private _savedTriggersCount = 0;

{
    private _thisTriggerHash = createHashMap;

    private _vehVarName = vehicleVarName _x;
    if (_vehVarName != "") then {
        _thisTriggerHash set ["varName",_vehVarName];
    };

    _thisTriggerHash set ["posASL",getPosASL _x];
    _thisTriggerHash set ["activated",triggerActivated _x];
    _thisTriggerHash set ["activation",triggerActivation _x];
    _thisTriggerHash set ["area",triggerArea _x];
    _thisTriggerHash set ["statements",triggerStatements _x];
    _thisTriggerHash set ["timeout",triggerTimeout _x];
    _thisTriggerHash set ["text",triggerText _x];
    _thisTriggerHash set ["type",triggerType _x];

    if (!isNil {_x getVariable QGVAR(reExecute)}) then {
        _thisTriggerHash set ["reExecute",_x getVariable QGVAR(reExecute)];
    };

    private _thisTriggerVars = [_allTriggerVariableClasses,_x] call FUNC(saveObjectVars);
    _thisTriggerHash set ["vars",_thisTriggerVars];

    // --- A.I.M. Per-Entity Save Pipeline ---
    private _uniqueEntityKey = format ["%1_trig_%2", _triggersTag, _savedTriggersCount];
    [_uniqueEntityKey, _thisTriggerHash] call A3M_fnc_dbSetSecure;
    
    _savedTriggersCount = _savedTriggersCount + 1;
} forEach _triggers;

// --- Save the COUNT integer ---
private _countKey = format ["%1_COUNT", _triggersTag];
[_countKey, _savedTriggersCount] call A3M_fnc_dbSetSecure;

// ALSO delete the old INDEX array so we don't duplicate logic if mixing load systems
private _indexKey = format ["%1_INDEX", _triggersTag];
[_indexKey, []] call A3M_fnc_dbSetSecure;
