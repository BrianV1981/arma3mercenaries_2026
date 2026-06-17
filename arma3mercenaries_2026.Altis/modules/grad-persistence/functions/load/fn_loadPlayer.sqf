#include "script_component.hpp"

private _playerWaitCondition = [missionConfigFile >> "CfgGradPersistence", "playerWaitCondition", ""] call BIS_fnc_returnConfigEntry;
if (_playerWaitCondition == "") then {_playerWaitCondition = "true"};

private _fnc_waitUntil = {
    params ["_passedArgs", "_waitCond"];
    if !(_passedArgs isEqualType []) exitWith { false };
    private _unit = _passedArgs param [0, objNull];
    if (isNull _unit) exitWith { false };
    
    [_unit,side _unit,typeOf _unit,roleDescription _unit] call compile _waitCond
};

[_fnc_waitUntil, {
    params ["_args","_playerWaitCondition"];
    _args params [
        "_unit",
        ["_savePlayerInventory",([missionConfigFile >> "CfgGradPersistence", "savePlayerInventory", 1] call BIS_fnc_returnConfigEntry) == 1],
        ["_savePlayerDamage",([missionConfigFile >> "CfgGradPersistence", "savePlayerDamage", 0] call BIS_fnc_returnConfigEntry) == 1],
        ["_savePlayerPosition",([missionConfigFile >> "CfgGradPersistence", "savePlayerPosition", 0] call BIS_fnc_returnConfigEntry) == 1],
        ["_savePlayerMoney",([missionConfigFile >> "CfgGradPersistence", "savePlayerMoney", 1] call BIS_fnc_returnConfigEntry) == 1]
    ];

    private _missionTag = [] call FUNC(getMissionTag);
    
    private _uid = getPlayerUID _unit;
    if (_uid == "") exitWith {ERROR_1("UID for player %1 not found.",name _unit)};

    // --- A.I.M. v812+ Architecture: Fetch Player State from SQLite ---
    private _uniquePlayerKey = format ["%1_player_%2", _missionTag, _uid];
    
    // Fetch and reconstruct the native HashMap (true parameter)
    private _unitDataHash = [_uniquePlayerKey, createHashMap, true] call A3M_fnc_dbGetSecure;
    
    // --- A.I.M. Lobby Dummy Overwrite Fix ---
    // We MUST unlock the profile save BEFORE the early exit so fresh profiles can be saved!
    _unit setVariable ["A3M_GearLoaded", true, true];

    // Check if the HashMap is empty (player has no save data)
    if (count _unitDataHash == 0) exitWith {INFO_1("SQLite data for player %1 not found.",name _unit)};

    if (_savePlayerInventory) then {
        private _unitLoadout = _unitDataHash getOrDefault ["inventory", []];
        if (count _unitLoadout > 0) then {
            _unit setUnitLoadout [_unitLoadout,false];
        };
    };

    if (_savePlayerDamage) then {
        if (isClass(configfile >> "CfgPatches" >> "ace_medical")) then {

            private _unitHits = _unitDataHash getOrDefault ["damage", []];
            if (count _unitHits > 0) then {
                [_unit, _unitHits] remoteExecCall ["ace_medical_fnc_deserializeState", _unit, false];
                diag_log "ACE DETECTED - PreLoading ACE wounds";
                diag_log format ["%1", _unitHits];
            };
            
        } else {
            private _unitHits = _unitDataHash getOrDefault ["damage", []];
            if (count _unitHits > 0) then {
                _unitHits params ["_unitHitNames","_unitHitDamages"];
                {
                    _unit setHit [_x,_unitHitDamages select _forEachIndex];
                } forEach _unitHitNames;
            };
        };
    };

    if (_savePlayerPosition) then {
        private _unitPosASL = _unitDataHash getOrDefault ["posASL", []];
        private _unitDir = _unitDataHash getOrDefault ["dir", -1];

        if ((count _unitPosASL > 0) && (_unitDir != -1)) then {
            _unit setPosASL _unitPosASL;
            _unit setDir _unitDir;
        };
    };

    if (_savePlayerMoney) then {
        private _unitMoney = _unitDataHash getOrDefault ["money", -1];
        if (_unitMoney != -1) then {
            _unit setVariable ["grad_lbm_myFunds",_unitMoney,true];
        };

        private _unitBankMoney = _unitDataHash getOrDefault ["bankMoney", -1];
        if (_unitBankMoney != -1) then {
            _unit setVariable ["grad_moneymenu_myBankBalance",_unitBankMoney,true];
        };
    };

    private _vars = _unitDataHash getOrDefault ["vars", []];
    [_vars,_unit] call FUNC(loadObjectVars);

}, [_this,_playerWaitCondition]] call CBA_fnc_waitUntilAndExecute;