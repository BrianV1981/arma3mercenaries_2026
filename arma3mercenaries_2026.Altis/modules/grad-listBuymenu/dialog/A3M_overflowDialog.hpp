class A3M_OverflowDialog {
    idd = 9010;
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
            text = "INVENTORY FULL - SELECT OVERFLOW DESTINATION";
            x = 0.35 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.3 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.8, 0.2, 0.2, 0.9}; // Red header
        };
    };
    
    class Controls {
        class ContainerList: grad_lbm_RscListNBox {
            idc = 9011;
            x = 0.36 * safezoneW + safezoneX;
            y = 0.31 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.26 * safezoneH;
            colorBackground[] = {0,0,0,0.5};
        };
        class AmountText: grad_lbm_RscText {
            idc = -1;
            text = "AMOUNT:";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.08 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class AmountEdit: grad_lbm_RscEdit {
            idc = 9014;
            text = "1";
            x = 0.44 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.06 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 1};
        };
        class ConfirmBtn: grad_lbm_RscButton {
            idc = 9012;
            text = "CONFIRM ROUTING";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.65 * safezoneH + safezoneY;
            w = 0.135 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.13, 0.54, 0.21, 0.8};
            action = "[] call grad_lbm_fnc_confirmOverflow;";
        };
        class CancelBtn: grad_lbm_RscButton {
            idc = 9013;
            text = "CANCEL";
            x = 0.505 * safezoneW + safezoneX;
            y = 0.65 * safezoneH + safezoneY;
            w = 0.135 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.8, 0.2, 0.2, 0.8};
            action = "closeDialog 0; systemChat 'Transaction cancelled.';";
        };
    };
};
