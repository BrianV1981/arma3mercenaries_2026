/*
    fn_openPlayerCard.sqf
    Handles fetching profile data and populating the Player Card UI.
*/

if (!hasInterface) exitWith {};

createDialog "A3M_PlayerProfileDialog";

private _display = findDisplay 7020;
if (isNull _display) exitWith {};

private _titleCtrl = _display displayCtrl 7021;
_titleCtrl ctrlSetText format ["CONSTELLIS DOSSIER: %1", toUpper(name player)];

private _listCtrl1 = _display displayCtrl 7022;
private _listCtrl2 = _display displayCtrl 7023;
private _listCtrl3 = _display displayCtrl 7024;
private _listCtrl4 = _display displayCtrl 7025;

lbClear _listCtrl1;
lbClear _listCtrl2;
lbClear _listCtrl3;
lbClear _listCtrl4;

_listCtrl1 lbAdd "Retrieving from A3M Database...";
_listCtrl2 lbAdd "Syncing Combat Logs...";
_listCtrl3 lbAdd "Syncing Logistics...";
_listCtrl4 lbAdd "Surveying Active Assets...";

// Fetch profile
[player] remoteExecCall ["A3M_fnc_serverFetchProfileForClient", 2];