/*
    fn_serverFetchShadowOpsRoster.sqf
    Server-side function to fetch all owned mercenaries that are STOWED and eligible for Shadow Operations.
*/
params ["_client"];

if (!isServer) exitWith {};

private _playerUID = getPlayerUID _client;
private _playerProfile = ["A3M_PROFILE_" + _playerUID, createHashMap, true] call A3M_fnc_dbGetSecure;

private _ownedMercs = _playerProfile getOrDefault ["OwnedMercenaries", []];
private _eligibleRoster = [];

{
    private _mercID = _x;
    private _profile = [format["A3M_MERC_%1", _mercID], createHashMap, true] call A3M_fnc_dbGetSecure;
    
    if (count _profile > 0) then {
        private _isDead = _profile getOrDefault ["IsDead", false];
        private _shadowStatus = _profile getOrDefault ["ShadowOps_Status", "Stowed"]; // Can be "Stowed", "Active", "WIA", "ShadowOps"
        
        if (!_isDead && _shadowStatus == "Stowed") then {
            // Check if they are currently deployed in the game world
            private _isDeployed = false;
            {
                if ((_x getVariable ["arma3mercenaries_aiUnit", ""]) == _mercID) exitWith { _isDeployed = true; };
            } forEach allUnits;
            
            if (!_isDeployed) then {
                private _name = _profile getOrDefault ["Name", "Unknown"];
                private _class = _profile getOrDefault ["Class", "Unknown"];
                
                private _logicalClass = "Rifleman";
                if (["medic", _class] call BIS_fnc_inString) then { _logicalClass = "Medic"; };
                if (["engineer", _class] call BIS_fnc_inString || ["exp", _class] call BIS_fnc_inString) then { _logicalClass = "Engineer"; };
                if (["sniper", _class] call BIS_fnc_inString || ["marksman", _class] call BIS_fnc_inString) then { _logicalClass = "Sniper"; };
                if (["at", _class] call BIS_fnc_inString) then { _logicalClass = "AT Specialist"; };
                if (["aa", _class] call BIS_fnc_inString) then { _logicalClass = "AA Specialist"; };
                if (["mg", _class] call BIS_fnc_inString || ["autorifle", _class] call BIS_fnc_inString) then { _logicalClass = "Machine Gunner"; };
                
                private _kills = _profile getOrDefault ["Kills", 0];
                
                _eligibleRoster pushBack [_mercID, _name, _logicalClass, _kills];
            };
        };
    };
} forEach _ownedMercs;

[_eligibleRoster] remoteExecCall ["A3M_fnc_receiveShadowOpsRoster", _client];
