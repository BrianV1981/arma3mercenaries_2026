/*
    File: cfgFunctions.hpp
    Author: Gruppe Adler (Original), [Your Name/Alias] (Modifications)
    Date: [Date of Modification]

    Description:
        Defines the functions used by the grad-persistence module, compiling them
        into the CfgFunctions configuration for Arma 3. Organizes functions
        into categories (common, load, save).

    MODIFICATION NOTES (Namespace Separation):
    - Added the 'wipeCategory' function definition within the 'common' class.
    - Purpose: This function allows authorized users (admins) to selectively delete
               all persistent data belonging to a specific category (e.g., "fortifications")
               by deleting the profileNamespace assigned to it in the configuration.
    - Properties: Marked as 'serverOnly = 1' to ensure it can only be executed on the server.
*/

#ifndef MODULES_DIRECTORY
    #define MODULES_DIRECTORY modules // Defines the base directory for module functions
#endif

class GRAD_persistence { // Main class for the function library
    tag = "GRAD_persistence"; // Function tag prefix (e.g., GRAD_persistence_fnc_wipeCategory)

    class common { // Category for common/utility functions
        file = MODULES_DIRECTORY\grad-persistence\functions\common; // Path to function files

        // --- Existing Common Functions ---
        class blacklistClasses {};
        class blacklistObjects {};
        class clearMissionData {};
        class generateCountArray {};
        class getMarkerChannel {};
        class getMissionTag {};
        class handleDisconnect {};
        class handleJIP {};
        class initModule {postInit = 1;}; // Initialize post game init
        class isBlacklisted {};
        class showWarningMessage {};
        class tagEditorObjects {};
        class unblacklistClasses {};
        class unblacklistObjects {};

        // --- Added Function for Namespace Wiping ---
        class wipeCategory {
            description = "Wipes persistent data for a specific category by deleting its assigned profileNamespace."; // Optional description
            serverOnly = 1; // Crucial: Ensures this function only runs on the server
        };
    };

    class load { // Category for data loading functions
        file = MODULES_DIRECTORY\grad-persistence\functions\load; // Path to load function files

        // --- Existing Load Functions ---
        class addBackpacks {};
        class addItems {};
        class addMagazines {};
        class addWeaponItems {};
        class createVehicleCrew {};
        class loadAllPlayers {};
        class loadContainers {};
        class loadGradFortificationsStatics {}; // Modified for namespace loading
        class loadGroups {};
        class loadMarkers {};
        class loadMission {};
        class loadObjectVars {};
        class loadPlayer {};
        class loadPlayerChatcommandServer {};
        class loadStatics {};
        class loadTasks {};
        class loadTeamAccounts {};
        class loadTimeAndDate {};
        class loadTriggers {};
        class loadTurretMagazines {};
        class loadVariables {};
        class loadVehicleHits {};
        class loadVehicleInventory {};
        class loadVehicles {};
        class requestLoadPlayer {};
    };

    class save { // Category for data saving functions
        file = MODULES_DIRECTORY\grad-persistence\functions\save; // Path to save function files

        // --- Existing Save Functions ---
        class deInstanceACRERadios {}; // Make sure this exists in your save folder if listed
        class deInstanceTFARRadios {};
        class getApplicableMarkers {};
        class getInventory {};
        class saveAllPlayers {};
        class saveContainers {};
        class saveGradFortificationsStatics {}; // Modified for namespace saving
        class saveGroups {};
        class saveMarkers {};
        class saveMission {};
        class saveObjectVars {};
        class savePlayer {};
        class saveStatics {};
        class saveTasks {};
        class saveTeamAccounts {};
        class saveTimeAndDate {};
        class saveTriggers {};
        class saveVariables {};
        class saveVehicles {};
    };
};