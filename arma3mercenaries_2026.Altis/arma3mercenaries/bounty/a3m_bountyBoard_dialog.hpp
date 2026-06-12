/*
    A3M Bounty Board Dialog
    Allows players to view active bounties and place new ones.
*/

#define GUI_GRID_X    (safezoneX)
#define GUI_GRID_Y    (safezoneY)
#define GUI_GRID_W    (safezoneW / 40)
#define GUI_GRID_H    (safezoneH / 25)

class A3M_BountyBoardDialog {
    idd = 7030;
    movingEnable = false;
    enableSimulation = true;

    class controlsBackground {
        class MainBackground: HG_RscText {
            idc = -1;
            x = 3 * GUI_GRID_W + GUI_GRID_X;
            y = 3 * GUI_GRID_H + GUI_GRID_Y;
            w = 34 * GUI_GRID_W;
            h = 20 * GUI_GRID_H;
            colorBackground[] = {0.1, 0.1, 0.1, 0.92};
        };
        class HeaderBackground: HG_RscText {
            idc = -1;
            x = 3 * GUI_GRID_W + GUI_GRID_X;
            y = 1 * GUI_GRID_H + GUI_GRID_Y;
            w = 34 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorBackground[] = {0.75, 0.35, 0.05, 1};
        };
    };

    class controls {
        class TitleText: HG_RscText {
            idc = 7031;
            text = "A3M BOUNTY BOARD";
            x = 3.5 * GUI_GRID_W + GUI_GRID_X;
            y = 1 * GUI_GRID_H + GUI_GRID_Y;
            w = 20 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorText[] = {0, 0, 0, 1};
            sizeEx = 1.5 * GUI_GRID_H;
        };

        class CloseButton: HG_RscButton {
            idc = -1;
            text = "X";
            x = 35 * GUI_GRID_W + GUI_GRID_X;
            y = 1 * GUI_GRID_H + GUI_GRID_Y;
            w = 2 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            action = "closeDialog 0; [] spawn { waitUntil {isNull (findDisplay 7030)}; [] call A3M_fnc_openPlayerCard; };";
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0.8, 0.1, 0.1, 1};
            colorBackgroundActive[] = {1, 0.2, 0.2, 1};
        };

        // Bounty list
        class BountyListBox: HG_RscListBox {
            idc = 7032;
            x = 3.5 * GUI_GRID_W + GUI_GRID_X;
            y = 3.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 33 * GUI_GRID_W;
            h = 12 * GUI_GRID_H;
            colorBackground[] = {0, 0, 0, 0.6};
            sizeEx = 0.9 * GUI_GRID_H;
        };

        // Info text
        class InfoText: HG_RscText {
            idc = 7033;
            text = "";
            x = 3.5 * GUI_GRID_W + GUI_GRID_X;
            y = 16 * GUI_GRID_H + GUI_GRID_Y;
            w = 20 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            colorText[] = {0.7, 0.7, 0.7, 1};
            sizeEx = 0.8 * GUI_GRID_H;
        };

        // Target UID input
        class TargetInput: HG_RscEdit {
            idc = 7034;
            text = "";
            x = 3.5 * GUI_GRID_W + GUI_GRID_X;
            y = 18 * GUI_GRID_H + GUI_GRID_Y;
            w = 15 * GUI_GRID_W;
            h = 1.8 * GUI_GRID_H;
            colorBackground[] = {0, 0, 0, 0.7};
            colorText[] = {1, 1, 1, 1};
            tooltip = "Target player UID";
        };

        // Amount input
        class AmountInput: HG_RscEdit {
            idc = 7035;
            text = "";
            x = 19 * GUI_GRID_W + GUI_GRID_X;
            y = 18 * GUI_GRID_H + GUI_GRID_Y;
            w = 8 * GUI_GRID_W;
            h = 1.8 * GUI_GRID_H;
            colorBackground[] = {0, 0, 0, 0.7};
            colorText[] = {1, 1, 1, 1};
            tooltip = "Bounty amount ($)";
        };

        // Place Bounty Button
        class PlaceButton: HG_RscButton {
            idc = -1;
            text = "PLACE BOUNTY";
            x = 28 * GUI_GRID_W + GUI_GRID_X;
            y = 18 * GUI_GRID_H + GUI_GRID_Y;
            w = 8.5 * GUI_GRID_W;
            h = 1.8 * GUI_GRID_H;
            action = "private _targetUID = ctrlText ((findDisplay 7030) displayCtrl 7034); private _amountStr = ctrlText ((findDisplay 7030) displayCtrl 7035); private _amount = parseNumber _amountStr; if (_targetUID != '' && _amount > 0) then { [player, _targetUID, _amount] remoteExecCall ['A3M_fnc_serverPlaceBounty', 2]; closeDialog 0; };";
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0.2, 0.6, 0.2, 0.9};
            colorBackgroundActive[] = {0.3, 0.8, 0.3, 1};
        };

        // Labels
        class TargetLabel: HG_RscText {
            idc = -1;
            text = "Target UID:";
            x = 3.5 * GUI_GRID_W + GUI_GRID_X;
            y = 17.2 * GUI_GRID_H + GUI_GRID_Y;
            w = 15 * GUI_GRID_W;
            h = 0.8 * GUI_GRID_H;
            colorText[] = {0.6, 0.6, 0.6, 1};
            sizeEx = 0.65 * GUI_GRID_H;
        };

        class AmountLabel: HG_RscText {
            idc = -1;
            text = "Amount ($):";
            x = 19 * GUI_GRID_W + GUI_GRID_X;
            y = 17.2 * GUI_GRID_H + GUI_GRID_Y;
            w = 8 * GUI_GRID_W;
            h = 0.8 * GUI_GRID_H;
            colorText[] = {0.6, 0.6, 0.6, 1};
            sizeEx = 0.65 * GUI_GRID_H;
        };
    };
};
