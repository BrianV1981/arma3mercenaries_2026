// File: fn_addUpdatePFH.sqf

params ["_builder", "_fort", "_surfaceNormal"];

// Add the per-frame handler and store its handle for later removal
grad_fortifications_updatePFH_handle = [

    {
        params ["_args", "_handle"];
        private ["_unit", "_fort", "_surfaceNormal"];
        _unit = _args select 0;
        _fort = _args select 1;
        _surfaceNormal = _args select 2;

        if (isNull _fort || !alive _unit || currentWeapon _unit != "") exitWith {
            [] call grad_fortifications_fnc_cancelPlacement;
        };

        [_unit, _fort] call grad_fortifications_fnc_setPosition;
        [_unit, _fort] call grad_fortifications_fnc_setDirection;
        [_unit, _fort, _surfaceNormal] call grad_fortifications_fnc_setUp;
    },

    0, // Delay between executions (0 for every frame)
    [_builder, _fort, _surfaceNormal] // Arguments to pass to the code block
] call CBA_fnc_addPerFrameHandler;
