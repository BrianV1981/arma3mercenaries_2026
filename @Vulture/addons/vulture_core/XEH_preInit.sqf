// Vulture: Dynamic Wreck Salvage - CBA Settings Registration

[
    "Vulture_RequiredItem",
    "EDITBOX",
    ["Required Item", "Classname of the item required to salvage (leave empty for none)"],
    ["Vulture: Wreck Salvage", "1. Core Settings"],
    "ToolKit",
    1
] call CBA_fnc_addSetting;

[
    "Vulture_SalvageTime",
    "SLIDER",
    ["Salvage Time", "Time in seconds the progress bar takes"],
    ["Vulture: Wreck Salvage", "1. Core Settings"],
    [5, 300, 60, 0], // Min, Max, Default, Trailing Decimals
    1
] call CBA_fnc_addSetting;

[
    "Vulture_EconomyMode",
    "LIST",
    ["Economy Mode", "Which economy system to wire the payouts into"],
    ["Vulture: Wreck Salvage", "2. Economy Settings"],
    [
        [0, 1, 2, 3], 
        ["GRAD Money Menu (Bank)", "HoverGuy Simple Economy", "Custom Player Variable", "Physical Item Drop"], 
        0
    ],
    1
] call CBA_fnc_addSetting;

[
    "Vulture_CustomVariable",
    "EDITBOX",
    ["Custom Money Variable", "If using 'Custom Player Variable' mode, type the exact variable name here (e.g. life_cash)"],
    ["Vulture: Wreck Salvage", "2. Economy Settings"],
    "my_server_cash",
    1
] call CBA_fnc_addSetting;

[
    "Vulture_DefaultReward",
    "EDITBOX",
    ["Default Reward", "The default payout amount if the vehicle is not in the custom price list"],
    ["Vulture: Wreck Salvage", "2. Economy Settings"],
    "50000",
    1
] call CBA_fnc_addSetting;

[
    "Vulture_CustomValues",
    "EDITBOX",
    ["Custom Prices Array", "Format: [['Classname', 75000], ['Classname2', 100000]]"],
    ["Vulture: Wreck Salvage", "3. Advanced Settings"],
    "[]",
    1
] call CBA_fnc_addSetting;
