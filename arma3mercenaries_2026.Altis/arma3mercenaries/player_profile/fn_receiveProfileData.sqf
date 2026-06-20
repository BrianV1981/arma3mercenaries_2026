/*
    fn_receiveProfileData.sqf
    Receives the flattened profile data from the server and populates the 3-column UI.
*/

params ["_flatData"];
if (!hasInterface) exitWith {};

// Reconstruct HashMap on client
private _keys = _flatData select 0;
private _values = _flatData select 1;
private _garageData = _flatData select 2;
private _activeForts = _flatData select 3;

private _profile = createHashMap;
{
    _profile set [_x, _values select _forEachIndex];
} forEach _keys;

private _display = findDisplay 7020;
if (isNull _display) exitWith {};

private _listCtrl1 = _display displayCtrl 7022; // Core Stats
private _listCtrl2 = _display displayCtrl 7023; // Kills Leaderboard
private _listCtrl3 = _display displayCtrl 7024; // Logistics/Deaths
private _listCtrl4 = _display displayCtrl 7025; // Assets

lbClear _listCtrl1;
lbClear _listCtrl2;
lbClear _listCtrl3;
lbClear _listCtrl4;

// --- COLUMN 1: SERVICE RECORD ---
private _kills = _profile getOrDefault ["Kills_Total", 0];
private _deaths = _profile getOrDefault ["Deaths_Total", 0];
private _kd = if (_deaths > 0) then { _kills / _deaths } else { _kills };
private _joinDate = _profile getOrDefault ["First_Joined_Date", "Unknown"];
private _lastDate = _profile getOrDefault ["Last_Deployment_Date", "Unknown"];
private _playtime = _profile getOrDefault ["PlayTime_Minutes", 0];
private _distWalk = _profile getOrDefault ["Distance_Walked", 0];
private _distDrive = _profile getOrDefault ["Distance_Driven", 0];
private _distFly = _profile getOrDefault ["Distance_Flown", 0];

private _rankName = _profile getOrDefault ["_TargetRankName", "UNKNOWN"];
private _xp = _profile getOrDefault ["_TargetXP", 0];

private _totalXP = 0;
private _maxXP = 1000;
switch (_rankName) do {
    case "PRIVATE": { _totalXP = _xp; _maxXP = 1000; };
    case "CORPORAL": { _totalXP = 1000 + _xp; _maxXP = 1500; };
    case "SERGEANT": { _totalXP = 2500 + _xp; _maxXP = 2000; };
    case "LIEUTENANT": { _totalXP = 4500 + _xp; _maxXP = 2500; };
    case "CAPTAIN": { _totalXP = 7000 + _xp; _maxXP = 3000; };
    case "MAJOR": { _totalXP = 10000 + _xp; _maxXP = 3500; };
    case "COLONEL": { _totalXP = 13500 + _xp; _maxXP = 0; };
    default { _totalXP = _xp; _maxXP = 0; };
};

private _wallet = _profile getOrDefault ["_TargetWallet", 0];
private _bank = _profile getOrDefault ["_TargetBank", 0];

_listCtrl1 lbAdd format ["RANK: %1", _rankName];
if (_maxXP > 0) then {
    _listCtrl1 lbAdd format ["EXPERIENCE: %1 / %2 XP", _xp, _maxXP];
} else {
    _listCtrl1 lbAdd format ["EXPERIENCE: %1 XP (MAX RANK)", _xp];
};
_listCtrl1 lbAdd format ["TOTAL CAREER XP: %1", _totalXP];
_listCtrl1 lbAdd "";
_listCtrl1 lbAdd format ["K/D RATIO: %1", _kd];
_listCtrl1 lbAdd format ["Total Kills: %1", _kills];
_listCtrl1 lbAdd format ["Total Deaths: %1", _deaths];
_listCtrl1 lbAdd format ["Team Kills: %1", _profile getOrDefault ["TeamKills", 0]];
_listCtrl1 lbAdd format ["Civilian Casualties: %1", _profile getOrDefault ["CivilianKills", 0]];
_listCtrl1 lbAdd format ["Suicides: %1", _profile getOrDefault ["Suicides", 0]];

// Calculate Signature Weapon
private _weaponStats = _profile getOrDefault ["Weapon_Kills", []];
private _favWeapon = "None";
private _maxWepKills = 0;
if (typeName _weaponStats == "ARRAY") then {
    {
        _x params ["_weap", "_kills"];
        if (_kills > _maxWepKills) then {
            _favWeapon = _weap;
            _maxWepKills = _kills;
        };
    } forEach _weaponStats;
} else {
    if (typeName _weaponStats == "HASHMAP") then {
        {
            if (_y > _maxWepKills) then {
                _favWeapon = _x;
                _maxWepKills = _y;
            };
        } forEach _weaponStats;
    };
};

_listCtrl1 lbAdd "";
_listCtrl1 lbAdd format ["Signature Weapon: %1 (%2 kills)", _favWeapon, _maxWepKills];
_listCtrl1 lbAdd format ["HVT Assassinations: %1", _profile getOrDefault ["HVT_Takedowns", 0]];
_listCtrl1 lbAdd format ["Medical Revives: %1", _profile getOrDefault ["Medical_Revives_Performed", 0]];
_listCtrl1 lbAdd format ["Mercenaries Contracted: %1", _profile getOrDefault ["Mercenaries_Contracted", 0]];
_listCtrl1 lbAdd "";
_listCtrl1 lbAdd format ["Wallet Balance: %1 cr.", _wallet];
_listCtrl1 lbAdd format ["Bank Balance: %1 cr.", _bank];
_listCtrl1 lbAdd format ["Total Lifetime Spent: %1 cr.", _profile getOrDefault ["Total_Capital_Spent", 0]];

