// File: arma3mercenaries\leaderboard\fn_openLeaderboard.sqf
/*
    fn_openLeaderboard.sqf
    Handles fetching leaderboard data from the server and populating the UI.
*/

if (!hasInterface) exitWith {};

createDialog "A3M_LeaderboardDialog";

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

_listCtrl1 lbAdd "Retrieving Global Stats...";
_listCtrl2 lbAdd "Compiling Shots...";
_listCtrl3 lbAdd "Auditing Wealth...";
_listCtrl4 lbAdd "Calculating Distance...";

// Trigger real-time compilation of the SQLite database
"a3m_db_core" callExtension ["compile_leaderboard"];

// Fetch leaderboard from server
[player] remoteExecCall ["A3M_fnc_serverFetchLeaderboard", 2];