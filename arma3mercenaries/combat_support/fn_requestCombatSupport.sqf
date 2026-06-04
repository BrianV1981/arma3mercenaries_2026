/*
    A3M_fnc_requestCombatSupport
    Author: A.I.M. Exoskeleton
*/
params ["_scriptId", "_durationSecs"];

if (_scriptId == "") exitWith { diag_log "A3M_fnc_requestCombatSupport: Empty ID."; };

if (isNil "A3M_CombatSupportConfig") then {
    A3M_CombatSupportConfig = createHashMapFromArray [
        ["ARTY1", ["B_MBT_01_arty_F", "WEST", "ARTY", "Sholef", "blufor_arty_1", 0]],
        ["ARTY2", ["B_MBT_01_arty_F", "WEST", "ARTY", "Seara", "blufor_arty_2", 0]],
        ["ARTY3", ["B_MBT_01_arty_F", "GUER", "ARTY", "Zamak MRL", "independent_arty_1", 0]],
        ["CAS1", ["B_Heli_Attack_01_F", "WEST", "CAS", "RAH-66 Comanchie", "blufor_cas_1", 60]],
        ["CAS10", ["B_MBT_01_TUSK_F", "WEST", "CAS", "Merkava MK IV LIC C", "blufor_cas_8", 60]],
        ["CAS11", ["B_MRAP_01_hmg_F", "WEST", "CAS", "M-ATV (HMG) C", "blufor_cas_9", 60]],
        ["CAS12", ["B_MRAP_01_gmg_F", "WEST", "CAS", "M-ATV (GMG) C", "blufor_cas_10", 60]],
        ["CAS13", ["B_APC_Tracked_01_AA_F", "WEST", "CAS", "Bardelas (AA) C", "blufor_cas_11", 60]],
        ["CAS14", ["I_MBT_03_cannon_F", "GUER", "CAS", "Leopard 2SG C", "independent_cas_4", 60]],
        ["CAS15", ["B_Heli_Attack_01_F", "WEST", "CAS", "V-44 X Blackfish C", "blufor_cas_12", 60]],
        ["CAS2", ["B_Heli_Attack_01_F", "WEST", "CAS", "A-164 Wipeout", "blufor_cas_2", 60]],
        ["CAS3", ["B_Heli_Attack_01_F", "WEST", "CAS", "F/A-181 Black Wasp II", "blufor_cas_3", 60]],
        ["CAS4", ["B_Heli_Attack_01_F", "WEST", "CAS", "F/A-181 Black Wasp II (Stealth)", "blufor_cas_4", 60]],
        ["CAS5", ["B_Heli_Attack_01_F", "GUER", "CAS", "AW159 Wildcat (CAS)", "independent_cas_1", 60]],
        ["CAS6", ["B_Heli_Attack_01_F", "GUER", "CAS", "L-159 ALCA", "independent_cas_2", 60]],
        ["CAS7", ["B_Heli_Attack_01_F", "GUER", "CAS", "JAS 39 Gripen", "independent_cas_3", 60]],
        ["CAS8", ["B_Heli_Attack_01_F", "WEST", "CAS", "AH-6 Little Bird", "blufor_cas_5", 60]],
        ["CAS9", ["B_Heli_Attack_01_F", "WEST", "CAS", "Badger IFV C", "blufor_cas_7", 60]],
        ["TRANSPORT1", ["B_Heli_Transport_01_F", "WEST", "TRANSPORT", "UH-80 Ghost Hawk", "blufor_transport_1", 60]],
        ["TRANSPORT10", ["B_MBT_01_TUSK_F", "WEST", "TRANSPORT", "Merkava MK IV LIC", "blufor_transport_7", 60]],
        ["TRANSPORT11", ["B_Truck_01_fuel_F", "WEST", "TRANSPORT", "HEMTT Fuel", "blufor_transport_8", 60]],
        ["TRANSPORT12", ["B_Truck_01_Repair_F", "WEST", "TRANSPORT", "HEMTT Repair", "blufor_transport_9", 60]],
        ["TRANSPORT13", ["B_Truck_01_ammo_F", "WEST", "TRANSPORT", "HEMTT Ammo", "blufor_transport_10", 60]],
        ["TRANSPORT14", ["B_Truck_01_medical_F", "WEST", "TRANSPORT", "HEMTT Medical", "blufor_transport_11", 60]],
        ["TRANSPORT15", ["B_MRAP_01_F", "WEST", "TRANSPORT", "M-ATV (Unarmed)", "blufor_transport_12", 0]],
        ["TRANSPORT16", ["B_Heli_Transport_01_F", "WEST", "TRANSPORT", "M-ATV (HMG)", "blufor_transport_13", 60]],
        ["TRANSPORT17", ["B_MRAP_01_gmg_F", "WEST", "TRANSPORT", "M-ATV (GMG)", "blufor_transport_14", 60]],
        ["TRANSPORT18", ["B_APC_Tracked_01_AA_F", "WEST", "TRANSPORT", "Bardelas (AA)", "blufor_transport_15", 60]],
        ["TRANSPORT19", ["I_MBT_03_cannon_F", "GUER", "TRANSPORT", "Leopard 2SG C", "independent_transport_4", 60]],
        ["TRANSPORT2", ["B_Heli_Transport_01_F", "WEST", "TRANSPORT", "CH47I Chinook", "blufor_transport_2", 60]],
        ["TRANSPORT20", ["I_Truck_02_ammo_F", "GUER", "TRANSPORT", "KamAZ Ammo", "independent_transport_5", 60]],
        ["TRANSPORT21", ["I_Truck_02_box_F", "GUER", "TRANSPORT", "KamAZ Repair", "independent_transport_6", 60]],
        ["TRANSPORT22", ["I_Truck_02_fuel_F", "WEST", "TRANSPORT", "KamAZ Fuel", "independent_transport_7", 60]],
        ["TRANSPORT23", ["I_Truck_02_medical_F", "WEST", "TRANSPORT", "KamAZ Medical", "independent_transport_8", 60]],
        ["TRANSPORT24", ["I_MRAP_03_F", "GUER", "TRANSPORT", "Fennek", "independent_transport_9", 60]],
        ["TRANSPORT25", ["I_MRAP_03_hmg_F", "GUER", "TRANSPORT", "Fennek (HMG)", "independent_transport_10", 60]],
        ["TRANSPORT26", ["I_MRAP_03_gmg_F", "GUER", "TRANSPORT", "Fennek (GMG)", "independent_transport_11", 60]],
        ["TRANSPORT27", ["I_APC_Wheeled_03_cannon_F", "GUER", "TRANSPORT", "Pandur II", "independent_transport_12", 60]],
        ["TRANSPORT28", ["I_APC_tracked_03_cannon_F", "GUER", "TRANSPORT", "FV510 Warrior", "independent_transport_13", 60]],
        ["TRANSPORT29", ["B_T_VTOL_01_infantry_F", "WEST", "TRANSPORT", "V-44 X Blackfish I", "blufor_transport_16", 225]],
        ["TRANSPORT3", ["B_Heli_Transport_01_F", "WEST", "TRANSPORT", "MH-9 Hummingbird", "blufor_transport_3", 60]],
        ["TRANSPORT30", ["B_T_VTOL_01_vehicle_F", "WEST", "TRANSPORT", "V-44 X Blackfish V", "blufor_transport_17", 225]],
        ["TRANSPORT4", ["B_Heli_Transport_01_F", "GUER", "TRANSPORT", "AW159 Wildcat (Unarmed)", "independent_transport_1", 60]],
        ["TRANSPORT5", ["B_Heli_Transport_01_F", "GUER", "TRANSPORT", "AW101 Merlin", "independent_transport_2", 60]],
        ["TRANSPORT6", ["B_Truck_01_transport_F", "WEST", "TRANSPORT", "HEMTT Transport", "blufor_transport_4", 60]],
        ["TRANSPORT7", ["I_Truck_02_transport_F", "GUER", "TRANSPORT", "KamAZ Transport", "independent_transport_3", 60]],
        ["TRANSPORT8", ["B_APC_Tracked_01_rcws_F", "WEST", "TRANSPORT", "Namer", "blufor_transport_5", 60]],
        ["TRANSPORT9", ["B_APC_Wheeled_01_cannon_F", "WEST", "TRANSPORT", "Badger IFV", "blufor_transport_6", 60]],
        ["placeholder", []]
    ];
};

