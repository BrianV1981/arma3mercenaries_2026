/*
    A3M Contract: CSAR (Combat Search and Rescue)
    Objective: Locate a downed pilot in enemy territory, secure them, and extract them to a safe zone.
    Refactored to ALiVE Virtualization and CBA PFH.
*/
params [["_difficulty", "NORMAL"], ["_customCrashPos", []], ["_crashName", "friendly aircraft"], ["_homePos", []], ["_side", west], ["_prefix", "A3M_CSAR_F1"], ["_xpRewardAmount", 500], ["_rewardAmount", 250000], ["_rewardRadius", 2], ["_pilotAnnouncements", true], ["_callsign", "Pilot"]];

if (!isServer) exitWith {};

// --- 1. Define Faction Metrics Dynamically from CBA ---
private _cbaMarker = missionNamespace getVariable [format ["%1_ExtractionMarker", _prefix], ""];
private _cbaRawPos = missionNamespace getVariable [format ["%1_ExtractionPos", _prefix], ""];
private _enemyFaction = missionNamespace getVariable [format ["%1_QRF_Faction", _prefix], "OPF_F"];
private _qrfSpawnChance = missionNamespace getVariable [format ["%1_QRF_SpawnChance", _prefix], 50];
private _qrfSquadCountMin = missionNamespace getVariable [format ["%1_QRF_SquadCountMin", _prefix], 1];
private _qrfSquadCountMax = missionNamespace getVariable [format ["%1_QRF_SquadCountMax", _prefix], 3];
private _qrfPursuitDelayMin = missionNamespace getVariable [format ["%1_QRF_PursuitDelayMin", _prefix], 5];
private _qrfPursuitDelayMax = missionNamespace getVariable [format ["%1_QRF_PursuitDelayMax", _prefix], 15];
private _debug = missionNamespace getVariable [format ["%1_Debug", _prefix], false];

// The 'Safe TAOR' is the territory the pilot belongs to. We pull this from their native FallbackTaor setting.
private _safeTaorRaw = missionNamespace getVariable [format ["%1_FallbackTaor", _prefix], "blue_taor"];
private _safeTaorMarkers = [_safeTaorRaw]; 

// The 'Enemy TAOR' is where they were shot down. We pull this from their native TargetTaor setting.
private _enemyTaorRaw = missionNamespace getVariable [format ["%1_TargetTaor", _prefix], "red_taor_1"];
private _enemyTaorMarkers = [_enemyTaorRaw];

private _reward = _rewardAmount;
private _xpReward = _xpRewardAmount;

// --- 2. Select Crash Site Location ---
private _crashPos = [];
if (_customCrashPos isNotEqualTo []) then {
    _crashPos = _customCrashPos;
} else {
    private _selectedTaor = selectRandom _enemyTaorMarkers;
    if (getMarkerColor _selectedTaor == "") exitWith {
        private _msg = format ["A3M FATAL ERROR: Contract aborted. TAOR marker '%1' does not exist on the map!", _selectedTaor];
        diag_log _msg;
        _msg remoteExec ["systemChat", 0];
    };
    private _randomTaorPos = _selectedTaor call BIS_fnc_randomPosTrigger;
    _crashPos = [_randomTaorPos, 1, 300, 15, 0, 0.2, 0] call BIS_fnc_findSafePos;
};

// --- 3. Establish Extraction Coordinates (The Hierarchy) ---
private _fobPos = [];

// Absolute 1st Priority: The CBA Explicit Coordinate Array
if (_cbaRawPos != "") then {
    // Failsafe: If the user forgot to include array brackets (e.g., "1234, 5678, 0")
    if ((_cbaRawPos find "[") == -1) then {
        _cbaRawPos = format ["[%1]", _cbaRawPos];
    };
    
    try {
        private _parsed = parseSimpleArray _cbaRawPos;
        if (_parsed isEqualType [] && {count _parsed >= 2}) then {
            _fobPos = _parsed;
        };
    } catch { diag_log format ["[A3M CSAR ERROR] Invalid coordinates in CBA ExtractionPos: %1", _cbaRawPos]; };
};

