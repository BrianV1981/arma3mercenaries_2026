    //buyables set/store:
    class haloStore_2 {

        //category:  
		class other {
            displayName = "Emergency HAHO/HALO Jump";
            kindOf = "Other";

			class B_T_VTOL_01_infantry_F {
                displayName = "5 Minute HALO/HAHO Solo Jump (Emergency)";
                description = "***WARNING***IT IS RECOMMENDED TO CARRY YOUR BACKPACK WITH ALiVE PLAYER LOGISTICS***After 5 minutes, a HALO option will be added to your ACE Self-Interact menu. Use it to explicitly designate your drop coordinates. In military operations, HALO is also used for delivering equipment, supplies, or personnel, while HAHO is generally used exclusively for personnel.";
                price = 10000;
                stock = 100;
		code = "if (player == (_this select 0)) then { [] spawn { systemChat '[A3M] Emergency HALO Drop will be authorized in 5 minutes.'; sleep 300; player setVariable ['A3M_Halo_Solo', true, true]; systemChat '[A3M] HALO Drop Authorized. Use ACE Self-Interact to designate coordinates.'; }; };";
            };
			class B_T_VTOL_01_vehicle_F {
                displayName = "5 Minute Emergency HALO/HAHO AI Group Jump (Emergency)";
                description = "***WARNING***IT IS RECOMMENDED TO CARRY YOUR BACKPACK WITH ALiVE PLAYER LOGISTICS***After 5 minutes, a HALO option will be added to your ACE Self-Interact menu. Use it to explicitly designate your group's drop coordinates. In military operations, HALO is also used for delivering equipment, supplies, or personnel, while HAHO is generally used exclusively for personnel.";
                price = 30000;
                stock = 100;
		code = "if (player == (_this select 0)) then { [] spawn { systemChat '[A3M] Emergency Squad HALO Drop will be authorized in 5 minutes.'; sleep 300; player setVariable ['A3M_Halo_Squad', true, true]; systemChat '[A3M] Squad HALO Drop Authorized. Use ACE Self-Interact to designate coordinates.'; }; };";
            };
	};
};