/*
    fn_shadowOpsAddMerc.sqf
    Moves a selected mercenary from the Available list to the Assigned list.
*/
disableSerialization;
private _display = findDisplay 7050;
if (isNull _display) exitWith {};

private _availableList = _display displayCtrl 7053;
private _selectedList = _display displayCtrl 7067;

private _selIndex = lbCurSel _availableList;
if (_selIndex == -1) exitWith { systemChat "No mercenary selected."; };

private _text = _availableList lbText _selIndex;
private _data = _availableList lbData _selIndex;

// Make sure they aren't somehow a placeholder text
if (_data == "") exitWith {};

// Add to new list
private _newIdx = _selectedList lbAdd _text;
_selectedList lbSetData [_newIdx, _data];

// Remove from old list
_availableList lbDelete _selIndex;

// Update Impact numbers automatically
[] call A3M_fnc_onShadowOpsPlanChanged;
