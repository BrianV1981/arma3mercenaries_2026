// Vulture: Dynamic Wreck Salvage - Post Initialization

if (hasInterface) then {
    // Only compile the add action function on clients who need it
    // Vulture_fnc_addSalvageInteraction is compiled via config.cpp CfgFunctions
};

if (isServer) then {
    // Call the core initialization script to set up the EntityKilled hook
    [] call Vulture_fnc_initSalvage;
};
