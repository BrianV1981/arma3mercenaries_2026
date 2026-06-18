/*
    fn_onShadowOpsMissionSelected.sqf
    Called when the player clicks on a contract in the left list box.
*/
disableSerialization;
params ["_control", "_selectedIndex"];

if (_selectedIndex == -1) exitWith {};

private _display = findDisplay 7050;
if (isNull _display) exitWith {};

private _missionIndexStr = _control lbData _selectedIndex;
private _missionIndex = parseNumber _missionIndexStr;

private _missions = _display getVariable ["A3M_ShadowOps_Missions", []];
private _missionData = _missions select _missionIndex;

_missionData params ["_missionName", "_missionType", "_missionDesc", "_baseDifficulty", "_rewardMultiplier"];

private _detailsCtrl = _display displayCtrl 7055;

private _formattedText = format [
    "<t align='left' size='1.0' color='#FFaa00'>%1</t><br/>" +
    "<t align='left' size='0.8' color='#bbbbbb'>Classification: %2</t><br/>" +
    "<t align='left' size='0.8' color='#bbbbbb'>Base Danger Level: %3</t><br/>" +
    "<t align='left' size='0.8' color='#bbbbbb'>Reward Multiplier: x%4</t><br/><br/>" +
    "<t align='left' size='0.9'>%5</t>",
    _missionName, _missionType, _baseDifficulty, _rewardMultiplier, _missionDesc
];

_detailsCtrl ctrlSetStructuredText parseText _formattedText;
