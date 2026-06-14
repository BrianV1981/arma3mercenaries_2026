/*
    arma3mercenaries\set_group_captive\squadReform.sqf
    Description: Hard-resets the squad's AI brain by creating a brand new Arma 3 group, transferring all members to it, and deleting the old glitched group. This completely fixes the "stuck AI leader" glitch that happens after ACE revives without having to ping the database to stow/deploy them!
*/

private _player = player;
private _oldGroup = group _player;
private _squadMembers = units _oldGroup;

// Notify start
private _startMsg = "<t align='left'><t size='0.8' color='#00aaff'>SQUAD REFORM</t><br/><t size='0.6' color='#FFFFFF'>Resetting AI command structure...</t></t>";
[_startMsg, 0.0, 0.1, 3, 0.5, 0, 789] spawn BIS_fnc_dynamicText;

// Step 1: Create a brand new group. 
// The 'true' flag ensures the group is automatically deleted by the engine when empty, saving group slots!
private _newGroup = createGroup [side _player, true];

// Step 2: Move the player into the new group and establish absolute leadership
[_player] joinSilent _newGroup;
_newGroup selectLeader _player;

// Step 3: Move all AI over to the new group instantly
(_squadMembers - [_player]) joinSilent _newGroup;

// Step 4: Flush their AI brains by forcing them to stop, then return to formation
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
} forEach (units _newGroup);

// Step 5: Manually delete the old group just to be absolutely sure it doesn't linger
if (count (units _oldGroup) == 0) then {
    deleteGroup _oldGroup;
};

// Notify completion
private _count = {!isPlayer _x} count (units _newGroup);
private _endMsg = format ["<t align='left'><t size='0.8' color='#00FF00'>REFORM COMPLETE</t><br/><t size='0.6' color='#FFFFFF'>%1 mercenaries successfully transferred to new command channel.</t></t>", _count];
[_endMsg, 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;
