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
    [0, 500000, 100000, 0], // [min, max, default, trailing decimals]
    true
] call CBA_Settings_fnc_init;

[
    "A3M_HVT_Satellite_Duration",
    "SLIDER",
    ["Satellite Feed Duration", "How long the drone visual feed lasts (in seconds)."],
    ["A3M Settings", "Tasks"],
    [5, 120, 60, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_HVT_Satellite_Cooldown",
    "SLIDER",
    ["Satellite Cooldown", "Cooldown in seconds before another sweep can be purchased globally."],
    ["A3M Settings", "Tasks"],
    [0, 3600, 300, 0],
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

// --- ALiVE REWARD SETTINGS ---
[
    "A3M_ALiVE_RewardDistribution",
    "LIST",
    ["ALiVE Reward Distribution", "Who receives the payout when an ALiVE task is completed."],
    ["A3M Settings", "ALiVE Integration"],
    [
        [0, 1, 2],
        ["Reward Side", "Reward Side + Allies", "Players Involved Only"],
        0
    ],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_ALiVE_RewardAmount",
    "SLIDER",
    ["ALiVE Task Reward Amount", "Funds distributed upon completing a C2ISTAR task."],
    ["A3M Settings", "ALiVE Integration"],
    [0, 1000000, 10000, 0],
    true
] call CBA_Settings_fnc_init;

// --- DYNAMIC ECONOMY SETTINGS ---
[
    "A3M_Economy_Enable",
    "CHECKBOX",
    ["Enable Dynamic Economy", "Allow the server to generate daily sales and stock shortages."],
    ["A3M Settings", "Dynamic Economy"],
    true,
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_OOSChance",
    "SLIDER",
    ["Out of Stock Chance (%)", "The percentage chance an item will completely sell out."],
    ["A3M Settings", "Dynamic Economy"],
    [0, 100, 5, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_LowStockChance",
    "SLIDER",
    ["Low Stock Chance (%)", "The percentage chance an item will have low inventory (1-3 items) if it isn't sold out."],
    ["A3M Settings", "Dynamic Economy"],
    [0, 100, 10, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_OverstockCount",
    "SLIDER",
    ["Overstock Sale Count", "How many items are randomly selected for the massive Overstock discount."],
    ["A3M Settings", "Dynamic Economy"],
    [0, 100, 4, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_OverstockDiscount",
    "SLIDER",
    ["Overstock Discount (%)", "How much cheaper these items are (e.g., 50 = Half Price)."],
    ["A3M Settings", "Dynamic Economy"],
    [1, 99, 50, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_ClearanceCount",
    "SLIDER",
    ["Clearance Sale Count", "How many items are randomly selected for the Clearance discount."],
    ["A3M Settings", "Dynamic Economy"],
    [0, 100, 10, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_ClearanceDiscount",
    "SLIDER",
    ["Clearance Discount (%)", "How much cheaper these items are (e.g., 30 = 30% Off)."],
    ["A3M Settings", "Dynamic Economy"],
    [1, 99, 30, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_DailyCount",
    "SLIDER",
    ["Daily Sale Count", "How many items are randomly selected for the standard Daily discount."],
    ["A3M Settings", "Dynamic Economy"],
    [0, 100, 30, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_DailyDiscount",
    "SLIDER",
    ["Daily Discount (%)", "How much cheaper these items are (e.g., 10 = 10% Off)."],
    ["A3M Settings", "Dynamic Economy"],
    [1, 99, 10, 0],
    true
] call CBA_Settings_fnc_init;

// --- BASE STOCK GENERATION ---
[
    "A3M_Economy_BaseStock_WeaponsMin",
    "SLIDER",
    ["Weapons Min Stock", "Minimum number of standard weapons available."],
    ["A3M Settings", "Dynamic Economy (Stock Ranges)"],
    [0, 100, 4, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_BaseStock_WeaponsMax",
    "SLIDER",
    ["Weapons Max Stock", "Maximum number of standard weapons available."],
    ["A3M Settings", "Dynamic Economy (Stock Ranges)"],
    [0, 100, 15, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_BaseStock_MagsMin",
    "SLIDER",
    ["Magazines Min Stock", "Minimum number of magazines available."],
    ["A3M Settings", "Dynamic Economy (Stock Ranges)"],
    [0, 500, 30, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_BaseStock_MagsMax",
    "SLIDER",
    ["Magazines Max Stock", "Maximum number of magazines available."],
    ["A3M Settings", "Dynamic Economy (Stock Ranges)"],
    [0, 500, 120, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_BaseStock_BackpacksMin",
    "SLIDER",
    ["Backpacks Min Stock", "Minimum number of backpacks available."],
    ["A3M Settings", "Dynamic Economy (Stock Ranges)"],
    [0, 200, 10, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_BaseStock_BackpacksMax",
    "SLIDER",
    ["Backpacks Max Stock", "Maximum number of backpacks available."],
    ["A3M Settings", "Dynamic Economy (Stock Ranges)"],
    [0, 200, 30, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_BaseStock_MiscMin",
    "SLIDER",
    ["Misc Items Min Stock", "Minimum number of misc items (equipment) available."],
    ["A3M Settings", "Dynamic Economy (Stock Ranges)"],
    [0, 200, 15, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_BaseStock_MiscMax",
    "SLIDER",
    ["Misc Items Max Stock", "Maximum number of misc items (equipment) available."],
    ["A3M Settings", "Dynamic Economy (Stock Ranges)"],
    [0, 200, 50, 0],
    true
] call CBA_Settings_fnc_init;

// --- ARMORY (BLACK MARKET) SETTINGS ---
[
    "A3M_Armory_CustomSpawn",
    "EDITBOX",
    ["Custom Spawn Coordinate", "Override the dynamic hover. Enter coordinates like [1234, 5678, 10] to force the Armory to spawn in a specific physical room. Leave blank to use dynamic hover."],
    ["A3M Settings", "Armory (Black Market)"],
    "",
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Armory_HoverHeight",
    "SLIDER",
    ["Dynamic Hover Altitude", "If using dynamic hover, how high above the player should the Armory spawn? Default is 30m."],
    ["A3M Settings", "Armory (Black Market)"],
    [5, 10000, 30, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Armory_HoverDistance",
    "SLIDER",
    ["Dynamic Hover Distance", "If using dynamic hover, how far forward from the player should the Armory spawn? Default is 0m (directly above)."],
    ["A3M Settings", "Armory (Black Market)"],
    [0, 100, 0, 0],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Armory_StudioLighting",
    "SLIDER",
    ["Studio Lighting Brightness", "Brightness of the automatic light spawned in the Armory at night."],
    ["A3M Settings", "Armory (Black Market)"],
    [0, 5, 1.5, 1],
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Armory_GhostProtocol",
    "CHECKBOX",
    ["Ghost Protocol (Invincibility)", "Make players invisible and completely invincible while they are inside the Armory (Prevents getting sniped while shopping)."],
    ["A3M Settings", "Armory (Black Market)"],
    true,
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Armory_RoomShell",
    "LIST",
    ["Local Room Shell", "Spawn a local, invisible-to-others physical structure around the player during shopping to boost FPS and immersion."],
    ["A3M Settings", "Armory (Black Market)"],
    [
        ["", "Land_VR_Block_02_F", "Land_Dome_Big_F", "Land_Pier_F"],
        ["None (Floating)", "VR Grid Floor (Open)", "Massive Concrete Dome (Enclosed)", "Concrete Pier Platform (Open)"],
        0
    ],
    true
] call CBA_Settings_fnc_init;
