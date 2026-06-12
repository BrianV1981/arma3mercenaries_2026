#include "script_component.hpp"

private _missionTag = [] call FUNC(getMissionTag);
private _markersTag = _missionTag + "_markers";

// --- A.I.M. v812+ Architecture: SQLite Per-Entity Loading ---
private _countKey = format ["%1_COUNT", _markersTag];
private _dbCount = [_countKey, -1, false] call A3M_fnc_dbGetSecure;

private _markersData = [];

if (_dbCount > -1) then {
    // New Iterative Architecture
    for "_i" from 0 to (_dbCount - 1) do {
        private _uniqueEntityKey = format ["%1_marker_%2", _markersTag, _i];
        // Fetch native HashMap. Note the 'true' parameter for HashMap reconstruction.
        private _entityHash = [_uniqueEntityKey, createHashMap, true] call A3M_fnc_dbGetSecure;
        
        if (count _entityHash > 0) then {
            _markersData pushBack _entityHash;
        };
    };
};

{
    private _thisMarkerHash = _x;
    private _originalMarkerName = _thisMarkerHash getOrDefault ["name", ""];
    
    // Skip empty or corrupted markers
    if (_originalMarkerName == "") then { continue; };

    private _markerName = if (_originalMarkerName find "_USER_DEFINED" == 0) then {
        (_originalMarkerName splitString " ") params ["",["_markerData",""]];
        (_markerData splitString "/") params ["","",["_channelID","-1"]];

        format ["_USER_DEFINED #%1_%2/%2/%3",QGVAR(marker),_forEachIndex,_channelID]
    } else {
        _originalMarkerName
    };

    // check if marker already exists
    private _thisMarker = if (markerShape _markerName == "") then {
        createMarker [_markerName,[0,0,0]]
    } else {
        _markerName
    };

    _thisMarker setMarkerAlpha (_thisMarkerHash getOrDefault ["alpha", 1]);
    _thisMarker setMarkerBrush (_thisMarkerHash getOrDefault ["brush", "Solid"]);
    _thisMarker setMarkerColor (_thisMarkerHash getOrDefault ["color", "Default"]);
    _thisMarker setMarkerDir (_thisMarkerHash getOrDefault ["dir", 0]);
    _thisMarker setMarkerPos (_thisMarkerHash getOrDefault ["pos", [0,0,0]]);
    _thisMarker setMarkerShape (_thisMarkerHash getOrDefault ["shape", "ICON"]);
    _thisMarker setMarkerSize (_thisMarkerHash getOrDefault ["size", [1,1]]);
    _thisMarker setMarkerText (_thisMarkerHash getOrDefault ["text", ""]);
    _thisMarker setMarkerType (_thisMarkerHash getOrDefault ["type", "mil_dot"]);

} forEach _markersData;
