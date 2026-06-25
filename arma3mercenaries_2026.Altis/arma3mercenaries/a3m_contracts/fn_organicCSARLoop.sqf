/*
    arma3mercenaries\a3m_contracts\fn_organicCSARLoop.sqf
    Description: Spawns an aircraft over "AO" or on runway. When shot down, generates a CSAR task. Re-runs after a delay.
*/
params [["_prefix", "A3M_CSAR_F1", [""]], ["_difficulty", "NORMAL"]];

if (!isServer) exitWith {};

private _getVar = {
    params ["_varSuffix", "_default"];
    missionNamespace getVariable [format ["%1_%2", _prefix, _varSuffix], _default]
};

private _enabled = ["Enabled", false] call _getVar;
private _debug = ["Debug", false] call _getVar;
if (!_enabled) exitWith { diag_log format ["[A3M TASK MANAGER] Organic CSAR %1 loop disabled.", _prefix]; };

private _sideInt = ["Side", 0] call _getVar;
private _side = [west, east, independent] select _sideInt;

private _vehiclesString = ["Vehicles", "'B_Plane_CAS_01_dynamicLoadout_F'"] call _getVar;
private _aircraftArray = call compile format ["[%1]", _vehiclesString];
if (isNil "_aircraftArray" || {count _aircraftArray == 0}) then { _aircraftArray = ["B_Plane_CAS_01_dynamicLoadout_F"]; };

private _sanitizeCoord = {
    params ["_str"];
    if (_str == "") exitWith { "" };
    if ((_str select [0,1]) != "[") then {
        _str = format ["[%1]", _str];
    };
    _str
};

private _spawnCoordStr = ["SpawnCoord", ""] call _getVar call _sanitizeCoord;
private _spawnMarker = ["SpawnMarker", ""] call _getVar;
private _spawnDir = ["SpawnDir", 0] call _getVar;
private _fallbackTaor = ["FallbackTaor", "blue_taor"] call _getVar;
private _fallbackCoordStr = ["FallbackCoord", ""] call _getVar call _sanitizeCoord;
private _fallbackRadius = ["FallbackRadius", 1000] call _getVar;
private _targetTaor = ["TargetTaor", "unoccupied_taor_1"] call _getVar;
private _targetCoordStr = ["TargetCoord", ""] call _getVar call _sanitizeCoord;
private _targetRadius = ["TargetRadius", 2000] call _getVar;
private _cooldownMin = ["CooldownMin", 5] call _getVar;
private _cooldownMax = ["CooldownMax", 10] call _getVar;
private _startupDelayMin = ["StartupDelayMin", 1] call _getVar;
private _startupDelayMax = ["StartupDelayMax", 3] call _getVar;
private _startupDelay = (_startupDelayMin + random (_startupDelayMax - _startupDelayMin)) * 60;
private _rewardAmount = ["RewardAmount", 250000] call _getVar;
private _xpRewardAmount = ["XPRewardAmount", 500] call _getVar;
private _rewardRadius = ["RewardRadius", 2] call _getVar;
private _pilotAnnouncements = ["PilotAnnouncements", true] call _getVar;

private _spawnPos = [];
private _startOnGround = false;

// 1. Determine Runway Spawn
diag_log format ["[A3M TASK MANAGER] Organic CSAR %1: Raw CBA SpawnCoord string is '%2', SpawnMarker is '%3'", _prefix, _spawnCoordStr, _spawnMarker];

if (_spawnMarker != "" && {getMarkerColor _spawnMarker != ""}) then {
    _spawnPos = getMarkerPos _spawnMarker;
    _spawnDir = markerDir _spawnMarker;
    _startOnGround = true;
};

if (!_startOnGround && _spawnCoordStr != "") then {
    private _temp = call compile _spawnCoordStr;
    if (!isNil "_temp" && {count _temp >= 2}) then {
        _spawnPos = _temp;
        _startOnGround = true;
    } else {
        diag_log format ["[A3M TASK MANAGER] Organic CSAR %1: FAILED to compile CBA SpawnCoord '%2'", _prefix, _spawnCoordStr];
    };
};

