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
        
        // Calculate the marker text and type dynamically
        private _markerText = "SpaceX Location: HVT";
        private _markerType = "mil_destroy";

        if (_taskId select [0, 7] == "PLAYER_") then {
            private _uid = _taskId select [7];
            private _playerName = "Unknown";
            { if (getPlayerUID _x == _uid) exitWith { _playerName = name _x; }; } forEach allPlayers;
            _markerText = format ["SpaceX Location: %1 (player)", _playerName];
            _markerType = "mil_dot";
        } else {
            private _taskDescArray = _taskId call BIS_fnc_taskDescription;
            private _taskTitle = if (typeName _taskDescArray == "ARRAY" && {count _taskDescArray > 1}) then { _taskDescArray select 1 } else { _taskId };
            
            // Safely unpack any deeply nested ALiVE string arrays
            while {typeName _taskTitle == "ARRAY" && {count _taskTitle > 0}} do {
                _taskTitle = _taskTitle select 0;
            };
            
            // Force it into a safe string representation without adding extra quotes
            _taskTitle = if (typeName _taskTitle == "STRING") then { _taskTitle } else { format ["%1", _taskTitle] };            
            if (["contract_csar_", _taskId] call BIS_fnc_inString) then {
                private _callsign = _taskTitle;
                if (["CSAR: ", _taskTitle] call BIS_fnc_inString) then {
                    _callsign = _taskTitle select [6];
                };
                _markerText = format ["SpaceX Location: %1 (CSAR)", _callsign];
                _markerType = "mil_dot";
            } else {
                _markerText = format ["SpaceX Location: %1", _taskTitle];
            };
        };

        // Create an explicit, visible map marker for the user
        private _markerName = "A3M_HVT_PINPOINT_" + _taskId;
        if (getMarkerColor _markerName == "") then {
            private _marker = createMarkerLocal [_markerName, _exactPos];
            _marker setMarkerTypeLocal _markerType;
            _marker setMarkerColorLocal "ColorRed";
            _marker setMarkerTextLocal _markerText;
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
            private _originalPos = getPosASL player;
            player allowDamage false;
            player setVariable ["ace_medical_allowDamage", false, true];
            player setCaptive true;
            [player, true] remoteExec ["hideObjectGlobal", 2];
            player hideObject true;
            
            // Place player exactly at the HVT initially to ensure ALiVE uncaches it
            player setVelocity [0,0,0];
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
            A3M_SatCam camPrepareFOV 0.9;
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
            A3M_SatCam_FOV = 0.9;
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
            
            // Linear Satellite Pass Loop
            private _duration = 60; // 1 full minute
            private _startTime = time;
            
            // Random pass trajectory (random angle from 0 to 360)
            private _passAngle = random 360;
            
            // Offset the trajectory laterally to prevent gimbal lock (violent camera flip at exactly 0-degree zenith)
            private _offsetDist = 200 + random 200;
            private _centerPath = _exactPos getPos [_offsetDist, _passAngle + 90];
            
            private _passStart = _centerPath getPos [1200, _passAngle];
            private _passEnd = _centerPath getPos [1200, _passAngle - 180];
            
            // The "Invisible Anchor" trick to prevent the freefall animation
            private _palantirAnchor = "Sign_Sphere10cm_F" createVehicleLocal [0,0,0];
            _palantirAnchor hideObject true;
            player attachTo [_palantirAnchor, [0,0,0]];
            
            while {time - _startTime < _duration && !A3M_SatCam_ForceExit} do {
                private _progress = (time - _startTime) / _duration; // 0.0 to 1.0
                
                private _x = (_passStart select 0) + ((_passEnd select 0) - (_passStart select 0)) * _progress;
                private _y = (_passStart select 1) + ((_passEnd select 1) - (_passStart select 1)) * _progress;
                
                // Extremely high altitude base (1200m)
                private _alt = 1200;
                
                A3M_SatCam setPosATL [_x, _y, _alt];
                
                // Move the anchor. The player is physically attached to it, so they move seamlessly
                // WITHOUT ever triggering the Arma freefall/skydiving animation!
                _palantirAnchor setPosATL [_x, _y, _alt];
                
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
            detach player;
            deleteVehicle _palantirAnchor;
            
            player setVelocity [0,0,0];
            player setPosASL _originalPos;
            player setVelocity [0,0,0];
            player allowDamage true;
            player setVariable ["ace_medical_allowDamage", true, true];
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
        params ["_gunship", "_gunner", "_taskId", "_exactPos"];
        
        [_gunship, _gunner, _taskId, _exactPos] spawn {
            params ["_gunship", "_gunner", "_taskId", "_exactPos"];
            
            titleText ["ESTABLISHING SECURE UPLINK...", "BLACK FADED", 10];
            sleep 2;
            titleText ["ROUTING THROUGH ORBITAL RELAY...", "BLACK FADED", 10];
            sleep 2;
            titleText ["SYNCHRONIZING TARGET SENSORS...", "BLACK FADED", 10];
            sleep 3;
            titleText ["CALIBRATING OPTICS...", "BLACK FADED", 10];
            sleep 2;
            titleText ["", "BLACK IN", 2];
            
            // ALiVE Spoof Teleportation (Forces base to spawn natively)
            if (vehicle player != player) then { moveOut player; sleep 0.1; };
            private _originalPos = getPosASL player;
            player allowDamage false;
            player setVariable ["ace_medical_allowDamage", false, true];
            player setCaptive true;
            [player, true] remoteExec ["hideObjectGlobal", 2];
            player hideObject true;
            
            // Attach player's physical body to the gunship so audio originates from the sky, not the ground impact zone
            // ALiVE will still uncache the base because the body is right above it
            player attachTo [_gunship, [0, 0, 0]];
            
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
            
            A3M_Gunship_MouseBtnEH = (findDisplay 46) displayAddEventHandler ["MouseButtonDown", {
                params ["_display", "_button"];
                if (_button == 1 || _button == 2) then { true } else { false };
            }];
            
            inGameUISetEventHandler ["Action", "true"];
            inGameUISetEventHandler ["PrevAction", "true"];
            inGameUISetEventHandler ["NextAction", "true"];
            
            private _duration = 300; // 5 full minutes
            private _startTime = time;
            
            waitUntil {
                sleep 0.5;
                (time - _startTime >= _duration) || A3M_Gunship_ForceExit || !alive _gunship || !alive _gunner
            };
            
            (findDisplay 46) displayRemoveEventHandler ["KeyDown", A3M_Gunship_KeyEH];
            (findDisplay 46) displayRemoveEventHandler ["MouseButtonDown", A3M_Gunship_MouseBtnEH];
            
            inGameUISetEventHandler ["Action", ""];
            inGameUISetEventHandler ["PrevAction", ""];
            inGameUISetEventHandler ["NextAction", ""];
            
            detach player;
            objNull remoteControl _gunner;
            player switchCamera "INTERNAL";
            
            // Restore Player Body
            player setVelocity [0,0,0];
            player setPosASL _originalPos;
            player setVelocity [0,0,0];
            player allowDamage true;
            player setVariable ["ace_medical_allowDamage", true, true];
            player setCaptive false;
            [player, false] remoteExec ["hideObjectGlobal", 2];
            player hideObject false;
            
            private _finalMsg = "<t align='left'><t size='0.8' color='#00FF00'>BLACKFISH UPLINK</t><br/><t size='0.6' color='#FFFFFF'>Feed terminated.<br/>Gunship returning to base.</t></t>";
            [_finalMsg, 0.0, 0.1, 5, 0.5, 0, 795] spawn BIS_fnc_dynamicText;
        };
    };
};

