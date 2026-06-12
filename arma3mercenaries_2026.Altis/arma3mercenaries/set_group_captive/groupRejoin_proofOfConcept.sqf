/*
    arma3mercenaries\set_group_captive\groupRejoin_proofOfConcept.sqf
    Author: BrianV1981
    Updated: A.I.M. (Issue #24 — Mobilize / Reactivate)

    Description:
    "Mobilize (Reactivate)" — Removes ALL captive guards from AI group members.
    Clears both the vanilla SQF guards (setCaptive, allowDamage) set by the server
    and the ACE handcuffs applied by the client.

    Runs on the player's client where AI are local (correct locality for ACE calls).
*/

{
    private _unit = _x;
    if (!isPlayer _unit) then {
        // Remove ACE handcuffs (visual + behavioral)
        [_unit, false] call ACE_captives_fnc_setHandcuffed;

        // Remove vanilla SQF guards
        _unit setCaptive false;
        _unit allowDamage true;

        // Ensure AI brain is fully enabled
        _unit enableAI "ALL";

        // Clear activation flag
        _unit setVariable ["A3M_AwaitingActivation", nil, true];
    };
} forEach units group player;

systemChat format ["[A3M] %1 mercenaries mobilized and combat-ready.", {!isPlayer _x} count units group player];
