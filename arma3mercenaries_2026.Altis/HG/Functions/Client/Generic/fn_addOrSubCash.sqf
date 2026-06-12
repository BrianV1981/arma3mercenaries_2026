/*
    Author - HoverGuy
    GitHub - https://github.com/Ppgtjmad/SimpleShops
	Steam - https://steamcommunity.com/id/HoverGuy/
*/
params[["_amount",1,[0]],["_mode",0,[0]],["_where",0,[0]],"_oldVal","_newVal"];

if(!([_amount] call HG_fnc_isNumeric)) exitWith {hint (localize "STR_HG_NOT_A_NUMBER");};
if(_amount isEqualTo 0) exitWith {true;};

private _actualAmount = if (_mode isEqualTo 0) then { _amount } else { -_amount };

if (_where isEqualTo 0) then {
    [player, _actualAmount] call grad_moneymenu_fnc_addFunds;
} else {
    [player, _actualAmount] call grad_moneymenu_fnc_addFundsBankAccount; // Assuming grad_moneymenu bank support exists, fallback if not
};

if(HG_HUD_ENABLED && {HG_HUD_TOGGLED}) then
{
    [1] call HG_fnc_HUD;
};

if(HG_ATM_ENABLED) then
{
	[] call HG_fnc_atmRefresh;
};

true;
