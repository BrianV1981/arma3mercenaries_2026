// File: arma3mercenaries\set_group_captive\fn_squadReorganizerMove.sqf
params ["_dir"];

disableSerialization;
private _display = findDisplay 7050;
if (isNull _display) exitWith {};

private _listbox = _display displayCtrl 7052;
private _curSel = lbCurSel _listbox;
if (_curSel == -1) exitWith {};

if (_dir == "UP" && _curSel > 0) then {
    private _unitToMove = A3M_Reorganizer_Units select _curSel;
    private _unitAbove = A3M_Reorganizer_Units select (_curSel - 1);
    
    A3M_Reorganizer_Units set [_curSel - 1, _unitToMove];
    A3M_Reorganizer_Units set [_curSel, _unitAbove];
    
    _curSel = _curSel - 1;
};

if (_dir == "DOWN" && _curSel < ((count A3M_Reorganizer_Units) - 1)) then {
    private _unitToMove = A3M_Reorganizer_Units select _curSel;
    private _unitBelow = A3M_Reorganizer_Units select (_curSel + 1);
    
    A3M_Reorganizer_Units set [_curSel + 1, _unitToMove];
    A3M_Reorganizer_Units set [_curSel, _unitBelow];
    
    _curSel = _curSel + 1;
};

// Refresh list
lbClear _listbox;
{
    private _name = name _x;
    private _role = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
    
    // Arma 3 uses 9 AI per page (F2 to F10). 
    private _page = floor (_forEachIndex / 9) + 1;
    private _fNum = (_forEachIndex % 9) + 2;
    private _fKey = format ["Pg%1-F%2", _page, _fNum];
    
    private _index = _listbox lbAdd format ["[%1] %2 (%3)", _fKey, _name, _role];
    _listbox lbSetData [_index, str _forEachIndex];
} forEach A3M_Reorganizer_Units;

_listbox lbSetCurSel _curSel;
