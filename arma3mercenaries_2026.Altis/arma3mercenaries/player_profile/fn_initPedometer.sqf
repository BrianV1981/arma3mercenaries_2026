/*
    fn_initPedometer.sqf
    Runs locally on the client. Tracks distance moved and play time.
*/

if (!hasInterface) exitWith {};

// Start tracking loop
[] spawn {
    waitUntil {sleep 1; !isNull player && alive player};
    private _lastPos = getPosASL player;
    
    while {true} do {
        sleep 10; // Check every 10 seconds
        
        if (!alive player) then { continue; };
        
        private _currentPos = getPosASL player;
        private _dist = _lastPos distance _currentPos;
        _lastPos = _currentPos;
        
        // Ignore massive teleportations (like respawning)
        if (_dist > 5000) then { continue; };
        
        // Determine movement type
        private _state = vehicle player;
        private _type = 0; // 0=Walk, 1=Drive, 2=Fly
        
        if (_state != player) then {
            if (_state isKindOf "Air" || _state isKindOf "Helicopter") then { _type = 2; }
            else { _type = 1; };
        };
        
        // Send to server: [Type, Distance, PlayTime (10s), PlayerObject]
        [_type, _dist, 10, player] remoteExecCall ["A3M_fnc_serverUpdatePedometer", 2];
    };
};