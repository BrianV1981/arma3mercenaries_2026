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
        
        // Create an explicit, visible map marker for the user
        private _markerName = "A3M_HVT_PINPOINT_" + _taskId;
        if (getMarkerColor _markerName == "") then {
            private _marker = createMarkerLocal [_markerName, _exactPos];
            _marker setMarkerTypeLocal "mil_destroy";
            _marker setMarkerColorLocal "ColorRed";
            _marker setMarkerTextLocal "HVT PINPOINT";
        };

        // Spawn custom interactive camera sequence
        [_exactPos, _gridPos] spawn {
            params ["_exactPos", "_gridPos"];
            
            // The ALiVE Zeus Camera Trick natively
            // ALiVE strictly evaluates the physical location of 'player' in the engine.
            // Since the camera is just a local screen effect, ALiVE ignores it.
            // We physically teleport the player's invisible, invincible body to the target location
            // so ALiVE natively detects them and uncaches the sector.
            if (vehicle player != player) then { moveOut player; sleep 0.1; };
            private _originalPos = getPosATL player;
            player allowDamage false;
            player setCaptive true;
            [player, true] remoteExec ["hideObjectGlobal", 2];
            player hideObject true;
            
            // Place player exactly at the HVT so ALiVE natively uncaches the sector
            player setPosATL _exactPos;
            
            // Multi-stage cinematic startup sequence to give ALiVE plenty of time to spawn AI
            titleText ["ESTABLISHING SECURE UPLINK...", "BLACK FADED", 10];
            sleep 2;
            titleText ["ROUTING THROUGH ORBITAL RELAY...", "BLACK FADED", 10];
            sleep 2;
            titleText ["SYNCHRONIZING TARGET SENSORS...", "BLACK FADED", 10];
            sleep 3;
            titleText ["CALIBRATING OPTICS...", "BLACK FADED", 10];
            sleep 2;
            titleText ["", "BLACK IN", 2];
            
            showCinemaBorder true;
            
            // Initial Camera Setup
            private _camPos = [_exactPos select 0, _exactPos select 1, 600];
            A3M_SatCam = "camera" camCreate _camPos;
            A3M_SatCam cameraEffect ["internal", "BACK"];
            
            // Post-processing for a drone/satellite feel
            "colorCorrections" ppEffectEnable true;
            "colorCorrections" ppEffectAdjust [1, 1, 0, [0,0,0,0], [0.3,0.3,0.3,0], [1,1,1,0]];
            "colorCorrections" ppEffectCommit 0;
            
            "filmGrain" ppEffectEnable true;
            "filmGrain" ppEffectAdjust [0.15, 1, 1, 0.1, 1, false];
            "filmGrain" ppEffectCommit 0;

            A3M_SatCam camPrepareTarget _exactPos;
            A3M_SatCam camPrepareFOV 0.5;
            A3M_SatCam camCommitPrepared 0;
            
            // Text overlay
            private _overlayText = format ["<t color='#00FF00' size='1.5'>SPACEX UPLINK ACTIVE</t><br/><t size='1'>TARGET GRID: %1</t><br/><t size='0.8' color='#AAAAAA'>Scroll Mouse Wheel to Zoom | 'N' to Toggle Optics | Backspace to Exit</t>", _gridPos];
            [_overlayText, 0, 0.8, 10, 1] spawn BIS_fnc_dynamicText;
            
            // Arma 3 Typing Info Text
            private _date = date;
            private _dateStr = format ["%1-%2-%3", _date select 0, _date select 1, _date select 2];
            private _timeStr = format ["%1:%2", _date select 3, if (_date select 4 < 10) then {format ["0%1", _date select 4]} else {_date select 4}];
            [
                ["SPACEX ORBITAL ASSET", "fontTitle"],
                [format ["TARGET GRID %1", _gridPos]],
                [_dateStr],
                [_timeStr]
            ] spawn BIS_fnc_infoText;
            
            // Global state for Event Handlers
            A3M_SatCam_FOV = 0.5;
            A3M_SatCam_ForceExit = false;
            A3M_SatCam_VisionMode = 0;
            
            // Zoom Event Handler
            A3M_SatCam_ScrollEH = (findDisplay 46) displayAddEventHandler ["MouseZChanged", {
                params ["_display", "_scroll"];
                private _newFOV = A3M_SatCam_FOV - (_scroll * 0.05);
                if (_newFOV < 0.05) then { _newFOV = 0.05; }; // Max zoom in (tight)
                if (_newFOV > 0.9) then { _newFOV = 0.9; };   // Max zoom out (wide)
                A3M_SatCam_FOV = _newFOV;
                
                A3M_SatCam camPrepareFOV A3M_SatCam_FOV;
                A3M_SatCam camCommitPrepared 0.1;
                true
            }];
            
            // Keyboard Event Handler
            A3M_SatCam_KeyEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
                params ["_display", "_key"];
                if (_key == 14 || _key == 1) then { // Backspace or ESC
                    A3M_SatCam_ForceExit = true;
                    true
                } else {
                    if (_key == 49) then { // N key
                        A3M_SatCam_VisionMode = A3M_SatCam_VisionMode + 1;
                        if (A3M_SatCam_VisionMode > 3) then { A3M_SatCam_VisionMode = 0; };
                        
                        switch (A3M_SatCam_VisionMode) do {
                            case 0: { camUseNVG false; false setCamUseTi 0; }; // Normal
                            case 1: { camUseNVG true; false setCamUseTi 0; }; // NVG
                            case 2: { camUseNVG false; true setCamUseTi 0; }; // Thermal WHOT
                            case 3: { camUseNVG false; true setCamUseTi 1; }; // Thermal BHOT
                        };
                        true
                    } else {
                        false
                    };
                };
            }];
            
            // Orbit Loop
            private _angle = 0;
            private _radius = 400; // Orbit radius
            private _duration = 60; // 1 full minute
            private _startTime = time;
            
            while {time - _startTime < _duration && !A3M_SatCam_ForceExit} do {
                _angle = _angle + 0.2; // Speed of orbit
                private _x = (_exactPos select 0) + (sin _angle * _radius);
                private _y = (_exactPos select 1) + (cos _angle * _radius);
                
                // Adjust altitude based on zoom to give a parallax effect
                private _alt = 400 + (A3M_SatCam_FOV * 400); 
                
                A3M_SatCam setPosATL [_x, _y, _alt];
                sleep 0.05;
            };
            
            // Cleanup
            (findDisplay 46) displayRemoveEventHandler ["MouseZChanged", A3M_SatCam_ScrollEH];
            (findDisplay 46) displayRemoveEventHandler ["KeyDown", A3M_SatCam_KeyEH];
            A3M_SatCam cameraEffect ["terminate", "BACK"];
            camDestroy A3M_SatCam;
            
            "colorCorrections" ppEffectEnable false;
            "filmGrain" ppEffectEnable false;
            camUseNVG false; false setCamUseTi 0;
            
            // Restore Player Body
            player setPosATL _originalPos;
            player allowDamage true;
            player setCaptive false;
            [player, false] remoteExec ["hideObjectGlobal", 2];
            player hideObject false;
            
            private _finalMsg = "<t align='left'><t size='0.8' color='#00FF00'>SPACEX UPLINK</t><br/><t size='0.6' color='#FFFFFF'>Feed terminated.<br/>Map has been marked with the HVT's location.</t></t>";
            [_finalMsg, 0.0, 0.1, 5, 0.5, 0, 795] spawn BIS_fnc_dynamicText;
        };
    };
};

