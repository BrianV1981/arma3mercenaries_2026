/*
    arma3mercenaries\set_group_captive\setGroupCaptive_proofOfConcept.sqf
    Author: BrianV1981
    Updated: A.I.M. (Issue #24 — Stand Down / Deactivate)

    Description:
    "Stand Down (Deactivate)" — Applies ALL captive guards to AI group members.
    Sets both the vanilla SQF guards (setCaptive, allowDamage) and ACE handcuffs.

    Runs on the player's client where AI are local (correct locality for ACE calls).
*/

{
    if (!isPlayer _x) then {
        // Force dismount from vehicles or static turrets
        if (vehicle _x != _x) then {
            unassignVehicle _x;
            moveOut _x;
        };

        // Apply ACE handcuffs (visual + behavioral)
        [_x, true] call ACE_captives_fnc_setHandcuffed;

        // Apply vanilla SQF guards
        _x setCaptive true;
        _x allowDamage false;
    };
} forEach units group player;

private _count = {!isPlayer _x} count units group player;
private _a3mMsg = format ["<t align='left'><t size='0.8' color='#FFaa00'>SQUAD STAND DOWN</t><br/><t size='0.6' color='#FFFFFF'>%1 mercenaries dismounted and secured.</t></t>", _count];
[_a3mMsg, 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;