// 2nd Priority: The CBA Options Explicit Marker
if (_fobPos isEqualTo [] && {_cbaMarker != ""} && {getMarkerColor _cbaMarker != ""}) then {
    _fobPos = getMarkerPos _cbaMarker;
};

// 2nd Priority: The Aircraft's Origin Home Base (provided it did not spawn dynamically mid-air)
if (_fobPos isEqualTo [] && {_homePos isNotEqualTo []}) then {
    if (count _homePos >= 3) then {
        // Only use the origin if it was a ground spawn (Z axis < 50m)
        if ((_homePos select 2) < 50) then {
            _fobPos = _homePos;
            _fobPos set [2, 0]; // Flatten it to the ground
        };
    };
};

// 3rd Priority: The default Safe Zone TAOR (Dynamically Generated)
if (_fobPos isEqualTo []) then {
    private _safeTaor = selectRandom _safeTaorMarkers;
    if (getMarkerColor _safeTaor == "") exitWith {
        private _msg = format ["A3M FATAL ERROR: Contract aborted. Safe Zone marker '%1' does not exist on the map!", _safeTaor];
        diag_log _msg;
        _msg remoteExec ["systemChat", 0];
    };
    private _safePos = _safeTaor call BIS_fnc_randomPosTrigger;
    _fobPos = [_safePos, 1, 1000, 10, 0, 0.1, 0] call BIS_fnc_findSafePos;
};

private _taskID = format ["contract_csar_%1_%2", floor(diag_tickTime * 10), floor(random 99999)];

// Create visible Extraction Marker
private _extMarkerName = format ["ext_mrk_%1", floor(random 99999)];
private _extMarker = createMarker [_extMarkerName, _fobPos];
_extMarker setMarkerType "hd_pickup";
_extMarker setMarkerColor "ColorBlue";
_extMarker setMarkerText " CSAR Extraction Zone";

private _nearestTown = text (nearestLocations [_crashPos, ["NameCityCapital", "NameCity", "NameVillage"], 3000] select 0);

// --- 4. Spawn Crash Site (Statics) ---
// The actual aircraft wreck is now handled dynamically by the organic loop!
private _campFire = createVehicle ["Campfire_burning_F", _crashPos getPos [5 + random 10, random 360], [], 0, "CAN_COLLIDE"];
private _sleepingBag = createVehicle ["Land_Sleeping_bag_F", getPos _campFire getPos [2, random 360], [], 0, "CAN_COLLIDE"];

// Add an IR strobe for night ops natively
private _irStrobe = "NVG_TargetW" createVehicle (getPos _campFire);

// --- 5. Spawn Physical Pilot (Zero FPS Cost via AI Disable) ---
private _pilotGroup = createGroup [west, true];
private _pilot = _pilotGroup createUnit ["B_Helipilot_F", getPos _campFire getPos [2, random 360], [], 0, "NONE"];

// CRITICAL: Pilot remains physical so he doesn't despawn and float above the campfire!
_pilot setCaptive true;
removeAllWeapons _pilot;
_pilot addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator", "_useEffects"];
    private _trueKiller = if (isNull _instigator) then { _killer } else { _instigator };
    
    _unit setVariable ["A3M_TrueKiller", _trueKiller];
    
    if (isPlayer _trueKiller) then {
        if (side _trueKiller == west || side _trueKiller == independent) then {
            // Player friendly fired the rescue target!
            [_trueKiller, -25000, true] remoteExecCall ["grad_moneymenu_fnc_addFunds", _trueKiller];
            
            // Failsafe execution warning
            private _message = "<t align='left'><t size='0.8' color='#FF0000'>COURT MARTIAL</t><br/><t size='0.6' color='#FFFFFF'>You executed the rescue target! Command has fined you heavily.</t></t>";
            [_message] remoteExecCall ["A3M_fnc_showWarningHUD", _trueKiller];
        } else {
            if (side _trueKiller == east) then {
                _trueKiller addScore 1000;
                [_trueKiller, 500000] remoteExecCall ["grad_moneymenu_fnc_addFunds", _trueKiller];
                [250, 0] remoteExecCall ["HG_fnc_addOrSubXP", _trueKiller, false];
                private _a3mMessage = "<t align='left'><t size='0.8' color='#00FF00'>HVT ELIMINATED</t><br/><t size='0.6' color='#FFFFFF'>Target neutralized. Good kill.<br/><br/>+$500,000<br/>+250 XP</t></t>";
                [_a3mMessage, 0.0, 0.1, 10, 1, 0, 799] remoteExec ["BIS_fnc_dynamicText", _trueKiller];
            };
        };
    };
}];
(group _pilot) setVariable ["Vcm_Disable", true, true];
_pilot setVariable ["ALiVE_profile_ignore", true, true];
_pilot setVariable ["ALiVE_disableDynamicSimulation", true, true];
{ _pilot disableAI _x } forEach ["MOVE", "FSM", "TARGET", "AUTOTARGET"];

