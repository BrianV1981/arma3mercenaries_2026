/*
    arma3mercenaries\player_profile\fn_serverLogRevive.sqf
    Author: A.I.M.
    Description: Called by clients when they successfully apply major ACE medical aid to an unconscious unit.
*/
params ["_medic", "_patientName", "_treatmentType"];

if (!isServer) exitWith {};
if (isNull _medic || !isPlayer _medic) exitWith {};
if (isNil "A3M_LiveProfiles") exitWith {};

private _medicUID = getPlayerUID _medic;
if (_medicUID == "") exitWith {};

private _profile = A3M_LiveProfiles getOrDefault [_medicUID, createHashMap];
if (count _profile == 0) exitWith {};

// Increment Revive Count
_profile set ["Medical_Revives_Performed", (_profile getOrDefault ["Medical_Revives_Performed", 0]) + 1];

// Add to Last 100 Saved
private _lastSaved = _profile getOrDefault ["Last_100_Saved", []];
private _saveEntry = [serverTime, _patientName, _treatmentType];
_lastSaved insert [0, [_saveEntry]];
if (count _lastSaved > 100) then { _lastSaved resize 100; };
_profile set ["Last_100_Saved", _lastSaved];

// Save to Profile Memory and SQLite DB
A3M_LiveProfiles set [_medicUID, _profile];
["A3M_PROFILE_" + _medicUID, _profile] call A3M_fnc_dbSetSecure;

diag_log format ["[A3M STATS] UID %1 administered life-saving aid to %2 (%3)", _medicUID, _patientName, _treatmentType];
