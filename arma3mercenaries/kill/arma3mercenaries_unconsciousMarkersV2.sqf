/*	
    arma3mercenaries_unconsciousMarkers.sqf
    Author: BrianV1981 (Revised by Assistant)

    Description:
    Handles the creation and management of map markers for unconscious players using ACE3.
    - Creates a marker when a player goes unconscious.
    - Updates the marker text after 30 seconds and 2 minutes if still unconscious.
    - Removes the marker when the player wakes up or dies.
    - Sends global system chat notifications.
    - Handles JIP players correctly.

    Dependencies:
    - ACE3 (specifically ace_medical_status and ace_common)
    - CBA_A3 (for event handlers and settings)
    - Relies on `createMarkerOptimized` function being defined globally (e.g., from arma3mercenaries_killMarkers.sqf).
    - CBA Setting: arma3mercenaries_unconsciousMarkerEnabled (BOOL)
*/

diag_log "//________________ arma3mercenaries Unconscious Markers Script v2 ________________";

// Ensure createMarkerOptimized is defined or handle gracefully
if (isNil "createMarkerOptimized") then {
    diag_log "[A3M Unconscious] ERROR: createMarkerOptimized function is not defined!";
    // Define a fallback or exit if critical
    createMarkerOptimized = { diag_log format ["Fallback createMarkerOptimized called: %1", _this]; }; // Example fallback
};

// Function to manage the monitoring loop for an unconscious player
// This should run server-side to manage global markers and chat centrally
A3M_fnc_monitorUnconscious = {
    params ["_unit", "_mrkName"];
    if (!isServer) exitWith {}; // Only run monitoring on the server

    _unit setVariable ["a3m_isBeingMonitored", true, true]; // Flag that monitoring is active (broadcast)
    diag_log format ["[A3M Unconscious] Server started monitoring: %1 (%2)", name _unit, _mrkName];

    private _startTime = time;
    private _notified30s = false;
    private _notified2min = false;

    // Initial marker creation and notification
    [
        _mrkName,                                           // Marker Name
        getPosATL _unit,                                    // Position
        "ICON",                                             // Shape
        "mil_warning",                                      // Type
        "ColorYellow",                                      // Color
        0.7,                                                // Size X
        0.7,                                                // Size Y
        format ["%1 unconscious", name _unit]               // Text
    ] remoteExec ["createMarkerOptimized", 0, _mrkName]; // JIP persistent via unique variable name
    [format ["%1 was knocked unconscious.", name _unit]] remoteExec ["systemChat", 0];


    // Monitoring Loop
    while {
        sleep 5; // Check every 5 seconds
        // Exit conditions: monitoring flag turned off (woke up/killed), unit object gone, unit no longer player, unit is awake
        !(_unit getVariable ["a3m_isBeingMonitored", false]) || {isNull _unit} || {!isPlayer _unit} || {(_unit call ace_common_fnc_isAwake)}
    } do {
        private _elapsed = time - _startTime;

        // Check for 30 second update
        if (_elapsed >= 30 && !_notified30s) then {
            _notified30s = true;
            private _newText = format ["%1 unconscious (30s+)", name _unit];
            diag_log format ["[A3M Unconscious] Server updating marker (30s): %1", _mrkName];
            // Update marker text globally - Target all clients + JIP (_mrkName makes it persistent)
            [_mrkName, _newText] remoteExec ["A3M_fnc_updateMarkerText", 0, _mrkName];
            [format ["%1 still unconscious after 30 seconds.", name _unit]] remoteExec ["systemChat", 0];
        };

        // Check for 2 minute update
        if (_elapsed >= 120 && !_notified2min) then {
            _notified2min = true;
            private _newText = format ["%1 unconscious (2m+)", name _unit];
            diag_log format ["[A3M Unconscious] Server updating marker (2m): %1", _mrkName];
             // Update marker text globally
            [_mrkName, _newText] remoteExec ["A3M_fnc_updateMarkerText", 0, _mrkName];
            [format ["%1 still unconscious after 2 minutes.", name _unit]] remoteExec ["systemChat", 0];
        };
    };

    // Loop finished - Player woke up, died, or monitor was cancelled
    diag_log format ["[A3M Unconscious] Server stopped monitoring: %1 (%2). Deleting marker.", name _unit, _mrkName];
    _unit setVariable ["a3m_isBeingMonitored", nil, true]; // Clean up variable (broadcast removal)
    // Delete marker globally - Target all clients + JIP (_mrkName makes it persistent)
    [_mrkName] remoteExec ["A3M_fnc_deleteMarkerGlobal", 0, _mrkName];

};

