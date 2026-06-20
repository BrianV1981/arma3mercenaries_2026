import re
import os

files = [
    'modules/mercenaryStoreMenu_1.hpp',
    'modules/mercenaryStoreMenu_2.hpp',
    'modules/mercenaryStoreMenu_parachute.hpp'
]

skip_cats = ['NATO', 'Syndicate', 'FIA', 'Gendarmerie', 'CTRG']

for file_path in files:
    if not os.path.exists(file_path): continue
    with open(file_path, 'r') as f:
        content = f.read()

    categories = re.findall(r'class units_\d+\s*\{.*?(?=\s*class units_|\s*\};$)', content, re.DOTALL)
    for cat in categories:
        cat_name_match = re.search(r'displayname\s*=\s*"(.*?)";', cat, re.IGNORECASE)
        if cat_name_match:
            cat_name = cat_name_match.group(1)
            if any(x in cat_name for x in skip_cats):
                continue
            print(f"--- {cat_name} ({file_path}) ---")
            
            classes = re.findall(r'class\s+([A-Za-z0-9_]+)\s*\{.*?displayName\s*=\s*"(.*?)";.*?price\s*=\s*(\d+);', cat, re.DOTALL)
            for cls_id, disp_name, price in classes:
                print(f"'{cls_id}': {price}, # {disp_name}")
