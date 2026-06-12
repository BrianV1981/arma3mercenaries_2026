class A3M_SectorControl {
    tag = "A3M";
    class SectorControlSystem {
        file = "arma3mercenaries\sector_control";
        class initSectorControl { postInit = 0; };
    };
    class SectorControlReward {
        file = "arma3mercenaries\sector_control\reward";
        class manageSectorsTick {};
        class processAIQueue {};
    };
    class SectorControlSpawn {
        file = "arma3mercenaries\sector_control\spawn";
        class spawnSectorControlUnitsTick {};
    };
};