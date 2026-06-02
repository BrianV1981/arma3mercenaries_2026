/*
    arma3mercenaries_killHandler.sqf
    Author: BrianV1981
    Refactored & Merged: AI Assistant
    Version: Consolidated Logic
*/

diag_log "//________________ arma3mercenaries Consolidated Kill Handler - START ________________";

//======================================================================================
// SECTION 1: REQUIRED FUNCTIONS
//======================================================================================

//------------------------------------------------------
// Client-Side Function: Display Warning HUD (Bottom Center)
//------------------------------------------------------
A3M_fnc_showWarningHUD = {
    // Runs locally on the targeted client
    params ["_message"]; // Expects pre-formatted structured text
    if (isNull player || !hasInterface) exitWith {}; // Basic client checks

    // diag_log format["[A3M WARNING CLI %1] Displaying Warning HUD: %2", player, _message]; // Optional log

    // Display Parameters
    private _posX = 0.5; // Center Horizontal
    private _posY = 0.85; // Bottom Center Area
    private _duration = 6; // How long the warning stays (seconds)
    private _fadeDuration = 0.5; // Fade out time

    // Spawn dynamic text
    [_message, _posX, _posY, _duration, _fadeDuration, -1, 7018] spawn bis_fnc_dynamicText; // Use ID 7018
};


