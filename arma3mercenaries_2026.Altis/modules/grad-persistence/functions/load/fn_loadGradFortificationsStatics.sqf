/*
    File: fn_loadGradFortificationsStatics.sqf
    Author: Gruppe Adler (Original), BrianV1981 (Modifications)
    Date: 4/23/2025

    Description:
        Loads GRAD Fortification data from persistent storage and spawns the corresponding
        static objects in the mission.

    MODIFICATION NOTES (A.I.M. SQLite V812+ Architecture):
    - Completely bypasses profileNamespace and legacy CBA_HASH logic.
    - Connects directly to the A.I.M. SQLite database via A3M_fnc_dbGetSecure.
    - Loads the INDEX array first, then fetches each fortification entity individually.
    - Retains all original asynchronous engine spawning and variable application logic.
*/

#include "script_component.hpp"

if (!isServer) exitWith {};

// --- Retrieve Category Namespace Configuration ---
// A.I.M. v816 Architecture: Removed obsolete profileNamespace config checks
private _missionTag = [] call FUNC(getMissionTag);
private _targetNamespace = _missionTag + "_fortifications";
// --- End Namespace Configuration ---

// --- A.I.M. v812+ Architecture: SQLite Per-Entity Loading ---
private _countKey = format ["%1_COUNT", _targetNamespace];
diag_log format ["%1: Attempting to load fortification count '%2' from SQLite.", ADDON, _countKey];

// Fetch the count of unique entity keys
private _dbCount = [_countKey, -1, false] call A3M_fnc_dbGetSecure;

private _gradFortificationsData = [];
private _loadedFrom = "SQLite (Per-Entity)";

if (_dbCount > -1) then {
    diag_log format ["%1: Found %2 fortifications in SQLite COUNT. Fetching entities...", ADDON, _dbCount];
    
    for "_i" from 0 to (_dbCount - 1) do {
        private _uniqueEntityKey = format ["%1_fort_%2", _targetNamespace, _i];
        private _entityData = [_uniqueEntityKey, [], false] call A3M_fnc_dbGetSecure;
        
        // Add to our processing array if valid (not empty)
        if (count _entityData > 0) then {
            _gradFortificationsData pushBack _entityData;
        } else {
            diag_log format ["%1: WARNING - SQLite returned empty data for key '%2'.", ADDON, _uniqueEntityKey];
        };
    };
} else {
    diag_log format ["%1: SQLite COUNT empty or not found. No fortifications to load.", ADDON];
};

// --- Check if data loading was successful ---
if (_gradFortificationsData isEqualTo []) exitWith {
     diag_log format ["%1: Fortification data is empty. Skipping fortification spawning.", ADDON];
};

diag_log format ["%1: Loading %2 fortifications. Data source: %3.", ADDON, count _gradFortificationsData, _loadedFrom];


