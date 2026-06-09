import sqlite3
import json

DB_PATH = "/home/brian-vasquez/arma3server/a3m_database.sqlite"

def process_category(cursor, index_id, count_id, prefix_pattern):
    cursor.execute("SELECT val FROM store WHERE id = ?", (index_id,))
    row = cursor.fetchone()
    if row:
        try:
            keys = json.loads(row[0])
            valid_data = []
            for key in keys:
                cursor.execute("SELECT val FROM store WHERE id = ?", (key,))
                data_row = cursor.fetchone()
                if data_row:
                    valid_data.append(data_row[0])
            
            cursor.execute(f"DELETE FROM store WHERE id LIKE '{prefix_pattern}%'")
            
            for i, data_str in enumerate(valid_data):
                new_key = f"{prefix_pattern}{i}"
                cursor.execute("INSERT INTO store (id, val) VALUES (?, ?)", (new_key, data_str))
                
            cursor.execute("INSERT OR REPLACE INTO store (id, val) VALUES (?, ?)", (count_id, str(len(valid_data))))
            cursor.execute("DELETE FROM store WHERE id = ?", (index_id,))
            print(f"Successfully migrated {len(valid_data)} items for {count_id}.")
        except Exception as e:
            print(f"Failed to migrate {index_id}: {e}")

def restructure_database():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Process all categories
    categories = [
        ("mcd_grad_persistence_my_persistent_mission_fortifications_INDEX", "mcd_grad_persistence_my_persistent_mission_fortifications_COUNT", "mcd_grad_persistence_my_persistent_mission_fortifications_fort_"),
        ("mcd_grad_persistence_my_persistent_mission_groups_INDEX", "mcd_grad_persistence_my_persistent_mission_groups_COUNT", "mcd_grad_persistence_my_persistent_mission_groups_grp_"),
        ("mcd_grad_persistence_my_persistent_mission_statics_INDEX", "mcd_grad_persistence_my_persistent_mission_statics_COUNT", "mcd_grad_persistence_my_persistent_mission_statics_stat_"),
        ("mcd_grad_persistence_my_persistent_mission_markers_INDEX", "mcd_grad_persistence_my_persistent_mission_markers_COUNT", "mcd_grad_persistence_my_persistent_mission_markers_marker_"),
        ("mcd_grad_persistence_my_persistent_mission_tasks_INDEX", "mcd_grad_persistence_my_persistent_mission_tasks_COUNT", "mcd_grad_persistence_my_persistent_mission_tasks_task_"),
        ("mcd_grad_persistence_my_persistent_mission_triggers_INDEX", "mcd_grad_persistence_my_persistent_mission_triggers_COUNT", "mcd_grad_persistence_my_persistent_mission_triggers_trig_")
    ]
    
    for idx, count_id, prefix in categories:
        process_category(cursor, idx, count_id, prefix)

    conn.commit()
    conn.close()

if __name__ == "__main__":
    restructure_database()