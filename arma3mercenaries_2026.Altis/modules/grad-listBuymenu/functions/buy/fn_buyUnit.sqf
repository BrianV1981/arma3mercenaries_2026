/*  
* Spawns unit(s) and assigns the arma3mercenaries_groupOwner variable
*/

params ["_buyer","_account","_price","_code","_baseConfigName","_categoryConfigName","_itemConfigName","_vehiclespawn"];

_amount = [(missionConfigFile >> "CfgGradBuymenu" >> _baseConfigName >> _categoryConfigName >> _itemConfigName >> "amount"), "number", 1] call CBA_fnc_getConfigEntry;
_minDistance = 0;

//vehiclespawn is object
if (_vehiclespawn isEqualType objNull) then {
    _minDistance = 5;
    _vehiclespawn = getPos _vehiclespawn;
};

//find spawn position
_spawnPosition = [];
for "_i" from 1 to 50 do {
    _spawnPosition = _vehiclespawn findEmptyPosition [_minDistance, 15 + 5*_i, _itemConfigName];
    if (str _spawnPosition != "[]") exitWith {};
};
if (str _spawnPosition == "[]") exitWith {[_buyer,_account,_price,"No unit spawn position found. You got your money back."] remoteExec ["grad_lbm_fnc_reimburse",0,false]};

//create a group for the units
_group = createGroup side _buyer;

//spawn units
for "_i" from 1 to _amount do {
    // Spawn the unit and add it to the group
    private _unit = _itemConfigName createUnit [_spawnPosition, _group];
    
    // Disable VCOM AI so they strictly obey the player's commands
    [_unit] call A3M_fnc_disableVcom;
    
    // Assign the arma3mercenaries_groupOwner variable to the unit
    private _ownerUID = getPlayerUID _buyer;
    _unit setVariable ["arma3mercenaries_groupOwner", _ownerUID, true];
    
    // --- A3M Squad Stats Initialization ---
    // Generate Unique Mercenary ID
    private _uniqueUnitID = round(time * 100) + _i; // Added _i to prevent dupes in fast loops
    private _aiUnitID = format ["arma3mercenaries_aiUnit_%1_%2", _uniqueUnitID, _ownerUID];
    
    // Broadcast ID globally
    _unit setVariable ["arma3mercenaries_aiUnit", _aiUnitID, true];
    
    // Ensure we are on the server before hitting the SQLite extension
    if (isServer) then {
        // Initialize SQLite Profile using explicit sets to avoid any array conversion issues
        private _mercProfile = createHashMap;
        _mercProfile set ["Name", name _unit];
        _mercProfile set ["Class", _itemConfigName];
        _mercProfile set ["JoinDate", systemTimeUTC];
        _mercProfile set ["Kills", 0];
        _mercProfile set ["Deaths", 0];
        _mercProfile set ["CashCarried", 0];
        _mercProfile set ["OwnerUID", _ownerUID];
        _mercProfile set ["Status", "Active"];
        
        // Log to RPT
        diag_log format ["A3M DEBUG: Saving Mercenary %1 to DB: %2", _aiUnitID, str _mercProfile];
        
        // Save to DB
        [format["A3M_MERC_%1", _aiUnitID], _mercProfile] call A3M_fnc_dbSetSecure;
        
        // Add to Player's Roster
        private _playerProfile = ["A3M_PROFILE_" + _ownerUID, createHashMap, true] call A3M_fnc_dbGetSecure;
        private _ownedMercs = _playerProfile getOrDefault ["OwnedMercenaries", []];
        _ownedMercs pushBack _aiUnitID;
        _playerProfile set ["OwnedMercenaries", _ownedMercs];
        ["A3M_PROFILE_" + _ownerUID, _playerProfile] call A3M_fnc_dbSetSecure;
        
        // --- The Death Tracker (Graveyard Support) ---
        _unit addMPEventHandler ["MPKilled", {
            params ["_unit", "_killer", "_instigator", "_useEffects"];
            if (!isServer) exitWith {};
            
            private _mercID = _unit getVariable ["arma3mercenaries_aiUnit", ""];
            private _groupID = _unit getVariable ["arma3mercenaries_groupID", ""]; 
            private _ownerID = _unit getVariable ["arma3mercenaries_groupOwner", ""];
            
            if (_mercID != "") then {
                private _profile = [format["A3M_MERC_%1", _mercID], createHashMap, true] call A3M_fnc_dbGetSecure;
                if (count _profile > 0) then {
                    _profile set ["Deaths", (_profile getOrDefault ["Deaths", 0]) + 1];
                    _profile set ["Status", "KIA"];
                    _profile set ["DeathDate", systemTimeUTC];
                    
                    // Determine Cause of Death
                    private _cause = "Killed in Action";
                    if (isNull _instigator && isNull _killer) then { _cause = "Accident / Unknown"; };
                    if (!isNull _instigator) then {
                        if (isPlayer _instigator) then {
                            if (getPlayerUID _instigator == _ownerID) then {
                                _cause = "Executed by Commander";
                            } else {
                                _cause = format ["Killed by Player: %1", name _instigator];
                            };
                        } else {
                            if (side _instigator == side _unit) then {
                                _cause = "Friendly Fire (AI)";
                            };
                        };
                    };
                    _profile set ["CauseOfDeath", _cause];
                    
                    [format["A3M_MERC_%1", _mercID], _profile] call A3M_fnc_dbSetSecure;
                };
            };
        }];
    };
    
    // Debug output to verify if the variable is set correctly
    // diag_log format ["Unit: %1, Owner UID: %2, AI Unit ID: %3", _unit, _ownerUID, _aiUnitID];
};

// Execute the provided code with the buyer, item, group, and spawn position
[_buyer,_itemConfigName,_group,_spawnPosition] call _code;
[[_buyer,_itemConfigName,_group,_spawnPosition],_code] remoteExec ["grad_lbm_fnc_callCodeClient",0,false];

//vehicle marker
_c1 = [(missionConfigFile >> "CfgGradBuymenu" >> _baseConfigName >> "vehicleMarkers"), "number", 2] call CBA_fnc_getConfigEntry;
_c2 = [(missionConfigFile >> "CfgGradBuymenu" >> "vehicleMarkers"), "number", 1] call CBA_fnc_getConfigEntry;
switch (true) do {
    case (_c1 == 1): {
        [_buyer, leader _group, _baseConfigName, _categoryConfigName, _itemConfigName] remoteExec ["grad_lbm_fnc_vehicleMarker", 0, false];
    };
    case (_c1 == 0): {false};
    case (_c2 == 1): {
        [_buyer, leader _group, _baseConfigName, _categoryConfigName, _itemConfigName] remoteExec ["grad_lbm_fnc_vehicleMarker", 0, false];
    };
    default {false};
};
