#include "script_component.hpp"

params [["_allVarClasses",[]],["_varObj",objNull]];

private _varsData = [];

{
    private _varName = [_x,"varName",""] call BIS_fnc_returnConfigEntry;
    private _value = _varObj getVariable _varName;
    if (!isNil "_value") then {
        // --- PHASE 10.4 SANITIZATION: Neutralize objNull/grpNull ---
        if (_value isEqualType objNull && {isNull _value}) then { _value = ""; };
        if (_value isEqualType grpNull && {isNull _value}) then { _value = ""; };
        
        // --- A.I.M. ACE Cargo Serialization Intercept ---
        // We now intentionally IGNORE ace_cargo_loaded!
        // We let fn_saveVehicles and fn_saveContainers physically save the attached dummy objects (offset by 5 meters).
        // If we save ace_cargo_loaded here, it will create an empty ghost duplicate box on restart.
        if (_varName != "ace_cargo_loaded") then {
            private _isPublic = ([_x,"public",0] call BIS_fnc_returnConfigEntry) == 1;
            _varsData pushBack [_varName,_value,_isPublic];
        };
    };
} forEach _allVarClasses;

_varsData