if (isNil "A3M_fnc_clientBlackfishFeed") then {
    A3M_fnc_clientBlackfishFeed = {
        params ["_gunship", "_gunner", "_taskId"];
        
        [_gunship, _gunner, _taskId] spawn {
            params ["_gunship", "_gunner", "_taskId"];
            
            titleText ["ESTABLISHING SECURE UPLINK...", "BLACK FADED", 10];
            sleep 2;
            titleText ["ROUTING THROUGH ORBITAL RELAY...", "BLACK FADED", 10];
            sleep 2;
            titleText ["SYNCHRONIZING TARGET SENSORS...", "BLACK FADED", 10];
            sleep 3;
            titleText ["CALIBRATING OPTICS...", "BLACK FADED", 10];
            sleep 2;
            titleText ["", "BLACK IN", 2];
            
            player remoteControl _gunner;
            _gunner switchCamera "GUNNER";
            
            private _overlayText = format ["<t color='#00FF00' size='1.5'>BLACKFISH UPLINK ACTIVE</t><br/><t size='0.8' color='#AAAAAA'>You have 5 minutes of firing time | Backspace to Abort</t>"];
            [_overlayText, 0, 0.8, 10, 1] spawn BIS_fnc_dynamicText;
            
            A3M_Gunship_ForceExit = false;
            A3M_Gunship_KeyEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
                params ["_display", "_key"];
                if (_key == 14 || _key == 1) then { // Backspace or ESC
                    A3M_Gunship_ForceExit = true;
                    true
                } else {
                    false
                };
            }];
            
            private _duration = 300; // 5 full minutes
            private _startTime = time;
            
            waitUntil {
                sleep 0.5;
                (time - _startTime >= _duration) || A3M_Gunship_ForceExit || !alive _gunship || !alive _gunner
            };
            
            (findDisplay 46) displayRemoveEventHandler ["KeyDown", A3M_Gunship_KeyEH];
            
            objNull remoteControl _gunner;
            player switchCamera "INTERNAL";
            
            private _finalMsg = "<t align='left'><t size='0.8' color='#00FF00'>BLACKFISH UPLINK</t><br/><t size='0.6' color='#FFFFFF'>Feed terminated.<br/>Gunship returning to base.</t></t>";
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
        
        private _cost = missionNamespace getVariable ["A3M_HVT_Satellite_Cost", 100000];
        private _playerFunds = player getVariable ["grad_lbm_myFunds", 0];
        diag_log format ["[A3M DEBUG] SAT SWEEP: Cost: %1 | Player Funds: %2", _cost, _playerFunds];
        
        if (_playerFunds < _cost) exitWith {
            diag_log "[A3M DEBUG] SAT SWEEP: Exited - Insufficient funds.";
            private _msg = format ["<t align='left'><t size='0.8' color='#FF0000'>SWEEP FAILED</t><br/><t size='0.6' color='#FFFFFF'>Insufficient funds. Requires $%1.</t></t>", _cost];
            [_msg, 0.0, 0.1, 5, 0.5, 0, 795] spawn BIS_fnc_dynamicText;
        };
        
        closeDialog 0; // Close the menu before initiating feed
        diag_log "[A3M DEBUG] SAT SWEEP: Dialog closed. Initiating remote execution...";
        
        private _deductMsg = format ["<t align='left'><t size='0.8' color='#00FF00'>SPACEX UPLINK</t><br/><t size='0.6' color='#FFFFFF'>Re-tasking orbital asset...<br/>-$%1</t></t>", _cost];
        [_deductMsg, 0.0, 0.1, 5, 0.5, 0, 795] spawn BIS_fnc_dynamicText;
        
        // Fade to black and spawn thread
        titleText ["ESTABLISHING SPACEX UPLINK...", "BLACK FADED", 10];
        
        [_taskId, player, _cost] spawn {
            params ["_taskId", "_client", "_cost"];
            sleep 1; // Wait for the fade to complete
            // Delegate to server to get the exact position and spawn spoof player
            [_taskId, _client, _cost] remoteExec ["A3M_fnc_serverSatelliteSweep", 2];
        };
    };
};

