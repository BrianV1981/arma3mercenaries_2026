/*
    fn_shadowOpsDispatch.sqf
    Triggered when the player clicks DISPATCH SQUAD in the Shadow Ops UI.
*/
disableSerialization;

private _display = findDisplay 7050;
if (isNull _display) exitWith {};

// 1. Get Selected Mission
private _missionListCtrl = _display displayCtrl 7052;
private _selectedMissionIndex = lbCurSel _missionListCtrl;

if (_selectedMissionIndex == -1) exitWith {
    systemChat "Error: You must select a contract first.";
};

private _missionIndexStr = _missionListCtrl lbData _selectedMissionIndex;
private _missionIndex = parseNumber _missionIndexStr;
private _missions = _display getVariable ["A3M_ShadowOps_Missions", []];
private _missionData = _missions select _missionIndex;

// Remove mission from session array so it doesn't appear again
private _sessionMissions = player getVariable ["A3M_ShadowOps_SessionMissions", []];
if (_missionIndex < count _sessionMissions) then {
    _sessionMissions deleteAt _missionIndex;
    player setVariable ["A3M_ShadowOps_SessionMissions", _sessionMissions];
};

// 2. Tally Upgrades from Cart
private _purchasedList = _display displayCtrl 7062;
private _allAssets = _display getVariable ["A3M_ShadowOps_Catalog", []];

private _totalCost = 0;
private _intelMod = 0;
private _p1Mod = 0;
private _p2Mod = 0;
private _p3Mod = 0;

private _assetNames = [];

for "_i" from 0 to ((lbSize _purchasedList) - 1) do {
    private _assetIdx = parseNumber (_purchasedList lbData _i);
    private _assetData = _allAssets select _assetIdx;
    
    _assetData params ["_cat", "_name", "_cost", "_iMod", "_1Mod", "_2Mod", "_3Mod"];
    
    _totalCost = _totalCost + _cost;
    _intelMod = _intelMod + _iMod;
    _p1Mod = _p1Mod + _1Mod;
    _p2Mod = _p2Mod + _2Mod;
    _p3Mod = _p3Mod + _3Mod;
    _assetNames pushBack _name;
};

// 3. Get Selected Mercenaries from the Assigned Listbox
private _selectedList = _display displayCtrl 7067;
private _squadCount = lbSize _selectedList;

if (_squadCount == 0) exitWith {
    systemChat "Error: You must assign at least one mercenary to the squad before dispatching.";
};

private _selectedMercs = [];
for "_i" from 0 to (_squadCount - 1) do {
    private _dataStr = _selectedList lbData _i;
    private _mercID = (_dataStr splitString "|") select 0;
    _selectedMercs pushBack _mercID;
};

// Add hazard pay
private _hazardPay = _squadCount * 20000;
_totalCost = _totalCost + _hazardPay;

// 4. Financial Check
private _playerFunds = [player, false] call grad_lbm_fnc_getFunds;
if (_playerFunds < _totalCost) exitWith {
    systemChat format ["Error: Insufficient funds. You need $%1 for this operational plan.", _totalCost];
};

// Deduct Funds
if (_totalCost > 0) then {
    [player, -_totalCost] call grad_lbm_fnc_addFunds;
};

// Package plan data and append the purchased asset names to it so the server can re-verify synergies with ACTUAL weather
private _planData = [_intelMod, _p1Mod, _p2Mod, _p3Mod, _assetNames];

// 5. Dispatch to server
[_missionData, _selectedMercs, _planData, player] remoteExecCall ["A3M_fnc_serverShadowOpsDispatch", 2];

// Close dialog and notify
closeDialog 0;
systemChat format ["Dispatch orders sent. Operation funded: $%1 deducted.", _totalCost];
