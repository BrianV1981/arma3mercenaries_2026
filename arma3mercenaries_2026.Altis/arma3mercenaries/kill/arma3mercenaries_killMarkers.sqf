/*
    arma3mercenaries_killMarkers.sqf
    Author: BrianV1981
    Version: v0.004
    Notes: Reinstated Faction Icon colors (ColorEAST, etc.) for Kill Markers. Death markers remain Red. Uses Profile Names.
*/
diag_log "//________________ arma3mercenaries Kill Markers Script v0.004 ________________";

// Define server function globally
A3M_fnc_createMarkerGlobal = {
    // Server-side function remains the same - accepts color string
    if (!isServer) exitWith {};
    params [ ["_name",""], ["_pos",[0,0,0]], ["_shape","ICON"], ["_type","mil_dot"], ["_color","ColorRed"], ["_sizeX",0.5], ["_sizeY",0.5], ["_text",""] ];
    if !(typeName _color isEqualTo "STRING") exitWith { diag_log format["[A3M MARKER SRV v0.004] ERROR: Invalid color type (%1) for marker %2", typeName _color, _name]; };
    try { deleteMarker _name; private _marker = createMarker [_name, _pos]; _marker setMarkerShape _shape; _marker setMarkerType _type; _marker setMarkerColor _color; _marker setMarkerSize [_sizeX, _sizeY]; _marker setMarkerText _text; } catch { diag_log format["[A3M MARKER SRV v0.004] ERROR Creating Marker %1: %2", _name, _exception]; };
};