//------------------------------------------------------
// Server-Side Function: Handle Rewards & Penalties
//------------------------------------------------------
A3M_fnc_serverHandleReward = {
    params ["_killed", "_killer", "_instigator", "_killedType", "_instigatorType", "_killedName", "_instigatorName"];
    if (!isServer) exitWith {}; // Run only on server

    // diag_log format ["[A3M SRV REWARD] Received Event: Instigator=%1, Killed=%2", _instigatorName, _killedName]; // Optional log

    try {
        // Validity Check (No Grad Check)
        if (isNull _instigator || isNull _killed || !(_killed isKindOf "CAManBase")) exitWith {};

        // --- GET BASIC INFO ---
        private _sideKiller = getNumber (configFile >> "cfgVehicles" >> typeOf _instigator >> "side");
        private _sideKilled = getNumber (configFile >> "cfgVehicles" >> typeOf _killed >> "side");
        private _factionNameKilled = switch (_sideKilled) do { case 0:{"OPFOR"}; case 1:{"NATO"}; case 2:{"Independent"}; case 3:{"Civilian"}; default {"Unknown"}; };
        private _factionNameKiller = switch (_sideKiller) do { case 0:{"OPFOR"}; case 1:{"NATO"}; case 2:{"Independent"}; case 3:{"Civilian"}; default {"Unknown"}; };
        
        // Calculate distance/weapon for ALL kills (used by HUD and SQLite Tracking)
        private _distance = floor (_instigator distance2D _killed);
        private _weaponDisplayName = "Unknown";
        private _weapon = currentWeapon _instigator;
        if (_weapon != "") then { try { _weaponDisplayName = getText(configFile >> "CfgWeapons" >> _weapon >> "displayName"); } catch {}; };
        if (_killer != _instigator && {!isNull _killer}) then { try { _weaponDisplayName = getText(configFile >> "CfgVehicles" >> typeOf _killer >> "displayName"); } catch {}; };

        // --- ACCESS CBA SETTINGS VIA GLOBAL VARIABLES ---
        private _friendlyFirePenalty = if (isNil "arma3mercenaries_friendlyFirePenalty") then { 10000 } else { arma3mercenaries_friendlyFirePenalty };
        private _friendlyFireCompensation = if (isNil "arma3mercenaries_friendlyFireCompensation") then { 20000 } else { arma3mercenaries_friendlyFireCompensation };
        private _civilianKillPenalty = if (isNil "arma3mercenaries_civilianKillPenalty") then { 10000 } else { arma3mercenaries_civilianKillPenalty };
        private _natoPenaltyIndependent = if (isNil "arma3mercenaries_natoPenaltyIndependent") then { 10000 } else { arma3mercenaries_natoPenaltyIndependent };
        private _deathPenalty = if (isNil "arma3mercenaries_deathPenalty") then { 10000 } else { arma3mercenaries_deathPenalty };
        private _silentHintsEnabled = if (isNil "arma3mercenaries_silentHints") then { true } else { arma3mercenaries_silentHints }; // Used as proxy for dynamic text warnings

        // --- DETERMINE PLAYER STATUS ---
        private _instigatorIsPlayer = isPlayer _instigator;
        private _killedIsPlayer = isPlayer _killed;

        // --- REWARD/PENALTY LOGIC ---

        // ** A. Friendly Fire Penalty **
        if (_instigatorIsPlayer && _sideKiller == _sideKilled && _instigator != _killed && _friendlyFirePenalty > 0) then {
            [_instigator, -_friendlyFirePenalty, true] call grad_moneymenu_fnc_addFunds;
            if (_silentHintsEnabled) then { // Use this setting to enable/disable dynamic text warnings too
                private _message = format [
                    "<t size='0.55' align='center' color='#FF0000' shadow='1'>FRIENDLY FIRE!</t><br/>" +
                    "<t size='0.45' align='center'>Killed %1 (%2). -%3 Bank</t>",
                     _killedName, _factionNameKilled, _friendlyFirePenalty
                ];
                 // diag_log format["[A3M SRV REWARD] Sending FF Penalty HUD to %1", _instigator]; // Optional log
                 [_message] remoteExecCall ["A3M_fnc_showWarningHUD", _instigator];
            };
        };

        // ** B. Friendly Fire Compensation **
        if (_killedIsPlayer && _sideKiller == _sideKilled && _instigator != _killed && _friendlyFireCompensation > 0) then {
            [_killed, _friendlyFireCompensation, true] call grad_moneymenu_fnc_addFunds;
            if (_silentHintsEnabled) then {
                 private _message = format [
                    "<t size='0.55' align='center' color='#FFA500' shadow='1'>COMPENSATION</t><br/>" +
                    "<t size='0.45' align='center'>Killed by FF (%1, %4, %5m). +%2 Bank</t>",
                     _instigatorName, _friendlyFireCompensation, _factionNameKiller, _weaponDisplayName, _distance // Include faction, weapon, dist
                 ];
                 // diag_log format["[A3M SRV REWARD] Sending FF Comp HUD to %1", _killed]; // Optional log
                 [_message] remoteExecCall ["A3M_fnc_showWarningHUD", _killed];
            };
        };

        // ** C. Civilian Kill Penalty **
        if (_instigatorIsPlayer && _sideKilled == 3 && _civilianKillPenalty > 0) then {
            [_instigator, -_civilianKillPenalty, true] call grad_moneymenu_fnc_addFunds;
            if (_silentHintsEnabled) then {
                 private _message = format [
                    "<t size='0.55' align='center' color='#FF0000' shadow='1'>CIVILIAN KILLED!</t><br/>" +
                    "<t size='0.45' align='center'>%1. -%2 Bank</t>",
                     _killedName, _civilianKillPenalty
                 ];
                 // diag_log format["[A3M SRV REWARD] Sending CIV Penalty HUD to %1", _instigator]; // Optional log
                 [_message] remoteExecCall ["A3M_fnc_showWarningHUD", _instigator];
            };
        };

         // ** D. Independent Kill Penalty (NATO Player) **
         if (_instigatorIsPlayer && _sideKilled == 2 && _sideKiller != 0 && _sideKiller != 2 && _natoPenaltyIndependent > 0) then {
             [_instigator, -_natoPenaltyIndependent, true] call grad_moneymenu_fnc_addFunds;
             if (_silentHintsEnabled) then {
                  private _message = format [
                     "<t size='0.55' align='center' color='#FF8C00' shadow='1'>INDEPENDENT KILLED!</t><br/>" + // Dark Orange
                     "<t size='0.45' align='center'>%1. -%2 Bank</t>",
                      _killedName, _natoPenaltyIndependent
                  ];
                  // diag_log format["[A3M REWARDS SRV] Sending INDEP Penalty HUD to %1", _instigator]; // Optional log
                  [_message] remoteExecCall ["A3M_fnc_showWarningHUD", _instigator];
             };
         };


        // ** F. Death Penalty **
        if (_killedIsPlayer && _sideKiller != _sideKilled && _deathPenalty > 0) then {
            [_killed, -_deathPenalty, true] call grad_moneymenu_fnc_addFunds;
            if (_silentHintsEnabled) then {
                 private _message = format [
                    "<t size='0.55' align='center' color='#FF0000' shadow='1'>PENALTY</t><br/>" +
                    "<t size='0.45' align='center'>You Died! -%1 Bank</t>",
                     _deathPenalty
                 ];
                 // diag_log format["[A3M REWARDS SRV] Sending Death Penalty HUD to %1", _killed]; // Optional log
                 [_message] remoteExecCall ["A3M_fnc_showWarningHUD", _killed];
            };
        };

        // --- Other logic (Enemy Kill Rewards, AI Wallet) ---
        if (_instigatorIsPlayer && _sideKiller != _sideKilled && _sideKilled != 3) then {
             // Retrieve reward settings only if needed
             private _opforKillReward = if (isNil "arma3mercenaries_opforKillReward") then { 10000 } else { arma3mercenaries_opforKillReward };
             private _natoKillReward = if (isNil "arma3mercenaries_natoKillReward") then { 10000 } else { arma3mercenaries_natoKillReward };
             private _independentKillReward = if (isNil "arma3mercenaries_independentKillReward") then { 10000 } else { arma3mercenaries_independentKillReward };

            switch (_sideKilled) do {
                case 0: { if (_opforKillReward > 0) then { private _reward = round random _opforKillReward; if (_reward > 0) then { [_instigator, _reward, false] call grad_moneymenu_fnc_addFunds; }; }; }; // OPFOR killed reward
                case 1: { if (_sideKiller == 0 && _natoKillReward > 0) then { private _reward = round random _natoKillReward; if (_reward > 0) then { [_instigator, _reward, false] call grad_moneymenu_fnc_addFunds; }; }; }; // NATO killed by OPFOR reward
                case 2: { if (_sideKiller == 0 && _independentKillReward > 0) then { private _reward = round random _independentKillReward; if (_reward > 0) then { [_instigator, _reward, false] call grad_moneymenu_fnc_addFunds; }; }; }; // INDEP killed by OPFOR reward
            };
        };
        if (!_killedIsPlayer) then {
            // Retrieve AI wallet settings only if needed
             private _opforAiWallet = if (isNil "arma3mercenaries_opforAiWallet") then { 10000 } else { arma3mercenaries_opforAiWallet };
             private _natoAiWallet = if (isNil "arma3mercenaries_natoAiWallet") then { 1000 } else { arma3mercenaries_natoAiWallet };
             private _independentAiWallet = if (isNil "arma3mercenaries_independentAiWallet") then { 1000 } else { arma3mercenaries_independentAiWallet };
             private _civilianAiWallet = if (isNil "arma3mercenaries_civilianAiWallet") then { 1000 } else { arma3mercenaries_civilianAiWallet };
             private _walletAmount = 0;
             switch (_sideKilled) do { case 0:{_walletAmount=round random _opforAiWallet}; case 1:{_walletAmount=round random _natoAiWallet}; case 2:{_walletAmount=round random _independentAiWallet}; case 3:{_walletAmount=round random _civilianAiWallet}; };
             if (_walletAmount > 0 && !isNull _killed) then { [_killed, _walletAmount, false] call grad_moneymenu_fnc_addFunds; };
        };

        // --- A3M DEEP STAT TRACKING (Phase 2) ---
        if (!isNil "A3M_LiveProfiles") then {
            private _killedUID = if (_killedIsPlayer) then { getPlayerUID _killed } else { "" };
            private _instigatorUID = if (_instigatorIsPlayer) then { getPlayerUID _instigator } else { "" };
            
            diag_log format ["[A3M STATS] Checking kill: Instigator UID: '%1', Killed UID: '%2', isSuicide: %3", _instigatorUID, _killedUID, _isSuicide];

            // Check for Suicide
            private _isSuicide = (_killedIsPlayer && _instigatorIsPlayer && _killed == _instigator) || (_killedIsPlayer && isNull _instigator);

            // 1. Process Death
            if (_killedIsPlayer && _killedUID != "") then {
                private _profile = A3M_LiveProfiles getOrDefault [_killedUID, createHashMap];
                if (count _profile > 0) then {
                    _profile set ["Deaths_Total", (_profile getOrDefault ["Deaths_Total", 0]) + 1];
                    if (_isSuicide) then {
                        _profile set ["Suicides", (_profile getOrDefault ["Suicides", 0]) + 1];
                    };
                    
                    private _lastDeaths = _profile getOrDefault ["Last_10_Deaths", []];
                    private _deathPos = getPosATL _killed;
                    private _safePos = [round(_deathPos select 0), round(_deathPos select 1), round(_deathPos select 2)];
                    private _deathEntry = [serverTime, _instigatorName, _weaponDisplayName, _safePos];
                    _lastDeaths insert [0, [_deathEntry]]; // Add to front
                    if (count _lastDeaths > 10) then { _lastDeaths resize 10; };
                    _profile set ["Last_10_Deaths", _lastDeaths];
                    
                    A3M_LiveProfiles set [_killedUID, _profile];
                    ["A3M_PROFILE_" + _killedUID, _profile] call A3M_fnc_dbSetSecure;
                    diag_log format ["[A3M STATS] Saved death for UID %1", _killedUID];
                } else {
                    diag_log format ["[A3M STATS] WARNING: Profile empty for dead UID %1", _killedUID];
                };
            };
            
            // 2. Process Kill
            if (_instigatorIsPlayer && _instigatorUID != "" && !_isSuicide) then {
                private _profile = A3M_LiveProfiles getOrDefault [_instigatorUID, createHashMap];
                if (count _profile > 0) then {
                    if (_sideKiller == _sideKilled) then {
                        _profile set ["TeamKills", (_profile getOrDefault ["TeamKills", 0]) + 1];
                    } else {
                        if (_sideKilled == 3) then { // Civilian
                            _profile set ["CivilianKills", (_profile getOrDefault ["CivilianKills", 0]) + 1];
                        } else {
                            _profile set ["Kills_Total", (_profile getOrDefault ["Kills_Total", 0]) + 1];
                            
                            // Last 10 Kills
                            private _lastKills = _profile getOrDefault ["Last_10_Kills", []];
                            private _killEntry = [serverTime, _killedName, _weaponDisplayName, _distance];
                            _lastKills insert [0, [_killEntry]];
                            if (count _lastKills > 10) then { _lastKills resize 10; };
                            _profile set ["Last_10_Kills", _lastKills];
                            
                            // Top 10 Longest Kills
                            private _topKills = _profile getOrDefault ["Top_10_Longest_Kills", []];
                            _topKills pushBack [_distance, _weaponDisplayName, _killedName];
                            _topKills sort false; // Sort descending
                            if (count _topKills > 10) then { _topKills resize 10; };
                            _profile set ["Top_10_Longest_Kills", _topKills];
                        };
                    };
                    
                    A3M_LiveProfiles set [_instigatorUID, _profile];
                    ["A3M_PROFILE_" + _instigatorUID, _profile] call A3M_fnc_dbSetSecure;
                    diag_log format ["[A3M STATS] Saved kill for UID %1", _instigatorUID];
                } else {
                    diag_log format ["[A3M STATS] WARNING: Profile empty for killer UID %1", _instigatorUID];
                };
            };
        };
        // ----------------------------------------

    } catch {
        diag_log ("[A3M SRV REWARD] ERROR: " + str _exception);
    };
    // diag_log "[A3M SRV REWARD] Finished."; // Optional log
};


