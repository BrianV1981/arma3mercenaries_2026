#include "script_component.hpp"

if (!isServer) exitWith {};

private _missionTag = [] call FUNC(getMissionTag);
private _staticsTag = _missionTag + "_statics";

// --- A.I.M. v812+ Architecture: SQLite Per-Entity Loading ---
private _countKey = format ["%1_COUNT", _staticsTag];
private _dbCount = [_countKey, -1, false] call A3M_fnc_dbGetSecure;

private _staticsData = [];

if (_dbCount > -1) then {
    // New Iterative Architecture
    for "_i" from 0 to (_dbCount - 1) do {
        private _uniqueEntityKey = format ["%1_stat_%2", _staticsTag, _i];
        // Fetch native HashMap. Note the 'true' parameter for HashMap reconstruction.
        private _entityHash = [_uniqueEntityKey, createHashMap, true] call A3M_fnc_dbGetSecure;
        
        if (count _entityHash > 0) then {
            _staticsData pushBack _entityHash;
        };
    };
};

{
    private _thisStaticHash = _x;
    private _vehVarName = _thisStaticHash getOrDefault ["varName", ""];

    private _thisStatic = objNull;
    private _editorVehicleFound = false;
    if (_vehVarName != "") then {
        // editor-placed object that already exists
        private _editorVehicle = call compile _vehVarName;
        if (!isNil "_editorVehicle") then {
            _thisStatic = _editorVehicle;
            _editorVehicleFound = true;
        };
    };

    if (!_editorVehicleFound) then {
        private _type = _thisStaticHash getOrDefault ["type", ""];
        _thisStatic = createVehicle [_type,[0,0,0],[],0,"CAN_COLLIDE"];

        if (_vehVarName != "") then {
            [_thisStatic,_vehVarName] remoteExec ["setVehicleVarName",0,_thisStatic];
        };
    };


    [{!isNull (_this select 0)}, {
        params ["_thisStatic","_thisStaticHash"];

        private _posASL = _thisStaticHash getOrDefault ["posASL", [0,0,0]];
        private _vectorDirAndUp = _thisStaticHash getOrDefault ["vectorDirAndUp", [[0,1,0],[0,0,1]]];
        private _damage = _thisStaticHash getOrDefault ["damage", 0];
        private _isGradMoneymenuStorage = _thisStaticHash getOrDefault ["isGradMoneymenuStorage", false];
        private _gradMoneymenuOwner = _thisStaticHash getOrDefault ["gradMoneymenuOwner", objNull];
        private _thisLbmMoney = _thisStaticHash getOrDefault ["gradLbmMoney", 0];

        _thisStatic setVectorDirAndUp _vectorDirAndUp;
        _thisStatic setPosASL _posASL;
        _thisStatic setDamage _damage;

        if (_isGradMoneymenuStorage && {!(_gradMoneymenuOwner isEqualType false)}) then {
            if !(objNull isEqualTo _gradMoneymenuOwner) then {
                [_thisStatic,_gradMoneymenuOwner] remoteExec ["grad_moneymenu_fnc_setStorage",0,true];
            } else {
                [_thisStatic] remoteExec ["grad_moneymenu_fnc_setStorage",0,true];
            };

            if (_thisLbmMoney isEqualType 0 && {_thisLbmMoney > 0}) then {
                _thisStatic setVariable ["grad_lbm_myFunds",_thisLbmMoney,true];
            };
        };

        private _vars = _thisStaticHash getOrDefault ["vars", []];
        [_vars,_thisStatic] call FUNC(loadObjectVars);

        // --- A.I.M. ACE Cargo Auto-Load ---
        private _aceParentVar = _thisStaticHash getOrDefault ["aceParentVar", ""];
        if (_aceParentVar != "") then {
            // Because parent vehicles spawn in a parallel script, we wait 2 seconds to guarantee they exist
            [{
                params ["_thisStatic", "_aceParentVar"];
                private _parentVeh = call compile _aceParentVar;
                if (!isNil "_parentVeh" && {!isNull _parentVeh}) then {
                    private _lockState = locked _parentVeh;
                    if (_lockState >= 2) then { _parentVeh lock 0; };
                    [_thisStatic, _parentVeh, true] call ace_cargo_fnc_loadItem;
                    if (_lockState >= 2) then { _parentVeh lock _lockState; };
                };
            }, [_thisStatic, _aceParentVar], 2] call CBA_fnc_waitAndExecute;
        };

    }, [_thisStatic,_thisStaticHash]] call CBA_fnc_waitUntilAndExecute;

} forEach _staticsData;

// --- A.I.M. v812+ Architecture: Delete SQLite Killed Statics ---
private _killedVarnamesKey = format ["%1_killedVarnames", _missionTag];
private _killedVarnames = [_killedVarnamesKey, [[],[],[],[]]] call A3M_fnc_dbGetSecure;
private _killedStaticsVarnames = _killedVarnames param [3,[]];

{
    private _editorVehicle = call compile _x;
    if (!isNil "_editorVehicle") then {deleteVehicle _editorVehicle};
} forEach _killedStaticsVarnames;
