/*
    fn_openShadowOpsDialog.sqf
    Called when a player opens the Shadow Operations terminal.
*/
disableSerialization;

createDialog "A3M_ShadowOpsDialog";
waitUntil {!isNull (findDisplay 7050)};

private _display = findDisplay 7050;
if (isNull _display) exitWith { systemChat "Error: Could not open Shadow Ops Terminal"; };

// ---------------------------
// Procedural Mission Generator
// ---------------------------
private _sessionMissions = player getVariable ["A3M_ShadowOps_SessionMissions", []];

if (count _sessionMissions == 0) then {
    private _opPrefixes = ["Operation", "Project", "Directive", "Code"];
    private _opColors = ["Silent", "Broken", "Ghost", "Black", "Crimson", "Iron", "Fallen", "Shattered", "Burning", "Frozen", "Golden", "Dark", "Hollow", "Viper", "Phantom", "Rogue"];
    private _opNouns = ["Dagger", "Anvil", "Viper", "Angel", "Sand", "Tempest", "Sun", "Moon", "Star", "Sword", "Shield", "Spear", "Crown", "Throne", "Mirror", "Shadow"];
    
    // Format: ["Type", BaseDiff, BaseReward, ["Targets"], ["Locations"], "RequiredClass"]
    private _missionTypes = [
        ["Assassination", 60, 1.0, ["General R. Makos", "CSAT Commander", "Rogue Warlord", "Cartel Boss", "Corrupt Official"], ["Heavily Guarded Checkpoint", "Mountain Villa", "Underground Bunker", "Urban Safehouse"], "Sniper"],
        ["Sabotage", 70, 1.2, ["CSAT Supply Convoy", "Munitions Depot", "Radar Installation", "Fuel Refinery", "Rail Depot"], ["Salt Flats", "Coastal Highway", "Industrial Zone", "Deep Forest"], "Engineer"],
        ["Asset Recovery", 50, 0.8, ["Downed F-18 Pilot", "Stolen Prototype Drone", "Captured Journalist", "Compromised Spy", "Seized Weapon Cache"], ["Hostile Village", "Enemy FOB", "Cave Network", "Abandoned Factory"], "Medic"],
        ["HVT Capture", 85, 1.8, ["AAF Defector", "Syndikat Lieutenant", "CSAT Cryptographer", "Black Market Arms Dealer"], ["Unknown Safehouse", "Moving Convoy", "Neutral Territory", "Heavily Fortified Estate"], "Any"],
        ["Infrastructure", 65, 1.1, ["Central Power Grid", "Water Treatment Plant", "Main Bridge", "Airfield Runway"], ["Agia Marina", "Kavala Outskirts", "Zaros", "Pyrgos Gulf"], "Engineer"],
        ["Extreme Assault", 110, 2.5, ["Coastal Fortress", "Main CSAT Headquarters", "Occupied Capital Building", "Nuclear Submarine Pen"], ["Pyrgos Gulf", "Sofia", "Altis Airport", "Ghost Hotel"], "AT Specialist"],
        ["Extreme Recovery", 120, 3.0, ["VIP NATO Ambassador", "Nuclear Launch Codes", "President's Family", "Biological Weapon Sample"], ["Active Warzone", "Enemy Capital", "Sinking Ship", "CSAT Black Site"], "Medic"],
        ["Reconnaissance", 55, 1.3, ["HQ Comm Relay", "Border Defenses", "Naval Fleet Movement", "Secret Missile Silo"], ["Mountaintop Base", "Border Wall", "Open Ocean", "Desert Depths"], "Sniper"],
        ["Raid", 40, 0.5, ["Small Arms Cache", "Medical Supply Convoy", "Smuggler's Hideout", "Outpost Armory"], ["Desert Ruins", "Jungle Camp", "Coastal Caves", "Abandoned Town"], "Any"],
        ["Defensive", 45, 0.6, ["FOB Guardian", "Civilian Hospital", "Refugee Camp", "UN Aid Convoy"], ["Altis Border", "Kavala Center", "Charkia", "Neochori"], "AT Specialist"]
    ];

    private _weatherTypes = ["Clear", "Overcast", "Rain", "Severe Storm", "Dense Fog"];
    private _timeTypes = ["0200 Hrs (Night)", "0500 Hrs (Dawn)", "1200 Hrs (Noon)", "1800 Hrs (Dusk)", "2300 Hrs (Night)"];

    for "_i" from 1 to 30 do {
        private _typeData = selectRandom _missionTypes;
        _typeData params ["_mType", "_baseDiff", "_mReward", "_targets", "_locations", "_reqClass"];
        
        private _opName = format ["%1 %2 %3", selectRandom _opPrefixes, selectRandom _opColors, selectRandom _opNouns];
        private _target = selectRandom _targets;
        private _location = selectRandom _locations;
        private _weather = selectRandom _weatherTypes;
        private _time = selectRandom _timeTypes;
        
        // Add some random variance to difficulty (+- 10) and reward (+- 0.5)
        private _diffVar = _baseDiff + ((floor random 21) - 10);
        private _rewardVar = _mReward + ((random 1.0) - 0.5);
        _rewardVar = _rewardVar max 0.3; // Minimum floor
        
        private _desc = format [
            "CLASSIFIED BRIEFING:<br/><br/>TARGET: %1<br/>LOCATION: %2<br/>PLANNED EXECUTION: %3<br/>FORECAST: %4<br/>REQUIRED SPECIALIST: %5<br/><br/>SITREP: The commander has authorized this contract. Proceed with caution. Failure could compromise global stability.",
            _target, _location, _time, _weather, _reqClass
        ];
        
        _sessionMissions pushBack [_opName, _mType, _desc, _diffVar, _rewardVar, _time, _weather, _reqClass];
    };
    
    player setVariable ["A3M_ShadowOps_SessionMissions", _sessionMissions];
};

