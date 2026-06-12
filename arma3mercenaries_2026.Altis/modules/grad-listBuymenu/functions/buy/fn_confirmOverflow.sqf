/* A3M Overflow Interceptor Confirm */
disableSerialization;
private _dialog = findDisplay 9010;
if (isNull _dialog) exitWith {};

private _listCtrl = _dialog displayCtrl 9011;
private _sel = lnbCurSelRow _listCtrl;
if (_sel < 0) exitWith {systemChat "Select a destination first.";};

private _amountStr = ctrlText 9014;
private _amount = parseNumber _amountStr;
if (_amount < 1) exitWith {systemChat "Invalid amount. Must be at least 1.";};

private _nearby = uiNamespace getVariable ["A3M_LBM_NearbyContainers", []];
private _targetCargoSpace = _nearby select _sel;

if (isNull _targetCargoSpace) exitWith {systemChat "Invalid destination."; closeDialog 0;};

private _purchaseData = uiNamespace getVariable ["A3M_LBM_PendingPurchase", []];
_purchaseData params ["_baseConfigName", "_categoryConfigName", "_itemConfigName", "_price", "_kindOf"];

private _defaultAmount = [(missionConfigFile >> "CfgGradBuymenu" >> _baseConfigName >> _categoryConfigName >> _itemConfigName >> "amount"), "number", 1] call CBA_fnc_getConfigEntry;
private _totalPhysicalItems = _defaultAmount * _amount;
private _totalPrice = _price * _amount;

private _funds = [] call grad_lbm_fnc_getCurrentFunds;
if (_funds < _totalPrice) exitWith {systemChat format ["Not enough funds for %1 purchases.", _amount];};

private _hasSpace = true;
if (_kindOf in ["WEAPONS", "ITEMS", "WEARABLES"]) then {
    _hasSpace = _targetCargoSpace canAdd [_itemConfigName, _totalPhysicalItems];
};

if (_kindOf == "FORTIFICATION") then {
    if (!isNil "grad_fortifications_fnc_canTake") then {
        _hasSpace = [_targetCargoSpace, _itemConfigName, _totalPhysicalItems] call grad_fortifications_fnc_canTake;
    };
};

if (!_hasSpace) exitWith {
    systemChat format ["Not enough space in destination for %1 items.", _totalPhysicalItems];
};

if (missionNamespace getVariable ["grad_lbm_currentAccount",player] isEqualType objNull) then {
    [missionNamespace getVariable ["grad_lbm_currentAccount",player], -_totalPrice] call grad_lbm_fnc_addFunds;
    [] call grad_lbm_fnc_updateFunds;
};

for "_i" from 1 to _amount do {
    [_baseConfigName, _categoryConfigName, _itemConfigName, player, _price, _targetCargoSpace, missionNamespace getVariable ["grad_lbm_currentAccount",player]] remoteExec ["grad_lbm_fnc_buyServer", 2, false];
};

closeDialog 0;
