/*
    arma3mercenaries\interrogations\fn_interrogateTarget.sqf
    Description:
    Unscheduled, Event-Driven Interrogation System.
    Compatible with ACE Medical and features Anti-Execution logic.
*/

params [
    ["_object", objNull],
    ["_player", objNull],
    ["_args", ["CIVILIAN"]]
];

if (typeName _args != "ARRAY") then { _args = [_args]; };
if (isNull _player) exitWith { diag_log "[A3M] Error: Player is null"; };

private _targetSideStr = _args param [0, "CIVILIAN"];
private _targetSide = civilian;
if (_targetSideStr == "OPFOR") then { _targetSide = east; };

// --- Configurable Cooldown ---
private _interrogationCooldown = 60;

private _playerFaction = switch (side _player) do {
    case west: {"BLUFOR"};
    case east: {"OPFOR"};
    case independent: {"Independent"};
    case civilian: {"Civilian"};
    default {"Unknown"};
};

// ==========================================
// MESSAGE ARRAYS (Your Original Flavor Text)
// ==========================================
private _factionRestrictionMessages = [
    "%4 huh? If you don't get out of here, you're the one who's going to be getting interrogated!",
    "This ain’t your fight.",
    "I would suggest turning around and looking for your %4 buddies.",
    "Are you wearing the wrong %4 uniform by chance?",
    "You’re on the wrong side of the fence. Doesn't %4 know how to read?"
];

private _noCapturedMessages = [
    "I don't see anybody to interrogate. You must make %4 real proud...",
    "Are you blind, son? The only person standing here that should be interrogated is you...",
    "Bring me someone with some information to extract or get out of my face, soldier!"
];

private _interrogationStartMessages = [
    "%1 %2 lined up—%1 targets. Cash comes after they sing or bleed.",
    "%1 %2 marked for questioning—%1 of them. Cash comes when the job’s finished.",
    "%1 %2 under the gun—%1 in total. Cash is yours when the talking’s over."
];

private _interrogationCompleteMessages = [
    "Interrogation’s done. %3 cash from the %2 in hand—don’t spend it all in one place.",
    "Job’s done. The %2 screamed about his family. Here’s your %3—I hope you can sleep at night.",
    "All done. That %2 was tough, but he finally cracked. %3 cash delivered—straight to your hands."
];

// ==========================================
// PLAYER STATE & COOLDOWN
// ==========================================
if (_player getVariable ["isBusyInterrogating", false]) exitWith {
    ["We're still processing the last batch. Give it some time before starting another round.", 0.0, 0.1, 5, 1, 0, 789] remoteExec ["BIS_fnc_dynamicText", _player];
};

if (!(side _player in [west, independent])) exitWith {
    private _msg = format [selectRandom _factionRestrictionMessages, "", "", "", _playerFaction];
    [_msg, 0.0, 0.1, 5, 1, 0, 789] remoteExec ["BIS_fnc_dynamicText", _player];
};

// Set busy flag globally
_player setVariable ["isBusyInterrogating", true, true];

// Unscheduled CBA Timer to clear the cooldown 60 seconds from now
[ { (_this select 0) setVariable ["isBusyInterrogating", nil, true]; }, [_player], _interrogationCooldown ] call CBA_fnc_waitAndExecute;

// ==========================================
// TARGET SELECTION
// ==========================================
private _capturedUnits = (getPos _player) nearEntities ["Man", 30] select {alive _x && side _x == _targetSide};
private _newCapturedUnits = _capturedUnits select { !(_x getVariable ["interrogationInProgress", false]) };
private _newCapturedCount = count _newCapturedUnits;

if (_newCapturedCount == 0) exitWith {
    private _msg = format [selectRandom _noCapturedMessages, "", "", "", _playerFaction];
    [_msg, 0.0, 0.1, 5, 1, 0, 789] remoteExec ["BIS_fnc_dynamicText", _player];
    _player setVariable ["isBusyInterrogating", nil, true]; // Clear CD early if they failed
};

private _startMsg = format [selectRandom _interrogationStartMessages, _newCapturedCount, _targetSideStr, "", _playerFaction];
[_startMsg, 0.0, 0.1, 5, 1, 0, 789] remoteExec ["BIS_fnc_dynamicText", _player];

