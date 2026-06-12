/*
    fn_receiveSquadDossierData.sqf
    Client-side receiver for Squad data.
*/
params ["_activeSquad", "_graveyard", ["_isBarracks", false]];

private _display = findDisplay 7040;
if (isNull _display) exitWith {};

private _listActive = _display displayCtrl 7042;
private _listGraveyard = _display displayCtrl 7043;
private _btnDeploy = _display displayCtrl 7044;
private _btnStow = _display displayCtrl 7045;

lbClear _listActive;
lbClear _listGraveyard;

if (_isBarracks) then {
    _btnDeploy ctrlShow true;
    _btnStow ctrlShow true;
} else {
    _btnDeploy ctrlShow false;
    _btnStow ctrlShow false;
};

if (count _activeSquad == 0) then {
    _listActive lbAdd "No Active Mercenaries found.";
} else {
    {
        _x params ["_mercID", "_name", "_class", "_kills", "_cash", "_joinDate", "_isDeployed"];
        
        private _statusStr = if (_isDeployed) then { "[Deployed]" } else { "[In Barracks]" };
        
        private _dateStr = "Unknown";
        if (count _joinDate >= 3) then {
            _dateStr = format ["%1-%2-%3", _joinDate select 0, _joinDate select 1, _joinDate select 2];
        };
        
        private _entry = format ["%1 %2 | Enlisted: %3 | Kills: %4 | Cash: $%5", _statusStr, _name, _dateStr, _kills, _cash];
        private _index = _listActive lbAdd _entry;
        _listActive lbSetData [_index, _mercID];
        
        // Optional color coding: Green for Deployed, Gray for Barracks
        if (_isDeployed) then {
            _listActive lbSetColor [_index, [0.5, 1, 0.5, 1]];
        } else {
            _listActive lbSetColor [_index, [0.7, 0.7, 0.7, 1]];
        };
    } forEach _activeSquad;
};

if (count _graveyard == 0) then {
    _listGraveyard lbAdd "No Fallen Soldiers.";
} else {
    {
        _x params ["_mercID", "_name", "_class", "_kills", "_cash", "_causeOfDeath", "_joinDate", "_deathDate"];
        
        private _timeServedStr = "Unknown";
        if (count _joinDate >= 6 && count _deathDate >= 6) then {
            // Very simple days-served estimation
            private _jd = _joinDate select 2;
            private _dd = _deathDate select 2;
            private _jm = _joinDate select 1;
            private _dm = _deathDate select 1;
            private _jy = _joinDate select 0;
            private _dy = _deathDate select 0;
            
            private _daysServed = ((_dy - _jy) * 365) + ((_dm - _jm) * 30) + (_dd - _jd);
            
            if (_daysServed == 0) then {
                _timeServedStr = "< 1 Day";
            } else {
                _timeServedStr = format ["%1 Days", _daysServed];
            };
        };
        
        private _entry = format ["%1 | Time Served: %2 | Kills: %3 | Cause: %4", _name, _timeServedStr, _kills, _causeOfDeath];
        private _index = _listGraveyard lbAdd _entry;
        _listGraveyard lbSetData [_index, _mercID];
        _listGraveyard lbSetColor [_index, [1, 0.4, 0.4, 1]];
    } forEach _graveyard;
};
