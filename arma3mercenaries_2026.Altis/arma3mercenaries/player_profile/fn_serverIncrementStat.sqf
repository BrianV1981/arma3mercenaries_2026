/*
    arma3mercenaries\player_profile\fn_serverIncrementStat.sqf
    Author: A.I.M.
    Description: Generic generic function to increment a simple integer stat in a player's profile database.
*/
params ["_player", "_statName", ["_amount", 1]];

if (!isServer) exitWith {};
if (isNull _player || !isPlayer _player) exitWith {};
if (isNil "A3M_LiveProfiles") exitWith {};

private _uid = getPlayerUID _player;
if (_uid == "") exitWith {};

private _profile = A3M_LiveProfiles getOrDefault [_uid, createHashMap];
if (count _profile == 0) exitWith {};

_profile set [_statName, (_profile getOrDefault [_statName, 0]) + _amount];

A3M_LiveProfiles set [_uid, _profile];
["A3M_PROFILE_" + _uid, _profile] call A3M_fnc_dbSetSecure;