if (isClass (configFile >> "CfgPatches" >> "ace_medical")) then {
    [_pilot, 0.5, "body", "punch"] call ace_medical_fnc_addDamageToUnit;
} else {
    _pilot setDamage 0.5;
};

[_pilot, "Acts_InjuredLyingRifle01"] remoteExec ["switchMove", 0, true];

// Create ACE Interact to 'Rescue' the pilot
[
    _pilot, 
    'Rescue Pilot', 
    '\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa',
    '\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa',
    '_this distance _target < 3 && !(_target getVariable [''A3M_Rescued'', false])', 
    '_caller distance _target < 3', 
    {}, 
    {}, 
    {
        params ['_target', '_caller', '_actionId', '_arguments'];
        _arguments params ['_fobPos', '_taskID', '_pilotAnnouncements', '_callsign'];
        _target setCaptive false;
        _target setUnitPos 'AUTO';
        { _target enableAI _x } forEach ['MOVE', 'FSM', 'TARGET', 'AUTOTARGET'];
        [_target, ""] remoteExec ["switchMove", 0, true];
        [_target, "AmovPercMstpSnonWnonDnon"] remoteExec ["playMoveNow", 0, true];
        [_target] joinSilent (group _caller);
        
        if (_pilotAnnouncements) then {
            private _chatMsg = format ["This is %1 actual. Good to see you. Let's move to extraction.", _callsign];
            [[_target, _chatMsg], { (_this select 0) sideChat (_this select 1); }] remoteExec ["call", 0];
        };
        
        private _msg = format ["<t color='#FF8C00' size='1.2'>RESCUE</t><br/><t size='0.8' color='#FFFFFF'>You have rescued %1! Escort him to the extraction zone.</t>", name _target];
        [_msg, -1, 0.8, 5, 0.5, 0, 789] remoteExec ["BIS_fnc_dynamicText", side (group _caller)];
        _target setVariable ['A3M_Rescued', true, true];
        
        // Update the Task Destination natively to point to the Extraction FOB
        [_taskID, _fobPos] remoteExec ["BIS_fnc_taskSetDestination", 0, true];
    },
    {},
    [_fobPos, _taskID, _pilotAnnouncements, _callsign],
    3,
    10,
    true,
    false
] remoteExec ['BIS_fnc_holdActionAdd', 0, _pilot];


// --- 6. Create Task ---
private _taskSide = west;

private _fuzzyLocation = [
    (_crashPos select 0) + (random 400) - 200,
    (_crashPos select 1) + (random 400) - 200,
    0
];

private _selectedDescription = [
    format ["Callsign '%1' went down in a %2 in OPFOR territory near <t color='#ffff00'>%3</t>. Satellite recon lost the feed, but we are picking up an IR strobe in the woods.<br/><br/>Locate the smoking wreck, heal %1, and escort him to the blue Extraction Zone marked on your map before the enemy QRF arrives.<br/><br/><t color='#00ff00'>Payout: %4 Cr / +%5 XP</t>", _callsign, _crashName, _nearestTown, _reward, _xpReward],
    format ["CSAR: %1", _callsign],
    format ["CSAR: %1", _callsign]
];

[
    [_taskSide, independent],
    _taskID,
    _selectedDescription,
    _fuzzyLocation,
    "ASSIGNED",
    1,
    true,
    "search",
    true
] call BIS_fnc_taskCreate;

