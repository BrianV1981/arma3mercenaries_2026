/*
    A3M_fnc_aiDroneKamikaze
    Spawns an AI drone (if needed) and forces it into a terminal dive towards a target.
*/
params ["_source", "_target"];

if (isNil "_source" || isNull _target) exitWith {};

private _drone = objNull;

// If the source is a unit or group calling for help, spawn the drone dynamically
if (_source isEqualType grpNull || _source isEqualType objNull) then {
    private _spawnPos = [];
    if (_source isEqualType grpNull) then {
        _spawnPos = getPos (leader _source);
    } else {
        _spawnPos = getPos _source;
    };
    
    // Spawn a quadcopter 300m above and slightly away from the caller
    _spawnPos = _spawnPos getPos [150, random 360];
    _spawnPos set [2, 300];
    
    private _side = if (_source isEqualType grpNull) then { side _source } else { side group _source };
    private _class = "O_UAV_01_F"; // default to enemy
    if (_side == west) then { _class = "B_UAV_01_F"; };
    if (_side == independent) then { _class = "I_UAV_01_F"; };
    
    private _vehArray = [_spawnPos, random 360, _class, _side] call BIS_fnc_spawnVehicle;
    _drone = _vehArray select 0;
    createVehicleCrew _drone;
} else {
    // Legacy support if someone passes an actual drone
    _drone = _source;
};

if (!alive _drone) exitWith {};

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

systemChat format ["[A3M] Enemy %1 Drone deployed targeting %2!", "KAMIKAZE", name _target];

// Force dive
[_drone, _target] spawn {
    params ["_drone", "_target"];
    while {alive _drone && alive _target} do {
        private _pos = getPosASL _target;
        _drone doMove ASLToAGL _pos;
        sleep 1;
    };
};
