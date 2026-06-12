/*
    fn_stowMercenary.sqf
    Triggered when the player clicks SEND TO BARRACKS in the Barracks UI.
*/
private _display = findDisplay 7040;
if (isNull _display) exitWith {};

private _listActive = _display displayCtrl 7042;
private _index = lbCurSel _listActive;

if (_index == -1) exitWith { systemChat "No mercenary selected!"; };

private _mercID = _listActive lbData _index;
if (_mercID == "") exitWith { systemChat "Invalid mercenary selected."; };

private _text = _listActive lbText _index;
if ("In Barracks" in _text) exitWith { systemChat "This mercenary is already in the barracks!"; };

if (player getVariable ["a3m_barracks_isProcessing", false]) exitWith { systemChat "Processing... please wait."; };
player setVariable ["a3m_barracks_isProcessing", true];

// Remove anti-spam lock after 2 seconds
[] spawn {
    uiSleep 2;
    player setVariable ["a3m_barracks_isProcessing", false];
};

// Request server to stow
[player, _mercID] remoteExecCall ["A3M_fnc_serverStowMercenary", 2];

systemChat "Sending mercenary to barracks...";
