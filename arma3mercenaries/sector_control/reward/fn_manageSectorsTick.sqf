// arma3mercenaries\sector_control\reward\fn_manageSectorsTick.sqf
// Executed every 10 seconds via CBA PFH (Unscheduled Environment)
// Replaces the legacy "Thread-Per-Player" fn_manageSectors.sqf script.

if (!isServer) exitWith {};

// Define Sector Properties once
if (isNil "A3M_SectorConfig") then {
    A3M_SectorConfig = [
        // [TriggerName, RewardMult, SpawnProb, SectorName, BlockTimeSec, RewardTimeSec]
        ["trigger_sector1", 0.5, 0.0, "Fort MAGA", 7200, 300],
        ["trigger_sector2", 1.5, 0.50, "Paros", 3600, 600],
        ["trigger_sector3", 1.25, 0.25, "Pefkas Military Base", 5400, 600],
        ["trigger_sector4", 2.0, 1.0, "Pyrgos", 3600, 300],
        ["trigger_sector5", 1.5, 1.0, "Charkia", 3600, 600],
        ["trigger_sector6", 1.75, 1.25, "Anthrakia", 3600, 600],
        ["trigger_sector7", 1.25, 1.0, "Neochori", 3600, 600],
        ["trigger_sector8", 1.5, 1.0, "Athira", 7200, 600],
        ["trigger_sector9", 1.75, 1.25, "Lakka Military Base", 9000, 600],
        ["trigger_sector10", 1.5, 1.25, "Rodopoli", 3600, 600],
        ["trigger_sector11", 2.0, 1.75, "Telos Military Base", 10800, 720],
        ["trigger_sector12", 3.0, 1.9, "Gravia Airforce Base", 14400, 900]
    ];
};

private _tickInterval = 10; // PFH interval

