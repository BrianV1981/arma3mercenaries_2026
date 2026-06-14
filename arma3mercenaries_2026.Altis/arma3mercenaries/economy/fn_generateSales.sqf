/*
    arma3mercenaries\economy\fn_generateSales.sqf
    Description: Called by initServer.sqf. Generates a random assortment of items across multiple stores and discounts them by 10%, 30%, or 50%.
    Stores the results in a globally synchronized hashmap for the UI to read with zero overhead.
*/

if (!isServer) exitWith {};

// 1. Gather ALL possible classnames from the config stores
private _allClassnames = [];

// Check Grad Stores
private _gradStoreConfigs = "true" configClasses (missionConfigFile >> "CfgGradBuymenu");
{
    private _baseConfig = _x;
    private _categories = "true" configClasses _baseConfig;
    {
        private _items = "true" configClasses _x;
        {
            _allClassnames pushBackUnique (configName _x);
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
            _allClassnames pushBackUnique (_x select 0);
        } forEach _vehicles;
    } forEach _categories;
} forEach _hgVehicleStores;

// Shuffle the massive list of classnames
_allClassnames = _allClassnames call BIS_fnc_arrayShuffle;

// 2. Assign the sales!
private _activeSales = createHashMap;

// --- 50% OFF (Extremely Rare: 1 Item) ---
if (count _allClassnames > 0) then {
    private _item = _allClassnames deleteAt 0;
    _activeSales set [_item, 0.5]; // 50% of the price
};

// --- 30% OFF (Medium: 3 Items) ---
for "_i" from 1 to 3 do {
    if (count _allClassnames > 0) then {
        private _item = _allClassnames deleteAt 0;
        _activeSales set [_item, 0.7]; // 70% of the price
    };
};

// --- 10% OFF (Prevalent: 10 Items) ---
for "_i" from 1 to 10 do {
    if (count _allClassnames > 0) then {
        private _item = _allClassnames deleteAt 0;
        _activeSales set [_item, 0.9]; // 90% of the price
    };
};

// 3. Broadcast to all clients instantly
missionNamespace setVariable ["A3M_ActiveSales", _activeSales, true];

diag_log format ["[A3M ECONOMY] Generated %1 daily sales for this server session.", count _activeSales];
