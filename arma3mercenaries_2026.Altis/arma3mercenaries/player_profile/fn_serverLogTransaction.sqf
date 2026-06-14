/*
    arma3mercenaries\player_profile\fn_serverLogTransaction.sqf
    Author: A.I.M.
    Description: Called by any client (like HG Vehicles) to safely log a purchase into their SQLite dossier.
*/
params ["_buyer", "_displayName", "_price"];

if (!isServer) exitWith {};
if (isNull _buyer || !isPlayer _buyer) exitWith {};
if (isNil "A3M_LiveProfiles") exitWith {};

private _buyerUID = getPlayerUID _buyer;
if (_buyerUID == "") exitWith {};

private _profile = A3M_LiveProfiles getOrDefault [_buyerUID, createHashMap];
if (count _profile == 0) exitWith {};

// Update Last 10 Purchases
private _lastPurchases = _profile getOrDefault ["Last_10_Purchases", []];
private _purchaseEntry = [serverTime, _displayName, _price];
_lastPurchases insert [0, [_purchaseEntry]];
if (count _lastPurchases > 10) then { _lastPurchases resize 10; };
_profile set ["Last_10_Purchases", _lastPurchases];

// Save to Profile Memory and SQLite DB
A3M_LiveProfiles set [_buyerUID, _profile];
["A3M_PROFILE_" + _buyerUID, _profile] call A3M_fnc_dbSetSecure;

diag_log format ["[A3M LEDGER] HG Shop: UID %1 bought %2 for %3 cr.", _buyerUID, _displayName, _price];
