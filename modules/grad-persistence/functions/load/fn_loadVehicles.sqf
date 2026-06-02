/*
    arma3mercenaries_fn_loadVehicles.sqf

    gradPersistence save vehicle script fn_loadVehicles.sqf

    enhanced by BrianV1981
*/

#include "script_component.hpp"

if (!isServer) exitWith {};

private _missionTag = [] call FUNC(getMissionTag);
private _vehiclesTag = _missionTag + "_vehicles";

// --- A.I.M. v812+ Architecture: SQLite Per-Entity Loading ---
private _countKey = format ["%1_COUNT", _vehiclesTag];
private _dbCount = [_countKey, -1, false] call A3M_fnc_dbGetSecure;

private _vehiclesData = [];

if (_dbCount > -1) then {
    // New Iterative Architecture
    for "_i" from 0 to (_dbCount - 1) do {
        private _uniqueEntityKey = format ["%1_veh_%2", _vehiclesTag, _i];
        private _entityHash = [_uniqueEntityKey, createHashMap, true] call A3M_fnc_dbGetSecure;
        
        if (count _entityHash > 0) then {
            _vehiclesData pushBack _entityHash;
        };
    };
};

{
    private _thisVehicleHash = _x;
    // Extract variables using native HashMaps
    private _type = _thisVehicleHash getOrDefault ["type", ""];
    private _side = _thisVehicleHash getOrDefault ["side", sideUnknown];
    private _vehVarName = _thisVehicleHash getOrDefault ["varName", ""];

    private _thisVehicle = objNull;
    private _editorVehicleFound = false;
    
    if (_vehVarName != "") then {
        // Check if it's an editor-placed object that already exists
        private _editorVehicle = call compile _vehVarName;
        if (!isNil "_editorVehicle") then {
            if (_editorVehicle isEqualType objNull) then {
                _thisVehicle = _editorVehicle;
                _editorVehicleFound = true;
            } else {
                ERROR_1("Vehicle varName %1 resolved to %2 (not type OBJECT). Spawning new vehicle instead.", _vehVarName, _editorVehicle);
            };
        };
    };

    if (!_editorVehicleFound) then {
        // Create the vehicle
        _thisVehicle = createVehicle [_type, [0,0,0], [], 0, "CAN_COLLIDE"];
        
        if (_vehVarName != "") then {
            [_thisVehicle,_vehVarName] remoteExec ["setVehicleVarName",0,_thisVehicle];
            missionNamespace setVariable [_vehVarName,_thisVehicle,true];
        };
    };

    // Extract properties natively before CBA
    private _posASL = _thisVehicleHash getOrDefault ["posASL", [0,0,0]];
    private _fuel = _thisVehicleHash getOrDefault ["fuel", 1];
    private _vectorDirAndUp = _thisVehicleHash getOrDefault ["vectorDirAndUp", [[0,1,0],[0,0,1]]];
    private _hitPointDamage = _thisVehicleHash getOrDefault ["hitpointDamage", [[],[]]];
    private _turretMagazines = _thisVehicleHash getOrDefault ["turretMagazines", []];
    private _inventory = _thisVehicleHash getOrDefault ["inventory", []];
    private _HG_Owner = _thisVehicleHash getOrDefault ["HG_Owner", objNull];
    private _vars = _thisVehicleHash getOrDefault ["vars", []];

    [{!isNull (_this select 0)}, {
        params ["_thisVehicle", "_posASL", "_fuel", "_vectorDirAndUp", "_hitPointDamage", "_turretMagazines", "_inventory", "_HG_Owner", "_vars"];

        // Restore the vehicle's attributes
        _thisVehicle enableSimulationGlobal false;
        
        _thisVehicle setPosASL _posASL;
        _thisVehicle setVectorDirAndUp _vectorDirAndUp;
        _thisVehicle setFuel _fuel;

        _thisVehicle enableSimulationGlobal true;

        [_thisVehicle,_turretMagazines] call FUNC(loadTurretMagazines);
        [_thisVehicle,_hitPointDamage] call FUNC(loadVehicleHits);
        [_thisVehicle,_inventory] call FUNC(loadVehicleInventory);
		
		//set vehicle ownerwith HG_Owner
        if (!isNil "_HG_Owner") then {
            _thisVehicle setVariable ["HG_Owner", _HG_Owner, true];
        };
		
		//added HG vehicle lock
		[_thisVehicle, 2] call HG_fnc_lock;

        [_vars,_thisVehicle] call FUNC(loadObjectVars);

    }, [_thisVehicle, _posASL, _fuel, _vectorDirAndUp, _hitPointDamage, _turretMagazines, _inventory, _HG_Owner, _vars], 10, {ERROR_1("Vehicle nullcheck timeout. Vehiclehash: %1",_this select 1)}] call CBA_fnc_waitUntilAndExecute;

} forEach _vehiclesData;

// --- A.I.M. v812+ Architecture: Delete SQLite Killed Vehicles ---
private _killedVarnamesKey = format ["%1_killedVarnames", _missionTag];
private _killedVarnames = [_killedVarnamesKey, [[],[],[]]] call A3M_fnc_dbGetSecure;
private _killedVehiclesVarnames = _killedVarnames param [1,[]];

{
    private _editorVehicle = call compile _x;
    if (!isNil "_editorVehicle") then {deleteVehicle _editorVehicle};
} forEach _killedVehiclesVarnames;
