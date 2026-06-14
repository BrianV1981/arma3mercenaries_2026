// Initialize CBA settings category
["initialize", "arma3mercenaries"] call CBA_settings_fnc_init;

// --- SATELLITE TRACKER SETTINGS ---
[
    "A3M_HVT_Satellite_Enabled",
    "CHECKBOX",
    ["Enable Satellite Tracker", "Allow players to buy satellite sweeps to locate HVTs."],
    ["A3M Settings", "Tasks"],
    true,
    true
] call CBA_Settings_fnc_init;

[
    "A3M_HVT_Satellite_Cost",
    "SLIDER",
    ["Satellite Sweep Cost", "Cost in funds to perform a satellite sweep."],
    ["A3M Settings", "Tasks"],
    [0, 500000, 25000, 0], // [min, max, default, trailing decimals]
    true
] call CBA_Settings_fnc_init;

// --- CAMPING / ADVANCE TIME SETTINGS ---
[
    "A3M_Camping_Enabled",
    "CHECKBOX",
    ["Enable Set Camp", "Allows players to skip time using the ACE self action."],
    ["A3M Settings", "Survival"],
    true,
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Camping_SkipHours",
    "SLIDER",
    ["Camp Skip Time (Hours)", "How many hours pass when setting camp."],
    ["A3M Settings", "Survival"],
    [1, 24, 6, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Camping_RestoreFatigue",
    "CHECKBOX",
    ["Camp Restores Fatigue", "Whether setting camp fully restores player fatigue."],
    ["A3M Settings", "Survival"],
    true,
    true
] call CBA_Settings_fnc_init;
