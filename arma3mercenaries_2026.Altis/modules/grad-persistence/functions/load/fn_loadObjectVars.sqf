#include "script_component.hpp"

params ["_vars","_object"];

{
    _x params ["_varName","_value","_isPublic"];
    
    // --- A.I.M. ACE Cargo Safe Deserialization Intercept ---
    if (_varName == "ace_cargo_loaded") then {
        if (_value isEqualType [] && {!(_value isEqualTo [])}) then {
            {
                if (_x isEqualType "") then {
                    [
                        {
                            params ["_className", "_object"];
                            private _lockedState = locked _object;
                            _object lock 0;
                            [_className, _object] call ace_cargo_fnc_addCargoItem;
                            _object lock _lockedState;
                        }, 
                        [_x, _object]
                    ] call CBA_fnc_execNextFrame;
                };
            } forEach _value;
        };
    } else {
        _object setVariable [_varName,_value,_isPublic];
    };
} forEach _vars;