{
    private _sectorData = _x;
    private _triggerName = _sectorData select 0;
    private _sectorIndex = _forEachIndex;
    
    // Fetch dynamic CBA values
    private _rewardMultiplier = missionNamespace getVariable [format ["A3M_Sector_%1_RewardMult", _sectorIndex], _sectorData select 1];
    private _spawnProbability = missionNamespace getVariable [format ["A3M_Sector_%1_SpawnProb", _sectorIndex], _sectorData select 2];
    private _blockTime = (missionNamespace getVariable [format ["A3M_Sector_%1_BlockMin", _sectorIndex], (_sectorData select 4) / 60]) * 60; // Convert CBA minutes back to seconds

    private _sectorName = _sectorData select 3;
    private _rewardTime = _sectorData select 5;

    private _indicatorID = 790 + _sectorIndex;
    private _warningHintID = 890 + _sectorIndex;
    private _blockedHintID = 990 + _sectorIndex;
    private _payoutHintID = 789;

    private _trigger = missionNamespace getVariable [_triggerName, objNull];
    if (isNull _trigger) then { continue; };
    
    private _triggerPos = getPos _trigger;

    // We must iterate over allPlayers to catch players who have started capturing but left the trigger
    {
        private _player = _x;
        private _uid = getPlayerUID _player;
        if (_uid == "") then { continue; };

        // Key formatted as "UID_SectorName"
        private _stateKey = format ["%1_%2", _uid, _sectorName];
        
        // Retrieve persistent profile and current active state
        private _profile = A3M_LiveProfiles getOrDefault [_uid, createHashMap];
        
        // State Array: [TimeTally, RewardsGiven, BlockEndTime, OutsideTally]
        private _playerState = A3M_SectorControlState getOrDefault [_stateKey, [0, 0, 0, 0]];
        
        private _timeTally = _playerState select 0;
        private _rewardsGiven = _playerState select 1;
        private _blockEndTime = _playerState select 2;
        private _outsideTally = _playerState select 3;

        private _isInSector = _player inArea _trigger;

        // Self-Healing / Unblock Check
        if (_blockEndTime > 0) then {
            if (diag_tickTime >= _blockEndTime) then {
                _blockEndTime = 0;
                _playerState set [2, 0];
                A3M_SectorControlState set [_stateKey, _playerState];
                ["", 0, 0, 0, 0, 0, _blockedHintID] remoteExec ["BIS_fnc_dynamicText", _player];
                
                // Clear SQLite flag
                _profile set [format["BlockEnd_%1", _sectorName], 0];
                ["A3M_PROFILE_" + _uid, _profile] call A3M_fnc_dbSetSecure;
            } else {
                // Player is blocked: Only show warning if they are standing inside the sector while blocked
                if (_isInSector) then {
                    private _remainingMin = ceil ((_blockEndTime - diag_tickTime) / 60);
                    private _blockedMessage = format ["<t color='#FFFF00' size='0.5'>Payments Halted: %1 (Blocked: ~%2 min)</t>", _sectorName, _remainingMin];
                    [_blockedMessage, 1.0, -0.1, 15, 0, 0, _blockedHintID] remoteExec ["BIS_fnc_dynamicText", _player];
                    ["", 0, 0, 0, 0, 0, _indicatorID] remoteExec ["BIS_fnc_dynamicText", _player];
                } else {
                    ["", 0, 0, 0, 0, 0, _blockedHintID] remoteExec ["BIS_fnc_dynamicText", _player];
                };
            };
        };

        // Not Blocked - Process Time
        if (_blockEndTime == 0) then {
            
            if (_isInSector) then {
                // --- PLAYER IS INSIDE ---
                if (_outsideTally > 0) then {
                    _outsideTally = 0; // Reset penalty strikes
                    ["", 0, 0, 0, 0, 0, _warningHintID] remoteExec ["BIS_fnc_dynamicText", _player];
                };

                // Show Active Indicator
                private _indicatorMessage = format ["<t color='#FFFFFF' size='0.5'>Receiving Payments: %1</t>", _sectorName];
                [_indicatorMessage, 1.0, -0.1, 15, 0, 0, _indicatorID] remoteExec ["BIS_fnc_dynamicText", _player];
                ["", 0, 0, 0, 0, 0, _blockedHintID] remoteExec ["BIS_fnc_dynamicText", _player];

                // Tally Time
                _timeTally = _timeTally + _tickInterval;

                if (_timeTally >= _rewardTime) then {
                    _timeTally = 0;
                    _rewardsGiven = _rewardsGiven + 1;

                    // Grant Economic Reward
                    private _rewardBase = switch (_rewardsGiven) do { case 1: {5000}; case 2: {20000}; case 3: {25000}; case 4: {50000}; case 5: {75000}; case 6: {100000}; default {0}; };
                    private _reward = _rewardBase * _rewardMultiplier;
                    
                    [_player, _reward] remoteExecCall ["grad_moneymenu_fnc_addFunds", _player];
                    
                    private _msg = format ["<t color='#FFFFFF' size='0.5'>Player: %1<br/>Sector: %2<br/>Payment: %3 Cr</t>", name _player, _sectorName, _reward];
                    [_msg, 1.0, 0.4, 10, 1, 0, _payoutHintID] remoteExec ["BIS_fnc_dynamicText", _player];

                    // Request AI Spawn (Decoupled to prevent stutter)
                    if (_rewardsGiven == 2 || _rewardsGiven == 4) then {
                        A3M_PendingAI_Spawns pushBack [_triggerPos, _spawnProbability, _sectorName];
                    };

                    // Trigger Block on Completion
                    if (_rewardsGiven >= 6) then {
                        _blockEndTime = diag_tickTime + _blockTime;
                        _rewardsGiven = 0; 
                        
                        private _blockMsg = format ["Good job securing %1! Payments halted for %2 minutes.", _sectorName, _blockTime / 60];
                        [_blockMsg, -1, -1, 10, 1, 0, _payoutHintID] remoteExec ["BIS_fnc_dynamicText", _player];
                        
                        // Save to SQLite
                        _profile set [format["BlockEnd_%1", _sectorName], 1]; // Flagged for offline tracking
                        ["A3M_PROFILE_" + _uid, _profile] call A3M_fnc_dbSetSecure;
                    };
                };

            } else {
                // --- PLAYER IS OUTSIDE ---
                // Only track penalty time if they have started capturing (TimeTally > 0 or RewardsGiven > 0)
                if (_timeTally > 0 || _rewardsGiven > 0) then {
                    _outsideTally = _outsideTally + _tickInterval;
                    
                    // Hide payment indicator
                    ["", 0, 0, 0, 0, 0, _indicatorID] remoteExec ["BIS_fnc_dynamicText", _player];

                    // Strike 1 Warning (~120s / 2 mins outside)
                    if (_outsideTally >= 120 && _outsideTally < 240) then {
                        private _warningMessage = format ["<t color='#FFFF00' size='0.5'>WARNING: Not detected inside %1.<br/>Return to the sector to continue payments.</t>", _sectorName];
                        [_warningMessage, 1.0, 0.4, 15, 0, 0, _warningHintID] remoteExec ["BIS_fnc_dynamicText", _player];
                    };
                    
                    // Strike 2 Warning (~240s / 4 mins outside)
                    if (_outsideTally >= 240 && _outsideTally < 360) then {
                        private _warningMessage = format ["<t color='#FF8C00' size='0.5'>FINAL WARNING: Not detected inside %1.<br/>Leaving sector will halt payments!</t>", _sectorName];
                        [_warningMessage, 1.0, 0.4, 15, 0, 0, _warningHintID] remoteExec ["BIS_fnc_dynamicText", _player];
                    };

                    // Strike 3 Block (~360s / 6 mins outside)
                    if (_outsideTally >= 360) then {
                        _blockEndTime = diag_tickTime + _blockTime;
                        _rewardsGiven = 0;
                        _timeTally = 0;
                        _outsideTally = 0; // Reset to prevent instant re-block later
                        
                        private _blockMsg = format ["You were outside the %1 sector boundaries for too long! Payments have been halted and can be resumed in %2 minutes.", _sectorName, _blockTime / 60];
                        [_blockMsg, -1, -1, 10, 1, 0, _payoutHintID] remoteExec ["BIS_fnc_dynamicText", _player];
                        ["", 0, 0, 0, 0, 0, _warningHintID] remoteExec ["BIS_fnc_dynamicText", _player]; // clear warnings
                        
                        // Save to SQLite
                        _profile set [format["BlockEnd_%1", _sectorName], 1]; // Flagged for offline tracking
                        ["A3M_PROFILE_" + _uid, _profile] call A3M_fnc_dbSetSecure;
                    };
                };
            };

            // Save State
            _playerState set [0, _timeTally];
            _playerState set [1, _rewardsGiven];
            _playerState set [2, _blockEndTime];
            _playerState set [3, _outsideTally];
            A3M_SectorControlState set [_stateKey, _playerState];
        };

    } forEach allPlayers;
} forEach A3M_SectorConfig;