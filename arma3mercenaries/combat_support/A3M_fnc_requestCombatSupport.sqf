/*
    A3M_fnc_requestCombatSupport
    Author: A.I.M. Exoskeleton
    Description: Unified, unscheduled data-driven combat support request.
*/
params ["_classname", "_durationSecs"];

// Validate classname
if (_classname == "") exitWith { diag_log "A3M_fnc_requestCombatSupport: Empty classname."; };

// Define the Master Config
if (isNil "A3M_CombatSupportConfig") then {
    A3M_CombatSupportConfig = createHashMapFromArray [
        ["B_T_VTOL_01_vehicle_F", ["WEST", "TRANSPORT", "V-44 X Blackfish V", "blufor_transport_17", 225]],
        ["I_Plane_Fighter_03_dynamicLoadout_F", ["GUER", "CAS", "L-159 ALCA", "independent_cas_2", 45]],
        ["B_Truck_01_Repair_F", ["WEST", "TRANSPORT", "HEMTT Repair", "blufor_transport_9", 60]],
        ["B_Heli_Transport_03_F", ["WEST", "TRANSPORT", "CH47I Chinook", "blufor_transport_2", 60]],
        ["I_Truck_02_ammo_F", ["GUER", "TRANSPORT", "KamAZ Ammo", "independent_transport_5", 60]],
        ["B_Truck_01_fuel_F", ["WEST", "TRANSPORT", "HEMTT Fuel", "blufor_transport_8", 60]],
        ["I_Heli_light_03_unarmed_F", ["GUER", "TRANSPORT", "AW159 Wildcat (Unarmed)", "independent_transport_1", 60]],
        ["B_Truck_01_medical_F", ["WEST", "TRANSPORT", "HEMTT Medical", "blufor_transport_11", 60]],
        ["I_Truck_02_medical_F", ["WEST", "TRANSPORT", "KamAZ Medical", "independent_transport_8", 60]],
        ["I_Truck_02_transport_F", ["GUER", "TRANSPORT", "KamAZ Transport", "independent_transport_3", 60]],
        ["B_APC_Wheeled_01_cannon_F", ["WEST", "CAS", "Badger IFV C", "blufor_cas_7", 60]],
        ["B_Truck_01_transport_F", ["WEST", "TRANSPORT", "HEMTT Transport", "blufor_transport_4", 60]],
        ["B_T_VTOL_01_armed_F", ["WEST", "CAS", "V-44 X Blackfish C", "blufor_cas_12", 225]],
        ["B_MRAP_01_gmg_F", ["WEST", "CAS", "M-ATV (GMG) C", "blufor_cas_10", 60]],
        ["I_MRAP_03_F", ["GUER", "TRANSPORT", "Fennek", "independent_transport_9", 60]],
        ["I_Truck_02_fuel_F", ["WEST", "TRANSPORT", "KamAZ Fuel", "independent_transport_7", 60]],
        ["B_Plane_Fighter_01_F", ["WEST", "CAS", "F/A-181 Black Wasp II", "blufor_cas_3", 225]],
        ["I_APC_tracked_03_cannon_F", ["GUER", "TRANSPORT", "FV510 Warrior", "independent_transport_13", 60]],
        ["I_MBT_03_cannon_F", ["GUER", "CAS", "Leopard 2SG C", "independent_cas_4", 60]],
        ["I_APC_Wheeled_03_cannon_F", ["GUER", "TRANSPORT", "Pandur II", "independent_transport_12", 60]],
        ["B_Heli_Light_01_F", ["WEST", "TRANSPORT", "MH-9 Hummingbird", "blufor_transport_3", 60]],
        ["B_APC_Tracked_01_AA_F", ["WEST", "CAS", "Bardelas (AA) C", "blufor_cas_11", 60]],
        ["B_T_VTOL_01_infantry_F", ["WEST", "TRANSPORT", "V-44 X Blackfish I", "blufor_transport_16", 225]],
        ["B_MBT_01_TUSK_F", ["WEST", "TRANSPORT", "Merkava MK IV LIC", "blufor_transport_7", 60]],
        ["B_APC_Tracked_01_rcws_F", ["WEST", "TRANSPORT", "Namer", "blufor_transport_5", 60]],
        ["I_MRAP_03_hmg_F", ["GUER", "TRANSPORT", "Fennek (HMG)", "independent_transport_10", 60]],
        ["I_Heli_light_03_dynamicLoadout_F", ["GUER", "CAS", "AW159 Wildcat (CAS)", "independent_cas_1", 60]],
        ["B_Plane_Fighter_01_Stealth_F", ["WEST", "CAS", "F/A-181 Black Wasp II (Stealth)", "blufor_cas_4", 225]],
        ["I_MRAP_03_gmg_F", ["GUER", "TRANSPORT", "Fennek (GMG)", "independent_transport_11", 60]],
        ["B_MRAP_01_hmg_F", ["WEST", "TRANSPORT", "M-ATV (HMG)", "blufor_transport_13", 60]],
        ["I_Truck_02_box_F", ["GUER", "TRANSPORT", "KamAZ Repair", "independent_transport_6", 60]],
        ["I_Plane_Fighter_04_F", ["GUER", "CAS", "JAS 39 Gripen", "independent_cas_3", 45]],
        ["B_Heli_Light_01_dynamicLoadout_F", ["WEST", "CAS", "AH-6 Little Bird", "blufor_cas_5", 60]],
        ["placeholder", []]
    ];
};

private _config = A3M_CombatSupportConfig getOrDefault [_classname, []];
if (count _config == 0) exitWith { diag_log format ["A3M_fnc_requestCombatSupport: Invalid classname %1", _classname]; };

_config params ["_side", "_type", "_callsign", "_marker", "_dir"];
private _safePos = getMarkerPos _marker;

if (_safePos isEqualTo [0,0,0]) exitWith { diag_log format ["A3M_fnc_requestCombatSupport: Invalid marker %1", _marker]; };

// Remove existing
[_side, _type, _callsign] call ALiVE_fnc_combatSupportRemove;

// Spawn after short delay using CBA
[
    {
        params ["_side", "_type", "_callsign", "_safePos", "_dir", "_classname", "_durationSecs"];
        
        // Add new
        [
            _type,
            [
                _safePos,
                _dir,
                _classname,
                _callsign,
                "",
                "(group (_this select 0)) setVariable ['Vcm_Disable',true]; (group (_this select 0)) setVariable ['ALiVE_disableDynamicSimulation',true,true];"
            ]
        ] call ALiVE_fnc_combatSupportAdd;
        
        // Schedule removal
        [
            {
                params ["_side", "_type", "_callsign"];
                [_side, _type, _callsign] call ALiVE_fnc_combatSupportRemove;
            },
            [_side, _type, _callsign],
            _durationSecs
        ] call CBA_fnc_waitAndExecute;
    },
    [_side, _type, _callsign, _safePos, _dir, _classname, _durationSecs],
    2 // 2 seconds delay to allow removal to process
] call CBA_fnc_waitAndExecute;

systemChat format ["%1 requested. It will arrive shortly.", _callsign];
