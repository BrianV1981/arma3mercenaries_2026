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
    "A3M_Economy_Whitelist_ZeroCost",
    "CHECKBOX",
    ["Whitelist $0 Items", "Automatically exempt all items with a base cost of $0 from the economy changes (sales & shortages)."],
    ["A3M Settings", "Dynamic Economy (Whitelist)"],
    true,
    true
] call CBA_Settings_fnc_init;

[
    "A3M_Economy_Whitelist_Classes",
    "EDITBOX",
    ["Whitelisted Items (Comma Separated)", "Specific classnames that should be ignored by the economy (e.g. 'hgun_P07_F, ItemMap')."],
    ["A3M Settings", "Dynamic Economy (Whitelist)"],
    "",
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
        ["", "Land_Warehouse_03_F", "Land_Pier_F"],
        ["None (Floating)", "Warehouse (Blue)", "Concrete Pier (Open)"],
        0
    ],
    true
] call CBA_Settings_fnc_init;

// --- AMBIENT CSAR (FACTION 1) ---
[
    "A3M_CSAR_F1_Enabled", "CHECKBOX", ["Enable Faction 1 CSAR", "Turn on ambient patrols."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], false, true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_Debug", "CHECKBOX", ["Debug Map Tracker", "Places a live map marker on the aircraft to monitor its route."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], false, true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_Side", "LIST", ["Faction Side", "The military branch this aircraft belongs to."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [[0, 1, 2], ["WEST (NATO)", "EAST (CSAT)", "INDEPENDENT"], 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_Vehicles", "EDITBOX", ["Vehicle Classes", "Comma-separated list of aircraft classnames. Example: 'B_Plane_CAS_01_dynamicLoadout_F'"],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], "'B_Heli_Attack_01_dynamicLoadout_F', 'B_Plane_CAS_01_dynamicLoadout_F'", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_SpawnCoord", "EDITBOX", ["Ground Spawn Coordinate", "Exact spot [X,Y,Z] where the vehicle will spawn parked. Leave blank to spawn directly in the air."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_SpawnMarker", "EDITBOX", ["Ground Spawn Marker", "Name of an invisible map marker showing exactly where the vehicle should spawn parked."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_SpawnDir", "SLIDER", ["Ground Spawn Direction", "If using the Coordinate box above, which compass direction (0-360) should the vehicle face when parked?"],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [0, 360, 0, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_ExtractionMarker", "EDITBOX", ["Extraction Marker (Success)", "The marker name where 0 pilots must be returned to succeed the CSAR. Defaults to origin or Safe TAOR."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_SafeTaor", "EDITBOX", ["Safe Zone TAOR (Extraction Fallback)", "If Extraction Marker is blank, the marker name of the territory where pilots must be extracted to."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], "blue_taor", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_QRF_Faction", "EDITBOX", ["Enemy QRF Faction", "The classname of the enemy faction that will attack the downed pilot (e.g., 'OPF_F', 'BLU_F', 'CUP_O_RU')."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], "OPF_F", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_QRF_SpawnChance", "SLIDER", ["QRF Spawn Probability (%)", "Percentage chance that enemy QRF forces will detect the crash and send patrols to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [0, 100, 50, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_QRF_SquadCountMin", "SLIDER", ["QRF Squads (Min)", "Minimum number of enemy infantry squads sent to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [0, 5, 0, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_QRF_SquadCountMax", "SLIDER", ["QRF Squads (Max)", "Maximum number of enemy infantry squads sent to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [0, 5, 2, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_QRF_PursuitDelayMin", "SLIDER", ["QRF Pursuit Delay Min (Minutes)", "Minimum time after the crash before enemy QRF forces are deployed to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [0, 120, 5, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_QRF_PursuitDelayMax", "SLIDER", ["QRF Pursuit Delay Max (Minutes)", "Maximum time after the crash before enemy QRF forces are deployed to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [0, 120, 15, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_FallbackTaor", "EDITBOX", ["Air Spawn Marker", "If spawning in the air, the name of the map marker it will spawn over."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], "blue_taor", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_FallbackCoord", "EDITBOX", ["Air Spawn Coord [X,Y]", "If spawning in the air, the exact coordinate it will spawn over."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_FallbackRadius", "SLIDER", ["Air Spawn Radius", "If spawning in the air using Coordinates, it will spawn randomly within this radius."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [100, 10000, 1000, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_TargetTaor", "EDITBOX", ["Patrol Target Marker", "Name of a map marker (like a rectangle) the aircraft will fly to and patrol inside."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], "unoccupied_taor_1", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_TargetCoord", "EDITBOX", ["Patrol Target Coord [X,Y]", "Exact [X,Y] coordinate the aircraft will fly to and patrol."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_TargetRadius", "SLIDER", ["Patrol Target Radius", "If using Target Coordinates, the aircraft will randomly hunt within this radius of the coordinate."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [100, 10000, 2000, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_RewardAmount", "SLIDER", ["Reward Amount (Cr)", "The amount of GRAD Money (Cr) to reward upon success."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [0, 5000000, 250000, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_XPRewardAmount", "SLIDER", ["Reward Amount (XP)", "The amount of HG Experience (XP) to reward upon success."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [0, 10000, 500, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_RewardRadius", "LIST", ["Reward Distribution", "Who receives the payout when the pilot is rescued?"],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [[0, 1, 2], ["Server Wide (All Players)", "Side Only (Allies)", "Proximity (Within 300m of Extraction)"], 2], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_PilotAnnouncements", "CHECKBOX", ["Pilot Radio Chatter", "If true, the CSAR pilot will broadcast radio transmissions over the side channel when taking off, crashing, and being rescued."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], true, true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_StartupDelayMin", "SLIDER", ["Pre-Flight Delay Min (Min)", "Minimum time the aircraft sits cold on the tarmac before taxiing."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [0, 30, 1, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_StartupDelayMax", "SLIDER", ["Pre-Flight Delay Max (Min)", "Maximum time the aircraft sits cold on the tarmac before taxiing."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [0, 30, 3, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_CooldownMin", "SLIDER", ["Cooldown Min (Minutes)", "Minimum time before next sortie launches."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [1, 60, 5, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F1_CooldownMax", "SLIDER", ["Cooldown Max (Minutes)", "Maximum time before next sortie launches."],
    ["A3M Settings", "Ambient CSAR (Faction 1)"], [1, 60, 10, 0], true
] call CBA_Settings_fnc_init;

// --- AMBIENT CSAR (FACTION 2) ---
[
    "A3M_CSAR_F2_Enabled", "CHECKBOX", ["Enable Faction 2 CSAR", "Turn on ambient patrols."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], false, true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_Debug", "CHECKBOX", ["Debug Map Tracker", "Places a live map marker on the aircraft to monitor its route."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], false, true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_Side", "LIST", ["Faction Side", "The military branch this aircraft belongs to."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [[0, 1, 2], ["WEST (NATO)", "EAST (CSAT)", "INDEPENDENT"], 1], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_Vehicles", "EDITBOX", ["Vehicle Classes", "Comma-separated list of aircraft classnames. Example: 'B_Plane_CAS_01_dynamicLoadout_F'"],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], "'O_Plane_CAS_02_dynamicLoadout_F', 'O_Heli_Attack_02_dynamicLoadout_F'", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_SpawnCoord", "EDITBOX", ["Ground Spawn Coordinate", "Exact spot [X,Y,Z] where the vehicle will spawn parked. Leave blank to spawn directly in the air."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_SpawnMarker", "EDITBOX", ["Ground Spawn Marker", "Name of an invisible map marker showing exactly where the vehicle should spawn parked."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_SpawnDir", "SLIDER", ["Ground Spawn Direction", "If using the Coordinate box above, which compass direction (0-360) should the vehicle face when parked?"],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [0, 360, 0, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_ExtractionMarker", "EDITBOX", ["Extraction Marker (Success)", "The marker name where 1 pilots must be returned to succeed the CSAR. Defaults to origin or Safe TAOR."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_SafeTaor", "EDITBOX", ["Safe Zone TAOR (Extraction Fallback)", "If Extraction Marker is blank, the marker name of the territory where pilots must be extracted to."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], "red_taor_1", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_QRF_Faction", "EDITBOX", ["Enemy QRF Faction", "The classname of the enemy faction that will attack the downed pilot (e.g., 'OPF_F', 'BLU_F', 'CUP_O_RU')."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], "BLU_F", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_QRF_SpawnChance", "SLIDER", ["QRF Spawn Probability (%)", "Percentage chance that enemy QRF forces will detect the crash and send patrols to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [0, 100, 50, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_QRF_SquadCountMin", "SLIDER", ["QRF Squads (Min)", "Minimum number of enemy infantry squads sent to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [0, 5, 0, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_QRF_SquadCountMax", "SLIDER", ["QRF Squads (Max)", "Maximum number of enemy infantry squads sent to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [0, 5, 2, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_QRF_PursuitDelayMin", "SLIDER", ["QRF Pursuit Delay Min (Minutes)", "Minimum time after the crash before enemy QRF forces are deployed to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [0, 120, 5, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_QRF_PursuitDelayMax", "SLIDER", ["QRF Pursuit Delay Max (Minutes)", "Maximum time after the crash before enemy QRF forces are deployed to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [0, 120, 15, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_FallbackTaor", "EDITBOX", ["Air Spawn Marker", "If spawning in the air, the name of the map marker it will spawn over."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], "red_taor_1", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_FallbackCoord", "EDITBOX", ["Air Spawn Coord [X,Y]", "If spawning in the air, the exact coordinate it will spawn over."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_FallbackRadius", "SLIDER", ["Air Spawn Radius", "If spawning in the air using Coordinates, it will spawn randomly within this radius."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [100, 10000, 1000, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_TargetTaor", "EDITBOX", ["Patrol Target Marker", "Name of a map marker (like a rectangle) the aircraft will fly to and patrol inside."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], "blue_taor", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_TargetCoord", "EDITBOX", ["Patrol Target Coord [X,Y]", "Exact [X,Y] coordinate the aircraft will fly to and patrol."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_TargetRadius", "SLIDER", ["Patrol Target Radius", "If using Target Coordinates, the aircraft will randomly hunt within this radius of the coordinate."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [100, 10000, 2000, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_RewardAmount", "SLIDER", ["Reward Amount (Cr)", "The amount of GRAD Money (Cr) to reward upon success."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [0, 5000000, 250000, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_XPRewardAmount", "SLIDER", ["Reward Amount (XP)", "The amount of HG Experience (XP) to reward upon success."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [0, 10000, 500, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_RewardRadius", "LIST", ["Reward Distribution", "Who receives the payout when the pilot is rescued?"],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [[0, 1, 2], ["Server Wide (All Players)", "Side Only (Allies)", "Proximity (Within 300m of Extraction)"], 2], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_PilotAnnouncements", "CHECKBOX", ["Pilot Radio Chatter", "If true, the CSAR pilot will broadcast radio transmissions over the side channel when taking off, crashing, and being rescued."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], true, true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_StartupDelayMin", "SLIDER", ["Pre-Flight Delay Min (Min)", "Minimum time the aircraft sits cold on the tarmac before taxiing."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [0, 30, 1, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_StartupDelayMax", "SLIDER", ["Pre-Flight Delay Max (Min)", "Maximum time the aircraft sits cold on the tarmac before taxiing."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [0, 30, 3, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_CooldownMin", "SLIDER", ["Cooldown Min (Minutes)", "Minimum time before next sortie launches."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [1, 60, 5, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F2_CooldownMax", "SLIDER", ["Cooldown Max (Minutes)", "Maximum time before next sortie launches."],
    ["A3M Settings", "Ambient CSAR (Faction 2)"], [1, 60, 10, 0], true
] call CBA_Settings_fnc_init;

// --- AMBIENT CSAR (FACTION 3) ---
[
    "A3M_CSAR_F3_Enabled", "CHECKBOX", ["Enable Faction 3 CSAR", "Turn on ambient patrols."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], false, true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_Debug", "CHECKBOX", ["Debug Map Tracker", "Places a live map marker on the aircraft to monitor its route."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], false, true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_Side", "LIST", ["Faction Side", "The military branch this aircraft belongs to."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [[0, 1, 2], ["WEST (NATO)", "EAST (CSAT)", "INDEPENDENT"], 2], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_Vehicles", "EDITBOX", ["Vehicle Classes", "Comma-separated list of aircraft classnames. Example: 'B_Plane_CAS_01_dynamicLoadout_F'"],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], "'I_Plane_Fighter_03_dynamicLoadout_F', 'I_Heli_light_03_dynamicLoadout_F'", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_SpawnCoord", "EDITBOX", ["Ground Spawn Coordinate", "Exact spot [X,Y,Z] where the vehicle will spawn parked. Leave blank to spawn directly in the air."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_SpawnMarker", "EDITBOX", ["Ground Spawn Marker", "Name of an invisible map marker showing exactly where the vehicle should spawn parked."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_SpawnDir", "SLIDER", ["Ground Spawn Direction", "If using the Coordinate box above, which compass direction (0-360) should the vehicle face when parked?"],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [0, 360, 0, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_ExtractionMarker", "EDITBOX", ["Extraction Marker (Success)", "The marker name where 2 pilots must be returned to succeed the CSAR. Defaults to origin or Safe TAOR."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_SafeTaor", "EDITBOX", ["Safe Zone TAOR (Extraction Fallback)", "If Extraction Marker is blank, the marker name of the territory where pilots must be extracted to."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], "green_taor", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_QRF_Faction", "EDITBOX", ["Enemy QRF Faction", "The classname of the enemy faction that will attack the downed pilot (e.g., 'OPF_F', 'BLU_F', 'CUP_O_RU')."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], "OPF_F", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_QRF_SpawnChance", "SLIDER", ["QRF Spawn Probability (%)", "Percentage chance that enemy QRF forces will detect the crash and send patrols to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [0, 100, 50, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_QRF_SquadCountMin", "SLIDER", ["QRF Squads (Min)", "Minimum number of enemy infantry squads sent to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [0, 5, 0, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_QRF_SquadCountMax", "SLIDER", ["QRF Squads (Max)", "Maximum number of enemy infantry squads sent to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [0, 5, 2, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_QRF_PursuitDelayMin", "SLIDER", ["QRF Pursuit Delay Min (Minutes)", "Minimum time after the crash before enemy QRF forces are deployed to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [0, 120, 5, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_QRF_PursuitDelayMax", "SLIDER", ["QRF Pursuit Delay Max (Minutes)", "Maximum time after the crash before enemy QRF forces are deployed to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [0, 120, 15, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_FallbackTaor", "EDITBOX", ["Air Spawn Marker", "If spawning in the air, the name of the map marker it will spawn over."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], "green_taor", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_FallbackCoord", "EDITBOX", ["Air Spawn Coord [X,Y]", "If spawning in the air, the exact coordinate it will spawn over."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_FallbackRadius", "SLIDER", ["Air Spawn Radius", "If spawning in the air using Coordinates, it will spawn randomly within this radius."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [100, 10000, 1000, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_TargetTaor", "EDITBOX", ["Patrol Target Marker", "Name of a map marker (like a rectangle) the aircraft will fly to and patrol inside."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], "unoccupied_taor_1", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_TargetCoord", "EDITBOX", ["Patrol Target Coord [X,Y]", "Exact [X,Y] coordinate the aircraft will fly to and patrol."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_TargetRadius", "SLIDER", ["Patrol Target Radius", "If using Target Coordinates, the aircraft will randomly hunt within this radius of the coordinate."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [100, 10000, 2000, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_RewardAmount", "SLIDER", ["Reward Amount (Cr)", "The amount of GRAD Money (Cr) to reward upon success."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [0, 5000000, 250000, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_XPRewardAmount", "SLIDER", ["Reward Amount (XP)", "The amount of HG Experience (XP) to reward upon success."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [0, 10000, 500, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_RewardRadius", "LIST", ["Reward Distribution", "Who receives the payout when the pilot is rescued?"],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [[0, 1, 2], ["Server Wide (All Players)", "Side Only (Allies)", "Proximity (Within 300m of Extraction)"], 2], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_PilotAnnouncements", "CHECKBOX", ["Pilot Radio Chatter", "If true, the CSAR pilot will broadcast radio transmissions over the side channel when taking off, crashing, and being rescued."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], true, true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_StartupDelayMin", "SLIDER", ["Pre-Flight Delay Min (Min)", "Minimum time the aircraft sits cold on the tarmac before taxiing."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [0, 30, 1, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_StartupDelayMax", "SLIDER", ["Pre-Flight Delay Max (Min)", "Maximum time the aircraft sits cold on the tarmac before taxiing."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [0, 30, 3, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_CooldownMin", "SLIDER", ["Cooldown Min (Minutes)", "Minimum time before next sortie launches."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [1, 60, 5, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F3_CooldownMax", "SLIDER", ["Cooldown Max (Minutes)", "Maximum time before next sortie launches."],
    ["A3M Settings", "Ambient CSAR (Faction 3)"], [1, 60, 10, 0], true
] call CBA_Settings_fnc_init;

// --- AMBIENT CSAR (FACTION 4) ---
[
    "A3M_CSAR_F4_Enabled", "CHECKBOX", ["Enable Faction 4 CSAR", "Turn on ambient patrols."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], false, true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_Debug", "CHECKBOX", ["Debug Map Tracker", "Places a live map marker on the aircraft to monitor its route."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], false, true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_Side", "LIST", ["Faction Side", "The military branch this aircraft belongs to."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [[0, 1, 2], ["WEST (NATO)", "EAST (CSAT)", "INDEPENDENT"], 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_Vehicles", "EDITBOX", ["Vehicle Classes", "Comma-separated list of aircraft classnames. Example: 'B_Plane_CAS_01_dynamicLoadout_F'"],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_SpawnCoord", "EDITBOX", ["Ground Spawn Coordinate", "Exact spot [X,Y,Z] where the vehicle will spawn parked. Leave blank to spawn directly in the air."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_SpawnMarker", "EDITBOX", ["Ground Spawn Marker", "Name of an invisible map marker showing exactly where the vehicle should spawn parked."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_SpawnDir", "SLIDER", ["Ground Spawn Direction", "If using the Coordinate box above, which compass direction (0-360) should the vehicle face when parked?"],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [0, 360, 0, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_ExtractionMarker", "EDITBOX", ["Extraction Marker (Success)", "The marker name where 0 pilots must be returned to succeed the CSAR. Defaults to origin or Safe TAOR."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_SafeTaor", "EDITBOX", ["Safe Zone TAOR (Extraction Fallback)", "If Extraction Marker is blank, the marker name of the territory where pilots must be extracted to."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], "custom_taor", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_QRF_Faction", "EDITBOX", ["Enemy QRF Faction", "The classname of the enemy faction that will attack the downed pilot (e.g., 'OPF_F', 'BLU_F', 'CUP_O_RU')."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], "OPF_F", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_QRF_SpawnChance", "SLIDER", ["QRF Spawn Probability (%)", "Percentage chance that enemy QRF forces will detect the crash and send patrols to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [0, 100, 50, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_QRF_SquadCountMin", "SLIDER", ["QRF Squads (Min)", "Minimum number of enemy infantry squads sent to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [0, 5, 0, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_QRF_SquadCountMax", "SLIDER", ["QRF Squads (Max)", "Maximum number of enemy infantry squads sent to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [0, 5, 2, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_QRF_PursuitDelayMin", "SLIDER", ["QRF Pursuit Delay Min (Minutes)", "Minimum time after the crash before enemy QRF forces are deployed to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [0, 120, 5, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_QRF_PursuitDelayMax", "SLIDER", ["QRF Pursuit Delay Max (Minutes)", "Maximum time after the crash before enemy QRF forces are deployed to hunt the pilot."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [0, 120, 15, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_FallbackTaor", "EDITBOX", ["Air Spawn Marker", "If spawning in the air, the name of the map marker it will spawn over."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], "custom_taor", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_FallbackCoord", "EDITBOX", ["Air Spawn Coord [X,Y]", "If spawning in the air, the exact coordinate it will spawn over."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_FallbackRadius", "SLIDER", ["Air Spawn Radius", "If spawning in the air using Coordinates, it will spawn randomly within this radius."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [100, 10000, 1000, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_TargetTaor", "EDITBOX", ["Patrol Target Marker", "Name of a map marker (like a rectangle) the aircraft will fly to and patrol inside."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], "unoccupied_taor_1", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_TargetCoord", "EDITBOX", ["Patrol Target Coord [X,Y]", "Exact [X,Y] coordinate the aircraft will fly to and patrol."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], "", true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_TargetRadius", "SLIDER", ["Patrol Target Radius", "If using Target Coordinates, the aircraft will randomly hunt within this radius of the coordinate."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [100, 10000, 2000, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_RewardAmount", "SLIDER", ["Reward Amount (Cr)", "The amount of GRAD Money (Cr) to reward upon success."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [0, 5000000, 250000, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_XPRewardAmount", "SLIDER", ["Reward Amount (XP)", "The amount of HG Experience (XP) to reward upon success."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [0, 10000, 500, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_RewardRadius", "LIST", ["Reward Distribution", "Who receives the payout when the pilot is rescued?"],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [[0, 1, 2], ["Server Wide (All Players)", "Side Only (Allies)", "Proximity (Within 300m of Extraction)"], 2], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_PilotAnnouncements", "CHECKBOX", ["Pilot Radio Chatter", "If true, the CSAR pilot will broadcast radio transmissions over the side channel when taking off, crashing, and being rescued."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], true, true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_StartupDelayMin", "SLIDER", ["Pre-Flight Delay Min (Min)", "Minimum time the aircraft sits cold on the tarmac before taxiing."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [0, 30, 1, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_StartupDelayMax", "SLIDER", ["Pre-Flight Delay Max (Min)", "Maximum time the aircraft sits cold on the tarmac before taxiing."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [0, 30, 3, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_CooldownMin", "SLIDER", ["Cooldown Min (Minutes)", "Minimum time before next sortie launches."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [1, 60, 5, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_F4_CooldownMax", "SLIDER", ["Cooldown Max (Minutes)", "Maximum time before next sortie launches."],
    ["A3M Settings", "Ambient CSAR (Faction 4)"], [1, 60, 10, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_ExpiryMin", "SLIDER", ["Mission Expiry Min (Hours)", "Minimum time before an uncompleted mission automatically fails to clean up the map."],
    ["A3M Settings", "Ambient CSAR (Global)"], [1, 10, 2, 0], true
] call CBA_Settings_fnc_init;

[
    "A3M_CSAR_ExpiryMax", "SLIDER", ["Mission Expiry Max (Hours)", "Maximum time before an uncompleted mission automatically fails to clean up the map."],
    ["A3M Settings", "Ambient CSAR (Global)"], [1, 10, 4, 0], true
] call CBA_Settings_fnc_init;

// --- ADMIN / DEV TOOLS ---
[
    "A3M_Dev_MoneySpigot", "CHECKBOX", ["Dev Money Spigot ($10M)", "If enabled, gives every connecting player $10,000,000 instantly. USE FOR TEST CENTER ONLY."],
    ["A3M Settings", "Admin / Dev Tools"], false, true
] call CBA_Settings_fnc_init;
