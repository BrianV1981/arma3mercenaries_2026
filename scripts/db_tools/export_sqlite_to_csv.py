import sqlite3
import json
import csv
import os

DB_PATH = "/home/brian-vasquez/arma3server/a3m_database.sqlite"
OUTPUT_DIR = "/home/brian-vasquez/aim-a3m/database_exports"

def clean_value(v):
    return json.dumps(v) if isinstance(v, (list, dict)) else v

def export_profiles(cursor):
    cursor.execute("SELECT id, val FROM store WHERE id LIKE 'A3M_PROFILE_%'")
    rows = cursor.fetchall()
    if not rows: return
    
    csv_path = os.path.join(OUTPUT_DIR, "A3M_Profiles.csv")
    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        header_written = False
        
        for row_id, val_str in rows:
            uid = row_id.replace("A3M_PROFILE_", "")
            try:
                parsed = json.loads(val_str)
                if len(parsed) == 2 and isinstance(parsed[0], list) and isinstance(parsed[1], list):
                    if not header_written:
                        writer.writerow(["UID"] + parsed[0])
                        header_written = True
                    writer.writerow([uid] + [clean_value(v) for v in parsed[1]])
            except Exception as e:
                print(f"Error parsing profile {row_id}: {e}")
    print(f"Exported {len(rows)} profiles.")

def export_flat_array(cursor, like_query, filename, headers):
    cursor.execute(f"SELECT id, val FROM store WHERE id LIKE '{like_query}'")
    rows = cursor.fetchall()
    if not rows: return
    
    csv_path = os.path.join(OUTPUT_DIR, filename)
    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(["EntityKey"] + headers)
        
        for row_id, val_str in rows:
            try:
                parsed = json.loads(val_str)
                # If it's a flat array of primitive values
                writer.writerow([row_id] + [clean_value(v) for v in parsed])
            except Exception as e:
                print(f"Error parsing {row_id}: {e}")
    print(f"Exported {len(rows)} to {filename}.")

def export_hg_garages(cursor):
    cursor.execute("SELECT id, val FROM store WHERE id LIKE 'HG_Garage_%'")
    rows = cursor.fetchall()
    if not rows: return
    
    csv_path = os.path.join(OUTPUT_DIR, "HG_Garages.csv")
    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(["Player_UID", "Classname", "License_Plate", "Color", "Is_Deployed"])
        
        for row_id, val_str in rows:
            uid = row_id.replace("HG_Garage_", "")
            try:
                vehicles = json.loads(val_str)
                for veh in vehicles:
                    writer.writerow([uid] + [clean_value(v) for v in veh])
            except Exception as e:
                print(f"Error parsing garage {row_id}: {e}")
    print(f"Exported {len(rows)} garages.")

def export_all_raw(cursor):
    cursor.execute("SELECT id, val FROM store")
    rows = cursor.fetchall()
    
    csv_path = os.path.join(OUTPUT_DIR, "A3M_Full_Database_Raw.csv")
    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(["Database_Key", "Raw_JSON_Value"])
        for row_id, val_str in rows:
            writer.writerow([row_id, val_str])
    print(f"Exported {len(rows)} total raw rows.")

def main():
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)
        
    print(f"Connecting to database: {DB_PATH}...")
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        export_profiles(cursor)
        
        export_flat_array(cursor, '%_containers_cont_%', "A3M_Containers.csv", 
                          ["Classname", "Position_ASL", "VectorDirUp", "Damage", "Inventory", "FortOwner", "IsStorage", "MoneyMenuOwner", "LbmMoney", "Variables", "VarName"])
        
        export_flat_array(cursor, '%_fortifications_fort_%', "A3M_Fortifications.csv", 
                          ["Classname", "Position_ASL", "VectorDirUp", "Damage", "IsStorage", "MoneyMenuOwner", "LbmMoney", "FortOwner", "Variables"])
        
        export_flat_array(cursor, '%_vehicles_veh_%', "A3M_Vehicles.csv", 
                          ["Classname", "Position_ASL", "VectorDirUp", "Hitpoints", "Fuel", "HasCrew", "Side", "TurretMagazines", "Inventory", "HG_Owner", "Variables", "VarName"])
        
        export_hg_garages(cursor)
        export_all_raw(cursor)
        
        conn.close()
        print("Comprehensive Export Complete!")
    except sqlite3.Error as e:
        print(f"Database error: {e}")

if __name__ == "__main__":
    main()