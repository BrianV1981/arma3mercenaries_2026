import urllib.request
import re

url = "https://community.bistudio.com/wiki/Arma_3:_CfgVehicles_EAST"
try:
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    response = urllib.request.urlopen(req)
    html = response.read().decode('utf-8')
    
    # Extract table rows
    matches = re.findall(r'<td>(O_[a-zA-Z0-9_]+)</td>\s*<td>(.*?)</td>', html)
    for classname, displayname in matches:
        if 'Soldier' in classname or 'medic' in classname or 'officer' in classname or 'engineer' in classname or 'pilot' in classname or 'crew' in classname or 'diver' in classname or 'support' in classname or 'recon' in classname or 'sniper' in classname or 'spotter' in classname or 'HeavyGunner' in classname or 'Sharpshooter' in classname:
            # Clean up displayname
            displayname = re.sub(r'<[^>]+>', '', displayname).strip()
            print(f"'{classname}': {displayname}")
except Exception as e:
    print("Error:", e)
