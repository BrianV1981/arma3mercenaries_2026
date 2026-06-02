// Initialize CBA settings for arma3mercenaries
["CBA_settingsInitialized", { // Safer initialization check
    if (isServer) then {
        ["initialize", "arma3mercenaries"] call CBA_settings_fnc_init;
    };
}] call CBA_fnc_addEventHandler;


// CBA settings for Kill Feed
[
    "arma3mercenaries_killFeedDuration",
    "SLIDER",
    ["Killfeed Display Duration", "Adjust the duration (in seconds) the killfeed notification remains on screen."],
    "arma3mercenaries Killfeed Settings",
    [1, 20, 5, 1],
    1, // Server only = false (0) or Global (1)? Keep 1 for global consistency
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_killFeedEnabled",
    "CHECKBOX",
    ["Enable Killfeed", "Toggles the display of the killfeed notification."],
    "arma3mercenaries Killfeed Settings",
    true,
    1, // Global setting
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_killNotificationSound",
    "CHECKBOX",
    ["Enable Kill Notification Sound", "Toggles the sound notification that plays when a kill is registered."],
    "arma3mercenaries Killfeed Settings",
    true,
    1, // Global setting
    {}
] call CBA_fnc_addSetting;

// <<< UPDATED SETTING >>>
[
    "arma3mercenaries_penaltyWarningsEnabled", // Renamed variable
    "CHECKBOX",
    [
        "Enable Penalty/Warning Messages", // Updated Title
        "Toggles the dynamic text display for penalties (FF, Civ, Indep), compensation (FF), and death." // Updated Description
    ],
    "arma3mercenaries Killfeed Settings", // Category remains Killfeed Settings
    true, // Default: Enabled
    1, // Global setting
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_penaltyWarningDuration", // Variable Name
    "SLIDER", // Control Type
    [
        "Penalty/Warning Display Duration", // Title
        "Adjust the duration (in seconds) the penalty/warning message remains on screen." // Description
    ],
    "arma3mercenaries Killfeed Settings", // Category
    [1, 20, 6, 1], // Min: 1, Max: 20, Default: 6, Decimals: 1
    1, // Global setting
    {}
] call CBA_fnc_addSetting;

// <<< END OF UPDATE >>>

// CBA settings for Reward System
[
    "arma3mercenaries_friendlyFirePenalty",
    "SLIDER",
    ["Friendly Fire Penalty (Bank)", "Set the amount of credits deducted for friendly fire incidents from the player's bank account."],
    "arma3mercenaries Reward Settings",
    [0, 100000, 10000, 1000], // Range, Default, Step
    1, // Global setting
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_friendlyFireCompensation",
    "SLIDER",
    ["Friendly Fire Compensation (Bank)", "Set the amount of credits awarded to a player when killed by friendly fire. Credits are added to the player's bank account."],
    "arma3mercenaries Reward Settings",
    [0, 100000, 20000, 1000],
    1,
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_opforKillReward",
    "SLIDER",
    ["OPFOR Kill Reward (Random, Wallet)", "Set the maximum random amount of credits awarded for killing an OPFOR unit. Credits are added to the player's wallet."],
    "arma3mercenaries Reward Settings",
    [0, 100000, 10000, 1000],
    1,
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_opforAiWallet",
    "SLIDER",
    ["OPFOR AI Wallet Amount (Random, Wallet)", "Set the amount of random credits awarded to a killed OPFOR AI unit. Credits are added to the AI unit's wallet."],
    "arma3mercenaries Reward Settings",
    [0, 100000, 10000, 1000],
    1,
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_natoKillReward",
    "SLIDER",
    ["NATO Kill Reward (Random, Wallet)", "Set the maximum random amount of credits awarded for killing a NATO unit. Credits are added to the player's wallet."],
    "arma3mercenaries Reward Settings",
    [0, 100000, 10000, 1000],
    1,
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_natoAiWallet",
    "SLIDER",
    ["NATO AI Wallet Amount (Random, Wallet)", "Set the amount of random credits awarded to a killed NATO AI unit. Credits are added to the AI unit's wallet."],
    "arma3mercenaries Reward Settings",
    [0, 100000, 1000, 100],
    1,
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_independentKillReward",
    "SLIDER",
    ["Independent Kill Reward (Random, Wallet)", "Set the maximum random amount of credits awarded for killing an Independent unit. Credits are added to the player's wallet."],
    "arma3mercenaries Reward Settings",
    [0, 100000, 10000, 1000],
    1,
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_independentAiWallet",
    "SLIDER",
    ["Independent AI Wallet Amount (Random, Wallet)", "Set the amount of random credits awarded to a killed Independent AI unit. Credits are added to the AI unit's wallet."],
    "arma3mercenaries Reward Settings",
    [0, 100000, 1000, 100],
    1,
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_natoPenaltyIndependent",
    "SLIDER",
    ["NATO Penalty for Killing Independent (Bank)", "Set the amount of credits deducted from a NATO player's bank account for killing an Independent unit."],
    "arma3mercenaries Reward Settings",
    [0, 100000, 10000, 1000],
    1,
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_civilianKillPenalty",
    "SLIDER",
    ["Civilian Kill Penalty (Bank)", "Set the amount of credits deducted from a player's bank account for killing a civilian."],
    "arma3mercenaries Reward Settings",
    [0, 100000, 10000, 1000],
    1,
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_civilianAiWallet",
    "SLIDER",
    ["Civilian AI Wallet Amount (Random, Wallet)", "Set the amount of random credits awarded to a killed Civilian AI unit. Credits are added to the AI unit's wallet."],
    "arma3mercenaries Reward Settings",
    [0, 100000, 1000, 100],
    1,
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_deathPenalty",
    "SLIDER",
    ["Death Penalty Amount (Bank)", "Set the amount of credits deducted from the player's bank account when they die."],
    "arma3mercenaries Reward Settings",
    [0, 100000, 10000, 1000],
    1,
    {}
] call CBA_fnc_addSetting;


// CBA settings for Marker System
[
    "arma3mercenaries_killMarkerEnabled",
    "CHECKBOX",
    ["Enable Kill Markers", "Toggles the creation of kill markers on the map."],
    "arma3mercenaries Marker Settings",
    true,
    1,
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_killMarkerSize",
    "SLIDER",
    ["Kill Marker Size", "Set the size of the kill markers on the map."],
    "arma3mercenaries Marker Settings",
    [0.1, 2, 0.5, 0.1],
    1,
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_deathMarkerEnabled",
    "CHECKBOX",
    ["Enable Death Markers", "Toggles the creation of death markers on the map."],
    "arma3mercenaries Marker Settings",
    true,
    1,
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_deathMarkerSize",
    "SLIDER",
    ["Death Marker Size", "Set the size of the death markers on the map."],
    "arma3mercenaries Marker Settings",
    [0.1, 2, 0.5, 0.1],
    1,
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_globalKillMarker",
    "CHECKBOX",
    ["Enable Global Kill Marker Notifications", "Toggles the display of kill marker notifications in the global side chat."],
    "arma3mercenaries Marker Settings",
    true, // Default to true based on HPP
    1,
    {}
] call CBA_fnc_addSetting;

[
    "arma3mercenaries_globalDeathMarker",
    "CHECKBOX",
    ["Enable Global Death Marker Notifications", "Toggles the display of death marker notifications in the global side chat."],
    "arma3mercenaries Marker Settings",
    true, // Default to true based on HPP
    1,
    {}
] call CBA_fnc_addSetting;

// <<< REMOVED Unconscious Marker Setting Registration >>>