/*
    arma3mercenaries_fn_bluforIndep_on_civilians.sqf
    Author: BrianV1981

	Description:
    Allows BLUFOR/Independent player to interrogate nearby civilians via addAction.
    Applies bleed damage over time, gives rewards, handles cooldowns, and filters targets.
    HVT task execution is remoteExec'd globally for MP/Dedicated Server compatibility.
    MP Sync: Uses remoteExec for client effects and broadcasting variables where needed.

	Parameters:
	_this select 0: Object - The object the action is attached to (_object)
	_this select 1: Object - The player who activated the action (_player)

	Uses: %1=Count, %2=Faction, %3=Reward, %4=PlayerFaction
*/

// --- Configurable Cooldown ---
private _interrogationCooldown = 60; // Time in seconds player must wait after starting an interrogation

// --- Message Arrays ---
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
    "Bring me someone with some information to extract or get out of my face, soldier!",
    "%4 must be having problems filling the ranks...",
    "It's not that hard to figure out. Go find and bring me someone to interrogate!",
    "What’s the matter, soldier? Did you forget to bring the prisoners? Get out there and do your job!",
    "I don't see any targets. Are you planning on interrogating the air?",
    "You expect me to interrogate ghosts? Bring me a real target, or get lost!",
    "Nice job, genius. You brought me nothing. Go fetch some real intel, or don't come back!",
    "What, did they all vanish? Next time, try bringing someone I can actually interrogate.",
    "I can’t work with thin air, soldier! Find someone for me to interrogate or get out of my sight!",
    "You brought me a whole lot of nothing. Did you think I’d interrogate the shadows?",
    "Great plan, bringing no one for interrogation. Maybe next time, try doing your job right."
];
private _interrogationStartMessages = [
    "%1 %2 lined up—%1 targets. Cash comes after they sing or bleed.",
    "%1 %2 marked for questioning—%1 of them. Cash comes when the job’s finished.",
    "%1 %2 under the gun—%1 in total. Cash is yours when the talking’s over.",
    "%1 %2 in the hot seat—%1 marked. You’ll get the cash once they spill or drop.",
    "Line up the %1 %2—%1 lives hanging by a thread. Cash rolls in when they start to break.",
    "Ready the %1 %2—%1 souls to crack. The money's yours once they start screaming.",
    "The %1 %2 are ready—%1 chances to make them bleed. Blood or tears, cash is coming either way.",
    "%1 %2, %1 whispers away from breaking. The cash flows when they stop breathing.",
    "%1 %2 in the spotlight—%1 chances to push them over the edge. Only one thing matters—the payday.",
    "The %1 %2 are sweating—%1 opportunities to break them. Cash doesn’t care how they fall.",
    "Eyes on the %1 %2—%1 lives on the line. Once they’re shattered, the cash is yours.",
    "%1 %2—%1 stories to cut short. Cash is what’s left when the screams fade away.",
    "The %1 %2 are ready—%1 chances to make them beg. The only thing left is the payoff.",
    "%1 %2 under pressure—%1 lives about to end. When the silence falls, the money rises."
];
private _interrogationCompleteMessages = [
    "Interrogation’s done. %3 cash from the %2 in hand—don’t spend it all in one place.",
    "Job’s done. The %2 screamed about his family. Here’s your %3—I hope you can sleep at night.",
    "All done. That %2 was tough, but he finally cracked. %3 cash delivered—straight to your hands.",
    "Interrogation complete on a %2. %3 cash in hand—use it wisely.",
    "He begged for mercy, but the info came first. %3 cash for a job well done on the %2.",
    "That %2 couldn’t hold out forever—now you’ve got %3 cash in your pocket.",
    "War isn’t pretty, but it pays well. %3 cash earned from interrogating a %2.",
    "They broke under pressure, and so did their bank—%3 cash delivered.",
    "The %2 didn’t make it home for dinner, that's for sure. %3 cash delivered!",
    "It’s not about the pain, it’s about the payday. %3 cash for your efforts.",
    "The screams still echo, but so does the sound of cash. %3 from the %2 in hand.",
    "%2 didn’t stand a chance—%3 cash earned. Maybe next time they’ll listen.",
    "%2 cried until the end. %3 cash is yours, but the guilt’s on you.",
    "%2 gave up everything—%3 cash won’t bring back their dignity.",
    "%3 cash for shattering a %2. The money feels heavy, doesn’t it?",
    "The %2 begged for mercy. %3 cash in your pocket, their blood on your hands.",
    "%2 couldn’t take it anymore. %3 cash earned, but at what cost?",
    "The %2’s last words were about family. %3 cash won’t silence the echoes.",
    "%3 cash for breaking a soul. The %2 never saw it coming.",
    "%2 broke down, and so did their wallet. %3 cash for a job well done."
];
private _cooldownMessage = "We're still processing the last batch. Give it some time before starting another round.";