if (isNil "A3M_fnc_clientDroneFeed") then {
    A3M_fnc_clientDroneFeed = {
        params ["_drone", "_gunner", "_taskId", "_exactPos"];
        
        [_drone, _gunner, _taskId, _exactPos] spawn {
            params ["_drone", "_gunner", "_taskId", "_exactPos"];
            
            titleText ["ESTABLISHING SECURE UPLINK...", "BLACK FADED", 10];
            sleep 2;
            titleText ["ROUTING THROUGH ORBITAL RELAY...", "BLACK FADED", 10];
            sleep 2;
            titleText ["SYNCHRONIZING TARGET SENSORS...", "BLACK FADED", 10];
            sleep 3;
            titleText ["CALIBRATING OPTICS...", "BLACK FADED", 10];
            sleep 2;
            titleText ["", "BLACK IN", 2];
            
            private _isPlayerTarget = (_taskId select [0, 7] == "PLAYER_");
            private _originalPos = [0,0,0];
            
            if (!_isPlayerTarget) then {
                // ALiVE Spoof Teleportation (Forces base to spawn natively)
                if (vehicle player != player) then { moveOut player; sleep 0.1; };
                _originalPos = getPosASL player;
                player allowDamage false;
                player setVariable ["ace_medical_allowDamage", false, true];
                player setCaptive true;
                [player, true] remoteExec ["hideObjectGlobal", 2];
                player hideObject true;
                
                // Attach player's physical body to the drone so audio originates from the sky
                player attachTo [_drone, [0, 0, 0]];
            };
            
            player remoteControl _gunner;
            _gunner switchCamera "GUNNER";
            
            private _overlayText = format ["<t color='#00FF00' size='1.5'>CONSTELLIS DRONE UPLINK ACTIVE</t><br/><t size='0.8' color='#AAAAAA'>You have 5 minutes of firing time | Backspace to Abort</t>"];
            [_overlayText, 0, 0.8, 10, 1] spawn BIS_fnc_dynamicText;
            
            A3M_Drone_ForceExit = false;
            A3M_Drone_KeyEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
                params ["_display", "_key"];
                if (_key == 14 || _key == 1) then { // Backspace or ESC
                    A3M_Drone_ForceExit = true;
                    true
                } else {
                    false
                };
            }];
            
            A3M_Drone_MouseBtnEH = (findDisplay 46) displayAddEventHandler ["MouseButtonDown", {
                params ["_display", "_button"];
                if (_button == 1 || _button == 2) then { true } else { false };
            }];
            
            inGameUISetEventHandler ["Action", "true"];
            inGameUISetEventHandler ["PrevAction", "true"];
            inGameUISetEventHandler ["NextAction", "true"];
            
            private _duration = 300; // 5 full minutes
            private _startTime = time;
            
            waitUntil {
                sleep 0.5;
                (time - _startTime >= _duration) || A3M_Drone_ForceExit || !alive _drone || !alive _gunner
            };
            
            (findDisplay 46) displayRemoveEventHandler ["KeyDown", A3M_Drone_KeyEH];
            (findDisplay 46) displayRemoveEventHandler ["MouseButtonDown", A3M_Drone_MouseBtnEH];
            
            inGameUISetEventHandler ["Action", ""];
            inGameUISetEventHandler ["PrevAction", ""];
            inGameUISetEventHandler ["NextAction", ""];
            
            objNull remoteControl _gunner;
            player switchCamera "INTERNAL";
            
            if (!_isPlayerTarget) then {
                detach player;
                // Restore Player Body
                player setVelocity [0,0,0];
                player setPosASL _originalPos;
                player setVelocity [0,0,0];
                player allowDamage true;
                player setVariable ["ace_medical_allowDamage", true, true];
                player setCaptive false;
                [player, false] remoteExec ["hideObjectGlobal", 2];
                player hideObject false;
            };
            
            private _finalMsg = "<t align='left'><t size='0.8' color='#00FF00'>CONSTELLIS DRONE UPLINK</t><br/><t size='0.6' color='#FFFFFF'>Feed terminated.<br/>Drone returning to base.</t></t>";
            [_finalMsg, 0.0, 0.1, 5, 0.5, 0, 795] spawn BIS_fnc_dynamicText;
        };
    };
};

