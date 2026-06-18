/*
    fn_serverShadowOpsDispatch.sqf
    Server-side validation and handoff to the Shadow Ops engine.
*/
params ["_missionData", "_selectedMercs", "_planData", "_client"];

if (!isServer) exitWith {};

_missionData params ["_missionName", "_missionDesc", "_difficulty"];

// 1. Validate all mercs are still Stowed
private _validatedMercs = [];
private _isValid = true;

{
    private _mercID = _x;
    private _profile = [format["A3M_MERC_%1", _mercID], createHashMap, true] call A3M_fnc_dbGetSecure;
    
    if (count _profile > 0) then {
        private _shadowStatus = _profile getOrDefault ["ShadowOps_Status", "Stowed"];
        if (_shadowStatus != "Stowed") then {
            _isValid = false;
        } else {
            _validatedMercs pushBack _profile;
        };
    } else {
        _isValid = false;
    };
} forEach _selectedMercs;

if (!_isValid) exitWith {
    "Error: One or more selected mercenaries are no longer available for dispatch." remoteExecCall ["systemChat", _client];
};

// 2. Lock them into Shadow Ops state in DB
{
    private _profile = _x;
    private _mercID = _profile getOrDefault ["MercID", ""];
    
    if (_mercID != "") then {
        _profile set ["ShadowOps_Status", "ShadowOps"];
        [format["A3M_MERC_%1", _mercID], _profile, true] call A3M_fnc_dbSetSecure;
    };
} forEach _validatedMercs;

// Notify Commander
format ["%1 mercenaries dispatched on '%2'. Commencing Phase 1...", count _validatedMercs, _missionName] remoteExecCall ["systemChat", _client];

// 3. Spawn the Async Story Engine Thread
[_missionData, _validatedMercs, _planData, _client] spawn A3M_fnc_serverShadowOpsThread;

