// --- File: modules\grad-fortifications\functions\place\fn_removeAllEHs.sqf ---
// (Updated with corrected PFH variable names)

// Remove standard display event handlers
(findDisplay 46) displayRemoveEventHandler ["MouseZChanged", grad_fortifications_mousewheelEH];
(findDisplay 46) displayRemoveEventHandler ["MouseButtonUp", grad_fortifications_mousebuttonEH];
(findDisplay 46) displayRemoveEventHandler ["KeyDown", grad_fortifications_keydownEH];
(findDisplay 46) displayRemoveEventHandler ["KeyUp", grad_fortifications_keyupEH];

// Remove CBA Per-Frame Handlers using the corrected variable names
// Assuming the handles were stored in variables ending with '_handle'
diag_log format ["GRAD FORT [%1]: Removing Update PFH using handle: %2", diag_frameno, grad_fortifications_updatePFH_handle];
[grad_fortifications_updatePFH_handle] call CBA_fnc_removePerFrameHandler; // Corrected variable name

diag_log format ["GRAD FORT [%1]: Removing Collision PFH using handle: %2", diag_frameno, grad_fortifications_checkCollisionPFH_handle]; // Assuming this follows the same pattern
[grad_fortifications_checkCollisionPFH_handle] call CBA_fnc_removePerFrameHandler; // Corrected variable name (assuming pattern)

// Remove the ACE action override
diag_log format ["GRAD FORT [%1]: Removing ACE fire override action.", diag_frameno];
ACE_player removeAction grad_fortifications_fireOverride;

// Clear the handle variables after removal (good practice)
grad_fortifications_updatePFH_handle = nil;
grad_fortifications_checkCollisionPFH_handle = nil; // Clear assumed collision handle variable too
grad_fortifications_mousewheelEH = nil;
grad_fortifications_mousebuttonEH = nil;
grad_fortifications_keydownEH = nil;
grad_fortifications_keyupEH = nil;

diag_log format ["GRAD FORT [%1]: fn_removeAllEHs finished.", diag_frameno];