/*
    fn_serverShadowOpsThread.sqf
    The massive asynchronous processing thread for Shadow Operations logic on the Server.
*/
params ["_mercIDs", "_missionData", "_assets", "_client"];

if (!isServer) exitWith {};

_missionData params ["_opName", "_mType", "_desc", "_baseDiff", "_rewardMultiplier", "_forecastTime", "_forecastWeather", "_reqClass"];

// 1. Mark Mercs as Deployed so they cannot be accessed
{
    private _profile = [format["A3M_MERC_%1", _x], createHashMap, true] call A3M_fnc_dbGetSecure;
    if (count _profile > 0) then {
        _profile set ["ShadowOps_Status", "ShadowOps"];
        [format["A3M_MERC_%1", _x], _profile] call A3M_fnc_dbSetSecure;
    };
} forEach _mercIDs;

private _fnc_notifyPlayer = {
    params ["_header", "_msg", "_color"];
    private _structured = format ["<t color='%3' size='1.2' align='center'>%1</t><br/><br/><t align='center'>%2</t>", _header, _msg, _color];
    [_structured] remoteExecCall ["hint", _client];
};

["SHADOW OPS DISPATCH", format ["%1 is a go. The squad has gone dark.", _opName], "#FFAA00"] call _fnc_notifyPlayer;

// Determine TRUE WEATHER (30% chance forecast is wrong)
private _actualWeather = _forecastWeather;
if (random 100 < 30) then {
    private _weatherTypes = ["Clear", "Overcast", "Rain", "Severe Storm", "Dense Fog"];
    _actualWeather = selectRandom _weatherTypes;
    
    // Simulate async travel time before briefing update
    sleep 5;
    ["METEOROLOGY UPDATE", format ["Commander, the forecast was wrong. Actual weather on target is: %1", _actualWeather], "#FF0000"] call _fnc_notifyPlayer;
};

// Calculate Class Synergies
private _hasMedic = false;
private _hasSpecialist = false;
{
    private _profile = [format["A3M_MERC_%1", _x], createHashMap, true] call A3M_fnc_dbGetSecure;
    private _mercClass = _profile getOrDefault ["Class", ""];
    
    if (["medic", _mercClass] call BIS_fnc_inString) then { _hasMedic = true; };
    
    if (_reqClass == "Medic" && ["medic", _mercClass] call BIS_fnc_inString) then { _hasSpecialist = true; };
    if (_reqClass == "Engineer" && (["engineer", _mercClass] call BIS_fnc_inString || ["exp", _mercClass] call BIS_fnc_inString)) then { _hasSpecialist = true; };
    if (_reqClass == "Sniper" && (["sniper", _mercClass] call BIS_fnc_inString || ["marksman", _mercClass] call BIS_fnc_inString)) then { _hasSpecialist = true; };
    if (_reqClass == "AT Specialist" && (["at", _mercClass] call BIS_fnc_inString || ["aa", _mercClass] call BIS_fnc_inString)) then { _hasSpecialist = true; };
} forEach _mercIDs;

// Calculate Global Odds
private _p1Mods = 0;
private _p2Mods = 0;
private _p3Mods = 0;

{
    _x params ["_cat", "_name", "_cost", "_p1", "_p2", "_p3"];
    
    // Weather Synergy Penalty on Assets
    if (_name == "Loitering CAS (Wipeout)" && (_actualWeather == "Severe Storm" || _actualWeather == "Dense Fog")) then {
        _p2 = -30; // Brutal penalty
    };
    if (_name == "Escorted Gunship Drop" && (_actualWeather == "Severe Storm")) then {
        _p1 = -20;
    };
    // Time Synergy
    if (_name == "HALO Drop" && _forecastTime == "1200 Hrs (Noon)") then {
        _p1 = -30; // Visible drop
    };
    if (_name == "HALO Drop" && _forecastTime == "0200 Hrs (Night)") then {
        _p1 = 35; // Perfect stealth
    };

    _p1Mods = _p1Mods + _p1;
    _p2Mods = _p2Mods + _p2;
    _p3Mods = _p3Mods + _p3;
} forEach _assets;

if (_hasSpecialist) then {
    _p2Mods = _p2Mods + 15;
} else {
    if (_reqClass != "Any") then { _p2Mods = _p2Mods - 30; };
};

// Size scaling (Large squads = noisy infil, stronger execution, harder exfil)
private _squadSize = count _mercIDs;
_p1Mods = _p1Mods - (_squadSize * 2);
_p2Mods = _p2Mods + (_squadSize * 5);
_p3Mods = _p3Mods - (_squadSize * 2);

// Phase 1: Insertion
sleep 8;
private _p1Roll = random 100;
private _p1Total = _p1Roll + _p1Mods;
private _phase1Success = (_p1Total >= _baseDiff);

