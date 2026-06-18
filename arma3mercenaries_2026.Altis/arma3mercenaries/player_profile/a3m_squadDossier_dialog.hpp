// File: arma3mercenaries\player_profile\a3m_squadDossier_dialog.hpp

class A3M_SquadDossierDialog {
    idd = 7040;
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
        
        class Col1Header: HG_RscText {
            idc = -1; text = "ACTIVE MERCENARIES";
            x = 0.12 * safezoneW + safezoneX; y = 0.16 * safezoneH + safezoneY;
            w = 0.36 * safezoneW; h = 0.03 * safezoneH;
            colorText[] = {0.8, 0.8, 0.8, 1}; sizeEx = 0.04;
        };
        
        class Col2Header: HG_RscText {
            idc = -1; text = "THE GRAVEYARD (FALLEN SOLDIERS)";
            x = 0.52 * safezoneW + safezoneX; y = 0.16 * safezoneH + safezoneY;
            w = 0.36 * safezoneW; h = 0.03 * safezoneH;
            colorText[] = {0.8, 0.8, 0.8, 1}; sizeEx = 0.04;
        };
    };

    class controls {
        class TitleText: HG_RscText {
            idc = 7041;
            text = "AI SQUAD DOSSIER";
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
            action = "closeDialog 0; [] spawn { waitUntil {isNull (findDisplay 7040)}; [] call A3M_fnc_openPlayerCard; };";
        };

        class ShadowOpsButton: HG_RscButton {
            idc = 7048;
            text = "SHADOW OPERATIONS";
            x = 0.70 * safezoneW + safezoneX;
            y = 0.105 * safezoneH + safezoneY;
            w = 0.15 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 1};
            action = "closeDialog 0; [] spawn { waitUntil {isNull (findDisplay 7040)}; [] spawn A3M_fnc_openShadowOpsDialog; };";
        };

        // Active List
        class ActiveList: HG_RscListBox {
            idc = 7042;
            x = 0.12 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.36 * safezoneW;
            h = 0.60 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.035;
        };

        class DeployButton: HG_RscButton {
            idc = 7044;
            text = "DEPLOY SELECTED";
            x = 0.12 * safezoneW + safezoneX;
            y = 0.81 * safezoneH + safezoneY;
            w = 0.17 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0, 0.6, 0, 1};
            action = "[] spawn A3M_fnc_deployMercenary;";
            show = 0; // Hidden by default, shown via script when at a Barracks
        };

        class StowButton: HG_RscButton {
            idc = 7045;
            text = "SEND TO BARRACKS";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.81 * safezoneH + safezoneY;
            w = 0.17 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.6, 0.2, 0, 1};
            action = "[] spawn A3M_fnc_stowMercenary;";
            show = 0; // Hidden by default
        };

        // Graveyard List
        class GraveyardList: HG_RscListBox {
            idc = 7043;
            x = 0.52 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.36 * safezoneW;
            h = 0.65 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.035;
        };

        class StatsBackground: HG_RscText {
            idc = -1;
            x = 0.12 * safezoneW + safezoneX;
            y = 0.86 * safezoneH + safezoneY;
            w = 0.76 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = {0.15, 0.15, 0.15, 1};
        };

        class StatsText: HG_RscStructuredText {
            idc = 7046;
            text = "<t align='center' size='1.1'>Loading Statistics...</t>";
            x = 0.12 * safezoneW + safezoneX;
            y = 0.865 * safezoneH + safezoneY;
            w = 0.76 * safezoneW;
            h = 0.03 * safezoneH;
        };
    };
};
