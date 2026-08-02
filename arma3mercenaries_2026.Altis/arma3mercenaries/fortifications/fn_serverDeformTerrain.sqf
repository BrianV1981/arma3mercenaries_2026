// arma3mercenaries_2026.Altis/arma3mercenaries/fortifications/fn_serverDeformTerrain.sqf
/*
    A3M True Terrain-Deforming Trenches (Issue #127)
    Author: A.I.M.
*/
params ["_targetPos", "_dir", "_ownerUID", ["_size", "LARGE"]];

if (!isServer) exitWith {};

private _depth = 1.2;
private _radius = 1.5;
private _anchorClass = "Land_HelipadEmpty_F"; // Large Foxhole anchor

if (_size == "SMALL") then {
    _depth = 0.6;
    _radius = 0.8;
    _anchorClass = "Land_ClutterCutter_small_F"; // Small Foxhole anchor
};

private _points = [];

// Central point
private _aslCenter = getTerrainHeightASL _targetPos;
_points append [_targetPos select 0, _targetPos select 1, _aslCenter - _depth];

// Left point
private _leftPos = _targetPos getPos [_radius, _dir - 90];
private _aslLeft = getTerrainHeightASL _leftPos;
_points append [_leftPos select 0, _leftPos select 1, _aslLeft - _depth];

// Right point
private _rightPos = _targetPos getPos [_radius, _dir + 90];
private _aslRight = getTerrainHeightASL _rightPos;
_points append [_rightPos select 0, _rightPos select 1, _aslRight - _depth];

// Forward points
private _frontPos = _targetPos getPos [_radius, _dir];
private _aslFront = getTerrainHeightASL _frontPos;
_points append [_frontPos select 0, _frontPos select 1, _aslFront - _depth];

// Back points
private _backPos = _targetPos getPos [_radius, _dir + 180];
private _aslBack = getTerrainHeightASL _backPos;
_points append [_backPos select 0, _backPos select 1, _aslBack - _depth];

// Apply the deformation!
setTerrainHeight [_points, true];

// Spawn the invisible anchor for grad-persistence to save to SQLite.
private _anchor = _anchorClass createVehicle [0,0,0];

// We set it to the original ground height (aslCenter)
_anchor setPosASL [_targetPos select 0, _targetPos select 1, _aslCenter];
_anchor setDir _dir;

// This tag is the magic that tells grad-persistence to save this object to the SQLite DB!
if (_ownerUID != "") then {
    _anchor setVariable ["grad_fortifications_fortOwner", _ownerUID, true];
};

// We also tag it with a unique variable so we know it's a true trench during live sessions
_anchor setVariable ["a3m_isTrenchAnchor", _size, true];

diag_log format ["[A3M Trenches] %3 Foxhole dug at %1 by UID %2. Anchor deployed.", _targetPos, _ownerUID, _size];
