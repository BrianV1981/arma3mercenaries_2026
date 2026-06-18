/*
    fn_shadowOpsAddMerc.sqf
    Moves a selected mercenary from the Available Roster to the Assigned Roster.
*/
disableSerialization;
private _display = findDisplay 7050;
if (isNull _display) exitWith {};

private _availableList = _display displayCtrl 7066;
private _assignedList = _display displayCtrl 7067;

private _selIndex = lbCurSel _availableList;
if (_selIndex == -1) exitWith { systemChat "No mercenary selected."; };

private _text = _availableList lbText _selIndex;
private _data = _availableList lbData _selIndex;

// Add to assigned
private _newIdx = _assignedList lbAdd _text;
_assignedList lbSetData [_newIdx, _data];

// Remove from available
_availableList lbDelete _selIndex;

// Auto-calculate impact
[] call A3M_fnc_onShadowOpsPlanChanged;
