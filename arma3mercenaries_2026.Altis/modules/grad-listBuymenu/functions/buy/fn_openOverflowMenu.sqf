/*  A3M Overflow Interceptor UI
*   Spawns dialog to let player pick where an item goes.
*/
disableSerialization;
params ["_purchaseData"];

uiNamespace setVariable ["A3M_LBM_PendingPurchase", _purchaseData];

createDialog "A3M_OverflowDialog";
private _dialog = findDisplay 9010;
private _listCtrl = _dialog displayCtrl 9011;

lnbClear _listCtrl;

private _itemConfigName = _purchaseData select 2;
private _kindOf = _purchaseData select 4;

private _titleCtrl = _dialog displayCtrl 9015;
private _weightCtrl = _dialog displayCtrl 9016;

if (_kindOf == "FORTIFICATION") then {
    _titleCtrl ctrlSetText "SELECT DESTINATION (FORTIFICATIONS)";
    private _size = 0;
    if (!isNil "grad_fortifications_fnc_getObjectSize") then {
        _size = [_itemConfigName] call grad_fortifications_fnc_getObjectSize;
    };
    _weightCtrl ctrlSetText format ["SIZE: %1", _size];
} else {
    _titleCtrl ctrlSetText "SELECT DESTINATION (REGULAR INVENTORY)";
    private _mass = getNumber (configFile >> "CfgWeapons" >> _itemConfigName >> "ItemInfo" >> "mass");
    if (_mass == 0) then { _mass = getNumber (configFile >> "CfgMagazines" >> _itemConfigName >> "mass"); };
    if (_mass == 0) then { _mass = getNumber (configFile >> "CfgVehicles" >> _itemConfigName >> "mass"); };
    _weightCtrl ctrlSetText format ["WEIGHT: %1", _mass];
};
private _nearbyRaw = nearestObjects [player, ["Car", "Tank", "Air", "Ship", "ReammoBox_F"], 25];
private _nearby = [player];
private _index = 0;
private _kindOf = _purchaseData select 4;

private _pSpaceStr = "";
if (_kindOf != "FORTIFICATION") then {
    _pSpaceStr = format ["[%1%2 Full]", round ((load player) * 100), "%"];
};
_listCtrl lnbAddRow [format ["My Inventory %1", _pSpaceStr]];

{
    if (alive _x && _x != player) then {
        private _name = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
        private _dist = round (player distance _x);
        
        private _spaceStr = "";
        if (_kindOf == "FORTIFICATION") then {
            if (!isNil "grad_fortifications_fnc_getVehicleInventorySize") then {
                private _maxSize = _x getVariable ["grad_fortifications_inventorySize", [_x] call grad_fortifications_fnc_getVehicleInventorySize];
                _spaceStr = format ["(Fort Max: %1)", _maxSize];
            };
        } else {
            private _loadPct = round ((load _x) * 100);
            _spaceStr = format ["[%1%2 Full]", _loadPct, "%"];
        };
        
        _listCtrl lnbAddRow [format ["%1 - %2m %3", _name, _dist, _spaceStr]];
        _nearby pushBack _x;
        _index = _index + 1;
    };
} forEach _nearbyRaw;

uiNamespace setVariable ["A3M_LBM_NearbyContainers", _nearby];

_listCtrl lnbSetCurSelRow 0;
