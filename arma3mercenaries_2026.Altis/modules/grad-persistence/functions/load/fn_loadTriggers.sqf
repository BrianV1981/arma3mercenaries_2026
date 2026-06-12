#include "script_component.hpp"

if (!isServer) exitWith {};

private _missionTag = [] call FUNC(getMissionTag);
private _triggersTag = _missionTag + "_triggers";

private _reExecute = ([missionConfigFile >> "CfgGradPersistence", "saveTriggers", 0] call BIS_fnc_returnConfigEntry) == 2;

// --- A.I.M. v812+ Architecture: SQLite Per-Entity Loading ---
private _countKey = format ["%1_COUNT", _triggersTag];
private _dbCount = [_countKey, -1, false] call A3M_fnc_dbGetSecure;

private _triggersData = [];

if (_dbCount > -1) then {
    // New Iterative Architecture
    for "_i" from 0 to (_dbCount - 1) do {
        private _uniqueEntityKey = format ["%1_trig_%2", _triggersTag, _i];
        // Fetch native HashMap. Note the 'true' parameter for HashMap reconstruction.
        private _entityHash = [_uniqueEntityKey, createHashMap, true] call A3M_fnc_dbGetSecure;
        
        if (count _entityHash > 0) then {
            _triggersData pushBack _entityHash;
        };
    };
};

{
    private _thisTriggerHash = _x;
    private _vehVarName = _thisTriggerHash getOrDefault ["varName", ""];

    private _thisTrigger = objNull;
    private _editorVehicleFound = false;
    if (_vehVarName != "") then {
        // editor-placed object that already exists
        private _editorVehicle = call compile _vehVarName;
        if (!isNil "_editorVehicle") then {
            _thisTrigger = _editorVehicle;
            _editorVehicleFound = true;
        };
    };

    if (!_editorVehicleFound) then {
        _thisTrigger = createTrigger ["EmptyDetector",[0,0,0]];

        if (_vehVarName != "") then {
            [_thisTrigger,_vehVarName] remoteExec ["setVehicleVarName",0,_thisTrigger];
        };
    };



    [{!isNull (_this select 0)}, {
        params ["_thisTrigger","_thisTriggerHash","_reExecute"];

        private _posASL = _thisTriggerHash getOrDefault ["posASL", [0,0,0]];
        private _activated = _thisTriggerHash getOrDefault ["activated", false];
        private _activation = _thisTriggerHash getOrDefault ["activation", []];
        private _area = _thisTriggerHash getOrDefault ["area", [0,0,0,false]];
        private _statements = _thisTriggerHash getOrDefault ["statements", ["","",""]];
        private _timeout = _thisTriggerHash getOrDefault ["timeout", [0,0,0,false]];
        private _text = _thisTriggerHash getOrDefault ["text", ""];
        private _type = _thisTriggerHash getOrDefault ["type", "NONE"];
        private _triggerReExecute = _thisTriggerHash getOrDefault ["reExecute", nil]; // use nil to mirror old behavior

        _thisTrigger setPosASL _posASL;
        _thisTrigger setTriggerArea _area;
        _thisTrigger setTriggerText _text;
        _thisTrigger setTriggerType _type;
        _thisTrigger setTriggerActivation _activation;

        if (_activated) then {
            if (
                (!isNil "_triggerReExecute" && {_triggerReExecute}) ||
                {isNil "_triggerReExecute" && {_reExecute}}
            ) then {
                _thisTrigger setTriggerStatements ["true",_statements select 1,_statements select 2];
            } else {
                _thisTrigger setTriggerStatements ["true","true","true"];
            };

            [{triggerActivated (_this select 0)},{
                params ["_thisTrigger","_statements","_timeout"];
                _thisTrigger setTriggerStatements _statements;
                _thisTrigger setTriggerTimeout _timeout;

            },[_thisTrigger,_statements,_timeout]] call CBA_fnc_waitUntilAndExecute;
        } else {
            _thisTrigger setTriggerStatements _statements;
            _thisTrigger setTriggerTimeout _timeout;
        };

        private _vars = _thisTriggerHash getOrDefault ["vars", []];
        [_vars,_thisTrigger] call FUNC(loadObjectVars);

    }, [_thisTrigger,_thisTriggerHash,_reExecute]] call CBA_fnc_waitUntilAndExecute;
} forEach _triggersData;
