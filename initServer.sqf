// execVM "arma3mercenaries\salvaging\arma3mercenaries_salvagingInit.sqf"; // failed idea so far...
// execVM "arma3mercenaries\salvaging\vehicleDestroyedTest.sqf"; // failed idea so far...
// [] execVM "arma3mercenaries\set_group_captive\setGroupCaptive.sqf"; // work in progress (doing it manually with ace self interact for now)

// --- A.I.M. Sovereign SQLite Bridge (v812+ Architecture) ---
// These wrappers establish a secure, native-HashMap compatible connection to the a3m_db_core Rust extension.
// They explicitly use toArray/parseSimpleArray to completely eliminate the use of `call compile`.

A3M_fnc_dbSetSecure = {
    params ["_key", "_data"];
    private _dataToSave = _data;
    
    // If the data is a HashMap, we explicitly flatten it to [keys, values] for safe serialization
    if (typeName _data == "HASHMAP") then {
        _dataToSave = [keys _data, values _data];
    };
    
    // Serialize to string safely
    private _serializedString = str _dataToSave;
    
    // Send to SQLite via Rust bridge
    "a3m_db_core" callExtension ["set", [_key, _serializedString]];
};

A3M_fnc_dbGetSecure = {
    params ["_key", "_defaultValue", ["_isHashMap", false]];
    
    // Fetch data from DB
    private _extArray = "a3m_db_core" callExtension ["get", [_key]];
    private _rawString = _extArray select 0;
    diag_log format ["[A3M DEBUG] RAW RUST STRING FOR %1: %2", _key, _rawString];
    
    // parseSimpleArray native safety check
    private _result = parseSimpleArray _rawString;
    
    // Rust bridge returns [1, "data"] on success, [0, "error"] on fail
    if ((_result select 0) isEqualTo 1 && {(_result select 1) != ""}) then {
        private _valString = _result select 1;
        
        // Check if it's an array bracket
        if (([_valString, 0, 0] call BIS_fnc_trimString) == "[") then {
            private _parsedArray = parseSimpleArray _valString;
            
            // Reconstruct HashMap if requested
            if (_isHashMap) then {
                private _newHash = createHashMap;
                
                // Handle the [keys, values] format we explicitly save
                if (count _parsedArray == 2 && {(_parsedArray select 0) isEqualType []} && {(_parsedArray select 1) isEqualType []}) then {
                    private _keys = _parsedArray select 0;
                    private _values = _parsedArray select 1;
                    {
                        _newHash set [_x, _values select _forEachIndex];
                    } forEach _keys;
                } else {
                    // Fallback for native key-value pair arrays [[k,v], [k,v]]
                    {
                        _newHash set [_x select 0, _x select 1];
                    } forEach _parsedArray;
                };
                
                _newHash;
            } else {
                _parsedArray;
            };
        } else {
            // It's not an array, parse it as a number or return as string
            private _parsedNumber = parseNumber _valString;
            if (_valString == "0" || _parsedNumber != 0) then {
                _parsedNumber;
            } else {
                _valString;
            };
        };
    } else {
        _defaultValue; // DB lookup failed or empty
    };
};
// -------------------------------------------------------------

// --- A3M DEEP STAT TRACKING (Phase 1) ---
if (isNil "A3M_LiveProfiles") then {
    A3M_LiveProfiles = createHashMap;
};

