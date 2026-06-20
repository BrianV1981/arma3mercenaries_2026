/*
    arma3mercenaries\set_group_captive\groupMountTurrets.sqf
    Author: BrianV1981 / A.I.M.
    Description:
    "Mount Nearest Turret" — Removes all captive guards from AI group members
    and automatically mounts them into the nearest vehicle's turrets.
*/

params [["_radius", 50]];

private _index = 0;
{
    private _unit = _x;
    if (!isPlayer _unit) then {
        [{
            params ["_unit", "_radius"];
            
            // Remove ACE handcuffs (visual + behavioral)
            [_unit, false] call ACE_captives_fnc_setHandcuffed;

            // Remove vanilla SQF guards
            _unit setCaptive false;
            _unit allowDamage true;

            // Ensure AI brain is fully enabled
            _unit enableAI "ALL";

            // Clear activation flag
            _unit setVariable ["A3M_AwaitingActivation", nil, true];

            // Scan for nearest vehicles around the unit (their nearest turret)
            private _nearestVehicles = nearestObjects [_unit, ["LandVehicle", "Air", "Ship", "StaticWeapon"], _radius];
            private _mounted = false;

            {
                private _vehicle = _x;
                if (!_mounted) then {
                    private _ownerArray = _vehicle getVariable ["HG_Owner", []];
                    private _hasKey = true;
                    if (count _ownerArray > 0) then {
                        _hasKey = (((_ownerArray select 0) == getPlayerUID player) || {getPlayerUID player in (_ownerArray select 3)});
                    };
                    
                    // Only process this vehicle if it is unlocked OR the player has the key
                    if ((locked _vehicle < 2) || _hasKey) then {
                        private _allSeats = fullCrew [_vehicle, "", true];
                    
                    // Priority 1: Turrets (Gunner, Commander, Turret)
                    {
                        _x params ["_occupant", "_role", "_cargoIndex", "_turretPath", "_personTurret"];
                        if (!_mounted && {isNull _occupant} && {_role in ["gunner", "commander", "turret"]}) then {
                            if ((locked _vehicle) >= 2) then { [_vehicle] call HG_fnc_lockOrUnlock; }; // Unlock via HG BEFORE assigning so engine doesn't eject them
                            if (_role == "gunner") then { _unit assignAsGunner _vehicle; };
                            if (_role == "commander") then { _unit assignAsCommander _vehicle; };
                            if (_role == "turret") then { _unit assignAsTurret [_vehicle, _turretPath]; };
                            
                            [_unit] orderGetIn true;
                            _unit moveInTurret [_vehicle, _turretPath];
                            _mounted = true;
                        };
                    } forEach _allSeats;

                    // Priority 2: Driver
                    if (!_mounted) then {
                        {
                            _x params ["_occupant", "_role", "_cargoIndex", "_turretPath", "_personTurret"];
                            if (!_mounted && {isNull _occupant} && {_role == "driver"}) then {
                                if ((locked _vehicle) >= 2) then { [_vehicle] call HG_fnc_lockOrUnlock; };
                                _unit assignAsDriver _vehicle;
                                [_unit] orderGetIn true;
                                _unit moveInDriver _vehicle;
                                _mounted = true;
                            };
                        } forEach _allSeats;
                    };

                    // Priority 3: Cargo
                    if (!_mounted) then {
                        {
                            _x params ["_occupant", "_role", "_cargoIndex", "_turretPath", "_personTurret"];
                            if (!_mounted && {isNull _occupant} && {_role == "cargo"}) then {
                                if ((locked _vehicle) >= 2) then { [_vehicle] call HG_fnc_lockOrUnlock; };
                                _unit assignAsCargoIndex [_vehicle, _cargoIndex];
                                [_unit] orderGetIn true;
                                _unit moveInCargo [_vehicle, _cargoIndex];
                                _mounted = true;
                            };
                        } forEach _allSeats;
                    };
                    }; // Closes the _hasKey check
                };
            } forEach _nearestVehicles;
        }, [_unit, _radius], _index * 0.5] call CBA_fnc_waitAndExecute;
        
        _index = _index + 1;
    };
} forEach units group player;

private _a3mMsg = "<t align='left'><t size='0.8' color='#FFaa00'>SQUAD QUICK LOAD</t><br/><t size='0.6' color='#FFFFFF'>Squad mobilized and mounting nearest vehicles.</t></t>";
[_a3mMsg, 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;
