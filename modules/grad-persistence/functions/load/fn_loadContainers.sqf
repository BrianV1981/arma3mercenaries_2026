/*
    arma3mercenaries_fn_loadContainers.sqf

    gradPersistence load containers script fn_loadContainers.sqf
    Enhanced By: BrianV1981

    MODIFICATION NOTES (A.I.M. SQLite V812+ Architecture):
    - Completely bypasses profileNamespace and legacy CBA_HASH logic.
    - Connects directly to the A.I.M. SQLite database via A3M_fnc_dbGetSecure.
    - Uses Per-Entity loading and Index arrays.
*/

#include "script_component.hpp"

// Ensure the script is only executed on the server
if (!isServer) exitWith {};

// Initialize the mission-specific tag for namespacing
private _missionTag = [] call FUNC(getMissionTag);
private _containersTag = _missionTag + "_containers";

// --- A.I.M. v812+ Architecture: SQLite Per-Entity Loading ---
private _countKey = format ["%1_COUNT", _containersTag];
diag_log format ["[A3M DEBUG] Fetching count using key: %1", _countKey];
private _dbCount = [_countKey, -1, false] call A3M_fnc_dbGetSecure;
diag_log format ["[A3M DEBUG] Received dbCount: %1 (Type: %2)", _dbCount, typeName _dbCount];

private _containersData = [];

if (_dbCount > -1) then {
    diag_log format ["[A3M DEBUG] dbCount > -1 is true! Starting loop from 0 to %1", _dbCount - 1];
    // New Iterative Architecture
    for "_i" from 0 to (_dbCount - 1) do {
        private _uniqueEntityKey = format ["%1_cont_%2", _containersTag, _i];
        private _entityData = [_uniqueEntityKey, [], false] call A3M_fnc_dbGetSecure;
        
        if (count _entityData > 0) then {
            _containersData pushBack _entityData;
            diag_log format ["[A3M DEBUG] Successfully loaded %1", _uniqueEntityKey];
        } else {
            diag_log format ["[A3M DEBUG] FAILED to load %1 (Returned Empty)", _uniqueEntityKey];
        };
    };
} else {
    diag_log "[A3M DEBUG] dbCount was <= -1, skipping loop.";
};

// Process each saved container from the saved data
{
    // Extract the saved data for the current container
    private _thisContainerData = _x;
    
    // --- PHASE 10: FLAT ARRAY OVERHAUL ---
    // [0:type, 1:posASL, 2:dirAndUp, 3:damage, 4:inventory, 5:fortOwner, 6:isStorage, 7:mmOwner, 8:lbmMoney, 9:vars, 10:varName]
    
    _thisContainerData params [
        "_type",
        "_posASL",
        "_vectorDirAndUp",
        "_damage",
        "_inventory",
        "_fortOwner",
        "_isGradMoneymenuStorage",
        "_mmOwner",
        "_thisLbmMoney",
        "_vars",
        ["_vehVarName", ""]
    ];

    // Initialize the container as null and a flag for checking if it's an editor-placed vehicle
    private _thisContainer = objNull;
    private _editorVehicleFound = false;

    // Check if the container was an editor-placed vehicle that already exists in the mission
    if (_vehVarName != "") then {
        private _editorVehicle = call compile _vehVarName;
        if (!isNil "_editorVehicle") then {
            _thisContainer = _editorVehicle;
            _editorVehicleFound = true; // Mark that an existing vehicle was found
        };
    };

    // If the container was not an editor-placed vehicle, create it anew
    if (!_editorVehicleFound) then {
        _thisContainer = createVehicle [_type, [0,0,0], [], 0, "CAN_COLLIDE"];

        // Assign the saved variable name to the newly created container
        if (_vehVarName != "") then {
            [_thisContainer, _vehVarName] remoteExec ["setVehicleVarName", 0, _thisContainer];
        };
    };

    // Wait until the container is fully created (not null) before applying saved attributes
    [{!isNull (_this select 0)}, {
        params ["_thisContainer", "_thisContainerData"];

        // Re-extract inside the scheduled environment
        _thisContainerData params [
            "_type", "_posASL", "_vectorDirAndUp", "_damage", "_inventory", 
            "_fortOwner", "_isGradMoneymenuStorage", "_mmOwner", "_thisLbmMoney", "_vars", "_vehVarName"
        ];
        
        // Desanitize safely
        private _gradFortificationsOwner = if (_fortOwner == "") then { objNull } else { _fortOwner };
        private _gradMoneymenuOwner = if (_mmOwner == "") then { objNull } else { _mmOwner };

        // Apply the saved position, direction, and damage to the container
        _thisContainer setVectorDirAndUp _vectorDirAndUp;
        _thisContainer setPosASL _posASL;
        _thisContainer setDamage _damage;

        // Restore the container's inventory
        [_thisContainer, _inventory] call FUNC(loadVehicleInventory);

        // Reapply the grad fortifications owner variable (Always apply it so the save filter catches it next time)
        _thisContainer setVariable ["grad_fortifications_fortOwner", _gradFortificationsOwner, true];

        // Initialize the container if it's part of the grad fortifications system
        if ((_gradFortificationsOwner isEqualType "" || {!isNull _gradFortificationsOwner}) && {isClass (missionConfigFile >> "CfgFunctions" >> "GRAD_fortifications")}) then {
            [_thisContainer, objNull] remoteExec ["grad_fortifications_fnc_initFort", 0, true];
        };

        // Handle grad moneymenu storage if applicable
        if (_isGradMoneymenuStorage) then {
            if !(objNull isEqualTo _gradMoneymenuOwner) then {
                [_thisContainer, _gradMoneymenuOwner] remoteExec ["grad_moneymenu_fnc_setStorage", 0, true];
            } else {
                [_thisContainer] remoteExec ["grad_moneymenu_fnc_setStorage", 0, true];
            };

            // Set the saved money variable
            if (_thisLbmMoney isEqualType 0 && {_thisLbmMoney > 0}) then {
                _thisContainer setVariable ["grad_lbm_myFunds", _thisLbmMoney, true];
            };
        };

        // Load and apply any additional saved variables to the container
        [_vars, _thisContainer] call FUNC(loadObjectVars);

    }, [_thisContainer, _thisContainerData]] call CBA_fnc_waitUntilAndExecute;

} forEach _containersData; // End of container processing

// --- A.I.M. v812+ Architecture: Delete SQLite Killed Containers ---
private _killedVarnamesKey = format ["%1_killedVarnames", _missionTag];
private _killedVarnames = [_killedVarnamesKey, [[],[],[]]] call A3M_fnc_dbGetSecure;
private _killedContainersVarnames = _killedVarnames param [2, []];

{
    private _editorVehicle = call compile _x;
    if (!isNil "_editorVehicle") then { deleteVehicle _editorVehicle };
} forEach _killedContainersVarnames;
