/*
    A3M_fnc_disableVcom
    Author: A.I.M. Exoskeleton
    Description: Completely shields a unit, vehicle, or group from VCOM AI and ALiVE Dynamic Simulation.
*/
params ["_target"];
private _group = grpNull;

if (_target isEqualType grpNull) then { 
    _group = _target; 
};

if (_target isEqualType objNull) then { 
    if (_target isKindOf "Man") then { 
        _group = group _target; 
    } else { 
        _group = group (effectiveCommander _target); 
        
        // Failsafe: if effectiveCommander is null, try getting group from crew
        if (isNull _group && {count (crew _target) > 0}) then {
            _group = group ((crew _target) select 0);
        };
    };
};

if (!isNull _group) then {
    _group setVariable ["Vcm_Disable", true, true];
    _group setVariable ["ALiVE_disableDynamicSimulation", true, true];
    
    {
        _x setVariable ["Vcm_Disable", true, true];
        _x setVariable ["ALiVE_disableDynamicSimulation", true, true];
        _x disableAI "AUTOCOMBAT";
    } forEach (units _group);
};
