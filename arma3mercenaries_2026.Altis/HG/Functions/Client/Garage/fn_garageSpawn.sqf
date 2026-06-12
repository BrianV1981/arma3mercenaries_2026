#include "HG_Macros.h" 

/*
  fn_garageSpawn.sqf
  A3M Dynamic Markerless Spawn Overhaul
*/

disableSerialization; 

private _sel = (HG_GARAGE_LIST lbData (lbCurSel HG_GARAGE_LIST)) splitString "/";
private _classname = _sel select 0;
private _color = _sel select 1;
private _plate = HG_GARAGE_LIST lbValue (lbCurSel HG_GARAGE_LIST);

private _targetLaptop = missionNamespace getVariable ["A3M_HG_CurrentLaptop", objNull];
private _spawnPosition = [];

private _spDropdown = HG_GARAGE_SP;
private _spValue = -1;

if (!isNull _spDropdown && {(lbCurSel _spDropdown) != -1}) then {
    _spValue = _spDropdown lbValue (lbCurSel _spDropdown);
};

if (_spValue != -1) then {
    if (!isNil "HG_SPAWN_POINTS" && {count HG_SPAWN_POINTS > _spValue}) then {
        private _selectedSpawn = HG_SPAWN_POINTS select _spValue; 
        private _markerArray = _selectedSpawn select 1;
        
        {
            if(count(nearestObjects[(getMarkerPos _x),["Car","Truck","Tank","Air","Ship","Submarine"],5]) isEqualTo 0) exitWith
            {
                _spawnPosition = _x; 
            };
        } forEach _markerArray;

        if ((typeName _spawnPosition) isEqualTo "ARRAY" && {_spawnPosition isEqualTo []}) then {
            titleText [(localize "STR_HG_SPAWN_BLOCKED"), "PLAIN DOWN", 1];
        };
    };
};

if ((typeName _spawnPosition) isEqualTo "ARRAY" && {_spawnPosition isEqualTo []}) then {
    private _distance = 15;
    private _direction = 0; 
    private _heading = getDir player;

    private _mathPos = player getRelPos [_distance, _direction];
    
    private _safePos = [];
    for "_i" from 1 to 50 do {
        _safePos = _mathPos findEmptyPosition [0, 15 + 5*_i, _classname];
        if !(_safePos isEqualTo []) exitWith {};
    };
    
    if !(_safePos isEqualTo []) then {
        _spawnPosition = _safePos;
        _spawnPosition pushBack _heading;
    } else {
        _spawnPosition = (getPos player) findEmptyPosition [5, 50, _classname];
    };
    
    if (_spawnPosition isEqualTo []) exitWith {
        titleText ["NO SAFE SPAWN POSITION FOUND NEARBY! SPAWN CANCELLED.", "PLAIN DOWN", 1];
    };
};

if ((typeName _spawnPosition) isEqualTo "ARRAY" && {_spawnPosition isEqualTo []}) exitWith {};

hint (localize "STR_HG_GRG_VEHICLE_SPAWNING"); 

closeDialog 0; 

// Execute the vehicle spawning function on the server (1 = From Garage)
[1, player, _classname, _spawnPosition, _plate, _color] remoteExecCall ["HG_fnc_spawnVehicle", 2, false];

// Trigger the 3D GRAD Position Marker so the player knows exactly where the vehicle spawned
[_classname, _spawnPosition] spawn {
    params ["_classname", "_spawnPosition"];
    private _displayName = getText(configFile >> "CfgVehicles" >> _classname >> "displayName");
    private _endTime = time + 30;
    
    waitUntil {
        drawIcon3D ["a3\ui_f\data\gui\Rsc\RscDisplayIntel\azimuth_ca.paa", [0,1,0,1], [_spawnPosition select 0, _spawnPosition select 1, (_spawnPosition select 2) + 2.5], 1, 1, 180, format ["%1 SPAWNED HERE", _displayName], 1, 0.04, "PuristaMedium", "center", true];
        (time > _endTime)
    };
};

true;
