// File: arma3mercenaries\set_group_captive\fn_openSquadReorganizer.sqf

disableSerialization;
createDialog "A3M_SquadReorganizerDialog";

private _display = findDisplay 7050;
if (isNull _display) exitWith { systemChat "Error: Could not open Squad Reorganizer."; };

private _listbox = _display displayCtrl 7052;
lbClear _listbox;

A3M_Reorganizer_Units = [];
private _units = units (group player);

{
    if (_x != player) then {
        A3M_Reorganizer_Units pushBack _x;
    };
} forEach _units;

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

if ((lbSize _listbox) > 0) then {
    _listbox lbSetCurSel 0;
};