//------------------------------------------------------
// Server-Side Function: Create Global Map Marker
//------------------------------------------------------
A3M_fnc_serverCreateMarkerGlobal = {
    // Run only on server
    if (!isServer) exitWith {};

    params ["_name", "_pos", "_shape", "_type", "_color", "_sizeX", "_sizeY", "_text"];

    // diag_log format["[A3M MARKER SRV] Received request: %1", _name]; // Optional log

    // Delete previous marker if it exists globally
    deleteMarker _name;

    // Create the marker globally
    private _marker = createMarker [_name, _pos];
    _marker setMarkerShape _shape;
    _marker setMarkerType _type;
    _marker setMarkerColor _color;
    _marker setMarkerSize [_sizeX, _sizeY];
    _marker setMarkerText _text;

     // diag_log format["[A3M MARKER SRV] Created Global Marker: %1", _name]; // Optional log
};


// --- Compile Functions Before Adding Handler ---
diag_log "[A3M INIT] Compiling functions...";
A3M_fnc_showWarningHUD = compileFinal A3M_fnc_showWarningHUD;
A3M_fnc_serverHandleReward = compileFinal A3M_fnc_serverHandleReward;
A3M_fnc_serverCreateMarkerGlobal = compileFinal A3M_fnc_serverCreateMarkerGlobal;
diag_log "[A3M INIT] Functions compiled.";


