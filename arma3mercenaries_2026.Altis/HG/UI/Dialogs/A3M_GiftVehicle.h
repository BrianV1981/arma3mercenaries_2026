#include "..\HG_IDCS.h"

class A3M_GiftVehicle
{
    idd = 99800;
	enableSimulation = true;
	name = "A3M_GiftVehicle";
	onUnload = "A3M_GIFT_VEHICLE = nil; A3M_GIFT_PLAYERS = nil";
	
	class ControlsBackground
	{
		class Background: HG_RscText
		{
			colorBackground[] = {0,0,0,0.5};
			x = 0.407187 * safezoneW + safezoneX;
			y = 0.400 * safezoneH + safezoneY;
			w = 0.185625 * safezoneW;
			h = 0.17 * safezoneH;
		};
		
		class BackgroundFrame: HG_RscFrame
		{
			x = 0.407187 * safezoneW + safezoneX;
		    y = 0.400 * safezoneH + safezoneY;
		    w = 0.185625 * safezoneW;
		    h = 0.17 * safezoneH;
		};
		
		class WhiteLine: HG_RscPicture
		{
			text = "#(argb,8,8,3)color(1,1,1,1)";
			x = 0.407187 * safezoneW + safezoneX;
			y = 0.400 * safezoneH + safezoneY;
			w = 0.185625 * safezoneW;
			h = 0.0022 * safezoneH;
		};
	};

	class Controls
	{
		class PlayersCombo: HG_RscCombo
		{
			idc = 9980;
			x = 0.412344 * safezoneW + safezoneX;
			y = 0.420 * safezoneH + safezoneY;
			w = 0.175313 * safezoneW;
			h = 0.022 * safezoneH;
		};
		
		class GiveBtn: HG_RscButton
		{
			idc = 9981;
			text = "GIFT VEHICLE";
			tooltip = "Gift this vehicle to the selected player";
			onButtonClick = "[] spawn A3M_fnc_giftVehicleConfirm";
			x = 0.412344 * safezoneW + safezoneX;
			y = 0.460 * safezoneH + safezoneY;
			w = 0.175313 * safezoneW;
			h = 0.04 * safezoneH;
            colorBackground[] = {0, 0.5, 0, 1}; // Green
		};
		
		class ExitButton: HG_RscButton
		{
            text = "CANCEL";
			tooltip = "$STR_HG_DLG_CLOSE_TOOLTIP";
			onButtonClick = "closeDialog 0";
			x = 0.412344 * safezoneW + safezoneX;
			y = 0.510 * safezoneH + safezoneY;
			w = 0.175313 * safezoneW;
			h = 0.04 * safezoneH;
		};
	};
};
