import sqlite3
import json

DB_PATH = "/home/brian-vasquez/arma3server/a3m_database_v842.sqlite"

conn = sqlite3.connect(DB_PATH)
cursor = conn.cursor()

cursor.execute("SELECT id, val FROM store WHERE id LIKE '%_containers_cont_%'")
rows = cursor.fetchall()

classnames = set()
for row_id, val_str in rows:
    try:
        parsed = json.loads(val_str)
        if len(parsed) > 0:
            classnames.add(parsed[0])
    except:
        pass

print("Found Classnames:")
for c in classnames:
    print(c)

conn.close()