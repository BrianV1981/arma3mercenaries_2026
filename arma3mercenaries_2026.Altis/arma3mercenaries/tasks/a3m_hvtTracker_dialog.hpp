class A3M_HVTTrackerDialog {
    idd = 9020;
    movingEnable = false;
    enableSimulation = true;
    
    class ControlsBackground {
        class Background: grad_lbm_RscBackground {
            x = 0.35 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.3 * safezoneW;
            h = 0.5 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.95};
        };
        class Title: grad_lbm_RscText {
            idc = 9025;
            text = "SPACEX SATELLITE UPLINK: LOCATE HVT";
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
            text = "COST: $100,000";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0,0,0,0};
            style = 0x02; // ST_CENTER
        };
        class BuyBtn: grad_lbm_RscButton {
            idc = 9022;
            text = "AUTHORIZE SATELLITE SWEEP";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.65 * safezoneH + safezoneY;
            w = 0.135 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.2, 0.8, 0.2, 1};
            action = "[] call A3M_fnc_buySatelliteSweep;";
        };
        class BuyBlackfishBtn: grad_lbm_RscButton {
            idc = 9027;
            text = "AUTHORIZE BLACKFISH STRIKE";
            x = 0.505 * safezoneW + safezoneX;
            y = 0.65 * safezoneH + safezoneY;
            w = 0.135 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.8, 0.2, 0.2, 1};
            action = "[] call A3M_fnc_buyBlackfishSweep;";
        };
        class CancelBtn: grad_lbm_RscButton {
            idc = 9023;
            text = "CANCEL";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.70 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.8, 0.2, 0.2, 0.8};
            action = "closeDialog 0;";
        };
    };
};
