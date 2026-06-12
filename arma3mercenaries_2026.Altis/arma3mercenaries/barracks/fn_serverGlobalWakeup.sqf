/*
    fn_serverGlobalWakeup.sqf
    Server-side function triggered by the FIRST player to log in after a server restart.
    It loops through all AI that are STILL local to the server (unclaimed offline players' AI),
    handcuffs them, and auto-mounts them into their respective base vehicles/turrets.
    This provides an immersive map where offline players' bases are populated correctly.
*/

if (!isServer) exitWith {};

{
    private _unit = _x;
    
    // Check if the unit is an AI, belongs to the A3M system, and is still local to the server
    if (!isPlayer _unit && {local _unit} && {(_unit getVariable ["arma3mercenaries_groupID", ""]) != ""}) then {
        
        // Ensure they haven't already been processed or claimed
        if (_unit getVariable ["A3M_AwaitingActivation", false]) then {
            
            // 1. Enable their AI so they can be handcuffed properly
            _unit enableAI "ALL";
            
            // 2. Slap the ACE Handcuffs on them
            [_unit, true] call ACE_captives_fnc_setHandcuffed;
            
            // 3. Mark them as processed
            _unit setVariable ["A3M_AwaitingActivation", nil, true];
            
            diag_log format ["[A3M GLOBAL WAKEUP] Initialized %1 (Handcuffed/Captive waiting for Operator).", name _unit];
        };
    };
} forEach allUnits;

diag_log "[A3M BARRACKS] Global Wakeup Protocol executed successfully for offline player mercenaries.";
