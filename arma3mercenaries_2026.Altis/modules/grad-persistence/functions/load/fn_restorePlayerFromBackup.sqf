/*

To execute the command as an admin, you can enter the following in the admin console:

["playerUID", save#] call restorePlayerFromBackup;

Restore the 5th backup (the oldest one):

["playerUID", 5] call restorePlayerFromBackup;

This command will restore the player's data from the 5th backup file.

Load the current most recent save:

["playerUID", 1] call restorePlayerFromBackup;

example of restoring the 2nd backup, as the 1st one is the one that is usually corrupted:

["76561197997216797", 2] call restorePlayerFromBackup;

This command will restore the player's data from the most recent backup file.

///////////////////////////////

Ensure your description.ext includes the function definitions.

description.ext

class CfgFunctions {
    class MyFunctions {
        class savePlayerBackup {
            file = "scripts\savePlayerBackup.sqf";
        };
        class restorePlayerFromBackup {
            file = "scripts\restorePlayerFromBackup.sqf";
        };
    };
};



///////////////////////////////////
Schedule Regular Backups
You can schedule the savePlayerBackup.sqf script to run periodically for each player.

Example:

[] spawn {
    while {true} do {
        {
            [_x] call savePlayerBackup;
        } forEach allPlayers;
        sleep 1800; // Backup every 30 minutes
    };
};




*/

#include "script_component.hpp"

// Function to restore player data from a specified backup
params ["_uid", "_backupIndex"];

// Get the mission tag
private _missionTag = [] call GRAD_persistence_fnc_getMissionTag;

// Exit if the UID is empty
if (_uid == "") exitWith {};

// --- A.I.M. v812+ Architecture: SQLite Backup Retrieval ---
private _backupIndexKey = format ["%1_playerBackups_%2", _missionTag, _uid];
private _backupHistory = [_backupIndexKey, []] call A3M_fnc_dbGetSecure;

// Exit if no backups exist or index out of range
if (count _backupHistory == 0) exitWith {
    ERROR_1("No backups found for UID %1.", _uid);
};

if (count _backupHistory < _backupIndex) exitWith {
    ERROR_1("Backup index %1 out of range. Max is %2.", _backupIndex, count _backupHistory);
};

// Retrieve the specific backup key (Index 1 = newest/last, higher index = older)
// Since we pushBack new backups, the newest is at the end of the array.
// To make index 1 the newest (as per script docs), we reverse the logic:
private _targetKey = _backupHistory select ((count _backupHistory) - _backupIndex);

// Fetch the backed up HashMap
private _restoredDataHash = [_targetKey, createHashMap, true] call A3M_fnc_dbGetSecure;

if (count _restoredDataHash == 0) exitWith {
    ERROR_1("Failed to load backup data from SQLite key %1.", _targetKey);
};

// Set the restored data as the new LIVE data for the player
private _livePlayerKey = format ["%1_player_%2", _missionTag, _uid];
[_livePlayerKey, _restoredDataHash] call A3M_fnc_dbSetSecure;

diag_log format ["%1: Successfully restored player %2 to backup %3.", ADDON, _uid, _targetKey];
"Player backup restored successfully. They must reconnect to load it." remoteExec ["systemChat", remoteExecutedOwner];
