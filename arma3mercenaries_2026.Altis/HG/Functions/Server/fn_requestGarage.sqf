/*
    Author - HoverGuy (SimpleShops)
    Enhanced By: A.I.M. (2026)

    A.I.M. PATCH NOTES & PAPER TRAIL:
    - [SQLite Bridge] Hooked into 'A3M_fnc_dbGet'.
    - [2024 Bug Fix] Applied the official "Disappearing Vehicle" fix. Prevents the garage UI from locking up or hiding vehicles if the array returns corrupted nulls.
*/
params["_unit","_grg","_garage",["_toSend",[],[[]]]];

if(!HG_SAVING_EXTDB) then
{
    // [SQLITE GET] Pull the garage array
    _garage = [format["HG_Garage_%1",(getPlayerUID _unit)],[]] call A3M_fnc_dbGetSecure;
    
    // [2024 Fix] Safely filter the array to ONLY include vehicles that are currently marked "Inactive" (0)
    // and explicitly ensure the array isn't null.
    if (!isNil "_garage" && {typeName _garage == "ARRAY"}) then {
        _garage = _garage select {(_x select 3) isEqualTo 0};
    } else {
        _garage = [];
    };
} else {
    // Legacy extDB3 Logic (Ignored)
};

if((count _garage) != 0) then
{
    private _types = getArray(getMissionConfig "CfgClient" >> "HG_GaragesCfg" >> _grg >> "allowedTypes");

    {
        _type = [_x select 0] call HG_fnc_getType;
        if(_type in _types) then
        {
            _toSend pushBack [(_x select 0),(_x select 1),(_x select 2)];
        };
    } forEach _garage;
};

// Send the safely filtered list back to the player's UI
_toSend remoteExecCall ["HG_fnc_fillGarage",(owner _unit),false];

true;
