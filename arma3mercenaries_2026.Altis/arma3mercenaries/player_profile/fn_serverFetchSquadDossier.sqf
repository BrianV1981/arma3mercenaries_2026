/*
    fn_serverFetchSquadDossier.sqf
    Server-side function to fetch all owned mercenaries.
*/
params ["_client", ["_isBarracks", false]];

if (!isServer) exitWith {};

private _playerUID = getPlayerUID _client;
private _playerProfile = ["A3M_PROFILE_" + _playerUID, createHashMap, true] call A3M_fnc_dbGetSecure;

private _ownedMercs = _playerProfile getOrDefault ["OwnedMercenaries", []];

private _activeSquad = [];
private _graveyard = [];

{
    private _mercID = _x;
    private _profile = [format["A3M_MERC_%1", _mercID], createHashMap, true] call A3M_fnc_dbGetSecure;
    
    if (count _profile > 0) then {
        private _name = _profile getOrDefault ["Name", "Unknown"];
        private _class = _profile getOrDefault ["Class", "Unknown"];
        private _kills = _profile getOrDefault ["Kills", 0];
        private _cash = _profile getOrDefault ["CashCarried", 0];
        private _isDead = _profile getOrDefault ["IsDead", false];
        private _joinDate = _profile getOrDefault ["JoinDate", []];
        
        if (_isDead) then {
            private _cause = _profile getOrDefault ["CauseOfDeath", "Unknown"];
            private _deathDate = _profile getOrDefault ["DeathDate", []];
            _graveyard pushBack [_mercID, _name, _class, _kills, _cash, _cause, _joinDate, _deathDate];
        } else {
            // Check if they are currently spawned in the game (Deployed vs In Barracks)
            private _isDeployed = false;
            {
                if ((_x getVariable ["arma3mercenaries_aiUnit", ""]) == _mercID) exitWith { _isDeployed = true; };
            } forEach allUnits;
            
            _activeSquad pushBack [_mercID, _name, _class, _kills, _cash, _joinDate, _isDeployed];
        };
    };
} forEach _ownedMercs;

[_activeSquad, _graveyard, _isBarracks] remoteExecCall ["A3M_fnc_receiveSquadDossierData", _client];
