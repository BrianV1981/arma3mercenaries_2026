/*  A3M OVERFLOW INTERCEPTOR
*   Sends buy request to server or opens Overflow Menu if full.
*/

#include "..\..\dialog\defines.hpp"
disableSerialization;

// --- A3M ANTI-SPAM PACER ---
private _lastBuy = player getVariable ["A3M_LBM_LastBuyTime", 0];
if (diag_tickTime - _lastBuy < 0.5) exitWith { 
    systemChat "Transaction processing. Please wait..."; 
};
player setVariable ["A3M_LBM_LastBuyTime", diag_tickTime];
// ---------------------------

private _dialog = findDisplay grad_lbm_DIALOG;
private _listCtrl = _dialog displayCtrl grad_lbm_ITEMLIST;
private _selIndex = lnbCurSelRow _listCtrl;
(call compile (_listCtrl lnbData [_selIndex,0])) params ["_baseConfigName", "_categoryConfigName", "_itemConfigName", "_displayName", "_price", "_description", "_code", "_picturePath"];

private _funds = [] call grad_lbm_fnc_getCurrentFunds;
if (_funds < _price) exitWith {systemChat "Not enough funds.";};

// A3M Logistics Overhaul: Pre-Flight Space Check
private _amount = [(missionConfigFile >> "CfgGradBuymenu" >> _baseConfigName >> _categoryConfigName >> _itemConfigName >> "amount"), "number", 1] call CBA_fnc_getConfigEntry;
private _kindOf = toUpper ([(missionConfigFile >> "CfgGradBuymenu" >> _baseConfigName >> _categoryConfigName >> _itemConfigName >> "kindOf"), "text", ""] call CBA_fnc_getConfigEntry);
if (_kindOf == "") then {_kindOf = toUpper ([(missionConfigFile >> "CfgGradBuymenu" >> _baseConfigName >> _categoryConfigName >> "kindOf"), "text", ""] call CBA_fnc_getConfigEntry)};

private _hasSpace = true;

if (_kindOf in ["WEAPONS", "ITEMS", "WEARABLES"]) then {
    _hasSpace = player canAdd [_itemConfigName, _amount];
};

if (_kindOf == "FORTIFICATION") then {
    if (!isNil "grad_fortifications_fnc_canTake") then {
        // canTake requires: [unit, classname, amount]
        _hasSpace = [player, _itemConfigName, _amount] call grad_fortifications_fnc_canTake;
    };
};

// If space is full, intercept and open the Overflow Menu
if (!_hasSpace) exitWith {
    // Pass the purchase parameters to the overflow menu
    private _purchaseData = [_baseConfigName, _categoryConfigName, _itemConfigName, _price, _kindOf];
    [_purchaseData] spawn grad_lbm_fnc_openOverflowMenu;
};

// If space is available, proceed normally (charging client visually, then firing to server)
if (missionNamespace getVariable ["grad_lbm_currentAccount",player] isEqualType objNull) then {
    [missionNamespace getVariable ["grad_lbm_currentAccount",player], -_price] call grad_lbm_fnc_addFunds;
    [] call grad_lbm_fnc_updateFunds;
};

// A3M Green Indicator Marker
[player, _displayName] spawn {
    params ["_target", "_displayName"];
    private _endTime = time + 15;
    waitUntil {
        if (isNull _target) exitWith {true};
        drawIcon3D ["a3\ui_f\data\gui\Rsc\RscDisplayIntel\azimuth_ca.paa", [0,1,0,1], (getPosATL _target) vectorAdd [0,0,2.5], 1, 1, 180, format ["%1 BOUGHT", _displayName], 1, 0.04, "PuristaMedium", "center", true];
        (time > _endTime)
    };
};

// Fire to Server with player as the target cargospace
[_baseConfigName, _categoryConfigName, _itemConfigName, player, _price, player, missionNamespace getVariable ["grad_lbm_currentAccount",player]] remoteExec ["grad_lbm_fnc_buyServer", 2, false];
