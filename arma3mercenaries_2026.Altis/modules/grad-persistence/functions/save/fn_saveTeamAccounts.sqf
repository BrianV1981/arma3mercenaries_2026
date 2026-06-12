if (!isServer) exitWith {};

private _missionTag = [] call grad_persistence_fnc_getMissionTag;
private _accountsTag = _missionTag + "_teamAccounts";

private _teamAccountHash = createHashMap;

_teamAccountHash set ["WEST", (missionNamespace getVariable ["grad_lbm_teamFunds_WEST",0])];
_teamAccountHash set ["EAST", (missionNamespace getVariable ["grad_lbm_teamFunds_EAST",0])];
_teamAccountHash set ["INDEPENDENT", (missionNamespace getVariable ["grad_lbm_teamFunds_INDEPENDENT",0])];
_teamAccountHash set ["CIVILIAN", (missionNamespace getVariable ["grad_lbm_teamFunds_CIVILIAN",0])];

// --- A.I.M. v812+ Architecture: Direct SQLite Save ---
[_accountsTag, _teamAccountHash] call A3M_fnc_dbSetSecure;
