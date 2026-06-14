    //emergency store that is in the ace self interact menu
	//buyables set/store:
    class supplyDropStore_1 {
		
		class supplyDrops_1 {
            displayname = "Emergency Supply Drops";
            kindOf = "other";

				class C_IDAP_supplyCrate_F {
                displayName = "Medical Suppply Drop";
                description = "This is an emergency supply drop of medical and other essential items such as zip ties, respawn camps, backpack ladders, water, and rations.";
                price = 10000;
                amount = 1;
                stock = 9999;
				code = ["C_IDAP_supplyCrate_F", _this select 0, [], [], [["ACE_personalAidKit",5],["ACE_bloodIV",25],["ACE_bloodIV_500",25],["ACE_bloodIV_250",25],["ACE_epinephrine",25],["ACE_morphine",25],["ACE_fieldDressing",100],["ACE_Splint",25],["ACE_Humanitarian_Ration",25],["ACE_Canteen",25],["ACE_EarPlugs",50],["ACE_CableTie",100],["ACE_EntrenchingTool",5],["ACE_Clacker",5],["ACE_DefusalKit",5],["ACE_TacticalLadder_Pack",5],["B_Respawn_TentDome_F",5]]] spawn A3M_fnc_initSupplyDrop;
            };
			
			class Box_NATO_Equip_F {
                displayName = "Drone Suppply Drop";
                description = "This is an emergency supply drop of NATO drone backpacks and batteries";
                price = 25000;
                amount = 1;
                stock = 9999;
				code = ["Box_NATO_Equip_F", _this select 0, [], [], [["B_UAV_01_backpack_F",2],["B_UAV_06_medical_backpack_F",1],["B_UAV_06_backpack_F",1],["B_UGV_02_Demining_backpack_F",1],["B_UGV_02_Science_backpack_F",1],["ACE_UAVBattery",20]]] spawn A3M_fnc_initSupplyDrop;
            };

			class Box_NATO_Equip_F_Combat {
                displayName = "Combat Drone Suppply Drop";
                description = "This is an emergency supply drop of 10 NATO Darter drones, UAV terminals, batteries, and a vast assortment of explosive payloads intended for aerial delivery.";
                price = 80000;
                amount = 1;
                stock = 9999;
				code = ["Box_NATO_Equip_F", _this select 0, [], [["HandGrenade", 10], ["MiniGrenade", 10], ["ACE_M14", 10], ["DemoCharge_Remote_Mag", 5], ["SatchelCharge_Remote_Mag", 2]], [["B_UAV_01_backpack_F", 10], ["B_UavTerminal", 2], ["ACE_UAVBattery", 20]]] spawn A3M_fnc_initSupplyDrop;
            };

			class Box_NATO_WpsSpecial_F {
                displayName = "Titan AT Suppply Drop";
                description = "This is an emergency supply drop of 20 Titan AT missles.";
                price = 50000;
                amount = 1;
                stock = 9999;
				code = ["Box_NATO_WpsSpecial_F", _this select 0, [], [["Titan_AT",20]], []] spawn A3M_fnc_initSupplyDrop;
            };
			
			class Box_IND_WpsSpecial_F {
                displayName = "Titan AA Suppply Drop";
                description = "This is an emergency supply drop of 20 Titan AA missles.";
                price = 50000;
                amount = 1;
                stock = 9999;
				code = ["Box_IND_WpsSpecial_F", _this select 0, [], [["Titan_AA",20]], []] spawn A3M_fnc_initSupplyDrop;
            };
			
			class B_CargoNet_01_ammo_F {
                displayName = "Titan Suppply Drop";
                description = "This is an emergency supply drop of Titan AA/AT launchers and missles.";
                price = 300000;
                amount = 1;
                stock = 9999;
				code = ["B_CargoNet_01_ammo_F", _this select 0, [], [["Titan_AT",40],["Titan_AA",40]], [["launch_B_Titan_short_F",5],["launch_B_Titan_F",5]]] spawn A3M_fnc_initSupplyDrop;
            };
			
			class B_Slingload_01_Cargo_F {
                displayName = "Advanced FOB Suppply Drop";
                description = "This is an emergency supply drop of an advaced FOB.";
                price = 500000;
                amount = 1;
                stock = 9999;
				code = ["B_Slingload_01_Cargo_F", _this select 0, [["ACE_ConcertinaWireCoil",20],["Land_HBarrier_5_F",10],["Land_HBarrierWall6_F",10],["Land_HBarrierWall_corner_F",8],["Land_CncWall4_F",30],["Land_BagBunker_Small_F",4],["Land_BagBunker_Tower_F",2],["ACE_TacticalLadder",4],["Land_TentLamp_01_standing_F",20],["Flag_US_F",1],["Flag_POWMIA_F",1],["WaterPump_01_forest_F",1],["Land_WoodenCrate_01_F",2],["CargoNet_01_box_F",5],["ACE_medicalSupplyCrate",4],["Land_PaperBox_01_small_closed_brown_food_F",4],["Land_PaperBox_01_small_closed_brown_F",2],["ACE_Box_Chemlights",2],["Box_Wps_F",2],["Land_RoadBarrier_01_F",2],["Land_HelipadCircle_F",1],["Land_BagFence_Round_F",20],["Land_BagFence_Long_F",20],["Land_CzechHedgehog_01_new_F",20],["Land_RepairDepot_01_green_F",1],["B_Slingload_01_Medevac_F",1],["B_Slingload_01_Fuel_F",1],["B_Slingload_01_Ammo_F",1]], [], []] spawn A3M_fnc_initSupplyDrop;
            };
			
			
		};   
	};