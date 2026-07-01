import re

input_file = '/home/brian-vasquez/aim-a3m/arma3mercenaries_2026.Altis/HG/Config/HG_VehiclesShopCfg.h'

with open(input_file, 'r') as f:
    content = f.read()

# Extract all vehicles
pattern = re.compile(r'\{"([^"]+)",\s*(\d+)\s*,\s*"([^"]+)"\}')
matches = pattern.findall(content)

vehicles = {}
for match in matches:
    classname, price, cond = match
    if classname not in vehicles:
        vehicles[classname] = (price, cond)

categories = {
    'Light': {'name': 'Light & Unarmored', 'items': []},
    'Armored': {'name': 'Armored Transports', 'items': []},
    'Heavy': {'name': 'Tanks & Artillery', 'items': []},
    'Support': {'name': 'Logistics & Support', 'items': []},
    'Helicopters': {'name': 'Rotary Wing', 'items': []},
    'Planes': {'name': 'Fixed Wing & VTOL', 'items': []},
    'Drones': {'name': 'UAVs & UGVs', 'items': []},
    'Naval': {'name': 'Boats & Submersibles', 'items': []},
    'Statics': {'name': 'Static Emplacements', 'items': []}
}

for classname, data in vehicles.items():
    cls_lower = classname.lower()
    
    if 'uav' in cls_lower or 'ugv' in cls_lower or 'drone' in cls_lower or 'stomper' in cls_lower or 'darter' in cls_lower:
        categories['Drones']['items'].append((classname, data[0], data[1]))
    elif 'static' in cls_lower or 'hmg' in cls_lower or 'gmg' in cls_lower or 'mortar' in cls_lower or 'at_f' in cls_lower or 'aa_f' in cls_lower or 'sam' in cls_lower or 'radar' in cls_lower:
        categories['Statics']['items'].append((classname, data[0], data[1]))
    elif 'boat' in cls_lower or 'sdv' in cls_lower or 'water' in cls_lower or 'rhib' in cls_lower:
        categories['Naval']['items'].append((classname, data[0], data[1]))
    elif 'heli' in cls_lower:
        categories['Helicopters']['items'].append((classname, data[0], data[1]))
    elif 'plane' in cls_lower or 'jet' in cls_lower or 'vtol' in cls_lower or 'wipeout' in cls_lower or 'neophron' in cls_lower or 'shikra' in cls_lower or 'black_wasp' in cls_lower or 'gryphon' in cls_lower:
        categories['Planes']['items'].append((classname, data[0], data[1]))
    elif 'truck' in cls_lower or 'van' in cls_lower or 'fuel' in cls_lower or 'ammo' in cls_lower or 'medical' in cls_lower or 'repair' in cls_lower:
        categories['Support']['items'].append((classname, data[0], data[1]))
    elif 'tank' in cls_lower or 'mbt' in cls_lower or 'arty' in cls_lower or 'scorcher' in cls_lower or 'sochor' in cls_lower:
        categories['Heavy']['items'].append((classname, data[0], data[1]))
    elif 'apc' in cls_lower or 'mrap' in cls_lower or 'ifv' in cls_lower or 'hunter' in cls_lower or 'strider' in cls_lower or 'ifrit' in cls_lower or 'gorgon' in cls_lower or 'panther' in cls_lower or 'bobcat' in cls_lower:
        categories['Armored']['items'].append((classname, data[0], data[1]))
    else:
        # Fallback to Light
        categories['Light']['items'].append((classname, data[0], data[1]))

new_config = """/*
    HG_VehiclesShopCfg.h
    Overhauled for A3M by A.I.M.
*/

class HG_DefaultShop 
{
    conditionToAccess = "true";
"""

for cat_key, cat_data in categories.items():
    if not cat_data['items']:
        continue
    
    new_config += f"""
    class {cat_key}
    {{
        displayName = "{cat_data['name']}";
        vehicles[] =
        {{
"""
    
    lines = []
    for item in cat_data['items']:
        lines.append(f'            {{"{item[0]}", {item[1]}, "{item[2]}"}}')
        
    new_config += ",\n".join(lines)
    new_config += """
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };
"""

new_config += "};\n"

with open(input_file, 'w') as f:
    f.write(new_config)

print(f"Successfully rebuilt config.")
