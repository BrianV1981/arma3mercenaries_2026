/*
    A.I.M. Unified Mercenary Initializer (Pillar 3 Consolidation)
    Replaces 100+ individual unit scripts.
    Dynamically spawns a delivery VTOL, parachutes the requested unit, and joins them to the player's group.
*/
params ["_unitClass", ["_buyer", objNull]];

if (!isServer) exitWith { diag_log "[A3M DEBUG] A3M_fnc_initMercenary skipped on client."; };

// If no buyer was passed, try to infer it (fallback)
if (isNull _buyer) then {
    if (isDedicated && !hasInterface) then {
        // Fallback for debugging locally
        _buyer = allPlayers select 0;
    } else {
        _buyer = player;
    };
};

if (isNull _buyer) exitWith { diag_log "[A3M ERROR] A3M_fnc_initMercenary aborted: _buyer is objNull!"; };

private _side = side _buyer;

if (isNil "radioSoundBlockTime") then { 
    radioSoundBlockTime = 0; 
}; 

// Master configuration for delivery properties based on faction
if (isNil "A3M_MercenaryDeliveryConfig") then {
    A3M_MercenaryDeliveryConfig = createHashMapFromArray [
        [west, ["B_T_VTOL_01_armed_F", "B_HeliPilot_F", "B_crew_F"]],
        [east, ["O_T_VTOL_02_infantry_F", "O_helipilot_F", "O_crew_F"]],
        [independent, ["I_Heli_Transport_02_F", "I_helipilot_F", "I_crew_F"]],
        [civilian, ["C_Heli_Light_01_civil_F", "C_man_pilot_F", "C_man_1_1_F"]]
    ];
};

private _sideConfig = A3M_MercenaryDeliveryConfig getOrDefault [_side, ["B_T_VTOL_01_armed_F", "B_HeliPilot_F", "B_crew_F"]];
_sideConfig params ["_vtolClass", "_pilotClass", "_crewClass"];

