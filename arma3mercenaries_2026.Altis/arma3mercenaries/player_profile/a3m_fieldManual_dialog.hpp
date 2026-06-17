/*
    A3M Field Manual / Player Guides Dialog
    Provides a clean explanation of the gameplay loop and mechanics.
*/

#define GUI_GRID_X    (safezoneX)
#define GUI_GRID_Y    (safezoneY)
#define GUI_GRID_W    (safezoneW / 40)
#define GUI_GRID_H    (safezoneH / 25)

class A3M_FieldManualDialog {
    idd = 7030;
    movingEnable = false;
    enableSimulation = true;

    class controlsBackground {
        class MainBackground: HG_RscText {
            idc = -1;
            x = 10 * GUI_GRID_W + GUI_GRID_X;
            y = 3 * GUI_GRID_H + GUI_GRID_Y;
            w = 20 * GUI_GRID_W;
            h = 20 * GUI_GRID_H;
            colorBackground[] = {0.1, 0.1, 0.1, 0.9}; // Dark translucent grey
        };
        class HeaderBackground: HG_RscText {
            idc = -1;
            x = 10 * GUI_GRID_W + GUI_GRID_X;
            y = 1 * GUI_GRID_H + GUI_GRID_Y;
            w = 20 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorBackground[] = {0.2, 0.4, 0.6, 1}; // Distinct blue header
        };
    };

    class controls {
        class TitleText: HG_RscText {
            idc = -1;
            text = "FIELD MANUAL & GUIDES"; 
            x = 10.5 * GUI_GRID_W + GUI_GRID_X;
            y = 1 * GUI_GRID_H + GUI_GRID_Y;
            w = 15 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorText[] = {1, 1, 1, 1}; // White text on blue
            sizeEx = 1.2 * GUI_GRID_H;
        };

        class CloseButton: HG_RscButton {
            idc = -1;
            text = "X";
            x = 28 * GUI_GRID_W + GUI_GRID_X;
            y = 1 * GUI_GRID_H + GUI_GRID_Y;
            w = 2 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            action = "closeDialog 0; [] spawn { waitUntil {isNull (findDisplay 7030)}; [] call A3M_fnc_openPlayerCard; };";
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0.8, 0.1, 0.1, 1};
            colorBackgroundActive[] = {1, 0.2, 0.2, 1};
        };

        class ManualContent: HG_RscStructuredText {
            idc = 7031;
            x = 10.5 * GUI_GRID_W + GUI_GRID_X;
            y = 3.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 19 * GUI_GRID_W;
            h = 19.5 * GUI_GRID_H;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.8 * GUI_GRID_H;
            text = "";
        };
    };
};