// Helper function executed on clients to update marker text
A3M_fnc_updateMarkerText = {
    params ["_markerName", "_markerText"];
    private _marker = markerText _markerName; // Check if marker exists locally first
    if (_marker != "") then { // markerText returns "" if marker doesn't exist
         _markerName setMarkerTextLocal _markerText;
         diag_log format["[A3M Unconscious Client] Updated marker text: %1 to '%2'", _markerName, _markerText];
    } else {
         diag_log format["[A3M Unconscious Client] Failed to update text, marker not found: %1", _markerName];
    };
};

// Helper function executed on clients to delete marker
A3M_fnc_deleteMarkerGlobal = {
    params ["_markerName"];
    if (markerText _markerName != "") then { // Check marker exists before deleting
        deleteMarkerLocal _markerName;
        diag_log format["[A3M Unconscious Client] Deleted marker: %1", _markerName];
    } else {
         diag_log format["[A3M Unconscious Client] Failed to delete marker, not found: %1", _markerName];
    };
};


// Main initialization function for a player
A3M_fnc_initUnconsciousEH = {
    params ["_unit"];
    if (!isPlayer _unit || isNull _unit) exitWith {}; // Ensure it's a valid player

    diag_log format ["[A3M Unconscious] Initializing Event Handlers for %1", name _unit];

    // --- ACE Unconscious Event Handler ---
    // Fires when player's unconscious state *changes*
    _unit addEventHandler ["ace_unconscious", {
        params ["_unit", "_isUnconscious"];
        if (!arma3mercenaries_unconsciousMarkerEnabled) exitWith {}; // Check setting

        private _mrkName = format ["%1_unconscious", getPlayerUID _unit]; // Use UID for uniqueness

        if (_isUnconscious) then {
            // Player went unconscious - Start monitoring on server
            diag_log format ["[A3M Unconscious] EH ace_unconscious=TRUE for %1. Requesting server monitor.", name _unit];
            [_unit, _mrkName] remoteExec ["A3M_fnc_monitorUnconscious", 2]; // 2 = Target server
        } else {
            // Player woke up - Stop monitoring on server (if it was running)
             diag_log format ["[A3M Unconscious] EH ace_unconscious=FALSE for %1. Requesting server stop monitor.", name _unit];
             // Tell the server loop to stop, it will handle marker deletion
             _unit setVariable ["a3m_isBeingMonitored", false, true]; // Set to false and broadcast
        };
    }];

    // --- Player Killed Event Handler ---
    // Redundancy: Ensure marker is cleaned up immediately on death
    _unit addEventHandler ["Killed", {
        params ["_unit", "_killer", "_instigator"];
        if (!arma3mercenaries_unconsciousMarkerEnabled) exitWith {}; // Check setting

        private _mrkName = format ["%1_unconscious", getPlayerUID _unit]; // Use UID
        diag_log format ["[A3M Unconscious] EH Killed for %1. Requesting server stop monitor.", name _unit];

        // Tell the server loop to stop, it will handle marker deletion
         _unit setVariable ["a3m_isBeingMonitored", false, true]; // Set to false and broadcast
    }];
};

// --- Initialize for existing players and JIP ---
if (hasInterface) then { // Only run on clients and HC
    // Add JIP handler using CBA
    ["Initialize", {
        {
            [_x] call A3M_fnc_initUnconsciousEH;
        } forEach playableUnits; // Apply to players already present

        // Add CBA Player Event Handler for JIP
        ["playerConnected", {
            params ["_unit", "_playerUID", "_playerName", "_jip"];
             if (_jip) then { // Only init for actual JIP players here
                diag_log format["[A3M Unconscious] JIP Detected: %1 (%2)", _playerName, _playerUID];
                [_unit] call A3M_fnc_initUnconsciousEH;
             };
        }] call CBA_fnc_addPlayerEventHandler;

        // Optional: Cleanup on disconnect (though Killed EH often covers this)
        ["playerDisconnected", {
             params ["_unit", "_playerUID", "_playerName"];
             diag_log format["[A3M Unconscious] Player Disconnected: %1 (%2)", _playerName, _playerUID];
             // You could force cleanup here if needed, but Killed/Wakeup should handle it
             // [_unit] remoteExec ["A3M_fnc_forceCleanup", 2]; // Example server call
         }] call CBA_fnc_addPlayerEventHandler;

    }] call CBA_fnc_addEventHandlerArgs;
};

diag_log "//________________ arma3mercenaries Unconscious Markers Script v2 Initialized ________________";