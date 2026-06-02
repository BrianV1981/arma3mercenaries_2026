// arma3mercenaries\sector_control\XEH_preInit.sqf

[
    "A3M_Sector_GlobalRewardMult",
    "SLIDER",
    ["Global Reward Multiplier", "Adjusts the base payout amount for all sectors."],
    "A3M Sector Control",
    [0.1, 5.0, 1.0, 1], // [Min, Max, Default, Decimals]
    true // isGlobal (Server-side setting only)
] call CBA_fnc_addSetting;

[
    "A3M_Sector_GlobalBlockMult",
    "SLIDER",
    ["Global Block Time Multiplier", "Adjusts the penalty block duration for all sectors."],
    "A3M Sector Control",
    [0.1, 5.0, 1.0, 1],
    true
] call CBA_fnc_addSetting;

[
    "A3M_Sector_GlobalSpawnProb",
    "SLIDER",
    ["Global AI Spawn Probability", "Adjusts the chance of enemy counter-attacks during capture (1.0 = normal, 2.0 = double chance, 0 = disabled)."],
    "A3M Sector Control",
    [0.0, 3.0, 1.0, 1],
    true
] call CBA_fnc_addSetting;