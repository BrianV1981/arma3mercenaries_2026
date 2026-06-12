/*
    fn_openSquadDossier.sqf
    Called when a player opens their squad dossier (either via player card or barracks object).
*/

if (!hasInterface) exitWith {};

params [["_isBarracks", false]];

createDialog "A3M_SquadDossierDialog";

private _display = findDisplay 7040;
if (isNull _display) exitWith { systemChat "Error: Could not open Squad Dossier"; };

private _titleCtrl = _display displayCtrl 7041;
_titleCtrl ctrlSetText format ["SQUAD DOSSIER: %1", toUpper(name player)];

private _listActive = _display displayCtrl 7042;
private _listGraveyard = _display displayCtrl 7043;

lbClear _listActive;
lbClear _listGraveyard;

_listActive lbAdd "Retrieving from A3M Database...";
_listGraveyard lbAdd "Syncing Graveyard Logs...";

// Fetch profile
[player, _isBarracks] remoteExecCall ["A3M_fnc_serverFetchSquadDossier", 2];
