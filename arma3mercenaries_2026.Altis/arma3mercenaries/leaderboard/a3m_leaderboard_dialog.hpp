// File: arma3mercenaries\leaderboard\a3m_leaderboard_dialog.hpp

class A3M_LeaderboardDialog {
    idd = 7030;
    movingEnable = false;
    enableSimulation = 1;

    class controlsBackground {
        class MainBackground: HG_RscText {
            idc = -1;
            x = 0.1 * safezoneW + safezoneX;
            y = 0.1 * safezoneH + safezoneY;
            w = 0.8 * safezoneW;
            h = 0.8 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.9};
        };
        class HeaderBackground: HG_RscText {
            idc = -1;
            x = 0.1 * safezoneW + safezoneX;
            y = 0.1 * safezoneH + safezoneY;
            w = 0.8 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
        };
    };

    class controls {
        class TitleText: HG_RscText {
            idc = 7031;
            text = "CONSTELLIS GLOBAL LEADERBOARDS";
            x = 0.1 * safezoneW + safezoneX;
            y = 0.1 * safezoneH + safezoneY;
            w = 0.8 * safezoneW;
            h = 0.05 * safezoneH;
            colorText[] = {1, 1, 1, 1};
            sizeEx = 0.05;
            style = 2; // Center
        };

        class CloseButton: HG_RscButton {
            idc = -1;
            text = "X";
            x = 0.87 * safezoneW + safezoneX;
            y = 0.105 * safezoneH + safezoneY;
            w = 0.02 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.8, 0, 0, 1};
            action = "closeDialog 0; [] spawn { waitUntil {isNull (findDisplay 7030)}; [] call A3M_fnc_openPlayerCard; };";
        };

        // Column 1: Top Killers
        class Col1_List: HG_RscListBox {
            idc = 7032;
            x = 0.12 * safezoneW + safezoneX;
            y = 0.18 * safezoneH + safezoneY;
            w = 0.17 * safezoneW;
            h = 0.68 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.035;
            onLBDblClick = "_this call A3M_fnc_openTargetPlayerCard;";
        };

        // Column 2: Longest Shots
        class Col2_List: HG_RscListBox {
            idc = 7033;
            x = 0.31 * safezoneW + safezoneX;
            y = 0.18 * safezoneH + safezoneY;
            w = 0.17 * safezoneW;
            h = 0.68 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.035;
            onLBDblClick = "_this call A3M_fnc_openTargetPlayerCard;";
        };

        // Column 3: Wealth (Bank Balance)
        class Col3_List: HG_RscListBox {
            idc = 7034;
            x = 0.50 * safezoneW + safezoneX;
            y = 0.18 * safezoneH + safezoneY;
            w = 0.17 * safezoneW;
            h = 0.68 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.035;
            onLBDblClick = "_this call A3M_fnc_openTargetPlayerCard;";
        };

        // Column 4: Distance Traveled
        class Col4_List: HG_RscListBox {
            idc = 7035;
            x = 0.69 * safezoneW + safezoneX;
            y = 0.18 * safezoneH + safezoneY;
            w = 0.17 * safezoneW;
            h = 0.68 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.035;
            onLBDblClick = "_this call A3M_fnc_openTargetPlayerCard;";
        };
    };
};