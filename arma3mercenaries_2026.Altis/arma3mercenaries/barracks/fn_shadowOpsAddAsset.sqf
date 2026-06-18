/*
    fn_shadowOpsAddAsset.sqf
    Moves a selected asset from the Catalog to the Purchased list.
*/
disableSerialization;
private _display = findDisplay 7050;
if (isNull _display) exitWith {};

private _catalogList = _display displayCtrl 7059;
private _purchasedList = _display displayCtrl 7062;

private _selIndex = lbCurSel _catalogList;
if (_selIndex == -1) exitWith { systemChat "No asset selected."; };

private _text = _catalogList lbText _selIndex;
private _data = _catalogList lbData _selIndex;
private _color = _catalogList lbColor _selIndex;

if (_data == "") exitWith {};

// Enforce rule: Only one INFIL and one EXFIL allowed
private _allAssets = _display getVariable ["A3M_ShadowOps_Catalog", []];
private _assetData = _allAssets select (parseNumber _data);
private _assetCategory = _assetData select 0;

if (_assetCategory == "INFIL" || _assetCategory == "EXFIL") then {
    private _purchasedCount = lbSize _purchasedList;
    private _foundConflict = false;
    for "_i" from 0 to (_purchasedCount - 1) do {
        private _pData = _purchasedList lbData _i;
        private _pAssetData = _allAssets select (parseNumber _pData);
        if ((_pAssetData select 0) == _assetCategory) then {
            _foundConflict = true;
        };
    };
    if (_foundConflict) exitWith {
        systemChat format ["Error: You can only select ONE %1 asset. Remove the existing one first.", _assetCategory];
    };
};

// Add to purchased
private _newIdx = _purchasedList lbAdd _text;
_purchasedList lbSetData [_newIdx, _data];
_purchasedList lbSetColor [_newIdx, _color];

// Remove from catalog
_catalogList lbDelete _selIndex;

// Auto-calculate impact
[] call A3M_fnc_onShadowOpsPlanChanged;