private _opforTaskID = _taskID + "_OPFOR";
[
    east,
    _opforTaskID,
    [
        format ["A BLUFOR pilot, callsign '%1', has been shot down. Capture the injured pilot and extract him for interrogation before BLUFOR can rescue him. <br/><br/><t color='#00ff00'>Payout: 500,000 Cr</t>", _callsign],
        format ["Capture: %1", _callsign],
        format ["Capture: %1", _callsign]
    ],
    _fuzzyLocation,
    "ASSIGNED",
    1,
    true,
    "interact",
    true
] call BIS_fnc_taskCreate;

if (!isNil "A3M_ActiveTasks") then {
    A3M_ActiveTasks set [_taskID, [_pilot, _fuzzyLocation, "CSAR"]];
    A3M_ActiveTasks set [_opforTaskID, [_pilot, _fuzzyLocation, "CSAR"]];
    publicVariable "A3M_ActiveTasks";
};



// --- 6.5 Native Arma 3 Extraction Trigger (Restored from 0355) ---
private _extTrigger = createTrigger ["EmptyDetector", _fobPos, false]; // Server-side only trigger
_extTrigger setTriggerArea [0, 0, 0, false];
_extTrigger setTriggerActivation ["NONE", "PRESENT", false];
_extTrigger setVariable ["A3M_CSAR_Pilot", _pilot];
_extTrigger setVariable ["A3M_CSAR_TaskID", _taskID];
_extTrigger setVariable ["A3M_CSAR_Reward", _reward];
_extTrigger setVariable ["A3M_CSAR_XPReward", _xpReward];
_extTrigger setVariable ["A3M_CSAR_RewardRadius", _rewardRadius];

_extTrigger setTriggerStatements [
    "alive (thisTrigger getVariable ['A3M_CSAR_Pilot', objNull]) && {((thisTrigger getVariable ['A3M_CSAR_Pilot', objNull]) distance2D thisTrigger) < 200}",
    "
        private _pilot = thisTrigger getVariable 'A3M_CSAR_Pilot';
        private _taskID = thisTrigger getVariable 'A3M_CSAR_TaskID';
        private _opforTaskID = _taskID + '_OPFOR';
        private _reward = thisTrigger getVariable 'A3M_CSAR_Reward';
        private _xpReward = thisTrigger getVariable 'A3M_CSAR_XPReward';
        private _rewardRadius = thisTrigger getVariable 'A3M_CSAR_RewardRadius';
        
        [_taskID, 'SUCCEEDED', true] call BIS_fnc_taskSetState;
        [_opforTaskID, 'FAILED', true] call BIS_fnc_taskSetState;
        
        if (!isNil 'A3M_ActiveTasks') then { 
            A3M_ActiveTasks deleteAt _taskID; 
            A3M_ActiveTasks deleteAt _opforTaskID; 
            publicVariable 'A3M_ActiveTasks'; 
        };
        
        {
            if (isPlayer _x && {alive _x}) then {
                private _giveReward = false;
                
                if (_rewardRadius == 0) then { _giveReward = true; };
                if (_rewardRadius == 1 && {side (group _x) == side (group _pilot)}) then { _giveReward = true; };
                if (_rewardRadius == 2 && {_x distance2D thisTrigger <= 300}) then { _giveReward = true; };
                
                if (_giveReward) then {
                    [_x, _reward] remoteExecCall ['grad_moneymenu_fnc_addFunds', _x];
                    [_xpReward, 0] remoteExecCall ['HG_fnc_addOrSubXP', _x, false];
                    
                    private _formattedHours = format [""%1"", date select 3];
                    if (date select 3 < 10) then { _formattedHours = format [""0%1"", date select 3]; };
                    private _formattedMinutes = format [""%1"", date select 4];
                    if (date select 4 < 10) then { _formattedMinutes = format [""0%1"", date select 4]; };
                    
                    private _msg = format [""<t color='#00FF00' size='1.2'>OPERATION SUCCESS</t><br/><t size='0.8' color='#FFFFFF'>Exemplary work! CSAR package secured.<br/>Time Extracted: %1:%2<br/>Payment: %3 Cr (+%4 XP)</t>"", _formattedHours, _formattedMinutes, _reward, _xpReward];
                    [_msg, 0.9, 0.9, 15, 1, 0, 789] remoteExec [""BIS_fnc_dynamicText"", _x];
                };
            };
        } forEach playableUnits;
        
        diag_log format ['[A3M TASK MANAGER] CSAR Task %1 SUCCEEDED via Native Trigger.', _taskID];
        
        [_pilot] remoteExecCall ['unassignVehicle', _pilot];
        [_pilot] remoteExecCall ['moveOut', _pilot];
        
        private _dummyGrp = createGroup [west, true];
        [[_pilot], _dummyGrp] remoteExecCall ['joinSilent', _pilot];
        
        [ { if (!isNull (_this select 0)) then { deleteVehicle (_this select 0); }; }, [_pilot], 5 ] call CBA_fnc_waitAndExecute;

        deleteMarker _extMarkerName;
        deleteVehicle thisTrigger;
    ",
    ""
];

