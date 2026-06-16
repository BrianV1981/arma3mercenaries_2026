/*
    arma3mercenaries\tasks\fn_openHVTTrackerMenu.sqf
    Description: Opens the HVT Satellite Tracking menu and populates active targets.
*/

if (!hasInterface) exitWith {};

// Removed broken server definition

if (isNil "A3M_fnc_clientSatelliteFeed") then {
    A3M_fnc_clientSatelliteFeed = {
        params ["_exactPos", "_taskId"];
        private _gridPos = mapGridPosition _exactPos;
        private _overlayText = format ["SIGINT DETECTED\nTARGET: HVT\nGRID: %1", _gridPos];
        
        // Execute BI Drone Feed
        [_exactPos, _overlayText, 500, 500, 75, 1, [], 0, true] spawn BIS_fnc_establishingShot;
        
        private _duration = missionNamespace getVariable ["A3M_HVT_Satellite_Duration", 15];
        
        // Wait for it to finish or be skipped
        [_duration] spawn {
            params ["_duration"];
            private _startTime = time;
            
            waitUntil {
                sleep 1; 
                !(missionNamespace getVariable ["BIS_fnc_establishingShot_playing", false]) || 
                (time - _startTime >= _duration)
            };
            
            if (missionNamespace getVariable ["BIS_fnc_establishingShot_playing", false]) then {
                missionNamespace setVariable ["BIS_fnc_establishingShot_playing", false];
            };
            
            // A3M Acknowledgment
            private _finalMsg = "<t align='left'><t size='0.8' color='#00FF00'>SATELLITE UPLINK</t><br/><t size='0.6' color='#FFFFFF'>Target acquired.<br/>Map has been marked with the HVT's location.</t></t>";
            [_finalMsg, 0.0, 0.1, 5, 0.5, 0, 795] spawn BIS_fnc_dynamicText;
        };
    };
};

if (isNil "A3M_fnc_onHVTTrackerSelChanged") then {
    A3M_fnc_onHVTTrackerSelChanged = {
        params ["_control", "_selectedIndex"];
        // Logic to update UI when a new HVT is selected (e.g. updating the cost if it were dynamic)
    };
};

if (isNil "A3M_fnc_buySatelliteSweep") then {
    A3M_fnc_buySatelliteSweep = {
        diag_log "[A3M DEBUG] SAT SWEEP: Button Clicked!";
        
        if (!(missionNamespace getVariable ["A3M_HVT_Satellite_Enabled", true])) exitWith {
            hint "Satellite sweeps are currently disabled.";
            diag_log "[A3M DEBUG] SAT SWEEP: Exited - Disabled.";
        };

        private _cooldown = missionNamespace getVariable ["A3M_HVT_Satellite_Cooldown", 300];
        private _lastSweep = missionNamespace getVariable ["A3M_HVT_Satellite_LastSweepTime", (time - _cooldown - 1)];
        if (time - _lastSweep < _cooldown) exitWith {
            private _timeLeft = ceil (_cooldown - (time - _lastSweep));
            hint format ["Satellite uplink is recharging...\nAvailable in %1 seconds.", _timeLeft];
            diag_log format ["[A3M DEBUG] SAT SWEEP: Exited - Cooldown active (%1s left).", _timeLeft];
        };

        private _display = findDisplay 9020;
        if (isNull _display) exitWith { diag_log "[A3M DEBUG] SAT SWEEP: Exited - Display null."; };
        private _listbox = _display displayCtrl 9021;
        
        private _selectedIndex = lbCurSel _listbox;
        diag_log format ["[A3M DEBUG] SAT SWEEP: Selected Index: %1", _selectedIndex];
        
        if (_selectedIndex == -1) exitWith {
            hint "Select an HVT first.";
        };
        
        private _taskId = _listbox lbData _selectedIndex;
        diag_log format ["[A3M DEBUG] SAT SWEEP: Selected Task ID: %1", _taskId];
        if (_taskId == "") exitWith { hint "Invalid HVT selected."; };
        
        private _cost = missionNamespace getVariable ["A3M_HVT_Satellite_Cost", 25000];
        private _playerFunds = player getVariable ["grad_lbm_myFunds", 0];
        diag_log format ["[A3M DEBUG] SAT SWEEP: Cost: %1 | Player Funds: %2", _cost, _playerFunds];
        
        if (_playerFunds < _cost) exitWith {
            diag_log "[A3M DEBUG] SAT SWEEP: Exited - Insufficient funds.";
            private _msg = format ["<t align='left'><t size='0.8' color='#FF0000'>SWEEP FAILED</t><br/><t size='0.6' color='#FFFFFF'>Insufficient funds. Requires $%1.</t></t>", _cost];
            [_msg, 0.0, 0.1, 5, 0.5, 0, 795] spawn BIS_fnc_dynamicText;
        };
        
        closeDialog 0; // Close the menu before initiating feed
        diag_log "[A3M DEBUG] SAT SWEEP: Dialog closed. Initiating remote execution...";
        
        private _deductMsg = format ["<t align='left'><t size='0.8' color='#00FF00'>SATELLITE UPLINK</t><br/><t size='0.6' color='#FFFFFF'>Re-tasking orbital asset...<br/>-$%1</t></t>", _cost];
        [_deductMsg, 0.0, 0.1, 5, 0.5, 0, 795] spawn BIS_fnc_dynamicText;
        
        // Delegate to server to get the exact position, since the client may not know the object if it's out of network range
        [_taskId, player, _cost] remoteExec ["A3M_fnc_serverSatelliteSweep", 2];
    };
};

