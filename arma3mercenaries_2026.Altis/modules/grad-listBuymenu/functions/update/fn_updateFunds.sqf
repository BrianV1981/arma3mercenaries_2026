/*  Updates funds text (top right) in buy menu
*
*/

#include "..\..\dialog\defines.hpp"
disableSerialization;

_dialog = findDisplay grad_lbm_DIALOG;
if (isNull _dialog) exitWith {};

_funds = [] call grad_lbm_fnc_getCurrentFunds;

_myfundsCtrl = _dialog displayCtrl grad_lbm_MYFUNDS;
_myfundsCtrl ctrlSetText format ["CREDITS: %1",_funds];

// A3M Custom Rank & XP Integration
private _xpCtrl = _dialog displayCtrl grad_lbm_XPBAR;
private _xpText = format ["RANK: %1 | MAX RANK REACHED", toUpper(rank player)];

if (!isNil "HG_XP_ENABLED") then {
    if (HG_XP_ENABLED) then {
        private _xpArray = player getVariable ["HG_XP", [(rank player), 0]];
        private _currentXP = _xpArray select 1;
        private _maxXP = getNumber (missionConfigFile >> "CfgClient" >> "HG_MasterCfg" >> (rank player) >> "xpToLvlUp");
        
        if (_maxXP > 0) then {
            _xpText = format ["RANK: %1 | XP: %2 / %3", toUpper(rank player), _currentXP, _maxXP];
        };
    };
};
_xpCtrl ctrlSetText _xpText;
