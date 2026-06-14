/*
    arma3mercenaries\ticketing\fn_submitTicket.sqf
    Client-side script to pull data from the UI and forward to server.
*/
disableSerialization;

private _display = findDisplay 7700;
if (isNull _display) exitWith {};

private _title = ctrlText (_display displayCtrl 7701);
private _desc = ctrlText (_display displayCtrl 7702);

if (_title == "" || _desc == "") exitWith {
    hint "You must fill out both the Title and Description!";
};

closeDialog 0;
hint "Submitting ticket to server...";

[player, _title, _desc] remoteExecCall ["A3M_fnc_serverLogTicket", 2];
