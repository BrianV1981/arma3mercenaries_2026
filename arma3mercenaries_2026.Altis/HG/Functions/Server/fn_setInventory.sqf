/*
    Author - HoverGuy
    Enhanced By: A.I.M. (2026)
    
    A.I.M. PATCH NOTES & PAPER TRAIL:
    - [SQLite Bridge] Hijacked profileNamespace and routed vehicle trunk loading to A3M_fnc_dbGet.
*/
params["_vehicle",["_inventory",[],[[]]]];

private _owner = _vehicle getVariable "HG_Owner";
private _uid = _owner select 0;
private _plate = _owner select 1;

if(!HG_SAVING_EXTDB) then
{
    // [SQLITE GET] Load the trunk contents from the SQLite database
    _inventory = [format["HG_Inventory_%1_%2",_uid ,_plate], []] call A3M_fnc_dbGetSecure;
} else {
    // Legacy extDB3
};

if((count _inventory) != 0) then
{
    clearItemCargoGlobal _vehicle;
    clearMagazineCargoGlobal _vehicle;
    clearWeaponCargoGlobal _vehicle;
    clearBackpackCargoGlobal _vehicle;

    private _items = (_inventory select 0) select 0;
    private _mags = (_inventory select 0) select 1;
    private _weapons = (_inventory select 0) select 2;
    private _backpacks = (_inventory select 0) select 3;

    for "_i" from 0 to ((count (_items select 0)) - 1) do
    {
        _vehicle addItemCargoGlobal [((_items select 0) select _i),((_items select 1) select _i)];
    };
    for "_i" from 0 to ((count (_mags select 0)) - 1) do
    {
        _vehicle addMagazineCargoGlobal [((_mags select 0) select _i),((_mags select 1) select _i)];
    };
    for "_i" from 0 to ((count (_weapons select 0)) - 1) do
    {
        _vehicle addWeaponCargoGlobal [((_weapons select 0) select _i),((_weapons select 1) select _i)];
    };
    for "_i" from 0 to ((count (_backpacks select 0)) - 1) do
    {
        _vehicle addBackpackCargoGlobal [((_backpacks select 0) select _i),((_backpacks select 1) select _i)];
    };

    // A3M Custom Persistence: Re-apply GRAD Fortifications & ACE Cargo
    if (count (_inventory select 0) > 4) then {
        private _aceCargo = (_inventory select 0) select 4;
        private _gradForts = (_inventory select 0) select 5;

        // --- ACE Cargo Load ---
        if !(_aceCargo isEqualTo []) then {
            {
                private _itemData = _x;
                
                // If it's a string, it's a standard virtual item. If it's an array, it's a complex serialized object.
                if (_itemData isEqualType "") then {
                    private _isVehicle = isClass (configFile >> "CfgVehicles" >> _itemData);
                    if (_isVehicle) then {
                        // (Legacy fallback) Simple classname for a physical static. Stagger spawn positions.
                        private _offset = 5 + (_forEachIndex * 2);
                        private _pos = getPos _vehicle;
                        private _spawnPos = [(_pos select 0) + _offset, (_pos select 1) + _offset, (_pos select 2)];
                        
                        private _obj = _itemData createVehicle _spawnPos;
                        _obj setPos _spawnPos;
                        
                        [{
                            params ["_obj", "_vehicle"];
                            private _lockState = locked _vehicle;
                            if (_lockState >= 2) then { _vehicle lock 0; };
                            [_obj, _vehicle, true] call ace_cargo_fnc_loadItem;
                            if (_lockState >= 2) then { _vehicle lock _lockState; };
                        }, [_obj, _vehicle], 2] call CBA_fnc_waitAndExecute;
                    } else {
                        // Standard string item
                        [_itemData, _vehicle, true] call ace_cargo_fnc_addCargoItem;
                    };
                } else {
                    // Complex Serialized Object (Cargo Net Box, Turret, etc)
                    _itemData params ["_className", "_nativeInv", "_fortsHash"];
                    
                    private _offset = 5 + (_forEachIndex * 2);
                    private _pos = getPos _vehicle;
                    private _spawnPos = [(_pos select 0) + _offset, (_pos select 1) + _offset, (_pos select 2)];
                    
                    private _obj = _className createVehicle _spawnPos;
                    _obj setPos _spawnPos;
                    
                    // Restore native Arma 3 inventory using grad-persistence's 100% proven logic
                    if !(_nativeInv isEqualTo []) then {
                        [_obj, _nativeInv] call grad_persistence_fnc_loadVehicleInventory;
                    };
                    
                    // Restore grad-fortifications
                    if !(_fortsHash isEqualTo []) then {
                        _obj setVariable ["grad_fortifications_myFortsHash", _fortsHash, true];
                        // Force capacity recalculation just in case
                        private _myFortsHash = _obj getVariable ["grad_fortifications_myFortsHash", [[],0] call CBA_fnc_hashCreate];
                    };
                    
                    // Force the vacuum load
                    [{
                        params ["_obj", "_vehicle"];
                        private _lockState = locked _vehicle;
                        if (_lockState >= 2) then { _vehicle lock 0; };
                        [_obj, _vehicle, true] call ace_cargo_fnc_loadItem;
                        if (_lockState >= 2) then { _vehicle lock _lockState; };
                    }, [_obj, _vehicle], 2] call CBA_fnc_waitAndExecute;
                };
            } forEach _aceCargo;
        };

        // --- GRAD Fortifications Load ---
        if !(_gradForts isEqualTo []) then {
            // Reapply the hashmap to the vehicle
            _vehicle setVariable ["grad_fortifications_myFortsHash", _gradForts, true];
            
            // Recalculate the physical weight/capacity limit so GRAD doesn't give them infinite free space
            private _totalSize = 0;
            private _keys = _gradForts select 0; // CBA Hash structure
            private _values = _gradForts select 1;
            
            {
                private _type = _x;
                private _amount = _values select _forEachIndex;
                private _size = [(missionConfigFile >> "CfgGradFortifications" >> "Fortifications" >> _type >> "size"), "number", [_type] call grad_fortifications_fnc_getObjectSize] call CBA_fnc_getConfigEntry;
                _totalSize = _totalSize + (_size * _amount);
            } forEach _keys;
            
            _vehicle setVariable ["grad_fortifications_inventoryCargo", _totalSize, true];
            
            // Update UI sync for players looking at it
            [_vehicle, _gradForts] remoteExec ["grad_fortifications_fnc_updateItemList", 0, false];
        };
    };
};

true;
