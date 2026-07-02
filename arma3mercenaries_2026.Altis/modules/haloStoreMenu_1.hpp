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
		code = "if (player == (_this select 0)) then { player setVariable ['A3M_Halo_Solo', true, true]; systemChat '[A3M] HALO Drop Authorized. Use ACE Self-Interact to designate coordinates.'; };";
            };
			class B_T_VTOL_01_vehicle_F {
                displayName = "HALO/HAHO AI Group Jump";
                description = "***WARNING***IT IS RECOMMENDED TO CARRY YOUR BACKPACK WITH ALiVE PLAYER LOGISTICS***When purchased, a HALO option will be added to your ACE Self-Interact menu. Use it to explicitly designate your group's drop coordinates. In military operations, HALO is also used for delivering equipment, supplies, or personnel, while HAHO is generally used exclusively for personnel.";
                price = 15000;
                stock = 100;
		code = "if (player == (_this select 0)) then { player setVariable ['A3M_Halo_Squad', true, true]; systemChat '[A3M] Squad HALO Drop Authorized. Use ACE Self-Interact to designate coordinates.'; };";
            };
	};
};