// --- 7. CBA PFH Task Tracker ---
private _qrfTriggered = false;
private _qrfActivationTime = time + (_qrfPursuitDelayMin * 60) + random ((_qrfPursuitDelayMax - _qrfPursuitDelayMin) * 60);
private _expiryMin = missionNamespace getVariable ["A3M_CSAR_ExpiryMin", 2];
private _expiryMax = missionNamespace getVariable ["A3M_CSAR_ExpiryMax", 4];
private _expiryTime = time + (_expiryMin * 3600) + random ((_expiryMax - _expiryMin) * 3600);

[{
    params ["_args", "_handle"];
    _args params ["_taskID", "_pilot", "_fobPos", "_reward", "_qrfTriggered", "_difficulty", "_enemyFaction", "_extMarkerName", "_expiryTime", "_qrfSpawnChance", "_qrfSquadCountMin", "_qrfSquadCountMax", "_debug", "_qrfActivationTime", "_prefix"];

    private _opforTaskID = _taskID + "_OPFOR";

    // 0. Task State Check
    private _taskState = [_taskID] call BIS_fnc_taskState;
    if (_taskState == "SUCCEEDED" || _taskState == "CANCELED" || _taskState == "FAILED") exitWith {
        if (!isNil "A3M_ActiveTasks") then { A3M_ActiveTasks deleteAt _taskID; A3M_ActiveTasks deleteAt _opforTaskID; publicVariable "A3M_ActiveTasks"; };
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
    
    if (!alive _pilot) exitWith {
        private _trueKiller = _pilot getVariable ["A3M_TrueKiller", objNull];
        
        [_taskID, 'FAILED', true] call BIS_fnc_taskSetState;
        
        if (!isNull _trueKiller && {side _trueKiller == east}) then {
            [_opforTaskID, 'SUCCEEDED', true] call BIS_fnc_taskSetState;
        } else {
            [_opforTaskID, 'FAILED', true] call BIS_fnc_taskSetState;
        };
        
        if (!isNil "A3M_ActiveTasks") then { A3M_ActiveTasks deleteAt _taskID; A3M_ActiveTasks deleteAt _opforTaskID; publicVariable "A3M_ActiveTasks"; };
        diag_log format ['[A3M TASK MANAGER] CSAR Task %1 FAILED (Pilot KIA).', _taskID];
        deleteMarker _extMarkerName;
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
    
    // Auto-Evac Expiry Check
    if (time > _expiryTime && !(_pilot getVariable ["A3M_Rescued", false])) exitWith {
        [_taskID, 'FAILED', true] call BIS_fnc_taskSetState;
        [_opforTaskID, 'FAILED', true] call BIS_fnc_taskSetState;
        if (!isNil "A3M_ActiveTasks") then { A3M_ActiveTasks deleteAt _taskID; A3M_ActiveTasks deleteAt _opforTaskID; publicVariable "A3M_ActiveTasks"; };
        diag_log format ['[A3M TASK MANAGER] CSAR Task %1 FAILED (Time Expired, Pilot succumbed to wounds).', _taskID];
        deleteMarker _extMarkerName;
        _pilot setDamage 1; 
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    // QRF Trigger
    if (!(_pilot getVariable ["A3M_QRF_Triggered", false])) then {
        // A3M DEBUG FIX: Re-evaluate variables natively in the loop so live CBA overrides actually work!
        private _liveSpawnChance = missionNamespace getVariable [format ["%1_QRF_SpawnChance", _prefix], _qrfSpawnChance];
        
        // If the user forced PursuitDelay to 0 dynamically, override the timer!
        private _liveDelay = missionNamespace getVariable [format ["%1_QRF_PursuitDelayMin", _prefix], -1];
        if (_liveDelay == 0) then { _qrfActivationTime = 0; };
        
        if (time > _qrfActivationTime) then {
            _pilot setVariable ["A3M_QRF_Triggered", true, true];
            
            ["Enemy forces have deployed a recovery team to search the crash site. They are attempting to capture the downed pilot and secure the intel. Protect the pilot!"] remoteExec ["A3M_fnc_logInfo", _taskSide];
            ["Enemy forces have deployed a recovery team to search the crash site. They are attempting to capture the downed pilot and secure the intel. Protect the pilot!"] remoteExec ["A3M_fnc_logInfo", independent];
            
            ["Command has deployed an AI QRF recovery team to your sector to capture the downed pilot. Secure the area and assist them!"] remoteExec ["A3M_fnc_logInfo", east];
            
            if (random 100 <= _liveSpawnChance) then {
                private _liveSquadMin = missionNamespace getVariable [format ["%1_QRF_SquadCountMin", _prefix], _qrfSquadCountMin];
                private _liveSquadMax = missionNamespace getVariable [format ["%1_QRF_SquadCountMax", _prefix], _qrfSquadCountMax];
                private _squadCount = _liveSquadMin + floor(random (_liveSquadMax - _liveSquadMin + 1));
                for "_i" from 1 to _squadCount do {
                    // Force true 360-degree randomness by picking a distinct compass bearing for every squad
                    private _spawnDir = random 360;
                    private _spawnDist = 400 + random 400; // Between 400m and 800m away
                    private _pilotPos = getPos _pilot;
                    
                    private _projectedX = (_pilotPos select 0) + (sin _spawnDir * _spawnDist);
                    private _projectedY = (_pilotPos select 1) + (cos _spawnDir * _spawnDist);
                    private _projectedPos = [_projectedX, _projectedY, 0];
                    
                    // Find a safe spot near our explicitly projected 360-degree coordinate
                    private _qrfSpawnPos = [_projectedPos, 1, 150, 5, 0, 0.2, 0] call BIS_fnc_findSafePos;
                    
                    if (count _qrfSpawnPos > 0) then {
                        diag_log format ["[A3M QRF TEST] Loop activated! Spawning QRF squad instantly at %1", _qrfSpawnPos];
                        
                        private _cfgSide = "East";
                        switch (_enemyFaction) do {
                            case "OPF_F";
                            case "OPF_G_F": { _cfgSide = "East"; };
                            case "BLU_F";
                            case "BLU_G_F": { _cfgSide = "West"; };
                            case "IND_F": { _cfgSide = "Indep"; };
                        };
                        
                        // A3M: Robust hardcoded QRF arrays to guarantee valid spawns and provide unit variety (inspired by Sector Control)
                        private _validGroups = [];
                        switch (_enemyFaction) do {
                            case "OPF_F": {
                                _validGroups = [
                                    "OIA_InfSquad",         // Basic CSAT Squad
                                    "OI_ViperTeam",         // CSAT Viper SpecOps
                                    "OIA_InfTeam_AT",       // CSAT Anti-Tank
                                    "OIA_InfTeam_AA",       // CSAT Anti-Air
                                    "OIA_ReconSquad"        // CSAT Recon
                                ];
                            };
                            case "OPF_G_F": {
                                _validGroups = [
                                    "O_G_InfSquad_Team",
                                    "O_G_InfTeam_AT",
                                    "O_G_InfTeam_Light",
                                    "O_G_InfTeam_Sniper"
                                ];
                            };
                            case "BLU_F": {
                                _validGroups = [
                                    "BUS_InfSquad",         // Basic NATO Squad
                                    "BUS_ReconSquad",       // NATO Recon
                                    "BUS_InfTeam_AT",       // NATO Anti-Tank
                                    "BUS_InfTeam_AA",       // NATO Anti-Air
                                    "BUS_SniperTeam"        // NATO Snipers
                                ];
                            };
                            case "IND_F": {
                                _validGroups = [
                                    "HAF_InfSquad",         // Basic AAF Squad
                                    "HAF_InfTeam_AT",       // AAF Anti-Tank
                                    "HAF_InfTeam_AA",       // AAF Anti-Air
                                    "HAF_ReconSquad"        // AAF Recon
                                ];
                            };
                            default {
                                // Extreme Failsafe for unmapped modded factions
                                _validGroups = ["OIA_InfSquad"];
                            };
                        };
                        
                        private _guardGroupConfig = selectRandom _validGroups;
                        
                        diag_log format ["[A3M QRF DEBUG] Handing off to Operator's Sector Control ALIVE_spawnProfileGroup: Faction: %1 | Group: %2 | Pos: %3", _enemyFaction, _guardGroupConfig, _qrfSpawnPos];
                        
                        // Fallback to the Operator's proven logic
                        // MUST be spawned in a scheduled thread because fnc_spawnProfileGroup.sqf contains a 'waitUntil' which crashes unscheduled PFHs
                        [_qrfSpawnPos, _pilot, _guardGroupConfig, _enemyFaction, _prefix] spawn {
                            params ["_qrfSpawnPos", "_pilot", "_guardGroupConfig", "_enemyFaction", "_prefix"];
                            
                            private _qrfProfiles = [_qrfSpawnPos, false, getPos _pilot, _guardGroupConfig, _enemyFaction] call ALIVE_spawnProfileGroup;
                            
                            // Live evaluation of debug toggle
                            private _liveDebug = missionNamespace getVariable [format ["%1_Debug", _prefix], false];
                            
                            // Re-apply debug markers using the returned profiles
                            if (_liveDebug && !isNil "_qrfProfiles" && {count _qrfProfiles > 0}) then {
                                private _firstProfile = _qrfProfiles select 0;
                                [_firstProfile, _enemyFaction] spawn {
                                    params ["_profile", "_enemyFaction"];
                                    private _profileID = [_profile, "profileID"] call ALIVE_fnc_profileEntity;
                                    private _markerName = format ["A3M_QRF_DEBUG_%1", floor(random 999999)];
                                    private _marker = createMarker [_markerName, [0,0,0]];
                                    _marker setMarkerType "o_inf";
                                    if (_enemyFaction == "OPF_F" || _enemyFaction == "OPF_G_F") then { _marker setMarkerColor "ColorOPFOR"; } else { _marker setMarkerColor "ColorBLUFOR"; };
                                    _marker setMarkerText format ["QRF Squad [%1]", _profileID];
                                    
                                    while {true} do {
                                        sleep 2;
                                        // ALIVE_fnc_profileEntity requires the profile array, not the string ID!
                                        private _pos = [_profile, "position"] call ALIVE_fnc_profileEntity;
                                        if (isNil "_pos" || {_pos isEqualTo []} || {_pos isEqualTo [0,0,0]}) exitWith {};
                                        _marker setMarkerPos _pos;
                                    };
                                    deleteMarker _marker;
                                };
                            };
                        };
                    };
                };
                private _msg = "<t color='#FF0000' size='1.2'>CSAR COMMAND</t><br/><t size='0.8' color='#FFFFFF'>Warning: Enemy forces have mobilized to hunt the pilot. Extract immediately!</t>";
                [_msg, -1, 0.8, 5, 0.5, 0, 789] remoteExec ["BIS_fnc_dynamicText", 0];
            };
        };
    };
}, 5, [_taskID, _pilot, _fobPos, _reward, _qrfTriggered, _difficulty, _enemyFaction, _extMarkerName, _expiryTime, _qrfSpawnChance, _qrfSquadCountMin, _qrfSquadCountMax, _debug, _qrfActivationTime, _prefix]] call CBA_fnc_addPerFrameHandler;

_taskID;
