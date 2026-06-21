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
        _unit setVariable ["ace_medical_allowDamage", true, true];

        // Ensure AI brain is fully enabled
        _unit enableAI "ALL";

        // Clear activation flag
        _unit setVariable ["A3M_AwaitingActivation", nil, true];
    };
} forEach units group player;

private _count = {!isPlayer _x} count units group player;
private _a3mMsg = format ["<t align='left'><t size='0.8' color='#FFaa00'>SQUAD MOBILIZED</t><br/><t size='0.6' color='#FFFFFF'>%1 mercenaries mobilized and combat-ready.</t></t>", _count];
[_a3mMsg, 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;
