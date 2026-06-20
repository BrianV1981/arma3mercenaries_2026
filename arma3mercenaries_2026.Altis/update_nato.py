import re
import os

files = [
    'modules/mercenaryStoreMenu_1.hpp',
    'modules/mercenaryStoreMenu_2.hpp',
    'modules/mercenaryStoreMenu_parachute.hpp'
]

prices = {
    'B_Soldier_unarmed_F': 3000,
    'B_officer_F': 15000,
    'B_Soldier_SL_F': 16000,
    'B_Patrol_Soldier_TL_F': 16000,
    'B_Soldier_F': 15000,
    'B_Soldier_lite_F': 13000,
    'B_soldier_AR_F': 18000,
    'B_soldier_AAR_F': 15000,
    'B_soldier_LAT_F': 25000,
    'B_Soldier_GL_F': 17000,
    'B_Patrol_Soldier_MG_F': 19000,
    'B_HeavyGunner_F': 22000,
    'B_Patrol_Soldier_M_F': 23000,
    'B_Sharpshooter_F': 23000,
    'B_sniper_F': 28000,
    'B_spotter_F': 25000,
    'B_soldier_PG_F': 15000,
    'B_Soldier_A_F': 15000,
    'B_soldier_AT_F': 45000,
    'B_soldier_AA_F': 35000,
    'B_soldier_AAT_F': 20000,
    'B_soldier_AAA_F': 20000,
    'B_soldier_mine_F': 20000,
    'B_soldier_repair_F': 20000,
    'B_engineer_F': 20000,
    'B_Patrol_Engineer_F': 20000,
    'B_medic_F': 20000,
    'B_diver_TL_F': 22000,
    'B_diver_F': 20000,
    'B_diver_exp_F': 25000,
    'B_support_Mort_F': 20000,
    'B_support_AMort_F': 15000,
    'B_support_MG_F': 20000,
    'B_support_GMG_F': 22000,
    'B_support_AMG_F': 15000,
    'B_Patrol_Soldier_UAV_F': 20000,
    'B_Fighter_Pilot_F': 15000,
    'B_Pilot_F': 15000,
    'B_helicrew_F': 12000,
    'B_crew_F': 12000,
    'B_recon_TL_F': 22000,
    'B_recon_M_F': 25000,
    'B_Recon_Sharpshooter_F': 25000,
    'B_recon_medic_F': 25000,
    'B_recon_exp_F': 26000,
    'B_recon_JTAC_F': 22000,
    'B_T_Recon_M_F': 25000,
    'B_recon_F': 20000,
    'B_recon_LAT_F': 30000
}

for file_path in files:
    if not os.path.exists(file_path):
        continue
    with open(file_path, 'r') as f:
        content = f.read()

    # Find the NATO block
    start_idx = content.find('class units_4 {')
    if start_idx == -1:
        continue
        
    end_idx = content.find('class units_5 {', start_idx)
    if end_idx == -1:
        end_idx = content.find('class units_', start_idx + 10)
        
    if end_idx == -1:
        nato_block = content[start_idx:]
    else:
        nato_block = content[start_idx:end_idx]

    for cls, price in prices.items():
        pattern = r'(class\s+' + cls + r'\s+\{.*?price\s*=\s*)\d+(;.*?\})'
        nato_block = re.sub(pattern, r'\g<1>' + str(price) + r'\g<2>', nato_block, flags=re.DOTALL)

    if end_idx == -1:
        new_content = content[:start_idx] + nato_block
    else:
        new_content = content[:start_idx] + nato_block + content[end_idx:]

    with open(file_path, 'w') as f:
        f.write(new_content)
    print(f"Updated NATO in {file_path}")

