/*

scripts/Extended_Init_EventHandlers.hpp

 //////GM repair vehicles//////
 class gm_ge_army_fuchsa0_engineer {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetRepairVehicle.sqf') };";
 };
 class gm_dk_army_m113a1dk_engineer {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetRepairVehicle.sqf') };";
 };
 class gm_gc_army_ural4320_repair {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetRepairVehicle.sqf') };";
 };
 class gm_gc_bgs_ural4320_repair {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetRepairVehicle.sqf') };";
 };
 class gm_pl_army_ural4320_repair {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetRepairVehicle.sqf') };";
 };
 class gm_ge_army_u1300l_repair {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetRepairVehicle.sqf') };";
 };
 
 ////////rearm vehicles////////
 class gm_gc_army_ural4320_reammo {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetAmmoVehicle.sqf') };";
 };
 class gm_gc_bgs_ural4320_reammo {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetAmmoVehicle.sqf') };";
 };
 class gm_pl_army_ural4320_reammo {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetAmmoVehicle.sqf') };";
 };
 class gm_ge_army_kat1_451_reammo {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetAmmoVehicle.sqf') };";
 };
 
 //////refuel vehicles///////////
  class gm_gc_army_ural375d_refuel {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetRefuelVehicle.sqf') };";
 };
 class gm_gc_bgs_ural375d_refuel {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetRefuelVehicle.sqf') };";
 };
 class gm_pl_army_ural375d_refuel {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetRefuelVehicle.sqf') };";
 };
 class gm_ge_army_kat1_451_refuel {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetRefuelVehicle.sqf') };";
 };
 
 //////repair, rearm, refuel vehicles///////////
  class gm_dk_army_bpz2a0 {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetRefuelVehicle.sqf'); _this call (compile preprocessFileLineNumbers 'scripts\ACEsetAmmoVehicle.sqf'); _this call (compile preprocessFileLineNumbers 'scripts\ACEsetRepairVehicle.sqf') };";
 };
 class gm_ge_army_bpz2a0 {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\ACEsetRefuelVehicle.sqf'); _this call (compile preprocessFileLineNumbers 'scripts\ACEsetAmmoVehicle.sqf'); _this call (compile preprocessFileLineNumbers 'scripts\ACEsetRepairVehicle.sqf') };";
 };
 
 ///FOBs in a box
 class I_EAF_supplyCrate_F {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\addBasicFOB.sqf') };";
 };
 class I_E_CargoNet_01_ammo_F {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\addAdvancedFOB.sqf') };";
 };
 class Box_EAF_Equip_F {
  init = "if (isServer) then { _this call (compile preprocessFileLineNumbers 'scripts\addBasicRoadBlock.sqf') };";
 };

*/




class Extended_Init_EventHandlers {
 
 /////////////
 
 class A3M_Scoreboard_Init { // Unique classname for your handler
        // This calls the script that sets up server-side event handlers for K/D tracking after CBA is ready
        init = "call compileScript ['arma3mercenaries\scoreboard\XEH_postInit.sqf']";
    };

};