// 2. Determine Air Fallback Spawn
if (!_startOnGround) then {
    if (_fallbackCoordStr != "") then {
        private _fCenter = call compile _fallbackCoordStr;
        if (!isNil "_fCenter" && {count _fCenter >= 2}) then {
            // Pick a random pos around the coord
            private _dir = random 360;
            private _dist = random _fallbackRadius;
            _spawnPos = [(_fCenter select 0) + (sin _dir * _dist), (_fCenter select 1) + (cos _dir * _dist), 1000];
        };
    };
    
    if (isNil "_spawnPos" || {_spawnPos isEqualTo []}) then {
        _spawnPos = _fallbackTaor call BIS_fnc_randomPosTrigger;
        if (isNil "_spawnPos" || {_spawnPos isEqualTo []}) then { _spawnPos = [0,0,0]; }; 
        _spawnPos set [2, 1000];
    };
};

private _aircraftClass = selectRandom _aircraftArray;
private _aircraftGroup = createGroup [_side, true];
_aircraftGroup setVariable ["Vcm_Disable", true, true];
_aircraftGroup setVariable ["ALIVE_profileIgnore", true, true];
private _spawnMode = if (_startOnGround) then { "NONE" } else { "FLY" };
private _aircraft = createVehicle [_aircraftClass, _spawnPos, [], 0, _spawnMode];
_aircraft setVariable ["ALIVE_profileIgnore", true, true];

if (_startOnGround) then {
    _aircraft setDir _spawnDir;
    _aircraft setPos _spawnPos;
} else {
    _aircraft setPosASL _spawnPos;
};

createVehicleCrew _aircraft;
(crew _aircraft) joinSilent _aircraftGroup;

// 3. Determine Patrol Target
private _targetPos = [];
if (_targetCoordStr != "") then {
    private _tCenter = call compile _targetCoordStr;
    if (!isNil "_tCenter" && {count _tCenter >= 2}) then {
        private _dir = random 360;
        private _dist = random _targetRadius;
        _targetPos = [(_tCenter select 0) + (sin _dir * _dist), (_tCenter select 1) + (cos _dir * _dist), 0];
    };
};

if (_targetPos isEqualTo []) then {
    _targetPos = _targetTaor call BIS_fnc_randomPosTrigger;
    if (_targetPos isEqualTo []) then { _targetPos = [worldSize/2, worldSize/2, 0]; };
};

private _callsign = selectRandom ["Maddog", "Ace", "Maverick", "Viper", "Jester", "Iceman", "Ghostrider", "Bandit", "Striker", "Wolfhound", "Raptor", "Hitman", "Assassin"];

private _fnc_announceDeparture = {
    params ["_callsign", "_targetPos", "_pilotAnnouncements"];
    if (_pilotAnnouncements) then {
        private _grid = mapGridPosition _targetPos;
        private _msg = selectRandom [
            format ["CROSSROAD, this is %1. Wheels up. Vectoring to grid %2 for operations. Out.", _callsign, _grid],
            format ["TOC, this is %1. We are Oscar-Mike to grid %2 for patrol sweep. Out.", _callsign, _grid],
            format ["Command, %1 is airborne. Proceeding to target sector %2 for tasking. Out.", _callsign, _grid]
        ];
        [_msg] remoteExecCall ["systemChat", 0];
    };
};

if (_startOnGround) then {
    _aircraft engineOn false;
    [{
        params ["_aircraftGroup", "_targetPos", "_aircraft", "_callsign", "_pilotAnnouncements", "_fnc_announceDeparture"];
        if (alive _aircraft) then {
            _aircraft engineOn true;
            [_callsign, _targetPos, _pilotAnnouncements] call _fnc_announceDeparture;
            private _wp = _aircraftGroup addWaypoint [_targetPos, 500];
            _wp setWaypointType "SAD";
            _wp setWaypointCombatMode "RED";
            _wp setWaypointBehaviour "COMBAT";
            _wp setWaypointSpeed "FULL";
        };
    }, [_aircraftGroup, _targetPos, _aircraft, _callsign, _pilotAnnouncements, _fnc_announceDeparture], _startupDelay] call CBA_fnc_waitAndExecute;
} else {
    _startupDelay = 0;
    [_callsign, _targetPos, _pilotAnnouncements] call _fnc_announceDeparture;
    private _wp = _aircraftGroup addWaypoint [_targetPos, 500];
    _wp setWaypointType "SAD";
    _wp setWaypointCombatMode "RED";
    _wp setWaypointBehaviour "COMBAT";
    _wp setWaypointSpeed "FULL";
};

diag_log format ["[A3M TASK MANAGER] Organic CSAR %1: Spawned %2 (Ground: %3). Patrol: %4.", _prefix, _aircraftClass, _startOnGround, _targetPos];

