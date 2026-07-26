class A3M_SquadReorganizerDialog {
    idd = 7050;
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
            idc = 7051;
            text = "SQUAD COMMAND AND REORGANIZER";
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
            action = "closeDialog 0;";
        };

        // --- SQUAD REORGANIZER (LEFT SIDE) ---
        class SquadList: HG_RscListBox {
            idc = 7052;
            x = 0.12 * safezoneW + safezoneX;
            y = 0.17 * safezoneH + safezoneY;
            w = 0.25 * safezoneW;
            h = 0.55 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.035;
        };

        class UpButton: HG_RscButton {
            idc = 7053;
            text = "MOVE UP";
            x = 0.12 * safezoneW + safezoneX;
            y = 0.74 * safezoneH + safezoneY;
            w = 0.12 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
            action = "['UP'] spawn A3M_fnc_squadReorganizerMove;";
        };

        class DownButton: HG_RscButton {
            idc = 7054;
            text = "MOVE DOWN";
            x = 0.25 * safezoneW + safezoneX;
            y = 0.74 * safezoneH + safezoneY;
            w = 0.12 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
            action = "['DOWN'] spawn A3M_fnc_squadReorganizerMove;";
        };

        class RebuildButton: HG_RscButton {
            idc = 7055;
            text = "APPLY & REBUILD SQUAD";
            x = 0.12 * safezoneW + safezoneX;
            y = 0.80 * safezoneH + safezoneY;
            w = 0.25 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = {0, 0.6, 0, 1};
            action = "[] spawn A3M_fnc_squadReorganizerApply;";
        };
        
        // --- SQUAD COMMANDS (RIGHT SIDE) ---
        // 1. RECALL
        class CmdRecall: HG_RscButton {
            idc = 7060;
            text = "RECALL SQUAD";
            x = 0.40 * safezoneW + safezoneX;
            y = 0.17 * safezoneH + safezoneY;
            w = 0.16 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.1, 0.3, 0.5, 1};
            action = "execVM 'arma3mercenaries\group_teleport\groupTeleport.sqf';";
        };
        class TxtRecall: HG_RscStructuredText {
            idc = -1;
            text = "<t size='0.8' color='#ffffff'>Executes groupTeleport.sqf. Generates a confirmation prompt, finds a safe location within 150m of the player, teleports all AI to that exact position, renders a 3D UI marker for 30s, and immediately triggers squadReform.sqf to flush their command buffer.</t>";
            x = 0.57 * safezoneW + safezoneX;
            y = 0.17 * safezoneH + safezoneY;
            w = 0.31 * safezoneW;
            h = 0.10 * safezoneH;
        };
        
        // 2. STAND DOWN
        class CmdStandDown: HG_RscButton {
            idc = 7061;
            text = "STAND DOWN";
            x = 0.40 * safezoneW + safezoneX;
            y = 0.28 * safezoneH + safezoneY;
            w = 0.16 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.5, 0.1, 0.1, 1};
            action = "execVM 'arma3mercenaries\set_group_captive\setGroupCaptive_proofOfConcept.sqf';";
        };
        class TxtStandDown: HG_RscStructuredText {
            idc = -1;
            text = "<t size='0.8' color='#ffffff'>Executes setGroupCaptive.sqf. Forces AI to dismount vehicles, applies vanilla SQF captive logic (setCaptive true, allowDamage false), disables their AI processing (disableAI 'ALL'), sets the A3M activation variable, and applies ACE handcuffs.</t>";
            x = 0.57 * safezoneW + safezoneX;
            y = 0.28 * safezoneH + safezoneY;
            w = 0.31 * safezoneW;
            h = 0.10 * safezoneH;
        };
        
        // 3. MOBILIZE
        class CmdMobilize: HG_RscButton {
            idc = 7062;
            text = "MOBILIZE";
            x = 0.40 * safezoneW + safezoneX;
            y = 0.39 * safezoneH + safezoneY;
            w = 0.16 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.1, 0.5, 0.1, 1};
            action = "execVM 'arma3mercenaries\set_group_captive\groupRejoin_proofOfConcept.sqf';";
        };
        class TxtMobilize: HG_RscStructuredText {
            idc = -1;
            text = "<t size='0.8' color='#ffffff'>Executes groupRejoin.sqf. Removes ACE handcuffs, clears vanilla SQF captive status, restores damage processing, clears the A3M activation variable, and reactivates all AI engine states using enableAI 'ALL'.</t>";
            x = 0.57 * safezoneW + safezoneX;
            y = 0.39 * safezoneH + safezoneY;
            w = 0.31 * safezoneW;
            h = 0.10 * safezoneH;
        };

        // 4. QUICK LOAD
        class CmdQuickLoad: HG_RscButton {
            idc = 7063;
            text = "QUICK LOAD (5m)";
            x = 0.40 * safezoneW + safezoneX;
            y = 0.50 * safezoneH + safezoneY;
            w = 0.16 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.4, 0.4, 0.1, 1};
            action = "[5] execVM 'arma3mercenaries\set_group_captive\groupMountTurrets.sqf';";
        };
        class TxtQuickLoad: HG_RscStructuredText {
            idc = -1;
            text = "<t size='0.8' color='#ffffff'>Executes groupMountTurrets.sqf [5m]. Mobilizes AI, scans a 5m radius for unlocked/owned vehicles or static weapons, and issues moveIn commands prioritizing Gunner, Commander, and Turret seats over Driver and Cargo.</t>";
            x = 0.57 * safezoneW + safezoneX;
            y = 0.50 * safezoneH + safezoneY;
            w = 0.31 * safezoneW;
            h = 0.10 * safezoneH;
        };

        // 5. SECURE BASE TURRETS
        class CmdTurrets: HG_RscButton {
            idc = 7064;
            text = "SECURE BASE (50m)";
            x = 0.40 * safezoneW + safezoneX;
            y = 0.61 * safezoneH + safezoneY;
            w = 0.16 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.4, 0.3, 0.1, 1};
            action = "[50] execVM 'arma3mercenaries\set_group_captive\groupMountTurrets.sqf';";
        };
        class TxtTurrets: HG_RscStructuredText {
            idc = -1;
            text = "<t size='0.8' color='#ffffff'>Executes groupMountTurrets.sqf [50m]. Scans a massive 50m radius. Automatically forces all mobilized AI squad members to rapidly man any empty base defenses, mortars, or static weapons in the FOB.</t>";
            x = 0.57 * safezoneW + safezoneX;
            y = 0.61 * safezoneH + safezoneY;
            w = 0.31 * safezoneW;
            h = 0.10 * safezoneH;
        };

        // 6. REFORM SQUAD
        class CmdReform: HG_RscButton {
            idc = 7065;
            text = "REFORM SQUAD";
            x = 0.40 * safezoneW + safezoneX;
            y = 0.72 * safezoneH + safezoneY;
            w = 0.16 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.4, 0.2, 0.6, 1};
            action = "execVM 'arma3mercenaries\set_group_captive\squadReform.sqf';";
        };
        class TxtReform: HG_RscStructuredText {
            idc = -1;
            text = "<t size='0.8' color='#ffffff'>Executes squadReform.sqf. Creates a new Arma 3 group, forcefully joins all AI to it via joinSilent under player leadership, temporarily disables AI targeting to flush their buffer, forces a doFollow, and deletes the glitched group.</t>";
            x = 0.57 * safezoneW + safezoneX;
            y = 0.72 * safezoneH + safezoneY;
            w = 0.31 * safezoneW;
            h = 0.10 * safezoneH;
        };
    };
};
