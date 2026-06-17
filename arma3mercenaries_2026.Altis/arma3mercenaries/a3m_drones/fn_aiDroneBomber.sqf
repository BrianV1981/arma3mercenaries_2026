/*
    A3M_fnc_aiDroneBomber
    Spawns an AI drone (if needed) and flies it over a target to automatically drop its payload.
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
    
    // Find a relatively safe spot on the ground near the squad
    private _safePos = [_spawnPos, 2, 15, 1, 0, 20, 0] call BIS_fnc_findSafePos;
    if (_safePos isEqualTo []) then { _safePos = _spawnPos getPos [5, random 360]; };
    
    _spawnPos = _safePos;
    _spawnPos set [2, 0.2]; // Spawn practically on the ground
    
    private _side = if (_source isEqualType grpNull) then { side _source } else { side group _source };
    private _class = "O_UAV_01_F"; // default to enemy
    if (_side == west) then { _class = "B_UAV_01_F"; };
    if (_side == independent) then { _class = "I_UAV_01_F"; };
    
    private _vehArray = [_spawnPos, random 360, _class, _side] call BIS_fnc_spawnVehicle;
    _drone = _vehArray select 0;
    createVehicleCrew _drone;
    _drone engineOn true; // Force engine to spool up immediately
} else {
    // Legacy support if someone passes an actual drone
    _drone = _source;
};

if (!alive _drone) exitWith {};

// Equip the drone if it doesn't have a payload
if (isNull (_drone getVariable ["A3M_Payload", objNull])) then {
    [_drone, "SatchelCharge_Remote_Mag"] call A3M_fnc_aiEquipDrone;
};

private _grp = group driver _drone;
while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };

// Force careless and fly at 50m so it goes straight without evasive maneuvers
_drone setBehaviour "CARELESS";
_drone setCombatMode "BLUE";
_drone disableAI "TARGET";
_drone disableAI "AUTOTARGET";
_drone flyInHeight 5; // User requested 5 meters

systemChat format ["[A3M] Enemy %1 Drone deployed targeting %2!", "BOMBER", name _target];

[_drone, _target] spawn {
    params ["_drone", "_target"];
    
    // Give the drone 3 seconds to take off and clear ground obstacles
    sleep 3;
    
    private _dropped = false;
    private _lastPos = [0,0,0];
    
    // Initial move command
    _drone doMove getPosATL _target;
    
    while {alive _drone && alive _target && !_dropped} do {
        private _targetPos = getPosATL _target;
        
        // Only update pathfinding if target moved more than 5 meters to prevent AI flaring/hovering
        if (_targetPos distance2D _lastPos > 5) then {
            _drone doMove _targetPos;
            _lastPos = _targetPos;
        };
        
        // Distance check (using 2D distance since it's 5m in the air)
        if ((_drone distance2D _target) < 15) then {
            [_drone, driver _drone] call A3M_fnc_dropPayload;
            _dropped = true;
        };
        sleep 0.5;
    };
    
    // Consumed after drop
    if (alive _drone) then {
        sleep 2; // Let it stabilize slightly after drop before deleting
        {deleteVehicle _x} forEach crew _drone;
        deleteVehicle _drone;
    };
};
