class A3M_SquadReorganizerDialog {
    idd = 7050;
    movingEnable = false;
    enableSimulation = 1;

    class controlsBackground {
        class MainBackground: HG_RscText {
            idc = -1;
            x = 0.2 * safezoneW + safezoneX;
            y = 0.2 * safezoneH + safezoneY;
            w = 0.6 * safezoneW;
            h = 0.6 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.9};
        };
        class HeaderBackground: HG_RscText {
            idc = -1;
            x = 0.2 * safezoneW + safezoneX;
            y = 0.2 * safezoneH + safezoneY;
            w = 0.6 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
        };
    };

    class controls {
        class TitleText: HG_RscText {
            idc = 7051;
            text = "SQUAD COMMAND AND REORGANIZER";
            x = 0.2 * safezoneW + safezoneX;
            y = 0.2 * safezoneH + safezoneY;
            w = 0.6 * safezoneW;
            h = 0.05 * safezoneH;
            colorText[] = {1, 1, 1, 1};
            sizeEx = 0.05;
            style = 2; // Center
        };

        class CloseButton: HG_RscButton {
            idc = -1;
            text = "X";
            x = 0.77 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.02 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.8, 0, 0, 1};
            action = "closeDialog 0;";
        };

        class SquadList: HG_RscListBox {
            idc = 7052;
            x = 0.22 * safezoneW + safezoneX;
            y = 0.27 * safezoneH + safezoneY;
            w = 0.3 * safezoneW;
            h = 0.45 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.035;
        };

        class UpButton: HG_RscButton {
            idc = 7053;
            text = "MOVE UP";
            x = 0.22 * safezoneW + safezoneX;
            y = 0.73 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
            action = "['UP'] spawn A3M_fnc_squadReorganizerMove;";
        };

        class DownButton: HG_RscButton {
            idc = 7054;
            text = "MOVE DOWN";
            x = 0.38 * safezoneW + safezoneX;
            y = 0.73 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
            action = "['DOWN'] spawn A3M_fnc_squadReorganizerMove;";
        };

        class RebuildButton: HG_RscButton {
            idc = 7055;
            text = "APPLY & REBUILD SQUAD";
            x = 0.55 * safezoneW + safezoneX;
            y = 0.73 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0, 0.6, 0, 1};
            action = "[] spawn A3M_fnc_squadReorganizerApply;";
        };
        
        // Command buttons
        class CmdRecall: HG_RscButton {
            idc = 7060;
            text = "RECALL SQUAD (TELEPORT)";
            x = 0.55 * safezoneW + safezoneX;
            y = 0.27 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.1, 0.3, 0.5, 1};
            action = "execVM 'arma3mercenaries\group_teleport\groupTeleport.sqf'; closeDialog 0;";
        };
        
        class CmdStandDown: HG_RscButton {
            idc = 7061;
            text = "STAND DOWN (DEACTIVATE)";
            x = 0.55 * safezoneW + safezoneX;
            y = 0.32 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.5, 0.1, 0.1, 1};
            action = "execVM 'arma3mercenaries\set_group_captive\setGroupCaptive_proofOfConcept.sqf'; closeDialog 0;";
        };
        
        class CmdMobilize: HG_RscButton {
            idc = 7062;
            text = "MOBILIZE (REACTIVATE)";
            x = 0.55 * safezoneW + safezoneX;
            y = 0.37 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.1, 0.5, 0.1, 1};
            action = "execVM 'arma3mercenaries\set_group_captive\groupRejoin_proofOfConcept.sqf'; closeDialog 0;";
        };

        class CmdTurrets: HG_RscButton {
            idc = 7063;
            text = "SECURE BASE TURRETS (50m)";
            x = 0.55 * safezoneW + safezoneX;
            y = 0.42 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.4, 0.4, 0.1, 1};
            action = "[50] execVM 'arma3mercenaries\set_group_captive\groupMountTurrets.sqf'; closeDialog 0;";
        };

        class CmdReform: HG_RscButton {
            idc = 7064;
            text = "REFORM SQUAD (RESET BRAIN)";
            x = 0.55 * safezoneW + safezoneX;
            y = 0.47 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.4, 0.2, 0.6, 1};
            action = "execVM 'arma3mercenaries\set_group_captive\squadReform.sqf'; closeDialog 0;";
        };
        
        class HintText: HG_RscStructuredText {
            idc = -1;
            text = "<t size='0.8' color='#aaffaa'>Adjust your squad's order here. The F-key mapping (F2, F3, F4, etc.) will be updated to match this list from top to bottom when you Apply &amp; Rebuild.</t>";
            x = 0.55 * safezoneW + safezoneX;
            y = 0.55 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.16 * safezoneH;
        };
    };
};
