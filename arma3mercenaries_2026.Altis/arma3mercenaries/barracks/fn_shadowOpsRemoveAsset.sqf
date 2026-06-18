/*
    fn_shadowOpsRemoveAsset.sqf
    Moves a selected asset from the Purchased list back to the Catalog.
*/
disableSerialization;
private _display = findDisplay 7050;
if (isNull _display) exitWith {};

private _catalogList = _display displayCtrl 7059;
private _purchasedList = _display displayCtrl 7062;

private _selIndex = lbCurSel _purchasedList;
if (_selIndex == -1) exitWith { systemChat "No asset selected to remove."; };

private _text = _purchasedList lbText _selIndex;
private _data = _purchasedList lbData _selIndex;
private _color = _purchasedList lbColor _selIndex;

if (_data == "") exitWith {};

// Add back to catalog
private _newIdx = _catalogList lbAdd _text;
_catalogList lbSetData [_newIdx, _data];
_catalogList lbSetColor [_newIdx, _color];

// Remove from purchased list
_purchasedList lbDelete _selIndex;

// Auto-calculate impact
[] call A3M_fnc_onShadowOpsPlanChanged;
