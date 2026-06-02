/*
    arma3mercenaries\tasks\HVT_1\HVTTaskTracker.sqf
    Author: BrianV1981 / Gemini 2.5
    Description:
    Runs only on the server. Periodically updates the destination marker
    for active HVT tasks based on the HVT's current position.
    Cleans up completed or invalid tasks from the tracking array.
*/

if (!isServer) exitWith {}; // Server only execution

// Ensure array exists (redundancy)
if (isNil "server_activeHvtTasks") then { server_activeHvtTasks = []; };

diag_log "SERVER: HVT Task Tracker Loop Initialized.";

// Define update interval (in seconds) - e.g., 2-3 minutes
private _updateIntervalMin = 180; // 180 = 3 minutes
private _updateIntervalMax = 360; // 360 = 6 minutes

while {true} do {
    // Use CBA_fnc_hashLoop or count for iteration if CBA is available for performance on very large arrays
    // For simplicity, using standard forEachIndex here
    private _tasksToRemoveIndices = []; // Store indices to remove later

    {
        _taskInfo = _x;
        _index = _forEachIndex;

        // Extract info
        _taskId = _taskInfo select 0;
        _hvt = _taskInfo select 1;
        // _taskSide = _taskInfo select 2; // Not needed for BIS_fnc_taskSetDestination unless filtering later

        // --- Validity Checks ---
        // Check if HVT unit exists and is alive
        if (isNull _hvt || {!alive _hvt}) then {
            _tasksToRemoveIndices pushBack _index; // Mark for removal
            diag_log format ["SERVER HVT Tracker: HVT %1 for task %2 is null or dead. Marking for removal.", _hvt, _taskId];
        } else {
            // Check if task is still considered active (ASSIGNED or CREATED)
            _taskState = _taskId call BIS_fnc_taskState;
            if (!(_taskState in ["ASSIGNED", "CREATED"])) then {
                _tasksToRemoveIndices pushBack _index; // Mark for removal
                diag_log format ["SERVER HVT Tracker: Task %1 state is %2. Marking for removal.", _taskId, _taskState];
            } else {
                // --- Task is Active and HVT is Alive: Update Position ---
                _hvtPos = getPosATL _hvt; // Use ATL for potentially better accuracy on terrain

                // Update the task destination - this function is global and works from server
                [_taskId, _hvtPos] call BIS_fnc_taskSetDestination;

                // Optional: Log the update
                // diag_log format ["SERVER HVT Tracker: Updated destination for task %1 to %2.", _taskId, _hvtPos];
            };
        };
    } forEach server_activeHvtTasks;


    // --- Cleanup Phase ---
    // Remove tasks marked for removal, iterating backwards by index to avoid issues
    if (count _tasksToRemoveIndices > 0) then {
        // Sort indices descending
        _tasksToRemoveIndices = _tasksToRemoveIndices call BIS_fnc_sortNum; // Sort ascending first
        reverse _tasksToRemoveIndices; // Reverse to descending

        {
            server_activeHvtTasks deleteAt _x;
        } forEach _tasksToRemoveIndices;
        diag_log format ["SERVER HVT Tracker: Removed %1 completed/invalid tasks. Current count: %2", count _tasksToRemoveIndices, count server_activeHvtTasks];
    };


    // --- Wait for next cycle ---
    _sleepTime = _updateIntervalMin + random (_updateIntervalMax - _updateIntervalMin);
    sleep _sleepTime;
};