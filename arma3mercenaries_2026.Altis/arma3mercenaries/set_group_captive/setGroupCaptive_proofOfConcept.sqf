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
        // Apply ACE handcuffs (visual + behavioral)
        [_x, true] call ACE_captives_fnc_setHandcuffed;

        // Apply vanilla SQF guards
        _x setCaptive true;
        _x allowDamage false;
    };
} forEach units group player;

systemChat format ["[A3M] %1 mercenaries standing down.", {!isPlayer _x} count units group player];
