/*
    A3M_fnc_armKamikaze
    Arms a drone payload for Kamikaze Mode (Explode on Impact/Death or Manual Detonation)
*/
params ["_drone", "_caller"];

private _dummy = _drone getVariable ["A3M_Payload", objNull];
if (isNull _dummy) exitWith { systemChat "No payload attached."; };

// Remove existing Drop and Arm actions
private _dropActionID = _drone getVariable ["A3M_Payload_ActionID", -1];
if (_dropActionID != -1) then { _drone removeAction _dropActionID; };

private _armActionID = _drone getVariable ["A3M_Kamikaze_ActionID", -1];
if (_armActionID != -1) then { _drone removeAction _armActionID; };

// Flag as armed
_drone setVariable ["A3M_KamikazeArmed", true, true];

systemChat "KAMIKAZE MODE ARMED! The drone will detonate on impact or if destroyed.";

// Provide an Airburst / Manual Detonate override
private _detonateActionID = _drone addAction [
    "<t color='#FFA500'>[DETONATE KAMIKAZE]</t>",
    {
        params ["_droneTarget", "_actionCaller", "_actionId", "_arguments"];
        _droneTarget setDamage 1; // Killing the drone triggers the payload explosion
    },
    nil,
    7,
    false,
    true,
    "",
    "driver _target == _this || gunner _target == _this"
];
_drone setVariable ["A3M_Kamikaze_DetonateActionID", _detonateActionID, true];

// Add the Impact / Death Event Handler
// Note: We use MPKilled to ensure it runs where the drone is local
_drone addEventHandler ["Killed", {
    params ["_killedDrone", "_killer", "_instigator", "_useEffects"];
    
    private _payloadClass = _killedDrone getVariable ["A3M_Payload_Class", ""];
    if (_payloadClass == "") exitWith {};

    // --- A3M DEEP STAT TRACKING: Drone Operator (#68) ---
    if (!isNull _instigator && isPlayer _instigator) then {
        [_instigator, "Drone_Kamikaze_Kills"] remoteExecCall ["A3M_fnc_serverIncrementStat", 2];
    } else {
        // Fallback: If Arma engine doesn't return the instigator, fetch the UAV controller
        private _controller = (UAVControl _killedDrone) select 0;
        if (!isNull _controller && isPlayer _controller) then {
            [_controller, "Drone_Kamikaze_Kills"] remoteExecCall ["A3M_fnc_serverIncrementStat", 2];
        };
    };

    private _pos = getPosASL _killedDrone;
    
    // Map Magazine class to Armed Projectile class
    private _ammoClass = "G_40mm_HE"; // Fallback
    if ("Satchel" in _payloadClass) then { _ammoClass = "Bo_GBU12_LGB"; }; 
    if ("Demo" in _payloadClass) then { _ammoClass = "R_TBG32V_F"; }; 
    if ("ACE_M14" in _payloadClass) then { _ammoClass = "Sh_155mm_AMOS"; }; 
    if ("Hand" in _payloadClass) then { _ammoClass = "GrenadeHand"; };
    if ("Mini" in _payloadClass) then { _ammoClass = "mini_Grenade"; };
    if ("1Rnd" in _payloadClass) then { _ammoClass = "G_40mm_HE"; };

    // Clean up the dummy object if it hasn't been destroyed yet
    private _dummy = _killedDrone getVariable ["A3M_Payload", objNull];
    if (!isNull _dummy) then { deleteVehicle _dummy; };

    // Spawn the explosion
    private _liveBomb = _ammoClass createVehicle [0,0,0];
    _liveBomb setPosASL _pos;
    
    // Force immediate detonation by setting its damage to 1, guaranteeing it explodes even mid-air
    _liveBomb setDamage 1;
}];
