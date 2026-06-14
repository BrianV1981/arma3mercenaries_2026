/*
    A.I.M. Unified Mercenary Initializer (Pillar 3 Consolidation)
    Replaces 100+ individual unit scripts.
    Dynamically spawns a delivery VTOL, parachutes the requested unit, and joins them to the player's group.
*/
params ["_buyer", "_unitClass", "_group", "_spawnPosition"];

if (!isServer) exitWith { diag_log "[A3M DEBUG] A3M_fnc_initMercenary skipped on client."; };

if (isNull _buyer) exitWith { diag_log "[A3M ERROR] A3M_fnc_initMercenary aborted: _buyer is objNull!"; };

// Hide the newly bought units immediately while they "fly in"
{
    _x hideObjectGlobal true;
    _x enableSimulationGlobal false;
    _x allowDamage false;
} forEach (units _group);

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

[_unitClass, _buyer, _side, _vtolClass, _pilotClass, _crewClass, _group] spawn { 
    params ["_unitClass", "_buyer", "_side", "_vtolClass", "_pilotClass", "_crewClass", "_group"];
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

    private _vtolGroup = createGroup [_side, true]; 
    _vtolGroup setVariable ["Vcm_Disable", true, true]; 
    _vtolGroup setVariable ["ALiVE_disableDynamicSimulation", true, true]; 

    private _pilot = _vtolGroup createUnit [_pilotClass, _startPos, [], 0, "FORM"]; 
    _pilot moveInDriver _blackfish; 

    // VTOLs usually have 3 turrets/crew seats
    private _gunner1 = _vtolGroup createUnit [_crewClass, _startPos, [], 0, "FORM"]; 
    private _gunner2 = _vtolGroup createUnit [_crewClass, _startPos, [], 0, "FORM"]; 
    private _gunner3 = _vtolGroup createUnit [_crewClass, _startPos, [], 0, "FORM"]; 

    _gunner1 moveInTurret [_blackfish, [0]];  
    _gunner2 moveInTurret [_blackfish, [1]];  
    _gunner3 moveInTurret [_blackfish, [2]];  

    {    
        _x setVariable ["ALiVE_disableDynamicSimulation", true, true];    
        _x setVariable ["Vcm_Disable", true, true];    
    } forEach [_pilot, _gunner1, _gunner2, _gunner3]; 

    private _endPos = _playerPos getPos [2000, _direction]; 

    private _wp1 = _vtolGroup addWaypoint [_playerPos, 0]; 
    _wp1 setWaypointType "MOVE"; 
    _wp1 setWaypointSpeed "FULL";  
    _wp1 setWaypointBehaviour "CARELESS";  

    private _wp2 = _vtolGroup addWaypoint [_endPos, 0]; 
    _wp2 setWaypointType "MOVE"; 
    _wp2 setWaypointSpeed "FULL";  
    _wp2 setWaypointBehaviour "COMBAT";  

    // Wait until the plane is close to the player to drop
    waitUntil { sleep 1; (_blackfish distance2D _playerPos) < 200 || !alive _blackfish };

    playSound3D ["a3\dubbing_f\modules\supports\transport_accomplished.ogg", _buyer];

    if (alive _blackfish) then {
        // Drop each unit in the bought group
        {
            private _unit = _x;
            private _dropPos = getPosATL _blackfish;
            _dropPos set [2, (_dropPos select 2) - 5]; // Drop slightly below plane
            
            private _parachute = createVehicle ["Steerable_Parachute_F", _dropPos, [], 0, "FLY"];
            
            if (!isNull _parachute) then {
                _unit hideObjectGlobal false;
                _unit enableSimulationGlobal true;
                
                // Move them safely into the parachute
                _unit setPos (getPos _parachute);
                _unit moveInDriver _parachute;
                
                [_unit, _buyer] spawn {
                    params ["_unit", "_buyer"];
                    waitUntil { sleep 0.5; isTouchingGround _unit || (getPos _unit select 2) < 1 };
                    _unit allowDamage true;
                    [_unit] joinSilent (group _buyer);
                    
                    if (isServer) then {
                        private _aiUnitID = _unit getVariable ["arma3mercenaries_aiUnit", ""];
                        if (_aiUnitID != "") then {
                            [_unit, _aiUnitID] call A3M_fnc_serverRegisterMercenary;
                            [_unit] remoteExec ["A3M_fnc_applyChatterEHs", _buyer];
                        };
                    };
                };
            };
            sleep 1; // Small stagger between drops
        } forEach (units _group);
    };

    sleep 10; 
    try { _blackfish animateDoor ['Door_1_source', 0]; } catch {};
    _blackfish allowDamage true; 

    // Wait until the plane flies away before deleting it
    waitUntil { sleep 5; (_blackfish distance2D _playerPos) > 1500 || !alive _blackfish };

    deleteVehicle _blackfish;
    {deleteVehicle _x} forEach units _vtolGroup;  
};