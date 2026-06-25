/*
    A3M Contract: Aid Delivery
    Objective: Transport a spawned relief truck from a Safe Zone into a Contested Zone.
*/
params [["_difficulty", "NORMAL"]];

if (!isServer) exitWith {};

// --- 1. Define Difficulty Metrics ---
private _startTaorMarkers = ["blue_taor", "unoccupied_taor_1"];
private _destinationTaorMarkers = ["red_taor_1", "red_taor_2", "red_taor_3", "red_taor_4", "red_taor_5"];
private _reward = if (_difficulty == "HARD") then { 350000 } else { 150000 };

// --- 2. Select Staging & Destination ---
private _startTaor = selectRandom _startTaorMarkers;
private _startPos = _startTaor call BIS_fnc_randomPosTrigger;
private _stagingPos = [_startPos, 1, 300, 10, 0, 0.1, 0] call BIS_fnc_findSafePos;

private _destTaor = selectRandom _destinationTaorMarkers;
private _destPos = _destTaor call BIS_fnc_randomPosTrigger;
private _dropOffPos = [_destPos, 1, 200, 10, 0, 0.1, 0] call BIS_fnc_findSafePos;

// Determine nearest town name for flavor text
private _nearestTown = text (nearestLocations [_dropOffPos, ["NameCityCapital", "NameCity", "NameVillage"], 2000] select 0);

// --- 3. Spawn the Relief Truck natively ---
private _truckClasses = ["C_Van_01_box_F", "C_Truck_02_covered_F"];
private _aidTruck = createVehicle [selectRandom _truckClasses, _stagingPos, [], 0, "NONE"];
_aidTruck setDir (random 360);
clearWeaponCargoGlobal _aidTruck;
clearMagazineCargoGlobal _aidTruck;
clearItemCargoGlobal _aidTruck;

// Give it a custom variable so players know it's the mission truck
_aidTruck setVariable ["A3M_IsAidTruck", true, true];

// --- 4. Create Task ---
private _taskID = format ["contract_aid_%1_%2", floor(diag_tickTime * 10), floor(random 99999)];
private _taskSide = west;

private _selectedDescription = [
    format ["CIA Civil Affairs needs us to win some hearts and minds.<br/><br/>A humanitarian aid truck has been staged in our territory. We need you to drive this specific truck through the buffer zone and deliver it safely to the center of <t color='#ffff00'>%1</t>.<br/><br/>If the truck is destroyed, the mission is a failure.<br/><br/><t color='#00ff00'>Payout: $%2</t>", _nearestTown, _reward],
    format ["Deliver Aid to %1", _nearestTown],
    format ["Deliver Aid to %1", _nearestTown]
];

[
    [_taskSide, independent],
    _taskID,
    _selectedDescription,
    _dropOffPos,
    "ASSIGNED",
    1,
    true,
    "heal",
    true
] call BIS_fnc_taskCreate;

// Create a secondary waypoint marker for the truck's starting location
private _stagingTaskID = format ["%1_staging", _taskID];
[
    [_taskSide, independent],
    [_stagingTaskID, _taskID],
    ["Locate and secure the staged Aid Truck.", "Secure Aid Truck", "Aid Truck"],
    _stagingPos,
    "ASSIGNED",
    1,
    true,
    "truck",
    true
] call BIS_fnc_taskCreate;

// --- 5. CBA PFH Task Tracker ---
// This PFH checks the truck's physical position.
[{
    params ["_args", "_handle"];
    _args params ["_taskID", "_stagingTaskID", "_aidTruck", "_dropOffPos", "_reward"];

    // 0. Task State Check (Prevents PFH from running forever if task is cancelled externally)
    private _taskState = [_taskID] call BIS_fnc_taskState;
    if (_taskState == "SUCCEEDED" || _taskState == "CANCELED" || _taskState == "FAILED") exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    // 1. If truck is destroyed
    if (!alive _aidTruck) exitWith {
        [_taskID, 'FAILED', true] call BIS_fnc_taskSetState;
        diag_log format ['[A3M TASK MANAGER] Aid Delivery Task %1 FAILED (Truck Destroyed).', _taskID];
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    // 2. Resolve Staging Task if a player gets in
    private _stagingState = [_stagingTaskID] call BIS_fnc_taskState;
    if (_stagingState != "SUCCEEDED") then {
        if ({isPlayer _x} count (crew _aidTruck) > 0) then {
            [_stagingTaskID, 'SUCCEEDED', false] call BIS_fnc_taskSetState;
        };
    };

    // 3. Check distance to Drop-Off
    if ((getPos _aidTruck) distance2D _dropOffPos < 100) then {
        // Must be driven by a player or have a player very close to it to prevent AI cheesing
        private _closestPlayer = [(getPos _aidTruck), playableUnits] call ALIVE_fnc_taskGetClosestPlayerToPosition;
        if (!isNull _closestPlayer && {(_closestPlayer distance2D _aidTruck) < 50}) then {
            
            [_taskID, 'SUCCEEDED', true] call BIS_fnc_taskSetState;
            
            {
                if (isPlayer _x && {alive _x}) then {
                    [_x, _reward] remoteExecCall ['grad_moneymenu_fnc_addFunds', _x];
                    ['AID DELIVERED', format ['+$%1', _reward]] remoteExec ['BIS_fnc_showSubtitle', _x];
                };
            } forEach playableUnits;
            
            diag_log format ['[A3M TASK MANAGER] Aid Delivery Task %1 SUCCEEDED.', _taskID];
            
            // Clean up truck after 60 seconds
            [{ deleteVehicle _this; }, _aidTruck, 60] call CBA_fnc_waitAndExecute;

            [_handle] call CBA_fnc_removePerFrameHandler;
        };
    };
}, 3, [_taskID, _stagingTaskID, _aidTruck, _dropOffPos, _reward]] call CBA_fnc_addPerFrameHandler;
