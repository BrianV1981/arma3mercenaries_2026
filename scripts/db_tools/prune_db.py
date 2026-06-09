import sqlite3
import json
import shutil

DB_PATH = "/home/brian-vasquez/arma3server/a3m_database.sqlite"

# Allowed prefixes or exact matches based on user instructions
ALLOWED_CLASSES = [
    "CargoNet_01_box_F", 
    "B_Slingload_01_Cargo_F",
    "Land_CzechHedgehog_01_new_F", 
    "Land_CzechHedgehog_01_F",
    "Land_CzechHedgehog_01_old_F",
    "ACE_medicalSupplyCrate", 
    "ACE_medicalSupplyCrate_advanced",
    "Land_PaperBox_01_small_closed_white_med_F",
    "ACE_Box_Chemlights"
]

def prune_database():
    print("Connecting to database...")
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute("SELECT id, val FROM store WHERE id LIKE '%_containers_cont_%'")
    rows = cursor.fetchall()
    
    kept_keys = []
    deleted_count = 0
    
    for row_id, val_str in rows:
        try:
            parsed = json.loads(val_str)
            classname = parsed[0]
            
            if classname in ALLOWED_CLASSES:
                # Keep it
                kept_keys.append(row_id)
            else:
                # Delete it
                cursor.execute("DELETE FROM store WHERE id = ?", (row_id,))
                deleted_count += 1
        except Exception as e:
            print(f"Error parsing {row_id}: {e}")
            
    # Update the INDEX array to only contain the kept keys
    index_val = json.dumps(kept_keys)
    cursor.execute("UPDATE store SET val = ? WHERE id = 'mcd_grad_persistence_my_persistent_mission_containers_INDEX'", (index_val,))
    
    conn.commit()
    conn.close()
    
    print(f"Pruning complete! Deleted {deleted_count} garbage containers.")
    print(f"Preserved {len(kept_keys)} valid containers: {kept_keys}")

if __name__ == "__main__":
    prune_database()