private _finalOutcome = "";
if (_phase1Success) then {
    _finalOutcome = "Squad successfully inserted without alerting enemy presence.";
    ["PHASE 1: INSERTION", _finalOutcome, "#00FF00"] call _fnc_notifyPlayer;
} else {
    _finalOutcome = "Insertion compromised. Enemy on high alert. Resistance heavily increased.";
    ["PHASE 1: INSERTION", _finalOutcome, "#FF0000"] call _fnc_notifyPlayer;
    _p2Mods = _p2Mods - 15;
    _p3Mods = _p3Mods - 15;
};

// Phase 2: Execution
sleep 8;
private _p2Roll = random 100;
private _p2Total = _p2Roll + _p2Mods;
private _phase2Success = (_p2Total >= _baseDiff);

if (_phase2Success) then {
    _finalOutcome = "Objective secured. Primary targets neutralized.";
    ["PHASE 2: EXECUTION", _finalOutcome, "#00FF00"] call _fnc_notifyPlayer;
} else {
    _finalOutcome = "Operation failed. Squad sustained heavy casualties and could not secure the objective.";
    ["PHASE 2: EXECUTION", _finalOutcome, "#FF0000"] call _fnc_notifyPlayer;
    _p3Mods = _p3Mods - 30;
};

// Phase 3: Extraction
sleep 8;
private _p3Roll = random 100;
private _p3Total = _p3Roll + _p3Mods;
private _phase3Success = (_p3Total >= _baseDiff);

// If they have a medic and the extraction gets messy, medic gives flat survival boost
if (!_phase3Success && _hasMedic) then {
    _p3Total = _p3Total + 20;
    _phase3Success = (_p3Total >= _baseDiff);
};

private _dbStatus = "Stowed";

if (_phase2Success && _phase3Success) then {
    _finalOutcome = "Dust off complete. Returning to base with objective.";
    ["PHASE 3: EXTRACTION", _finalOutcome, "#00FF00"] call _fnc_notifyPlayer;
    
    private _basePayout = 200000 + (random 100000);
    private _totalPayout = _basePayout * _rewardMultiplier;
    
    [format ["Shadow Ops Contract Complete: $%1", round _totalPayout]] remoteExecCall ["systemChat", _client];
    [_client, round _totalPayout] remoteExecCall ["grad_lbm_fnc_addFunds", 2];
    
    // Pay out Hazard Pay to surviving Mercenaries ($20k each)
    {
        private _profile = [format["A3M_MERC_%1", _x], createHashMap, true] call A3M_fnc_dbGetSecure;
        if (count _profile > 0) then {
            private _currentCash = _profile getOrDefault ["CashCarried", 0];
            _profile set ["CashCarried", _currentCash + 20000];
            [format["A3M_MERC_%1", _x], _profile] call A3M_fnc_dbSetSecure;
        };
    } forEach _mercIDs;
    
} else {
    if (!_phase2Success) then {
        _finalOutcome = "Squad wiped out or captured. Mission Failed.";
        ["PHASE 3: EXTRACTION", _finalOutcome, "#FF0000"] call _fnc_notifyPlayer;
        _dbStatus = "WIA"; 
    } else {
        _finalOutcome = "Extraction was messy. Squad sustained injuries but secured the objective.";
        ["PHASE 3: EXTRACTION", _finalOutcome, "#FFaa00"] call _fnc_notifyPlayer;
        _dbStatus = "WIA";
        
        private _basePayout = 75000;
        private _totalPayout = _basePayout * _rewardMultiplier;
        [format ["Shadow Ops Contract (Partial) Complete: $%1", round _totalPayout]] remoteExecCall ["systemChat", _client];
        [_client, round _totalPayout] remoteExecCall ["grad_lbm_fnc_addFunds", 2];
        
        // Hazard Pay
        {
            private _profile = [format["A3M_MERC_%1", _x], createHashMap, true] call A3M_fnc_dbGetSecure;
            if (count _profile > 0) then {
                private _currentCash = _profile getOrDefault ["CashCarried", 0];
                _profile set ["CashCarried", _currentCash + 20000];
                [format["A3M_MERC_%1", _x], _profile] call A3M_fnc_dbSetSecure;
            };
        } forEach _mercIDs;
    };
};

// Free up the Mercs
{
    private _profile = [format["A3M_MERC_%1", _x], createHashMap, true] call A3M_fnc_dbGetSecure;
    if (count _profile > 0) then {
        _profile set ["ShadowOps_Status", _dbStatus];
        [format["A3M_MERC_%1", _x], _profile] call A3M_fnc_dbSetSecure;
    };
} forEach _mercIDs;