if (isNil "A3M_fnc_clientCameraFeed") then {
    A3M_fnc_clientCameraFeed = {
        params ["_drone", "_taskId", "_exactPos"];
        
        [_drone, _taskId, _exactPos] spawn {
            params ["_drone", "_taskId", "_exactPos"];
            
            titleText ["ESTABLISHING CAS UPLINK...", "BLACK FADED", 10];
            sleep 2;
            titleText ["ROUTING THROUGH ORBITAL RELAY...", "BLACK FADED", 10];
            sleep 2;
            titleText ["", "BLACK IN", 2];
            
            private _isPlayerTarget = (_taskId select [0, 7] == "PLAYER_");
            private _originalPos = [0,0,0];
            
            if (!_isPlayerTarget) then {
                // ALiVE Spoof Teleportation
                if (vehicle player != player) then { moveOut player; sleep 0.1; };
                _originalPos = getPosASL player;
                player allowDamage false;
                player setVariable ["ace_medical_allowDamage", false, true];
                player setCaptive true;
                [player, true] remoteExec ["hideObjectGlobal", 2];
                player hideObject true;
            };
            
            // Create cinematic camera attached to Wipeout belly
            private _cam = "camera" camCreate (getPos _drone);
            _cam cameraEffect ["Internal", "Back"];
            _cam attachTo [_drone, [0, 4, -3]];
            _cam camSetTarget _exactPos;
            _cam camCommit 0;
            
            A3M_ActiveCam = _cam;
            A3M_Cam_FOV = 0.7;
            A3M_Cam_VisionMode = 0;
            
            private _overlayText = format ["<t color='#00FF00' size='1.5'>CONSTELLIS CAS UPLINK ACTIVE</t><br/><t size='0.8' color='#AAAAAA'>[Scroll] Zoom | [N] Vision Mode | [Backspace] Abort</t>"];
            [_overlayText, 0, 0.8, 10, 1] spawn BIS_fnc_dynamicText;
            
            A3M_Drone_ForceExit = false;
            
            A3M_Drone_MouseEH = (findDisplay 46) displayAddEventHandler ["MouseZChanged", {
                params ["_display", "_scroll"];
                if (_scroll > 0) then { A3M_Cam_FOV = A3M_Cam_FOV - 0.1; } else { A3M_Cam_FOV = A3M_Cam_FOV + 0.1; };
                if (A3M_Cam_FOV < 0.05) then { A3M_Cam_FOV = 0.05; };
                if (A3M_Cam_FOV > 0.9) then { A3M_Cam_FOV = 0.9; };
                if (!isNull A3M_ActiveCam) then { A3M_ActiveCam camSetFov A3M_Cam_FOV; A3M_ActiveCam camCommit 0.1; };
                false
            }];
            
            A3M_Drone_KeyEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
                params ["_display", "_key"];
                if (_key == 14 || _key == 1) then { // Backspace or ESC
                    A3M_Drone_ForceExit = true;
                    true
                } else {
                    if (_key == 49) then { // N key
                        A3M_Cam_VisionMode = A3M_Cam_VisionMode + 1;
                        if (A3M_Cam_VisionMode > 3) then { A3M_Cam_VisionMode = 0; };
                        if (A3M_Cam_VisionMode == 0) then { camUseNVG false; false setCamUseTi 0; };
                        if (A3M_Cam_VisionMode == 1) then { camUseNVG true; false setCamUseTi 0; };
                        if (A3M_Cam_VisionMode == 2) then { camUseNVG false; true setCamUseTi 0; }; // WHOT
                        if (A3M_Cam_VisionMode == 3) then { camUseNVG false; true setCamUseTi 1; }; // BHOT
                        true
                    } else { false };
                };
            }];
            
            private _duration = 300;
            private _startTime = time;
            
            waitUntil {
                sleep 0.5;
                // Continuously track target
                _cam camSetTarget _exactPos;
                _cam camCommit 0.5;
                (time - _startTime >= _duration) || A3M_Drone_ForceExit || !alive _drone
            };
            
            (findDisplay 46) displayRemoveEventHandler ["KeyDown", A3M_Drone_KeyEH];
            (findDisplay 46) displayRemoveEventHandler ["MouseZChanged", A3M_Drone_MouseEH];
            
            // Reset vision modes
            camUseNVG false; false setCamUseTi 0;
            
            _cam cameraEffect ["Terminate", "Back"];
            camDestroy _cam;
            
            if (!_isPlayerTarget) then {
                // Restore Player Body
                player setVelocity [0,0,0];
                player setPosASL _originalPos;
                player allowDamage true;
                player setVariable ["ace_medical_allowDamage", true, true];
                player setCaptive false;
                [player, false] remoteExec ["hideObjectGlobal", 2];
                player hideObject false;
            };
            
            private _finalMsg = "<t align='left'><t size='0.8' color='#00FF00'>CAS UPLINK</t><br/><t size='0.6' color='#FFFFFF'>Feed terminated.<br/>Asset returning to base.</t></t>";
            [_finalMsg, 0.0, 0.1, 5, 0.5, 0, 795] spawn BIS_fnc_dynamicText;
        };
    };
};

