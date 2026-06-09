# A.I.M. System Operations & Architecture Hand-Off

## 1. Directory Architecture

**The Project Workspace (Mission Editing):**
*   **Location:** `/home/brian-vasquez/aim-arma/projects/`
*   **Mission Repo:** `arma3mercenaries_2026.Altis` (Tracked via Git. Default branch is `main`).
*   **Rust Extension Repo:** `a3m-sqlite-bridge` (Tracked via Git. Holds the Golden Binary).
*   **Rule:** NEVER edit files directly inside the active server directory. Always edit in a Git Worktree, pack to a `.pbo`, and push to the server.

**The Arma 3 Dedicated Server (Execution):**
*   **Location:** `/home/brian-vasquez/arma3server/`
*   **Server Binary:** `arma3server_x64` (Must run the 64-bit binary to support the Rust DB extension).
*   **PBO Directory:** `/home/brian-vasquez/arma3server/mpmissions/`
*   **The Live Database:** `/home/brian-vasquez/arma3server/a3m_database.sqlite` (The master SQLite file for persistence).

**The Server Configuration & Execution:**
*   **Location:** `/home/brian-vasquez/arma3server/`
*   **Central Configs:** `server.cfg`, `alive.cfg`, and `basic.cfg` are all cleanly located in the server root.
*   **Live Console Log:** `/home/brian-vasquez/arma3server/server_logs/arma3_live_console.log` (Because Arma 3 Linux `.rpt` generation is broken on this OS, we capture the live terminal output and pipe it here using `tee`). Always check this log for errors.

## 2. The Human Operator Panel

To completely decouple server administration from the AI exoskeleton, a Human Operator Panel was created at `/home/brian-vasquez/arma3server/a3m-operator-panel/`.

**If you need to test code on the server, you MUST use these scripts:**
1.  **Start the Server:** `./1_START_SERVER.sh` (This automatically runs the Python leaderboard compiler, safely boots the Arma 3 engine into a detached `tmux` virtual terminal, and pipes the output to the console log).
2.  **View Live Terminal:** `./2_VIEW_LIVE_TERMINAL.sh` (Connects the user directly to the running `tmux` session).
3.  **Stop the Server:** `./3_STOP_SERVER.sh` (Safely kills the Arma 3 process and the `tmux` session).

*Note: Do not try to launch the `arma3server_x64` binary using generic `nohup` bash commands without a PTY. It will crash the engine.*

## 3. The A3M SQLite Architecture (The Golden Binary)

The mission relies on a custom 64-bit Rust extension (`@a3m_db_core`) bridging Arma 3 directly to a local SQLite database.

**The Golden Binary Constraint (CRITICAL):**
The Rust bridge has been specifically tuned for Arma 3's high-speed parser (`parseSimpleArray`).
1.  **The JSON Bug:** Arma 3's parser crashes if it sees standard JSON escaped quotes (\"). The Rust bridge manually replaces them with `""` natively before returning the string.
2.  **The Boolean Bug:** Arma 3's `isEqualTo` SQF command fails if it compares a boolean (`true`) to an integer (`1`). The Rust bridge explicitly returns `[1, "data"]` on success.
*Mandate: DO NOT update or "fix" the `lib.rs` file with standard JSON libraries (like `serde_json`). It will break the entire persistence engine.*

**Serialization Mandates:**
*   **Flat Arrays Only:** You cannot save Arma 3 Objects or native HashMaps directly. HashMaps are safely flattened into `[keys, values]` arrays by `A3M_fnc_dbSetSecure` inside `initServer.sqf`.

## 4. Systems Mapped

**Deep Stat Tracking:**
*   **Data Structure:** Native HashMaps built inside `initServer.sqf` and cached globally in `A3M_LiveProfiles`.
*   **The Kill Hook:** Injected directly into `arma3mercenaries/kill/arma3mercenaries_killHandler.sqf` inside `A3M_fnc_serverHandleReward`. Captures Kills, Deaths, TKs, Civilian Kills, Suicides, and aggregates sliding arrays for Top 10 Longest Kills, Last 10 Kills, and Last 10 Deaths (with exact 3D coordinates).
*   **The Pedometer:** Client-side script (`arma3mercenaries/player_profile/fn_initPedometer.sqf`) pings the server every 10 seconds with distance walked/driven/flown. The server securely writes to SQLite every 60 seconds.
*   **The Black Market Ledger:** Hook injected into `modules/grad-listBuymenu/functions/buy/fn_buyServer.sqf`. Dynamically queries `CfgWeapons`/`CfgVehicles` for the display name and logs the item/price.
*   **Global Leaderboards (Decoupled Sync):** The leaderboard string is compiled by a Python script (`scripts/compile_global_leaderboards.py`). This script is securely executed by the `1_START_SERVER.sh` boot script and a Linux Cron Job (running every hour) to ensure real-time updates without bogging down the Arma 3 game loop.

**Mercenary Recruitment Consolidation (Pillar 3):**
*   100+ individual unit scripts were deleted and replaced by a single, unified data-driven script: `A3M_fnc_initMercenary`.
*   When a player purchases a unit from the store menus, this function spawns the correct delivery VTOL for their faction, paradrops the requested classname, and safely joins the AI to the player's group.

## 5. Active Deployment Protocol (GitOps)

To correctly deploy a new version of the mission:
1. Create a new Git Worktree from the `arma3mercenaries_2026.Altis` repository (e.g., `git worktree add ../fix-issue-10.Altis -b fix/issue-10`).
2. Make your code edits inside the isolated worktree folder.
3. Pack the mission in the background using `pack_mission.sh` (e.g., `/home/brian-vasquez/aim-a3m/scripts/pack_mission.sh "/home/brian-vasquez/aim-a3m/arma3mercenaries_2026.Altis"`).
4. Check the background task output to verify the `.pbo` was created successfully.
5. Forcefully stop the active server using the Operator Panel: `cd /home/brian-vasquez/arma3server/a3m-operator-panel && ./3_STOP_SERVER.sh`.
6. Start the server using the Operator Panel: `./1_START_SERVER.sh`.
7. Once testing is verified, merge your worktree branch into `main` and delete the worktree.