// arma3mercenaries\sector_control\XEH_preInit.sqf

if (isNil "A3M_SectorConfig") then {
    A3M_SectorConfig = [
        // [TriggerName, RewardMult, SpawnProb, SectorName, BlockTimeSec, RewardTimeSec]
        ["trigger_sector1", 0.5, 0.0, "Fort MAGA", 7200, 300],
        ["trigger_sector2", 1.5, 0.50, "Paros", 3600, 600],
        ["trigger_sector3", 1.25, 0.25, "Pefkas Military Base", 5400, 600],
        ["trigger_sector4", 2.0, 1.0, "Pyrgos", 3600, 300],
        ["trigger_sector5", 1.5, 1.0, "Charkia", 3600, 600],
        ["trigger_sector6", 1.75, 1.25, "Anthrakia", 3600, 600],
        ["trigger_sector7", 1.25, 1.0, "Neochori", 3600, 600],
        ["trigger_sector8", 1.5, 1.0, "Athira", 7200, 600],
        ["trigger_sector9", 1.75, 1.25, "Lakka Military Base", 9000, 600],
        ["trigger_sector10", 1.5, 1.25, "Rodopoli", 3600, 600],
        ["trigger_sector11", 2.0, 1.75, "Telos Military Base", 10800, 720],
        ["trigger_sector12", 3.0, 1.9, "Gravia Airforce Base", 14400, 900]
    ];
};

{
    private _sectorName = _x select 3;
    private _defaultReward = _x select 1;
    private _defaultSpawn = _x select 2;
    private _defaultBlock = (_x select 4) / 60; // Convert to minutes for GUI

    private _varReward = format ["A3M_Sector_%1_RewardMult", _forEachIndex];
    private _varBlock = format ["A3M_Sector_%1_BlockMin", _forEachIndex];
    private _varSpawn = format ["A3M_Sector_%1_SpawnProb", _forEachIndex];

    [
        _varReward,
        "SLIDER",
        [format ["%1: Reward Multiplier", _sectorName], "Adjusts the base payout amount."],
        "A3M Sector Control",
        [0.0, 5.0, _defaultReward, 2], 
        true 
    ] call CBA_fnc_addSetting;

    [
        _varBlock,
        "SLIDER",
        [format ["%1: Block Time (Min)", _sectorName], "Adjusts the penalty block duration in minutes."],
        "A3M Sector Control",
        [1, 300, _defaultBlock, 0],
        true
    ] call CBA_fnc_addSetting;

    [
        _varSpawn,
        "SLIDER",
        [format ["%1: AI Spawn Probability", _sectorName], "Adjusts the chance of enemy counter-attacks."],
        "A3M Sector Control",
        [0.0, 3.0, _defaultSpawn, 2],
        true
    ] call CBA_fnc_addSetting;

} forEach A3M_SectorConfig;