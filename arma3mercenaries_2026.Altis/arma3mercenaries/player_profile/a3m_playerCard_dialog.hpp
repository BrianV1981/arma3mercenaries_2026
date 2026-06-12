/*
    A3M Player Profile Card Dialog (v840 Overhaul)
    Using HG_RscBase classes to prevent undefined class errors
*/

#define GUI_GRID_X    (safezoneX)
#define GUI_GRID_Y    (safezoneY)
#define GUI_GRID_W    (safezoneW / 40)
#define GUI_GRID_H    (safezoneH / 25)

class A3M_PlayerProfileDialog {
    idd = 7020;
    movingEnable = false;
    enableSimulation = true;

    class controlsBackground {
        class MainBackground: HG_RscText {
            idc = -1;
            x = 1 * GUI_GRID_W + GUI_GRID_X;
            y = 4 * GUI_GRID_H + GUI_GRID_Y;
            w = 38 * GUI_GRID_W;
            h = 18 * GUI_GRID_H;
            colorBackground[] = {0.1, 0.1, 0.1, 0.9}; // Dark translucent grey
        };
        class HeaderBackground: HG_RscText {
            idc = -1;
            x = 1 * GUI_GRID_W + GUI_GRID_X;
            y = 2 * GUI_GRID_H + GUI_GRID_Y;
            w = 38 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorBackground[] = {0.75, 0.5, 0.05, 1}; // Mercenary Orange header
        };
        
        // Column Headers
        class Col1Header: HG_RscText {
            idc = -1; text = "SERVICE RECORD";
            x = 1.5 * GUI_GRID_W + GUI_GRID_X; y = 4.2 * GUI_GRID_H + GUI_GRID_Y;
            w = 8.5 * GUI_GRID_W; h = 1.2 * GUI_GRID_H;
            colorText[] = {0.8, 0.8, 0.8, 1}; sizeEx = 1 * GUI_GRID_H;
        };
        class Col2Header: HG_RscText {
            idc = -1; text = "COMBAT HISTORY";
            x = 10.5 * GUI_GRID_W + GUI_GRID_X; y = 4.2 * GUI_GRID_H + GUI_GRID_Y;
            w = 8.5 * GUI_GRID_W; h = 1.2 * GUI_GRID_H;
            colorText[] = {0.8, 0.8, 0.8, 1}; sizeEx = 1 * GUI_GRID_H;
        };
        class Col3Header: HG_RscText {
            idc = -1; text = "LOGISTICS & LEDGER";
            x = 19.5 * GUI_GRID_W + GUI_GRID_X; y = 4.2 * GUI_GRID_H + GUI_GRID_Y;
            w = 8.5 * GUI_GRID_W; h = 1.2 * GUI_GRID_H;
            colorText[] = {0.8, 0.8, 0.8, 1}; sizeEx = 1 * GUI_GRID_H;
        };
        class Col4Header: HG_RscText {
            idc = -1; text = "ASSETS & PROPERTY";
            x = 28.5 * GUI_GRID_W + GUI_GRID_X; y = 4.2 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W; h = 1.2 * GUI_GRID_H;
            colorText[] = {0.8, 0.8, 0.8, 1}; sizeEx = 1 * GUI_GRID_H;
        };
    };

    class controls {
        class TitleText: HG_RscText {
            idc = 7021; // Player Name goes here
            text = "A3M PLAYER CARD"; 
            x = 1.5 * GUI_GRID_W + GUI_GRID_X;
            y = 2 * GUI_GRID_H + GUI_GRID_Y;
            w = 12.5 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorText[] = {0, 0, 0, 1}; // Black text on orange
            sizeEx = 1.5 * GUI_GRID_H;
        };

        class SquadDossierButton: HG_RscButton {
            idc = -1;
            text = "MY SQUAD";
            x = 16.5 * GUI_GRID_W + GUI_GRID_X;
            y = 2.625 * GUI_GRID_H + GUI_GRID_Y;
            w = 4.8 * GUI_GRID_W;
            h = 0.75 * GUI_GRID_H;
            action = "closeDialog 0; [] spawn { waitUntil {isNull (findDisplay 7020)}; [] call A3M_fnc_openSquadDossier; };";
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0.4, 0.4, 0.4, 1};
            colorBackgroundActive[] = {0.6, 0.6, 0.6, 1};
        };