// --- Process Fortification Data and Spawn Objects ---
{
    private _thisGradFortificationsData = _x; 
    
    // --- PHASE 10: FLAT ARRAY OVERHAUL ---
    // [0:type, 1:posASL, 2:dirAndUp, 3:damage, 4:isStorage, 5:mmOwner, 6:lbmMoney, 7:fortOwner, 8:vars]

    _thisGradFortificationsData params [
        ["_type", ""],
        ["_posASL", [0,0,0]],
        ["_vectorDirAndUp", [[0,1,0],[0,0,1]]],
        ["_damage", 0],
        ["_isGradMoneymenuStorage", false],
        ["_mmOwner", ""],
        ["_thisLbmMoney", 0],
        ["_fortOwner", ""],
        ["_vars", []],
        ["_vehVarName", ""],
        ["_aceParentVar", ""]
    ];

    if (_type == "") then {
        diag_log format ["%1: WARNING - Skipping fortification entry due to missing 'type'.", ADDON];
        continue; // Skip this entry
    };
    
    // Desanitize safely
    private _gradFortificationsOwner = if (_fortOwner == "") then { objNull } else { _fortOwner };
    private _gradMoneymenuOwner = if (_mmOwner == "") then { objNull } else { _mmOwner };

    // --- Create the object ---
    private _thisGradFortificationsStatic = createVehicle [_type, [0,0,0], [], 0, "CAN_COLLIDE"]; // Create away first


    // --- Wait until object is created and apply properties ---
    [{!isNull (_this select 0)}, {
        params ["_thisGradFortificationsStatic", "_posASL", "_vectorDirAndUp", "_damage", "_isGradMoneymenuStorage", "_gradMoneymenuOwner", "_thisLbmMoney", "_gradFortificationsOwner", "_vars", "_aceParentVar"];

        // Apply position, orientation, damage
        _thisGradFortificationsStatic setVectorDirAndUp _vectorDirAndUp;
        _thisGradFortificationsStatic setPosASL _posASL; // Set position after orientation
        _thisGradFortificationsStatic setDamage _damage;


        // --- Restore Fortification Owner ---
        private _restoredOwner = objNull; // Default to null
        if (_gradFortificationsOwner isEqualType "" || {!isNull _gradFortificationsOwner}) then {
            private _savedOwnerData = _gradFortificationsOwner;
            if (_savedOwnerData isEqualType "" && {_savedOwnerData != ""}) then {
                if (_savedOwnerData select [0, 6] == "GROUP:") then {
                     diag_log format ["%1: WARNING - Group ownership restoration for %2 (%3) is currently basic/unreliable.", ADDON, typeOf _thisGradFortificationsStatic, _posASL];
                     _restoredOwner = grpNull; // Represent group ownership marker, but maybe not the actual group
                } else {
                    if (_savedOwnerData select [0, 5] == "SIDE:") then {
                         // Restore side
                         _restoredOwner = call compile (_savedOwnerData select [5]); // e.g., call compile "WEST" -> west
                    } else {
                        // Assume it's a player UID
                        {
                            if (getPlayerUID _x == _savedOwnerData) exitWith {
                                _restoredOwner = _x; // Found player object by UID
                            };
                        } forEach allPlayers; // Check currently connected players

                        if (isNull _restoredOwner) then {
                             diag_log format ["%1: WARNING - Could not find player object for UID '%2' for fortification %3 (%4). Owner might be offline.", ADDON, _savedOwnerData, typeOf _thisGradFortificationsStatic, _posASL];
                             _restoredOwner = _savedOwnerData; // Store the UID string if player not found
                        };
                    };
                };
            } else {
                 if (_savedOwnerData isEqualType objNull) then { _restoredOwner = _savedOwnerData; };
            };
        };
        
        _thisGradFortificationsStatic setVariable ["grad_fortifications_fortOwner", _restoredOwner, true]; // Set restored owner (object, side, group marker, or UID string)


        // Re-initialize grad_fortifications functionality if present
        if (isClass (missionConfigFile >> "CfgFunctions" >> "GRAD_fortifications")) then {
            // Pass the restored owner to initFort if it accepts it, otherwise just the object
            // Check grad_fortifications documentation if fnc_initFort uses the owner. Assuming objNull for now.
            [_thisGradFortificationsStatic, objNull] remoteExec ["grad_fortifications_fnc_initFort", 0, true];
        };

        // --- Restore grad_moneymenu storage ---
        if (_isGradMoneymenuStorage) then {
            if !(objNull isEqualTo _gradMoneymenuOwner) then {
                [_thisGradFortificationsStatic, _gradMoneymenuOwner] remoteExec ["grad_moneymenu_fnc_setStorage", 0, true];
            } else {
                [_thisGradFortificationsStatic] remoteExec ["grad_moneymenu_fnc_setStorage", 0, true];
            };

            if (_thisLbmMoney > 0) then {
                _thisGradFortificationsStatic setVariable ["grad_lbm_myFunds", _thisLbmMoney, true];
            };
        };


        // --- Load Custom Variables ---
        [_vars, _thisGradFortificationsStatic] call FUNC(loadObjectVars);

        // --- A.I.M. ACE Cargo Auto-Load ---
        if (_aceParentVar != "") then {
            // Because parent vehicles spawn in a parallel script, we wait 2 seconds to guarantee they exist
            [{
                params ["_thisGradFortificationsStatic", "_aceParentVar"];
                private _parentVeh = call compile _aceParentVar;
                if (!isNil "_parentVeh" && {!isNull _parentVeh}) then {
                    private _lockState = locked _parentVeh;
                    if (_lockState >= 2) then { _parentVeh lock 0; };
                    [_thisGradFortificationsStatic, _parentVeh, true] call ace_cargo_fnc_loadItem;
                    if (_lockState >= 2) then { _parentVeh lock _lockState; };
                };
            }, [_thisGradFortificationsStatic, _aceParentVar], 2] call CBA_fnc_waitAndExecute;
        };

    }, [_thisGradFortificationsStatic, _posASL, _vectorDirAndUp, _damage, _isGradMoneymenuStorage, _gradMoneymenuOwner, _thisLbmMoney, _gradFortificationsOwner, _vars, _aceParentVar]] call CBA_fnc_waitUntilAndExecute; // Pass all needed vars

} forEach _gradFortificationsData;

diag_log format ["%1: Finished loading fortifications.", ADDON];