import sqlite3
import json

db_path = '/home/brian-vasquez/arma3server/a3m_database.sqlite'

# Realistic fake players
players = [
    {
        "uid": "76561198000000001",
        "name": "Ghost",
        "kills": 845,
        "deaths": 12,
        "walked": 45000.5,
        "longest": [1250, "M320 LRR", "Vasquez"]
    },
    {
        "uid": "76561198000000002",
        "name": "Reaper",
        "kills": 412,
        "deaths": 55,
        "walked": 32000.1,
        "longest": [890, "Mk14", "CSAT Sniper"]
    },
    {
        "uid": "76561198000000003",
        "name": "Wraith",
        "kills": 1205,
        "deaths": 5,
        "walked": 85000.9,
        "longest": [1520, "GM6 Lynx", "AAF Spotter"]
    },
    {
        "uid": "76561198000000004",
        "name": "Specter",
        "kills": 630,
        "deaths": 22,
        "walked": 22000.3,
        "longest": [1050, "Cyrus", "Vasquez"]
    }
]

def serialize(obj):
    return json.dumps(obj, separators=(',', ':'))

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

for p in players:
    # 1. Profile Data
    keys = [
        "PlayerName", "Kills_Total", "Deaths_Total", "PlayTime_Minutes", "Distance_Walked",
        "First_Joined_Date", "Last_Deployment_Date", "Top_10_Longest_Kills", "Last_10_Kills"
    ]
    values = [
        p["name"], p["kills"], p["deaths"], 5400, p["walked"],
        "2025-01-01", "2026-06-02", 
        [[p["longest"][0], p["longest"][1], p["longest"][2]]], 
        [[2000, "Unknown", "MX", 150]]
    ]
    
    profile_data = [keys, values]
    profile_str = serialize(profile_data)
    profile_key = f"A3M_PROFILE_{p['uid']}"
    
    # 2. Garage Data (array of arrays)
    garage_data = [
        ["B_MRAP_01_hmg_F", "DEF-123", "", 0],
        ["B_Heli_Light_01_F", "AIR-456", "", 0]
    ]
    garage_str = serialize(garage_data)
    garage_key = f"HG_Garage_{p['uid']}"
    
    # Upsert Profile
    cursor.execute('''
        INSERT INTO store (id, val) VALUES (?, ?)
        ON CONFLICT(id) DO UPDATE SET val = excluded.val
    ''', (profile_key, profile_str))
    
    # Upsert Garage
    cursor.execute('''
        INSERT INTO store (id, val) VALUES (?, ?)
        ON CONFLICT(id) DO UPDATE SET val = excluded.val
    ''', (garage_key, garage_str))
    
    print(f"Injected Player: {p['name']} ({p['uid']})")

# Also spoof some grad-persistence money so the wealth leaderboard populates
for profile in players:
    steam_id = profile["uid"]
    bank = profile.get("kills", 10) * 1500 # Just fake some wealth based on kills
    grad_id = f"mcd_grad_persistence_my_persistent_mission_player_{steam_id}"
    grad_keys = ["money", "vars", "damage", "posASL", "inventory", "dir", "bankMoney"]
    grad_vals = [5000, [], "{}", [], [], 0, bank]
    grad_str = serialize([grad_keys, grad_vals])

    cursor.execute('''
        INSERT INTO store (id, val) VALUES (?, ?)
        ON CONFLICT(id) DO UPDATE SET val = excluded.val
    ''', (grad_id, grad_str))

conn.commit()
conn.close()
print("Database spoofing complete.")
