/*
    A3M Contract: Rescue (POW / Hostage)
    Objective: Assault a compound deep in enemy territory and rescue a bound VIP.
    Refactored to ALiVE Virtualization and CBA PFH.
*/
params [["_difficulty", "NORMAL"]];

if (!isServer) exitWith {};

// --- 1. Define Difficulty Metrics ---
private _enemyTaorMarkers = ["red_taor_1", "red_taor_2", "red_taor_3", "red_taor_4", "red_taor_5"];
private _enemyFaction = if (_difficulty == "HARD") then { "OPF_F" } else { "OPF_G_F" }; // CSAT vs FIA
private _reward = if (_difficulty == "HARD") then { 600000 } else { 300000 };

private _safeTaorMarkers = ["blue_taor"];

// --- 2. Select Compound Location ---
private _selectedTaor = selectRandom _enemyTaorMarkers;
if (getMarkerColor _selectedTaor == "") exitWith {
    private _msg = format ["A3M FATAL ERROR: Contract aborted. TAOR marker '%1' does not exist on the map!", _selectedTaor];
    diag_log _msg;
    _msg remoteExec ["systemChat", 0];
};
private _randomTaorPos = _selectedTaor call BIS_fnc_randomPosTrigger;

// Find nearest buildings to stash the hostage
private _houseList = nearestObjects [_randomTaorPos, ["House", "Building"], 1000];
private _prisonPos = [];
if (count _houseList > 0) then {
    private _selectedHouse = selectRandom _houseList;
    private _bldgPosCount = count (_selectedHouse buildingPos -1);
    if (_bldgPosCount > 0) then {
        _prisonPos = _selectedHouse buildingPos (floor random _bldgPosCount);
    } else {
        _prisonPos = getPos _selectedHouse;
    };
} else {
    _prisonPos = [_randomTaorPos, 1, 300, 5, 0, 0.2, 0] call BIS_fnc_findSafePos;
};

// --- 3. Select Safe FOB Location ---
private _safeTaor = selectRandom _safeTaorMarkers;
if (getMarkerColor _safeTaor == "") exitWith {
    private _msg = format ["A3M FATAL ERROR: Contract aborted. Safe Zone marker '%1' does not exist on the map!", _safeTaor];
    diag_log _msg;
    _msg remoteExec ["systemChat", 0];
};
private _safePos = _safeTaor call BIS_fnc_randomPosTrigger;

private _fobPos = [_safePos, 1, 1000, 10, 0, 0.1, 0] call BIS_fnc_findSafePos;

// Create visible Extraction Marker
private _extMarkerName = format ["ext_mrk_%1", floor(random 99999)];
private _extMarker = createMarker [_extMarkerName, _fobPos];
_extMarker setMarkerType "hd_pickup";
_extMarker setMarkerColor "ColorBlue";
_extMarker setMarkerText " Extraction Zone";

// Determine nearest town name for flavor text
private _nearestTown = text (nearestLocations [_prisonPos, ["NameCityCapital", "NameCity", "NameVillage"], 3000] select 0);

// --- 4. Spawn Hostage & Ambush Detail ---
private _hostageGroup = createGroup [civilian, true];
private _hostage = _hostageGroup createUnit ["C_journalist_F", _prisonPos, [], 0, "NONE"];

// CRITICAL: Hostage remains a physical entity! 
// Virtualizing a bound unit ruins their exact building placement and animations when they re-spawn.
// By disabling all their AI, they cost zero FPS natively.
_hostage setCaptive true;
removeAllWeapons _hostage;
_hostage setVariable ["A3M_IsRescueTarget", true, true];
_hostage setVariable ["VCOM_NOAI", true, true];
{ _hostage disableAI _x } forEach ["MOVE", "FSM", "TARGET", "AUTOTARGET"];

// Play bound animation
[_hostage, "Acts_AidlPsitMstpSsurWnonDnon01"] remoteExec ["switchMove", 0, true];

