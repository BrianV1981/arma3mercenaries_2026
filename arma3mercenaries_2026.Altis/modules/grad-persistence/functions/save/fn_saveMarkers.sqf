#include "script_component.hpp"

if (!isServer) exitWith {};

params [["_area",false]];

if (_area isEqualType []) then {
    _area params ["_center","_a","_b",["_angle",0],["_isRectangle",false],["_c",-1]];
    if (isNil "_b") then {_b = _a};
    _area = [_center,_a,_b,_angle,_isRectangle,_c];
};

private _missionTag = [] call FUNC(getMissionTag);
private _markersTag = _missionTag + "_markers";

private _markers = [_area] call FUNC(getApplicableMarkers);

// --- A.I.M. v812+ Architecture: DB Index Tracking ---
private _savedMarkersCount = 0;

{
    private _thisMarkerHash = createHashMap;

    _thisMarkerHash set ["name",_x];
    _thisMarkerHash set ["alpha",markerAlpha _x];
    _thisMarkerHash set ["brush",markerBrush _x];
    _thisMarkerHash set ["color",getMarkerColor _x];
    _thisMarkerHash set ["dir",markerDir _x];
    _thisMarkerHash set ["pos",getMarkerPos _x];
    _thisMarkerHash set ["shape",markerShape _x];
    _thisMarkerHash set ["size",getMarkerSize _x];
    _thisMarkerHash set ["text",markerText _x];
    _thisMarkerHash set ["type",getMarkerType _x];

    // --- A.I.M. Per-Entity Save Pipeline ---
    private _uniqueEntityKey = format ["%1_marker_%2", _markersTag, _savedMarkersCount];
    [_uniqueEntityKey, _thisMarkerHash] call A3M_fnc_dbSetSecure;
    
    _savedMarkersCount = _savedMarkersCount + 1;

} forEach _markers;

// --- Save the COUNT integer ---
private _countKey = format ["%1_COUNT", _markersTag];
[_countKey, _savedMarkersCount] call A3M_fnc_dbSetSecure;

// ALSO delete the old INDEX array so we don't duplicate logic if mixing load systems
private _indexKey = format ["%1_INDEX", _markersTag];
[_indexKey, []] call A3M_fnc_dbSetSecure;
