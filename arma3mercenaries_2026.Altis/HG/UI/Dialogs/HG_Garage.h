#include "..\HG_IDCS.h"
/*
    Author - HoverGuy
    GitHub - https://github.com/Ppgtjmad/SimpleShops
	Steam - https://steamcommunity.com/id/HoverGuy/
*/

class HG_Garage
{
    idd = HG_GARAGE_IDD;
	enableSimulation = true;
	movingEnable = true;
	name = "HG_Garage";
	onUnload = "HG_SPAWN_POINTS = nil; HG_STRING_HANDLER = nil";
	
	class ControlsBackground
	{
		class Background: HG_RscText
		{
			colorBackground[] = {0,0,0,0.5};
			x = 0.386562 * safeZoneW + safeZoneX;
			y = 0.335 * safeZoneH + safeZoneY;
			w = 0.226875 * safeZoneW;
			h = 0.48 * safeZoneH; // Extended to cover new buttons
		};
		
		class BackgroundFrame: HG_RscFrame
		{
			x = 0.386562 * safeZoneW + safeZoneX;
			y = 0.335 * safeZoneH + safeZoneY;
			w = 0.226875 * safeZoneW;
			h = 0.48 * safeZoneH;
		};
		
		class WhiteLine: HG_RscPicture
		{
			text = "#(argb,8,8,3)color(1,1,1,1)";
			x = 0.386562 * safeZoneW + safeZoneX;
			y = 0.335 * safeZoneH + safeZoneY;
			w = 0.226875 * safeZoneW;
			h = 0.0022 * safeZoneH;
		};
	    
		class GarageInfo: HG_RscText
		{
			idc = HG_GARAGE_INFO_IDC;
			style = "0x02";
			shadow = 0;
			x = 0.391719 * safeZoneW + safeZoneX;
			y = 0.396 * safeZoneH + safeZoneY;
			w = 0.216563 * safeZoneW;
			h = 0.269 * safezoneH;
		};
	};
	
	class Controls
	{
		class ParkBtn: HG_RscButton
		{
			idc = -1;
			text = "PARK NEAREST VEHICLE";
			tooltip = "Stores the nearest owned vehicle back into the garage";
			onButtonClick = "['HG_DefaultGarage'] spawn HG_fnc_storeVehicleClient; closeDialog 0;";
			x = 0.391719 * safeZoneW + safeZoneX;
			y = 0.346 * safeZoneH + safeZoneY;
			w = 0.216563 * safeZoneW;
			h = 0.04 * safeZoneH;
            colorBackground[] = {0.8, 0.4, 0, 1}; // Orange
		};

		class List: HG_RscListBox
		{
			idc = HG_GARAGE_LIST_IDC;
			style = "0x02 + 16";
			rowHeight = "1 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
			x = 0.391719 * safeZoneW + safeZoneX;
			y = 0.396 * safeZoneH + safeZoneY;
			w = 0.216563 * safeZoneW;
			h = 0.269 * safezoneH;
		};
		
		/*
		class SpawnPointsList: HG_RscCombo
		{
			idc = HG_GARAGE_SP_IDC;
			x = 0.391719 * safezoneW + safezoneX;
			y = 0.676 * safezoneH + safezoneY;
			w = 0.216563 * safezoneW;
			h = 0.022 * safezoneH;
		};
		*/
		
		class SpawnBtn: HG_RscButton
		{
			idc = HG_GARAGE_SPAWN_BTN_IDC;
			text = "SPAWN VEHICLE";
			tooltip = "$STR_HG_GRG_SPAWN_TOOLTIP";
			onButtonClick = "[] call HG_fnc_garageSpawn";
			x = 0.391719 * safeZoneW + safeZoneX;
			y = 0.710 * safeZoneH + safeZoneY;
			w = 0.216563 * safeZoneW;
			h = 0.04 * safeZoneH;
            colorBackground[] = {0, 0.5, 0, 1}; // Green
		};

		class RefreshBtn: HG_RscButton
		{
			idc = HG_GARAGE_REFRESH_BTN_IDC;
			text = "REFRESH";
			tooltip = "$STR_HG_GRG_REFRESH_TOOLTIP";
			onButtonClick = "[] call HG_fnc_refreshGarage";
			x = 0.391719 * safeZoneW + safeZoneX;
			y = 0.760 * safeZoneH + safeZoneY;
			w = 0.105 * safeZoneW;
			h = 0.04 * safeZoneH;
            colorBackground[] = {0.8, 0.2, 0, 1}; // Red
		};
		
		class ExitButton: HG_RscButton
		{
			text = "EXIT GARAGE";
			tooltip = "$STR_HG_DLG_CLOSE_TOOLTIP";
			onButtonClick = "closeDialog 0";
			x = 0.503282 * safeZoneW + safeZoneX;
			y = 0.760 * safeZoneH + safeZoneY;
			w = 0.105 * safeZoneW;
			h = 0.04 * safeZoneH;
            colorBackground[] = {0.4, 0.4, 0.4, 1}; // Gray
		};
	};
};
