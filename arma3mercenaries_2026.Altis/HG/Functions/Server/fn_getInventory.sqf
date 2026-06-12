/*
    Author - HoverGuy
    Enhanced By: A.I.M. (2026)
    
    A.I.M. PATCH NOTES & PAPER TRAIL:
    - [SQLite Bridge] Hijacked profileNamespace and routed vehicle trunk saving to A3M_fnc_dbSet.
*/
params["_vehicle",["_inventory",[],[[]]]];

private _owner = _vehicle getVariable "HG_Owner";
private _uid = _owner select 0;
private _plate = _owner select 1;

private _items = getItemCargo _vehicle;
private _mags = getMagazineCargo _vehicle;
private _weapons = getWeaponCargo _vehicle;
private _backpacks = getBackpackCargo _vehicle;

// A3M Custom Persistence: Extract GRAD Fortifications & ACE Cargo safely
private _aceCargo = [];
{
    if (_x isEqualType objNull) then {
        // Complex Serialization: Store Classname, Native Inventory, and Fortifications Hash
        private _objInv = [_x] call grad_persistence_fnc_getInventory;
        private _objForts = _x getVariable ["grad_fortifications_myFortsHash", []];
        _aceCargo pushBack [typeOf _x, _objInv, _objForts];
        
        deleteVehicle _x; // CRITICAL: Prevent dupe exploit and floating objects when garage deletes parent!
    } else {
        // Standard strings
        _aceCargo pushBack _x;
    };
} forEach (_vehicle getVariable ["ace_cargo_loaded", []]);

private _gradForts = _vehicle getVariable ["grad_fortifications_myFortsHash", []];

// Push all 6 arrays into the persistent SQLite blob
_inventory pushBack [_items,_mags,_weapons,_backpacks,_aceCargo,_gradForts];

if(!HG_SAVING_EXTDB) then
{
    // [SQLITE SET] Save the trunk contents to the SQLite database
    [format["HG_Inventory_%1_%2",_uid,_plate], _inventory] call A3M_fnc_dbSetSecure;
} else {
    // Legacy extDB3
};

true;
