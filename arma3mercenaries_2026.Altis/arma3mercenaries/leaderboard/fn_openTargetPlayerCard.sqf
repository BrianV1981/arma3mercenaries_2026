/*
    fn_openTargetPlayerCard.sqf
    Called when a player double clicks a row in the Global Leaderboard.
*/
params ["_control", "_selectedIndex"];

private _steamId = _control lbData _selectedIndex;
if (_steamId == "") exitWith {
    hint "No player data available for this entry.";
};

private _rowText = _control lbText _selectedIndex;
// Example: "1. Vasquez - 24 Kills"
// Extract just the name for the title, or fallback to something generic.
private _nameParts = _rowText splitString ".- ";
private _targetName = if (count _nameParts >= 2) then { _nameParts select 1 } else { "ENCRYPTED TARGET" };

// We need to close the leaderboard before opening the player card cleanly
closeDialog 0;

[_steamId, _targetName] spawn {
    params ["_steamId", "_targetName"];
    waitUntil {isNull (findDisplay 7030)};
    
    createDialog "A3M_PlayerProfileDialog";

    private _display = findDisplay 7020;
    if (isNull _display) exitWith {};

    private _titleCtrl = _display displayCtrl 7021;
    _titleCtrl ctrlSetText format ["CONSTELLIS DOSSIER: %1", toUpper(_targetName)];

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

    [_steamId, player] remoteExecCall ["A3M_fnc_serverFetchTargetProfileForClient", 2];
};