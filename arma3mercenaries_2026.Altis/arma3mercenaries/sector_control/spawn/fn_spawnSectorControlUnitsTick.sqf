// arma3mercenaries\sector_control\spawn\fn_spawnSectorControlUnitsTick.sqf
// Executed every 120 seconds via CBA PFH
// Replaces the legacy while {true} fn_spawnSectorControlUnits.sqf script.

if (!isServer) exitWith {};

if (isNil "A3M_SectorControlGroups") then {
    // Initialize an array of 12 sectors with [grpEast, grpWest, grpGuer]
    A3M_SectorControlGroups = [];
    for "_i" from 1 to 12 do { A3M_SectorControlGroups pushBack [grpNull, grpNull, grpNull]; };
};

private _sectors = [
    ["spawnMarker_1", "waypointMarker_1", 100],
    ["spawnMarker_2", "waypointMarker_2", 300],
    ["spawnMarker_3", "waypointMarker_3", 150],
    ["spawnMarker_4", "waypointMarker_4", 600],
    ["spawnMarker_5", "waypointMarker_5", 400],
    ["spawnMarker_6", "waypointMarker_6", 250],
    ["spawnMarker_7", "waypointMarker_7", 300],
    ["spawnMarker_8", "waypointMarker_8", 350],
    ["spawnMarker_9", "waypointMarker_9", 300],
    ["spawnMarker_10", "waypointMarker_10", 250],
    ["spawnMarker_11", "waypointMarker_11", 300],
    ["spawnMarker_12", "waypointMarker_12", 1000]
];

private _eastGroupType = ["O_Soldier_F"];
private _westGroupType = ["B_Soldier_F"];
private _guerGroupType = ["I_C_Soldier_Para_1_F"];

{
    private _sector = _x;
    private _spawnMarkerName = _sector select 0;
    private _waypointMarkerName = _sector select 1;
    private _markerRadius = _sector select 2;

    private _spawnPos = getMarkerPos _spawnMarkerName;
    private _waypointPos = getMarkerPos _waypointMarkerName;

    private _groupEast = (A3M_SectorControlGroups select _forEachIndex) select 0;
    private _groupWest = (A3M_SectorControlGroups select _forEachIndex) select 1;
    private _groupGuer = (A3M_SectorControlGroups select _forEachIndex) select 2;

    private _realPlayersInArea = allPlayers select { _x distance2D _waypointPos <= _markerRadius };

    if ((count _realPlayersInArea) > 0) then {
        // Players present: Despawn active ALiVE representations
        if (!isNull _groupEast) then { { _x setDamage 1 } forEach units _groupEast; _groupEast deleteGroupWhenEmpty true; };
        if (!isNull _groupWest) then { { _x setDamage 1 } forEach units _groupWest; _groupWest deleteGroupWhenEmpty true; };
        if (!isNull _groupGuer) then { { _x setDamage 1 } forEach units _groupGuer; _groupGuer deleteGroupWhenEmpty true; };
    } else {
        // No players present: Spawn ALiVE representations based on virtual profiles
        // Spawn East
        if ((count ([_waypointPos, _markerRadius, ["EAST", "entity"]] call ALIVE_fnc_getNearProfiles)) > 0) then {
            if (isNull _groupEast || {count units _groupEast == 0}) then {
                _groupEast = [_spawnPos, EAST, _eastGroupType] call BIS_fnc_spawnGroup;
                if (!isNull _groupEast) then { _groupEast deleteGroupWhenEmpty true; private _wp = _groupEast addWaypoint [_waypointPos, 0]; _wp setWaypointType "MOVE"; _wp setWaypointSpeed "FULL"; };
            };
        } else {
            if (!isNull _groupEast) then { { _x setDamage 1 } forEach units _groupEast; _groupEast deleteGroupWhenEmpty true; };
        };
        
        // Spawn West
        if ((count ([_waypointPos, _markerRadius, ["WEST", "entity"]] call ALIVE_fnc_getNearProfiles)) > 0) then {
            if (isNull _groupWest || {count units _groupWest == 0}) then {
                _groupWest = [_spawnPos, WEST, _westGroupType] call BIS_fnc_spawnGroup;
                if (!isNull _groupWest) then { _groupWest deleteGroupWhenEmpty true; private _wp = _groupWest addWaypoint [_waypointPos, 0]; _wp setWaypointType "MOVE"; _wp setWaypointSpeed "FULL"; };
            };
        } else {
            if (!isNull _groupWest) then { { _x setDamage 1 } forEach units _groupWest; _groupWest deleteGroupWhenEmpty true; };
        };

        // Spawn Guer
        if ((count ([_waypointPos, _markerRadius, ["GUER", "entity"]] call ALIVE_fnc_getNearProfiles)) > 0) then {
            if (isNull _groupGuer || {count units _groupGuer == 0}) then {
                _groupGuer = [_spawnPos, INDEPENDENT, _guerGroupType] call BIS_fnc_spawnGroup;
                if (!isNull _groupGuer) then { _groupGuer deleteGroupWhenEmpty true; private _wp = _groupGuer addWaypoint [_waypointPos, 0]; _wp setWaypointType "MOVE"; _wp setWaypointSpeed "FULL"; };
            };
        } else {
            if (!isNull _groupGuer) then { { _x setDamage 1 } forEach units _groupGuer; _groupGuer deleteGroupWhenEmpty true; };
        };
    };

    // Save state back to array
    (A3M_SectorControlGroups select _forEachIndex) set [0, _groupEast];
    (A3M_SectorControlGroups select _forEachIndex) set [1, _groupWest];
    (A3M_SectorControlGroups select _forEachIndex) set [2, _groupGuer];

} forEach _sectors;