// --- Open Dialog & Populate ---
createDialog "A3M_HVTTrackerDialog";
waitUntil { !isNull findDisplay 9020 };

private _display = findDisplay 9020;
private _listbox = _display displayCtrl 9021;
lbClear _listbox;

private _activeHVTsFound = false;

private _activeTasks = [];
diag_log "[A3M DEBUG] SAT TRACKER: Fetching all player tasks via BIS_fnc_tasksUnit...";
private _allPlayerTasks = player call BIS_fnc_tasksUnit;
diag_log format ["[A3M DEBUG] SAT TRACKER: Found %1 total player tasks.", count _allPlayerTasks];

{
    if (["assassination", _x] call BIS_fnc_inString) then {
        _activeTasks pushBackUnique _x;
    };
} forEach _allPlayerTasks;
diag_log format ["[A3M DEBUG] SAT TRACKER: Filtered 'assassination' tasks: %1", _activeTasks];

{
    private _taskId = _x;
    private _state = [_taskId] call BIS_fnc_taskState;
    diag_log format ["[A3M DEBUG] SAT TRACKER: Evaluating Task: %1 | State: %2", _taskId, _state];
    
    // Only display if it hasn't succeeded/failed/canceled
    if (_state != "SUCCEEDED" && _state != "FAILED" && _state != "CANCELED") then {
        _activeHVTsFound = true;
        
        private _taskDescArray = _taskId call BIS_fnc_taskDescription;
        diag_log format ["[A3M DEBUG] SAT TRACKER: Extracted Description Array: %1", _taskDescArray];
        
        private _taskTitle = if (typeName _taskDescArray == "ARRAY" && {count _taskDescArray > 1}) then { _taskDescArray select 1 } else { _taskId };
        if (typeName _taskTitle != "STRING") then { _taskTitle = str _taskTitle; };
        
        private _index = _listbox lbAdd _taskTitle;
        _listbox lbSetData [_index, _taskId];
    };
} forEach _activeTasks;

if (!_activeHVTsFound) then {
    _listbox lbAdd "No active HVT signals detected.";
    private _buyBtn = _display displayCtrl 9022;
    _buyBtn ctrlEnable false;
};

// Set dynamic cost text UI
// Set dynamic cost text UI
private _costAmount = missionNamespace getVariable ["A3M_HVT_Satellite_Cost", 25000];
private _costText = _display displayCtrl 9026;
_costText ctrlSetText format ["COST: $%1", _costAmount];
