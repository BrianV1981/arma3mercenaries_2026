# A.I.M. Agent Onboarding Guide (Arma 3 Mercenaries 2026)

**⚠️ CRITICAL MANDATE:** Read this entire document before executing any commands or writing code. This is a highly customized, database-driven Arma 3 architecture. Standard Arma 3 conventions often do not apply.

---

## 1. The Core Philosophy: Optimization & Data-Driven Design
The overarching goal of the `arma3mercenaries_2026` codebase is **Optimization and Consolidation**. We are systematically eradicating bloated, repetitive, brute-force scripting in favor of elegant, data-driven architecture. 

**The Standard:** Never copy-paste boilerplate code. Condense, unify, and parameterize. If you see a folder with 100 repetitive `.sqf` files, it needs to be refactored into a single `CfgFunction` driven by a `HashMap` configuration.

---

## 2. The Strict Separation of Environments
You MUST respect the strict boundary between the Development Workspace and the Live Production Server.

### A. The Development Workspace (Where we write code)
**Path:** `/home/brian-vasquez/aim-arma/projects/`
This is your sandbox. All Git repositories and development scripts live here.
*   **Mission Repo:** `arma3mercenaries_2026.Altis/` (The main Arma 3 codebase).
    *   *Mandate:* **NEVER edit the `main` branch directly.** Use Git Worktrees for all edits (e.g., `git worktree add ../fix-issue-10.Altis -b fix/issue-10`).
    *   *Mandate:* Use `/home/brian-vasquez/aim-a3m/scripts/pack_mission.sh` to compile your worktrees into `.pbo` files.
*   **Database Bridge Repo:** `a3m-sqlite-bridge/` (The Rust extension source code).
    *   *Mandate:* This is a separate, private Git repository containing the pristine \"Golden Binary\" and custom Rust code.

### B. The Production Server (Where the game actually runs)
**Path:** `/home/brian-vasquez/arma3server/`
This is the live 64-bit Linux Arma 3 Server. **DO NOT** clutter this directory. **DO NOT** attempt to install this inside the AI workspace.
*   **Live PBOs:** `mpmissions/` (Where `pack_mission.sh` automatically sends compiled missions).
*   **Live Database:** `a3m_database.sqlite` (The active persistence DB).
*   **Live Extension:** `@a3m_db_core/a3m_db_core_x64.so` (The compiled Rust binary).
*   **Live Configs:** `server.cfg`, `basic.cfg`, and `alive.cfg` are cleanly centralized in the root folder.
*   **Live Logs:** `server_logs/arma3_live_console.log` (Because native Linux `.rpt` generation is broken, we pipe the live `tmux` terminal output here).

---

## 3. The Human Operator Panel (Server Execution)
**Path:** `/home/brian-vasquez/arma3server/a3m-operator-panel/`
The user is completely decoupled from AI-assisted server launches. They use this panel to start and stop the server manually.

**If you need to cycle the server to test a new PBO, you MUST use these scripts:**
1.  **Stop the Server:** `cd /home/brian-vasquez/arma3server/a3m-operator-panel && ./3_STOP_SERVER.sh`
2.  **Start the Server:** `./1_START_SERVER.sh` (This automatically runs background jobs and securely boots the Arma 3 engine into a detached `tmux` virtual terminal).
3.  **View Live Console:** `tmux capture-pane -t a3m_live -p`

*Note: Do not try to launch the `arma3server_x64` binary using generic `nohup` bash commands. It will instantly crash the engine.*

---

## 4. The Golden Binary Constraint (SQLite)
The `a3m_db_core` Rust extension bridging Arma 3 directly to local SQLite has been specifically tuned for Arma 3. 

1.  **The JSON Bug:** Arma 3's `parseSimpleArray` crashes if it sees standard JSON escaped quotes (\"). The Rust bridge manually replaces them with \"\" natively before returning the string.
2.  **The Boolean Bug:** Arma 3's `isEqualTo` SQF command fails if it compares a boolean (`true`) to an integer (`1`). The Rust bridge explicitly returns `[1, \"data\"]` on success.

**Mandate:** DO NOT update or \"fix\" the `lib.rs` file with standard JSON libraries (like `serde_json`). It will break the entire persistence engine.

---

## 5. The Four Pillars of Architecture Overhaul
When refactoring legacy scripts, you must adhere to these Four Pillars:

1.  **CfgFunctions (Pillar 1):** Eradicate `execVM` calls. Group logic into `description.ext` libraries (e.g., `A3M_Tasks`) so they execute instantaneously from RAM.
2.  **Unscheduled Execution (Pillar 2):** Eradicate scheduled loops (`spawn`, `sleep`, `while {true}`). Transition logic to `CBA_fnc_addPerFrameHandler` or state machines to prevent server timer drift under heavy load.
3.  **Data-Driven Design (Pillar 3):** Consolidate massive folders of brute-force scripts (like the 100+ mercenary scripts) into a single, unified function driven by a HashMap or Array configuration.
4.  **Database Integration (Pillar 4):** Push massive arrays (like player stats, loadouts, and kill data) out of volatile server RAM and into the custom `A3M_PROFILE_<UID>` HashMaps stored in the SQLite database.

---

## 6. Historical Engram Data (Log Archives)
If you need to forensically reconstruct lost logic, the massive JSONL logs from the May/June architectural overhaul are located at:
`/home/brian-vasquez/.gemini/tmp/aim-arma/chats/`
*(Do not `cat` these files. Use a Python script to parse the JSON tree).*