// ==========================================
// THE INTERROGATION ENGINE
// ==========================================
{
    private _unit = _x;
    
    // Mark as active
    _unit setVariable ["interrogationInProgress", true, true];

    // Store data on the unit so the Server Event Handler knows who to pay later
    _unit setVariable ["a3m_interrogator", _player, true];
    _unit setVariable ["a3m_targetSideText", _targetSideStr, true];
    _unit setVariable ["a3m_playerFactionText", _playerFaction, true];
    _unit setVariable ["a3m_successMsgTpl", selectRandom _interrogationCompleteMessages, true];

    // ------------------------------------------
    // PART A: THE JUDGE (MPKilled Event Handler)
    // ------------------------------------------
    private _ehId = _unit addMPEventHandler ["MPKilled", {
        params ["_killedUnit", "_killer", "_instigator", "_useEffects"];
        
        // Only run the payout logic on the Server to prevent double-payouts
        if (!isServer) exitWith {};

        private _interrogator = _killedUnit getVariable ["a3m_interrogator", objNull];
        if (isNull _interrogator) exitWith {}; // Failsafe
        
        // ANTI-CHEAT: Did a player manually execute them?
        // ACE Medical cardiac arrests register as objNull instigator. A bullet registers the shooter.
        private _executedByPlayer = false;
        if (isPlayer _instigator || isPlayer _killer) then { _executedByPlayer = true; };

        if (_executedByPlayer) then {
            // Fired a weapon/blew them up. Punish them.
            ["You executed the asset! The intel died with them.", 0.0, 0.1, 5, 1, 0, 789] remoteExec ["BIS_fnc_dynamicText", _interrogator];
        } else {
            // Died naturally from the script's bleeding. Payout time!
            private _sideText = _killedUnit getVariable ["a3m_targetSideText", "CIVILIAN"];
            private _factionText = _killedUnit getVariable ["a3m_playerFactionText", "BLUFOR"];
            private _msgTpl = _killedUnit getVariable ["a3m_successMsgTpl", "Interrogation complete. %3 cash earned."];

            private _reward = 10000 + random 20000;
            
            // 50% chance for HVT Task
            if (random 100 < 50) then {
                _reward = _reward * 20;
                ["HVT found! The information extracted was invaluable to our war effort!"] remoteExec ["hintSilent", _interrogator];
                ["HVT", getPos _interrogator] remoteExec ["A3M_fnc_requestTask", 2]; // Server creates the task
            };

            // Award Funds to the interrogator
            [_interrogator, round _reward] remoteExec ["grad_lbm_fnc_addFunds", _interrogator];
            [50, 0] remoteExecCall ["HG_fnc_addOrSubXP", _interrogator, false];
            "Intel Extracted: +50 XP" remoteExec ["systemChat", _interrogator, false];

            // Show custom completion text
            private _finalMsg = format [_msgTpl, "", _sideText, round _reward, _factionText];
            [_finalMsg, 0.0, 0.1, 5, 1, 0, 789] remoteExec ["BIS_fnc_dynamicText", _interrogator];
        };

        // Clean up variables and the Event Handler itself
        _killedUnit setVariable ["interrogationInProgress", nil, true];
        _killedUnit removeMPEventHandler ["MPKilled", _killedUnit getVariable ["a3m_mpKilledEH", -1]];
    }];

    // Save the EH ID so we can delete it later
    _unit setVariable ["a3m_mpKilledEH", _ehId, true];

    // ------------------------------------------
    // PART B: THE BLEEDER (CBA Per Frame Handler)
    // ------------------------------------------
    private _bleedPercentage = random 0.1 + 0.01; // Bleed amount

    [{
        params ["_args", "_handle"];
        _args params ["_unit", "_bleedAmount"];

        // If the unit died (the Judge took over) or the flag was cleared, stop bleeding
        if (!alive _unit || !(_unit getVariable ["interrogationInProgress", false])) exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
        };

        // Apply a chunk of damage every 10 seconds
        _unit setDamage (damage _unit + _bleedAmount);

    }, 10, [_unit, _bleedPercentage]] call CBA_fnc_addPerFrameHandler;

} forEach _newCapturedUnits;