// Client handler triggers server function
addMissionEventHandler ["entityKilled", {
    params ["_killed", "_killer", "_instigator"];
    if (isNull _killed || !(_killed isKindOf "CAManBase")) exitWith {};
    if (isNull _instigator) then { _instigator = _killed; };

    // --- Determine if this machine should handle marker creation request ---
    private _isKillerLocal = local _instigator && isPlayer _instigator;
    private _isVictimPlayer = isPlayer _killed;
    private _shouldHandleMarker = _isKillerLocal || (_isVictimPlayer);

    if (_shouldHandleMarker) then {
        // --- Gather Info ---
        private _killedName = name _killed;
        private _instigatorName = name _instigator;
        private _killedPos = getPosATL _killed;
        if (count _killedPos == 0) exitWith {};

        private _sideKiller = -1; try { _sideKiller = getNumber (configFile >> "cfgVehicles" >> typeOf _instigator >> "side"); } catch {};
        private _factionNameKiller = switch (_sideKiller) do { case 0:{"OPFOR"}; case 1:{"NATO"}; case 2:{"Independent"}; case 3:{"Civilian"}; default {"Unknown"}; };
        private _distance = 0; try { _distance = _instigator distance2D _killed; } catch {};
        private _weapon = ""; try { _weapon = currentWeapon _instigator; } catch {};
        private _weaponDisplayName = "Unknown"; try { if (_weapon != "") then { _weaponDisplayName = getText(configFile >> "CfgWeapons" >> _weapon >> "displayName"); }; if (_killer != _instigator && {!isNull _killer}) then { _weaponDisplayName = getText(configFile >> "CfgVehicles" >> typeOf _killer >> "displayName"); }; } catch {};
        if (_instigator == _killed) then { _instigatorName = _killedName; _factionNameKiller = switch (_sideKiller) do { case 0:{"OPFOR"}; case 1:{"NATO"}; case 2:{"Independent"}; case 3:{"Civilian"}; default {"Unknown"}; }; _weaponDisplayName = "Gravity/Self"; _distance = 0; };
         if (isNull _killer && _instigator == _killed) then { _instigatorName = _killedName; _factionNameKiller = "Environment/Self"; _weaponDisplayName = "Physics/Self"; _distance = 0; };

        private _killedType = typeOf _killed;
        private _sideKilled = -1; try { _sideKilled = getNumber (configFile >> "cfgVehicles" >> _killedType >> "side"); } catch {};
        private _factionNameKilled = switch (_sideKilled) do { case 0:{"OPFOR"}; case 1:{"NATO"}; case 2:{"Independent"}; case 3:{"Civilian"}; default {"Unknown"}; };

        // --- Get CBA Settings ---
        private _killMarkerEnabled = if (isNil "arma3mercenaries_killMarkerEnabled") then { true } else { arma3mercenaries_killMarkerEnabled };
        private _deathMarkerEnabled = if (isNil "arma3mercenaries_deathMarkerEnabled") then { true } else { arma3mercenaries_deathMarkerEnabled };
        private _globalKillMarkerChat = if (isNil "arma3mercenaries_globalKillMarker") then { false } else { arma3mercenaries_globalKillMarker };
        private _globalDeathMarkerChat = if (isNil "arma3mercenaries_globalDeathMarker") then { false } else { arma3mercenaries_globalDeathMarker };
        private _killMarkerSize = if (isNil "arma3mercenaries_killMarkerSize") then { 0.5 } else { arma3mercenaries_killMarkerSize };
        private _deathMarkerSize = if (isNil "arma3mercenaries_deathMarkerSize") then { 0.5 } else { arma3mercenaries_deathMarkerSize };

        // --- Decide which marker(s) to request from the server ---

        // Request KILL marker only if killer is local player AND setting is enabled
        if (_isKillerLocal && _killMarkerEnabled) then {
            private _mrkName = format ["%1_LastKill", _instigatorName];
            // <<< REVERT TO FACTION COLORS (ColorEAST etc.) FOR KILL MARKER ICONS >>>
            private _markerColor = switch (_sideKilled) do {
                case 0: { "ColorEAST" };        // OPFOR (Verify this is defined in CfgMarkerColors)
                case 1: { "ColorWEST" };        // NATO (Verify this is defined)
                case 2: { "colorIndependent" }; // Independent (Verify this is defined)
                case 3: { "ColorCIV" };         // Civilian (Verify this is defined)
                default { "ColorUNKNOWN" };     // Fallback (Verify this is defined, or use "ColorGrey")
            };
            private _markerText = format ["%1 (%2) killed by %3 (%4) [%5|%6m]", _killedName, _factionNameKilled, _instigatorName, _factionNameKiller, _weaponDisplayName, floor _distance]; // Text remains plain
            private _params = [ _mrkName, _killedPos, "ICON", "mil_dot", _markerColor, _killMarkerSize, _killMarkerSize, _markerText ];
            _params remoteExecCall ["A3M_fnc_createMarkerGlobal", 2];

            // Global Kill Chat
            if (_globalKillMarkerChat) then { /* ... */ };
        };

        // Request DEATH marker only if victim is player AND setting is enabled
        if (_isVictimPlayer && _deathMarkerEnabled) then {
             private _mrkName = format ["%1_LastDeath", _killedName];
             private _markerText = format ["%1 (%2) killed by %3 (%4) [%5|%6m]", _killedName, _factionNameKilled, _instigatorName, _factionNameKiller, _weaponDisplayName, floor _distance]; // Text remains plain
             // <<< DEATH MARKER REMAINS BRIGHT RED >>>
             private _params = [ _mrkName, _killedPos, "ICON", "mil_warning", "ColorRed", _deathMarkerSize, _deathMarkerSize, _markerText ];
             // Trigger only once per death event (check avoids duplicates if killer was local)
             if (!_isKillerLocal || (_isKillerLocal && !_killMarkerEnabled)) then { // Send if killer wasn't local, OR if killer was local but kill markers disabled
                  _params remoteExecCall ["A3M_fnc_createMarkerGlobal", 2];
             } else {
                 // If killer was local AND kill markers are enabled, still create the death marker separately
                  _params remoteExecCall ["A3M_fnc_createMarkerGlobal", 2];
             };


             // Global Death Chat
             if (_globalDeathMarkerChat) then { /* ... */ };
        };
    };
}];

diag_log "//________________ arma3mercenaries Kill Markers Script v0.004 Finished Loading ________________";