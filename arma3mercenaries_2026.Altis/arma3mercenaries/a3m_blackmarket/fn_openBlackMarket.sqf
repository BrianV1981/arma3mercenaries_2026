/*
    A3M Quartermaster: Native Arsenal Hook (Phase 1)
    Author: A.I.M. / BrianV1981
    Description: Parses GRAD Stores, whitelists the Native Arsenal, and injects a Calculate/Purchase UI.
*/

params [["_useBank", false]];

disableSerialization;

// -------------------------------------------------------------------------
// 1. Snapshot Original Gear
// -------------------------------------------------------------------------
private _oldLoadout = getUnitLoadout player;
private _oldWeapons = weapons player;
private _oldItems = items player + assignedItems player + [headgear player, goggles player, vest player, uniform player, backpack player];

// Store temporarily
player setVariable ["A3M_Armory_UseBank", _useBank];
player setVariable ["A3M_Armory_OldLoadout", _oldLoadout];
player setVariable ["A3M_Armory_OldWeapons", _oldWeapons];
player setVariable ["A3M_Armory_OldItems", _oldItems];

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
                for "_k" from 0 to ((count _categoryClass) - 1) do {
                    private _itemClass = _categoryClass select _k;
                    if (isClass _itemClass) then {
                        private _className = configName _itemClass;
                        private _price = getNumber (_itemClass >> "price");
                        
                        if (_price > 0) then {
                            A3M_Armory_GradPrices set [_className, _price];
                            
                            // Categorize for Arsenal Whitelisting
                            private _details = _className call BIS_fnc_itemType;
                            private _cat = _details select 0;
                            private _type = _details select 1;
                            
                            if (_cat == "Weapon") then { _whitelistWeapons pushBack _className; };
                            if (_cat == "Magazine") then { _whitelistMagazines pushBack _className; };
                            if (_type == "Backpack") then { _whitelistBackpacks pushBack _className; } else {
                                if (_cat == "Item" || _cat == "Equipment") then { _whitelistItems pushBack _className; };
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

    // Nav Tabs Group (Top - Absolute Coordinates)
    private _btnArmory = _display ctrlCreate ["RscButtonMenu", 9003];
    _btnArmory ctrlSetPosition [0.10 * safeZoneW + safeZoneX, 0.02 * safeZoneH + safeZoneY, 0.15 * safeZoneW, 0.04 * safeZoneH];
    _btnArmory ctrlSetText "ARMORY";
    _btnArmory ctrlSetBackgroundColor [0.13, 0.54, 0.21, 0.8];
    _btnArmory ctrlAddEventHandler ["ButtonClick", {
        (ctrlParent (_this select 0)) closeDisplay 2;
        [] spawn { 
            waitUntil {isNull (uiNamespace getVariable ["RscDisplayArsenal", displayNull])};
            uiSleep 0.5; 
            [false] spawn A3M_fnc_openBlackMarket; 
        };
    }];
    _btnArmory ctrlCommit 0;

    private _btnVehicles = _display ctrlCreate ["RscButtonMenu", 9004];
    _btnVehicles ctrlSetPosition [0.26 * safeZoneW + safeZoneX, 0.02 * safeZoneH + safeZoneY, 0.15 * safeZoneW, 0.04 * safeZoneH];
    _btnVehicles ctrlSetText "MOTORPOOL";
    _btnVehicles ctrlSetBackgroundColor [0.13, 0.54, 0.21, 0.8];
    _btnVehicles ctrlAddEventHandler ["ButtonClick", {
        (ctrlParent (_this select 0)) closeDisplay 2;
        [] spawn { 
            waitUntil {isNull (uiNamespace getVariable ["RscDisplayArsenal", displayNull])};
            uiSleep 0.5; 
            ['HG_DefaultShop', missionNamespace getVariable ['A3M_HG_CurrentLaptop', player]] call HG_fnc_dialogOnLoadVehicles; 
        };
    }];
    _btnVehicles ctrlCommit 0;

    private _btnForts = _display ctrlCreate ["RscButtonMenu", 9005];
    _btnForts ctrlSetPosition [0.42 * safeZoneW + safeZoneX, 0.02 * safeZoneH + safeZoneY, 0.15 * safeZoneW, 0.04 * safeZoneH];
    _btnForts ctrlSetText "BASE BUILDING";
    _btnForts ctrlSetBackgroundColor [0.13, 0.54, 0.21, 0.8];
    _btnForts ctrlAddEventHandler ["ButtonClick", {
        (ctrlParent (_this select 0)) closeDisplay 2;
        [] spawn { 
            waitUntil {isNull (uiNamespace getVariable ["RscDisplayArsenal", displayNull])};
            uiSleep 0.5; 
            [missionNamespace getVariable ['A3M_HG_CurrentLaptop', player], objNull, objNull, 'fortificationStore_1', '', player] call grad_lbm_fnc_loadBuymenu; 
        };
    }];
    _btnForts ctrlCommit 0;

    private _btnSupport = _display ctrlCreate ["RscButtonMenu", 9006];
    _btnSupport ctrlSetPosition [0.58 * safeZoneW + safeZoneX, 0.02 * safeZoneH + safeZoneY, 0.15 * safeZoneW, 0.04 * safeZoneH];
    _btnSupport ctrlSetText "SUPPORT";
    _btnSupport ctrlSetBackgroundColor [0.13, 0.54, 0.21, 0.8];
    _btnSupport ctrlAddEventHandler ["ButtonClick", {
        (ctrlParent (_this select 0)) closeDisplay 2;
        [] spawn { 
            waitUntil {isNull (uiNamespace getVariable ["RscDisplayArsenal", displayNull])};
            uiSleep 0.5; 
            [missionNamespace getVariable ['A3M_HG_CurrentLaptop', player], objNull, objNull, 'aliveStore_1', '', player] call grad_lbm_fnc_loadBuymenu; 
        };
    }];
    _btnSupport ctrlCommit 0;

    private _btnMercs = _display ctrlCreate ["RscButtonMenu", 9007];
    _btnMercs ctrlSetPosition [0.74 * safeZoneW + safeZoneX, 0.02 * safeZoneH + safeZoneY, 0.15 * safeZoneW, 0.04 * safeZoneH];
    _btnMercs ctrlSetText "CONTRACTORS";
    _btnMercs ctrlSetBackgroundColor [0.13, 0.54, 0.21, 0.8];
    _btnMercs ctrlAddEventHandler ["ButtonClick", {
        (ctrlParent (_this select 0)) closeDisplay 2;
        [] spawn { 
            waitUntil {isNull (uiNamespace getVariable ["RscDisplayArsenal", displayNull])};
            uiSleep 0.5; 
            [missionNamespace getVariable ['A3M_HG_CurrentLaptop', player], objNull, objNull, 'mercenaryStore_1', '', player] call grad_lbm_fnc_loadBuymenu; 
        };
    }];
    _btnMercs ctrlCommit 0;

    // Calculate Button Group (Bottom Left)
    private _calcGroup = _display ctrlCreate ["RscControlsGroupNoScrollbars", 9002];
    _calcGroup ctrlSetPosition [0.01 * safeZoneW + safeZoneX, 0.85 * safeZoneH + safeZoneY, 0.2 * safeZoneW, 0.1];
    _calcGroup ctrlCommit 0;
    
    // The "Calculate Cost" Button
    private _btnCalc = _display ctrlCreate ["RscButtonMenu", 9008, _calcGroup];
    _btnCalc ctrlSetPosition [0, 0, 0.15 * safeZoneW, 0.05 * safeZoneH];
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
            private _oldWeapons = player getVariable ["A3M_Armory_OldWeapons", []];
            private _oldItems = player getVariable ["A3M_Armory_OldItems", []];
            
            private _newWeapons = weapons player;
            private _newItems = items player + assignedItems player + [headgear player, goggles player, vest player, uniform player, backpack player];
            
            private _totalCost = 0;
            private _contraband = false;
            
            {
                if (!(_x in _oldWeapons) && _x != "") then { 
                    private _p = A3M_Armory_GradPrices getOrDefault [_x, 0];
                    if (_p == 0) then { 
                        systemChat format ["CONTRABAND DETECTED: %1 is not sold here.", _x]; 
                        _contraband = true;
                    };
                    _totalCost = _totalCost + _p; 
                };
            } forEach _newWeapons;
            
            {
                if (!(_x in _oldItems) && _x != "") then { 
                    private _p = A3M_Armory_GradPrices getOrDefault [_x, 0];
                    if (_p == 0) then { 
                        systemChat format ["CONTRABAND DETECTED: %1 is not sold here.", _x]; 
                        _contraband = true;
                    };
                    _totalCost = _totalCost + _p; 
                };
            } forEach _newItems;
            
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
[missionNamespace, "arsenalClosed", {
    [missionNamespace, "arsenalClosed", _thisScript] call BIS_fnc_removeScriptedEventHandler;
    
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
    private _oldWeapons = player getVariable ["A3M_Armory_OldWeapons", []];
    private _oldItems = player getVariable ["A3M_Armory_OldItems", []];
    
    private _newWeapons = weapons player;
    private _newItems = items player + assignedItems player + [headgear player, goggles player, vest player, uniform player, backpack player];
    private _totalCost = 0;
    
    {
        if (!(_x in _oldWeapons)) then { _totalCost = _totalCost + (A3M_Armory_GradPrices getOrDefault [_x, 0]); };
    } forEach _newWeapons;
    
    {
        if (!(_x in _oldItems)) then { _totalCost = _totalCost + (A3M_Armory_GradPrices getOrDefault [_x, 0]); };
    } forEach _newItems;
    
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