private _spawnTime = diag_tickTime + _startupDelay;
_aircraft setVariable ["A3M_RTB", false];

private _debugMarker = "";
if (_debug) then {
    _debugMarker = createMarker [format ["A3M_CSAR_DEBUG_%1_%2", _prefix, _spawnTime], getPos _aircraft];
    if (_aircraft isKindOf "Helicopter") then { _debugMarker setMarkerType "b_air"; } else { _debugMarker setMarkerType "b_plane"; };
    _debugMarker setMarkerText format ["%1 CSAR (Pre-Flight)", _prefix];
    if (_side == west) then { _debugMarker setMarkerColor "ColorBLUFOR"; };
    if (_side == east) then { _debugMarker setMarkerColor "ColorOPFOR"; };
    if (_side == independent) then { _debugMarker setMarkerColor "ColorGUER"; };
};

[{
    params ["_args", "_handle"];
    _args params ["_aircraft", "_aircraftGroup", "_difficulty", "_spawnTime", "_prefix", "_cooldownMin", "_cooldownMax", "_debugMarker", "_spawnPos", "_side", "_xpRewardAmount", "_rewardAmount", "_rewardRadius", "_pilotAnnouncements", "_callsign"];

    private _reQueueLoop = {
        params ["_pfhHandle", "_aircraft", "_prefix", "_cooldownMin", "_cooldownMax", "_difficulty", "_debugMarker"];
        if (_debugMarker != "") then { deleteMarker _debugMarker; };
        [_pfhHandle] call CBA_fnc_removePerFrameHandler;
        { deleteVehicle _x; } forEach (crew _aircraft);
        deleteVehicle _aircraft;
        
        private _minSec = _cooldownMin * 60;
        private _maxSec = _cooldownMax * 60;
        private _cooldown = _minSec + random (_maxSec - _minSec); 
        [{ [_this select 0, _this select 1] spawn A3M_fnc_organicCSARLoop; }, [_prefix, _difficulty], _cooldown] call CBA_fnc_waitAndExecute;
    };

        if (_debugMarker != "") then {
        _debugMarker setMarkerPos (getPos _aircraft);
        _debugMarker setMarkerDir (getDir _aircraft);
        if (_aircraft getVariable ["A3M_RTB", false]) then {
            _debugMarker setMarkerText format ["%1 CSAR (RTB)", _prefix];
        } else {
            if (diag_tickTime < _spawnTime) then {
                _debugMarker setMarkerText format ["%1 CSAR (Pre-Flight)", _prefix];
            } else {
                _debugMarker setMarkerText format ["%1 CSAR (Patrol)", _prefix];
            };
        };
    };

    if (diag_tickTime > _spawnTime + 600 && !(_aircraft getVariable ["A3M_RTB", false])) then {
        _aircraft setVariable ["A3M_RTB", true];
        while {(count (waypoints _aircraftGroup)) > 0} do { deleteWaypoint ((waypoints _aircraftGroup) select 0); };
        private _airportID = [getPos _aircraft] call ALiVE_fnc_getNearestAirportID;
        if (isNil "_airportID") then { _airportID = 0; };
        _aircraft landAt _airportID;
    };

    if (_aircraft getVariable ["A3M_RTB", false]) then {
        if (speed _aircraft < 2 && (getPos _aircraft select 2) < 2 && unitReady (driver _aircraft)) then {
            [_handle, _aircraft, _prefix, _cooldownMin, _cooldownMax, _difficulty, _debugMarker] call _reQueueLoop;
        };
    };

    if (diag_tickTime > _spawnTime + 1800) exitWith {
        [_handle, _aircraft, _prefix, _cooldownMin, _cooldownMax, _difficulty, _debugMarker] call _reQueueLoop;
    };

    private _isShotDown = false;
    private _crashPos = getPos _aircraft;

    if (!alive _aircraft) then { _isShotDown = true; };
    if ({alive _x} count (crew _aircraft) == 0) then { _isShotDown = true; };
    if ((getPos _aircraft select 2) < 15 && {damage _aircraft > 0.6}) then { _isShotDown = true; };

    if (_isShotDown && !(_aircraft getVariable ["A3M_RTB", false] && (getPos _aircraft select 2) < 15)) then {
        
        // Failsafe: Prevent Base-Camping Exploit
        if (_crashPos distance2D _spawnPos <= 300) exitWith {
            diag_log format ["[A3M TASK MANAGER] Organic CSAR %1: Aircraft destroyed within 300m of spawn. Anti-farm failsafe engaged. Resetting.", _prefix];
            [_handle, _aircraft, _prefix, _cooldownMin, _cooldownMax, _difficulty, _debugMarker] call _reQueueLoop;
        };

        [_handle] call CBA_fnc_removePerFrameHandler;
        
        if (_debugMarker != "") then { deleteMarker _debugMarker; };
        
        if (_pilotAnnouncements) then {
            private _chatMsg = format ["MAYDAY, MAYDAY! This is %1! We are going down! Grid %2!", _callsign, mapGridPosition _crashPos];
            [_chatMsg] remoteExecCall ["systemChat", 0];
        };
        
        // Asynchronously track the falling wreckage to the ground
        [_aircraft, _difficulty, _prefix, _cooldownMin, _cooldownMax, _spawnPos, _side, _xpRewardAmount, _rewardAmount, _rewardRadius, _pilotAnnouncements, _callsign] spawn {
            params ["_aircraft", "_difficulty", "_prefix", "_cooldownMin", "_cooldownMax", "_spawnPos", "_side", "_xpRewardAmount", "_rewardAmount", "_rewardRadius", "_pilotAnnouncements", "_callsign"];
            
            private _vehType = typeOf _aircraft;
            private _displayName = getText (configFile >> "CfgVehicles" >> _vehType >> "displayName");
            
            // Wait for it to hit the ground and settle (max 3 minutes)
            private _timeout = time + 180;
            private _lastPos = getPos _aircraft;
            
            waitUntil {
                sleep 2;
                if (!isNull _aircraft) then { _lastPos = getPos _aircraft; };
                (getPos _aircraft select 2 < 5 && vectorMagnitude (velocity _aircraft) < 1) || time > _timeout || isNull _aircraft
            };
            
            private _crashPos = _lastPos;
            _crashPos set [2, 0];
            
            // Delete the original dynamic wreckage/debris so we can replace it with a clean mission prop
            if (!isNull _aircraft) then {
                { deleteVehicle _x; } forEach crew _aircraft;
                deleteVehicle _aircraft;
            };
            
            // Spawn a perfect, permanent wreck of the exact same aircraft type
            private _missionWreck = createVehicle [_vehType, _crashPos, [], 0, "CAN_COLLIDE"];
            _missionWreck setDir (random 360);
            
            // Remove fuel and ammo so it doesn't violently explode again, then instantly destroy it
            _missionWreck setFuel 0;
            _missionWreck setVehicleAmmo 0;
            _missionWreck setDamage [1, false];
            
            // Tag it so garbage collectors ignore our mission prop
            _missionWreck setVariable ["ALiVE_profile_ignore", true, true];
            removeFromRemainsCollector [_missionWreck];
            
            private _taskID = [_difficulty, _crashPos, _displayName, _spawnPos, _side, _prefix, _xpRewardAmount, _rewardAmount, _rewardRadius, _pilotAnnouncements, _callsign] call A3M_fnc_generateCSAR;

            // Asynchronously wait for the CSAR task to finish before starting the cooldown for the next aircraft
            [_taskID, _cooldownMin, _cooldownMax, _prefix, _difficulty] spawn {
                params ["_taskID", "_cooldownMin", "_cooldownMax", "_prefix", "_difficulty"];
                
                waitUntil {
                    sleep 10;
                    private _state = [_taskID] call BIS_fnc_taskState;
                    (_state == "SUCCEEDED" || _state == "FAILED" || _state == "CANCELED" || _state == "")
                };
                
                private _minSec = _cooldownMin * 60;
                private _maxSec = _cooldownMax * 60;
                private _cooldown = _minSec + random (_maxSec - _minSec); 
                [{ [_this select 0, _this select 1] spawn A3M_fnc_organicCSARLoop; }, [_prefix, _difficulty], _cooldown] call CBA_fnc_waitAndExecute;
            };
        };
    };
}, 5, [_aircraft, _aircraftGroup, _difficulty, _spawnTime, _prefix, _cooldownMin, _cooldownMax, _debugMarker, _spawnPos, _side, _xpRewardAmount, _rewardAmount, _rewardRadius, _pilotAnnouncements, _callsign]] call CBA_fnc_addPerFrameHandler;
