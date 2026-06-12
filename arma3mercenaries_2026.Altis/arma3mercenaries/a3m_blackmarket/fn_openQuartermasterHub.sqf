/*
    A3M Quartermaster Hub Routing Script
    Description: Opens the custom Hub UI and dynamically assigns actions based on laptop variables.
*/

params ["_target", "_caller"];

// Read which modules this laptop is authorized to show.
private _modules = _target getVariable ["A3M_Hub_Modules", ["ARMORY", "VEHICLES", "FORTIFICATIONS", "SUPPORT", "CONTRACTORS"]];

createDialog "A3M_QuartermasterHub";
waitUntil {!isNull (findDisplay 9005)};
private _display = findDisplay 9005;

// Store the laptop globally so the nested menus know what they are interacting with
missionNamespace setVariable ["A3M_HG_CurrentLaptop", _target];

private _btnArmory = _display displayCtrl 1601;
private _btnVehicles = _display displayCtrl 1602;
private _btnFortifications = _display displayCtrl 1603;
private _btnSupport = _display displayCtrl 1604;
private _btnMercs = _display displayCtrl 1605;

// Hide everything initially
_btnArmory ctrlShow false;
_btnVehicles ctrlShow false;
_btnFortifications ctrlShow false;
_btnSupport ctrlShow false;
_btnMercs ctrlShow false;

// -------------------------------------------------------------
// Inject Routing Actions
// -------------------------------------------------------------

// Armory uses our custom Black Market Hook
_btnArmory buttonSetAction "closeDialog 0; [false] spawn A3M_fnc_openBlackMarket;";

// Vehicles uses HG
private _hgShop = _target getVariable ["A3M_Hub_HGShop", "HG_DefaultShop"]; // Defaults to standard if not set
_btnVehicles buttonSetAction format ["closeDialog 0; ['%1', missionNamespace getVariable ['A3M_HG_CurrentLaptop', player]] call HG_fnc_dialogOnLoadVehicles;", _hgShop];

// Base Building uses GRAD
private _gradFort = _target getVariable ["A3M_Hub_GradFort", "fortificationStore_1"];
_btnFortifications buttonSetAction format ["closeDialog 0; [missionNamespace getVariable ['A3M_HG_CurrentLaptop', player], objNull, objNull, '%1', '', player] call grad_lbm_fnc_loadBuymenu;", _gradFort];

// Combat Support uses GRAD
private _gradSupp = _target getVariable ["A3M_Hub_GradSupp", "aliveStore_1"];
_btnSupport buttonSetAction format ["closeDialog 0; [missionNamespace getVariable ['A3M_HG_CurrentLaptop', player], objNull, objNull, '%1', '', player] call grad_lbm_fnc_loadBuymenu;", _gradSupp];

// Contractors uses GRAD
private _gradMercs = _target getVariable ["A3M_Hub_GradMercs", "mercenaryStore_1"];
_btnMercs buttonSetAction format ["closeDialog 0; [missionNamespace getVariable ['A3M_HG_CurrentLaptop', player], objNull, objNull, '%1', '', player] call grad_lbm_fnc_loadBuymenu;", _gradMercs];

// -------------------------------------------------------------
// Layout Engine (Stack buttons dynamically)
// -------------------------------------------------------------
private _startY = 0.38;
private _spacingY = 0.07;
private _currentY = _startY;

if ("ARMORY" in _modules) then {
    _btnArmory ctrlShow true;
    _btnArmory ctrlSetPosition [0.4 * safezoneW + safezoneX, _currentY * safezoneH + safezoneY, 0.2 * safezoneW, 0.05 * safezoneH];
    _btnArmory ctrlCommit 0;
    _currentY = _currentY + _spacingY;
};

if ("VEHICLES" in _modules) then {
    _btnVehicles ctrlShow true;
    _btnVehicles ctrlSetPosition [0.4 * safezoneW + safezoneX, _currentY * safezoneH + safezoneY, 0.2 * safezoneW, 0.05 * safezoneH];
    _btnVehicles ctrlCommit 0;
    _currentY = _currentY + _spacingY;
};

if ("FORTIFICATIONS" in _modules) then {
    _btnFortifications ctrlShow true;
    _btnFortifications ctrlSetPosition [0.4 * safezoneW + safezoneX, _currentY * safezoneH + safezoneY, 0.2 * safezoneW, 0.05 * safezoneH];
    _btnFortifications ctrlCommit 0;
    _currentY = _currentY + _spacingY;
};

if ("SUPPORT" in _modules) then {
    _btnSupport ctrlShow true;
    _btnSupport ctrlSetPosition [0.4 * safezoneW + safezoneX, _currentY * safezoneH + safezoneY, 0.2 * safezoneW, 0.05 * safezoneH];
    _btnSupport ctrlCommit 0;
    _currentY = _currentY + _spacingY;
};

if ("CONTRACTORS" in _modules) then {
    _btnMercs ctrlShow true;
    _btnMercs ctrlSetPosition [0.4 * safezoneW + safezoneX, _currentY * safezoneH + safezoneY, 0.2 * safezoneW, 0.05 * safezoneH];
    _btnMercs ctrlCommit 0;
};
