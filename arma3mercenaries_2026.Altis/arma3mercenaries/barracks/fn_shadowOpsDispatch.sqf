/*
    fn_shadowOpsDispatch.sqf
    Handles client-side dispatch validation.
*/
disableSerialization;
private _display = findDisplay 7050;
if (isNull _display) exitWith {};

private _missionListCtrl = _display displayCtrl 7052;
private _assignedListCtrl = _display displayCtrl 7067;
private _purchasedList = _display displayCtrl 7062;

private _selIndex = lbCurSel _missionListCtrl;
if (_selIndex == -1) exitWith { systemChat "You must select a mission."; };

if (lbSize _assignedListCtrl == 0) exitWith { systemChat "You cannot dispatch a mission with no assigned squad members."; };

private _missionIdxStr = _missionListCtrl lbData _selIndex;
private _missionIndex = parseNumber _missionIdxStr;
private _missions = _display getVariable ["A3M_ShadowOps_Missions", []];
private _selectedMission = _missions select _missionIndex;

_selectedMission params ["_opName", "_mType", "_desc", "_baseDiff", "_mReward", "_time", "_weather", "_reqClass"];

// Extract Asset Info
private _allAssets = _display getVariable ["A3M_ShadowOps_Catalog", []];
private _totalCost = 0;
private _purchasedAssetData = [];

for "_i" from 0 to ((lbSize _purchasedList) - 1) do {
    private _dataStr = _purchasedList lbData _i;
    private _asset = _allAssets select (parseNumber _dataStr);
    _totalCost = _totalCost + (_asset select 2);
    _purchasedAssetData pushBack _asset;
};

// Add Hazard Pay Cost ($20k per Merc)
private _squadCount = lbSize _assignedListCtrl;
private _hazardPayCost = _squadCount * 20000;
_totalCost = _totalCost + _hazardPayCost;

// Check funds
private _playerFunds = player getVariable ["grad_lbm_myFunds", 0];
if (_playerFunds < _totalCost) exitWith {
    systemChat format ["Insufficient funds. You need $%1 to cover Hazard Pay and Assets.", _totalCost];
};

// Extract selected mercs
private _dispatchedMercIDs = [];
for "_i" from 0 to ((lbSize _assignedListCtrl) - 1) do {
    _dispatchedMercIDs pushBack (_assignedListCtrl lbData _i);
};

// Verify we have an Infil and Exfil selected (required)
private _hasInfil = false;
private _hasExfil = false;
{
    if ((_x select 0) == "INFIL") then { _hasInfil = true; };
    if ((_x select 0) == "EXFIL") then { _hasExfil = true; };
} forEach _purchasedAssetData;

if (!_hasInfil) exitWith { systemChat "Error: You MUST purchase an INFIL method."; };
if (!_hasExfil) exitWith { systemChat "Error: You MUST purchase an EXFIL method."; };

// Validated! Deduct funds
[player, -_totalCost] remoteExecCall ["grad_lbm_fnc_addFunds", 2];
systemChat format ["Squad dispatched. $%1 deducted (Assets + Hazard Pay).", _totalCost];

// Remove the mission from local session so it can't be spammed
_missions deleteAt _missionIndex;
player setVariable ["A3M_ShadowOps_SessionMissions", _missions];

closeDialog 0;

// Send to server
[_dispatchedMercIDs, _selectedMission, _purchasedAssetData, player] remoteExecCall ["A3M_fnc_serverShadowOpsThread", 2];
