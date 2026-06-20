/*
    fn_receiveShadowOpsRoster.sqf
    Client-side function triggered by the server to populate the eligible Shadow Ops roster.
*/
params ["_rosterData"];

disableSerialization;
private _display = findDisplay 7050;
if (isNull _display) exitWith {};

private _rosterListCtrl = _display displayCtrl 7053;
private _selectedListCtrl = _display displayCtrl 7067;
lbClear _rosterListCtrl;
lbClear _selectedListCtrl;

if (count _rosterData == 0) exitWith {
    _rosterListCtrl lbAdd "No eligible mercenaries in the barracks.";
};

{
    _x params ["_mercID", "_name", "_logicalClass", "_kills"];
    
    private _displayName = format ["%1 - %2 (Kills: %3)", _name, _logicalClass, _kills];
    private _index = _rosterListCtrl lbAdd _displayName;
    
    // Store the database ID and logical class in the UI control data so we know who we selected
    _rosterListCtrl lbSetData [_index, format ["%1|%2", _mercID, _logicalClass]];
} forEach _rosterData;