if (isNil "A3M_fnc_onHVTTrackerSelChanged") then {
    A3M_fnc_onHVTTrackerSelChanged = {
        params ["_control", "_selectedIndex"];
        private _display = ctrlParent _control;
        private _taskId = _control lbData _selectedIndex;
        private _map = _display displayCtrl 9023;
        
        private _exactPos = [0,0,0];
        private _targetType = "HVT"; // HVT, FRIENDLY, ENEMY
        
        if (_taskId select [0, 7] == "PLAYER_") then {
            private _uid = _taskId select [7];
            {
                if (getPlayerUID _x == _uid) exitWith {
                    _exactPos = getPosASL _x;
                    if (side group _x == playerSide) then { _targetType = "FRIENDLY"; } else { _targetType = "ENEMY"; };
                };
            } forEach allPlayers;
        } else {
            _exactPos = taskDestination _taskId;
        };
        
        if !(_exactPos isEqualTo [0,0,0]) then {
            _map ctrlMapAnimAdd [1, 0.1, _exactPos];
            ctrlMapAnimCommit _map;
        };
        
        private _combo = _display displayCtrl 9030;
        lbClear _combo;
        
        private _services = [
            ["SpaceX Satellite Sweep", 100000, "A3M_fnc_serverSatelliteSweep"]
        ];
        
        if (_targetType != "ENEMY") then {
            _services append [
                ["UCAV Sentinel Scan", 150000, "A3M_fnc_serverSentinelSweep"],
                ["AH-99 Blackfoot CAS", 200000, "A3M_fnc_serverBlackfootSweep"],
                // ["A-164 Wipeout CAS", 200000, "A3M_fnc_serverWipeoutSweep"], // Stubbed out temporarily
                ["Constellis Blackfish Attack", 200000, "A3M_fnc_serverBlackfishSweep"],
                ["Constellis Drone Sweep (Greyhawk)", 75000, "A3M_fnc_serverDroneSweep"],
                ["Darter Micro-UAV Sweep", 50000, "A3M_fnc_serverDarterSweep"]
            ];
        };
        
        {
            _x params ["_name", "_cost", "_func"];
            private _idx = _combo lbAdd format["%1 ($%2)", _name, [_cost, 1, 0, true] call CBA_fnc_formatNumber];
            _combo lbSetData [_idx, str [_cost, _name, _func]];
        } forEach _services;
        _combo lbSetCurSel 0;
    };
};

