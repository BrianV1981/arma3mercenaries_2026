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

A3M_compHALO = {
    private _plyr = _this;
    A3M_fnc_orient = {
        private _obj = _this select 0;
        private _p = _this select 1;
        _obj setVectorDirAndUp [
            [0, cos _p, sin _p],
            [[0, -sin _p, cos _p], 0] call BIS_fnc_rotateVector2D
        ];
    };
    _plyr setVariable ['bpk', unitBackpack _plyr];
    if (backpack _plyr != '') then {
        private _whs = createVehicle ['WeaponHolderSimulated_Scripted', getpos _plyr, [], 0, 'can_collide'];
        _plyr action ['DropBag', _whs, typeOf (_plyr getVariable 'bpk')];
        ['EHid', 'onEachFrame', {
            params ['_plyr', '_whs'];
            if (backpack _plyr != 'B_parachute') then {
                _plyr action ['dropBag', _whs, typeOf (_plyr getVariable 'bpk')];
                _plyr action ['AddBag', _whs, 'B_Parachute'];
            };
            call {
                if (stance _plyr == 'UNDEFINED') exitWith {
                    _whs attachTo [_plyr, [-0.1, -0.05, -0.7], 'leaning_axis'];
                    [_whs, -180] call A3M_fnc_orient;
                };
                if (stance _plyr != 'UNDEFINED') exitWith {
                    _whs attachTo [_plyr, [-0.1, 0.75, -0.05], 'leaning_axis'];
                    [_whs, -90] call A3M_fnc_orient;
                };
            };
            if (isNil {_plyr getVariable ['bpk', nil]}) then {
                ['EHid', 'onEachFrame'] call BIS_fnc_removeStackedEventHandler;
            };
        }, [_plyr, _whs]] call BIS_fnc_addStackedEventHandler;
    };
};

A3M_HALO_MapClick_EH = addMissionEventHandler ["MapSingleClick", {
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
        private _jump_safety = 90;

        if (_jumpType == "SOLO") then {
            [player, 0, _pos, _jump_alt, _jump_safety] spawn {
                params ["_unit","_index","_pos","_jump_alt","_jump_safety"];
                private ["_bpk","_bpktype","_whs","_para"];
                _unit call A3M_compHALO;
                uiSleep 2;
                _unit allowDamage false;
                _unit setPos [(_pos select 0), (_pos select 1), (_jump_alt max 200)];
                waitUntil {(getPos _unit select 2) > _jump_safety - 50};
                uiSleep 0.2;
                _bpk = _unit getVariable "bpk";
                _bpktype = typeOf (_unit getVariable "bpk");
                _whs = objectParent _bpk;
                _unit addBackpackGlobal "B_parachute";
                waitUntil {(getPos _unit select 2) < _jump_safety or !isNull objectParent player};
                _unit allowDamage true;
                if (!isTouchingGround _unit) then { _unit action ["OpenParachute", _unit]; };
                _para = objectParent _unit;
                waitUntil {!isNull _para};
                _para allowDamage false;
                waitUntil {sleep 0.5; (isTouchingGround _unit && isNull _para) or surfaceIsWater (getpos _unit) or !alive _unit};
                _unit setVariable ["bpk",nil];
                waitUntil {isNull _para};
                deleteVehicle _para;
                sleep 0.5;
                detach _whs;
                if (!isNull _whs) then {
                    _unit action ["AddBag", objectParent _bpk, _bpktype];
                    sleep 2;
                    deleteVehicle _whs;
                };
            };
        } else {
            private _MGI_units = (units player) select {local _x && alive _x && _x distanceSqr player < 100000 && isNull objectParent _x};
            {
                [_x, _forEachIndex, _pos, _jump_alt, _jump_safety] spawn {
                    params ["_unit","_index","_pos","_jump_alt","_jump_safety"];
                    if (isPlayer _unit) then { _unit call A3M_compHALO; };
                    uiSleep 2;
                    _unit allowDamage false;
                    _unit setPos [(_pos select 0)-60 + random 30, (_pos select 1)-60 + random 30, (_jump_alt max 200) + (12 * _index)];
                    waitUntil {(getPos _unit select 2) > _jump_safety - 50};
                    uiSleep 0.2;
                    if (isPlayer _unit) then {
                        _bpk = _unit getVariable "bpk";
                        _bpktype = typeOf (_unit getVariable "bpk");
                        _whs = objectParent _bpk;
                        _unit addBackpackGlobal "B_parachute";
                    };
                    waitUntil {(getPos _unit select 2) < ([_jump_safety max 90, _jump_safety] select (isPlayer _unit)) + 20 or (!isNull objectParent player)};
                    if (!isPlayer _unit) then {
                        uiSleep 0.8;
                        _chute = createVehicle ["Steerable_Parachute_F", getPos _unit, [], 0, "can_collide"];
                        _unit moveInDriver _chute;
                        _unit allowDamage true;
                    } else {
                        _unit allowDamage true;
                        if (!isTouchingGround _unit) then { _unit action ["OpenParachute", _unit]; };
                        _para = objectParent _unit;
                        waitUntil {!isNull _para};
                        _para allowDamage false;
                        waitUntil {sleep 0.5; (isTouchingGround _unit && isNull _para) or surfaceIsWater (getpos _unit) or !alive _unit};
                        _unit setVariable ["bpk",nil];
                        waitUntil {isNull _para};
                        deleteVehicle _para;
                        sleep 0.5;
                        detach _whs;
                        if (!isNull _whs) then {
                            _unit action ["AddBag", objectParent _bpk, _bpktype];
                            sleep 2;
                            deleteVehicle _whs;
                        };
                    };
                };
            } forEach _MGI_units;
        };
    } else {
        systemChat "[A3M] HALO Drop Aborted. You can open map to try again.";
        removeMissionEventHandler ["MapSingleClick", A3M_HALO_MapClick_EH];
    };
}];
