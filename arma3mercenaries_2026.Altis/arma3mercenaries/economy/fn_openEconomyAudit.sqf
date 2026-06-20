/*
    A3M Economy Audit Routing Script
    Description: Opens the Audit Ledger and populates it with color-coded economy fluctuations.
*/

createDialog "A3M_EconomyAudit";
waitUntil {!isNull (findDisplay 9006)};
private _display = findDisplay 9006;
private _listCtrl = _display displayCtrl 1701;

private _auditData = missionNamespace getVariable ["A3M_EconomyAudit_Data", createHashMap];

if (count _auditData == 0) exitWith {
    _listCtrl lbAdd "No market anomalies reported today.";
};

{
    private _itemName = _x;
    private _data = _y; // [originalPrice, discountMult, storeName, type]
    
    private _displayName = getText (configFile >> "CfgWeapons" >> _itemName >> "displayName");
    if (_displayName == "") then { _displayName = getText (configFile >> "CfgVehicles" >> _itemName >> "displayName"); };
    if (_displayName == "") then { _displayName = getText (configFile >> "CfgMagazines" >> _itemName >> "displayName"); };
    if (_displayName == "") then { _displayName = getText (configFile >> "CfgGlasses" >> _itemName >> "displayName"); };
    if (_displayName == "") then { _displayName = _itemName; };
    
    private _storeName = _data select 2;
    private _type = _data select 3;
    
    private _index = -1;
    if (_type == "OUT_OF_STOCK") then {
        _index = _listCtrl lbAdd format ["SOLD OUT: %1 (%2)", _displayName, _storeName];
        _listCtrl lbSetColor [_index, [0.8, 0.2, 0.2, 1]]; // Red
    } else {
        if ("LOW_STOCK" in _type) then {
            _index = _listCtrl lbAdd format ["%1: %2 (%3)", _type, _displayName, _storeName];
            _listCtrl lbSetColor [_index, [0.9, 0.5, 0.1, 1]]; // Orange
        } else {
            if (_type == "SALE") then {
                private _discount = (1 - (_data select 1)) * 100;
                _index = _listCtrl lbAdd format ["SALE (%1%2 OFF): %3 (%4)", _discount, "%", _displayName, _storeName];
                _listCtrl lbSetColor [_index, [0.2, 0.8, 0.2, 1]]; // Green
            };
        };
    };
    
} forEach _auditData;
