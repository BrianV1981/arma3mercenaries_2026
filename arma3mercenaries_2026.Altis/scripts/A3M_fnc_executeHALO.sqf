params [["_jumpType", "SOLO"]];

if (!alive player || {player getVariable ["ACE_isUnconscious", false]}) exitWith {
    systemChat "[A3M] HALO aborted. Operator is incapacitated.";
};

systemChat "[A3M] Select HALO Drop Coordinates on the map.";
openMap [true, false];

if (!isNil "A3M_HALO_MapClick_EH") then {
    removeMissionEventHandler ["MapSingleClick", A3M_HALO_MapClick_EH];
};

player setVariable ["A3M_Halo_ActiveType", _jumpType];

A3M_HALO_MapClick_EH = addMissionEventHandler ["MapSingleClick", {
    _this spawn {
        params ["_units", "_pos", "_alt", "_shift"];
        
        if (!alive player || {player getVariable ["ACE_isUnconscious", false]}) exitWith {
            systemChat "[A3M] HALO aborted. Operator is incapacitated.";
            removeMissionEventHandler ["MapSingleClick", A3M_HALO_MapClick_EH];
            openMap [false, false];
        };

        private _confirm = [
            "Execute HALO Drop at these coordinates?", 
            "HALO INSERTION", 
            "EXECUTE", 
            "ABORT"
        ] call BIS_fnc_guiMessage;

        if (_confirm) then {
            removeMissionEventHandler ["MapSingleClick", A3M_HALO_MapClick_EH];
            openMap [false, false];

            private _jumpType = player getVariable ["A3M_Halo_ActiveType", "SOLO"];
            
            if (_jumpType == "SOLO") then {
                player setVariable ["A3M_Halo_Solo", false, true];
            } else {
                player setVariable ["A3M_Halo_Squad", false, true];
            };

            private _markerName = format ["A3M_HALO_MKR_%1_%2", getPlayerUID player, time];
            private _marker = createMarker [_markerName, _pos];
            _marker setMarkerType "hd_destroy";
            _marker setMarkerColor ([side player, true] call BIS_fnc_sideColor);
            _marker setMarkerText (format ["HALO INSERTION: %1", name player]);
            
            [_marker] spawn {
                sleep 120;
                deleteMarker (_this select 0);
            };

            private _jump_alt = 2000;
            private _jump_safety = 120;

            private _fnc_jumpUnit = {
                params ["_unit", "_index", "_pos", "_jump_alt", "_jump_safety"];
                
                // Hide and detach backpack gracefully
                private _bpkClass = backpack _unit;
                private _whs = objNull;

                if (_bpkClass != "") then {
                    _whs = createVehicle ["WeaponHolderSimulated_Scripted", getPos _unit, [], 0, "can_collide"];
                    _whs hideObjectGlobal true;
                    _unit action ["DropBag", _whs, _bpkClass];
                    waitUntil {sleep 0.1; backpack _unit == ""};
                    _whs attachTo [_unit, [0,0,0]];
                };

                uiSleep 2;
                _unit allowDamage false;
                _unit setPos [(_pos select 0) - 60 + random 30, (_pos select 1) - 60 + random 30, (_jump_alt max 200) + (12 * _index)];
                
                waitUntil {(getPos _unit select 2) > _jump_safety - 50};
                uiSleep 0.2;
                
                if (isPlayer _unit) then {
                    _unit addBackpackGlobal "B_parachute";
                };

                waitUntil {(getPos _unit select 2) < ([_jump_safety max 120, _jump_safety] select (isPlayer _unit)) + 20 || (!isNull objectParent player)};
                
                if (!isPlayer _unit) then {
                    // AI Chute Logic - NO B_parachute backpack to prevent double deployment
                    uiSleep 0.8;
                    private _chute = createVehicle ["Steerable_Parachute_F", getPos _unit, [], 0, "FLY"];
                    _chute setPos (getPos _unit);
                    _unit moveInDriver _chute;
                    _unit allowDamage true;
                    
                    waitUntil {sleep 0.5; (isTouchingGround _unit && isNull objectParent _unit) || surfaceIsWater (getpos _unit) || !alive _unit};
                } else {
                    // Player Chute Logic
                    _unit allowDamage true;
                    if (!isTouchingGround _unit && {isNull objectParent _unit}) then { _unit action ["OpenParachute", _unit]; };
                    
                    private _para = objectParent _unit;
                    waitUntil {!isNull _para};
                    _para allowDamage false;
                    
                    waitUntil {sleep 0.5; (isTouchingGround _unit && isNull _para) || surfaceIsWater (getpos _unit) || !alive _unit};
                    
                    if (!isNull _para) then {
                        deleteVehicle _para;
                    };
                };

                // Restore Backpack safely
                removeBackpackGlobal _unit;
                sleep 0.5;
                if (!isNull _whs) then {
                    detach _whs;
                    _unit action ["AddBag", _whs, _bpkClass];
                    waitUntil {sleep 0.5; backpack _unit == _bpkClass};
                    deleteVehicle _whs;
                };
            };

            if (_jumpType == "SOLO") then {
                [player, 0, _pos, _jump_alt, _jump_safety] spawn _fnc_jumpUnit;
            } else {
                private _MGI_units = (units player) select {local _x && alive _x && _x distanceSqr player < 100000 && isNull objectParent _x};
                {
                    [_x, _forEachIndex, _pos, _jump_alt, _jump_safety] spawn _fnc_jumpUnit;
                } forEach _MGI_units;
            };

        } else {
            systemChat "[A3M] HALO Drop Aborted. You can open map to try again.";
            removeMissionEventHandler ["MapSingleClick", A3M_HALO_MapClick_EH];
        };
    };
}];
