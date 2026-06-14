class A3M_TicketMenu {
    idd = 7700;
    movingEnable = true;
    enableSimulation = true;

    class controlsBackground {
        class MainBackground: HG_RscText {
            idc = -1;
            x = 0.3 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.4 * safezoneW;
            h = 0.5 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.9};
        };
        class HeaderBackground: HG_RscText {
            idc = -1;
            x = 0.3 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.4 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = {1, 0.5, 0, 0.8}; // A3M Orange
        };
        class HeaderText: HG_RscText {
            idc = -1;
            text = "A3M TICKETING & BUG REPORT SYSTEM";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.05 * safezoneH;
            colorText[] = {1, 1, 1, 1};
            font = "RobotoCondensedBold";
            sizeEx = 0.045;
        };
        class TitleLabel: HG_RscText {
            idc = -1;
            text = "TICKET TITLE (Short Summary):";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.32 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.03 * safezoneH;
            font = "RobotoCondensed";
            sizeEx = 0.035;
        };
        class DescLabel: HG_RscText {
            idc = -1;
            text = "DETAILED DESCRIPTION:";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.41 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.03 * safezoneH;
            font = "RobotoCondensed";
            sizeEx = 0.035;
        };
        class InfoLabel: HG_RscText {
            idc = -1;
            text = "Tickets are pushed securely to the remote GitHub issue tracker.";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.70 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.03 * safezoneH;
            font = "RobotoCondensed";
            sizeEx = 0.03;
            colorText[] = {0.7, 0.7, 0.7, 1};
        };
    };

    class controls {
        class TitleEdit: HG_RscEdit {
            idc = 7701;
            x = 0.31 * safezoneW + safezoneX;
            y = 0.36 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.8};
            text = "";
        };
        class DescEdit: HG_RscEdit {
            idc = 7702;
            style = 16; // ST_MULTI
            x = 0.31 * safezoneW + safezoneX;
            y = 0.45 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.23 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.8};
            text = "";
            lineSpacing = 1;
        };
        class SubmitButton: HG_RscButton {
            idc = 7703;
            text = "SUBMIT TICKET";
            x = 0.52 * safezoneW + safezoneX;
            y = 0.69 * safezoneH + safezoneY;
            w = 0.17 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.2, 0.6, 0.2, 1};
            action = "[] call A3M_fnc_submitTicket;";
        };
        class CancelButton: HG_RscButton {
            idc = 7704;
            text = "CANCEL";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.69 * safezoneH + safezoneY;
            w = 0.10 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.6, 0.2, 0.2, 1};
            action = "closeDialog 0;";
        };
    };
};