// --- Script Start ---
// Get parameters from addAction
private _object = _this select 0; // Object action is attached to
private _player = _this select 1; // Player who activated action

// Sanity check for player object
if (isNull _player) exitWith { diag_log "Interrogation Script: Action triggered with null player."; };

// Determine player faction
private _playerFaction = switch (side _player) do {
    case west: {"BLUFOR"};
    case east: {"OPFOR"};
    case independent: {"Independent"};
    case civilian: {"Civilian"};
    default {"Unknown"};
};

// --- Player Cooldown Check ---
// Check variable on player object, relies on broadcast from previous runs
if (_player getVariable ["isBusyInterrogating", false]) exitWith {
    // Display cooldown message only to the activating player
    [_cooldownMessage, 0.0, 0.1, 5, 1, 0, 789] remoteExec ["BIS_fnc_dynamicText", _player, true];
};

// --- Set Player Cooldown ---
// Mark the player as busy, broadcast this state change to everyone
_player setVariable ["isBusyInterrogating", true, true];

// Spawn a *local* process to clear the busy flag after the cooldown
// This ensures the timer runs even if the main script exits early
[_player, _interrogationCooldown] spawn {
    params ["_playerToClear", "_delay"];
    sleep _delay;
    // Clear the flag and broadcast the change so the player can interrogate again
    // Check if player object still exists (might disconnect)
    if (!isNull _playerToClear) then {
        _playerToClear setVariable ["isBusyInterrogating", nil, true];
    };
};

// --- Faction Check ---
// Check if the player belongs to BLUFOR or Independent
if (!(side _player in [west, independent])) exitWith {
    private _factionRestrictionMessage = format [selectRandom _factionRestrictionMessages, "", "", "", _playerFaction];
    // Display restriction message only to the activating player
    [_factionRestrictionMessage, 0.0, 0.1, 5, 1, 0, 789] remoteExec ["BIS_fnc_dynamicText", _player, true];
    // Player wasn't busy before, but we set the flag. Clear it immediately since they failed the faction check.
    _player setVariable ["isBusyInterrogating", nil, true];
};

// --- Target Identification & Filtering ---
// Get the player's position and find nearby potential targets
private _pos = getPos _player;
private _capturedUnits = _pos nearEntities ["Man", 30]; // Find units within 30m
_capturedUnits = _capturedUnits select {alive _x && side _x == civilian}; // Filter for alive civilians

// Filter out units that are *already* being interrogated (check broadcasted variable)
private _newCapturedUnits = _capturedUnits select { !(_x getVariable ["interrogationInProgress", false]) };

// Recalculate the count after filtering
private _newCapturedCount = count _newCapturedUnits;

// --- No Targets Check ---
if (_newCapturedCount == 0) exitWith {
    private _noCapturedMessage = format [selectRandom _noCapturedMessages, "", "", "", _playerFaction];
    // Display "no targets" message only to the activating player
    [_noCapturedMessage, 0.0, 0.1, 5, 1, 0, 789] remoteExec ["BIS_fnc_dynamicText", _player, true];
    // Clear the busy flag since no interrogation is happening
    _player setVariable ["isBusyInterrogating", nil, true];
};

