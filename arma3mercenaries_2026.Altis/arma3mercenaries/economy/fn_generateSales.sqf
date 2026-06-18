/*
    arma3mercenaries\economy\fn_generateSales.sqf
    Description: Called by initServer.sqf. Generates a random assortment of items across multiple stores and discounts them by 10%, 30%, or 50%.
    Stores the results in a globally synchronized hashmap for the UI to read with zero overhead.
*/

if (!isServer) exitWith {};

// 1. Gather ALL possible classnames from the config stores
private _allHGItems = []; // Array of [classname, price, storeName]
private _allGradItems = []; // Array of [baseName, catName, itemName, price, storeName]

// Check Grad Stores
private _gradStoreConfigs = "true" configClasses (missionConfigFile >> "CfgGradBuymenu");
{
    private _baseConfigName = configName _x;
    private _storeDisplayName = getText (_x >> "Tracking" >> "storeName");
    if (_storeDisplayName == "") then { _storeDisplayName = _baseConfigName; };
    
    private _categories = "true" configClasses _x;
    {
        private _catConfigName = configName _x;
        private _items = "true" configClasses _x;
        {
            private _itemName = configName _x;
            private _price = getNumber (_x >> "price");
            _allGradItems pushBack [_baseConfigName, _catConfigName, _itemName, _price, _storeDisplayName];
        } forEach _items;
    } forEach _categories;
} forEach _gradStoreConfigs;

// Check HG Vehicle Stores
private _hgVehicleStores = "true" configClasses (missionConfigFile >> "CfgClient" >> "HG_VehiclesShopCfg");
{
    private _store = _x;
    private _storeName = configName _store;
    private _categories = "true" configClasses _store;
    {
        private _vehicles = getArray (_x >> "vehicles");
        {
            _allHGItems pushBackUnique [_x select 0, _x select 1, _storeName];
        } forEach _vehicles;
    } forEach _categories;
} forEach _hgVehicleStores;

// Check HG Gear Stores
private _hgGearStores = "true" configClasses (missionConfigFile >> "CfgClient" >> "HG_GearShopCfg");
{
    private _store = _x;
    private _storeName = configName _store;
    private _categories = "true" configClasses _store;
    {
        private _gearItems = getArray (_x >> "items");
        {
            _allHGItems pushBackUnique [_x select 0, _x select 1, _storeName];
        } forEach _gearItems;
    } forEach _categories;
} forEach _hgGearStores;

// Shuffle the massive lists
_allHGItems = _allHGItems call BIS_fnc_arrayShuffle;
_allGradItems = _allGradItems call BIS_fnc_arrayShuffle;
private _combinedItems = _allHGItems + (_allGradItems apply { [_x select 2, _x select 3, _x select 4] });
_combinedItems = _combinedItems call BIS_fnc_arrayShuffle;

// 2. Assign the sales & shortages!
private _activeSales = createHashMap;
private _activeShortages = createHashMap; // For HG shops

// AUDIT CACHE: classname -> [originalPrice, discountMult, storeName, type("SALE"|"OUT_OF_STOCK"|"LOW_STOCK")]
private _auditData = createHashMap; 

// --- SOLD OUT (20 Items) ---
for "_i" from 1 to 20 do {
    // 50/50 chance to pick from GRAD or HG
    if (count _allGradItems > 0 && {random 1 > 0.5 || count _allHGItems == 0}) then {
        private _gItem = _allGradItems deleteAt 0;
        [_gItem select 0, _gItem select 1, _gItem select 2, 0] call grad_lbm_fnc_setStock;
        _auditData set [_gItem select 2, [_gItem select 3, 1, _gItem select 4, "OUT_OF_STOCK"]];
    } else {
        if (count _allHGItems > 0) then {
            private _hItem = _allHGItems deleteAt 0;
            _activeShortages set [_hItem select 0, true];
            _auditData set [_hItem select 0, [_hItem select 1, 1, _hItem select 2, "OUT_OF_STOCK"]];
        };
    };
};

// --- LOW STOCK (10 Items) ---
// We only apply this to GRAD stores because they actually support numerical stock natively
for "_i" from 1 to 10 do {
    if (count _allGradItems > 0) then {
        private _gItem = _allGradItems deleteAt 0;
        private _stockNum = (floor random 3) + 1;
        [_gItem select 0, _gItem select 1, _gItem select 2, _stockNum] call grad_lbm_fnc_setStock;
        // Also log to audit so we can see it!
        _auditData set [_gItem select 2, [_gItem select 3, 1, _gItem select 4, format["LOW_STOCK (%1 left)", _stockNum]]];
    };
};

// --- OVERSTOCK / 50% OFF (Extremely Rare: 2 Items) ---
for "_i" from 1 to 2 do {
    if (count _combinedItems > 0) then {
        private _itemData = _combinedItems deleteAt 0;
        _activeSales set [_itemData select 0, 0.5];
        _auditData set [_itemData select 0, [_itemData select 1, 0.5, _itemData select 2, "SALE"]];
    };
};

// --- 30% OFF (Medium: 5 Items) ---
for "_i" from 1 to 5 do {
    if (count _combinedItems > 0) then {
        private _itemData = _combinedItems deleteAt 0;
        _activeSales set [_itemData select 0, 0.7];
        _auditData set [_itemData select 0, [_itemData select 1, 0.7, _itemData select 2, "SALE"]];
    };
};

// --- 10% OFF (Prevalent: 15 Items) ---
for "_i" from 1 to 15 do {
    if (count _combinedItems > 0) then {
        private _itemData = _combinedItems deleteAt 0;
        _activeSales set [_itemData select 0, 0.9];
        _auditData set [_itemData select 0, [_itemData select 1, 0.9, _itemData select 2, "SALE"]];
    };
};

// 3. Broadcast to all clients instantly
missionNamespace setVariable ["A3M_ActiveSales", _activeSales, true];
missionNamespace setVariable ["A3M_ActiveShortages", _activeShortages, true];
missionNamespace setVariable ["A3M_EconomyAudit_Data", _auditData, true];

diag_log format ["[A3M ECONOMY] Generated %1 daily sales and %2 shortages for this server session.", count _activeSales, count _activeShortages];

