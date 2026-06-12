/*
    fn_receiveBountyData.sqf
    Receives bounty list from server and populates the Bounty Board UI.
*/
params ["_bountyList"];
if (!hasInterface) exitWith {};

private _display = findDisplay 7030;
if (isNull _display) exitWith {};

private _listCtrl = _display displayCtrl 7032;
lbClear _listCtrl;

if (count _bountyList == 0) then {
    _listCtrl lbAdd "No active bounties found.";
    _listCtrl lbAdd "";
    _listCtrl lbAdd "Use the input below to place a new bounty on any player.";
} else {
    _listCtrl lbAdd format ["--- %1 ACTIVE BOUNTIES ---", count _bountyList];
    _listCtrl lbAdd "";
    {
        _x params ["_uid", "_name", "_amount", "_isOnline"];
        private _status = if (_isOnline) then {"[ONLINE]"} else {"[OFFLINE]"};
        _listCtrl lbAdd format ["%1 %2 - $%3 bounty", _status, _name, _amount];
        _listCtrl lbSetData [_forEachIndex + 2, _uid]; // Store UID for placement
    } forEach _bountyList;
};

// Store the full list for the place button to reference
uiNamespace setVariable ["A3M_BountyList", _bountyList];
