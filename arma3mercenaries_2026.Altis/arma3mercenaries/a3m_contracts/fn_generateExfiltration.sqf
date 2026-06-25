/*
    arma3mercenaries\a3m_contracts\fn_generateExfiltration.sqf
    Description: Generates a custom Informant Exfiltration Contract using ALiVE for world-building,
    ALiVE Virtualization (0 FPS cost), and CBA PFH state tracking.
*/
if (!isServer) exitWith {};

// Ensure BIS functions are initialized
waitUntil {!(isNil "BIS_fnc_init")};

private _taskID = format ["contract_exfil_%1_%2", floor(diag_tickTime * 10), floor(random 99999)];
private _taskSide = west;
private _taskFaction = "BLU_F"; 
private _taskEnemyFaction = "OPF_F"; 

// --- 1. Find a valid location within the OPFOR TAOR ---
private _enemyTaorMarkers = ["red_taor_1", "red_taor_2", "red_taor_3", "red_taor_4", "red_taor_5"]; 
private _selectedTaor = selectRandom _enemyTaorMarkers;

// Pick a random coordinate STRICTLY INSIDE the geometry of the chosen TAOR marker
if (getMarkerColor _selectedTaor == "") exitWith {
    private _msg = format ["A3M FATAL ERROR: Contract aborted. TAOR marker '%1' does not exist on the map!", _selectedTaor];
    diag_log _msg;
    _msg remoteExec ["systemChat", 0];
};
private _randomTaorPos = _selectedTaor call BIS_fnc_randomPosTrigger;

// Find a flat, safe spot within 300 meters of that exact point inside the TAOR
private _taskLocation = [_randomTaorPos, 1, 300, 5, 0, 0.1, 0] call BIS_fnc_findSafePos;

if (_taskLocation isEqualTo []) then {
    _taskLocation = _randomTaorPos; // Fallback
};

// Spawn a small ALiVE composition to give the informant a place to hide
private _compResult = [_taskLocation, "Civilian", "settlements", "CIV_F", "Small", 0] call ALIVE_fnc_spawnRandomPopulatedComposition;

if (isNil "_compResult" || {!_compResult}) then {
    diag_log "[A3M Contracts] ALiVE composition failed to spawn, using raw safe pos.";
};

// --- 2. Spawn the Informant (VIP) ---
private _vipGroup = createGroup [civilian, true];
private _civClasses = ["C_man_p_beggar_F", "C_man_1", "C_Orestes", "C_Nikos", "C_man_p_fugitive_F"];
private _vip = _vipGroup createUnit [selectRandom _civClasses, _taskLocation, [], 0, "NONE"];

// --- VIRTUALIZE THE VIP IMMEDIATELY ---
private _vipProfileEntity = ["ADD", [_vip]] call ALIVE_fnc_createProfilesFromUnits;
private _vipProfileID = [_vipProfileEntity, "profileID"] call ALIVE_fnc_profileEntity;

