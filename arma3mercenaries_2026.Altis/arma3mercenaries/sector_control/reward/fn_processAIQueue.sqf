// arma3mercenaries\sector_control\reward\fn_processAIQueue.sqf
// Executed every 5 seconds via CBA PFH (Unscheduled Environment)
// Decouples heavy AI spawning from the economic reward loop to prevent server stutter.

if (!isServer) exitWith {};

if (count A3M_PendingAI_Spawns > 0) then {
    // Pop the first request off the queue
    private _request = A3M_PendingAI_Spawns deleteAt 0;
    _request params ["_triggerPos", "_spawnProbability", "_sectorName"];
    
    private _groupArray = [ "OIA_InfSquad_Weapons", "OIA_InfTeam", "OIA_InfTeam_AT", "OIA_InfTeam_AA", "OI_SniperTeam", "OIA_InfAssault" ];
    
    private _adjustedChance = _spawnProbability * (random 1);
    private _groupsToSpawn = 0;
    if (_adjustedChance > 0.5) then { _groupsToSpawn = 2; } else { _groupsToSpawn = 1; };
    if (_adjustedChance < 0.1) then { _groupsToSpawn = 0; };
    
    if (_groupsToSpawn > 0) then {
        // Find safe position (this is the heavy mathematical operation)
        private _randomPos = [_triggerPos, 500, 1000, 3, 0, 0.2, 0, [], [_triggerPos, _triggerPos]] call BIS_fnc_findSafePos;
        if !(_randomPos isEqualTo [0,0,0]) then {
            for "_i" from 1 to _groupsToSpawn do {
                private _randomGroup = selectRandom _groupArray;
                private _spawnedGroup = [_randomPos, EAST, _randomGroup] call ALIVE_fnc_spawnGroup;
            };
            diag_log format ["A3M SECTOR AI: Queued spawn executed at %1 for %2.", _randomPos, _sectorName];
        };
    };
};