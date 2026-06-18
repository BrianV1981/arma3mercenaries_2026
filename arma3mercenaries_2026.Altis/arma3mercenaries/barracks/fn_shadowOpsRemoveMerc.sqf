/*
    fn_shadowOpsRemoveMerc.sqf
    Moves a selected mercenary from the Assigned Roster back to the Available Roster.
*/
disableSerialization;
private _display = findDisplay 7050;
if (isNull _display) exitWith {};

private _availableList = _display displayCtrl 7066;
private _assignedList = _display displayCtrl 7067;

private _selIndex = lbCurSel _assignedList;
if (_selIndex == -1) exitWith { systemChat "No mercenary selected."; };

private _text = _assignedList lbText _selIndex;
private _data = _assignedList lbData _selIndex;

// Add to available
private _newIdx = _availableList lbAdd _text;
_availableList lbSetData [_newIdx, _data];

// Remove from assigned
_assignedList lbDelete _selIndex;

// Auto-calculate impact
[] call A3M_fnc_onShadowOpsPlanChanged;
