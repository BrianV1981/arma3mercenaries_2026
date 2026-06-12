/*
    A3M Salvage System - Initialization
    Author: A.I.M. / BrianV1981
    Description: Initializes the Mission Event Handler to automatically attach salvage interactions to destroyed vehicles.
    Note: Variables are handled via CBA settings in XEH_preInit.sqf.
*/

if (!isServer) exitWith {};

// --- GLOBAL HOOK ---
// This fires the exact millisecond any entity dies anywhere on the map (ALiVE, Zeus, Editor).
addMissionEventHandler ["EntityKilled", {
    params ["_killedEntity", "_killer", "_instigator", "_useEffects"];
    
    // Check if the destroyed entity was a land vehicle or aircraft
    if (_killedEntity isKindOf "LandVehicle" || _killedEntity isKindOf "Air") then {
        // Broadcast the ACE interaction to all clients so they can see the option
        [_killedEntity] remoteExec ["A3M_fnc_addSalvageInteraction", 0, true];
    };
}];