private _playerBounty = _profile getOrDefault ["Bounty", 0];
if (_playerBounty > 0) then {
    _listCtrl1 lbAdd "";
    _listCtrl1 lbAdd format ["*** BOUNTY ON HEAD: %1 cr. ***", _playerBounty];
};
_listCtrl1 lbAdd "";
_listCtrl1 lbAdd format ["Missions Completed: %1", _profile getOrDefault ["Missions_Completed", 0]];
_listCtrl1 lbAdd format ["Vehicles Destroyed: %1", _profile getOrDefault ["Vehicles_Destroyed", 0]];
_listCtrl1 lbAdd format ["Supply Drops Called: %1", _profile getOrDefault ["Supply_Drops_Called", 0]];
_listCtrl1 lbAdd format ["Engineer Score (Forts Built): %1", _profile getOrDefault ["Engineer_Score_Total", 0]];

_listCtrl1 lbAdd "";
_listCtrl1 lbAdd "--- DRONE OPERATOR ---";
_listCtrl1 lbAdd format ["Ordnance Dropped: %1", _profile getOrDefault ["Drone_Strikes_Dropped", 0]];
_listCtrl1 lbAdd format ["Kamikaze Kills: %1", _profile getOrDefault ["Drone_Kamikaze_Kills", 0]];

_listCtrl1 lbAdd "";
_listCtrl1 lbAdd format ["Distance Walked: %1m", round _distWalk];
_listCtrl1 lbAdd format ["Distance Driven: %1m", round _distDrive];
_listCtrl1 lbAdd format ["Distance Flown: %1m", round _distFly];
_listCtrl1 lbAdd format ["Time in Combat: %1 min", round _playtime];
_listCtrl1 lbAdd "";
_listCtrl1 lbAdd format ["First Deployment: %1", _joinDate];
_listCtrl1 lbAdd format ["Last Deployment:  %1", _lastDate];

// --- COLUMN 2: COMBAT HISTORY ---
_listCtrl2 lbAdd "--- TOP 10 LONGEST KILLS ---";
private _topKills = _profile getOrDefault ["Top_10_Longest_Kills", []];
if (count _topKills == 0) then { _listCtrl2 lbAdd "No kills recorded yet."; } else {
    { _x params ["_dist", "_weap", "_vic"]; _listCtrl2 lbAdd format ["%1m - %2 (with %3)", round _dist, _vic, _weap]; } forEach _topKills;
};

_listCtrl2 lbAdd "";
_listCtrl2 lbAdd "--- RECENT KILLS ---";
private _lastKills = _profile getOrDefault ["Last_10_Kills", []];
if (count _lastKills == 0) then { _listCtrl2 lbAdd "No kills recorded yet."; } else {
    { _x params ["_time", "_vic", "_weap", "_dist"]; _listCtrl2 lbAdd format ["Killed %1 [%2m]", _vic, round _dist]; } forEach _lastKills;
};

// --- COLUMN 4: ASSETS & PROPERTY ---
_listCtrl4 lbAdd "--- HG GARAGE ---";
if (count _garageData == 0) then { _listCtrl4 lbAdd "No vehicles garaged."; } else {
    { 
        _x params ["_class", "_plate", "_color", "_active"];
        private _status = if (_active == 1) then {"[DEPLOYED]"} else {"[GARAGED]"};
        private _name = _class;
        try { _name = getText(configFile >> "CfgVehicles" >> _class >> "displayName"); } catch {};
        _listCtrl4 lbAdd format ["%1 %2 (Plate: %3)", _status, _name, _plate];
    } forEach _garageData;
};

// --- COLUMN 3: LOGISTICS & CASUALTIES ---
_listCtrl3 lbAdd "--- RECENT DEATHS ---";
private _lastDeaths = _profile getOrDefault ["Last_10_Deaths", []];
if (count _lastDeaths == 0) then { _listCtrl3 lbAdd "No deaths recorded yet."; } else {
    { _x params ["_time", "_killer", "_weap", "_pos"]; _listCtrl3 lbAdd format ["Killed by %1 [%2]", _killer, _weap]; } forEach _lastDeaths;
};

_listCtrl3 lbAdd "";
_listCtrl3 lbAdd "--- BLACK MARKET LEDGER ---";
private _lastPurchases = _profile getOrDefault ["Last_10_Purchases", []];
if (count _lastPurchases == 0) then { _listCtrl3 lbAdd "No purchases recorded yet."; } else {
    { _x params ["_time", "_item", "_price"]; _listCtrl3 lbAdd format ["Bought %1 (-%2 cr)", _item, _price]; } forEach _lastPurchases;
};

_listCtrl3 lbAdd "";
_listCtrl3 lbAdd "--- MEDICAL HERO LEDGER ---";
private _lastSaved = _profile getOrDefault ["Last_100_Saved", []];
if (count _lastSaved == 0) then { _listCtrl3 lbAdd "No major interventions recorded."; } else {
    { _x params ["_time", "_patient", "_treatment"]; _listCtrl3 lbAdd format ["Saved %1 [%2]", _patient, _treatment]; } forEach _lastSaved;
};