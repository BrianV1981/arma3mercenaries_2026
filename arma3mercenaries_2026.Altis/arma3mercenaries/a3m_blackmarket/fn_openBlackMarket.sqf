/*
    A3M Quartermaster: Native Arsenal Hook (Phase 1)
    Author: A.I.M. / BrianV1981
    
    DESCRIPTION:
    This script acts as a bridge between the Grad List Buymenu (grad-lbm) economy and the 
    Native Arma 3 Virtual Arsenal. Instead of using a hardcoded whitelist, it dynamically 
    generates the Arsenal's inventory on the fly.
    
    HOW THE WHITELIST WORKS:
    1. The script scans `missionConfigFile >> "CfgGradBuymenu"` (which contains your 
       Quartermaster configs like weaponStoreMenu.hpp, itemStoreMenu.hpp, etc.).
    2. It loops through every configured item and checks if it has a price > 0.
    3. It uses `BIS_fnc_itemType` to categorize valid items into Weapons, Magazines/Explosives, 
       Backpacks, and Items/Attachments.
    4. It creates an invisible Virtual Ammo Box (`A3M_ArmoryBox`), wipes it clean, and injects
       only the dynamically generated arrays.
    5. The Native Arsenal is then opened targeting that invisible box.
    
    Any item you add to a Grad Store config with a valid price will automatically appear 
    in the Armory interface without requiring manual whitelist updates.
    
    CALCULATION ENGINE:
    When the player clicks "CALCULATE COST", the script aggregates all gear on the player
    (including scopes attached to weapons and magazines inside vests) and runs a frequency 
    diff against their original loadout snapshot. The player is charged exactly for the net 
    difference in items based on the Grad Store prices.
*/

params [["_useBank", false]];

disableSerialization;

// -------------------------------------------------------------------------
// 1. Snapshot Original Gear
// -------------------------------------------------------------------------
private _oldLoadout = getUnitLoadout player;

// Helper to get ALL gear into a flat array
private _fnc_getAllGear = {
    private _gear = [];
    _gear append (weapons player);
    _gear append (items player);
    _gear append (magazines player);
    _gear append (assignedItems player);
    _gear append (primaryWeaponItems player);
    _gear append (secondaryWeaponItems player);
    _gear append (handgunItems player);
    _gear append [headgear player, goggles player, vest player, uniform player, backpack player];
    _gear = _gear - [""];
    _gear
};

private _oldGear = call _fnc_getAllGear;

// Store temporarily
player setVariable ["A3M_Armory_UseBank", _useBank];
player setVariable ["A3M_Armory_OldLoadout", _oldLoadout];
player setVariable ["A3M_Armory_OldGear", _oldGear];

// -------------------------------------------------------------------------
// 2. Parse CfgGradBuymenu & Build Whitelists
// -------------------------------------------------------------------------
if (isNil "A3M_Armory_GradPrices") then {
    A3M_Armory_GradPrices = createHashMap;
};
private _whitelistWeapons = [];
private _whitelistMagazines = [];
private _whitelistItems = [];
private _whitelistBackpacks = [];

