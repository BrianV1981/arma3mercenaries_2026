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
        if (!missionNamespace getVariable ["A3M_HVT_Satellite_Enabled", true]) exitWith {
            hint "Satellite sweeps are currently disabled.";
        };

        private _cooldown = missionNamespace getVariable ["A3M_HVT_Satellite_Cooldown", 300];
        private _lastSweep = missionNamespace getVariable ["A3M_HVT_Satellite_LastSweepTime", -_cooldown];
        if (time - _lastSweep < _cooldown) exitWith {
            private _timeLeft = ceil (_cooldown - (time - _lastSweep));
            hint format ["Satellite uplink is recharging...\nAvailable in %1 seconds.", _timeLeft];
        };

        private _display = findDisplay 9020;
        if (isNull _display) exitWith {};
        private _listbox = _display displayCtrl 9021;
        
        private _selectedIndex = lbCurSel _listbox;
        if (_selectedIndex == -1) exitWith {
            hint "Select an HVT first.";
        };
        
        private _taskId = _listbox lbData _selectedIndex;
        if (_taskId == "") exitWith { hint "Invalid HVT selected."; };
        
        private _cost = missionNamespace getVariable ["A3M_HVT_Satellite_Cost", 25000];
        private _playerFunds = player getVariable ["grad_lbm_myFunds", 0];
        
        if (_playerFunds < _cost) exitWith {
            private _msg = format ["<t align='left'><t size='0.8' color='#FF0000'>SWEEP FAILED</t><br/><t size='0.6' color='#FFFFFF'>Insufficient funds. Requires $%1.</t></t>", [_cost, 1, 0, true] call CBA_fnc_formatNumber];
            [_msg, 0.0, 0.1, 5, 0.5, 0, 795] spawn BIS_fnc_dynamicText;
        };
        
        closeDialog 0; // Close the menu before initiating feed
        
        private _deductMsg = format ["<t align='left'><t size='0.8' color='#00FF00'>SATELLITE UPLINK</t><br/><t size='0.6' color='#FFFFFF'>Re-tasking orbital asset...<br/>-$%1</t></t>", [_cost, 1, 0, true] call CBA_fnc_formatNumber];
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
private _allPlayerTasks = [player] call BIS_fnc_tasksUnit;
{
    // Re-adding the filter now that the syntax crash is identified
    if (["assassination", _x] call BIS_fnc_inString) then {
        _activeTasks pushBackUnique _x;
    };
} forEach _allPlayerTasks;

{
    private _taskId = _x;
    private _state = [_taskId] call BIS_fnc_taskState;
    
    // Only display if it hasn't succeeded/failed/canceled
    if (_state != "SUCCEEDED" && _state != "FAILED" && _state != "CANCELED") then {
        _activeHVTsFound = true;
        
        private _taskDescArray = [_taskId] call BIS_fnc_taskDescription;
        private _taskTitle = if (count _taskDescArray > 1) then { _taskDescArray select 1 } else { "Unknown HVT" };
        
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
_costText ctrlSetText format ["COST: $%1", [_costAmount, 1, 0, true] call CBA_fnc_formatNumber];