private _missionListCtrl = _display displayCtrl 7052;
lbClear _missionListCtrl;

_display setVariable ["A3M_ShadowOps_Missions", _sessionMissions];

{
    private _missionName = _x select 0;
    private _index = _missionListCtrl lbAdd _missionName;
    _missionListCtrl lbSetData [_index, str _forEachIndex];
} forEach _sessionMissions;

// ---------------------------
// Define Upgrades Data (Type, Name, Cost, Intel, P1, P2, P3)
// ---------------------------
private _allAssets = [
    ["INTEL", "Paid Local Informants", 15000, 25, 5, 0, 0],
    ["INTEL", "SIGINT & Drone Sat-Sweep", 45000, 50, 15, 0, 0],
    ["INTEL", "Embedded CIA Asset", 85000, 85, 30, 0, 0],
    
    ["INFIL", "Basic Ground Infil", 0, 0, 0, 0, 0],
    ["INFIL", "HALO Drop", 25000, 0, 20, 0, -10],
    ["INFIL", "Submarine Coastal Insert", 40000, 0, 30, 0, -5],
    ["INFIL", "Escorted Gunship Drop", 75000, 0, 45, 0, 0],
    
    ["SUPPORT", "Mortar Fire Mission", 30000, 0, -5, 20, 0],
    ["SUPPORT", "Loitering CAS (Wipeout)", 65000, 0, -15, 45, -20],
    ["SUPPORT", "Cruise Missile Strike", 120000, 0, -25, 75, -25],
    
    ["EXFIL", "Basic Ground Exfil", 0, 0, 0, 0, 0],
    ["EXFIL", "Fast Rope Helo Extract", 35000, 0, 0, 0, 25],
    ["EXFIL", "Armored Convoy Extract", 55000, 0, 0, 0, 35],
    ["EXFIL", "Carrier Strike Group Evac", 150000, 0, 0, 0, 70]
];

_display setVariable ["A3M_ShadowOps_Catalog", _allAssets];

// Populate Asset Catalog Listbox
private _catalogCtrl = _display displayCtrl 7059;
lbClear _catalogCtrl;

{
    _x params ["_cat", "_name", "_cost"];
    private _text = format ["[%1] %2 ($%3)", _cat, _name, _cost];
    private _idx = _catalogCtrl lbAdd _text;
    _catalogCtrl lbSetData [_idx, str _forEachIndex];
    
    // Set color based on category
    if (_cat == "INTEL") then { _catalogCtrl lbSetColor [_idx, [0.2, 0.6, 1.0, 1]]; };
    if (_cat == "INFIL") then { _catalogCtrl lbSetColor [_idx, [1.0, 0.6, 0.2, 1]]; };
    if (_cat == "SUPPORT") then { _catalogCtrl lbSetColor [_idx, [1.0, 0.2, 0.2, 1]]; };
    if (_cat == "EXFIL") then { _catalogCtrl lbSetColor [_idx, [0.2, 1.0, 0.2, 1]]; };
} forEach _allAssets;

// Request Stowed AI from server
[player] remoteExecCall ["A3M_fnc_serverFetchShadowOpsRoster", 2];
