/*
    File: fn_saveGradFortificationsStatics.sqf
    Author: Gruppe Adler (Original), BrianV1981 (Modifications)
    Date: 4/23/2025

    Description:
        Collects data for static objects identified as GRAD Fortifications (based on the
        presence of the 'grad_fortifications_fortOwner' variable) and saves it
        to the persistent storage.

    MODIFICATION NOTES (Namespace Separation):
    - Retrieves the persistence configuration for the 'fortifications' category
      from the global GVAR(categoryConfigMap).
    - Determines the specific profileNamespace defined for fortifications.
    - Saves the collected fortification data (_gradFortificationsData) into this
      dedicated namespace using a standard key (_missionTag + "_data").
    - No longer uses the old combined key (_missionTag + "_gradFortificationsStatics")
      in the default profile namespace for saving this specific data.
    - Removed the call to FUNC(getSaveData) as this function is now only concerned
      with *saving* data to the new location, not reading/modifying existing data
      from the profileNamespace during the save process.
*/

#include "script_component.hpp"

if (!isServer) exitWith {};

params [["_area",false],["_allVariableClasses",[]]]; // Parameters remain the same

// --- Retrieve Category Namespace Configuration ---
// A.I.M. v816 Architecture: Removed obsolete profileNamespace config checks
private _missionTag = [] call FUNC(getMissionTag);
private _namespace = _missionTag + "_fortifications";
// --- End Namespace Configuration ---


// Get the mission tag (still useful for internal variables if needed)
private _missionTag = [] call FUNC(getMissionTag);

// Filter custom variables relevant only to fortifications (if any were defined with varNamespace = "gradFortificationsStatic")
// Note: The original code checks for "gradFortificationsStatic" namespace in custom vars.
// This might need adjustment if you want custom variables saved alongside fortifications
// to follow the new namespace system. For now, we keep the original filtering logic.
private _allGradFortificationsVariableClasses = _allVariableClasses select {
    ([_x,"varNamespace",""] call BIS_fnc_returnConfigEntry) == "gradFortificationsStatic"
};

// --- Collect Fortification Data ---
// Define the area for filtering if provided
if (_area isEqualType []) then {
    _area params ["_center","_a","_b",["_angle",0],["_isRectangle",false],["_c",-1]];
    if (isNil "_b") then {_b = _a};
    _area = [_center,_a,_b,_angle,_isRectangle,_c];
};

// 1. RESTORED & ENHANCED: The BrianV1981 Target Filter
// Changed "Static" to "All" so it catches non-static props like water tanks
// Added AllVehicles exclusion to prevent scooping up MRAPs and Trucks
// Added Container exclusion to prevent scooping up Cargo Nets and Medical Boxes
private _gradFortificationsStatics = (allMissionObjects "All") select {
    !isNil {_x getVariable "grad_fortifications_fortOwner"} &&
    {!(_x isKindOf "AllVehicles")} &&
    {!( (_x isKindOf "ThingX") && !(_x isKindOf "Static") )}
};

// A.I.M. v812+ Architecture: Instead of one massive array, we track the keys in an Index
private _dbIndexList = [];

{
    // Apply filters: not CBA dummy, not blacklisted, within area (if specified)
    if (
        typeOf _x != "CBA_NamespaceDummy" &&
        {!([_x] call FUNC(isBlacklisted))} &&
        {if (_area isEqualType false) then {true} else {_x inArea _area}}
    ) then {

        // --- PHASE 10: FLAT ARRAY OVERHAUL ---
        // [0:type, 1:posASL, 2:dirAndUp, 3:damage, 4:isStorage, 5:mmOwner, 6:lbmMoney, 7:fortOwner, 8:vars]
        
        private _mmOwner = _x getVariable ["grad_moneymenu_owner", objNull];
        if (isNull _mmOwner) then { _mmOwner = ""; }; 

        // Save fort owner UID/Side/Group name (Handle complex types)
        private _fortOwner = _x getVariable ["grad_fortifications_fortOwner",objNull];
        private _ownerToSave = switch (typeName _fortOwner) do {
            case "OBJECT": { if (isNull _fortOwner) then { "" } else { getPlayerUID _fortOwner } }; 
            case "GROUP": { format ["GROUP:%1", groupId _fortOwner] }; 
            case "SIDE": { str _fortOwner }; 
            default { "" }; 
        };

        private _posASL = getPosASL _x;
        private _aceParentVar = "";
        if (!isNull attachedTo _x) then {
            _posASL = _posASL vectorAdd [5, 0, 1]; // Offset attached dummy objects
            _aceParentVar = vehicleVarName (attachedTo _x);
        };

        private _thisGradFortificationsData = [
            typeOf _x,
            _posASL,
            [vectorDir _x, vectorUp _x],
            damage _x,
            _x getVariable ["grad_moneymenu_isStorage",false],
            _mmOwner,
            _x getVariable ["grad_lbm_myFunds",0],
            _ownerToSave,
            [_allGradFortificationsVariableClasses,_x] call FUNC(saveObjectVars),
            _aceParentVar
        ];

        // --- A.I.M. Per-Entity Save Pipeline ---
        private _uniqueEntityKey = format ["%1_fort_%2", _namespace, _forEachIndex];
        [_uniqueEntityKey, _thisGradFortificationsData] call A3M_fnc_dbSetSecure;
    };
} forEach _gradFortificationsStatics;


// --- Save the COUNT integer to the DB ---
private _countKey = format ["%1_COUNT", _namespace];
diag_log format ["%1: Saving %2 fortifications to SQLite via COUNT '%3'.", ADDON, count _gradFortificationsStatics, _countKey];
[_countKey, count _gradFortificationsStatics] call A3M_fnc_dbSetSecure;

// ALSO delete the old INDEX array so we don't duplicate logic if mixing load systems
private _indexKey = format ["%1_INDEX", _namespace];
[_indexKey, []] call A3M_fnc_dbSetSecure;

diag_log format ["%1: Finished saving fortifications to SQLite database.", ADDON];