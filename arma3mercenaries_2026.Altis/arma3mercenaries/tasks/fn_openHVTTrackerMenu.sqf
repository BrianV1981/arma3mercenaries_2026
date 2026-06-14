/*
    arma3mercenaries\tasks\fn_openHVTTrackerMenu.sqf
    Description: Opens the HVT Satellite Tracking menu and populates active targets.
*/

if (!hasInterface) exitWith {};

// --- Helper Functions ---
if (isNil "A3M_fnc_serverSatelliteSweep") then {
    A3M_fnc_serverSatelliteSweep = {
        params ["_taskId", "_client", "_cost"];
        
        // Find the HVT object
        private _hvtTarget = objNull;
        if (!isNil "A3M_ActiveTasks") then {
            private _taskData = A3M_ActiveTasks getOrDefault [_taskId, []];
            if (count _taskData > 0) then {
                _hvtTarget = _taskData select 0;
            };
        };
        
        if (isNull _hvtTarget || !alive _hvtTarget) exitWith {
            private _msg = "<t align='left'><t size='0.8' color='#FF0000'>SWEEP FAILED</t><br/><t size='0.6' color='#FFFFFF'>Target signal lost or KIA.</t></t>";
            [_msg, 0.0, 0.1, 5, 0.5, 0, 795] remoteExec ["BIS_fnc_dynamicText", _client];
        };
        
        // Get the actual exact position from the server where the object is guaranteed to be known
        private _exactPos = getPosATL _hvtTarget;
        
        // Update the task destination to the exact position for everyone
        [_taskId, _exactPos] remoteExec ["BIS_fnc_taskSetDestination", 0, "JIP_id_" + _taskId];
        
        // Deduct Funds from the specific client
        [_client, -_cost, true] remoteExec ["grad_moneymenu_fnc_addFunds", _client];
        
        // Tell the client to start the visual drone feed
        [_exactPos, _taskId] remoteExec ["A3M_fnc_clientSatelliteFeed", _client];
    };
};

if (isNil "A3M_fnc_clientSatelliteFeed") then {
    A3M_fnc_clientSatelliteFeed = {
        params ["_exactPos", "_taskId"];
        private _gridPos = mapGridPosition _exactPos;
        private _overlayText = format ["SIGINT DETECTED\nTARGET: HVT\nGRID: %1", _gridPos];
        
        // Execute BI Drone Feed
        [_exactPos, _overlayText, 500, 500, 75, 1, [], 0, true] spawn BIS_fnc_establishingShot;
        
        // Wait for it to finish or be skipped
        [] spawn {
            waitUntil {sleep 1; !(missionNamespace getVariable ["BIS_fnc_establishingShot_playing", false])};
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

if (!isNil "A3M_ActiveTasks") then {
    {
        private _taskId = _x;
        private _taskData = _y;
        _taskData params ["_hvtObj", "_taskType"];
        
        if (_taskType == "HVT") then {
            _activeHVTsFound = true;
            
            // Extract the title of the task
            private _taskDescArray = _taskId call BIS_fnc_taskDescription;
            private _taskTitle = if (count _taskDescArray > 1) then { _taskDescArray select 1 } else { "Unknown HVT" };
            
            private _index = _listbox lbAdd _taskTitle;
            _listbox lbSetData [_index, _taskId];
        };
    } forEach A3M_ActiveTasks;
};

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
