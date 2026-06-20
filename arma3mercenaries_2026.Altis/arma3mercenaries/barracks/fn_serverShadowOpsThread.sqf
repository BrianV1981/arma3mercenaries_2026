/*
    fn_serverShadowOpsThread.sqf
    The Async Story Engine for Shadow Operations.
*/
params ["_missionData", "_selectedMercs", "_planData", "_client"];

// Unpack payload
_missionData params ["_missionName", "_mType", "_missionDesc", "_baseDifficulty", "_rewardMultiplier", "_plannedTime", "_forecastWeather", "_reqClass"];
_planData params ["_intelMod", "_p1ModBase", "_p2ModBase", "_p3ModBase", "_purchasedAssets"];

private _squadCount = count _selectedMercs;
private _squadBonus = _squadCount * 5;

// Helper function for sending stylized UI notifications to the player
private _fnc_notifyPlayer = {
    params ["_title", "_text", "_color"];
    private _html = format [
        "<t align='center' size='1.2' color='%3'>%1</t><br/><br/><t align='center' size='0.9'>%2</t>", 
        _title, _text, _color
    ];
    [parseText _html, "hint"] remoteExecCall ["A3M_fnc_shadowOpsFeedback", _client];
    uiSleep 8;
};

// ==========================================
// PRE-EXECUTION: ACTUAL WEATHER & SYNERGIES
// ==========================================
["OPERATION LAUNCH", format ["%1 squad members have departed base. Commencing blackout...", _squadCount], "#FFFFFF"] call _fnc_notifyPlayer;
uiSleep 5;

// Roll Actual Weather (70% chance to match forecast, 30% chance to be completely random)
private _weatherTypes = ["Clear", "Overcast", "Rain", "Severe Storm", "Dense Fog"];
private _actualWeather = _forecastWeather;
if (random 100 > 70) then {
    _actualWeather = selectRandom _weatherTypes;
};

if (_actualWeather != _forecastWeather) then {
    ["WEATHER UPDATE", format ["Meteorology got it wrong. Actual conditions on target are %1. Adjusting parameters.", _actualWeather], "#FFaa00"] call _fnc_notifyPlayer;
} else {
    ["WEATHER UPDATE", format ["Conditions hold steady at %1 as forecasted.", _actualWeather], "#00FF00"] call _fnc_notifyPlayer;
};

// Calculate Class Synergies
private _hasRequiredClass = false;
private _hasMedic = false;
{
    private _mercID = _x getOrDefault ["MercID", ""];
    private _mercClass = _x getOrDefault ["Class", ""];
    
    private _logicalClass = "Rifleman";
    if (["medic", _mercClass] call BIS_fnc_inString) then { _logicalClass = "Medic"; _hasMedic = true; };
    if (["engineer", _mercClass] call BIS_fnc_inString || ["exp", _mercClass] call BIS_fnc_inString) then { _logicalClass = "Engineer"; };
    if (["sniper", _mercClass] call BIS_fnc_inString || ["marksman", _mercClass] call BIS_fnc_inString) then { _logicalClass = "Sniper"; };
    if (["at", _mercClass] call BIS_fnc_inString) then { _logicalClass = "AT Specialist"; };
    if (["aa", _mercClass] call BIS_fnc_inString) then { _logicalClass = "AA Specialist"; };
    if (["mg", _mercClass] call BIS_fnc_inString || ["autorifle", _mercClass] call BIS_fnc_inString) then { _logicalClass = "Machine Gunner"; };
    
    if (_logicalClass == _reqClass || _reqClass == "Any") then { _hasRequiredClass = true; };
} forEach _selectedMercs;

private _p2Mod = _p2ModBase + _squadBonus;
private _p1Mod = _p1ModBase + _squadBonus;
private _p3Mod = _p3ModBase + _squadBonus;

if (!_hasRequiredClass) then {
    _p2Mod = _p2Mod - 30;
    ["SITREP", "Squad lacks the required specialist for this target type. Execution will be extremely difficult.", "#FF0000"] call _fnc_notifyPlayer;
} else {
    if (_reqClass != "Any") then {
        _p2Mod = _p2Mod + 15;
    };
};

if (_hasMedic) then {
    _p3Mod = _p3Mod + 10;
};

// Calculate Asset Synergies
private _hasHalo = "HALO Drop" in _purchasedAssets;
private _hasHeloExfil = "Fast Rope Helo Extract" in _purchasedAssets;
private _hasCAS = "Loitering CAS (Wipeout)" in _purchasedAssets;

if (_hasHalo && (_plannedTime == "1200 Hrs (Noon)" || _plannedTime == "1800 Hrs (Dusk)")) then {
    _p1Mod = _p1Mod - 35;
    ["SITREP", "Daylight HALO drop highly visible. Enemy air defenses are tracking.", "#FF0000"] call _fnc_notifyPlayer;
};
if (_hasHalo && (_plannedTime == "0200 Hrs (Night)" || _plannedTime == "2300 Hrs (Night)")) then {
    _p1Mod = _p1Mod + 20;
};
if (_hasHeloExfil && (_actualWeather == "Severe Storm")) then {
    _p3Mod = _p3Mod - 40;
    ["SITREP", "Severe storm is throwing the extraction chopper around. Dust-off is highly unstable.", "#FF0000"] call _fnc_notifyPlayer;
};
if (_hasCAS && (_actualWeather == "Severe Storm" || _actualWeather == "Dense Fog")) then {
    _p2Mod = _p2Mod - 20;
    ["SITREP", "Zero visibility. CAS cannot acquire targets and is returning to base. You are on your own.", "#FF0000"] call _fnc_notifyPlayer;
};


