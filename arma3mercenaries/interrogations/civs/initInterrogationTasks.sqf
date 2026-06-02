/*
    File: arma3mercenaries\interrogations\civs\initInterrogationTasks.sqf
    Author: Your Name / AI Assistant
    Description:
        Initializes persistent tasks guiding players to civilian interrogation points.
        Creates tasks and adds actions to designated bodybag objects.
        Designed to be called server-side via CfgFunctions postInit.
*/

// Use a function structure for CfgFunctions compatibility
A3M_fnc_initInterrogationTasks = {
    // Wait until the marker objects are initialized server-side
    waitUntil { !isNull (missionNamespace getVariable "interrogation_bodybag_1") && !isNull (missionNamespace getVariable "interrogation_bodybag_2") };

    // Retrieve objects safely after waiting
    private _bodybag1 = missionNamespace getVariable "interrogation_bodybag_1";
    private _bodybag2 = missionNamespace getVariable "interrogation_bodybag_2";

    // Ensure objects were found (extra safety check)
    if (isNull _bodybag1 || isNull _bodybag2) exitWith {
        diag_log "[A3M Interrogation Tasks] ERROR: Bodybag objects not found after wait. Tasks/Actions not created.";
    };

    diag_log "[A3M Interrogation Tasks] Bodybag objects found. Proceeding with task/action creation.";

    // --- Task 1: Interrogation Point Alpha (Bodybag 1) ---
    private _taskID1 = "InterrogateLocA"; // Task ID Alpha
    private _owners1 = [west, independent]; // BLUFOR & Independent
    private _title1 = "Interrogation Point Alpha";
    private _descriptionText1 = "Command wants intel, and they don't care how we get it. Bring any captured civilians to this primary 'processing' point. Use the action menu on the nearby container once they're secured. Standard extraction protocols yield cash rewards, but be thorough – high-value information could expose a key HVT and lead to a substantial bonus payout.";
    private _description1 = [_descriptionText1, _title1, ""]; // [description, title, marker (obsolete)]
    private _destination1 = getPos _bodybag1;
    private _initialState1 = "CREATED"; // Persistent task
    private _priority1 = -1; // No auto-assign
    private _showNotification1 = true; // Notify players on mission start
    private _taskType1 = "interact"; // Suitable icon

    // Create the first task
    [_owners1, _taskID1, _description1, _destination1, _initialState1, _priority1, _showNotification1, _taskType1] call BIS_fnc_taskCreate;
    diag_log format ["[A3M Interrogation Tasks] Created task '%1' at %2", _taskID1, _destination1];

    // --- Task 2: Interrogation Point Bravo (Bodybag 2) ---
    private _taskID2 = "InterrogateLocB"; // Task ID Bravo
    private _owners2 = [west, independent]; // BLUFOR & Independent
    private _title2 = "Interrogation Point Bravo";
    private _descriptionText2 = "This secondary site is authorized for extracting information from civilian assets. Secure the targets near the container and initiate interrogation via the action menu. Payment is issued upon successful processing. Stay alert – valuable intel leading to an HVT might surface, triggering follow-on operations and a significant reward.";
    private _description2 = [_descriptionText2, _title2, ""]; // [description, title, marker (obsolete)]
    private _destination2 = getPos _bodybag2;
    private _initialState2 = "CREATED"; // Persistent task
    private _priority2 = -1; // No auto-assign
    private _showNotification2 = true; // Notify players on mission start
    private _taskType2 = "interact"; // Suitable icon

    // Create the second task
    [_owners2, _taskID2, _description2, _destination2, _initialState2, _priority2, _showNotification2, _taskType2] call BIS_fnc_taskCreate;
    diag_log format ["[A3M Interrogation Tasks] Created task '%1' at %2", _taskID2, _destination2];


    // --- Add Actions to Bodybags (Server Side) ---

    // AddAction for Bodybag 1
    _bodybag1 addAction [
        "<t color='#FFD700'>Begin Interrogation</t>", // Action text
        {
            // Action code runs where action is added (server)
            params ["_target", "_caller", "_actionId", "_arguments"]; // _target is bodybag, _caller is player

            // Execute the main interrogation script
            [_target, _caller] spawn { // Use spawn for safety to not block scheduler if script is heavy
                _this execVM "arma3mercenaries\interrogations\arma3mercenaries_interrogate_bluforIndep_on_civilians.sqf";
            };
            // Optional: Give immediate feedback to the player that action was triggered
             ["Interrogation protocols initiated...", 0,0,3,0,0,789] remoteExec ["BIS_fnc_dynamicText", _caller];
        },
        nil, // _arguments
        6,   // priority
        true, // showWindow
        true, // hideOnUse
        "",  // shortcut
        "player distance _target < 5 && {side player in [west, independent]}", // condition: Close & correct side
        5    // radius condition check
    ];
    diag_log format ["[A3M Interrogation Tasks] Added action to %1 (Object: %2)", typeOf _bodybag1, _bodybag1];

    // AddAction for Bodybag 2
    _bodybag2 addAction [
        "<t color='#FFD700'>Begin Interrogation</t>", // Action text
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
             [_target, _caller] spawn {
                _this execVM "arma3mercenaries\interrogations\arma3mercenaries_interrogate_bluforIndep_on_civilians.sqf";
            };
             ["Interrogation protocols initiated...", 0,0,3,0,0,789] remoteExec ["BIS_fnc_dynamicText", _caller];
        },
        nil, 6, true, true, "",
        "player distance _target < 5 && {side player in [west, independent]}", 5
    ];
    diag_log format ["[A3M Interrogation Tasks] Added action to %1 (Object: %2)", typeOf _bodybag2, _bodybag2];

    diag_log "[A3M Interrogation Tasks] Initialization complete.";

}; // End of A3M_fnc_initInterrogationTasks function