class A3M_ShadowOpsDialog {
    idd = 7050;
    movingEnable = false;
    enableSimulation = true;

    class controlsBackground {
        class MainBackground: HG_RscText {
            idc = -1;
            x = 0.1 * safezoneW + safezoneX;
            y = 0.1 * safezoneH + safezoneY;
            w = 0.8 * safezoneW;
            h = 0.8 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.95};
        };
        class Header: HG_RscText {
            idc = -1;
            text = "A3M SHADOW OPERATIONS - CLASSIFIED TERMINAL";
            x = 0.1 * safezoneW + safezoneX;
            y = 0.1 * safezoneH + safezoneY;
            w = 0.8 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
            colorText[] = {1, 1, 1, 1};
            sizeEx = 0.05;
        };
    };

    class controls {
        class MissionList: HG_RscListBox {
            idc = 7052;
            x = 0.12 * safezoneW + safezoneX;
            y = 0.18 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.3 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.8};
            onLBSelChanged = "_this call A3M_fnc_onShadowOpsMissionSelected;";
        };
        class MissionDetails: HG_RscStructuredText {
            idc = 7053;
            x = 0.12 * safezoneW + safezoneX;
            y = 0.5 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.3 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
            text = "<t align='center'><br/>Select a contract to view details.</t>";
        };
        
        // --- ASSET REQUISITION CATALOG ---
        class AssetCatalogText: HG_RscText {
            idc = -1;
            text = "AVAILABLE ASSETS";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.16 * safezoneH + safezoneY;
            w = 0.2 * safezoneW;
            h = 0.03 * safezoneH;
        };
        class AssetCatalogList: HG_RscListBox {
            idc = 7059;
            x = 0.36 * safezoneW + safezoneX;
            y = 0.19 * safezoneH + safezoneY;
            w = 0.2 * safezoneW;
            h = 0.2 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.8};
            sizeEx = 0.03;
        };
        
        class BtnAddAsset: HG_RscButton {
            idc = 7060;
            text = "ADD TO CART ->";
            x = 0.40 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.12 * safezoneW;
            h = 0.03 * safezoneH;
            action = "[] call A3M_fnc_shadowOpsAddAsset;";
        };
        class BtnRemoveAsset: HG_RscButton {
            idc = 7061;
            text = "<- REMOVE";
            x = 0.40 * safezoneW + safezoneX;
            y = 0.44 * safezoneH + safezoneY;
            w = 0.12 * safezoneW;
            h = 0.03 * safezoneH;
            action = "[] call A3M_fnc_shadowOpsRemoveAsset;";
        };
        
        class PurchasedAssetsText: HG_RscText {
            idc = -1;
            text = "PURCHASED ASSETS (CART)";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.48 * safezoneH + safezoneY;
            w = 0.2 * safezoneW;
            h = 0.03 * safezoneH;
        };
        class PurchasedAssetsList: HG_RscListBox {
            idc = 7062;
            x = 0.36 * safezoneW + safezoneX;
            y = 0.51 * safezoneH + safezoneY;
            w = 0.2 * safezoneW;
            h = 0.15 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.8};
            sizeEx = 0.03;
        };
        
        class OperationalPlanDetails: HG_RscStructuredText {
            idc = 7063;
            x = 0.36 * safezoneW + safezoneX;
            y = 0.67 * safezoneH + safezoneY;
            w = 0.2 * safezoneW;
            h = 0.2 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.5};
            text = "<t align='center'>Select an operation.</t>";
        };

        // --- SQUAD ASSIGNMENT ---
        class AvailableRosterText: HG_RscText {
            idc = -1;
            text = "STOWED ROSTER";
            x = 0.6 * safezoneW + safezoneX;
            y = 0.16 * safezoneH + safezoneY;
            w = 0.12 * safezoneW;
            h = 0.03 * safezoneH;
        };
        class AvailableRosterList: HG_RscListBox {
            idc = 7066;
            x = 0.6 * safezoneW + safezoneX;
            y = 0.19 * safezoneH + safezoneY;
            w = 0.12 * safezoneW;
            h = 0.4 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.8};
            sizeEx = 0.035;
        };
        
        class BtnAssign: HG_RscButton {
            idc = -1;
            text = "ASSIGN ->";
            x = 0.73 * safezoneW + safezoneX;
            y = 0.3 * safezoneH + safezoneY;
            w = 0.06 * safezoneW;
            h = 0.04 * safezoneH;
            action = "[] call A3M_fnc_shadowOpsAddMerc;";
        };
        class BtnUnassign: HG_RscButton {
            idc = -1;
            text = "<- REMOVE";
            x = 0.73 * safezoneW + safezoneX;
            y = 0.35 * safezoneH + safezoneY;
            w = 0.06 * safezoneW;
            h = 0.04 * safezoneH;
            action = "[] call A3M_fnc_shadowOpsRemoveMerc;";
        };
        
        class AssignedRosterText: HG_RscText {
            idc = -1;
            text = "ASSIGNED TO OPERATION";
            x = 0.8 * safezoneW + safezoneX;
            y = 0.16 * safezoneH + safezoneY;
            w = 0.15 * safezoneW;
            h = 0.03 * safezoneH;
        };
        class AssignedRosterList: HG_RscListBox {
            idc = 7067;
            x = 0.8 * safezoneW + safezoneX;
            y = 0.19 * safezoneH + safezoneY;
            w = 0.08 * safezoneW;
            h = 0.4 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.8};
            sizeEx = 0.035;
            onLBSelChanged = "[] call A3M_fnc_onShadowOpsPlanChanged;";
        };
        
        class BtnCalcImpact: HG_RscButton {
            idc = -1;
            text = "CALCULATE IMPACT";
            x = 0.6 * safezoneW + safezoneX;
            y = 0.6 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.2, 0.6, 0.2, 1};
            action = "[] call A3M_fnc_onShadowOpsPlanChanged;";
        };

        class BtnDispatch: HG_RscButton {
            idc = 7064;
            text = "DISPATCH SQUAD (INITIATE OPERATION)";
            x = 0.6 * safezoneW + safezoneX;
            y = 0.7 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.08 * safezoneH;
            colorBackground[] = {0.6, 0.1, 0.1, 1};
            sizeEx = 0.05;
            action = "[] call A3M_fnc_shadowOpsDispatch;";
        };

        class BtnClose: HG_RscButton {
            idc = -1;
            text = "CLOSE";
            x = 0.82 * safezoneW + safezoneX;
            y = 0.82 * safezoneH + safezoneY;
            w = 0.06 * safezoneW;
            h = 0.04 * safezoneH;
            action = "closeDialog 0;";
        };
    };
};
