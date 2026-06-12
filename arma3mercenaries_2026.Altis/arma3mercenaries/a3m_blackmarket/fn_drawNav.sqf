/*
    A3M Quartermaster: Dynamic Navigation UI Injector
    Author: A.I.M. / BrianV1981
    Description: Dynamically injects the 6 inactive Quartermaster tabs, perfectly centered.
*/
params ["_display", "_activeID"];

// 1. Define all 7 Stores
private _allButtons = [
    ["weaponStore", "CIA ARMS DEALER", { [] spawn { waitUntil {isNull (uiNamespace getVariable ["ace_arsenal_display", displayNull])}; uiSleep 0.2; [missionNamespace getVariable ['A3M_HG_CurrentLaptop', player], objNull, objNull, 'weaponStore', '', player] call grad_lbm_fnc_loadBuymenu; }; }],
    ["itemStore", "MILITARY SURPLUS", { [] spawn { waitUntil {isNull (uiNamespace getVariable ["ace_arsenal_display", displayNull])}; uiSleep 0.2; [missionNamespace getVariable ['A3M_HG_CurrentLaptop', player], objNull, objNull, 'itemStore', '', player] call grad_lbm_fnc_loadBuymenu; }; }],
    ["armory", "ARMORY", { [] spawn { waitUntil {isNull (uiNamespace getVariable ["ace_arsenal_display", displayNull])}; uiSleep 0.2; [false] spawn A3M_fnc_openBlackMarket; }; }],
    ["vehicles", "CIA VEHICLE LOT", { [] spawn { waitUntil {isNull (uiNamespace getVariable ["ace_arsenal_display", displayNull])}; uiSleep 0.2; ['HG_DefaultShop', missionNamespace getVariable ['A3M_HG_CurrentLaptop', player]] call HG_fnc_dialogOnLoadVehicles; }; }],
    ["fortificationStore_1", "BASE BUILDING", { [] spawn { waitUntil {isNull (uiNamespace getVariable ["ace_arsenal_display", displayNull])}; uiSleep 0.2; [missionNamespace getVariable ['A3M_HG_CurrentLaptop', player], objNull, objNull, 'fortificationStore_1', '', player] call grad_lbm_fnc_loadBuymenu; }; }],
    ["aliveStore_1", "COMBAT SUPPORT", { [] spawn { waitUntil {isNull (uiNamespace getVariable ["ace_arsenal_display", displayNull])}; uiSleep 0.2; [missionNamespace getVariable ['A3M_HG_CurrentLaptop', player], objNull, objNull, 'aliveStore_1', '', player] call grad_lbm_fnc_loadBuymenu; }; }],
    ["mercenaryStore_1", "CONTRACTORS", { [] spawn { waitUntil {isNull (uiNamespace getVariable ["ace_arsenal_display", displayNull])}; uiSleep 0.2; [missionNamespace getVariable ['A3M_HG_CurrentLaptop', player], objNull, objNull, 'mercenaryStore_1', '', player] call grad_lbm_fnc_loadBuymenu; }; }]
];

// 2. Filter out the active store
private _buttonsToDraw = [];
{
    if ((_x select 0) != _activeID) then { _buttonsToDraw pushBack _x; };
} forEach _allButtons;

// 3. Mathematical Centering for exactly 6 buttons
private _buttonWidth = 0.11 * safeZoneW;
private _buttonHeight = 0.03 * safeZoneH;
private _spacing = 0.01 * safeZoneW;
private _totalWidth = (6 * _buttonWidth) + (5 * _spacing);
private _startX = safeZoneX + ((safeZoneW - _totalWidth) / 2); // Perfectly centered
private _startY = 0.02 * safeZoneH + safeZoneY;

// 4. Inject
for "_i" from 0 to 5 do {
    private _data = _buttonsToDraw select _i;
    private _text = _data select 1;
    private _code = _data select 2;
    private _xPos = _startX + (_i * (_buttonWidth + _spacing));
    
    private _btn = _display ctrlCreate ["HG_RscButton", 9100 + _i];
    _btn ctrlSetPosition [_xPos, _startY, _buttonWidth, _buttonHeight];
    _btn ctrlSetText _text;
    _btn ctrlSetBackgroundColor [0.13, 0.54, 0.21, 0.8];
    _btn setVariable ["A3M_NavCode", _code];
    
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _display = ctrlParent _ctrl;
        _display closeDisplay 2; 
        private _code = _ctrl getVariable "A3M_NavCode";
        call _code;
    }];
    
    _btn ctrlCommit 0;
};
