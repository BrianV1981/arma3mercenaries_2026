class A3M_EconomyAudit {
    idd = 9006;
    movingEnable = 0;
    enableSimulation = 1;

    class controlsBackground {
        class MainBackground: HG_RscText {
            idc = -1;
            x = 0.25 * safezoneW + safezoneX;
            y = 0.2 * safezoneH + safezoneY;
            w = 0.5 * safezoneW;
            h = 0.6 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.95};
        };
        class HeaderBackground: HG_RscText {
            idc = -1;
            x = 0.25 * safezoneW + safezoneX;
            y = 0.2 * safezoneH + safezoneY;
            w = 0.5 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.8, 0.2, 0, 1};
        };
        class HeaderText: HG_RscText {
            idc = -1;
            text = "DAILY SUPPLY LEDGER (SALES & SHORTAGES)";
            x = 0.255 * safezoneW + safezoneX;
            y = 0.2 * safezoneH + safezoneY;
            w = 0.45 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = {1, 1, 1, 1};
        };
    };

    class controls {
        class BtnClose: HG_RscButton {
            idc = -1;
            text = "X";
            x = 0.725 * safezoneW + safezoneX;
            y = 0.2 * safezoneH + safezoneY;
            w = 0.025 * safezoneW;
            h = 0.04 * safezoneH;
            action = "closeDialog 0;";
            colorBackground[] = {0,0,0,0};
        };

        class AuditList: HG_RscListBox {
            idc = 1701;
            x = 0.26 * safezoneW + safezoneX;
            y = 0.26 * safezoneH + safezoneY;
            w = 0.48 * safezoneW;
            h = 0.52 * safezoneH;
        };
    };
};
