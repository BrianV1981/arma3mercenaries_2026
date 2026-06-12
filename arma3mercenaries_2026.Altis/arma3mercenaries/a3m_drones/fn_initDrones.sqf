/*
    A3M Drone Payload System
    Init Script - Registers ACE interactions globally
*/
if (!hasInterface) exitWith {};

// Wait for ACE to initialize
waitUntil {!isNil "ace_interact_menu_fnc_createAction"};

// Add the action to UAVs
private _action = [
    "A3M_AttachPayload",
    "Attach Explosive",
    "",
    { [_target, player] call A3M_fnc_attachPayload; },
    {
        alive _target && 
        {isNull (_target getVariable ["A3M_Payload", objNull])} &&
        {
            ("DemoCharge_Remote_Mag" in (magazines player)) ||
            ("SatchelCharge_Remote_Mag" in (magazines player)) ||
            ("MiniGrenade" in (magazines player)) ||
            ("HandGrenade" in (magazines player)) ||
            ("1Rnd_HE_Grenade_shell" in (magazines player))
        }
    }
] call ace_interact_menu_fnc_createAction;

["UAV_01_base_F", 0, ["ACE_MainActions"], _action, true] call ace_interact_menu_fnc_addActionToClass;
