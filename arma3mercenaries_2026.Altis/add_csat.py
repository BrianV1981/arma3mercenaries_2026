import re
import os

files = [
    'modules/mercenaryStoreMenu_1.hpp',
    'modules/mercenaryStoreMenu_2.hpp',
    'modules/mercenaryStoreMenu_parachute.hpp'
]

csat_template = """
		//category:
		class units_11 {
            displayname = "CSAT Mercenaries (Regulars)";
            kindOf = "other";

			class O_Soldier_F {
                displayName = "CSAT Rifleman";
                description = "This is a CSAT Rifleman.";
                price = 12000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
			class O_Soldier_lite_F {
                displayName = "CSAT Rifleman (Light)";
                description = "This is a CSAT Rifleman (Light).";
                price = 12000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
			class O_Soldier_GL_F {
                displayName = "CSAT Grenadier";
                description = "This is a CSAT Grenadier.";
                price = 13000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
			class O_Soldier_AR_F {
                displayName = "CSAT Autorifleman";
                description = "This is a CSAT Autorifleman.";
                price = 14000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
			class O_Soldier_SL_F {
                displayName = "CSAT Squad Leader";
                description = "This is a CSAT Squad Leader.";
                price = 13000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
			class O_Soldier_TL_F {
                displayName = "CSAT Team Leader";
                description = "This is a CSAT Team Leader.";
                price = 13000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
			class O_medic_F {
                displayName = "CSAT Combat Life Saver";
                description = "This is a CSAT Combat Life Saver.";
                price = 18000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
			class O_soldier_repair_F {
                displayName = "CSAT Repair Specialist";
                description = "This is a CSAT Repair Specialist.";
                price = 18000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
			class O_soldier_exp_F {
                displayName = "CSAT Explosive Specialist";
                description = "This is a CSAT Explosive Specialist.";
                price = 18000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
			class O_engineer_F {
                displayName = "CSAT Engineer";
                description = "This is a CSAT Engineer.";
                price = 18000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
			class O_Soldier_A_F {
                displayName = "CSAT Ammo Bearer";
                description = "This is a CSAT Ammo Bearer.";
                price = 12000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
			class O_Soldier_AT_F {
                displayName = "CSAT Missile Specialist (AT)";
                description = "This is a CSAT Missile Specialist (AT).";
                price = 35000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
			class O_Soldier_AA_F {
                displayName = "CSAT Missile Specialist (AA)";
                description = "This is a CSAT Missile Specialist (AA).";
                price = 25000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
			class O_officer_F {
                displayName = "CSAT Officer";
                description = "This is a CSAT Officer.";
                price = 12000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
			class O_sniper_F {
                displayName = "CSAT Sniper";
                description = "This is a CSAT Sniper.";
                price = 25000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
			class O_spotter_F {
                displayName = "CSAT Spotter";
                description = "This is a CSAT Spotter.";
                price = 18000;
                amount = 1;
                stock = 9999;
				code = "CODE_REPLACE";
            };
		};
"""

for file_path in files:
    if not os.path.exists(file_path): continue
    with open(file_path, 'r') as f:
        content = f.read()

    # Determine what code string to use by looking at the first unit's code
    code_match = re.search(r'code\s*=\s*"(.*?)";', content)
    code_str = code_match.group(1) if code_match else "[_this select 1, _this select 0] spawn A3M_fnc_initMercenary;"
    
    csat_block = csat_template.replace("CODE_REPLACE", code_str)

    # Insert before the last '};'
    # We find the last instance of '};'
    last_brace_idx = content.rfind('};')
    
    if last_brace_idx != -1:
        new_content = content[:last_brace_idx] + csat_block + content[last_brace_idx:]
        with open(file_path, 'w') as f:
            f.write(new_content)
        print(f"Added CSAT to {file_path}")

