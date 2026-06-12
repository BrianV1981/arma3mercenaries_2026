#include "script_component.hpp"

// Function to create a backup of a player's data
params ["_unit", "_uid"];

// Get the mission tag
private _missionTag = [] call GRAD_persistence_fnc_getMissionTag;

// If the UID is not provided, get it from the player unit
if (isNil "_uid") then {
    _uid = getPlayerUID _unit;
};

// Exit if the UID is empty
if (_uid == "") exitWith {};

// Retrieve the current live player state from SQLite
private _uniquePlayerKey = format ["%1_player_%2", _missionTag, _uid];
private _unitDataHash = [_uniquePlayerKey, createHashMap, true] call A3M_fnc_dbGetSecure;

if (count _unitDataHash == 0) exitWith { diag_log format ["%1: Backup failed. No live data found for %2", ADDON, _uid]; };

private _timestamp = floor time; 

// --- A.I.M. v812+ Architecture: SQLite Backup ---
// We manage a rolling list of the last 5 backup keys for this player
private _backupIndexKey = format ["%1_playerBackups_%2", _missionTag, _uid];
private _backupHistory = [_backupIndexKey, []] call A3M_fnc_dbGetSecure;

// Create the new backup key
private _newBackupKey = format ["%1_backup_%3", _backupIndexKey, _timestamp];

// Save the snapshot to SQLite
[_newBackupKey, _unitDataHash] call A3M_fnc_dbSetSecure;

// Update the rolling history
_backupHistory pushBack _newBackupKey;

// Limit to 5 backups
if (count _backupHistory > 5) then {
    // Delete the oldest backup payload from DB
    private _oldestKey = _backupHistory select 0;
    private _sqlDeletePattern = format ["%1", _oldestKey]; 
    "a3m_db_core" callExtension ["delete_like", [_sqlDeletePattern]]; // Delete exact key
    
    // Remove from history array
    _backupHistory deleteAt 0;
};

// Save updated history index to SQLite
[_backupIndexKey, _backupHistory] call A3M_fnc_dbSetSecure;
diag_log format ["%1: Created player backup for %2 at %3", ADDON, _uid, _newBackupKey];
