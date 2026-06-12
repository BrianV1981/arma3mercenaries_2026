class A3M_QuartermasterHub {
    idd = 9005;
    movingEnable = 0;
    enableSimulation = 1;

    class controlsBackground {
        class MainBackground: HG_RscText {
            idc = -1;
            x = 0.35 * safezoneW + safezoneX;
            y = 0.3 * safezoneH + safezoneY;
            w = 0.3 * safezoneW;
            h = 0.58 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.95};
        };
        class HeaderBackground: HG_RscText {
            idc = -1;
            x = 0.35 * safezoneW + safezoneX;
            y = 0.3 * safezoneH + safezoneY;
            w = 0.3 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.8, 0.2, 0, 1};
        };
        class HeaderText: HG_RscText {
            idc = -1;
            text = "CONSTELLIS BLACK MARKET HUB";
            x = 0.355 * safezoneW + safezoneX;
            y = 0.3 * safezoneH + safezoneY;
            w = 0.25 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = {1, 1, 1, 1};
        };
    };

    class controls {
        class BtnClose: HG_RscButton {
            idc = -1;
            text = "X";
            x = 0.625 * safezoneW + safezoneX;
            y = 0.3 * safezoneH + safezoneY;
            w = 0.025 * safezoneW;
            h = 0.04 * safezoneH;
            action = "closeDialog 0;";
            colorBackground[] = {0,0,0,0};
        };

        class BtnArmory: HG_RscButton {
            idc = 1601;
            text = "ARMORY & GEAR";
            x = 0.4 * safezoneW + safezoneX;
            y = 0.38 * safezoneH + safezoneY;
            w = 0.2 * safezoneW;
            h = 0.05 * safezoneH;
            // action injected via script
        };

        class BtnVehicles: HG_RscButton {
            idc = 1602;
            text = "MOTORPOOL";
            x = 0.4 * safezoneW + safezoneX;
            y = 0.45 * safezoneH + safezoneY;
            w = 0.2 * safezoneW;
            h = 0.05 * safezoneH;
            // action injected via script
        };

        class BtnFortifications: HG_RscButton {
            idc = 1603;
            text = "BASE BUILDING";
            x = 0.4 * safezoneW + safezoneX;
            y = 0.52 * safezoneH + safezoneY;
            w = 0.2 * safezoneW;
            h = 0.05 * safezoneH;
            // action injected via script
        };

        class BtnSupport: HG_RscButton {
            idc = 1604;
            text = "COMBAT SUPPORT";
            x = 0.4 * safezoneW + safezoneX;
            y = 0.59 * safezoneH + safezoneY;
            w = 0.2 * safezoneW;
            h = 0.05 * safezoneH;
            // action injected via script
        };
        
        class BtnMercenaries: HG_RscButton {
            idc = 1605;
            text = "CONTRACTORS";
            x = 0.4 * safezoneW + safezoneX;
            y = 0.66 * safezoneH + safezoneY;
            w = 0.2 * safezoneW;
            h = 0.05 * safezoneH;
            // action injected via script
        };

        class BtnArmsDealer: HG_RscButton {
            idc = 1606;
            text = "CIA ARMS DEALER";
            x = 0.4 * safezoneW + safezoneX;
            y = 0.73 * safezoneH + safezoneY;
            w = 0.2 * safezoneW;
            h = 0.05 * safezoneH;
        };

        class BtnSurplus: HG_RscButton {
            idc = 1607;
            text = "MILITARY SURPLUS";
            x = 0.4 * safezoneW + safezoneX;
            y = 0.80 * safezoneH + safezoneY;
            w = 0.2 * safezoneW;
            h = 0.05 * safezoneH;
        };
    };
};
