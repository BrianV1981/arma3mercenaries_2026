/*
    arma3mercenaries\economy\fn_generateSales.sqf
    Description: Called by initServer.sqf. Generates a random assortment of items across multiple stores and discounts them by 10%, 30%, or 50%.
    Stores the results in a globally synchronized hashmap for the UI to read with zero overhead.
*/

if (!isServer) exitWith {};

// 1. Gather ALL possible classnames from the config stores
private _allHGItems = [];
private _allGradItems = []; // Array of [baseName, catName, itemName]

// Check Grad Stores
private _gradStoreConfigs = "true" configClasses (missionConfigFile >> "CfgGradBuymenu");
{
    private _baseConfigName = configName _x;
    private _categories = "true" configClasses _x;
    {
        private _catConfigName = configName _x;
        private _items = "true" configClasses _x;
        {
            private _itemName = configName _x;
            _allGradItems pushBack [_baseConfigName, _catConfigName, _itemName];
        } forEach _items;
    } forEach _categories;
} forEach _gradStoreConfigs;

// Check HG Vehicle Stores
private _hgVehicleStores = "true" configClasses (missionConfigFile >> "CfgClient" >> "HG_VehiclesShopCfg");
{
    private _store = _x;
    private _categories = "true" configClasses _store;
    {
        private _vehicles = getArray (_x >> "vehicles");
        {
            _allHGItems pushBackUnique (_x select 0);
        } forEach _vehicles;
    } forEach _categories;
} forEach _hgVehicleStores;

// Check HG Gear Stores
private _hgGearStores = "true" configClasses (missionConfigFile >> "CfgClient" >> "HG_GearShopCfg");
{
    private _store = _x;
    private _categories = "true" configClasses _store;
    {
        private _gearItems = getArray (_x >> "items");
        {
            _allHGItems pushBackUnique (_x select 0);
        } forEach _gearItems;
    } forEach _categories;
} forEach _hgGearStores;

// Shuffle the massive lists
_allHGItems = _allHGItems call BIS_fnc_arrayShuffle;
_allGradItems = _allGradItems call BIS_fnc_arrayShuffle;
private _combinedItems = _allHGItems + (_allGradItems apply { _x select 2 });
_combinedItems = _combinedItems call BIS_fnc_arrayShuffle;

// 2. Assign the sales & shortages!
private _activeSales = createHashMap;
private _activeShortages = createHashMap; // For HG shops

// --- SOLD OUT (20 Items) ---
for "_i" from 1 to 20 do {
    // 50/50 chance to pick from GRAD or HG
    if (count _allGradItems > 0 && {random 1 > 0.5 || count _allHGItems == 0}) then {
        private _gItem = _allGradItems deleteAt 0;
        // Physically set GRAD stock to 0!
        [_gItem select 0, _gItem select 1, _gItem select 2, 0] call grad_lbm_fnc_setStock;
    } else {
        if (count _allHGItems > 0) then {
            private _hItem = _allHGItems deleteAt 0;
            _activeShortages set [_hItem, true]; // HG will read this to block purchases
        };
    };
};

// --- LOW STOCK (10 Items) ---
// We only apply this to GRAD stores because they actually support numerical stock natively
for "_i" from 1 to 10 do {
    if (count _allGradItems > 0) then {
        private _gItem = _allGradItems deleteAt 0;
        // Randomly set stock between 1 and 3
        [_gItem select 0, _gItem select 1, _gItem select 2, (floor random 3) + 1] call grad_lbm_fnc_setStock;
    };
};

// --- OVERSTOCK / 50% OFF (Extremely Rare: 2 Items) ---
for "_i" from 1 to 2 do {
    if (count _combinedItems > 0) then {
        private _item = _combinedItems deleteAt 0;
        _activeSales set [_item, 0.5]; // 50% of the price
    };
};

// --- 30% OFF (Medium: 5 Items) ---
for "_i" from 1 to 5 do {
    if (count _combinedItems > 0) then {
        private _item = _combinedItems deleteAt 0;
        _activeSales set [_item, 0.7]; // 70% of the price
    };
};

// --- 10% OFF (Prevalent: 15 Items) ---
for "_i" from 1 to 15 do {
    if (count _combinedItems > 0) then {
        private _item = _combinedItems deleteAt 0;
        _activeSales set [_item, 0.9]; // 90% of the price
    };
};

// 3. Broadcast to all clients instantly
missionNamespace setVariable ["A3M_ActiveSales", _activeSales, true];
missionNamespace setVariable ["A3M_ActiveShortages", _activeShortages, true];

diag_log format ["[A3M ECONOMY] Generated %1 daily sales and %2 shortages for this server session.", count _activeSales, count _activeShortages];
