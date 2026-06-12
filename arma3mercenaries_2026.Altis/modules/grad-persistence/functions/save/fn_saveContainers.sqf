/*
    arma3mercenaries_fn_saveContainers.sqf

    gradPersistence save containers script fn_saveContainers.sqf
    Enhanced By: BrianV1981

    MODIFICATION NOTES (A.I.M. SQLite V812+ Architecture):
    - Completely bypasses profileNamespace and legacy CBA_HASH logic.
    - Connects directly to the A.I.M. SQLite database via A3M_fnc_dbGetSecure.
    - Uses Per-Entity saving and Index arrays.
*/

#include "script_component.hpp"

// Ensure the script is only executed on the server
if (!isServer) exitWith {};

// Parameters: _area for defining the area to save containers from, _allVariableClasses for filtering variables to be saved
params [["_area", false], ["_allVariableClasses", []]];

// Process the _area parameter to ensure it has a consistent format
if (_area isEqualType []) then {
    _area params ["_center", "_a", "_b", ["_angle", 0], ["_isRectangle", false], ["_c", -1]];
    if (isNil "_b") then { _b = _a };
    _area = [_center, _a, _b, _angle, _isRectangle, _c];
};

// Filter to identify variable classes related to containers
private _allContainerVariableClasses = _allVariableClasses select {
    ([_x, "varNamespace", ""] call BIS_fnc_returnConfigEntry) == "container"
};

// Initialize the mission-specific tag for namespacing and the container data storage
private _missionTag = [] call FUNC(getMissionTag);
private _containersTag = _missionTag + "_containers";
private _foundContainersVarnames = GVAR(allFoundVarNames) select 2;

// Retrieve all containers (vehicles) and configure the saving mode from the mission config
private _allContainers = vehicles;
private _saveContainersMode = [missionConfigFile >> "CfgGradPersistence", "saveContainers", 1] call BIS_fnc_returnConfigEntry;

// Filter containers that have a recognized owner tag (mimicking gradstatics)
_allContainers = _allContainers select {
    (_x isKindOf "ThingX") &&
    !(_x isKindOf "Static") &&
    {alive _x} &&
    {!([_x] call FUNC(isBlacklisted))} &&
    {
        // ABSOLUTE STRICT A3M FILTER: Only save boxes that have a grad_fortifications tag.
        (!isNil {_x getVariable "grad_fortifications_fortOwner"}) || (!isNil {_x getVariable "grad_fortifications_myFortsHash"})
    } &&
    {if (_area isEqualType false) then {true} else {_x inArea _area}}
};

// A.I.M. v812+ Architecture: DB Index Tracking
private _dbIndexList = [];

// Process each container to save relevant data
{
    private _containerInventory = [_x] call FUNC(getInventory);

    private _vehVarName = vehicleVarName _x;
    if (_vehVarName != "") then {
        _foundContainersVarnames deleteAt (_foundContainersVarnames find _vehVarName);
    };

    // --- PHASE 10: FLAT ARRAY OVERHAUL ---
    // [0:type, 1:posASL, 2:dirAndUp, 3:damage, 4:inventory, 5:fortOwner, 6:isStorage, 7:mmOwner, 8:lbmMoney, 9:vars, 10:varName]
    
    private _rawFortOwner = _x getVariable ["grad_fortifications_fortOwner", objNull];
    private _fortOwner = switch (typeName _rawFortOwner) do {
        case "OBJECT": { if (isNull _rawFortOwner) then { "" } else { getPlayerUID _rawFortOwner } }; 
        case "GROUP": { format ["GROUP:%1", groupId _rawFortOwner] }; 
        case "SIDE": { str _rawFortOwner }; 
        default { "" }; 
    };
    
    private _mmOwner = _x getVariable ["grad_moneymenu_owner", objNull];
    if (isNull _mmOwner) then { _mmOwner = ""; }; // Safe flat-array fallback

    private _posASL = getPosASL _x;
    private _aceParentVar = "";
    if (!isNull attachedTo _x) then {
        _posASL = _posASL vectorAdd [5, 0, 1]; // Offset attached containers so they spawn safely next to the vehicle
        _aceParentVar = vehicleVarName (attachedTo _x);
    };

    private _thisContainerData = [
        typeOf _x,
        _posASL,
        [vectorDir _x, vectorUp _x],
        damage _x,
        _containerInventory,
        _fortOwner,
        _x getVariable ["grad_moneymenu_isStorage", false],
        _mmOwner,
        _x getVariable ["grad_lbm_myFunds", 0],
        [_allContainerVariableClasses, _x] call FUNC(saveObjectVars),
        _vehVarName,
        _aceParentVar
    ];

    // --- A.I.M. Per-Entity Save Pipeline ---
    private _uniqueEntityKey = format ["%1_cont_%2", _containersTag, _forEachIndex];
    [_uniqueEntityKey, _thisContainerData] call A3M_fnc_dbSetSecure;

} forEach _allContainers; // End of container processing

// --- Save the COUNT integer for Iterative Architecture ---
private _countKey = format ["%1_COUNT", _containersTag];
[_countKey, count _allContainers] call A3M_fnc_dbSetSecure;

// ALSO delete the old INDEX array so we don't duplicate logic if mixing load systems
private _indexKey = format ["%1_INDEX", _containersTag];
[_indexKey, []] call A3M_fnc_dbSetSecure;

// --- A.I.M. v812+ Architecture: SQLite Killed Tracker ---
// Handle any container variable names that were not saved (e.g., removed or killed)
private _killedVarnamesKey = format ["%1_killedVarnames", _missionTag];
private _killedVarnames = [_killedVarnamesKey, [[],[],[]]] call A3M_fnc_dbGetSecure; // Index 2 is for containers
private _killedContainersVarnames = _killedVarnames param [2, []];

_killedContainersVarnames append _foundContainersVarnames;
_killedContainersVarnames arrayIntersect _killedContainersVarnames;
_killedVarnames set [2, _killedContainersVarnames];

// Save the updated tracking array to SQLite
[_killedVarnamesKey, _killedVarnames] call A3M_fnc_dbSetSecure;
