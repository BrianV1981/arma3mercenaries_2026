// A3M Speech Overhaul - Apply Chatter Event Handlers
// Attach this to any AI unit to give them the Custom PMC Radio system.
// Uses a 15-second group cooldown hash to prevent audio spam.

params ["_unit"];

if (!local _unit) exitWith {}; // EHs must be applied where the unit is local

// 1. Reloading Event
_unit addEventHandler ["Reloaded", {
    params ["_unit", "_weapon", "_muzzle", "_newMagazine", "_oldMagazine"];
    
    // Only care about primary weapons or handguns, not launchers
    if !(_weapon == primaryWeapon _unit || _weapon == handgunWeapon _unit) exitWith {};
    
    private _group = group _unit;
    private _cooldown = _group getVariable ["a3m_chatter_cooldown", 0];
    
    if (time >= _cooldown) then {
        _group setVariable ["a3m_chatter_cooldown", time + 15]; // 15 second squad mute
        
        if (!isNil "A3M_Speech_West_Reload") then {
            private _sound = selectRandom A3M_Speech_West_Reload;
            _unit say3D _sound; // Play in 3D space
        };
    };
}];

// 2. Hit Event
_unit addEventHandler ["Hit", {
    params ["_unit", "_source", "_damage", "_instigator"];
    
    private _group = group _unit;
    private _cooldown = _group getVariable ["a3m_chatter_cooldown", 0];
    
    if (time >= _cooldown) then {
        _group setVariable ["a3m_chatter_cooldown", time + 15];
        
        if (!isNil "A3M_Speech_West_Hit") then {
            private _sound = selectRandom A3M_Speech_West_Hit;
            _unit say3D _sound;
        };
    };
}];

// 3. FiredNear (Suppressed) Event
_unit addEventHandler ["FiredNear", {
    params ["_unit", "_firer", "_distance", "_weapon", "_muzzle", "_mode", "_ammo", "_gunner"];
    
    if (_distance > 15) exitWith {}; // Only care about bullets whizzing close
    if (side _firer == side _unit) exitWith {}; // Ignore friendly fire suppression
    
    private _group = group _unit;
    private _cooldown = _group getVariable ["a3m_chatter_cooldown", 0];
    
    if (time >= _cooldown) then {
        _group setVariable ["a3m_chatter_cooldown", time + 15];
        
        if (!isNil "A3M_Speech_West_Suppress") then {
            private _sound = selectRandom A3M_Speech_West_Suppress;
            _unit say3D _sound;
        };
    };
}];

// 4. Killed Event
_unit addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator", "_useEffects"];
    
    private _group = group _unit;
    private _cooldown = _group getVariable ["a3m_chatter_cooldown", 0];
    
    if (time >= _cooldown) then {
        _group setVariable ["a3m_chatter_cooldown", time + 15];
        
        // Have a surviving group member yell "Man Down!"
        private _aliveUnits = (units _group) select {alive _x};
        if (count _aliveUnits > 0) then {
            private _speaker = selectRandom _aliveUnits;
            if (!isNil "A3M_Speech_West_Killed") then {
                private _sound = selectRandom A3M_Speech_West_Killed;
                _speaker say3D _sound;
            };
        };
    };
}];