private _cfgBuymenu = missionConfigFile >> "CfgGradBuymenu";
for "_i" from 0 to ((count _cfgBuymenu) - 1) do {
    private _storeClass = _cfgBuymenu select _i;
    if (isClass _storeClass) then {
        for "_j" from 0 to ((count _storeClass) - 1) do {
            private _categoryClass = _storeClass select _j;
            if (isClass _categoryClass) then {
                private _catCondStr = getText (_categoryClass >> "condition");
                if (_catCondStr == "") then { _catCondStr = "true"; };
                
                if (call compile _catCondStr) then {
                    for "_k" from 0 to ((count _categoryClass) - 1) do {
                        private _itemClass = _categoryClass select _k;
                        if (isClass _itemClass) then {
                            private _itemCondStr = getText (_itemClass >> "condition");
                            if (_itemCondStr == "") then { _itemCondStr = "true"; };
                            if (call compile _itemCondStr) then {
                                private _className = configName _itemClass;
                                private _price = getNumber (_itemClass >> "price");
                                
                                if (_price >= 0) then {
                                    A3M_Armory_GradPrices set [toLower _className, _price];
                                        
                                    // Check if it's out of stock in the dynamic economy
                                    private _activeShortages = missionNamespace getVariable ["A3M_ActiveShortages", createHashMap];
                                    if (!(_activeShortages getOrDefault [_className, false])) then {
                                        // Categorize for Arsenal Whitelisting
                                        private _details = _className call BIS_fnc_itemType;
                                        private _cat = _details select 0;
                                        private _type = _details select 1;
                                        
                                        if (_cat == "Weapon") then { _whitelistWeapons pushBackUnique _className; };
                                        if (_cat == "Magazine") then { _whitelistMagazines pushBackUnique _className; };
                                        if (_type == "Backpack") then { _whitelistBackpacks pushBackUnique _className; } else {
                                            if (_cat == "Item" || _cat == "Equipment") then { _whitelistItems pushBackUnique _className; };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
        };
    };
};

// -------------------------------------------------------------------------
// 3. Create Virtual Ammo Box & Open Arsenal
// -------------------------------------------------------------------------
if (isNull (missionNamespace getVariable ["A3M_ArmoryBox", objNull])) then {
    A3M_ArmoryBox = "Box_NATO_Wps_F" createVehicleLocal [0,0,0];
    A3M_ArmoryBox hideObject true;
    A3M_ArmoryBox allowDamage false;
};

// Reset Cargo
[A3M_ArmoryBox, ["%ALL"]] call BIS_fnc_removeVirtualWeaponCargo;
[A3M_ArmoryBox, ["%ALL"]] call BIS_fnc_removeVirtualMagazineCargo;
[A3M_ArmoryBox, ["%ALL"]] call BIS_fnc_removeVirtualItemCargo;
[A3M_ArmoryBox, ["%ALL"]] call BIS_fnc_removeVirtualBackpackCargo;

// Apply Whitelist
[A3M_ArmoryBox, _whitelistWeapons] call BIS_fnc_addVirtualWeaponCargo;
[A3M_ArmoryBox, _whitelistMagazines] call BIS_fnc_addVirtualMagazineCargo;
[A3M_ArmoryBox, _whitelistItems] call BIS_fnc_addVirtualItemCargo;
[A3M_ArmoryBox, _whitelistBackpacks] call BIS_fnc_addVirtualBackpackCargo;

// Open the Arsenal locally
["Open", [false, A3M_ArmoryBox, player]] call BIS_fnc_arsenal;

// -------------------------------------------------------------------------
// 4. Inject Custom UI (Calculate & Purchase)
// -------------------------------------------------------------------------
[] spawn {
    disableSerialization;
    waitUntil {!isNull (uiNamespace getVariable ["RscDisplayArsenal", displayNull])};
    private _display = uiNamespace getVariable ["RscDisplayArsenal", displayNull];

    // Nav Tabs Group (Dynamic Injection)
    [_display, "armory"] call A3M_fnc_drawNav;

    // Calculate Button Group (Bottom Center)
    private _calcGroup = _display ctrlCreate ["RscControlsGroupNoScrollbars", 9002];
    private _groupWidth = 0.15 * safeZoneW;
    private _groupHeight = 0.04 * safeZoneH;
    private _groupX = safeZoneX + ((safeZoneW - _groupWidth) / 2); // Centered horizontally
    private _groupY = safeZoneY + safeZoneH - (_groupHeight + (0.06 * safeZoneH)); // Moved up by approx 1 button height
    _calcGroup ctrlSetPosition [_groupX, _groupY, _groupWidth, _groupHeight];
    _calcGroup ctrlCommit 0;
    
    // The "Calculate Cost" Button
    private _btnCalc = _display ctrlCreate ["HG_RscButton", 9008, _calcGroup];
    _btnCalc ctrlSetPosition [0, 0, _groupWidth, _groupHeight];
    _btnCalc ctrlSetText "CALCULATE COST";
    _btnCalc ctrlSetBackgroundColor [0.13, 0.54, 0.21, 0.8]; // Green
    _btnCalc ctrlCommit 0;
    
    // Hidden variable to track the calculated price
    _display setVariable ["A3M_CurrentCartPrice", -1];
    
    // Button Click Logic
    _btnCalc ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _display = ctrlParent _ctrl;
        
        // Ensure they aren't already ready to purchase
        private _currentState = _display getVariable ["A3M_CurrentCartPrice", -1];
        
        // Run the math function
        private _fnc_calculateDiff = {
            private _oldGear = player getVariable ["A3M_Armory_OldGear", []];
            
            // Helper to get ALL gear into a flat array
            private _fnc_getAllGear = {
                private _gear = [];
                _gear append (weapons player);
                _gear append (items player);
                _gear append (magazines player);
                _gear append (assignedItems player);
                _gear append (primaryWeaponItems player);
                _gear append (secondaryWeaponItems player);
                _gear append (handgunItems player);
                _gear append [headgear player, goggles player, vest player, uniform player, backpack player];
                _gear = _gear - [""];
                _gear
            };
            
            private _newGear = call _fnc_getAllGear;
            
            private _oldCounts = createHashMap;
            {
                private _k = toLower _x;
                _oldCounts set [_k, (_oldCounts getOrDefault [_k, 0]) + 1];
            } forEach _oldGear;
            
            private _newCounts = createHashMap;
            {
                private _k = toLower _x;
                _newCounts set [_k, (_newCounts getOrDefault [_k, 0]) + 1];
            } forEach _newGear;
            
            private _totalCost = 0;
            private _contraband = false;
            
            private _activeSales = missionNamespace getVariable ["A3M_ActiveSales", createHashMap];
            {
                private _item = _x;
                private _newQty = _y;
                private _oldQty = _oldCounts getOrDefault [_item, 0];
                
                if (_newQty > _oldQty) then {
                    private _diff = _newQty - _oldQty;
                    private _p = A3M_Armory_GradPrices getOrDefault [_item, 0];
                    if (_p == 0) then { 
                        systemChat format ["CONTRABAND DETECTED: %1 is not sold here.", _item]; 
                        _contraband = true;
                    } else {
                        private _discountMult = _activeSales getOrDefault [_item, 1];
                        _p = round (_p * _discountMult);
                    };
                    _totalCost = _totalCost + (_p * _diff); 
                };
            } forEach _newCounts;
            
            if (_contraband) exitWith { -2 }; // Return -2 to signify contraband error
            _totalCost
        };
        
        private _actualCost = call _fnc_calculateDiff;
        
        if (_actualCost == -2) then {
            // State 0: Contraband Error
            systemChat "TRANSACTION BLOCKED: You have unauthorized items in your loadout.";
            _display setVariable ["A3M_CurrentCartPrice", -1];
            _ctrl ctrlSetText "ILLEGAL GEAR LOADED";
            _ctrl ctrlSetBackgroundColor [0, 0, 0, 1]; // Black warning
            
            [_ctrl, _display] spawn {
                params ["_c", "_d"];
                sleep 3;
                if (!isNull _c) then {
                    _c ctrlSetText "CALCULATE COST";
                    _c ctrlSetBackgroundColor [0, 0.5, 0, 1];
                };
            };
        } else {
            if (_currentState == -1) then {
                // State 1: Hit Calculate
                _display setVariable ["A3M_CurrentCartPrice", _actualCost];
                _ctrl ctrlSetText format ["PURCHASE ($%1)", _actualCost];
                _ctrl ctrlSetBackgroundColor [0.8, 0.2, 0, 1]; // Red for purchase
                
                // Failsafe: Reset back to "CALCULATE" after 5 seconds if they don't click it
                [_ctrl, _display] spawn {
                    params ["_c", "_d"];
                    sleep 5;
                    if (!isNull _c && {(_d getVariable ["A3M_CurrentCartPrice", -1]) != -1}) then {
                        _d setVariable ["A3M_CurrentCartPrice", -1];
                        _c ctrlSetText "CALCULATE COST";
                        _c ctrlSetBackgroundColor [0, 0.5, 0, 1];
                    };
                };
            } else {
                // State 2: Hit Purchase (Double Check Anti-Cheat)
                if (_actualCost != _currentState) then {
                    systemChat "TRANSACTION FAILED: Loadout was modified after calculating. Please recalculate.";
                    _display setVariable ["A3M_CurrentCartPrice", -1];
                    _ctrl ctrlSetText "CALCULATE COST";
                    _ctrl ctrlSetBackgroundColor [0, 0.5, 0, 1];
                } else {
                    // SUCCESS! Close the Arsenal, allowing the exit trapdoor to finalize the transaction.
                    player setVariable ["A3M_Armory_ReadyToPurchase", true];
                    _display closeDisplay 1;
                };
            };
        };
    }];
};

// -------------------------------------------------------------------------
// 5. The Exit Trapdoor (Failsafe & Transaction Finalization)
// -------------------------------------------------------------------------
if (!isNil "A3M_Armory_EH_ID") then {
    [missionNamespace, "arsenalClosed", A3M_Armory_EH_ID] call BIS_fnc_removeScriptedEventHandler;
};

A3M_Armory_EH_ID = [missionNamespace, "arsenalClosed", {
    if (!isNil "A3M_Armory_EH_ID") then {
        [missionNamespace, "arsenalClosed", A3M_Armory_EH_ID] call BIS_fnc_removeScriptedEventHandler;
        A3M_Armory_EH_ID = nil;
    };
    
    private _readyToPurchase = player getVariable ["A3M_Armory_ReadyToPurchase", false];
    private _oldLoadout = player getVariable ["A3M_Armory_OldLoadout", []];
    player setVariable ["A3M_Armory_ReadyToPurchase", nil]; // Clean up
    
    if (!_readyToPurchase) exitWith {
        // Player closed Arsenal via Native "Close" button. Revert their gear for free.
        player setUnitLoadout _oldLoadout;
        private _msg = "<t color='#AAAAAA' size='0.6'>Armory Exit</t><br/><t size='0.5'>Transaction cancelled. Gear reverted.</t>";
        [_msg, -1, 0.8, 3, 0.5, 0, 789] call BIS_fnc_dynamicText;
    };
    
    // Proceed with Final Payment
    private _useBank = player getVariable ["A3M_Armory_UseBank", false];
    private _oldGear = player getVariable ["A3M_Armory_OldGear", []];
    
    // Helper to get ALL gear into a flat array
    private _fnc_getAllGear = {
        private _gear = [];
        _gear append (weapons player);
        _gear append (items player);
        _gear append (magazines player);
        _gear append (assignedItems player);
        _gear append (primaryWeaponItems player);
        _gear append (secondaryWeaponItems player);
        _gear append (handgunItems player);
        _gear append [headgear player, goggles player, vest player, uniform player, backpack player];
        _gear = _gear - [""];
        _gear
    };
    
    private _newGear = call _fnc_getAllGear;
    
    private _oldCounts = createHashMap;
    {
        private _k = toLower _x;
        _oldCounts set [_k, (_oldCounts getOrDefault [_k, 0]) + 1];
    } forEach _oldGear;
    
    private _newCounts = createHashMap;
    {
        private _k = toLower _x;
        _newCounts set [_k, (_newCounts getOrDefault [_k, 0]) + 1];
    } forEach _newGear;
    
    private _totalCost = 0;
    
    private _activeSales = missionNamespace getVariable ["A3M_ActiveSales", createHashMap];
    {
        private _item = _x;
        private _newQty = _y;
        private _oldQty = _oldCounts getOrDefault [_item, 0];
        
        if (_newQty > _oldQty) then {
            private _diff = _newQty - _oldQty;
            private _p = A3M_Armory_GradPrices getOrDefault [_item, 0];
            private _discountMult = _activeSales getOrDefault [_item, 1];
            _p = round (_p * _discountMult);
            _totalCost = _totalCost + (_p * _diff); 
        };
    } forEach _newCounts;
    
    // Check funds
    private _availableFunds = [player, _useBank] call GRAD_moneymenu_fnc_getFunds;
    
    if (_availableFunds >= _totalCost) then {
        // Success: Deduct money
        [player, -_totalCost, _useBank] call GRAD_moneymenu_fnc_addFunds;
        
        private _method = ["Wallet", "Debit Card"] select _useBank;
        private _msg = format ["<t color='#00FF00' size='0.6'>Armory Purchase Complete</t><br/><t size='0.5'>$%1 was charged to your %2.</t>", _totalCost, _method];
        [_msg, -1, 0.8, 5, 0.5, 0, 789] call BIS_fnc_dynamicText;
        playSound "FD_Target_PopDown_Small_F"; 
    } else {
        // Failure: Strip naked and revert gear
        player setUnitLoadout _oldLoadout;
        private _msg = format ["<t color='#FF0000' size='0.6'>Transaction Declined</t><br/><t size='0.5'>You need $%1 but only have $%2 in your account.</t>", _totalCost, _availableFunds];
        [_msg, -1, 0.8, 5, 0.5, 0, 789] call BIS_fnc_dynamicText;
    };
    
}] call BIS_fnc_addScriptedEventHandler;
