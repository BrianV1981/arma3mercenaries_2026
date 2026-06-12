import re, glob, os, sys

"""
sync_prices.py

A.I.M. Configuration Synchronizer Tool

PURPOSE:
This script synchronizes vehicle attributes (prices and descriptions) from the master 
GRAD store definitions (e.g. CfgGradBuymenu -> vehicleStoreMenu_1.hpp) directly into 
the HoverGuy (HG) Vehicle Shop UI configurations (HG_VehiclesShopCfg.h).

HOW IT WORKS:
1. It crawls the master `/modules/*.hpp` directory for Arma 3 `class` definitions.
2. It extracts the `price` and `description` string for each vehicle classname.
3. It opens `HG_VehiclesShopCfg.h` and uses Regex to inject these updated values directly 
   into the C++ arrays used by the HG Shop.

ARRAY ARCHITECTURE:
Standard HG arrays are formatted as: {"Classname", Price, "ConditionToBuy"}
This script natively injects a 4th parameter: {"Classname", Price, "ConditionToBuy", "Description"}

SQF INTEGRATION:
The injected 4th parameter ("Description") is read in-game by:
`HG/Functions/Client/VehiclesShop/fn_xVehicleSelectionChanged.sqf`
It safely strips the 4th string out and saves it to a global array (`A3M_HG_CurrentVehicleDescriptions`), 
which is then displayed beautifully on the vehicle info panel by `fn_vehicleSelectionChanged.sqf`.

Running this script guarantees that the HG UI natively reflects the true economy 
and lore descriptions set in the master Quartermaster database without in-game lag.
"""

workspace_dir = os.path.dirname(os.path.abspath(__file__))
# Check if running in a workspace branch
if "workspace/issue-54" in os.getcwd():
    workspace_dir = os.path.join(workspace_dir, "workspace", "issue-54")

mission_dir = os.path.join(workspace_dir, "arma3mercenaries_2026.Altis")

prices = {}
descriptions = {}

for f in glob.glob(os.path.join(mission_dir, 'modules/*.hpp')):
    with open(f, 'r') as file:
        content = file.read()
        
        parts = content.split("class ")
        for p in parts:
            lines = p.strip().split('\n')
            if not lines: continue
            first_line = lines[0]
            if '{' not in first_line: continue
            classname = first_line.split('{')[0].strip()
            
            # search for price = X; 
            price_match = re.search(r'price\s*=\s*(\d+);', p)
            if price_match:
                prices[classname] = int(price_match.group(1))
                
            # search for description = "...";
            desc_match = re.search(r'description\s*=\s*"([^"]+)";', p)
            if desc_match:
                descriptions[classname] = desc_match.group(1).replace('"', "'")

print(f"Found {len(prices)} items with prices.")

# Now parse HG_VehiclesShopCfg.h and replace prices
hg_file = os.path.join(mission_dir, 'HG/Config/HG_VehiclesShopCfg.h')
with open(hg_file, 'r') as f:
    hg_content = f.read()

def replace_price(match):
    classname = match.group(1)
    old_price = match.group(2)
    rest = match.group(3)
    
    cond_match = re.search(r'^("[^"]+")', rest)
    condition = cond_match.group(1) if cond_match else '"true"'
    
    new_price = old_price
    if classname in prices:
        new_price = prices[classname]
        
    desc = "No description available in the Quartermaster network."
    if classname in descriptions:
        desc = descriptions[classname]
        
    return f'{{"{classname}", {new_price}, {condition}, "{desc}"}}'

# Replace all matches
new_hg_content = re.sub(r'\{"([^"]+)",\s*(\d+),\s*([^}]+)\}', replace_price, hg_content)

with open(hg_file, 'w') as f:
    f.write(new_hg_content)

print("Finished updating HG Vehicles Shop prices and descriptions.")