// --- Start Interrogation ---
// Determine the faction side text of the first valid captured unit
private _capturedSideText = switch (side (_newCapturedUnits select 0)) do {
    case west: {"NATO"};
    case east: {"CSAT"};
    case independent: {"Independent"};
    case civilian: {"Civilian"};
    default {"Unknown"};
};

// Display the interrogation start message to the activating player
private _interrogationStartMessage = format [selectRandom _interrogationStartMessages, _newCapturedCount, _capturedSideText, "", _playerFaction];
[_interrogationStartMessage, 0.0, 0.1, 5, 1, 0, 789] remoteExec ["BIS_fnc_dynamicText", _player, true];

// --- Process Each Captured Unit ---
{
    private _unit = _x; // Current unit in the loop
    private _bleedPercentage = random 0.1 + 0.01; // Random bleed between 1% and ~11%

    // Mark the unit as being interrogated, **BROADCAST** this state change
    _unit setVariable ["interrogationInProgress", true, true];

    // Spawn a *local* process for each captured unit's bleed/death cycle
    [_unit, _player, _bleedPercentage, _capturedSideText, _playerFaction, _interrogationCompleteMessages] spawn {
        params ["_cap", "_playerParam", "_bleed", "_capSideText", "_playerSideText", "_completeMessages"];

        // Apply health bleed at intervals until unit dies or flag is cleared
        while {alive _cap && {_cap getVariable ["interrogationInProgress", false]}} do {
            sleep (10 + random 20); // Random interval between 10 and 30 seconds

            // Apply damage globally. This works but is less secure than server-only damage.
            _cap setDamage (damage _cap + _bleed);

            // Check if unit died (local check, but damage is global)
            if (damage _cap >= 1) then {
                // Ensure unit is fully dead (global command)
                _cap setDamage 1;

                // Calculate reward
                private _reward = 10000 + random 20000; // Base reward 10k-30k
                private _multiplierChance = random 100;

                if (_multiplierChance < 50) then { // 50% chance for HVT
                    _reward = _reward * 20; // Apply multiplier

                    // Send HVT hint message ONLY to the interrogating player
                    ["HVT found! The information extracted was invaluable to our war effort!"] remoteExec ["hintSilent", _playerParam];

                    // *** FIXED: Execute HVT task script GLOBALLY using remoteExec ***
                    // Target 0 = All Clients + Server (JIP safe)
                    ["arma3mercenaries\tasks\HVT_1\HVT_task_1.sqf"] remoteExec ["execVM", 0];
                };

                // Award funds (remoteExec ensures it runs where grad_lbm expects it - targeting player)
                [_playerParam, _reward] remoteExec ["grad_lbm_fnc_addFunds", _playerParam, true];

                // Display completion message to the interrogating player
                private _completionMessage = format [selectRandom _completeMessages, "", _capSideText, _reward, _playerSideText];
                [_completionMessage, 0.0, 0.1, 5, 1, 0, 789] remoteExec ["BIS_fnc_dynamicText", _playerParam, true];

                // Clean up the variable on the captured unit, **BROADCAST** change
                _cap setVariable ["interrogationInProgress", nil, true];

                // Exit the while loop for this (now dead) unit
                break;
            };
        };

        // Final cleanup check if loop exited unexpectedly (e.g. unit deleted while flag was true)
        // Check if unit still exists and flag is still true
        if (!isNull _cap && alive _cap && {_cap getVariable ["interrogationInProgress", false]}) then {
            _cap setVariable ["interrogationInProgress", nil, true]; // Broadcast cleanup
        };
    };
} forEach _newCapturedUnits;

// Main script execution finishes here for the player who triggered it.
// The spawned cooldown timer and unit processing loops continue independently.