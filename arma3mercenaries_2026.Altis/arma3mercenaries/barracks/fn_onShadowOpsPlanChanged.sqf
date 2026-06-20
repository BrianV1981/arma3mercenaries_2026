/*
    fn_onShadowOpsPlanChanged.sqf
    Updates the Operational Planning summary box. Calculates synergies from cart + squad + mission forecast.
*/
disableSerialization;

private _display = findDisplay 7050;
if (isNull _display) exitWith {};

// 1. Get Selected Mission
private _missionListCtrl = _display displayCtrl 7052;
private _selectedMissionIndex = lbCurSel _missionListCtrl;

if (_selectedMissionIndex == -1) exitWith {
    private _detailsCtrl = _display displayCtrl 7063;
    _detailsCtrl ctrlSetStructuredText parseText "<t align='center'><br/>Select a contract to view strategic tradeoffs.</t>";
};

private _missionIndexStr = _missionListCtrl lbData _selectedMissionIndex;
private _missions = _display getVariable ["A3M_ShadowOps_Missions", []];
private _missionData = _missions select (parseNumber _missionIndexStr);

_missionData params ["_opName", "_mType", "_desc", "_baseDiff", "_mReward", "_time", "_weather", "_reqClass"];

// 2. Tally Upgrades from Cart
private _purchasedList = _display displayCtrl 7062;
private _allAssets = _display getVariable ["A3M_ShadowOps_Catalog", []];

private _totalCost = 0;
private _intelMod = 0;
private _p1Mod = 0;
private _p2Mod = 0;
private _p3Mod = 0;

private _hasHalo = false;
private _hasHeloExfil = false;
private _hasCAS = false;

for "_i" from 0 to ((lbSize _purchasedList) - 1) do {
    private _assetIdx = parseNumber (_purchasedList lbData _i);
    private _assetData = _allAssets select _assetIdx;
    
    _assetData params ["_cat", "_name", "_cost", "_iMod", "_1Mod", "_2Mod", "_3Mod"];
    
    _totalCost = _totalCost + _cost;
    _intelMod = _intelMod + _iMod;
    _p1Mod = _p1Mod + _1Mod;
    _p2Mod = _p2Mod + _2Mod;
    _p3Mod = _p3Mod + _3Mod;
    
    if (_name == "HALO Drop") then { _hasHalo = true; };
    if (_name == "Fast Rope Helo Extract") then { _hasHeloExfil = true; };
    if (_name == "Loitering CAS (Wipeout)") then { _hasCAS = true; };
};

// 3. Tally Squad Size & Specialists
private _selectedSquadList = _display displayCtrl 7067;
private _squadCount = lbSize _selectedSquadList;
private _squadBonus = _squadCount * 5;

private _hasRequiredClass = false;
private _hasMedic = false;

for "_i" from 0 to (_squadCount - 1) do {
    private _dataStr = _selectedSquadList lbData _i;
    private _parts = _dataStr splitString "|";
    private _logicalClass = if (count _parts > 1) then { _parts select 1 } else { "Any" };
    
    if (_logicalClass == "Medic") then { _hasMedic = true; };
    if (_logicalClass == _reqClass || _reqClass == "Any") then {
        _hasRequiredClass = true;
    };
};

// 4. Calculate Synergies
private _synergyText = "";
private _hazardPay = _squadCount * 20000;
_totalCost = _totalCost + _hazardPay;

// Class Penalty
if (!_hasRequiredClass && _squadCount > 0) then {
    _p2Mod = _p2Mod - 30;
    _synergyText = _synergyText + "<t color='#FF0000'>WARNING: Missing Required Specialist (-30 Exec)</t><br/>";
} else {
    if (_hasRequiredClass && _reqClass != "Any" && _squadCount > 0) then {
        _p2Mod = _p2Mod + 15;
        _synergyText = _synergyText + "<t color='#00FF00'>SYNERGY: Specialist Attached (+15 Exec)</t><br/>";
    };
};

if (_hasMedic && _squadCount > 0) then {
    _p3Mod = _p3Mod + 10;
    _synergyText = _synergyText + "<t color='#00FF00'>SYNERGY: Combat Medic Attached (+10 Exfil)</t><br/>";
};

// Weather/Time Penalties
if (_hasHalo && (_time == "1200 Hrs (Noon)" || _time == "1800 Hrs (Dusk)")) then {
    _p1Mod = _p1Mod - 35;
    _synergyText = _synergyText + "<t color='#FF0000'>WARNING: Daylight HALO Drop highly visible (-35 Infil)</t><br/>";
};

if (_hasHalo && (_time == "0200 Hrs (Night)" || _time == "2300 Hrs (Night)")) then {
    _p1Mod = _p1Mod + 20;
    _synergyText = _synergyText + "<t color='#00FF00'>SYNERGY: Nighttime HALO Drop is stealthy (+20 Infil)</t><br/>";
};

if (_hasHeloExfil && (_weather == "Severe Storm")) then {
    _p3Mod = _p3Mod - 40;
    _synergyText = _synergyText + "<t color='#FF0000'>WARNING: Helo Exfil in Severe Storm is suicidal (-40 Exfil)</t><br/>";
};

if (_hasCAS && (_weather == "Severe Storm" || _weather == "Dense Fog")) then {
    _p2Mod = _p2Mod - 20;
    _synergyText = _synergyText + "<t color='#FF0000'>WARNING: CAS useless in zero-visibility weather (-20 Exec)</t><br/>";
};

// Add base squad bonuses
_p1Mod = _p1Mod + _squadBonus;
_p2Mod = _p2Mod + _squadBonus;
_p3Mod = _p3Mod + _squadBonus;

// 5. Display
private _formatSign = {
    params ["_val"];
    if (_val > 0) then { format ["<t color='#00FF00'>+%1</t>", _val] }
    else { if (_val < 0) then { format ["<t color='#FF0000'>%1</t>", _val] } else { "<t color='#888888'>0</t>" } };
};

private _text = format [
    "<t align='left' size='0.85'>Asset Requisitions:</t><t align='right' size='0.85' color='#00FF00'>$%1</t><br/>" +
    "<t align='left' size='0.85'>Hazard Pay ($20k per merc):</t><t align='right' size='0.85' color='#00FF00'>$%8</t><br/>" +
    "<t align='left' size='0.85'>Total Funding Required:</t><t align='right' size='0.85' color='#00FF00'>$%2</t><br/>" +
    "<t align='left' size='0.85'>Squad Size Multiplier:</t><t align='right' size='0.85'>%7</t><br/><br/>" +
    "%9<br/>" +
    "<t align='left' size='0.85'>Intel Accuracy:</t><t align='right' size='0.85'>%6</t><br/>" +
    "<t align='left' size='0.85'>Phase 1 (Infil) Mod:</t><t align='right' size='0.85'>%3</t><br/>" +
    "<t align='left' size='0.85'>Phase 2 (Exec) Mod:</t><t align='right' size='0.85'>%4</t><br/>" +
    "<t align='left' size='0.85'>Phase 3 (Exfil) Mod:</t><t align='right' size='0.85'>%5</t>",
    (_totalCost - _hazardPay), _totalCost, [_p1Mod] call _formatSign, [_p2Mod] call _formatSign, [_p3Mod] call _formatSign, [_intelMod] call _formatSign, [_squadBonus] call _formatSign, _hazardPay, _synergyText
];

private _detailsCtrl = _display displayCtrl 7063;
_detailsCtrl ctrlSetStructuredText parseText _text;