A3M_fnc_initPlayerProfile = {
    params ["_uid", "_playerName"];
    private _dbKey = "A3M_PROFILE_" + _uid;
    
    // Attempt to load from SQLite (true flag for hashmap reconstruct)
    private _profile = [_dbKey, "", true] call A3M_fnc_dbGetSecure;
    
    if (isNil "_profile" || {typeName _profile != "HASHMAP"}) then {
        // Create new massive HashMap
        _profile = createHashMap;
        _profile set ["PlayerName", _playerName];
        _profile set ["Kills_Total", 0];
        _profile set ["Deaths_Total", 0];
        _profile set ["TeamKills", 0];
        _profile set ["CivilianKills", 0];
        _profile set ["Suicides", 0];
        _profile set ["Distance_Walked", 0];
        _profile set ["Distance_Driven", 0];
        _profile set ["Distance_Flown", 0];
        _profile set ["PlayTime_Minutes", 0];
        _profile set ["Revives_Given", 0];
        // Use systemTime string representation for join date
        private _date = systemTime;
        private _month = if ((_date select 1) < 10) then {format["0%1", _date select 1]} else {str (_date select 1)};
        private _day = if ((_date select 2) < 10) then {format["0%1", _date select 2]} else {str (_date select 2)};
        private _dateString = format ["%1-%2-%3", _date select 0, _month, _day];

        _profile set ["First_Joined_Date", _dateString];
        _profile set ["Last_Deployment_Date", _dateString];

        _profile set ["Top_10_Longest_Kills", []];
        _profile set ["Last_10_Deaths", []];
        _profile set ["Last_10_Kills", []];
        _profile set ["Last_10_Purchases", []];

        // Save to DB immediately
        [_dbKey, _profile] call A3M_fnc_dbSetSecure;
        diag_log format ["[A3M PROFILE] Created new SQLite profile for %1 (%2)", _playerName, _uid];
        } else {
        // Update the Last Deployment Date every time they log in
        private _date = systemTime;
        private _month = if ((_date select 1) < 10) then {format["0%1", _date select 1]} else {str (_date select 1)};
        private _day = if ((_date select 2) < 10) then {format["0%1", _date select 2]} else {str (_date select 2)};
        _profile set ["Last_Deployment_Date", format ["%1-%2-%3", _date select 0, _month, _day]];
        [_dbKey, _profile] call A3M_fnc_dbSetSecure;

        diag_log format ["[A3M PROFILE] Loaded existing SQLite profile for %1 (%2)", _playerName, _uid];
        };
    
    // Store in live server memory
    A3M_LiveProfiles set [_uid, _profile];
};

A3M_fnc_serverFetchProfileForClient = {
    params ["_clientObj"];
    if (!isServer || isNull _clientObj) exitWith {};
    
    private _uid = getPlayerUID _clientObj;
    private _profile = A3M_LiveProfiles getOrDefault [_uid, createHashMap];
    
    // Fetch Garage from SQLite
    private _garageKey = "HG_Garage_" + _uid;
    private _garageData = [_garageKey, [], false] call A3M_fnc_dbGetSecure;
    
    // Scan server for active deployed vehicles not in the garage DB
    private _knownPlates = [];
    { _knownPlates pushBack (_x select 1); } forEach _garageData; // Get plates of all HG cars
    
    {
        private _ownerArray = _x getVariable ["HG_Owner", []];
        if (count _ownerArray > 0 && {(_ownerArray select 0) == _uid}) then {
            private _plate = _ownerArray select 1; // Index 1 is the Plate Number
            private _color = _ownerArray select 2; // Index 2 is the Color
            if (!(_plate in _knownPlates)) then {
                // It's a deployed vehicle bought from another store, add it dynamically!
                _garageData pushBack [typeOf _x, _plate, _color, 1]; // 1 = Active
            };
        };
    } forEach vehicles;
    
    // Append current player specific volatile stats to profile before flattening
    _profile set ["_TargetWallet", [_clientObj, false] call grad_moneymenu_fnc_getFunds];
    _profile set ["_TargetBank", [_clientObj, true] call grad_moneymenu_fnc_getFunds];
    private _hgRankData = _clientObj getVariable ["HG_XP", ["PRIVATE", 0]];
    _profile set ["_TargetRankName", _hgRankData select 0];
    _profile set ["_TargetXP", _hgRankData select 1];
    
    // Flatten for network transmission
    private _flatData = [keys _profile, values _profile, _garageData];
    [_flatData] remoteExecCall ["A3M_fnc_receiveProfileData", _clientObj];
};

