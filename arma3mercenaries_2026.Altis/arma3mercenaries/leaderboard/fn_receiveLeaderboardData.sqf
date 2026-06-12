// File: arma3mercenaries\leaderboard\fn_receiveLeaderboardData.sqf
/*
    fn_receiveLeaderboardData.sqf
    Receives the compiled arrays from the server and populates the UI columns.
*/

params ["_topKillers", "_topShots", "_topWealth", "_topDistance"];
if (!hasInterface) exitWith {};

private _display = findDisplay 7030;
if (isNull _display) exitWith {};

private _listCtrl1 = _display displayCtrl 7032;
private _listCtrl2 = _display displayCtrl 7033;
private _listCtrl3 = _display displayCtrl 7034;
private _listCtrl4 = _display displayCtrl 7035;

lbClear _listCtrl1;
lbClear _listCtrl2;
lbClear _listCtrl3;
lbClear _listCtrl4;

// Column 1: Top Killers
_listCtrl1 lbAdd "--- MOST LETHAL ---";
_listCtrl1 lbAdd "";
{
    _x params ["_name", "_val", ["_steamId", ""]];
    private _idx = _listCtrl1 lbAdd format ["%1. %2 - %3 Kills", _forEachIndex + 1, _name, _val];
    if (_steamId != "") then { _listCtrl1 lbSetData [_idx, _steamId]; };
} forEach _topKillers;

// Column 2: Longest Shots
_listCtrl2 lbAdd "--- LONGEST SHOTS ---";
_listCtrl2 lbAdd "";
{
    _x params ["_name", "_val", ["_steamId", ""]];
    private _idx = _listCtrl2 lbAdd format ["%1. %2 - %3m", _forEachIndex + 1, _name, round _val];
    if (_steamId != "") then { _listCtrl2 lbSetData [_idx, _steamId]; };
} forEach _topShots;

// Column 3: Wealth
_listCtrl3 lbAdd "--- TOP WEALTH ---";
_listCtrl3 lbAdd "";
{
    _x params ["_name", "_val", ["_steamId", ""]];
    private _idx = _listCtrl3 lbAdd format ["%1. %2 - %3 cr.", _forEachIndex + 1, _name, _val];
    if (_steamId != "") then { _listCtrl3 lbSetData [_idx, _steamId]; };
} forEach _topWealth;

// Column 4: Distance Traveled
_listCtrl4 lbAdd "--- MOST TRAVELED ---";
_listCtrl4 lbAdd "";
{
    _x params ["_name", "_val", ["_steamId", ""]];
    private _idx = _listCtrl4 lbAdd format ["%1. %2 - %3m", _forEachIndex + 1, _name, round _val];
    if (_steamId != "") then { _listCtrl4 lbSetData [_idx, _steamId]; };
} forEach _topDistance;