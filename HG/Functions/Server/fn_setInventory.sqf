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
};

true;