A3M_fnc_serverFetchTargetProfileForClient = {
    params ["_targetUid", "_clientObj"];
    if (!isServer || isNull _clientObj || _targetUid == "") exitWith {};
    
    // Try live profiles first (if they are online)
    private _profile = A3M_LiveProfiles getOrDefault [_targetUid, createHashMap];
    private _isOnline = false;
    
    if (count _profile == 0) then {
        // Fetch offline from SQLite
        private _dbKey = "A3M_PROFILE_" + _targetUid;
        _profile = [_dbKey, createHashMap, true] call A3M_fnc_dbGetSecure;
    } else {
        _isOnline = true;
    };
    
    // Fetch Garage from SQLite
    private _garageKey = "HG_Garage_" + _targetUid;
    private _garageData = [_garageKey, [], false] call A3M_fnc_dbGetSecure;
    
    if (_isOnline) then {
        // Scan server for active deployed vehicles not in the garage DB for this online player
        private _knownPlates = [];
        { _knownPlates pushBack (_x select 1); } forEach _garageData;
        
        {
            private _ownerArray = _x getVariable ["HG_Owner", []];
            if (count _ownerArray > 0 && {(_ownerArray select 0) == _targetUid}) then {
                private _plate = _ownerArray select 1;
                private _color = _ownerArray select 2;
                if (!(_plate in _knownPlates)) then {
                    _garageData pushBack [typeOf _x, _plate, _color, 1];
                };
            };
        } forEach vehicles;
    };
    
    // Grab Wealth from SQLite (grad persistence)
    private _gradKey = "mcd_grad_persistence_my_persistent_mission_player_" + _targetUid;
    private _gradData = [_gradKey, [], false] call A3M_fnc_dbGetSecure;
    private _offlineBank = 0;
    private _offlineWallet = 0;
    
    if (count _gradData == 2) then {
        private _gKeys = _gradData select 0;
        private _gVals = _gradData select 1;
        private _bankIdx = _gKeys find "bankMoney";
        private _moneyIdx = _gKeys find "money";
        if (_bankIdx != -1) then { _offlineBank = _gVals select _bankIdx; };
        if (_moneyIdx != -1) then { _offlineWallet = _gVals select _moneyIdx; };
    };

    _profile set ["_TargetWallet", _offlineWallet];
    _profile set ["_TargetBank", _offlineBank];
    _profile set ["_TargetRankName", "UNKNOWN (OFFLINE)"];
    _profile set ["_TargetXP", 0];
    
    // Flatten for network transmission
    private _flatData = [keys _profile, values _profile, _garageData];
    [_flatData] remoteExecCall ["A3M_fnc_receiveProfileData", _clientObj];
};

A3M_fnc_serverUpdatePedometer = {
    params ["_type", "_dist", "_seconds", "_clientObj"];
    if (!isServer || isNull _clientObj) exitWith {};
    
    private _uid = getPlayerUID _clientObj; 
    if (_uid == "") exitWith {};
    
    private _profile = A3M_LiveProfiles getOrDefault [_uid, createHashMap];
    if (count _profile > 0) then {
        // Update Time
        _profile set ["PlayTime_Minutes", (_profile getOrDefault ["PlayTime_Minutes", 0]) + (_seconds / 60)];
        
        // Update Distance
        if (_dist > 0) then {
            switch (_type) do {
                case 0: { _profile set ["Distance_Walked", (_profile getOrDefault ["Distance_Walked", 0]) + _dist]; };
                case 1: { _profile set ["Distance_Driven", (_profile getOrDefault ["Distance_Driven", 0]) + _dist]; };
                case 2: { _profile set ["Distance_Flown", (_profile getOrDefault ["Distance_Flown", 0]) + _dist]; };
            };
        };
        
        // Write to DB every 60 seconds (6 pings)
        private _pingCount = _profile getOrDefault ["_TempPingCount", 0];
        _pingCount = _pingCount + 1;
        if (_pingCount >= 6) then {
            ["A3M_PROFILE_" + _uid, _profile] call A3M_fnc_dbSetSecure;
            _pingCount = 0;
            diag_log format ["[A3M PEDOMETER] Saved 60s movement data for %1", _uid];
        };
        _profile set ["_TempPingCount", _pingCount];
        A3M_LiveProfiles set [_uid, _profile];
    };
};

A3M_fnc_serverFetchLeaderboard = compileFinal (preprocessFileLineNumbers "arma3mercenaries\leaderboard\fn_serverFetchLeaderboard.sqf");
// -------------------------------------------------------------

