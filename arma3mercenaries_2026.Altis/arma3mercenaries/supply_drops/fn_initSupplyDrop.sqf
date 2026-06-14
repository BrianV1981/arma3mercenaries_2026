/*
    A.I.M. Unified Supply Drop Initializer
    Dynamically spawns a delivery VTOL, parachutes the requested cargo box, fills it with items, and tags it for ownership.
*/
params [
    ["_cargoClass", "B_Slingload_01_Cargo_F", [""]], 
    ["_buyer", objNull, [objNull]],
    ["_fortsArray", [], [[]]],
    ["_magsArray", [], [[]]],
    ["_itemsArray", [], [[]]]
];

if (!isServer) exitWith { diag_log "[A3M DEBUG] A3M_fnc_initSupplyDrop skipped on client."; };

if (isNull _buyer) then { _buyer = player; };
if (isNull _buyer) exitWith {};

private _side = side _buyer;

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

[_cargoClass, _buyer, _side, _vtolClass, _pilotClass, _crewClass, _fortsArray, _magsArray, _itemsArray] spawn { 
    params ["_cargoClass", "_buyer", "_side", "_vtolClass", "_pilotClass", "_crewClass", "_fortsArray", "_magsArray", "_itemsArray"];
    
    // Announce
    playSound3D ["a3\dubbing_f\modules\supports\drop_request.ogg", _buyer]; 
    sleep (5 + random 5); 
    playSound3D ["a3\dubbing_f\modules\supports\drop_acknowledged.ogg", _buyer]; 

    private _playerPos = getPos _buyer; 
    private _direction = random 360; 
    private _startPos = _playerPos getPos [1500, _direction]; 

    private _vtol = createVehicle [_vtolClass, _startPos, [], 0, "FLY"]; 
    _vtol allowDamage false; 
    
    try { _vtol animateDoor ['Door_1_source', 1]; } catch {};

    private _group = createGroup [_side, true]; 
    _group setVariable ["Vcm_Disable", true, true]; 
    _group setVariable ["ALiVE_disableDynamicSimulation", true, true]; 

    private _pilot = _group createUnit [_pilotClass, _startPos, [], 0, "FORM"]; 
    _pilot moveInDriver _vtol; 

    private _gunner1 = _group createUnit [_crewClass, _startPos, [], 0, "FORM"]; 
    private _gunner2 = _group createUnit [_crewClass, _startPos, [], 0, "FORM"]; 
    private _gunner3 = _group createUnit [_crewClass, _startPos, [], 0, "FORM"]; 

    _gunner1 moveInTurret [_vtol, [0]];  
    _gunner2 moveInTurret [_vtol, [1]];  
    _gunner3 moveInTurret [_vtol, [2]];  

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

    // Drop Logic
    [_group, _cargoClass, _buyer, _fortsArray, _magsArray, _itemsArray] spawn {
        params ["_group", "_cargoClass", "_buyer", "_fortsArray", "_magsArray", "_itemsArray"]; 

        private _wp1Index = currentWaypoint _group; 
        waitUntil { currentWaypoint _group > _wp1Index };
        
        playSound3D ["a3\dubbing_f\modules\supports\drop_accomplished.ogg", _buyer];

        private _vtol = vehicle (leader _group);
        private _dropPos = getPosATL _vtol;
        _dropPos set [2, (_dropPos select 2) - 5]; // Drop slightly below the plane to avoid collision

        private _parachute = createVehicle ["B_Parachute_02_F", _dropPos, [], 0, "FLY"];
        private _cargo = createVehicle [_cargoClass, _dropPos, [], 0, "NONE"];
        _cargo attachTo [_parachute, [0,0,0]];

        // Clear default cargo
        clearWeaponCargoGlobal _cargo; 
        clearMagazineCargoGlobal _cargo; 
        clearItemCargoGlobal _cargo; 
        clearBackpackCargoGlobal _cargo;

        // CRITICAL A3M LOGIC: Tag Ownership so it can be managed by grad-fortifications and packed
        _cargo setVariable ["grad_fortifications_fortOwner", getPlayerUID _buyer, true];
        
        // Ensure it always saves
        _cargo setVariable ["grad_persistence_isExcluded", false, true];

        // Populate Fortifications
        {
            _x params ["_class", "_count"];
            [_cargo, _class, _count] call grad_fortifications_fnc_addFort;
        } forEach _fortsArray;

        // Populate Mags
        {
            _x params ["_class", "_count"];
            _cargo addMagazineCargoGlobal [_class, _count];
        } forEach _magsArray;

        // Populate Items
        {
            _x params ["_class", "_count"];
            if (isClass (configFile >> "CfgVehicles" >> _class)) then {
                _cargo addBackpackCargoGlobal [_class, _count];
            } else {
                _cargo addItemCargoGlobal [_class, _count];
            };
        } forEach _itemsArray;

        // Add visual markers
        private _Chemlight1 = "Chemlight_red" createVehicle (position _cargo); 
        _Chemlight1 attachTo [_cargo, [0,0.5,-0.4]]; 
        private _Chemlight2 = "Chemlight_red" createVehicle (position _cargo); 
        _Chemlight2 attachTo [_cargo, [0,-0.5,-0.4]]; 
        private _Smoke = "SmokeShellRed" createVehicle (position _cargo); 
        _Smoke attachTo [_cargo, [0,0,0]]; 

        // Handle Landing
        waitUntil { (getPos _cargo select 2) < 4 }; 
        _cargo setVelocity (velocity _cargo); 
        
        waitUntil { (getPos _cargo select 2) < 0.5 }; 
        playSound3D ["a3\sounds_f\weapons\Flare_Gun\flaregun_1_shoot.wss", _cargo]; 
        detach _cargo; 
        _parachute disableCollisionWith _cargo; 

        sleep 6;
        if (!isNull _parachute) then { deleteVehicle _parachute; };
    };

    sleep 30; 
    try { _vtol animateDoor ['Door_1_source', 0]; } catch {};
    _vtol allowDamage true; 

    sleep 30;

    deleteVehicle _vtol;
    {deleteVehicle _x} forEach units _group;  
};
