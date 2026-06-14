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

// Map Magazine class to Armed Projectile class (The Cleaner Solution)
private _ammoClass = "G_40mm_HE"; // Fallback
if ("Satchel" in _payloadClass) then { _ammoClass = "Bo_GBU12_LGB"; }; // Massive bomb
if ("Demo" in _payloadClass) then { _ammoClass = "R_TBG32V_F"; }; // Rocket explosion
if ("ACE_M14" in _payloadClass) then { _ammoClass = "Sh_155mm_AMOS"; }; // Huge artillery blast for WP simulation
if ("Hand" in _payloadClass) then { _ammoClass = "GrenadeHand"; };
if ("Mini" in _payloadClass) then { _ammoClass = "mini_Grenade"; };
if ("1Rnd" in _payloadClass) then { _ammoClass = "G_40mm_HE"; };

// Spawn the LIVE armed projectile
private _liveBomb = _ammoClass createVehicle [0,0,0];
_liveBomb setPosASL _pos;
_liveBomb setDir _dir;

// Calculate inherited velocity, and forcefully pitch it downward so it detonates instantly on impact
_liveBomb setVectorDirAndUp [[0, 0, -1], [0, 1, 0]]; 
_liveBomb setVelocity [(_vel select 0), (_vel select 1), (_vel select 2) - 15];

private _displayName = getText (configFile >> "CfgMagazines" >> _payloadClass >> "displayName");
systemChat format ["%1 Dropped! Brace for impact.", _displayName];

// --- A3M DEEP STAT TRACKING: Drone Operator (#68) ---
if (!isNull _caller) then {
    [_caller, "Drone_Strikes_Dropped"] remoteExecCall ["A3M_fnc_serverIncrementStat", 2];
};
