/*
    Author - HoverGuy (SimpleShops)
    Enhanced By: BrianV1981 & A.I.M. (2026)
    
    A.I.M. PATCH NOTES & PAPER TRAIL:
    - [Architecture] Bypassed legacy 'profileNamespace' entirely. 
    - [SQLite Bridge] Hooked this script into 'A3M_fnc_dbGet' and 'A3M_fnc_dbSet' to route vehicle garage data directly to the native Rust SQLite extension.
    - [Bug Fix] Applied 2024 HG GitHub logic to ensure garages properly initialize as empty arrays if no profile exists.
*/
params["_mode","_unit","_vehicle",["_plate",round(random(9999))],["_color",""]];

if(!HG_SAVING_EXTDB) then
{
    // [SQLITE GET] Pull the player's garage array from the SQLite database.
    private _garage = [format["HG_Garage_%1",(getPlayerUID _unit)],[]] call A3M_fnc_dbGetSecure;
    
    if(_mode isEqualTo 0) then
    {
        // Add new vehicle to the array. (3 = Status: 0 is Inactive/Garaged, 1 is Active/Out)
        _garage pushBack [(typeOf _vehicle),_plate,_color,0]; // Explicitly use typeOf to avoid storing object
    } else {
        // Find existing vehicle by license plate
        private _index = [_plate,_garage] call HG_fnc_findIndex;
        
        if(_index != -1) then
        {
            // Vehicle found: Set its status to 0 (Safely stored in garage)
            (_garage select _index) set [3,0];
        } else {
            // [Bug Fix] 2024 Fallback: If vehicle isn't in array but exists in world, force-add it.
            private _color = (_vehicle getVariable "HG_Owner") select 2;
            _garage pushBack [(typeOf _vehicle),_plate,_color,0];
        };
    };
    
    // [SQLITE SET] Push the updated array back to the SQLite database.
    [format["HG_Garage_%1",(getPlayerUID _unit)], _garage] call A3M_fnc_dbSetSecure;
} else {
    // Legacy extDB3 logic (Ignored)
};

// Mobile Respawn Point Removal integration
if(_mode isEqualTo 1) then
{
    // If vehicle inventory saving is enabled in the mission config, save the inventory before deleting the vehicle
    if((getNumber(getMissionConfig "CfgClient" >> "enableVehicleInventorySave")) isEqualTo 1) then
    {
        [_vehicle] call HG_fnc_getInventory;
    };
    
    // Delete the vehicle from the game world
    deleteVehicle _vehicle;
    
    // Inform the player that the vehicle has been stored successfully
    (localize "STR_HG_GRG_VEHICLE_STORED") remoteExecCall ["hint",(owner _unit),false];
};
    
true;
