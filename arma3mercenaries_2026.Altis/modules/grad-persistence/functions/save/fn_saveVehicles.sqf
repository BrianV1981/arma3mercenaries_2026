/*

arma3mercenaries_fn_saveVehicle.sqf

gradPersistence save vehicle script fn_saveVehicle.sqf

enhanced by BrianV1981

*/

#include "script_component.hpp"

if (!isServer) exitWith {};

params [["_area",false],["_allVariableClasses",[]]];

if (_area isEqualType []) then {
    _area params ["_center","_a","_b",["_angle",0],["_isRectangle",false],["_c",-1]];
    if (isNil "_b") then {_b = _a};
    _area = [_center,_a,_b,_angle,_isRectangle,_c];
};

private _allVehicleVariableClasses = _allVariableClasses select {
    ([_x,"varNamespace",""] call BIS_fnc_returnConfigEntry) == "vehicle"
};

private _missionTag = [] call FUNC(getMissionTag);
private _vehiclesTag = _missionTag + "_vehicles";
private _foundVehiclesVarnames = GVAR(allFoundVarNames) select 1;

// Collect only vehicles that are tagged with the HG_Owner variable
private _allVehicles = vehicles select {
    !(_x isKindOf "Static") &&
    !((_x isKindOf "ThingX") && (([configfile >> "CfgVehicles" >> typeOf _x,"maximumLoad",0] call BIS_fnc_returnConfigEntry) > 0)) &&
    {alive _x} &&
    {!([_x] call FUNC(isBlacklisted))} &&
    {if (_area isEqualType false) then {true} else {_x inArea _area}} &&
    {(!isNil {_x getVariable "HG_Owner"}) || (!isNil {_x getVariable "grad_fortifications_myFortsHash"})}
};

// A.I.M. v812+ Architecture: DB Index Tracking
private _dbIndexList = [];

{
    private _thisVehicle = _x;
    private _hitPointDamage = getAllHitPointsDamage _thisVehicle;
    private _hitNames = [];
    private _hitDamages = [];
    if (count _hitPointDamage > 0) then {
        _hitNames = _hitPointDamage select 0;
        _hitDamages = _hitPointDamage select 2;
    };

    private _vehicleInventory = [_thisVehicle] call FUNC(getInventory);

    // native Arma 3 HashMap
    private _thisVehicleHash = createHashMap;

    private _vehVarName = vehicleVarName _thisVehicle;
    if (_vehVarName == "") then {
        _vehVarName = format ["A3M_Veh_%1_%2", round (random 1000000), _forEachIndex];
        _thisVehicle setVehicleVarName _vehVarName;
        [_thisVehicle, _vehVarName] remoteExec ["setVehicleVarName", 0, _thisVehicle];
    };
    if (_vehVarName != "") then {
        _thisVehicleHash set ["varName",_vehVarName];
        _foundVehiclesVarnames deleteAt (_foundVehiclesVarnames find _vehVarName);
    };

    private _posASL = getPosASL _thisVehicle;
    private _aceParentVar = "";
    
    if (!isNull attachedTo _thisVehicle) then {
        _posASL = _posASL vectorAdd [5, 0, 1]; // Offset attached dummy objects so they spawn safely next to the vehicle
        _aceParentVar = vehicleVarName (attachedTo _thisVehicle);
    };

    // --- ACE Cargo Stranded Static Interceptor ---
    // When ACE Cargo loads statics (unlike boxes), it hides them and strands them at their original physical location.
    // We must search every truck's ace_cargo_loaded array to find which truck this static actually belongs to.
    if (_aceParentVar == "" && {_thisVehicle isKindOf "StaticWeapon"}) then {
        {
            private _cargoArray = _x getVariable ["ace_cargo_loaded", []];
            if (_thisVehicle in _cargoArray) exitWith {
                _posASL = (getPosASL _x) vectorAdd [5, 0, 1]; // Teleport stranded static to truck's location, offset by 5m
                _aceParentVar = vehicleVarName _x;
            };
        } forEach vehicles;
    };

    _thisVehicleHash set ["type",typeOf _thisVehicle];
    _thisVehicleHash set ["posASL",_posASL];
    _thisVehicleHash set ["vectorDirAndUp",[vectorDir _thisVehicle,vectorUp _thisVehicle]];
    _thisVehicleHash set ["aceParentVar", _aceParentVar];
    _thisVehicleHash set ["hitpointDamage",[_hitNames,_hitDamages]];
    _thisVehicleHash set ["fuel",fuel _thisVehicle];
    _thisVehicleHash set ["hasCrew",{!isPlayer _thisVehicle} count (crew _thisVehicle) > 0];
    _thisVehicleHash set ["side",str (side _thisVehicle)];
    _thisVehicleHash set ["turretMagazines", magazinesAllTurrets _thisVehicle];
    _thisVehicleHash set ["inventory", _vehicleInventory];
    _thisVehicleHash set ["HG_Owner",_thisVehicle getVariable "HG_Owner"];

    private _thisVehicleVars = [_allVehicleVariableClasses,_thisVehicle] call FUNC(saveObjectVars);
    _thisVehicleHash set ["vars",_thisVehicleVars];

    // --- A.I.M. Per-Entity Save Pipeline ---
    private _uniqueEntityKey = format ["%1_veh_%2", _vehiclesTag, _forEachIndex];
    [_uniqueEntityKey, _thisVehicleHash] call A3M_fnc_dbSetSecure;

} forEach _allVehicles;

// --- Save the COUNT integer for Iterative Architecture ---
private _countKey = format ["%1_COUNT", _vehiclesTag];
[_countKey, count _allVehicles] call A3M_fnc_dbSetSecure;

// ALSO delete the old INDEX array so we don't duplicate logic if mixing load systems
private _indexKey = format ["%1_INDEX", _vehiclesTag];
[_indexKey, []] call A3M_fnc_dbSetSecure;

// --- A.I.M. v812+ Architecture: SQLite Killed Tracker ---
// all _foundVehiclesVarnames that were not saved must have been removed or killed --> add to killedVarNames array
private _killedVarnamesKey = format ["%1_killedVarnames", _missionTag];
private _killedVarnames = [_killedVarnamesKey, [[],[],[]]] call A3M_fnc_dbGetSecure; // Index 1 is for vehicles
private _killedVehiclesVarnames = _killedVarnames param [1,[]];

_killedVehiclesVarnames append _foundVehiclesVarnames;
_killedVehiclesVarnames arrayIntersect _killedVehiclesVarnames; // remove duplicates
_killedVarnames set [1,_killedVehiclesVarnames];

[_killedVarnamesKey, _killedVarnames] call A3M_fnc_dbSetSecure;
