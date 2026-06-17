/*
    A3M_fnc_aiDroneBomber
    Flies an AI drone over a target and automatically drops its payload.
*/
params ["_drone", "_target"];

if (!alive _drone || isNull _target) exitWith {};

// Equip the drone if it doesn't have a payload
if (isNull (_drone getVariable ["A3M_Payload", objNull])) then {
    [_drone, "SatchelCharge_Remote_Mag"] call A3M_fnc_aiEquipDrone;
};

private _grp = group driver _drone;
while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };

_drone setBehaviour "AWARE";
_drone setCombatMode "RED";

[_drone, _target] spawn {
    params ["_drone", "_target"];
    
    // Command the drone to fly to the target
    private _targetPos = getPosASL _target;
    _drone doMove ASLToAGL _targetPos;
    
    private _dropped = false;
    
    while {alive _drone && alive _target && !_dropped} do {
        _targetPos = getPosASL _target;
        _drone doMove ASLToAGL _targetPos;
        
        // Distance check
        if ((_drone distance2D _target) < 15) then {
            [_drone, driver _drone] call A3M_fnc_dropPayload;
            _dropped = true;
        };
        sleep 0.5;
    };
    
    // RTB after drop
    if (alive _drone) then {
        // Fly away to a random safe distance to loiter or despawn
        private _safePos = _drone getPos [2000, random 360];
        _drone doMove _safePos;
    };
};