//======================================================================================
// SECTION 2: MAIN EVENT HANDLER (Client & Server)
//======================================================================================
diag_log "[A3M INIT] Attempting addMissionEventHandler";

addMissionEventHandler ["entityKilled", {
    params ["_killed", "_killer", "_instigator"];
    if (isNull _instigator) then { _instigator = _killer };

    // --- Exit Checks ---
    if (isNull _instigator || isNull _killed || !(_killed isKindOf "CAManBase")) exitWith {};
    private _killedPos = getPosATL _killed; // Need position early for markers
    if (count _killedPos == 0) exitWith {};

    // --- Gather Info ---
    private _killedType = typeOf _killed;
    private _instigatorType = typeOf _instigator;
    private _killedIsPlayer = isPlayer _killed;
    private _instigatorIsPlayer = isPlayer _instigator;
    private _killedName = if (_killedIsPlayer) then { name _killed } else { getText (configFile >> "CfgVehicles" >> _killedType >> "displayname") };
    private _instigatorName = if (_instigatorIsPlayer) then { name _instigator } else { getText (configFile >> "CfgVehicles" >> _instigatorType >> "displayname") };


    // --- Client-Side Actions (Kill Feed HUD, Sound, Marker Trigger) ---
    if (local _instigator && _instigatorIsPlayer) then { // Only for local player killer
        private _prefix = format["[A3M CLI %1 EH]", player];

        // -- Kill Feed --
        try {
            if ( !(isNil "arma3mercenaries_killFeedEnabled") && {arma3mercenaries_killFeedEnabled} ) then {
                private _killed_Color = (side group _killed call BIS_fnc_sideColor) call BIS_fnc_colorRGBtoHTML;
                private _distance = _instigator distance2D _killed;
                private _weapon = currentWeapon _instigator;
                private _weaponDisplayName = "Unknown";
                 if (_weapon != "") then { try { _weaponDisplayName = getText(configFile >> "CfgWeapons" >> _weapon >> "displayName"); } catch {}; };
                 if (_killer != _instigator && {!isNull _killer} && {_killer isKindOf "LandVehicle" || _killer isKindOf "Air" || _killer isKindOf "Ship"}) then { try { _weaponDisplayName = getText(configFile >> "CfgVehicles" >> typeOf _killer >> "displayName"); } catch {}; };
                private _killFeedDuration = if (isNil "arma3mercenaries_killFeedDuration") then { 5 } else { arma3mercenaries_killFeedDuration };
                private _kill_HUD = format[ "<t size='0.45' align='center' shadow='1'>Killed </t><t size='0.65' align='center' shadow='1' color='%1'>%2 </t><t size='0.45' align='center' shadow='1'>[%3m | %4]</t>", _killed_Color, _killedName, floor _distance, _weaponDisplayName ];
                private _posX = 0.5; private _posY = 0.05; // Top Center
                [_kill_HUD, _posX, _posY, _killFeedDuration, 0.5, -1, 7017] spawn bis_fnc_dynamicText;
                 if ( !(isNil "arma3mercenaries_killNotificationSound") && {arma3mercenaries_killNotificationSound} ) then { playSound "Killfeed_notification"; };
                 // diag_log (_prefix + " Kill Feed Displayed."); // Optional log
            };
        } catch { diag_log (_prefix + " ERROR KF: " + str _exception); };

        // -- Marker Triggering --
        try {
            private _killMarkerEnabled = if (isNil "arma3mercenaries_killMarkerEnabled") then { true } else { arma3mercenaries_killMarkerEnabled };
            private _deathMarkerEnabled = if (isNil "arma3mercenaries_deathMarkerEnabled") then { true } else { arma3mercenaries_deathMarkerEnabled };
            private _globalKillMarkerChat = if (isNil "arma3mercenaries_globalKillMarker") then { false } else { arma3mercenaries_globalKillMarker };
            private _globalDeathMarkerChat = if (isNil "arma3mercenaries_globalDeathMarker") then { false } else { arma3mercenaries_globalDeathMarker };

            if (_killMarkerEnabled || _deathMarkerEnabled || _globalKillMarkerChat || _globalDeathMarkerChat) then {
                // Calculate common marker info only if needed
                private _sideKilled = getNumber (configFile >> "cfgVehicles" >> _killedType >> "side");
                private _sideKiller = getNumber (configFile >> "cfgVehicles" >> _instigatorType >> "side"); // Killer is player here
                private _distanceForMarker = _instigator distance2D _killed;
                private _weaponForMarker = currentWeapon _instigator;
                private _weaponDisplayNameForMarker = "Unknown";
                 if (_weaponForMarker != "") then { try { _weaponDisplayNameForMarker = getText(configFile >> "CfgWeapons" >> _weaponForMarker >> "displayName"); } catch {}; };
                 if (_killer != _instigator && {!isNull _killer}) then { try { _weaponDisplayNameForMarker = getText(configFile >> "CfgVehicles" >> typeOf _killer >> "displayName"); } catch {}; };
                 private _factionNameKilled = switch (_sideKilled) do { case 0:{"O"}; case 1:{"N"}; case 2:{"I"}; case 3:{"C"}; default {"U"}; };
                 private _factionNameKiller = switch (_sideKiller) do { case 0:{"O"}; case 1:{"N"}; case 2:{"I"}; case 3:{"C"}; default {"U"}; };

                // Trigger Kill Marker Server Call
                if (_killMarkerEnabled) then {
                    private _killMarkerSize = if (isNil "arma3mercenaries_killMarkerSize") then { 0.5 } else { arma3mercenaries_killMarkerSize };
                    private _mrkName = format ["%1_LastKill", _instigatorName];
                    private _markerColor = switch (_sideKilled) do { case 0: { "ColorEAST" }; case 1: { "ColorWEST" }; case 2: { "colorIndependent" }; case 3: { "ColorCIV" }; default { "ColorUNKNOWN" }; };
                    private _markerText = format ["%1(%2) killed by %3(%4) [%5|%6m]", _killedName, _factionNameKilled, _instigatorName, _factionNameKiller, _weaponDisplayNameForMarker, floor _distanceForMarker];
                    private _params = [ _mrkName, _killedPos, "ICON", "mil_dot", _markerColor, _killMarkerSize, _killMarkerSize, _markerText ];
                    // diag_log format["%1 Sending Kill Marker RE: %2", _prefix, _params]; // Optional log
                    _params remoteExecCall ["A3M_fnc_serverCreateMarkerGlobal", 2];
                };
                // Trigger Death Marker Server Call
                 if (_killedIsPlayer && _deathMarkerEnabled) then { // Also check if killed was a player
                    private _deathMarkerSize = if (isNil "arma3mercenaries_deathMarkerSize") then { 0.5 } else { arma3mercenaries_deathMarkerSize };
                    private _mrkName = format ["%1_LastDeath", _killedName];
                    private _markerText = format ["%1(%2) killed by %3(%4) [%5|%6m]", _killedName, _factionNameKilled, _instigatorName, _factionNameKiller, _weaponDisplayNameForMarker, floor _distanceForMarker];
                    private _params = [ _mrkName, _killedPos, "ICON", "mil_warning", "ColorRed", _deathMarkerSize, _deathMarkerSize, _markerText ];
                     // diag_log format["%1 Sending Death Marker RE: %2", _prefix, _params]; // Optional log
                    _params remoteExecCall ["A3M_fnc_serverCreateMarkerGlobal", 2];
                 };
                 // Global Chat Notifications (Sent directly from client for simplicity)
                 if (_globalKillMarkerChat && _killMarkerEnabled) then { // Only if kill marker also enabled
                     private _chatMsg = format ["%1 %2 killed by %3 %4 with %5 from %6m", _factionNameKilled, _killedName, _factionNameKiller, _instigatorName, _weaponDisplayNameForMarker, floor _distanceForMarker];
                     [_chatMsg] remoteExec ["systemChat", 0];
                 };
                 if (_globalDeathMarkerChat && _deathMarkerEnabled && _killedIsPlayer) then { // Only if death marker enabled and victim player
                     private _chatMsg = format ["%1 %2 was killed by %3 %4 with %5 from %6m", _factionNameKilled, _killedName, _factionNameKiller, _instigatorName, _weaponDisplayNameForMarker, floor _distanceForMarker];
                     [_chatMsg] remoteExec ["systemChat", 0];
                 };
            };
        } catch { diag_log (_prefix + " ERROR MKR: " + str _exception); };
        // diag_log (_prefix + " Local Instigator END."); // Optional log
    }; // End local _instigator block

    // --- Trigger Server Reward Processing (Always if initial checks passed) ---
    try {
        if (isServer) then {
            private _params = [ _killed, _killer, _instigator, _killedType, _instigatorType, _killedName, _instigatorName ];
            _params call A3M_fnc_serverHandleReward; // Call directly since we are on the server
        };
    } catch { diag_log ("ERROR RWD RE: " + str _exception); };

    // diag_log (_prefix + " END"); // Optional log
}]; // End addMissionEventHandler

diag_log "[A3M INIT] Finished addMissionEventHandler";
diag_log "//________________ arma3mercenaries Consolidated Kill Handler - LOADED ________________";