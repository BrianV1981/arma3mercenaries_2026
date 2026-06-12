params ["_drone", "_caller"];

private _dummy = _drone getVariable ["A3M_Payload", objNull];
if (isNull _dummy) exitWith {};

// Retrieve variables
private _payloadClass = _drone getVariable ["A3M_Payload_Class", ""];
private _owner = _drone getVariable ["A3M_Payload_Owner", objNull];

// Clean up drone
private _actionID = _drone getVariable ["A3M_Payload_ActionID", -1];
if (_actionID != -1) then { _drone removeAction _actionID; };
_drone setVariable ["A3M_Payload", nil, true];
_drone setVariable ["A3M_Payload_ActionID", nil, true];

// Get drop pos and delete the simple object proxy
private _pos = getPosASL _dummy;
private _vel = velocity _drone;
private _dir = getDir _drone;
deleteVehicle _dummy;

// Map Magazine class to Ammo class
private _ammoClass = getText (configFile >> "CfgMagazines" >> _payloadClass >> "ammo");
if (_ammoClass == "") then {
    // Fallbacks if config parsing fails
    if ("Satchel" in _payloadClass) then { _ammoClass = "SatchelCharge_Remote_Ammo"; };
    if ("Demo" in _payloadClass) then { _ammoClass = "DemoCharge_Remote_Ammo"; };
    if ("Hand" in _payloadClass) then { _ammoClass = "GrenadeHand"; };
    if ("Mini" in _payloadClass) then { _ammoClass = "mini_Grenade"; };
    if ("1Rnd" in _payloadClass) then { _ammoClass = "G_40mm_HE"; };
};

// Spawn the LIVE projectile
private _liveBomb = _ammoClass createVehicle [0,0,0];
_liveBomb setPosASL _pos;
_liveBomb setDir _dir;
// Push it slightly down so it falls nicely instead of clipping the drone
_liveBomb setVelocity [(_vel select 0), (_vel select 1), (_vel select 2) - 3];

// If it's a remote explosive, we give the caller a custom action to detonate it
if ("Remote" in _payloadClass) then {
    private _displayName = getText (configFile >> "CfgMagazines" >> _payloadClass >> "displayName");
    private _detActionID = _caller addAction [
        format ["<t color='#FFA500'>[DETONATE %1]</t>", _displayName],
        {
            params ["_target", "_caller", "_actionId", "_args"];
            private _bomb = _args select 0;
            if (alive _bomb) then {
                _bomb setDamage 1; // Boom
            };
            _caller removeAction _actionId;
        },
        [_liveBomb],
        7,
        false,
        true
    ];
    
    // Safety cleanup if the bomb gets destroyed by other means (e.g. shot)
    [_liveBomb, _caller, _detActionID] spawn {
        params ["_b", "_c", "_id"];
        waitUntil {sleep 1; !alive _b || isNull _b};
        _c removeAction _id;
    };
    systemChat format ["%1 Dropped! Use scroll wheel to Detonate.", _displayName];
} else {
    // 40mm detonates on impact natively. Frag grenades detonate after fuse natively.
    systemChat "Payload Dropped!";
};