if (isNil "A3M_fnc_buyPalantirService") then {
    A3M_fnc_buyPalantirService = {
        private _display = findDisplay 9020;
        if (isNull _display) exitWith {};
        private _listbox = _display displayCtrl 9021;
        private _combo = _display displayCtrl 9030;
        
        private _hvtIndex = lbCurSel _listbox;
        if (_hvtIndex == -1) exitWith { hint "Select an HVT first."; };
        
        private _taskId = _listbox lbData _hvtIndex;
        if (_taskId == "") exitWith { hint "Invalid HVT selected."; };
        
        private _serviceIndex = lbCurSel _combo;
        if (_serviceIndex == -1) exitWith { hint "Select a Palantir service."; };
        
        private _serviceDataStr = _combo lbData _serviceIndex;
        private _serviceData = parseSimpleArray _serviceDataStr;
        _serviceData params ["_cost", "_serviceName", "_serverFunction"];
        
        private _playerFunds = player getVariable ["grad_lbm_myFunds", 0];
        
        if (_playerFunds < _cost) exitWith {
            private _msg = format ["<t align='left'><t size='0.8' color='#FF0000'>REQUEST FAILED</t><br/><t size='0.6' color='#FFFFFF'>Insufficient funds. Requires $%1.</t></t>", [_cost, 1, 0, true] call CBA_fnc_formatNumber];
            [_msg, 0.0, 0.1, 5, 0.5, 0, 795] spawn BIS_fnc_dynamicText;
        };
        
        closeDialog 0;
        
        private _deductMsg = format ["<t align='left'><t size='0.8' color='#00FF00'>UPLINK ACTIVE</t><br/><t size='0.6' color='#FFFFFF'>Requesting %1...<br/>-$%2</t></t>", _serviceName, [_cost, 1, 0, true] call CBA_fnc_formatNumber];
        [_deductMsg, 0.0, 0.1, 5, 0.5, 0, 795] spawn BIS_fnc_dynamicText;
        
        titleText [format["ESTABLISHING %1 UPLINK...", toUpper _serviceName], "BLACK FADED", 10];
        
        [_taskId, player, _cost, _serverFunction] spawn {
            params ["_taskId", "_client", "_cost", "_serverFunction"];
            sleep 1;
            [_taskId, _client, _cost] remoteExec [_serverFunction, 2];
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
private _allPlayerTasks = player call BIS_fnc_tasksUnit;

{
    if (["assassination", _x] call BIS_fnc_inString || ["contract_csar_", _x] call BIS_fnc_inString) then {
        _activeTasks pushBackUnique _x;
    };
} forEach _allPlayerTasks;

{
    private _taskId = _x;
    private _state = [_taskId] call BIS_fnc_taskState;
    if (_state != "SUCCEEDED" && _state != "FAILED" && _state != "CANCELED") then {
        _activeHVTsFound = true;
        private _taskDescArray = _taskId call BIS_fnc_taskDescription;
        private _taskTitle = if (typeName _taskDescArray == "ARRAY" && {count _taskDescArray > 1}) then { _taskDescArray select 1 } else { _taskId };
        
        // Safely unpack any deeply nested ALiVE string arrays
        while {typeName _taskTitle == "ARRAY" && {count _taskTitle > 0}} do {
            _taskTitle = _taskTitle select 0;
        };
        
        // Force it into a safe string representation without adding extra quotes
        _taskTitle = if (typeName _taskTitle == "STRING") then { _taskTitle } else { format ["%1", _taskTitle] };
        
        private _isCSAR = ["contract_csar_", _taskId] call BIS_fnc_inString;
        private _menuText = if (_isCSAR) then { _taskTitle } else { format ["HVT: %1", _taskTitle] };
        
        private _index = _listbox lbAdd _menuText;
        _listbox lbSetData [_index, _taskId];
        
        if (_isCSAR) then {
            _listbox lbSetColor [_index, [0, 1, 0.5, 1]]; // Greenish Blue for CSAR
        } else {
            _listbox lbSetColor [_index, [1, 0, 0, 1]]; // Red for HVT
        };
    };
} forEach _activeTasks;

{
    private _name = name _x;
    private _uid = getPlayerUID _x;
    if (_uid != "") then {
        _activeHVTsFound = true;
        private _isFriendly = (side group _x == playerSide);
        private _prefix = if (_x == player) then { "SELF" } else { if (_isFriendly) then { "FRIENDLY" } else { "ENEMY" } };
        private _index = _listbox lbAdd format ["%1: %2", _prefix, _name];
        _listbox lbSetData [_index, "PLAYER_" + _uid];
        
        if (_x == player) then {
            _listbox lbSetColor [_index, [0, 1, 0, 1]]; // Green
        } else {
            if (_isFriendly) then {
                _listbox lbSetColor [_index, [0, 0.5, 1, 1]]; // Blue
            } else {
                _listbox lbSetColor [_index, [1, 0.5, 0, 1]]; // Orange
            };
        };
    };
} forEach allPlayers;

if (!_activeHVTsFound) then {
    _listbox lbAdd "No active HVT or Player signals detected.";
    (_display displayCtrl 9022) ctrlEnable false;
    (_display displayCtrl 9030) ctrlEnable false;
} else {
    _listbox lbSetCurSel 0; // Trigger EH
};
