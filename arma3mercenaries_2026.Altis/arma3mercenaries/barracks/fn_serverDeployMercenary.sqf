/*
    fn_serverDeployMercenary.sqf
    Server-side logic to pull a mercenary from the DB and spawn them physically into the world.
*/
params ["_client", "_mercID"];

if (!isServer) exitWith {};

// Ensure they aren't already deployed
private _isDeployed = false;
{
    if ((_x getVariable ["arma3mercenaries_aiUnit", ""]) == _mercID) exitWith { _isDeployed = true; };
} forEach allUnits;

if (_isDeployed) exitWith { "Mercenary is already deployed!" remoteExecCall ["systemChat", _client]; };

// Fetch profile
private _profile = [format["A3M_MERC_%1", _mercID], createHashMap, true] call A3M_fnc_dbGetSecure;
if (count _profile == 0) exitWith { "Error: Database profile not found." remoteExecCall ["systemChat", _client]; };

if (_profile getOrDefault ["IsDead", false]) exitWith { "Error: This mercenary is dead." remoteExecCall ["systemChat", _client]; };

private _shadowStatus = _profile getOrDefault ["ShadowOps_Status", "Stowed"];
if (_shadowStatus != "Stowed") exitWith { format ["Error: Mercenary is currently %1 on a Shadow Operation.", _shadowStatus] remoteExecCall ["systemChat", _client]; };

private _class = _profile getOrDefault ["Class", ""];
if (_class == "") exitWith { "Error: Invalid class in database." remoteExecCall ["systemChat", _client]; };

private _name = _profile getOrDefault ["Name", "Mercenary"];
private _nameParts = _name splitString " ";
private _firstName = if (count _nameParts > 0) then { _nameParts select 0 } else { _name };
private _lastName = if (count _nameParts > 1) then { _nameParts select 1 } else { "" };

// Escape single quotes for the init string injection to prevent syntax errors (e.g. O'Brien)
private _safeName = (_name splitString "'") joinString "''";

// Spawn them safely near the player
private _spawnPos = (getPos _client) findEmptyPosition [2, 15, _class];
if (count _spawnPos == 0) then { _spawnPos = getPos _client; };

// --- THE DUMMY GROUP HACK ---
// A3M Bugfix: Spawning AI directly into a remote client's group from the server corrupts their FSM (breaking Move/Stop commands).
// We must spawn them into a server-local dummy group first, then transfer them.
private _dummyGroup = createGroup (side _client);

// A3M Bugfix: Use older string-syntax createUnit to inject the ACE name synchronously DURING engine initialization.
_class createUnit [_spawnPos, _dummyGroup, format["
    this setVariable ['ACE_Name', '%1', true];
    this setVariable ['ACE_name', '%1', true];
    this setVariable ['ace_name', '%1', true];
    this setVariable ['arma3mercenaries_aiUnit', '%2', true];
    this setVariable ['arma3mercenaries_groupID', '%3', true];
    A3M_TEMP_SPAWN_UNIT = this;
", _safeName, _mercID, getPlayerUID _client]];

// Retrieve the synchronously created unit object
private _unit = A3M_TEMP_SPAWN_UNIT;

// Safely transfer the fully initialized unit into the player's group across the network
[_unit] joinSilent (group _client);

// JIP broadcast setName (This perfectly syncs the F-keys across all clients)
[_unit, [_name, _firstName, _lastName]] remoteExecCall ["setName", 0, _unit];

// A3M: Auto-load into vehicle if the Operator is mounted
if (vehicle _client != _client) then {
    _unit assignAsCargo (vehicle _client);
    _unit moveInAny (vehicle _client);
};

// Optional: Set skill to max since they are persistent elites
_unit setSkill 1;
[_unit] call A3M_fnc_disableVcom; // A3M: Completely shield the deployed mercenary from VCOM AI and ALiVE Simulation so they perfectly obey the player

// Register the mercenary (hooks MPKilled event handler)
[_unit, _mercID] call A3M_fnc_serverRegisterMercenary;

// --- A3M: Deploy in Captive State (Layer 1 — Server-side Vanilla Guard) ---
_unit setCaptive true;
_unit allowDamage false;
_unit disableAI "ALL";
_unit setVariable ["A3M_AwaitingActivation", true, true];
_unit setVariable ["ALiVE_disableDynamicSimulation", true, true];

// --- Layer 2: Tell the owning client to apply ACE handcuffs after locality transfers ---
[{
    params ["_unit"];
    local _unit
}, {
    params ["_unit"];
    // Delay 1 second to ensure the engine spawn animation doesn't override the ACE handcuff animation
    [{
        params ["_unit"];
        _unit enableAI "ALL";
        [_unit, true] call ACE_captives_fnc_setHandcuffed;
        _unit setVariable ["A3M_AwaitingActivation", nil, true];
        diag_log format ["[A3M BARRACKS] Deployed merc %1 — ACE captive applied on client.", name _unit];
    }, [_unit], 1] call CBA_fnc_waitAndExecute;
}, [_unit], 15, {
    // Timeout fallback
    params ["_unit"];
    _unit enableAI "ALL";
    [_unit, true] remoteExecCall ["ACE_captives_fnc_setHandcuffed", _unit];
    _unit setVariable ["A3M_AwaitingActivation", nil, true];
}] remoteExecCall ["CBA_fnc_waitUntilAndExecute", _client];

// Restore their wallet from the database profile
private _cash = _profile getOrDefault ["CashCarried", 0];
if (_cash > 0) then {
    [_unit, _cash] remoteExecCall ["grad_moneymenu_fnc_addFunds", _client];
};

format ["%1 deployed from barracks (Standing Down). Use 'Mobilize' to activate.", _name] remoteExecCall ["systemChat", _client];

// Refresh the UI so the state updates seamlessly
[_client, true] call A3M_fnc_serverFetchSquadDossier;
