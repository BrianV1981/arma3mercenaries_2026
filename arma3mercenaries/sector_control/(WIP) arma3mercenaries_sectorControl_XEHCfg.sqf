// arma3mercenaries\sector_control\arma3mercenaries_sectorControl_XEHCfg.sqf
/*
    Registers CBA settings for the arma3mercenaries Sector Control system.
    Run via XEH PostInit.
*/
diag_log "[A3M Sector Control] XEHCfg: Attempting to register CBA settings.";

// Prevent double initialization if script somehow runs twice
if !(isNil "arma3mercenaries_sectorControl_settings_defined") exitWith {
    diag_log "[A3M Sector Control] XEHCfg: Settings already defined. Exiting registration.";
};

// --- CBA Initialization ---
// Use a unique event name or ensure CBA is loaded before XEH PostInit runs
["CBA_settingsInitialized", {
    if (isServer) then {
        diag_log "[A3M Sector Control] XEHCfg: CBA Initialized, running settings registration on server.";
        ["initialize", "arma3mercenaries"] call CBA_settings_fnc_init; // Initialize our addon category if not already done

        // --- Define Default Sector Data (matches your fn_manageSectors array) ---
        // This is only used here to get default values for registration
        private _defaultSectorData = [
            // [TriggerName, BlockVar, CaptureVar, RewardMult, SpawnProb, SectorName, BlockTimeSec, RewardTimeSec] - Names/Vars aren't needed here
            [0.5, 0.0, "Fort MAGA", 7200, 720],
            [1.5, 0.50, "Paros", 7200, 720],
            [1.25, 0.25, "Pefkas Military Base", 7200, 720],
            [2.0, 1.0, "Pyrgos", 10800, 720],
            [1.5, 1.0, "Charkia", 7200, 720],
            [1.75, 1.25, "Anthrakia", 9000, 720],
            [1.25, 1.0, "Neochori", 7200, 720],
            [1.5, 1.0, "Athira", 7200, 720],
            [1.75, 1.25, "Lakka Military Base", 9000, 720],
            [1.5, 1.25, "Rodopoli", 7200, 720],
            [2.0, 1.75, "Telos Military Base", 10800, 720],
            [3.0, 1.9, "Gravia Airforce Base", 14400, 720]
        ];

        // --- Register Global Settings ---
        private _globalCat = "arma3mercenaries Sector Control Settings"; // Main Category defined in HPP
        private _globalSubCat = "Global Sector Settings"; // Sub Category defined in HPP

        [
            "arma3mercenaries_sectorControl_global_checkInterval",
            "SLIDER",
            ["Position Check Interval (Seconds)", "How often (in seconds) the script checks if a player is inside/outside a captured sector. Affects how quickly 'strikes' accumulate."],
            _globalSubCat, // Put under Global sub-category
            [10, 600, 120, 0], // Min, Max, Default, Decimals
            1, // Global setting (affects server logic)
            {}
        ] call CBA_fnc_addSetting;

         [
            "arma3mercenaries_sectorControl_global_maxRewards",
            "SLIDER",
            ["Rewards Before Completion Block", "How many reward payouts a player receives before being blocked from the sector (normal completion)."],
             _globalSubCat,
            [1, 20, 6, 0],
            1,
            {}
        ] call CBA_fnc_addSetting;

         [
            "arma3mercenaries_sectorControl_global_maxStrikes",
            "SLIDER",
            ["Strikes Before Strikeout Block", "How many consecutive position checks must fail (player outside) before they are blocked for leaving."],
             _globalSubCat,
            [1, 10, 3, 0],
            1,
            {}
        ] call CBA_fnc_addSetting;

        [
            "arma3mercenaries_sectorControl_global_mainLoopSleep",
            "SLIDER",
            ["Main Loop Scan Interval (Seconds)", "How often (in seconds) the main server loop scans all sector triggers for players to initiate the monitoring process."],
            _globalSubCat,
            [30, 600, 120, 0],
            1,
            {}
        ] call CBA_fnc_addSetting;


        // --- Register Per-Sector Settings ---
        { // Loop through the default data to register settings for sectors 1 to 12
            private _index = _forEachIndex + 1; // Sector index (1-based)
            private _sectorDefaults = _x; // Current sector's default values [RewardMult, SpawnProb, Name, BlockTime, RewardTime]
            private _defaultRewardMult = _sectorDefaults select 0;
            private _defaultSpawnProb = _sectorDefaults select 1;
            private _sectorName = _sectorDefaults select 2;
            private _defaultBlockTime = _sectorDefaults select 3;
            private _defaultRewardTime = _sectorDefaults select 4;

            // Define CBA Subcategory Title for this sector
            private _sectorSubCat = format ["Sector %1: %2 Settings", _index, _sectorName];

            // Register Reward Multiplier
            [
                format ["arma3mercenaries_sectorControl_sector%1_rewardMultiplier", _index], // Variable name
                "SLIDER",
                ["Reward Multiplier", "Adjusts the base reward amounts for this specific sector (e.g., 0.5 = half reward, 2.0 = double reward)."],
                _sectorSubCat, // Put under this sector's sub-category
                [0.0, 5.0, _defaultRewardMult, 2], // Min, Max, Default, Decimals
                1, // Global setting
                {}
            ] call CBA_fnc_addSetting;

            // Register Spawn Probability Multiplier
            [
                format ["arma3mercenaries_sectorControl_sector%1_spawnProbability", _index],
                "SLIDER",
                ["Enemy Spawn Probability Multiplier", "Adjusts the chance of enemy groups spawning during the reward cycle for this sector (0 = never, 1 = default chance, 2 = double chance)."],
                _sectorSubCat,
                [0.0, 3.0, _defaultSpawnProb, 2],
                1,
                {}
            ] call CBA_fnc_addSetting;

            // Register Block Time
            [
                 format ["arma3mercenaries_sectorControl_sector%1_blockTime", _index],
                 "SLIDER",
                 ["Block Duration (Seconds)", "How long (in seconds) a player is blocked from this sector after completing rewards or being struck out."],
                 _sectorSubCat,
                 [60, 28800, _defaultBlockTime, 0], // 1 min to 8 hours
                 1,
                 {}
             ] call CBA_fnc_addSetting;

            // Register Reward Grant Interval
             [
                 format ["arma3mercenaries_sectorControl_sector%1_rewardTime", _index],
                 "SLIDER",
                 ["Reward Grant Interval (Seconds)", "How often (in seconds) a reward payout is actually given to the player (if they are inside the sector)."],
                 _sectorSubCat,
                 [60, 3600, _defaultRewardTime, 0], // 1 min to 1 hour
                 1,
                 {}
             ] call CBA_fnc_addSetting;

        } forEach _defaultSectorData;

         diag_log "[A3M Sector Control] XEHCfg: CBA settings registration complete.";

    }; // end isServer check
}] call CBA_fnc_addEventHandler;

// Set flag to prevent re-registration
arma3mercenaries_sectorControl_settings_defined = true;