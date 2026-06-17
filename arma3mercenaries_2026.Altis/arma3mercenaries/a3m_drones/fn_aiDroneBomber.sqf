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

// Attach Explosives based on CBA Setting
private _payloadClass = missionNamespace getVariable ["A3M_BomberPayload", "SatchelCharge_Remote_Mag"];

// Equip the drone if it doesn't have a payload
if (isNull (_drone getVariable ["A3M_Payload", objNull])) then {
    [_drone, _payloadClass] call A3M_fnc_aiEquipDrone;
};

private _grp = group driver _drone;
while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };

// Force careless and fly at 50m so it goes straight without evasive maneuvers
// Exclude from VCOM AI interference
(group driver _drone) setVariable ["Vcm_Disable", true, true];
_drone setVariable ["Vcm_Disable", true, true];

// Completely lobotomize the Arma 3 AI so it CANNOT pathfind or ascend
_drone disableAI "ALL";
_drone engineOn true;

private _minAlt = missionNamespace getVariable ["A3M_DroneMinAltitude", 10];
private _maxAlt = missionNamespace getVariable ["A3M_DroneMaxAltitude", 50];
private _targetAlt = _minAlt + random (0 max (_maxAlt - _minAlt));

if (missionNamespace getVariable ["A3M_DroneDebug", false]) then {
    systemChat format ["[A3M] Enemy %1 Drone deployed targeting %2! Payload: %3", "BOMBER", name _target, (missionNamespace getVariable ["A3M_BomberPayload", "SatchelCharge_Remote_Mag"])];
};

[_drone, _target, _targetAlt] spawn {
    params ["_drone", "_target", "_targetAlt"];
    
    // Phase 1: Vertical Liftoff
    private _liftoffEnd = time + 3;
    while {time < _liftoffEnd && alive _drone} do {
        _drone setVelocity [0, 0, 5]; // Ascend at 5 m/s
        _drone setVectorDirAndUp [vectorDir _drone, [0,0,1]];
        sleep 0.1;
    };
    
    private _dropped = false;
    
    // Phase 2: Approach and Drop
    while {alive _drone && alive _target && !_dropped} do {
        private _targetPos = getPosATL _target;
        private _dist2D = _drone distance2D _target;
        
        if (_dist2D < 5) then {
            // We are directly above the target - hover and drop payload
            _drone setVelocity [0, 0, 0];
            
            // Drop official A3M payload
            [_drone, driver _drone] call A3M_fnc_dropPayload;
            
            _dropped = true; // Payload consumed
        } else {
            // Phase 2: Horizontal Approach (Physics-driven)
            private _dirTo = _drone getDir _target;
            private _speed = 15; // 15 m/s cruise speed
            private _vx = (sin _dirTo) * _speed;
            private _vy = (cos _dirTo) * _speed;
            
            // Altitude correction
            private _currentAlt = (getPosATL _drone) select 2;
            private _vz = 0;
            if (_currentAlt < _targetAlt - 2) then { _vz = 3; }
            else { if (_currentAlt > _targetAlt + 2) then { _vz = -3; }; };
            
            // Level flight pointing at target
            _drone setVectorDirAndUp [[_vx, _vy, 0], [0,0,1]]; 
            _drone setVelocity [_vx, _vy, _vz];
        };
        
        sleep 0.1; // 10 Hz physics tick
    };
    
    // Cleanup - Drone flies away or dies
    if (alive _drone) then {
        sleep 5; // Give it 5 seconds to fly away visually
        _drone setDamage 1; 
        sleep 1;
        {deleteVehicle _x} forEach crew _drone;
        deleteVehicle _drone;
    };
};