/*
execVM "arma3mercenaries\sector_control\spawn\arma3mercenaries_fn_spawnSectorControlUnit_12.sqf";
execVM "arma3mercenaries\sector_control\spawn\arma3mercenaries_fn_spawnSectorControlUnit_11.sqf";
execVM "arma3mercenaries\sector_control\spawn\arma3mercenaries_fn_spawnSectorControlUnit_10.sqf";
execVM "arma3mercenaries\sector_control\spawn\arma3mercenaries_fn_spawnSectorControlUnit_9.sqf";
execVM "arma3mercenaries\sector_control\spawn\arma3mercenaries_fn_spawnSectorControlUnit_8.sqf";
execVM "arma3mercenaries\sector_control\spawn\arma3mercenaries_fn_spawnSectorControlUnit_7.sqf";
execVM "arma3mercenaries\sector_control\spawn\arma3mercenaries_fn_spawnSectorControlUnit_6.sqf";
execVM "arma3mercenaries\sector_control\spawn\arma3mercenaries_fn_spawnSectorControlUnit_5.sqf";
execVM "arma3mercenaries\sector_control\spawn\arma3mercenaries_fn_spawnSectorControlUnit_4.sqf";
execVM "arma3mercenaries\sector_control\spawn\arma3mercenaries_fn_spawnSectorControlUnit_3.sqf";
execVM "arma3mercenaries\sector_control\spawn\arma3mercenaries_fn_spawnSectorControlUnit_2.sqf";
execVM "arma3mercenaries\sector_control\spawn\arma3mercenaries_fn_spawnSectorControlUnit_1.sqf";

[] execVM "arma3mercenaries\sector_control\reward_system\fn_checkSector_1.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_checkSector_2.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_checkSector_3.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_checkSector_4.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_checkSector_5.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_checkSector_6.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_checkSector_7.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_checkSector_8.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_checkSector_9.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_checkSector_10.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_checkSector_11.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_checkSector_12.sqf";

[] execVM "arma3mercenaries\sector_control\reward_system\fn_rewardSector_1.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_rewardSector_2.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_rewardSector_3.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_rewardSector_4.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_rewardSector_5.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_rewardSector_6.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_rewardSector_7.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_rewardSector_8.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_rewardSector_9.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_rewardSector_10.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_rewardSector_11.sqf";
[] execVM "arma3mercenaries\sector_control\reward_system\fn_rewardSector_12.sqf";
*/

/// temporarily disable alive reward systems (disable installation, complete task, and objective secured)
// execVM "scripts\aliveDisableReward.sqf"; (fires off all the time - randomly)
// execVM "arma3mercenaries\ALiVE\aliveTaskReward.sqf"; (fires off all the time - randomly)

///using ace towing now
///execVM "SA_AdvancedTowing\functions\fn_advancedTowingInit.sqf";
execVM "AR_AdvancedRappelling\functions\fn_advancedRappellingInit.sqf";
execVM "SA_AdvancedSlingLoading\functions\fn_advancedSlingLoadingInit.sqf";
execVM "scripts\HG_initServer.sqf";

///execVM "scripts\deleteVehicles_Dock_1.sqf";
///execVM "scripts\deleteVehicles_Dock_2.sqf";
///execVM "scripts\deleteVehicles_Garage_1.sqf";
///execVM "scripts\deleteVehicles_Garage_2.sqf";

////http://alivemod.com/forum/4788-autosave-every-x-minutes/0 (directions say init.sqf but I think serverinit.sqf is better?)
21601 call ALiVE_fnc_AutoSave_PNS;

///https://github.com/gruppe-adler/grad-persistence/wiki/saveMission
[{[false, 3601] call grad_persistence_fnc_saveMission}, 21000, []] call CBA_fnc_addPerFrameHandler;


// Initialize the new Sector Control State Machine
[] call A3M_fnc_initSectorControl;
nul = [] execVM "arma3mercenaries\interrogations\interrogationTaskLocations.sqf";




///arma3mercenaries HVT Task Tracking

// --- Initialize the global tracking array directly ---
if (isServer) then { // Good practice to wrap server-only init logic
    if (isNil "server_activeHvtTasks") then {
        server_activeHvtTasks = [];
        diag_log "SERVER: Initialized server_activeHvtTasks array.";
    };

    // --- Start the HVT tracker loop using spawn ---
    [] spawn {
        // Check if server again inside spawn just to be safe if code is moved later
        if (!isServer) exitWith {};
        // Execute the tracker script in this spawned thread
        [] execVM "arma3mercenaries\tasks\HVT_1\HVTTaskTracker.sqf";

    };
    diag_log "SERVER: HVT Task Tracker script spawned.";
};

HG_SAVING_EXTDB = false; // addresses extDB error from HG Simple Shops