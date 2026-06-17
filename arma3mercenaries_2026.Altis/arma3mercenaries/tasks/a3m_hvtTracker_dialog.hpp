class A3M_HVTTrackerDialog {
    idd = 9020;
    movingEnable = false;
    enableSimulation = true;
    
    class ControlsBackground {
        class Background: grad_lbm_RscBackground {
            x = 0.35 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.3 * safezoneW;
            h = 0.6 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.95};
        };
        class Title: grad_lbm_RscText {
            idc = 9025;
            text = "PALANTIR TRACKING SYSTEMS";
            x = 0.35 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.3 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.2, 0.4, 0.8, 0.9};
        };
    };
    
    class Controls {
        class HVTList: grad_lbm_RscListBox {
            idc = 9021;
            x = 0.36 * safezoneW + safezoneX;
            y = 0.31 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.26 * safezoneH;
            colorBackground[] = {0,0,0,0.5};
            onLBSelChanged = "_this call A3M_fnc_onHVTTrackerSelChanged;";
        };
        class CostText: grad_lbm_RscText {
            idc = 9026;
            text = "SELECT PALANTIR SERVICE";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0,0,0,0};
            style = 0x02; // ST_CENTER
        };
        class BuyBtn: grad_lbm_RscButton {
            idc = 9022;
            text = "SpaceX Satellite Sweep ($100k)";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.63 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.2, 0.8, 0.2, 1};
            action = "[] call A3M_fnc_buySatelliteSweep;";
        };
        class BuyDroneBtn: grad_lbm_RscButton {
            idc = 9028;
            text = "Constellis Drone Sweep ($50k)";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.68 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.8, 0.6, 0.2, 1};
            action = "[] call A3M_fnc_buyDroneSweep;";
        };
        class BuyBlackfishBtn: grad_lbm_RscButton {
            idc = 9027;
            text = "Constellis Blackfish Attack Mission ($200k)";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.73 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.8, 0.2, 0.2, 1};
            action = "[] call A3M_fnc_buyBlackfishSweep;";
        };
        class CancelBtn: grad_lbm_RscButton {
            idc = 9023;
            text = "CANCEL";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.79 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.8, 0.2, 0.2, 0.8};
            action = "closeDialog 0;";
        };
    };
};
