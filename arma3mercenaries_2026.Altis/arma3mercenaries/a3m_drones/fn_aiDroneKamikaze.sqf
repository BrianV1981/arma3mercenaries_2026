/*
    A3M_fnc_aiDroneKamikaze
    Forces an AI drone into a terminal dive towards a target.
*/
params ["_drone", "_target"];

if (!alive _drone || isNull _target) exitWith {};

// Equip the drone if it doesn't have a payload
if (isNull (_drone getVariable ["A3M_Payload", objNull])) then {
    [_drone, "DemoCharge_Remote_Mag"] call A3M_fnc_aiEquipDrone;
};

// Arm it
[_drone, driver _drone] call A3M_fnc_armKamikaze;

// Strip waypoints and disable AI components that might prevent crashing
private _grp = group driver _drone;
while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };

_drone setBehaviour "CARELESS";
_drone setCombatMode "BLUE";

// Force dive
[_drone, _target] spawn {
    params ["_drone", "_target"];
    while {alive _drone && alive _target} do {
        private _pos = getPosASL _target;
        _drone doMove ASLToAGL _pos;
        sleep 1;
    };
};
