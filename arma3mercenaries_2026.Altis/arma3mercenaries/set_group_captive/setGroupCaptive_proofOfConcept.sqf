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
        [_x] spawn {
            params ["_unit"];
            
            // Force dismount from vehicles or static turrets
            if (vehicle _unit != _unit) then {
                unassignVehicle _unit;
                moveOut _unit;
                
                // Wait for the engine to physically detach them from the turret/vehicle
                waitUntil { sleep 0.1; vehicle _unit == _unit };
                sleep 0.5; // Allow animation state to settle
            };

            // Apply vanilla SQF guards
            _unit setCaptive true;
            _unit allowDamage false;
            
            // Apply ACE handcuffs (visual + behavioral) ONLY when safely on foot
            [_unit, true] call ACE_captives_fnc_setHandcuffed;
        };
    };
} forEach units group player;

private _count = {!isPlayer _x} count units group player;
private _a3mMsg = format ["<t align='left'><t size='0.8' color='#FFaa00'>SQUAD STAND DOWN</t><br/><t size='0.6' color='#FFFFFF'>%1 mercenaries dismounted and secured.</t></t>", _count];
[_a3mMsg, 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;