// ==========================================
// EXECUTION PHASES
// ==========================================

// --- PHASE 0: HVT Intel Check ---
// For Assassinations or Captures, if you don't buy intel, you might hit a dry hole.
private _abortMission = false;
if (_mType == "Assassination" || _mType == "HVT Capture") then {
    private _intelRoll = (random 100) + _intelMod;
    if (_intelRoll < 80) then {
        ["PHASE 0: TARGET ACQUISITION", "Target was not at the expected location. Dry hole. Aborting operation.", "#FF0000"] call _fnc_notifyPlayer;
        _abortMission = true;
    } else {
        ["PHASE 0: TARGET ACQUISITION", "Target positively identified at location. Proceeding to Phase 1.", "#00FF00"] call _fnc_notifyPlayer;
    };
};

if (_abortMission) exitWith {
    // Return everyone safely
    {
        private _profile = _x;
        private _mercID = _profile getOrDefault ["MercID", ""];
        _profile set ["ShadowOps_Status", "Stowed"];
        [format["A3M_MERC_%1", _mercID], _profile, true] call A3M_fnc_dbSetSecure;
    } forEach _selectedMercs;
    [format ["Shadow Ops Contract Failed: Dry Hole. Initial investments lost."]] remoteExecCall ["systemChat", _client];
    // Refresh UI
    [_client, true] call A3M_fnc_serverFetchSquadDossier;
};

// --- PHASE 1: INSERTION ---
private _p1Roll = (random 100) + _p1Mod;
private _p1Thresh = _baseDifficulty - 20; // Stealthy insertion is usually easier
private _phase1Success = _p1Roll >= _p1Thresh;

if (_phase1Success) then {
    ["PHASE 1: INSERTION", "Insertion successful. Squad has breached the perimeter undetected.", "#00FF00"] call _fnc_notifyPlayer;
} else {
    ["PHASE 1: INSERTION", "Insertion compromised! Squad took contact on approach. Element of surprise lost.", "#FFaa00"] call _fnc_notifyPlayer;
    _baseDifficulty = _baseDifficulty + 10; // Penalty cascades
};

// --- PHASE 2: EXECUTION ---
private _p2Roll = (random 100) + _p2Mod;
private _p2Thresh = _baseDifficulty;
private _phase2Success = _p2Roll >= _p2Thresh;

if (_phase2Success) then {
    ["PHASE 2: EXECUTION", "Objective secured. Primary target eliminated/captured.", "#00FF00"] call _fnc_notifyPlayer;
} else {
    ["PHASE 2: EXECUTION", "Heavy resistance encountered. Squad pinned down and taking casualties.", "#FF0000"] call _fnc_notifyPlayer;
    _baseDifficulty = _baseDifficulty + 15; // Cascading penalty
};

// --- PHASE 3: EXTRACTION ---
private _p3Roll = (random 100) + _p3Mod;
private _p3Thresh = _baseDifficulty;
private _phase3Success = _p3Roll >= _p3Thresh;

// ==========================================
// AFTERMATH
// ==========================================
private _finalOutcome = "";
private _dbStatus = "Stowed";

if (_phase2Success && _phase3Success) then {
    _finalOutcome = "Dust off complete. Returning to base with objective.";
    ["PHASE 3: EXTRACTION", _finalOutcome, "#00FF00"] call _fnc_notifyPlayer;
    
    private _basePayout = 200000 + (random 100000);
    private _totalPayout = _basePayout * _rewardMultiplier;
    
    [format ["Shadow Ops Contract Complete: $%1", round _totalPayout]] remoteExecCall ["systemChat", _client];
    [_client, round _totalPayout] remoteExecCall ["grad_lbm_fnc_addFunds", 2];
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
    };
};

// Update Mercenaries in Database
{
    private _profile = _x;
    private _mercID = _profile getOrDefault ["MercID", ""];
    _profile set ["ShadowOps_Status", _dbStatus];
    
    // Add kills if successful
    if (_phase2Success) then {
        private _currentKills = _profile getOrDefault ["Kills", 0];
        _profile set ["Kills", _currentKills + (floor random 5) + 1];
        
        // Hazard Pay Delivery (If they didn't wipe in Phase 2)
        private _currentCash = _profile getOrDefault ["CashCarried", 0];
        _profile set ["CashCarried", _currentCash + 20000];
    };
    
    [format["A3M_MERC_%1", _mercID], _profile, true] call A3M_fnc_dbSetSecure;
} forEach _selectedMercs;

// Refresh UI Dossier
[_client, true] call A3M_fnc_serverFetchSquadDossier;
