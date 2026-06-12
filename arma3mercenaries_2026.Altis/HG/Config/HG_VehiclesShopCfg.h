/*
    HG_VehiclesShopCfg.h
    Overhauled for A3M by A.I.M.
    Mirrored exactly from grad-listBuymenu (vehicleStoreMenu_1.hpp)
*/

class HG_DefaultShop 
{
    conditionToAccess = "true";

    class Rvehicles
    {
        displayName = "Automobiles and Recreational Vehicles";
        vehicles[] =
        {
            {"C_Kart_01_black_F", 0, "true"},
            {"B_Quadbike_01_F", 0, "true"},
            {"C_Hatchback_01_sport_F", 4000, "true"},
            {"I_C_Offroad_02_unarmed_F", 6000, "true"},
            {"C_SUV_01_F", 8000, "true"},
            {"I_E_Offroad_01_F", 8000, "true"},
            {"I_E_Offroad_01_covered_F", 8000, "true"},
            {"I_E_Offroad_01_comms_F", 8000, "true"},
            {"I_C_Van_02_transport_F", 10000, "true"},
            {"I_C_Van_02_vehicle_F", 10000, "true"},
            {"C_Van_01_box_F", 13000, "true"},
            {"C_Tractor_01_F", 5000, "true"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class Svehicles
    {
        displayName = "Support Vehicles";
        vehicles[] =
        {
            {"I_C_Van_01_transport_F", 13000, "true"},
            {"I_E_Van_02_medevac_F", 15000, "true"},
            {"B_G_Van_01_fuel_F", 15000, "true"},
            {"B_G_Offroad_01_repair_F", 50000, "true"},
            {"I_Truck_02_covered_F", 125000, "true"},
            {"I_Truck_02_medical_F", 150000, "true"},
            {"C_IDAP_Truck_02_water_F", 150000, "true"},
            {"I_Truck_02_fuel_F", 150000, "true"},
            {"I_Truck_02_box_F", 150000, "true"},
            {"I_Truck_02_ammo_F", 175000, "true"},
            {"B_Truck_01_mover_F", 200000, "true"},
            {"B_Truck_01_flatbed_F", 200000, "true"},
            {"B_Truck_01_cargo_F", 200000, "true"},
            {"B_Truck_01_box_F", 200000, "true"},
            {"B_Truck_01_transport_F", 200000, "true"},
            {"B_Truck_01_covered_F", 200000, "true"},
            {"B_Truck_01_medical_F", 225000, "true"},
            {"B_Truck_01_fuel_F", 225000, "true"},
            {"B_Truck_01_Repair_F", 225000, "true"},
            {"B_Truck_01_ammo_F", 250000, "true"},
            {"O_T_Truck_03_transport_ghex_F", 250000, "true"},
            {"O_T_Truck_03_covered_ghex_F", 250000, "true"},
            {"O_T_Truck_03_medical_ghex_F", 275000, "true"},
            {"O_T_Truck_03_repair_ghex_F", 275000, "true"},
            {"O_T_Truck_03_ammo_ghex_F", 300000, "true"},
            {"B_APC_Tracked_01_CRV_F", 475000, "true"},
            {"B_T_APC_Tracked_01_CRV_F", 575000, "true"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class Cvehicles
    {
        displayName = "Combat Vehicles";
        vehicles[] =
        {
            {"I_C_Offroad_02_LMG_F", 20000, "true"},
            {"B_G_Offroad_01_armed_F", 20000, "true"},
            {"I_C_Offroad_02_AT_F", 30000, "true"},
            {"B_G_Offroad_01_AT_F", 30000, "true"},
            {"O_T_LSV_02_unarmed_F", 150000, "true"},
            {"B_T_LSV_01_unarmed_F", 150000, "true"},
            {"O_T_LSV_02_armed_F", 175000, "true"},
            {"B_LSV_01_armed_F", 175000, "true"},
            {"O_T_LSV_02_AT_F", 190000, "true"},
            {"B_T_LSV_01_AT_F", 190000, "true"},
            {"B_MRAP_01_F", 190000, "true"},
            {"O_MRAP_02_F", 190000, "true"},
            {"I_MRAP_03_F", 190000, "true"},
            {"B_MRAP_01_hmg_F", 225000, "true"},
            {"O_MRAP_02_hmg_F", 225000, "true"},
            {"I_MRAP_03_hmg_F", 225000, "true"},
            {"B_MRAP_01_gmg_F", 250000, "true"},
            {"O_MRAP_02_gmg_F", 250000, "true"},
            {"I_MRAP_03_gmg_F", 250000, "true"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class LAvehicles
    {
        displayName = "Light Armored Vehicles";
        vehicles[] =
        {
            {"I_LT_01_scout_F", 300000, "true"},
            {"I_LT_01_AT_F", 350000, "true"},
            {"I_LT_01_AA_F", 350000, "true"},
            {"B_APC_Wheeled_03_cannon_F", 420000, "true"},
            {"O_APC_Wheeled_02_rcws_v2_F", 420000, "true"},
            {"B_APC_Wheeled_01_cannon_F", 420000, "true"},
            {"B_T_APC_Wheeled_01_cannon_F", 520000, "true"},
            {"B_AFV_Wheeled_01_cannon_F", 450000, "true"},
            {"B_T_AFV_Wheeled_01_cannon_F", 550000, "true"},
            {"B_AFV_Wheeled_01_up_cannon_F", 475000, "true"},
            {"B_T_AFV_Wheeled_01_up_cannon_F", 575000, "true"},
            {"B_APC_Tracked_01_rcws_F", 440000, "true"},
            {"B_T_APC_Tracked_01_rcws_F", 540000, "true"},
            {"O_APC_Tracked_02_cannon_F", 440000, "true"},
            {"O_APC_Tracked_02_AA_F", 440000, "true"},
            {"I_APC_tracked_03_cannon_F", 440000, "true"},
            {"B_APC_Tracked_01_AA_F", 500000, "true"},
            {"B_T_APC_Tracked_01_AA_F", 600000, "true"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class HAvehicles
    {
        displayName = "Heavy Armored Vehicles";
        vehicles[] =
        {
            {"I_MBT_03_cannon_F", 560000, "true"},
            {"O_MBT_02_cannon_F", 575000, "true"},
            {"B_MBT_01_cannon_F", 600000, "true"},
            {"B_T_MBT_01_cannon_F", 700000, "true"},
            {"O_MBT_04_cannon_F", 625000, "true"},
            {"B_MBT_01_TUSK_F", 650000, "true"},
            {"B_T_MBT_01_TUSK_F", 750000, "true"},
            {"O_MBT_04_command_F", 675000, "true"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class AAvehicles
    {
        displayName = "Artillery Vehicles";
        vehicles[] =
        {
            {"I_Truck_02_MRL_F", 400000, "true"},
            {"B_MBT_01_mlrs_F", 600000, "true"},
            {"B_T_MBT_01_mlrs_F", 700000, "true"},
            {"B_MBT_01_arty_F", 700000, "true"},
            {"B_T_MBT_01_arty_F", 800000, "true"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class Avehicles
    {
        displayName = "Fixed-Wing and VTOL Aircraft";
        vehicles[] =
        {
            {"B_T_VTOL_01_infantry_F", 400000, "true"},
            {"B_T_VTOL_01_infantry_olive_F", 500000, "true"},
            {"B_T_VTOL_01_armed_F", 420000, "true"},
            {"B_T_VTOL_01_armed_olive_F", 520000, "true"},
            {"I_C_Plane_Civil_01_F", 50000, "true"},
            {"I_Plane_Fighter_04_F", 500000, "true"},
            {"I_Plane_Fighter_03_dynamicLoadout_F", 600000, "true"},
            {"O_Plane_Fighter_02_F", 650000, "true"},
            {"B_Plane_Fighter_01_F", 650000, "true"},
            {"O_Plane_CAS_02_dynamicLoadout_F", 650000, "true"},
            {"B_Plane_CAS_01_dynamicLoadout_F", 650000, "true"},
            {"O_Plane_Fighter_02_Stealth_F", 700000, "true"},
            {"B_Plane_Fighter_01_Stealth_F", 700000, "true"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class Hvehicles
    {
        displayName = "Rotary-Wing Aircraft";
        vehicles[] =
        {
            {"I_C_Heli_Light_01_civil_F", 50000, "true"},
            {"B_Heli_Light_01_stripped_F", 75000, "true"},
            {"B_Heli_Light_01_F", 150000, "true"},
            {"B_Heli_Light_01_dynamicLoadout_F", 200000, "true"},
            {"I_Heli_light_03_unarmed_F", 200000, "true"},
            {"O_Heli_Light_02_unarmed_F", 200000, "true"},
            {"I_Heli_light_03_dynamicLoadout_F", 300000, "true"},
            {"O_Heli_Light_02_dynamicLoadout_F", 300000, "true"},
            {"B_Heli_Transport_01_F", 350000, "true"},
            {"B_Heli_Transport_01_camo_F", 450000, "true"},
            {"I_Heli_Transport_02_F", 350000, "true"},
            {"B_Heli_Transport_03_unarmed_green_F", 350000, "true"},
            {"O_Heli_Transport_04_F", 350000, "true"},
            {"B_Heli_Transport_03_F", 400000, "true"},
            {"B_Heli_Attack_01_dynamicLoadout_F", 525000, "true"},
            {"O_Heli_Attack_02_dynamicLoadout_F", 575000, "true"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class NDunits
    {
        displayName = "NDunits";
        vehicles[] =
        {
            {"B_UavTerminal", 10000, "true"},
            {"ACE_UAVBattery", 100, "true"},
            {"B_UAV_01_F", 5000, "true"},
            {"B_UAV_06_F", 5000, "true"},
            {"B_UAV_06_medical_F", 5000, "true"},
            {"B_UAV_02_dynamicLoadout_F", 500000, "true"},
            {"B_UAV_05_F", 500000, "true"},
            {"B_UGV_02_Science_F", 5000, "true"},
            {"B_UGV_02_Demining_F", 10000, "true"},
            {"B_UGV_01_F", 10000, "true"},
            {"B_UGV_01_rcws_F", 50000, "true"},
            {"B_T_UAV_03_dynamicLoadout_F", 100000, "true"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class IDunits
    {
        displayName = "IDunits";
        vehicles[] =
        {
            {"I_UavTerminal", 10000, "true"},
            {"ACE_UAVBattery", 100, "true"},
            {"I_UAV_01_F", 5000, "true"},
            {"I_UAV_06_F", 5000, "true"},
            {"I_UAV_06_medical_F", 5000, "true"},
            {"I_UAV_02_dynamicLoadout_F", 500000, "true"},
            {"I_UGV_02_Science_F", 5000, "true"},
            {"I_UGV_02_Demining_F", 10000, "true"},
            {"I_E_UGV_01_F", 10000, "true"},
            {"I_E_UGV_01_rcws_F", 50000, "true"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };
};
