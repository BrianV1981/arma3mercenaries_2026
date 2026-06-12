# Post-Mortem: Grad-Persistence Database "Soft Wipe" Corruption

## 1. What Happened
Following a server crash (or unexpected system suspend), the Arma 3 server rebooted. While player profiles, ranks, and wallets loaded correctly from SQLite, the entire map appeared to suffer a "soft wipe." 

All world-state assets governed by `grad-persistence`—including dozens of fortifications, deployed vehicles, storage containers, and active AI mercenary groups—completely vanished and failed to spawn in.

## 2. Why It Happened (The Root Cause)
The failure was not caused by missing data, but by an interruption during the `grad-persistence` SQLite serialization cycle.

When the `saveMission` loop runs, it executes in three distinct phases:
1. **Clearance:** It targets the master index keys (e.g., `mcd_grad_persistence_my_persistent_mission_fortifications_COUNT`) and temporarily sets their value to `0`.
2. **Serialization:** It loops through every object on the map and writes their individual data strings to the database sequentially (e.g., `fort_0`, `fort_1`, `fort_2`).
3. **Commit:** Once the loop finishes, it updates the `COUNT` key to reflect the final total (e.g., `59`).

**The Failure Point:** The server was forcefully killed (or went to sleep) during **Phase 2**. The script successfully wrote the 59 individual fortifications to the SQLite database, but it never survived to execute Phase 3. 

As a result, the master `COUNT` key was permanently stuck at `0`. When the server rebooted, the `loadMission` script queried the `COUNT` key, received `0`, and bypassed the loading phase entirely, ignoring the perfectly intact data sitting right beneath it.

## 3. How to Avoid It
Because this vulnerability is inherent to how `grad-persistence` indexes arrays in a key-value database, the only prevention is operational hygiene:
* **Never Force-Kill:** Never use `CTRL+C`, `kill -9`, or close the Linux terminal window while the Arma 3 server process is running. 
* **Safe Shutdowns Only:** Always use the dedicated Operator Panel scripts (`3_STOP_SERVER.sh`) or shut the server down gracefully from within the game as a logged-in admin (`#shutdown`).
* **Watch the Logs:** Before restarting, always check the live console for the `"grad-persistence: SQLite mission save completed"` message.
* **The 10-Minute Safety Net:** We recently patched the auto-save interval from 6 hours to 10 minutes. This drastically reduces the window of vulnerability.

## 4. What To Do If It Happens Again (The Recovery Protocol)
If the server crashes and bases fail to load on the next boot, **do not place new objects or force a save**, as this will overwrite the orphaned data.

To recover the lost assets, you must manually repair the index counts in the database:
1. Stop the Arma 3 Dedicated Server.
2. Open the SQLite database via terminal: `sqlite3 /home/brian-vasquez/arma3server/a3m_database.sqlite`
3. Query the database to find the true count of the orphaned objects. For example, to find fortifications:
   `SELECT COUNT(*) FROM store WHERE id LIKE '%fortifications_fort%';`
4. Manually update the master `COUNT` key to match the result of your query:
   `UPDATE store SET val = '59' WHERE id = 'mcd_grad_persistence_my_persistent_mission_fortifications_COUNT';`
5. Repeat this process for `vehicles_COUNT`, `containers_COUNT`, and `groups_COUNT`.
6. Restart the server. The load script will read the corrected keys and physically spawn the assets back into the world.