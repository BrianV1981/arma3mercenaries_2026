// File: arma3mercenaries\barracks\a3m_shadowOps_dialog.hpp

class A3M_ShadowOpsDialog {
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
            colorBackground[] = {0.1, 0.1, 0.1, 0.95};
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
            idc = -1; text = "AVAILABLE CONTRACTS";
            x = 0.12 * safezoneW + safezoneX; y = 0.16 * safezoneH + safezoneY;
            w = 0.22 * safezoneW; h = 0.03 * safezoneH;
            colorText[] = {0.8, 0.8, 0.8, 1}; sizeEx = 0.04;
        };

        class Col2Header: HG_RscText {
            idc = -1; text = "ASSET REQUISITION";
            x = 0.35 * safezoneW + safezoneX; y = 0.16 * safezoneH + safezoneY;
            w = 0.22 * safezoneW; h = 0.03 * safezoneH;
            colorText[] = {0.8, 0.8, 0.8, 1}; sizeEx = 0.04;
        };
        
        class Col3HeaderAvailable: HG_RscText {
            idc = -1; text = "STOWED AI";
            x = 0.58 * safezoneW + safezoneX; y = 0.16 * safezoneH + safezoneY;
            w = 0.13 * safezoneW; h = 0.03 * safezoneH;
            colorText[] = {0.8, 0.8, 0.8, 1}; sizeEx = 0.04;
        };

        class Col3HeaderSelected: HG_RscText {
            idc = -1; text = "SQUAD ASSIGNED";
            x = 0.75 * safezoneW + safezoneX; y = 0.16 * safezoneH + safezoneY;
            w = 0.13 * safezoneW; h = 0.03 * safezoneH;
            colorText[] = {0.0, 0.8, 0.0, 1}; sizeEx = 0.04;
        };
    };

    class controls {
        class TitleText: HG_RscText {
            idc = 7051;
            text = "SHADOW OPERATIONS TERMINAL";
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

        class ReturnToDossierButton: HG_RscButton {
            idc = -1;
            text = "PLAYER DOSSIER";
            x = 0.11 * safezoneW + safezoneX;
            y = 0.105 * safezoneH + safezoneY;
            w = 0.10 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.2, 0.4, 0.6, 1};
            action = "closeDialog 0; [] spawn { waitUntil {isNull (findDisplay 7050)}; [] call A3M_fnc_openPlayerCard; };";
        };

        class ReturnToBarracksButton: HG_RscButton {
            idc = -1;
            text = "SQUAD BARRACKS";
            x = 0.22 * safezoneW + safezoneX;
            y = 0.105 * safezoneH + safezoneY;
            w = 0.10 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.2, 0.4, 0.6, 1};
            action = "closeDialog 0; [] spawn { waitUntil {isNull (findDisplay 7050)}; [] call A3M_fnc_openSquadDossier; };";
        };

        // Available Missions List (Left Top)
        class MissionList: HG_RscListBox {
            idc = 7052;
            x = 0.12 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.25 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.035;
            onLBSelChanged = "_this call A3M_fnc_onShadowOpsMissionSelected;";
        };

        // Mission Briefing Box (Left Bottom)
        class MissionDetailsBackground: HG_RscText {
            idc = -1;
            x = 0.12 * safezoneW + safezoneX;
            y = 0.46 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.34 * safezoneH;
            colorBackground[] = {0.05, 0.05, 0.05, 1};
        };

        class MissionDetailsText: HG_RscStructuredText {
            idc = 7055;
            text = "<t align='left' size='0.9'>Select a contract to view the classified briefing, forecasted weather conditions, and required class specialists.</t>";
            x = 0.125 * safezoneW + safezoneX;
            y = 0.47 * safezoneH + safezoneY;
            w = 0.21 * safezoneW;
            h = 0.32 * safezoneH;
        };

        // Planning Panel (Middle) - Asset Store
        class AssetCatalogList: HG_RscListBox {
            idc = 7059;
            x = 0.35 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.20 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.035;
        };

        class AddAssetButton: HG_RscButton {
            idc = 7060;
            text = "ADD TO CART";
            x = 0.35 * safezoneW + safezoneX;
            y = 0.41 * safezoneH + safezoneY;
            w = 0.10 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = {0.2, 0.6, 0.2, 1};
            action = "[] call A3M_fnc_shadowOpsAddAsset;";
        };

        class RemoveAssetButton: HG_RscButton {
            idc = 7061;
            text = "REMOVE";
            x = 0.47 * safezoneW + safezoneX;
            y = 0.41 * safezoneH + safezoneY;
            w = 0.10 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = {0.8, 0.2, 0.2, 1};
            action = "[] call A3M_fnc_shadowOpsRemoveAsset;";
        };

        class PurchasedAssetsList: HG_RscListBox {
            idc = 7062;
            x = 0.35 * safezoneW + safezoneX;
            y = 0.45 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.13 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.035;
        };

        class CalculateButton: HG_RscButton {
            idc = 7064;
            text = "CALCULATE IMPACT";
            x = 0.35 * safezoneW + safezoneX;
            y = 0.59 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = {0.0, 0.4, 0.8, 1};
            action = "[] call A3M_fnc_onShadowOpsPlanChanged;";
        };

        class PlanDetailsBackground: HG_RscText {
            idc = -1;
            x = 0.35 * safezoneW + safezoneX;
            y = 0.63 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.17 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
        };

        class PlanDetailsText: HG_RscStructuredText {
            idc = 7063;
            text = "<t align='center'><br/>Click 'CALCULATE IMPACT' to view strategic tradeoffs.</t>";
            x = 0.355 * safezoneW + safezoneX;
            y = 0.64 * safezoneH + safezoneY;
            w = 0.21 * safezoneW;
            h = 0.15 * safezoneH;
        };

        // Squad Management (Right)
        class AvailableAIList: HG_RscListBox {
            idc = 7053;
            x = 0.58 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.13 * safezoneW;
            h = 0.60 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.035;
        };

        class AddMercButton: HG_RscButton {
            idc = 7065;
            text = ">>";
            x = 0.715 * safezoneW + safezoneX;
            y = 0.45 * safezoneH + safezoneY;
            w = 0.03 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.2, 0.6, 0.2, 1};
            action = "[] call A3M_fnc_shadowOpsAddMerc;";
        };

        class RemoveMercButton: HG_RscButton {
            idc = 7066;
            text = "<<";
            x = 0.715 * safezoneW + safezoneX;
            y = 0.50 * safezoneH + safezoneY;
            w = 0.03 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.8, 0.2, 0.2, 1};
            action = "[] call A3M_fnc_shadowOpsRemoveMerc;";
        };

        class SelectedAIList: HG_RscListBox {
            idc = 7067;
            x = 0.75 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.13 * safezoneW;
            h = 0.60 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
            sizeEx = 0.035;
        };

        // Bottom Dispatch Action
        class DispatchButton: HG_RscButton {
            idc = 7054;
            text = "AUTHORIZE & DISPATCH SQUAD";
            x = 0.35 * safezoneW + safezoneX;
            y = 0.82 * safezoneH + safezoneY;
            w = 0.53 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = {0.6, 0, 0, 1};
            action = "[] spawn A3M_fnc_shadowOpsDispatch;";
        };
    };
};