// Create ACE Interact to 'Rescue' the hostage
[
    _hostage, 
    "Cut Zip-Ties", 
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
    "_this distance _target < 2", 
    "_caller distance _target < 2", 
    {}, 
    {}, 
    {
        params ["_target", "_caller"];
        _target setCaptive false;
        { _target enableAI _x } forEach ["MOVE", "FSM", "TARGET", "AUTOTARGET"];
        [_target, ""] remoteExec ["switchMove", 0, true]; // Break anim
        [_target] joinSilent (group _caller);
        ['Rescue', format ['You have rescued the VIP! Escort them to the FOB.', name _target]] remoteExec ['BIS_fnc_showSubtitle', side (group _caller)];
        _target setVariable ["A3M_Rescued", true, true];
    },
    {},
    [],
    4,
    10,
    true,
    false
] remoteExec ["BIS_fnc_holdActionAdd", 0, _hostage];

// Spawn an ALiVE Virtualized Guard Detail around the building
private _guardGroupConfig = if (_difficulty == "HARD") then { "OIA_InfSquad" } else { "OIA_InfTeam" };
private _guardProfiles = [_guardGroupConfig, _prisonPos, random 360, false, _enemyFaction] call ALIVE_fnc_createProfilesFromGroupConfig;
if (count _guardProfiles > 0) then {
    private _wp = [_prisonPos, 30, "GUARD", "COMBAT", 0] call ALIVE_fnc_createProfileWaypoint;
    [(_guardProfiles select 0), "addWaypoint", _wp] call ALIVE_fnc_profileEntity;
};

// --- 5. Create Task ---
private _taskID = format ["contract_pow_%1_%2", floor(diag_tickTime * 10), floor(random 99999)];
private _taskSide = west;

private _selectedDescription = [
    format ["A high-value CIA asset was captured and is being held in a compound near <t color='#ffff00'>%1</t>.<br/><br/>Assault the compound, eliminate the guards, and free the hostage. You must escort them back to the blue Extraction Zone marked on your map.<br/><br/><t color='#00ff00'>Payout: $%2</t>", _nearestTown, _reward],
    format ["Rescue POW near %1", _nearestTown],
    format ["Rescue POW near %1", _nearestTown]
];

[
    [_taskSide, independent],
    _taskID,
    _selectedDescription,
    _prisonPos,
    "ASSIGNED",
    1,
    true,
    "meet",
    true
] call BIS_fnc_taskCreate;

// --- 6. CBA PFH Task Tracker ---
[{
    params ["_args", "_handle"];
    _args params ["_taskID", "_hostage", "_fobPos", "_reward"];

    // 0. Task State Check
    private _taskState = [_taskID] call BIS_fnc_taskState;
    if (_taskState == "SUCCEEDED" || _taskState == "CANCELED" || _taskState == "FAILED") exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    if (!alive _hostage) exitWith {
        [_taskID, 'FAILED', true] call BIS_fnc_taskSetState;
        diag_log format ['[A3M TASK MANAGER] Rescue Task %1 FAILED (VIP KIA).', _taskID];
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    // Check distance to Drop-Off FOB
    if ((_hostage getVariable ["A3M_Rescued", false]) && {(getPos _hostage) distance2D _fobPos < 100}) then {
        
        [_taskID, 'SUCCEEDED', true] call BIS_fnc_taskSetState;
        
        {
            if (isPlayer _x && {alive _x}) then {
                [_x, _reward] remoteExecCall ['grad_moneymenu_fnc_addFunds', _x];
                ['RESCUE SUCCESS', format ['+$%1', _reward]] remoteExec ['BIS_fnc_showSubtitle', _x];
            };
        } forEach playableUnits;
        
        diag_log format ['[A3M TASK MANAGER] Rescue Task %1 SUCCEEDED.', _taskID];
        
        [_hostage] joinSilent grpNull;
        [ { if (!isNull (_this select 0)) then { deleteVehicle (_this select 0); }; }, [_hostage], 30 ] call CBA_fnc_waitAndExecute;
        
        deleteMarker _extMarkerName;
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
}, 5, [_taskID, _hostage, _fobPos, _reward, _extMarkerName]] call CBA_fnc_addPerFrameHandler;
