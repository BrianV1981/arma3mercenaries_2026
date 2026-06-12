/*
    fn_deployMercenary.sqf
    Triggered when the player clicks DEPLOY SELECTED in the Barracks UI.
*/
private _display = findDisplay 7040;
if (isNull _display) exitWith {};

private _listActive = _display displayCtrl 7042;
private _index = lbCurSel _listActive;

if (_index == -1) exitWith { systemChat "No mercenary selected!"; };

private _mercID = _listActive lbData _index;
if (_mercID == "") exitWith { systemChat "Invalid mercenary selected."; };

private _text = _listActive lbText _index;
if ("Deployed" in _text) exitWith { systemChat "This mercenary is already deployed!"; };

if (player getVariable ["a3m_barracks_isProcessing", false]) exitWith { systemChat "Processing... please wait."; };
player setVariable ["a3m_barracks_isProcessing", true];

// Remove anti-spam lock after 2 seconds
[] spawn {
    uiSleep 2;
    player setVariable ["a3m_barracks_isProcessing", false];
};

// Request server to deploy
[player, _mercID] remoteExecCall ["A3M_fnc_serverDeployMercenary", 2];

systemChat "Deploying mercenary...";
