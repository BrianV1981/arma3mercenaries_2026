#include "HG_Macros.h"
/*
    fn_buyVehicle.sqf
    Author - HoverGuy
    GitHub - https://github.com/Ppgtjmad/SimpleShops
	Steam - https://steamcommunity.com/id/HoverGuy/
    Enhanced by - BrianV1981
    Changes:
    - Replaced HG money handling functions with Grad Money functions.
    - Removed discount logic based on player rank (commented out).
    - Updated for compatibility with Grad Money system.
*/

private["_price", "_discount"];

disableSerialization;

// Get the price of the selected vehicle
_price = HG_VEHICLES_LIST lbValue (lbCurSel HG_VEHICLES_LIST);

// Commented out the discount logic based on player rank
/*
_discount = ((getNumber(getMissionConfig "CfgClient" >> "HG_MasterCfg" >> (rank player) >> "vShopDiscount")) != 0) AND (_price != 0);

if(_discount) then
{
    _price = round(_price - (_price * ((getNumber(getMissionConfig "CfgClient" >> "HG_MasterCfg" >> (rank player) >> "vShopDiscount")) / 100)));
};
*/

// Check if the player has enough money using Grad Money
private _playerFunds = [player, false] call grad_lbm_fnc_getFunds;

if(_playerFunds >= _price) then
{
    private["_classname", "_color", "_spawnPosition", "_targetLaptop", "_distance", "_direction", "_heading"];

    _classname = HG_VEHICLES_LIST lbData (lbCurSel HG_VEHICLES_LIST);
    
    // Check if the item is sold out globally
    private _shortages = missionNamespace getVariable ["A3M_ActiveShortages", createHashMap];
    if (_classname in _shortages) exitWith {
        private _a3mMsg = "<t align='center'><t font='RobotoCondensedBold' size='0.8' color='#FF0000'>OUT OF STOCK</t><br/><t font='PuristaMedium' size='0.6' color='#FFFFFF'>This vehicle is currently sold out on the Black Market.</t></t>";
        [_a3mMsg, -1, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;
    };
    
    _color = HG_VEHICLES_COLORS lbData (lbCurSel HG_VEHICLES_COLORS);
    
    // -------------------------------------------------------------
    // DYNAMIC SPAWN LOGIC: Config Markers -> Laptop Math Fallback
    // -------------------------------------------------------------
    _spawnPosition = [];
    private _spDropdown = HG_VEHICLES_SP;
    private _spValue = -1;

    // 1. Try to use explicit config markers from the dropdown list
    if (!isNull _spDropdown && {(lbCurSel _spDropdown) != -1}) then {
        _spValue = _spDropdown lbValue (lbCurSel _spDropdown);
    };
    
    if (_spValue != -1) then {
        private _shopType = HG_VEHICLES_SWITCH lbData (lbCurSel HG_VEHICLES_SWITCH);
        _shopType = _shopType splitString "/";
        private _spawnPoints = getArray(getMissionConfig "CfgClient" >> "HG_VehiclesShopCfg" >> (_shopType select 0) >> (_shopType select 1) >> "spawnPoints");
        
        if (count _spawnPoints > _spValue) then {
            private _selectedSpawn = _spawnPoints select _spValue; 
            private _markerArray = _selectedSpawn select 1;
            
            // Find first empty marker
            {
                if(count(nearestObjects[(getMarkerPos _x),["Car","Truck","Tank","Air","Ship","Submarine"],5]) isEqualTo 0) exitWith
                {
                    _spawnPosition = _x; // passing string marker to server
                };
            } forEach _markerArray;

            if ((typeName _spawnPosition) isEqualTo "ARRAY" && {_spawnPosition isEqualTo []}) then {
                titleText [(localize "STR_HG_SPAWN_BLOCKED"), "PLAIN DOWN", 1];
            };
        };
    };

    // 2. If no valid marker was found, fallback to player-relative dynamic math
    if ((typeName _spawnPosition) isEqualTo "ARRAY" && {_spawnPosition isEqualTo []}) then {
        private _distance = 50;
        private _direction = 0; 
        private _heading = getDir player;

        private _mathPos = player getRelPos [_distance, _direction];
        
        private _safePos = [];
        for "_i" from 1 to 50 do {
            _safePos = _mathPos findEmptyPosition [0, 20 + 5*_i, _classname];
            if !(_safePos isEqualTo []) exitWith {};
        };
        
        if !(_safePos isEqualTo []) then {
            _spawnPosition = _safePos;
            _spawnPosition pushBack _heading; // Server reads [X, Y, Z, Heading]
        } else {
            _spawnPosition = (getPos player) findEmptyPosition [50, 150, _classname];
        };
        
        if (_spawnPosition isEqualTo []) exitWith {
            titleText ["NO SAFE SPAWN POSITION FOUND NEARBY! PURCHASE CANCELLED.", "PLAIN DOWN", 1];
        };
    };

    if ((typeName _spawnPosition) isEqualTo "ARRAY" && {_spawnPosition isEqualTo []}) exitWith {};

    // Deduct the price from the player's Grad Money account
    [player, -_price] call grad_lbm_fnc_addFunds;

    // Close the dialog and spawn the vehicle
    closeDialog 0;
    
    private _displayName = getText(configFile >> "CfgVehicles" >> _classname >> "displayName");
    hint format[(localize "STR_HG_VEHICLE_BOUGHT"), _displayName, [_price, true] call HG_fnc_currencyToText];
    
    // Spawn the vehicle on the server using our raw XYZ array instead of a marker string
    [0, player, _classname, _spawnPosition, nil, _color] remoteExecCall ["HG_fnc_spawnVehicle", 2, false];
    
    // Log transaction to A3M Player Dossier
    [player, _displayName, _price] remoteExecCall ["A3M_fnc_serverLogTransaction", 2];

    // Trigger the 3D GRAD Position Marker so the player knows exactly where the vehicle spawned
    // GRAD vehicleMarker expects: [buyer, vehicle, baseConfig, categoryConfig, itemConfig]
    // Since we don't have the GRAD configs here, we can just pass dummy strings, because the script only needs the vehicle object and the itemConfigName (classname) for the display name.
    // Wait, we need the actual spawned vehicle object! HG_fnc_spawnVehicle executes on the server and doesn't return the vehicle to the client natively.
    // However, we can track it by waiting for the player to become the owner of a new vehicle, or we can just spawn it locally for the marker, but that's complex.
    // Actually, HG_fnc_spawnVehicle executes: `[_vehicle] remoteExecCall ["HG_fnc_addActions",(owner _unit),false];` 
    // It's easier to just use a custom 3D marker loop locally based on the coordinates for 30 seconds!
    
    [_classname, _spawnPosition] spawn {
        params ["_classname", "_spawnPosition"];
        private _displayName = getText(configFile >> "CfgVehicles" >> _classname >> "displayName");
        private _endTime = time + 90;
        
        // Custom 3D Marker rendering loop (mimicking GRAD)
        waitUntil {
            drawIcon3D ["a3\ui_f\data\gui\Rsc\RscDisplayIntel\azimuth_ca.paa", [0,1,0,1], [_spawnPosition select 0, _spawnPosition select 1, (_spawnPosition select 2) + 2.5], 1, 1, 180, format ["%1 SPAWNED HERE", _displayName], 1, 0.04, "PuristaMedium", "center", true];
            (time > _endTime)
        };
    };
} else {
    titleText [format[(localize "STR_HG_NOT_ENOUGH_MONEY"), [_price, true] call HG_fnc_currencyToText], "PLAIN DOWN", 1];
};

true;
