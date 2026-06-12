/*
    arma3mercenaries\set_group_captive\groupRejoin.sqf
    Author: BrianV1981
    Rewritten: A.I.M. (Issue #24 — Two-Layer Captive System, Layer 2)

    Description:
    Player Group Persistence. Reclaims AI mercenaries after server restart.
    
    Layer 2 of the captive system:
    - Waits for A3M_ServerLoaded (grad-persistence load complete)
    - Joins matching AI to the player's group (transfers locality)
    - Waits for locality transfer to complete
    - Applies ACE handcuffs on the correct machine (where AI is local)
    - The player can then use "Mobilize (Reactivate)" ACE action to release them
*/

// --- A3M: Fresh Squad Isolation ---
// Forces the player into a brand new, clean squad upon login to prevent Arma 3 
// from aggressively merging them into an abandoned squad (which would cause them to inherit another player's stranded AI).
private _freshSquad = createGroup [side player, true];
[player] joinSilent _freshSquad;

// Get the player's UID and tag the player
private _playerUID = getPlayerUID player;
player setVariable ["arma3mercenaries_groupID", _playerUID, true];

// --- Wait for grad-persistence to finish loading before scanning allUnits ---
// A3M_ServerLoaded is set to true at the END of fn_loadMission.sqf (line 39)
// Fallback: if it never fires within 120 seconds, proceed anyway to prevent infinite hang
[{
    params ["_playerUID"];
    (!isNull player) && (time > 0) && 
    (missionNamespace getVariable ["A3M_ServerLoaded", false] || time > 120)
}, {
    params ["_playerUID"];

    private _claimedUnits = [];

    // Scan all units for mercenaries belonging to this player
    {
        private _unit = _x;
        if (!isPlayer _unit) then {
            private _uID = _unit getVariable ["arma3mercenaries_groupID", ""];
            // Support both new (raw UID) and legacy (prefixed) formats
            if (_uID == _playerUID || _uID == format ["arma3mercenaries_groupID_%1", _playerUID]) then {
                // Join the player's group — this initiates locality transfer
                [_unit] joinSilent group player;
                _claimedUnits pushBack _unit;
            };
        };
    } forEach allUnits;

    // For each claimed unit, wait for locality transfer, then apply ACE captive state
    {
        private _unit = _x;
        private _index = _forEachIndex;
        [{
            params ["_unit"];
            local _unit  // True when the unit is local to THIS player's client
        }, {
            params ["_unit", "_index"];

            // --- Locality confirmed. Safe to apply ACE handcuffs. ---
            
            // Re-enable the AI brain (was disabled by server-side disableAI "ALL")
            _unit enableAI "ALL";

            // Apply ACE handcuffs (proper visual + behavioral captive state)
            // This now runs on the correct machine (where the unit is local)
            [_unit, true] call ACE_captives_fnc_setHandcuffed;

            // --- A3M: Restore Wallet on Client ---
            private _loadedCash = _unit getVariable ["A3M_LoadedCash", 0];
            if (_loadedCash > 0) then {
                [_unit, _loadedCash, false] call grad_moneymenu_fnc_addFunds;
                _unit setVariable ["A3M_LoadedCash", 0, true]; // Clear it so it's not repeatedly added
                diag_log format ["[A3M BARRACKS] Wallet restored locally for %1: $%2", name _unit, _loadedCash];
            };

            // Keep vanilla guards active (player removes them via "Mobilize" action)
            _unit setCaptive true;
            _unit allowDamage false;

            // Clear the server-side activation flag
            _unit setVariable ["A3M_AwaitingActivation", nil, true];

            diag_log format ["[A3M BARRACKS] Mercenary %1 (%2) claimed by player. ACE captive applied locally.",
                name _unit, _unit getVariable ["arma3mercenaries_aiUnit", "?"]];

        }, [_unit, _index], 30, {
            // Timeout handler (30s) — if locality never transfers, force-apply anyway
            params ["_unit", "_index"];
            diag_log format ["[A3M BARRACKS WARNING] Locality timeout for %1. Force-applying captive state on this client.", name _unit];
            _unit enableAI "ALL";
            [_unit, true] remoteExecCall ["ACE_captives_fnc_setHandcuffed", _unit];
            _unit setCaptive true;
            _unit allowDamage false;
            _unit setVariable ["A3M_AwaitingActivation", nil, true];
        }] call CBA_fnc_waitUntilAndExecute;
    } forEach _claimedUnits;

    if (count _claimedUnits > 0) then {
        systemChat format ["[A3M] %1 mercenaries reclaimed from barracks. Use 'Mobilize' to activate.", count _claimedUnits];
    };

    // --- A3M Global Wakeup Protocol (One-Time Execution per Server Restart) ---
    // If you are the first player to log in, you trigger the global vehicle mount for all OFFLINE players' AI.
    if (isNil {missionNamespace getVariable "A3M_GlobalWakeupFired"}) then {
        missionNamespace setVariable ["A3M_GlobalWakeupFired", true, true];
        remoteExecCall ["A3M_fnc_serverGlobalWakeup", 2];
        diag_log "[A3M BARRACKS] First player logged in. Triggering Server Global Wakeup for offline AI.";
    };

}, [_playerUID], 120, {
    // Absolute timeout handler (120s) — server never signaled load complete
    diag_log "[A3M BARRACKS WARNING] A3M_ServerLoaded never fired within 120s. GroupRejoin proceeding with timeout fallback.";
}] call CBA_fnc_waitUntilAndExecute;