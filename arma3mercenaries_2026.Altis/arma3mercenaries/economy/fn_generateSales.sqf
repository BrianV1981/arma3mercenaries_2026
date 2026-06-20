/*
    arma3mercenaries\economy\fn_generateSales.sqf
    Description: Called by initServer.sqf. Generates a random assortment of items across multiple stores and discounts them by 10%, 30%, or 50%.
    Stores the results in a globally synchronized hashmap for the UI to read with zero overhead.
*/

if (!isServer) exitWith {};

// Check if economy is disabled via CBA
private _isEnabled = missionNamespace getVariable ["A3M_Economy_Enable", true];
if (!_isEnabled) exitWith {};

// Read CBA Settings
private _oosChance = missionNamespace getVariable ["A3M_Economy_OOSChance", 5];
private _lsChance = missionNamespace getVariable ["A3M_Economy_LowStockChance", 10];

private _overstockCount = missionNamespace getVariable ["A3M_Economy_OverstockCount", 4];
private _clearanceCount = missionNamespace getVariable ["A3M_Economy_ClearanceCount", 10];
private _dailyCount = missionNamespace getVariable ["A3M_Economy_DailyCount", 30];

private _overstockDiscount = missionNamespace getVariable ["A3M_Economy_OverstockDiscount", 50];
private _clearanceDiscount = missionNamespace getVariable ["A3M_Economy_ClearanceDiscount", 30];
private _dailyDiscount = missionNamespace getVariable ["A3M_Economy_DailyDiscount", 10];

private _wMin = missionNamespace getVariable ["A3M_Economy_BaseStock_WeaponsMin", 4];
private _wMax = missionNamespace getVariable ["A3M_Economy_BaseStock_WeaponsMax", 15];
private _mMin = missionNamespace getVariable ["A3M_Economy_BaseStock_MagsMin", 30];
private _mMax = missionNamespace getVariable ["A3M_Economy_BaseStock_MagsMax", 120];
private _bMin = missionNamespace getVariable ["A3M_Economy_BaseStock_BackpacksMin", 10];
private _bMax = missionNamespace getVariable ["A3M_Economy_BaseStock_BackpacksMax", 30];
private _miscMin = missionNamespace getVariable ["A3M_Economy_BaseStock_MiscMin", 15];
private _miscMax = missionNamespace getVariable ["A3M_Economy_BaseStock_MiscMax", 50];

// Convert plain English percentages (50%) to mathematical multipliers (0.5)
private _overstockMult = 1 - (_overstockDiscount / 100);
private _clearanceMult = 1 - (_clearanceDiscount / 100);
private _dailyMult = 1 - (_dailyDiscount / 100);

// 1. Gather ALL possible classnames from the config stores
private _allHGItems = []; // Array of [classname, price, storeName]
private _allGradItems = []; // Array of [baseName, catName, itemName, price, storeName]

// Check Grad Stores
private _gradStoreConfigs = "true" configClasses (missionConfigFile >> "CfgGradBuymenu");
{
    private _baseConfigName = configName _x;
    private _lowerBase = toLower _baseConfigName;
    
    // Stub out specialized vehicle menus so they have infinite stock and no random sales (we use HG for vehicles)
    if (!(["vehicle", _lowerBase] call BIS_fnc_inString)) then {
        
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
    };
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

// Stubbed out: HG Gear Shops bypass dynamic stock shortages in favor of custom Armory Hooks.

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

// --- GRAD INVENTORY OVERHAUL ---
// Every single item gets a realistic randomized stock based on its category
{
    private _baseConfigName = _x select 0;
    private _catConfigName = _x select 1;
    private _itemName = _x select 2;
    private _price = _x select 3;
    private _storeDisplayName = _x select 4;
    
    private _stock = 999;
    
    // Evaluate based on engine type
    private _details = _itemName call BIS_fnc_itemType;
    private _cat = _details select 0;
    private _type = _details select 1;

    if (_cat == "Weapon") then {
        _stock = _wMin + floor(random (1 max (_wMax - _wMin + 1)));
    } else {
        if (_cat == "Magazine") then {
            _stock = _mMin + floor(random (1 max (_mMax - _mMin + 1)));
        } else {
            if (_type == "Backpack") then {
                _stock = _bMin + floor(random (1 max (_bMax - _bMin + 1)));
            } else {
                _stock = _miscMin + floor(random (1 max (_miscMax - _miscMin + 1)));
            };
        };
    };

    // Apply Shortages via CBA Settings
    if (random 100 < _oosChance) then {
        _stock = 0; // Completely SOLD OUT
        _activeShortages set [_itemName, true];
        _auditData set [_itemName, [_price, 1, _storeDisplayName, "OUT_OF_STOCK"]];
    } else {
        if (random 100 < _lsChance) then {
            _stock = 1 + floor(random 3); // 1 to 3 items
            _auditData set [_itemName, [_price, 1, _storeDisplayName, format["LOW_STOCK (%1 left)", _stock]]];
        };
    };
    // Inject directly into GRAD Hashmap to bypass setStock validation errors
    private _hashKey = format ["%1_%2_%3", _baseConfigName, _catConfigName, _itemName];
    [GRAD_LBM_ITEMSTOCKS, _hashKey, _stock] call CBA_fnc_hashSet;
} forEach _allGradItems;

// Broadcast the entire modified stock hashmap to all clients
publicVariable "GRAD_LBM_ITEMSTOCKS";

// --- HG INVENTORY OVERHAUL ---
// HG doesn't support low stock numbers natively, but we can completely sell out items
{
    private _itemName = _x select 0;
    private _price = _x select 1;
    private _storeDisplayName = _x select 2;
    
    // Check against CBA Out of Stock setting
    if (random 100 < _oosChance) then {
        _activeShortages set [_itemName, true];
        _auditData set [_itemName, [_price, 1, _storeDisplayName, "OUT_OF_STOCK"]];
    };
} forEach _allHGItems;

// --- OVERSTOCK (CBA Controlled) ---
for "_i" from 1 to _overstockCount do {
    if (count _combinedItems == 0) exitWith {};
    private _itemData = _combinedItems deleteAt 0;
    _activeSales set [_itemData select 0, _overstockMult];
    _auditData set [_itemData select 0, [_itemData select 1, _overstockMult, _itemData select 2, "SALE"]];
};

// --- CLEARANCE (CBA Controlled) ---
for "_i" from 1 to _clearanceCount do {
    if (count _combinedItems == 0) exitWith {};
    private _itemData = _combinedItems deleteAt 0;
    _activeSales set [_itemData select 0, _clearanceMult];
    _auditData set [_itemData select 0, [_itemData select 1, _clearanceMult, _itemData select 2, "SALE"]];
};

// --- DAILY (CBA Controlled) ---
for "_i" from 1 to _dailyCount do {
    if (count _combinedItems == 0) exitWith {};
    private _itemData = _combinedItems deleteAt 0;
    _activeSales set [_itemData select 0, _dailyMult];
    _auditData set [_itemData select 0, [_itemData select 1, _dailyMult, _itemData select 2, "SALE"]];
};

// 3. Broadcast to all clients instantly
missionNamespace setVariable ["A3M_ActiveSales", _activeSales, true];
missionNamespace setVariable ["A3M_ActiveShortages", _activeShortages, true];
missionNamespace setVariable ["A3M_EconomyAudit_Data", _auditData, true];

diag_log format ["[A3M ECONOMY] Generated %1 daily sales and %2 shortages for this server session.", count _activeSales, count _activeShortages];

