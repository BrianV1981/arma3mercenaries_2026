/*
    fn_shadowOpsRemoveMerc.sqf
    Moves a selected mercenary from the Assigned list back to the Available list.
*/
disableSerialization;
private _display = findDisplay 7050;
if (isNull _display) exitWith {};

private _availableList = _display displayCtrl 7053;
private _selectedList = _display displayCtrl 7067;

private _selIndex = lbCurSel _selectedList;
if (_selIndex == -1) exitWith { systemChat "No mercenary selected to remove."; };

private _text = _selectedList lbText _selIndex;
private _data = _selectedList lbData _selIndex;

if (_data == "") exitWith {};

// Add back to available list
private _newIdx = _availableList lbAdd _text;
_availableList lbSetData [_newIdx, _data];

// Remove from selected list
_selectedList lbDelete _selIndex;

// Update Impact numbers automatically
[] call A3M_fnc_onShadowOpsPlanChanged;
