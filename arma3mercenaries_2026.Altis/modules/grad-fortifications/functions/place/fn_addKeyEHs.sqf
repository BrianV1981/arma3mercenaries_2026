grad_fortifications_keydownEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
    params ["_display", "_keyCode", "_ctrl", "_shift", "_alt"];

    private _builder = ACE_player;

    switch (true) do {
        case (_keyCode in [42,54]): {
            _builder setVariable ["grad_fortifications_shiftDown", true];
        };
        case (_keyCode in [29,157]): {
            _builder setVariable ["grad_fortifications_ctrlDown", true];
        };
        case (_keyCode in [56,184]): {
            _builder setVariable ["grad_fortifications_altDown", true];
        };
    };

    // Return true to consume the key event if it's one of the monitored keys
    (_keyCode in [42,54,29,157,56,184,15])
}];

grad_fortifications_keyupEH = (findDisplay 46) displayAddEventHandler ["KeyUp", {
    params ["_display", "_keyCode", "_ctrl", "_shift", "_alt"];

    private _builder = ACE_player;

    switch (true) do {
        case (_keyCode in [42,54]): {
            _builder setVariable ["grad_fortifications_shiftDown", false];
        };
        case (_keyCode in [29,157]): {
            _builder setVariable ["grad_fortifications_ctrlDown", false];
        };
        case (_keyCode in [56,184]): {
            _builder setVariable ["grad_fortifications_altDown", false];
        };
        case (_keyCode == 15): {
            if !(_builder getVariable ["grad_fortifications_surfaceNormalForced", false]) then {
                _builder setVariable ["grad_fortifications_surfaceNormal", !(_builder getVariable ["grad_fortifications_surfaceNormal", true])];
            };
        };
    };

    // Return true to consume the key event if it's one of the monitored keys
    (_keyCode in [42,54,29,157,56,184,15])
}];
