/*
    Author - HoverGuy (SimpleShops)
    Enhanced By: A.I.M. (2026)

    A.I.M. PATCH NOTES & PAPER TRAIL:
    - [SQLite Bridge] Hooked into 'A3M_fnc_dbGet' and 'A3M_fnc_dbSet'.
    - [2023 Bug Fix] Applied the official "Ghost Vehicle" exploit fix. Previously, when a vehicle was destroyed, HG just removed it from the array. However, due to desync, players could sometimes still pull it out.
    - [The Fix] We now explicitly wipe the trunk inventory (if enabled) AND we force the SQLite array to overwrite instantly so the garage UI physically cannot read the dead vehicle's plate anymore.
*/
params["_unit","_killer","_instigator","_useEffects","_owner","_uid","_plate"];

_owner = _unit getVariable "HG_Owner";
_uid = _owner select 0;
_plate = _owner select 1;

if(!HG_SAVING_EXTDB) then
{
    private["_garage","_index"];

    // [SQLITE GET] Pull current garage array
    _garage = [format["HG_Garage_%1",_uid],[]] call A3M_fnc_dbGet;
    
    // Find the dead vehicle by license plate
    _index = [_plate,_garage] call HG_fnc_findIndex;
    
    // [Ghost Vehicle Fix] If found, delete it entirely from the garage memory
    if (_index != -1) then {
        _garage deleteAt _index;
    };

    // [SQLITE SET] Instantly commit the garage with the dead vehicle removed
    [format["HG_Garage_%1",_uid], _garage] call A3M_fnc_dbSet;

    // Wipe the trunk inventory so players can't exploit items from blown up cars
    if((getNumber(getMissionConfig "CfgClient" >> "enableVehicleInventorySave")) isEqualTo 1) then
    {
        [format["HG_Inventory_%1_%2",_uid,_plate], ""] call A3M_fnc_dbSet;
    };

} else {
    // Legacy extDB3 Logic (Ignored)
};
