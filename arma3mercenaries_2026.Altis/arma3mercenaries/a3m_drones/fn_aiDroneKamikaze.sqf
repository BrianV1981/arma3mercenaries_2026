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
    [_drone, "DemoCharge_Remote_Mag"] call A3M_fnc_aiEquipDrone;
};

// Arm it
[_drone, driver _drone] call A3M_fnc_armKamikaze;

// Strip waypoints and disable AI components that might prevent crashing
private _grp = group driver _drone;
while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };

// Force careless and dive bomb
// Exclude from VCOM AI interference
(group driver _drone) setVariable ["Vcm_Disable", true, true];
_drone setVariable ["Vcm_Disable", true, true];

_drone setBehaviour "CARELESS";
_drone setCombatMode "BLUE";
_drone disableAI "TARGET";
_drone disableAI "AUTOTARGET";
_drone disableAI "FSM"; // Stop native evasion state machines

private _minAlt = missionNamespace getVariable ["A3M_DroneMinAltitude", 10];
private _maxAlt = missionNamespace getVariable ["A3M_DroneMaxAltitude", 50];
private _targetAlt = _minAlt + random (0 max (_maxAlt - _minAlt));

systemChat format ["[A3M] Enemy %1 Drone deployed targeting %2!", "KAMIKAZE", name _target];

// Force dive
[_drone, _target, _targetAlt] spawn {
    params ["_drone", "_target", "_targetAlt"];
    
    // Give the drone 3 seconds to take off and clear ground obstacles
    sleep 3;
    
    private _detonated = false;
    private _lastPos = [0,0,0];
    
    // Initial move command
    _drone flyInHeight _targetAlt;
    _drone doMove getPosATL _target;
    
    while {alive _drone && alive _target && !_detonated} do {
        private _targetPos = getPosATL _target;
        
        // Aggressively force altitude to fight Arma's terrain-avoidance climb
        _drone flyInHeight _targetAlt;
        
        // Only update pathfinding if target moved more than 5 meters
        if (_targetPos distance2D _lastPos > 5) then {
            _drone doMove _targetPos;
            _lastPos = _targetPos;
        };
        
        // If it gets within 15 meters 3D distance or 10 meters 2D distance, detonate
        if ((_drone distance _target) < 15 || (_drone distance2D _target) < 10) then {
            _drone setDamage 1; // Detonates the armed payload
            _detonated = true;
        };
        sleep 0.5;
    };
    
    // Clean up if the target died before drone arrived or it detonated
    if (alive _drone) then {
        _drone setDamage 1; // Just blow it up anyway as consumption
        sleep 1;
        {deleteVehicle _x} forEach crew _drone;
        deleteVehicle _drone;
    };
};