private _config = A3M_CombatSupportConfig getOrDefault [_scriptId, []];
if (count _config == 0) exitWith { diag_log format ["A3M_fnc_requestCombatSupport: Invalid ID %1", _scriptId]; };

_config params ["_classname", "_side", "_type", "_callsign", "_marker", "_dir"];
private _safePos = getMarkerPos _marker;
if (_safePos isEqualTo [0,0,0]) exitWith { diag_log format ["A3M_fnc_requestCombatSupport: Invalid marker %1", _marker]; };

[_side, _type, _callsign] call ALiVE_fnc_combatSupportRemove;

[
    {
        params ["_side", "_type", "_callsign", "_safePos", "_dir", "_classname", "_durationSecs"];
        
        private _supportData = [];
        if (_type == "ARTY") then {
            _supportData = [
                _safePos,
                _classname,
                _callsign,
                1,
                [
                    ["HE", 30],
                    ["ILLUM", 30],
                    ["SMOKE", 30],
                    ["SADARM", 30],
                    ["CLUSTER", 30],
                    ["LASER", 30],
                    ["MINE", 30],
                    ["AT MINE", 30],
                    ["ROCKETS", 30]
                ],
                ""
            ];
        } else {
            _supportData = [
                _safePos,
                _dir,
                _classname,
                _callsign,
                "(group (_this select 0)) setVariable ['Vcm_Disable',true]; (group (_this select 0)) setVariable ['ALiVE_disableDynamicSimulation',true,true];",
                "0"
            ];
            
            if (_type == "TRANSPORT") then {
                private _isHeli = _classname isKindOf "Helicopter";
                _supportData pushBack _isHeli;
                _supportData pushBack 0;
            };
        };

        [_type, _supportData] call ALiVE_fnc_combatSupportAdd;
        
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
    2
] call CBA_fnc_waitAndExecute;

[format ["%1 requested. It will arrive shortly.", _callsign]] remoteExec ["systemChat", 0];
