/*
    fn_openBountyBoard.sqf
    Opens the Bounty Board dialog and requests bounty data from the server.
*/
if (!hasInterface) exitWith {};

createDialog "A3M_BountyBoardDialog";

private _display = findDisplay 7030;
if (isNull _display) exitWith {};

private _titleCtrl = _display displayCtrl 7031;
_titleCtrl ctrlSetText "A3M BOUNTY BOARD";

private _listCtrl = _display displayCtrl 7032;
lbClear _listCtrl;
_listCtrl lbAdd "Fetching active bounties from server...";

private _infoCtrl = _display displayCtrl 7033;
_infoCtrl ctrlSetText "Select a target and enter an amount to place a bounty.";

// Request bounty data from server
[player] remoteExecCall ["A3M_fnc_serverFetchBountyTargets", 2];
