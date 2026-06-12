/*
    Configuration for grad-persistence Mod
    
    MODIFICATION NOTES (A.I.M. v812+ Architecture):
    - Profile Namespaces have been completely removed. Data is now routed directly to
      an external SQLite database via `A3M_fnc_dbSetSecure`.
    - The old `PersistenceCategories` block is no longer needed. SQLite isolates data
      using explicit keys (e.g., "my_persistent_mission_vehicles_1").
    - The boolean flags below (saveUnits, saveVehicles, etc.) still control *whether*
      the data is gathered and sent to the database.
*/
// https://github.com/gruppe-adler/grad-persistence/wiki/Configuration
// https://github.com/gruppe-adler/grad-persistence/wiki/Saving-Variables
class CfgGradPersistence {
    missionTag = "my_persistent_mission"; // Used as the base prefix for all SQLite keys
    loadOnMissionStart = 1;
    missionWaitCondition = "true";
    playerWaitCondition = "true";

    // --- Core Save Flags ---
    // These flags enable/disable the saving/loading process for each category.
    // Set to 1 (load/save) or 3 (load/save/cleanup) to enable. 0 disables.
    
    saveUnits = 3;                  // Saves AI Groups to SQLite
    saveVehicles = 3;               // Saves Vehicles to SQLite
    saveContainers = 3;             // Saves Cargo Boxes to SQLite
    saveStatics = 0;                // Standard static objects (Disabled)
    saveGradFortificationsStatics = 3; // GRAD Fortifications to SQLite

    // --- Player State Flags ---
    savePlayerInventory = 1;
    savePlayerDamage = 1;
    savePlayerPosition = 1;         // Set to 0: Does not save player position (Loads at spawn point)
    savePlayerMoney = 1;

    // --- Mission State Flags ---
    saveMarkers = 3;
    saveTasks = 0;
    saveTriggers = 0;
    saveTeamAccounts = 0;
    saveTimeAndDate = 1;

    // --- Custom Variables ---
    // These variables will be attached to the respective entities when saved to SQLite.
    class customVariables {
        class acexFood {
            varName = "acex_field_rations_hunger";
            varNamespace = "player";
            public = 1;
        };
        class acexWater {
            varName = "acex_field_rations_thirst";
            varNamespace = "player";
            public = 1;
        };
        class hgOwner {
            varName = "HG_Owner";
            varNamespace = "vehicle";
            public = 1;
        };
        class aiUnit {
            varName = "arma3mercenaries_aiUnit";
            varNamespace = "unit";
            public = 1;
        };
        class groupID {
            varName = "arma3mercenaries_groupID";
            varNamespace = "unit";
            public = 1;
        };
        class a3mPlayerStats {
            varName = "a3m_playerStats";
            varNamespace = "mission";
            public = 0;
        };
        class gradFortVehicleInventory {
            varName = "grad_fortifications_myFortsHash";
            varNamespace = "vehicle";
            public = 1;
        };
        class gradFortPlayerInventory {
            varName = "grad_fortifications_myFortsHash";
            varNamespace = "player";
            public = 1;
        };
        class gradFortContainerInventory {
            varName = "grad_fortifications_myFortsHash";
            varNamespace = "container";
            public = 1;
        };
        class aceCargoLoaded {
            varName = "ace_cargo_loaded";
            varNamespace = "vehicle";
            public = 0;
        };
    };
};