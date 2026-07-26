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
    private _fKey = format ["F%1", _forEachIndex + 2]; // Player is F1
    private _index = _listbox lbAdd format ["[%1] %2 (%3)", _fKey, _name, _role];
    _listbox lbSetData [_index, str _forEachIndex];
} forEach A3M_Reorganizer_Units;

if ((lbSize _listbox) > 0) then {
    _listbox lbSetCurSel 0;
};