if (isNil "A3M_fnc_buyBlackfishSweep") then {
    A3M_fnc_buyBlackfishSweep = {
        diag_log "[A3M DEBUG] BLACKFISH: Button Clicked!";
        
        private _display = findDisplay 9020;
        if (isNull _display) exitWith { diag_log "[A3M DEBUG] BLACKFISH: Exited - Display null."; };
        private _listbox = _display displayCtrl 9021;
        
        private _selectedIndex = lbCurSel _listbox;
        diag_log format ["[A3M DEBUG] BLACKFISH: Selected Index: %1", _selectedIndex];
        
        if (_selectedIndex == -1) exitWith {
            hint "Select an HVT first.";
        };
        
        private _taskId = _listbox lbData _selectedIndex;
        diag_log format ["[A3M DEBUG] BLACKFISH: Selected Task ID: %1", _taskId];
        if (_taskId == "") exitWith { hint "Invalid HVT selected."; };
        
        private _cost = 200000;
        private _playerFunds = player getVariable ["grad_lbm_myFunds", 0];
        diag_log format ["[A3M DEBUG] BLACKFISH: Cost: %1 | Player Funds: %2", _cost, _playerFunds];
        
        if (_playerFunds < _cost) exitWith {
            diag_log "[A3M DEBUG] BLACKFISH: Exited - Insufficient funds.";
            private _msg = format ["<t align='left'><t size='0.8' color='#FF0000'>REQUEST FAILED</t><br/><t size='0.6' color='#FFFFFF'>Insufficient funds. Requires $%1.</t></t>", [_cost, 1, 0, true] call CBA_fnc_formatNumber];
            [_msg, 0.0, 0.1, 5, 0.5, 0, 795] spawn BIS_fnc_dynamicText;
        };
        
        closeDialog 0; // Close the menu before initiating feed
        diag_log "[A3M DEBUG] BLACKFISH: Dialog closed. Initiating remote execution...";
        
        private _deductMsg = format ["<t align='left'><t size='0.8' color='#00FF00'>BLACKFISH UPLINK</t><br/><t size='0.6' color='#FFFFFF'>Scrambling Gunship...<br/>-$%1</t></t>", [_cost, 1, 0, true] call CBA_fnc_formatNumber];
        [_deductMsg, 0.0, 0.1, 5, 0.5, 0, 795] spawn BIS_fnc_dynamicText;
        
        // Fade to black and spawn thread
        titleText ["ESTABLISHING BLACKFISH UPLINK...", "BLACK FADED", 10];
        
        [_taskId, player, _cost] spawn {
            params ["_taskId", "_client", "_cost"];
            sleep 1; // Wait for the fade to complete
            // Delegate to server to get the exact position and spawn spoof player
            [_taskId, _client, _cost] remoteExec ["A3M_fnc_serverBlackfishSweep", 2];
        };
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
private _costAmount = missionNamespace getVariable ["A3M_HVT_Satellite_Cost", 100000];
private _costText = _display displayCtrl 9026;
_costText ctrlSetText format ["COST: $%1", _costAmount];
