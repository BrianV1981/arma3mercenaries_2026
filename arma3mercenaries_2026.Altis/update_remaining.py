import re
import os

files = [
    'modules/mercenaryStoreMenu_1.hpp',
    'modules/mercenaryStoreMenu_2.hpp',
    'modules/mercenaryStoreMenu_parachute.hpp'
]

prices = {
    # AAF Mercenaries (Mk20 gear)
    'units_6': 10000, # AAF Rifleman
    'I_Soldier_lite_F': 10000,
    'I_Soldier_A_F': 10000,
    'I_Soldier_GL_F': 11000,
    'I_Soldier_AR_F': 12000,
    'I_Soldier_SL_F': 11000,
    'I_Soldier_TL_F': 11000,
    'I_crew_F': 8000,
    'I_helicrew_F': 8000,
    'I_officer_F': 10000,
    'I_soldier_UAV_F': 10000,
    'I_soldier_UAV_06_F': 10000,
    'I_soldier_UAV_06_medical_F': 10000,
    'I_Soldier_universal_F': 10000,
    'I_Soldier_AAR_F': 10000,
    'I_support_MG_F': 12000,
    'I_support_GMG_F': 12000,
    'I_support_Mort_F': 12000,
    'I_support_AMG_F': 10000,
    'I_support_AMort_F': 10000,
    
    # AAF Specialized
    'I_Soldier_M_F': 16000,
    'I_Soldier_LAT_F': 15000,
    'I_Soldier_AT_F': 35000, # Titan
    'I_Soldier_AA_F': 25000, # Titan AA
    'I_Soldier_AAT_F': 12000,
    'I_Soldier_AAA_F': 12000,
    'I_medic_F': 15000,
    'I_Soldier_repair_F': 15000,
    'I_Soldier_exp_F': 15000,
    'I_soldier_mine_F': 15000,
    'I_engineer_F': 15000,
    'I_helipilot_F': 12000,
    'I_pilot_F': 12000,
    'I_diver_F': 15000,
    'I_diver_exp_F': 18000,
    'I_diver_TL_F': 16000,
    'I_Spotter_F': 15000,
    'I_Sniper_F': 22000,
    'I_Soldier_LAT2_F': 15000,

    # LDF Mercenaries (Promet gear)
    'units_7': 3000, # Unarmed
    'I_E_Soldier_F': 12000,
    'I_E_Soldier_A_F': 12000,
    'I_E_Soldier_AAR_F': 12000,
    'I_E_Soldier_AR_F': 14000,
    'I_E_Soldier_lite_F': 12000,
    'I_E_Soldier_GL_F': 13000,
    'I_E_Officer_F': 12000,
    'I_E_Soldier_SL_F': 13000,
    'I_E_Soldier_TL_F': 13000,
    'I_E_RadioOperator_F': 12000,
    'I_E_Support_GMG_F': 14000,
    'I_E_Support_MG_F': 14000,
    'I_E_Support_Mort_F': 14000,
    'I_E_Support_AMG_F': 12000,
    'I_E_Support_AMort_F': 12000,
    'I_E_Soldier_Pathfinder_F': 12000,
    'I_E_Soldier_CBRN_F': 12000,
    'I_E_Soldier_MP_F': 12000,
    
    # LDF Specialized
    'I_E_soldier_M_F': 18000,
    'I_E_Soldier_AA_F': 25000,
    'I_E_Soldier_AT_F': 35000,
    'I_E_Soldier_LAT_F': 18000,
    'I_E_Soldier_LAT2_F': 18000,
    'I_E_Soldier_AAA_F': 13000,
    'I_E_Soldier_AAT_F': 13000,
    'I_E_Engineer_F': 18000,
    'I_E_Soldier_Exp_F': 18000,
    'I_E_Soldier_Repair_F': 18000,
    'I_E_Medic_F': 18000,
    'I_E_Soldier_UAV_F': 16000,
    'I_E_soldier_UAV_06_F': 16000,
    'I_E_soldier_UAV_06_medical_F': 16000,
    'I_E_soldier_UGV_02_Science_F': 16000,
    'I_E_soldier_UGV_02_Demining_F': 16000,

    # Spetsnaz Mercenaries (AK-12 gear, Spec Forces Base 5000)
    'units_8': 16000, # TL
    'O_R_Soldier_GL_F': 17000,
    'O_R_Soldier_AR_F': 18000,
    'O_R_JTAC_F': 16000,
    'O_R_recon_TL_F': 16000,
    'O_R_recon_AR_F': 18000,
    'O_R_recon_GL_F': 17000,
    'O_R_recon_JTAC_F': 16000,
    'O_R_Patrol_Soldier_TL_F': 16000,
    'O_R_Patrol_Soldier_AR_F': 18000,
    'O_R_Patrol_Soldier_AR2_F': 17000,
    'O_R_Patrol_Soldier_A_F': 15000,

    # Spetsnaz Specialized
    'O_R_soldier_exp_F': 20000,
    'O_R_soldier_M_F': 22000,
    'O_R_medic_F': 20000,
    'O_R_Soldier_LAT_F': 25000,
    'O_R_recon_exp_F': 20000,
    'O_R_recon_M_F': 22000,
    'O_R_recon_medic_F': 20000,
    'O_R_recon_LAT_F': 25000,
    'O_R_Patrol_Soldier_M_F': 22000,
    'O_R_Patrol_Soldier_M2_F': 22000,
    'O_R_Patrol_Soldier_Medic': 20000,
    'O_R_Patrol_Soldier_Engineer_F': 20000,
    'O_R_Patrol_Soldier_LAT_F': 25000,

    # CSAT Viper Team (Type 115 gear, Spec Forces Base 5000)
    'units_9': 22000, # TL
    'O_V_Soldier_hex_F': 20000, # Operative
    'O_V_Soldier_Exp_hex_F': 25000, # Demo
    'O_V_Soldier_Medic_hex_F': 25000, # Medic
    'O_V_Soldier_M_hex_F': 25000, # Marksman
    'O_V_Soldier_LAT_hex_F': 30000, # AT
    'O_V_Soldier_JTAC_hex_F': 22000, # JTAC

    # Agent Provocateurs (Looters, Standard Base 2500)
    'units_10': 3000, # Looter Pistol
    'I_L_Looter_SG_F': 4000,
    'I_L_Looter_SMG_F': 4000,
    'I_L_Criminal_SG_F': 4000,
    'I_L_Criminal_SMG_F': 4000,
    'I_L_Hunter_F': 5000
}

for file_path in files:
    if not os.path.exists(file_path): continue
    with open(file_path, 'r') as f:
        content = f.read()

    for cls, price in prices.items():
        pattern = r'(class\s+' + cls + r'\s+\{.*?price\s*=\s*)\d+(;.*?\})'
        content = re.sub(pattern, r'\g<1>' + str(price) + r'\g<2>', content, flags=re.DOTALL)

    with open(file_path, 'w') as f:
        f.write(content)
    print(f"Updated remaining mercs in {file_path}")
