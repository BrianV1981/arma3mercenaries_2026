    //buyables set/store:
    class haloStore_1 {

        //category:  
		class other {
            displayName = "HAHO/HALO Jump";
            kindOf = "Other";

			class B_T_VTOL_01_infantry_F {
                displayName = "HALO/HAHO Solo Jump";
                description = "***WARNING***IT IS RECOMMENDED TO CARRY YOUR BACKPACK WITH ALiVE PLAYER LOGISTICS***When purchased, a HALO option will be added to your ACE Self-Interact menu. Use it to explicitly designate your drop coordinates. In military operations, HALO is also used for delivering equipment, supplies, or personnel, while HAHO is generally used exclusively for personnel.";
                price = 5000;
                stock = 100;
                condition = "!(player getVariable ['A3M_Halo_Solo', false])";
		code = "if (player == (_this select 0)) then { player setVariable ['A3M_Halo_Solo', true, true]; ['<t align=''left''><t size=''0.8'' color=''#00FF00''>HALO AUTHORIZED</t><br/><t size=''0.6'' color=''#FFFFFF''>Use ACE Self-Interact to designate coordinates.</t></t>', 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText; };";
            };
			class B_T_VTOL_01_vehicle_F {
                displayName = "HALO/HAHO AI Group Jump";
                description = "***WARNING***IT IS RECOMMENDED TO CARRY YOUR BACKPACK WITH ALiVE PLAYER LOGISTICS***When purchased, a HALO option will be added to your ACE Self-Interact menu. Use it to explicitly designate your group's drop coordinates. In military operations, HALO is also used for delivering equipment, supplies, or personnel, while HAHO is generally used exclusively for personnel.";
                price = 15000;
                stock = 100;
                condition = "!(player getVariable ['A3M_Halo_Squad', false])";
		code = "if (player == (_this select 0)) then { player setVariable ['A3M_Halo_Squad', true, true]; ['<t align=''left''><t size=''0.8'' color=''#00FF00''>SQUAD HALO AUTHORIZED</t><br/><t size=''0.6'' color=''#FFFFFF''>Use ACE Self-Interact to designate coordinates.</t></t>', 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText; };";
            };
	};
};