// File: arma3mercenaries\set_group_captive\fn_squadReorganizerApply.sqf

disableSerialization;

private _player = player;
private _oldGroup = group _player;

// Notify start
private _startMsg = "<t align='left'><t size='0.8' color='#00aaff'>SQUAD REORGANIZED</t><br/><t size='0.6' color='#FFFFFF'>Applying new tactical layout...</t></t>";
[_startMsg, 0.0, 0.1, 3, 0.5, 0, 789] spawn BIS_fnc_dynamicText;

// 1. Create a brand new group. 
private _newGroup = createGroup [side _player, true];

// 2. Move the player into the new group and establish absolute leadership
[_player] joinSilent _newGroup;
_newGroup selectLeader _player;

// 3. Move the AI into the new group in the EXACT order defined by the UI
{
    [_x] joinSilent _newGroup;
    _x setVariable ["A3M_SquadIndex", _forEachIndex + 1, true]; // Sync new index
} forEach A3M_Reorganizer_Units;

// Re-shield the new group so VCOM doesn't hijack it
[_newGroup] call A3M_fnc_disableVcom;

// 4. Flush their AI brains by forcing them to stop, then return to formation
{
    if (!isPlayer _x) then {
        _x doWatch objNull;
        _x disableAI "TARGET";
        _x disableAI "AUTOTARGET";
        
        // Give them a split second to clear their FSM
        [_x] spawn {
            params ["_unit"];
            sleep 1;
            _unit enableAI "TARGET";
            _unit enableAI "AUTOTARGET";
            _unit doFollow player;
        };
    };
} forEach A3M_Reorganizer_Units;

// 5. Manually delete the old group just to be absolutely sure it doesn't linger
if (count (units _oldGroup) == 0) then {
    deleteGroup _oldGroup;
};

// Also save to DB immediately to persist the new order!
[] spawn {
    sleep 2;
    [player] call grad_persistence_fnc_savePlayer;
    systemChat "Tactical layout saved to database.";
};

// Notify completion
private _count = count A3M_Reorganizer_Units;
private _endMsg = format ["<t align='left'><t size='0.8' color='#00FF00'>REORGANIZATION COMPLETE</t><br/><t size='0.6' color='#FFFFFF'>%1 mercenaries successfully assigned to new F-keys.</t></t>", _count];
[_endMsg, 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;
