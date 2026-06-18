/*
    fn_onShadowOpsPlanChanged.sqf
    Calculates projected impact of the current squad + assets vs the selected mission.
*/
disableSerialization;
private _display = findDisplay 7050;
if (isNull _display) exitWith {};

private _missionListCtrl = _display displayCtrl 7052;
private _assignedListCtrl = _display displayCtrl 7067;
private _detailsCtrl = _display displayCtrl 7063;
private _purchasedList = _display displayCtrl 7062;

private _selIndex = lbCurSel _missionListCtrl;
if (_selIndex == -1) exitWith { _detailsCtrl ctrlSetStructuredText parseText "<t align='center'>Select an operation to calculate impact.</t>"; };

private _missionIdxStr = _missionListCtrl lbData _selIndex;
private _missionIndex = parseNumber _missionIdxStr;
private _missions = _display getVariable ["A3M_ShadowOps_Missions", []];
private _selectedMission = _missions select _missionIndex;

_selectedMission params ["_opName", "_mType", "_desc", "_baseDiff", "_mReward", "_forecastTime", "_forecastWeather", "_reqClass"];

private _allAssets = _display getVariable ["A3M_ShadowOps_Catalog", []];
private _assetCost = 0;
private _p1Impact = 0;
private _p2Impact = 0;
private _p3Impact = 0;
private _hasInfil = false;
private _hasExfil = false;

for "_i" from 0 to ((lbSize _purchasedList) - 1) do {
    private _dataStr = _purchasedList lbData _i;
    private _asset = _allAssets select (parseNumber _dataStr);
    _assetCost = _assetCost + (_asset select 2);
    
    private _cat = _asset select 0;
    private _name = _asset select 1;
    private _p1 = _asset select 4;
    private _p2 = _asset select 5;
    private _p3 = _asset select 6;
    
    if (_cat == "INFIL") then { _hasInfil = true; };
    if (_cat == "EXFIL") then { _hasExfil = true; };
    
    // UI Warnings for known synergies
    if (_name == "Loitering CAS (Wipeout)" && (_forecastWeather == "Severe Storm" || _forecastWeather == "Dense Fog")) then {
        _p2 = -30; // Brutal penalty
    };
    if (_name == "Escorted Gunship Drop" && (_forecastWeather == "Severe Storm")) then {
        _p1 = -20;
    };
    if (_name == "HALO Drop" && _forecastTime == "1200 Hrs (Noon)") then {
        _p1 = -30;
    };
    if (_name == "HALO Drop" && _forecastTime == "0200 Hrs (Night)") then {
        _p1 = 35;
    };
    
    _p1Impact = _p1Impact + _p1;
    _p2Impact = _p2Impact + _p2;
    _p3Impact = _p3Impact + _p3;
};

// Check Mercs
private _hasMedic = false;
private _hasSpecialist = false;
private _squadCount = lbSize _assignedListCtrl;

for "_i" from 0 to (_squadCount - 1) do {
    private _mercID = _assignedListCtrl lbData _i;
    private _profile = [format["A3M_MERC_%1", _mercID], createHashMap, true] call A3M_fnc_dbGetSecure;
    private _mercClass = _profile getOrDefault ["Class", ""];
    
    // Convert Arma classnames to our logical categories
    if (["medic", _mercClass] call BIS_fnc_inString) then { _hasMedic = true; };
    
    if (_reqClass == "Medic" && ["medic", _mercClass] call BIS_fnc_inString) then { _hasSpecialist = true; };
    if (_reqClass == "Engineer" && (["engineer", _mercClass] call BIS_fnc_inString || ["exp", _mercClass] call BIS_fnc_inString)) then { _hasSpecialist = true; };
    if (_reqClass == "Sniper" && (["sniper", _mercClass] call BIS_fnc_inString || ["marksman", _mercClass] call BIS_fnc_inString)) then { _hasSpecialist = true; };
    if (_reqClass == "AT Specialist" && (["at", _mercClass] call BIS_fnc_inString || ["aa", _mercClass] call BIS_fnc_inString)) then { _hasSpecialist = true; };
};

// Apply Specialist Bonus/Penalty
if (_hasSpecialist) then {
    _p2Impact = _p2Impact + 15;
} else {
    if (_reqClass != "Any" && _squadCount > 0) then { _p2Impact = _p2Impact - 30; };
};

// Squad Size Scaling
_p1Impact = _p1Impact - (_squadCount * 2);
_p2Impact = _p2Impact + (_squadCount * 5);
_p3Impact = _p3Impact - (_squadCount * 2);

private _hazardPayCost = _squadCount * 20000;
private _totalCost = _assetCost + _hazardPayCost;

private _p1Color = if (_p1Impact >= 0) then { "#00FF00" } else { "#FF0000" };
private _p2Color = if (_p2Impact >= 0) then { "#00FF00" } else { "#FF0000" };
private _p3Color = if (_p3Impact >= 0) then { "#00FF00" } else { "#FF0000" };

private _infilWarning = if (!_hasInfil) then { "<t color='#FF0000'>WARNING: MISSING INFIL METHOD</t><br/>" } else { "" };
private _exfilWarning = if (!_hasExfil) then { "<t color='#FF0000'>WARNING: MISSING EXFIL METHOD</t><br/>" } else { "" };

private _text = format [
    "%5%6" +
    "PROJECTED IMPACT:<br/>" +
    "Insertion: <t color='%1'>%+2</t><br/>" +
    "Execution: <t color='%3'>%+4</t><br/>" +
    "Extraction: <t color='%7'>%+8</t><br/><br/>" +
    "COSTS:<br/>" +
    "Assets: $%9<br/>" +
    "Hazard Pay ($20k/merc): $%10<br/>" +
    "TOTAL COST: $%11",
    _p1Color, _p1Impact, _p2Color, _p2Impact, _infilWarning, _exfilWarning, _p3Color, _p3Impact, _assetCost, _hazardPayCost, _totalCost
];

_detailsCtrl ctrlSetStructuredText parseText _text;