[_unitClass, _buyer, _side, _vtolClass, _pilotClass, _crewClass] spawn { 
    params ["_unitClass", "_buyer", "_side", "_vtolClass", "_pilotClass", "_crewClass"];
    private _currentTime = time; 

    if (_currentTime > radioSoundBlockTime) then { 
        radioSoundBlockTime = _currentTime + 120; 
        playSound3D ["a3\dubbing_f\modules\supports\transport_request.ogg", _buyer]; 
        private _randomRadioDelay = 5 + random 5; 
        sleep _randomRadioDelay; 
        playSound3D ["a3\dubbing_f\modules\supports\transport_acknowledged.ogg", _buyer]; 
    }; 

    private _randomTransportTime = 5 + random 5; 
    sleep _randomTransportTime; 

    private _playerPos = getPos _buyer; 
    private _direction = random 360; 
    private _startPos = _playerPos getPos [1000, _direction]; 

    private _blackfish = createVehicle [_vtolClass, _startPos, [], 0, "FLY"]; 
    _blackfish allowDamage false; 
    
    try { _blackfish animateDoor ['Door_1_source', 1]; } catch {};

    private _group = createGroup [_side, true]; 
    _group setVariable ["Vcm_Disable", true, true]; 
    _group setVariable ["ALiVE_disableDynamicSimulation", true, true]; 

    private _pilot = _group createUnit [_pilotClass, _startPos, [], 0, "FORM"]; 
    _pilot moveInDriver _blackfish; 

    // VTOLs usually have 3 turrets/crew seats
    private _gunner1 = _group createUnit [_crewClass, _startPos, [], 0, "FORM"]; 
    private _gunner2 = _group createUnit [_crewClass, _startPos, [], 0, "FORM"]; 
    private _gunner3 = _group createUnit [_crewClass, _startPos, [], 0, "FORM"]; 

    _gunner1 moveInTurret [_blackfish, [0]];  
    _gunner2 moveInTurret [_blackfish, [1]];  
    _gunner3 moveInTurret [_blackfish, [2]];  

    {    
        _x setVariable ["ALiVE_disableDynamicSimulation", true, true];    
        _x setVariable ["Vcm_Disable", true, true];    
    } forEach [_pilot, _gunner1, _gunner2, _gunner3]; 

    private _endPos = _playerPos getPos [2000, _direction]; 

    private _wp1 = _group addWaypoint [_playerPos, 0]; 
    _wp1 setWaypointType "MOVE"; 
    _wp1 setWaypointSpeed "FULL";  
    _wp1 setWaypointBehaviour "CARELESS";  

    private _wp2 = _group addWaypoint [_endPos, 0]; 
    _wp2 setWaypointType "MOVE"; 
    _wp2 setWaypointSpeed "FULL";  
    _wp2 setWaypointBehaviour "COMBAT";  

    [_group, _unitClass, _buyer] spawn {
        params ["_group", "_unitClass", "_buyer"]; 

        private _wp1Index = currentWaypoint _group; 
        waitUntil { currentWaypoint _group > _wp1Index };
        
        playSound3D ["a3\dubbing_f\modules\supports\transport_accomplished.ogg", _buyer];

        private _parachute = createVehicle ["Steerable_Parachute_F", [0, 0, 0], [], 0, "FLY"];
        
        if (!isNull _parachute) then {
            _parachute setPos (_buyer modelToWorld [0, 0, 50]);
            private _playerUID = getPlayerUID _buyer;
            private _uniqueUnitID = str (diag_tickTime + random 1000);
            private _aiUnitID = format ["arma3mercenaries_aiUnit_%1_%2", _uniqueUnitID, _playerUID];
            
            // A3M Group Fix: We now use the raw UID instead of formatted string for grouping
            private _groupID = _playerUID;

            private _unit = _group createUnit [_unitClass, position _parachute, [], 0, "FORM"];
            _unit moveInDriver _parachute;

            _unit setVariable ['arma3mercenaries_aiUnit', _aiUnitID, true];
            _unit setVariable ['arma3mercenaries_groupID', _groupID, true];
            _unit setVariable ['Vcm_Disable', true, true];
            
            waitUntil { isTouchingGround _unit || (getPos _unit select 2) < 1 };
            [_unit] joinSilent (group _buyer);

            // A3M: Phase 1 & 3 - Mercenary Profile Generation & Tracking
            if (isServer) then {
                private _mercProfile = createHashMapFromArray [
                    ["Name", name _unit],
                    ["Class", _unitClass],
                    ["JoinDate", systemTimeUTC], 
                    ["Kills", 0],
                    ["Deaths", 0],
                    ["CashCarried", 0],
                    ["OwnerUID", _playerUID]
                ];
                
                // Save immediately to DB
                [format["A3M_MERC_%1", _aiUnitID], _mercProfile] call A3M_fnc_dbSetSecure;
                
                // Add to Player's list of owned AI (so we can populate the UI later)
                private _playerProfile = ["A3M_PROFILE_" + _playerUID, createHashMap, true] call A3M_fnc_dbGetSecure;
                private _ownedMercs = _playerProfile getOrDefault ["OwnedMercenaries", []];
                _ownedMercs pushBack _aiUnitID;
                _playerProfile set ["OwnedMercenaries", _ownedMercs];
                ["A3M_PROFILE_" + _playerUID, _playerProfile] call A3M_fnc_dbSetSecure;
                
                // CRITICAL: Update the LiveProfile cache so the Pedometer loop doesn't overwrite our DB changes!
                if (!isNil "A3M_LiveProfiles") then {
                    A3M_LiveProfiles set [_playerUID, _playerProfile];
                };
                
                // Phase 3: The Death Tracker & Custom Name (Graveyard Support)
                [_unit, _aiUnitID] call A3M_fnc_serverRegisterMercenary;
                
                // Phase 4: PMC Speech Overhaul (Apply Audio Event Handlers on the client)
                [_unit] remoteExec ["A3M_fnc_applyChatterEHs", _buyer];
            };
        };
    };

    sleep 30; 
    try { _blackfish animateDoor ['Door_1_source', 0]; } catch {};
    _blackfish allowDamage true; 

    sleep 30;

    deleteVehicle _blackfish;
    {deleteVehicle _x} forEach units _group;  
};