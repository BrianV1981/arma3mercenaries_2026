/*
    arma3mercenaries\set_group_captive\setGroupCaptive_proofOfConcept.sqf
    Author: BrianV1981
    Updated: A.I.M. (Issue #24 — Stand Down / Deactivate)

    Description:
    "Stand Down (Deactivate)" — Applies ALL captive guards to AI group members.
    Forces them to disembark any vehicles/turrets using proper orderGetIn logic,
    and then applies vanilla SQF guards and ACE handcuffs.
*/

private _index = 0;
{
    private _unit = _x;
    if (!isPlayer _unit) then {
        [{
            params ["_unit"];
            
            private _veh = vehicle _unit;
            
            // Force dismount from vehicles or static turrets
            if (_veh != _unit) then {
                // If vehicle is locked, unlock it so the AI can physically get out
                if ((locked _veh) >= 2) then {
                    [_veh] call HG_fnc_lockOrUnlock;
                };

                [_unit] orderGetIn false;
                [_unit] allowGetIn false;
                unassignVehicle _unit;
                doGetOut _unit;
                
                // Backup: Force them out instantly if they are stubborn
                moveOut _unit; 
            };

            // Wait 0.8 seconds for them to hit the ground before applying cuffs.
            [{
                params ["_unit", "_veh"];
                
                // ALWAYS lock the vehicle after they dismount (per user directive)
                if (_veh != _unit) then {
                    if ((locked _veh) < 2) then {
                        [_veh] call HG_fnc_lockOrUnlock;
                    };
                };
                
                // Apply vanilla SQF guards
                _unit setCaptive true;
                _unit allowDamage false;
                _unit setVariable ["ace_medical_allowDamage", false, true];
                
                // Disable their AI brain so they don't try to wander or re-mount
                _unit disableAI "ALL";
                
                // Mark them as deactivated
                _unit setVariable ["A3M_AwaitingActivation", true, true];
                
                    [_unit, true] call ACE_captives_fnc_setHandcuffed;
            }, [_unit, _veh], 0.8] call CBA_fnc_waitAndExecute;

        }, [_unit], _index * 0.5] call CBA_fnc_waitAndExecute;
        
        _index = _index + 1;
    };
} forEach units group player;

private _count = {!isPlayer _x} count units group player;
private _a3mMsg = format ["<t align='left'><t size='0.8' color='#FFaa00'>SQUAD STAND DOWN</t><br/><t size='0.6' color='#FFFFFF'>%1 mercenaries dismounted and secured.</t></t>", _count];
[_a3mMsg, 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;
