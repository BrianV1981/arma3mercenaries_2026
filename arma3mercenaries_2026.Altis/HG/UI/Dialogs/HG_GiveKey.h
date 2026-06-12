#include "..\HG_IDCS.h"
/*
    Author - HoverGuy
    GitHub - https://github.com/Ppgtjmad/SimpleShops
	Steam - https://steamcommunity.com/id/HoverGuy/
*/

class HG_GiveKey
{
    idd = HG_GK_IDD;
	enableSimulation = true;
	name = "HG_GiveKey";
	onUnload = "HG_CURSOR_OBJECT = nil; HG_ARRAY_HANDLER = nil";
	
	class ControlsBackground
	{
		class Background: HG_RscText
		{
			colorBackground[] = {0,0,0,0.5};
			x = 0.407187 * safezoneW + safezoneX;
			y = 0.313 * safezoneH + safezoneY;
			w = 0.185625 * safezoneW;
			h = 0.55 * safezoneH;
		};
		
		class BackgroundFrame: HG_RscFrame
		{
			x = 0.407187 * safezoneW + safezoneX;
		    y = 0.313 * safezoneH + safezoneY;
		    w = 0.185625 * safezoneW;
		    h = 0.55 * safeZoneH;
		};
		
		class WhiteLine: HG_RscPicture
		{
			text = "#(argb,8,8,3)color(1,1,1,1)";
			x = 0.407187 * safezoneW + safezoneX;
			y = 0.313 * safezoneH + safezoneY;
			w = 0.185625 * safezoneW;
			h = 0.0022 * safeZoneH;
		};
	};

	class Controls
	{
		class OwnersList: HG_RscListBox
		{
			idc = HG_GK_OWNERS_LIST_IDC;
			rowHeight = "1 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
			x = 0.412344 * safezoneW + safezoneX;
			y = 0.325 * safezoneH + safezoneY;
			w = 0.175313 * safezoneW;
			h = 0.28 * safezoneH;
		};
		
		class PlayersCombo: HG_RscCombo
		{
			idc = HG_GK_PLAYERS_COMBO_IDC;
			x = 0.412344 * safezoneW + safezoneX;
			y = 0.615 * safezoneH + safezoneY;
			w = 0.175313 * safezoneW;
			h = 0.022 * safezoneH;
		};
		
		class GiveBtn: HG_RscButton
		{
			idc = HG_GK_GIVE_BTN_IDC;
			text = "GIVE KEY TO PLAYER";
			tooltip = "$STR_HG_DLG_GK_GIVE_TOOLTIP";
			onButtonClick = "[1] call HG_fnc_giveKeyBtns";
			x = 0.412344 * safezoneW + safezoneX;
			y = 0.650 * safezoneH + safezoneY;
			w = 0.175313 * safezoneW;
			h = 0.04 * safezoneH;
            colorBackground[] = {0, 0.5, 0, 1}; // Green
		};

		class RemoveBtn: HG_RscButton
		{
			idc = HG_GK_REMOVE_BTN_IDC;
            text = "DESTROY KEY";
			tooltip = "$STR_HG_DLG_GK_REMOVE_TOOLTIP";
			onButtonClick = "[0] call HG_fnc_giveKeyBtns";
			x = 0.412344 * safezoneW + safezoneX;
			y = 0.700 * safezoneH + safezoneY;
			w = 0.175313 * safezoneW;
			h = 0.04 * safeZoneH;
            colorBackground[] = {0.5, 0, 0, 1}; // Red
		};
		
		class RefreshBtn: HG_RscButton
		{
			idc = HG_GK_REFRESH_BTN_IDC;
            text = "REFRESH LISTS";
			tooltip = "$STR_HG_DLG_GK_REFRESH_TOOLTIP";
			onButtonClick = "[] call HG_fnc_refreshKeyCombo";
			x = 0.412344 * safezoneW + safezoneX;
			y = 0.750 * safezoneH + safezoneY;
			w = 0.175313 * safezoneW;
			h = 0.04 * safeZoneH;
		};
		
		class ExitButton: HG_RscButton
		{
            text = "CLOSE";
			tooltip = "$STR_HG_DLG_CLOSE_TOOLTIP";
			onButtonClick = "closeDialog 0";
			x = 0.412344 * safezoneW + safezoneX;
			y = 0.800 * safezoneH + safezoneY;
			w = 0.175313 * safezoneW;
			h = 0.04 * safeZoneH;
		};
	};
};
