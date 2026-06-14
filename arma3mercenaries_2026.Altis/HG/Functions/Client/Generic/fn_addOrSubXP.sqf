/*
    Author - HoverGuy
    GitHub - https://github.com/Ppgtjmad/SimpleShops
	Steam - https://steamcommunity.com/id/HoverGuy/
*/
params[["_amount",1,[0]],["_mode",0,[0]],["_ranks",["PRIVATE","CORPORAL","SERGEANT","LIEUTENANT","CAPTAIN","MAJOR","COLONEL"]]];

if((rank player) isEqualTo "COLONEL") exitWith {};

private["_curXp","_rankIndex","_newXp"];
_curXp = (player getVariable "HG_XP") select 1;
_rankIndex = _ranks find (rank player);

if(_mode isEqualTo 1) then
{
	_newXp = _curXp - _amount;
	
	if(_newXp < 0) then
	{
	    _newXp = 0;
		
		if((rank player) != "PRIVATE") then
		{
		    private _newRank = (_ranks select (_rankIndex - 1));
			private _demoMsg = format["<t align='center'><t font='RobotoCondensedBold' size='2.0' color='#FF0000'>DEMOTED</t><br/><t font='PuristaMedium' size='1.2' color='#FFFFFF'>You have been busted down to %1.</t></t>", _newRank];
            [_demoMsg, -1, 0.3, 7, 1, 0, 788] spawn BIS_fnc_dynamicText;
            playSound "A3M_RankDown";
	        player setUnitRank _newRank;
		};
	};
} else {
    private _reqXp = getNumber(getMissionConfig "CfgClient" >> "HG_MasterCfg" >> (rank player) >> "xpToLvlUp");
	_newXp = _curXp + _amount;
	
	if(_newXp >= _reqXp) then
	{
	    _newXp = 0;
		private _newRank = (_ranks select (_rankIndex + 1));
		private _promoMsg = format["<t align='center'><t font='RobotoCondensedBold' size='2.0' color='#00FF00'>PROMOTED</t><br/><t font='PuristaMedium' size='1.2' color='#FFFFFF'>Congratulations, you are now a %1!</t></t>", _newRank];
        [_promoMsg, -1, 0.3, 7, 1, 0, 788] spawn BIS_fnc_dynamicText;
        playSound "A3M_RankUp";
		player setUnitRank _newRank;
	};
};

HG_CLIENT = [2,(getPlayerUID player),[(rank player),_newXp]];
if(isServer) then
{
	[HG_CLIENT] call HG_fnc_clientToServer;
} else {
    publicVariableServer "HG_CLIENT";
};
HG_CLIENT = nil;
player setVariable ["HG_XP",[(rank player),_newXp],true];

if(HG_HUD_ENABLED) then
{
    if(HG_HUD_TOGGLED) then
	{
        [2] call HG_fnc_HUD;
	    [3] call HG_fnc_HUD;
	};
};

true;
