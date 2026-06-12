// https://github.com/gruppe-adler/grad-persistence/wiki/Configuration
// https://github.com/gruppe-adler/grad-persistence/wiki/Saving-Variables
class CfgGradPersistence_fortifications {
    missionTag = "fortifications_persistent_save";
    loadOnMissionStart = 1;
    missionWaitCondition = "true";
    playerWaitCondition = "true";

    saveUnits = 0;
    saveVehicles = 0;
    saveContainers = 0;
    saveStatics = 0;
	saveGradFortificationsStatics = 3;
	
    savePlayerInventory = 0;
    savePlayerDamage = 0;
    savePlayerPosition = 0;
    savePlayerMoney = 0;
	
    saveMarkers = 0;
    saveTasks = 0;
    saveTriggers = 0;
    saveTeamAccounts = 0;
	saveTimeAndDate = 0;
	
	};