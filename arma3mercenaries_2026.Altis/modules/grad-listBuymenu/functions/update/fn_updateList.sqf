/*  Updates itemlist based on chosen category
*
*/

#include "..\..\dialog\defines.hpp"
params ["_categoryCtrl", "_selIndex"];
disableSerialization;

_dialog = findDisplay grad_lbm_DIALOG;
_listCtrl = _dialog displayCtrl grad_lbm_ITEMLIST;

(call compile (_categoryCtrl lbData _selIndex)) params ["_baseConfigName", "_categoryConfigName"];

_allItems = "true" configClasses (missionConfigFile >> "CfgGradBuymenu" >> _baseConfigName >> _categoryConfigName);
lbClear _listCtrl;
_listIndex = 0;
{
    _config = _x;
    _condition = [(_config >> "condition"), "text", "true"] call CBA_fnc_getConfigEntry;

    private _isLocked = !(call compile _condition);
    _itemConfigName = configName _config;
    _displayName = [(_config >> "displayName"), "text", [_itemConfigName] call grad_lbm_fnc_getDisplayName] call CBA_fnc_getConfigEntry;
    
    if (_isLocked) then {
        if (["rank", _condition, false] call BIS_fnc_inString) then {
            _displayName = format ["[RANK LOCKED] %1", _displayName];
        } else {
            if (["side", _condition, false] call BIS_fnc_inString) then {
                _displayName = format ["[FACTION LOCKED] %1", _displayName];
            } else {
                _displayName = format ["[LOCKED] %1", _displayName];
            };
        };
    };

    _price = [(_config >> "price"), "number", 999999] call CBA_fnc_getConfigEntry;
    _description = [(_config >> "description"), "text", [_itemConfigName] call grad_lbm_fnc_getDescription] call CBA_fnc_getConfigEntry;
    _code = compile ([(_config >> "code"), "text", ""] call CBA_fnc_getConfigEntry);
    _picturePath = [(_config >> "picture"), "text", ""] call CBA_fnc_getConfigEntry;

    // --- A3M ECONOMY: Dynamic Daily Sales Check ---
    private _activeSales = missionNamespace getVariable ["A3M_ActiveSales", createHashMap];
    private _discountMultiplier = _activeSales getOrDefault [_itemConfigName, 1];
    private _isOnSale = false;

    if (_discountMultiplier < 1) then {
        _price = round (_price * _discountMultiplier);
        _isOnSale = true;
    };
    // ----------------------------------------------

    private _listText = format ["[%1 Cr] %2", _price, _displayName];
    if (_isOnSale) then {
        _listText = format ["[%1 Cr] [SALE] %2", _price, _displayName];
    };

    _listIndex = _listCtrl lbAdd _listText;

    private _stock = [_baseConfigName, _categoryConfigName, _itemConfigName] call grad_lbm_fnc_getStock;

    if (_isLocked) then {
        _listCtrl lbSetColor [_listIndex, [0.8, 0.2, 0.2, 1]]; // Red text
    } else {
        if (_stock <= 0) then {
            _listCtrl lbSetColor [_listIndex, [1.0, 0.2, 0.2, 1]]; // Bright Red
        } else {
            if (_stock <= 3) then {
                _listCtrl lbSetColor [_listIndex, [1.0, 0.65, 0.0, 1]]; // Orange text
            } else {
                if (_isOnSale) then {
                    _listCtrl lbSetColor [_listIndex, [0, 1, 0, 1]]; // Neon Green
                };
            };
        };
    };

    _data = str [_baseConfigName, _categoryConfigName, _itemConfigName, _displayName, _price, _description, _code, _picturePath, _isLocked];
    _listCtrl lbSetData [_listIndex, _data];
} forEach _allItems;

if ((lbSize _listCtrl) > 0) then {_listCtrl lbSetCurSel 0};

//save last category selection
player setVariable ["grad_lbm_lastSelectedCategoryIndex", lbCurSel _categoryCtrl];
