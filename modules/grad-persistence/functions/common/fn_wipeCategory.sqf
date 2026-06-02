/*
    File: fn_wipeCategory.sqf
    Author: BrianV1981
    Date: 4/23/2024
    Description: Wipes a specific category from the SQLite database.
    Parameters: 
        0: STRING - The category key prefix to wipe (e.g., "my_persistent_mission_fortifications")
    Returns: Nothing.
    Execution: Server only. Call with e.g., ["my_persistent_mission_fortifications"] call GRAD_persistence_fnc_wipeCategory;
*/

#include "script_component.hpp" // Note: removed the trailing semicolon that was causing syntax errors

if (!isServer) exitWith {};

params [["_categoryPrefix", "", [""]]];

if (_categoryPrefix == "") exitWith {
    diag_log format ["%1: ERROR - Cannot wipe empty category prefix.", ADDON];
};

diag_log format ["%1: Attempting to wipe SQLite category pattern '%2_%%'.", ADDON, _categoryPrefix];

// --- A.I.M. v812+ Architecture: SQLite Category Wipe ---
// Use the Rust bridge to execute a wildcard delete (e.g. DELETE FROM store WHERE key LIKE 'my_persistent_mission_fortifications_%')
private _sqlDeletePattern = format ["%1_%%", _categoryPrefix];
"a3m_db_core" callExtension ["delete_like", [_sqlDeletePattern]];

diag_log format ["%1: Wipe successful for SQLite pattern '%2'.", ADDON, _sqlDeletePattern];