        class PlayerGuidesButton: HG_RscButton {
            idc = -1;
            text = "PLAYER GUIDES";
            x = 21.6 * GUI_GRID_W + GUI_GRID_X;
            y = 2.625 * GUI_GRID_H + GUI_GRID_Y;
            w = 4.8 * GUI_GRID_W;
            h = 0.75 * GUI_GRID_H;
            action = "closeDialog 0; [] spawn { waitUntil {isNull (findDisplay 7020)}; [] call A3M_fnc_openFieldManual; };";
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0.4, 0.4, 0.4, 1};
            colorBackgroundActive[] = {0.6, 0.6, 0.6, 1};
        };

        class LeaderboardButton: HG_RscButton {
            idc = -1;
            text = "LEADERBOARD";
            x = 26.7 * GUI_GRID_W + GUI_GRID_X;
            y = 2.625 * GUI_GRID_H + GUI_GRID_Y;
            w = 4.8 * GUI_GRID_W;
            h = 0.75 * GUI_GRID_H;
            action = "closeDialog 0; [] spawn { waitUntil {isNull (findDisplay 7020)}; [] call A3M_fnc_openLeaderboard; };";
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0.4, 0.4, 0.4, 1};
            colorBackgroundActive[] = {0.6, 0.6, 0.6, 1};
        };

        class BountyBoardButton: HG_RscButton {
            idc = -1;
            text = "BOUNTY BOARD";
            x = 31.8 * GUI_GRID_W + GUI_GRID_X;
            y = 2.625 * GUI_GRID_H + GUI_GRID_Y;
            w = 4.8 * GUI_GRID_W;
            h = 0.75 * GUI_GRID_H;
            action = "closeDialog 0; [] spawn { waitUntil {isNull (findDisplay 7020)}; [] call A3M_fnc_openBountyBoard; };";
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0.4, 0.4, 0.4, 1};
            colorBackgroundActive[] = {0.6, 0.6, 0.6, 1};
        };

        class CloseButton: HG_RscButton {
            idc = -1;
            text = "X";
            x = 37 * GUI_GRID_W + GUI_GRID_X;
            y = 2 * GUI_GRID_H + GUI_GRID_Y;
            w = 2 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            action = "closeDialog 0;";
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0.8, 0.1, 0.1, 1};
            colorBackgroundActive[] = {1, 0.2, 0.2, 1};
        };
        
        // Column 1: Core Stats
        class StatsList: HG_RscListBox {
            idc = 7022; 
            x = 1.5 * GUI_GRID_W + GUI_GRID_X;
            y = 5.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 8.5 * GUI_GRID_W;
            h = 16 * GUI_GRID_H;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.8 * GUI_GRID_H;
        };
        
        // Column 2: Top Kills & Recent Kills
        class KillsList: HG_RscListBox {
            idc = 7023; 
            x = 10.5 * GUI_GRID_W + GUI_GRID_X;
            y = 5.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 8.5 * GUI_GRID_W;
            h = 16 * GUI_GRID_H;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.8 * GUI_GRID_H;
        };
        
        // Column 3: Recent Deaths & Ledger
        class LogisticsList: HG_RscListBox {
            idc = 7024; 
            x = 19.5 * GUI_GRID_W + GUI_GRID_X;
            y = 5.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 8.5 * GUI_GRID_W;
            h = 16 * GUI_GRID_H;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.8 * GUI_GRID_H;
        };
        
        // Column 4: Garage & Fortifications
        class AssetsList: HG_RscListBox {
            idc = 7025; 
            x = 28.5 * GUI_GRID_W + GUI_GRID_X;
            y = 5.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 16 * GUI_GRID_H;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.8 * GUI_GRID_H;
        };
    };
};