// Ensure every time the VIP physically spawns (when players get close), the behavior, event handlers, and Hold Actions are reapplied!
private _onSpawnCode = format [
"
    _this setVariable ['taskID', '%1', true];
    _this setVariable ['VCOM_NOAI', true, true];
    removeAllWeapons _this;
    _this disableAI 'AUTOTARGET';
    _this disableAI 'TARGET';
    _this setCaptive true;
    _this setBehaviour 'CARELESS';
    _this setVariable ['A3M_isInformant', true, true];
    _this setVariable ['A3M_isSecured', false, true];
    _this setVariable ['A3M_originPos', getPosATL _this, true];
    _this setVariable ['A3M_isPanicking', false, true];
    
    // Panic Flee Logic (CBA Instead of native spawn)
    _this addEventHandler ['FiredNear', {
        params ['_unit', '_shooter', '_distance', '_weapon', '_muzzle', '_mode', '_ammo', '_gunner'];
        if !(_unit getVariable ['A3M_isPanicking', false]) then {
            _unit setVariable ['A3M_isPanicking', true, true];
            _unit setUnitPos 'MIDDLE';
            _unit setBehaviour 'COMBAT';
            ['A3M WARNING', 'The Informant is panicking and fleeing! Keep track of him!'] remoteExec ['BIS_fnc_showSubtitle', 0];
            
            private _fleePos = [getPosATL _unit, 10, 50, 1, 0, 0.25, 0] call BIS_fnc_findSafePos;
            if !(_fleePos isEqualTo []) then { [_unit, _fleePos] remoteExec ['doMove', _unit]; };
            
            [ {
                params ['_u'];
                if (alive _u) then {
                    _u setUnitPos 'AUTO';
                    _u setBehaviour 'CARELESS';
                    _u setVariable ['A3M_isPanicking', false, true];
                    if (_u getVariable ['A3M_isSecured', false]) then {
                        [_u, getPosATL (leader group _u)] remoteExec ['doMove', _u];
                    } else {
                        private _origin = _u getVariable ['A3M_originPos', getPosATL _u];
                        [_u, _origin] remoteExec ['doMove', _u];
                    };
                };
            }, [_unit], 30] call CBA_fnc_waitAndExecute;
        };
    }];
    
    // Secure Informant Hold Action (Broadcast to all clients)
    [
        _this,
        'Secure Informant',
        '\a3\missions_f_oldman\data\img\holdactions\holdAction_follow_start_ca.paa',
        '\a3\missions_f_oldman\data\img\holdactions\holdAction_follow_start_ca.paa',
        '_this distance2D _target < 4 && !(_target getVariable [''A3M_isSecured'', false])',
        '_caller distance2D _target < 4',
        {},
        {},
        {
            params ['_target', '_caller'];
            _target setVariable ['A3M_isSecured', true, true];
            [_target] joinSilent (group _caller);
            
            // CRITICAL: Prevent ALiVE from de-spawning the VIP now that he is joining the player's group
            _target setVariable ['ALIVE_profileIgnore', true, true];
            
            ['Task Update', format ['%1 secured the informant. Get him to the extraction point!', name _caller]] remoteExec ['BIS_fnc_showSubtitle', side (group _caller)];
        },
        {},
        [],
        4,
        10,
        true,
        false
    ] remoteExec ['BIS_fnc_holdActionAdd', 0, _this];
", _taskID];

[_vipProfileEntity, "onEachSpawn", _onSpawnCode] call ALIVE_fnc_profileEntity;

// --- 4. Define the Extraction Point ---
private _extractionPoint = getMarkerPos "respawn_west";
if (_extractionPoint isEqualTo [0,0,0]) then { _extractionPoint = _taskLocation; }; // Failsafe

// --- 5. Create the Task ---
private _fuzzyLocation = _taskLocation getPos [100 + random 100, random 360];

[
    [_taskSide, independent],
    _taskID,
    [
        format ["We have a defector trapped in a civilian settlement near grid %1. Find him, secure him, and bring him back to base alive. Payment upon successful extraction.", mapGridPosition _taskLocation],
        "Contract: Informant Exfiltration",
        "Extract_Marker"
    ],
    _fuzzyLocation,
    "ASSIGNED",
    1,
    true,
    "meet",
    true
] call BIS_fnc_taskCreate;

if (isNil "A3M_ActiveContracts") then { A3M_ActiveContracts = [] call ALiVE_fnc_hashCreate; };
[A3M_ActiveContracts, _taskID, [_taskID, "Exfiltration"]] call ALiVE_fnc_hashSet;

// --- 6. The CBA Per-Frame Handler (No Native Triggers) ---
[{
    params ["_args", "_handle"];
    _args params ["_taskID", "_vipProfileID", "_extractionPoint"];

    // 1. Check if Task is already completed/failed externally
    private _taskState = [_taskID] call BIS_fnc_taskState;
    if (_taskState == "SUCCEEDED" || _taskState == "CANCELED" || _taskState == "FAILED") exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    // 2. Check if the ALiVE Profile still exists (Checks for Virtual Deaths)
    private _profileData = [ALIVE_profileHandler, "getProfile", _vipProfileID] call ALIVE_fnc_profileHandler;
    if (isNil "_profileData") exitWith {
        [_taskID, 'FAILED', true] call BIS_fnc_taskSetState;
        diag_log format ['[A3M Contracts] Exfil Task %1 FAILED (Informant Killed Virtually).', _taskID];
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    // 3. Physical State & Trigger Check
    private _vipEntity = [_profileData, "entity"] call ALIVE_fnc_profileEntity;
    if (!isNil "_vipEntity" && {!isNull _vipEntity}) then {
        
        // Physical Death Check
        if (!alive _vipEntity) exitWith {
             [_taskID, 'FAILED', true] call BIS_fnc_taskSetState;
             diag_log format ['[A3M Contracts] Exfil Task %1 FAILED (Informant Killed Physically).', _taskID];
             [_handle] call CBA_fnc_removePerFrameHandler;
        };
        
        // Extraction Check
        if (_vipEntity getVariable ["A3M_isSecured", false]) then {
            if (_vipEntity distance2D _extractionPoint < 50) then {
                [_taskID, 'SUCCEEDED', true] call BIS_fnc_taskSetState;
                
                private _reward = 250000;
                {
                    if (isPlayer _x && {alive _x}) then {
                        [_x, _reward] remoteExecCall ['grad_moneymenu_fnc_addFunds', _x];
                        ['Contract Complete', format ['Transferred %1c for successful extraction.', _reward]] remoteExec ['BIS_fnc_showSubtitle', _x];
                    };
                } forEach playableUnits; 
                
                diag_log format ['[A3M Contracts] Task %1 SUCCEEDED.', _taskID];
                
                // Cleanup VIP after 30 seconds cleanly
                [ { if (!isNull (_this select 0)) then { deleteVehicle (_this select 0); }; }, [_vipEntity], 30 ] call CBA_fnc_waitAndExecute;
                
                [_handle] call CBA_fnc_removePerFrameHandler;
            };
        };
    };
}, 2, [_taskID, _vipProfileID, _extractionPoint]] call CBA_fnc_addPerFrameHandler;
