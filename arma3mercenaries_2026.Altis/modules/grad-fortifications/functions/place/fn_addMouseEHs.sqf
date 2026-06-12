// --- File: modules\grad-fortifications\functions\place\fn_addMouseEHs.sqf ---
// (Updated with placementReady check)

grad_fortifications_mousewheelEH = (findDisplay 46) displayAddEventHandler ["MouseZChanged", {
    params ["_display", "_wheelChange"];

    private _builder = ACE_player;
    private _accelFactor = if (_builder getVariable ["grad_fortifications_altDown", false]) then {3} else {1};

    // Check if placement is ready before allowing adjustments
    if !(_builder getVariable ["grad_fortifications_placementReady", false]) exitWith { false; };

    switch (true) do {
        case (_builder getVariable ["grad_fortifications_shiftDown", false]): {
            private _currentDir = _builder getVariable ["grad_fortifications_currentDirection", 0];
            private _newDirection = _currentDir + _wheelChange * _accelFactor;
            _builder setVariable ["grad_fortifications_currentDirection", _newDirection];
        };

        case (_builder getVariable ["grad_fortifications_ctrlDown", false]): {
            private _currentHeight = _builder getVariable ["grad_fortifications_currentHeight", 0];
            private _minHeight = _builder getVariable ["grad_fortifications_minHeight", -0.8];
            private _maxHeight = _builder getVariable ["grad_fortifications_maxHeight", 3];
            private _newHeight = ((_currentHeight + (_wheelChange / 45) * _accelFactor) max _minHeight) min _maxHeight;
            _builder setVariable ["grad_fortifications_currentHeight", _newHeight];
        };

        default {
            private _currentDistance = _builder getVariable ["grad_fortifications_currentDistance", 4];
            private _size = _builder getVariable ["grad_fortifications_currentSize", 1];
            private _newDistance = ((_currentDistance + (_wheelChange / 20) * _accelFactor) max (((_size * 2) ^ (1 / 2)) max 2)) min ((_size * 6) ^ (1 / 2));
            _builder setVariable ["grad_fortifications_currentDistance", _newDistance];
        };
    };

    false // Do not consume the event
}];

grad_fortifications_mousebuttonEH = (findDisplay 46) displayAddEventHandler ["MouseButtonUp", {
    params ["_display", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];

    private _builder = ACE_player;

    // *** ADDED: Check if placement interaction is ready ***
    if !(_builder getVariable ["grad_fortifications_placementReady", false]) exitWith {
        false; // Exit the handler code block, don't consume event
    };
    // *** END CHECK ***

    if !(_button in [0,1]) exitWith {}; // Check button is Left (0) or Right (1)

    if (_button == 0) then { // Left Click - Place
        [_builder] call grad_fortifications_fnc_placeFortification;
    };

    if (_button == 1) then { // Right Click - Cancel
        [] call grad_fortifications_fnc_cancelPlacement;
    };

    false // Do not consume the event
}];

// Keep the fire override action
grad_fortifications_fireOverride = ACE_player addAction ["", {true}, "", 0, false, true, "DefaultAction", "true"];