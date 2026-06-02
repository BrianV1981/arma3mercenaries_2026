#include "script_component.hpp"

if (!isServer) exitWith {};

private _missionTag = [] call FUNC(getMissionTag);
private _accountsTag = _missionTag + "_teamAccounts";

// --- A.I.M. v812+ Architecture: Direct SQLite Load ---
private _teamAccountHash = [_accountsTag, createHashMap, true] call A3M_fnc_dbGetSecure;

if (count _teamAccountHash > 0) then {
    missionNamespace setVariable ["grad_lbm_teamFunds_WEST", _teamAccountHash getOrDefault ["WEST", 0], true];
    missionNamespace setVariable ["grad_lbm_teamFunds_EAST", _teamAccountHash getOrDefault ["EAST", 0], true];
    missionNamespace setVariable ["grad_lbm_teamFunds_INDEPENDENT", _teamAccountHash getOrDefault ["INDEPENDENT", 0], true];
    missionNamespace setVariable ["grad_lbm_teamFunds_CIVILIAN", _teamAccountHash getOrDefault ["CIVILIAN", 0], true];
};
