import re
import os

files = [
    'modules/mercenaryStoreMenu_1.hpp',
    'modules/mercenaryStoreMenu_2.hpp',
    'modules/mercenaryStoreMenu_parachute.hpp'
]

prices = {
    # CTRG
    'B_CTRG_Soldier_TL_tna_F': 15000,
    'B_CTRG_Soldier_Exp_tna_F': 20000,
    'B_CTRG_Soldier_Medic_tna_F': 20000,
    'B_CTRG_Soldier_M_tna_F': 22000,
    'B_CTRG_Soldier_tna_F': 15000,
    'B_CTRG_Soldier_LAT_tna_F': 25000,
    'B_CTRG_Soldier_AR_tna_F': 16000,
    'B_CTRG_Soldier_JTAC_tna_F': 15000,

    # FIA
    'I_G_Soldier_unarmed_F': 3000,
    'I_G_Soldier_F': 9000,
    'I_G_Soldier_lite_F': 9000,
    'I_G_Soldier_SL_F': 9000,
    'I_G_Soldier_TL_F': 9000,
    'I_G_Soldier_AR_F': 12000,
    'I_G_medic_F': 13000,
    'I_G_engineer_F': 13000,
    'I_G_Soldier_exp_F': 14000,
    'I_G_Soldier_GL_F': 10000,
    'I_G_Soldier_M_F': 14000,
    'I_G_Soldier_LAT_F': 16000,
    'I_G_Soldier_A_F': 9000,
    'I_G_officer_F': 9000,
    'I_G_Sharpshooter_F': 14000,
    'I_G_Soldier_LAT2_F': 11000,

    # Gendarmerie
    'B_GEN_Commander_F': 8000,
    'B_GEN_Soldier_universal_F': 8000
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
    print(f"Propagated CTRG/FIA/Gend to {file_path}")
