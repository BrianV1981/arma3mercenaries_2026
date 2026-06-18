/*
    fn_onShadowOpsRosterClick.sqf
    Handles clicking on the barracks roster to toggle selection.
*/
disableSerialization;
params ["_control", "_selectedIndex"];

if (_selectedIndex == -1) exitWith {};

private _display = findDisplay 7050;
if (isNull _display) exitWith {};

private _mercID = _control lbData _selectedIndex;
private _selectedMercs = _display getVariable ["A3M_ShadowOps_SelectedMercs", []];

private _idx = _selectedMercs find _mercID;

if (_idx == -1) then {
    // Select
    _selectedMercs pushBack _mercID;
    _control lbSetColor [_selectedIndex, [0, 1, 0, 1]]; // Green text
} else {
    // Deselect
    _selectedMercs deleteAt _idx;
    _control lbSetColor [_selectedIndex, [1, 1, 1, 1]]; // White text
};

_display setVariable ["A3M_ShadowOps_SelectedMercs", _selectedMercs];

// Clear the actual native selection to prevent UI bugs
_control lbSetCurSel -1;
