class CfgPatches {
    class vulture_core {
        name = "Vulture: Dynamic Wreck Salvage";
        author = "A.I.M. / BrianV1981";
        url = "https://github.com/BrianV1981/arma3mercenaries_2026";
        requiredVersion = 1.60;
        requiredAddons[] = {"cba_main", "ace_interact_menu"};
        units[] = {};
        weapons[] = {};
    };
};

class CfgFunctions {
    class Vulture {
        tag = "Vulture";
        class Core {
            file = "vulture_core\functions";
            class initSalvage {};
            class addSalvageInteraction {};
        };
    };
};

class Extended_PreInit_EventHandlers {
    class vulture_preInit {
        init = "call compile preprocessFileLineNumbers 'vulture_core\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers {
    class vulture_postInit {
        init = "call compile preprocessFileLineNumbers 'vulture_core\XEH_postInit.sqf'";
    };
};
