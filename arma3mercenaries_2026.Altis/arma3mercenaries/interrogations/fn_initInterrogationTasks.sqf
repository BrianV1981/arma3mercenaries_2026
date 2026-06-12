/*
    arma3mercenaries\interrogations\fn_initInterrogationTasks.sqf
    Description: Server-side initialization of Map Tasks for interrogations.
    Executed from initServer.sqf
*/
if (!isServer) exitWith {};

diag_log "[A3M INTERROGATIONS] fn_initInterrogationTasks.sqf has started execution.";

private _taskConfigs = [
    ["task_InterrogateAlpha", "Interrogation Point Alpha", "Command wants intel, and they don't care how we get it. Bring any captured civilians to this primary 'processing' point. Use the action menu on the nearby desk once they're secured. Standard extraction protocols yield cash rewards, but be thorough – high-value information could expose a key HVT and lead to a substantial bonus payout.", "interrogation_bodybag_1", ["CIVILIAN"]],
    ["task_InterrogateBravo", "Interrogation Point Bravo", "This secondary site is authorized for extracting information from civilian assets. Secure the targets near the container and initiate interrogation via the desk. Payment is issued upon successful processing. Stay alert – valuable intel leading to an HVT might surface, triggering follow-on operations and a significant reward.", "interrogation_bodybag_2", ["CIVILIAN"]],
    ["task_InterrogateCharlie", "Interrogation Point Charlie", "Charlie Point serves as an additional facility for intel extraction. Bring captives to the desk location and initiate the process using the object's action menu. Financial rewards are standard, with significant bonuses possible for HVT identification.", "interrogation_bodybag_3", ["CIVILIAN"]]
];

{
    _x params ["_taskID", "_title", "_desc", "_objVarName", "_targetTypeArgs"];
    
    // Check if the object exists
    private _targetObj = missionNamespace getVariable [_objVarName, objNull];
    if (!isNull _targetObj) then {
        // Create Map Tasks
        [west, _taskID, [_desc, _title, ""], _targetObj, false, 0, true, "default"] call BIS_fnc_taskCreate;
        [resistance, _taskID, [_desc, _title, ""], _targetObj, false, 0, true, "default"] call BIS_fnc_taskCreate;
        
        // Strip legacy baked-in Eden Editor actions
        removeAllActions _targetObj;
        
        // Force simulation on globally
        _targetObj enableSimulationGlobal true;
        
        // Broadcast a variable to JIP clients so ACE interactions can reliably identify this object
        _targetObj setVariable ["isInterrogationTarget", true, true];

        diag_log format ["[A3M INTERROGATIONS] Tasks and simulation enabled for %1", _objVarName];

    } else {
        diag_log format ["[A3M INTERROGATIONS] WARNING: Object %1 not found for task %2", _objVarName, _taskID];
    };
} forEach _taskConfigs;