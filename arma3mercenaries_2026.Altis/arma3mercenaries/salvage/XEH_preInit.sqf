// A3M Salvage Ecosystem - CBA Settings Registration

[
    "A3M_Salvage_RequiredItem",
    "EDITBOX",
    ["Required Item", "Classname of the item required to salvage (leave empty for none)"],
    ["A3M: Vehicle Salvage", "1. Core Settings"],
    "ToolKit",
    1
] call CBA_fnc_addSetting;

[
    "A3M_Salvage_Time",
    "SLIDER",
    ["Salvage Time", "Time in seconds the progress bar takes"],
    ["A3M: Vehicle Salvage", "1. Core Settings"],
    [5, 300, 60, 0], // Min, Max, Default, Trailing Decimals
    1
] call CBA_fnc_addSetting;

[
    "A3M_Salvage_EconomyMode",
    "LIST",
    ["Economy Mode", "Which economy system to wire the payouts into"],
    ["A3M: Vehicle Salvage", "2. Economy Settings"],
    [
        [0, 1, 2, 3], 
        ["GRAD Money Menu (Bank)", "HoverGuy Simple Economy", "Custom Player Variable", "Physical Item Drop"], 
        0
    ],
    1
] call CBA_fnc_addSetting;

[
    "A3M_Salvage_CustomVariable",
    "EDITBOX",
    ["Custom Money Variable", "If using 'Custom Player Variable' mode, type the exact variable name here (e.g. life_cash)"],
    ["A3M: Vehicle Salvage", "2. Economy Settings"],
    "my_server_cash",
    1
] call CBA_fnc_addSetting;

[
    "A3M_Salvage_DefaultReward",
    "EDITBOX",
    ["Default Reward", "The default payout amount if the vehicle is not in the custom price list"],
    ["A3M: Vehicle Salvage", "2. Economy Settings"],
    "50000",
    1
] call CBA_fnc_addSetting;

[
    "A3M_Salvage_Values_String",
    "EDITBOX",
    ["Custom Prices Array", "Format: [['Classname', 75000], ['Classname2', 100000]]"],
    ["A3M: Vehicle Salvage", "3. Advanced Settings"],
    "[['O_MBT_02_cannon_F', 75000], ['O_Heli_Attack_02_F', 100000]]",
    1
] call CBA_fnc_addSetting;
