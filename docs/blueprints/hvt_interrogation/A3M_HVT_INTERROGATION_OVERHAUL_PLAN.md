# Master Plan: Interrogation & HVT Architecture Overhaul

**Objective:** Transition the legacy, scheduled, monolithic script structure into a highly performant, data-driven framework utilizing `CfgFunctions`, `CBA_fnc_addPerFrameHandler`, and centralized State Management. This plan directly addresses GitHub Issues #11 (HVT & Task State Machine) and #3 (Interrogation Architecture Overhaul).

---

## Phase 1: Interrogation Consolidation & Unscheduled Execution (Issue #3)

Currently, the interrogation logic is split across multiple redundant files (`..._on_civilians.sqf`, `..._on_opfor.sqf`) and relies heavily on scheduled `spawn` and `while {true}` loops to apply bleed damage.

1.  **Consolidate the Action Logic:**
    *   Delete the redundant `arma3mercenaries_interrogate_bluforIndep_on_civilians.sqf` and `...on_opfor.sqf` scripts.
    *   Create a single, unified pre-compiled function: `A3M_fnc_interrogateTarget`.
    *   Pass the target's faction/side as an argument to the function to handle dynamic text and rewards without duplicating code.

2.  **Eradicate Scheduled Bleed Loops (Pillar 2):**
    *   Replace the `while {alive _cap}` loop with `CBA_fnc_addPerFrameHandler`.
    *   The PFH will tick predictably, applying the "bleed" damage and checking for the death state. Once the unit dies, the PFH will remove itself (`CBA_fnc_removePerFrameHandler`), calculate the reward, and trigger the HVT payload.

3.  **Modernize `interrogationTaskLocations.sqf`:**
    *   Remove the scheduled `waitUntil { sleep 0.5; }` block.
    *   Convert the three hardcoded Task definitions into a data-driven function (`A3M_fnc_initInterrogationTasks`) that iterates through an array of configured bodybag objects and spawns the static UI tasks instantly upon server boot.

---

## Phase 2: HVT Monolith Refactoring (Issue #11 - Part A)

The current `HVT_task_1.sqf` is a massive 600-line script executed via `execVM`, causing severe disk I/O bottlenecks. It handles everything from spawning units to UI text.

1.  **Migrate to `CfgFunctions` (Pillar 1):**
    *   Delete the monolithic `HVT_task_1.sqf` (and its iteration backups).
    *   Create a new library in `description.ext`: `A3M_Tasks`.
    *   Break the monolith into modular, single-responsibility functions:
        *   `A3M_fnc_generateHVTProfile` (Handles names, roles, and loadouts).
        *   `A3M_fnc_spawnHVTComposition` (Handles the ALiVE random composition spawning).
        *   `A3M_fnc_spawnHVTInsertion` (Handles the Helicopter transport and waypoints).

2.  **Decouple the Trigger:**
    *   Instead of the interrogation script directly running `execVM "HVT_task_1.sqf"`, the interrogation PFH will simply call: `["HVT", _taskLocation] call A3M_fnc_requestTask;`
    *   This funnels all task creation through a centralized Task Manager.

---

## Phase 3: The Task State Machine (Issue #11 - Part B)

The current HVT tracking relies on a disparate global array (`server_activeHvtTasks`) and a scheduled `while {true}` loop (`HVTTaskTracker.sqf`) to update the 3D marker.

1.  **Establish the Task State Machine:**
    *   Create a global `A3M_ActiveTasks` HashMap on the server.
    *   When an HVT is generated, its data (Task ID, HVT Object, State, Location) is stored as a Key-Value pair in the HashMap for `O(1)` retrieval.

2.  **Unscheduled Task Tracking (Pillar 2):**
    *   Delete `HVTTaskTracker.sqf` and `HVTTaskTrackingArray.sqf`.
    *   Create `A3M_fnc_taskTrackerPFH`. We will add a single `CBA_fnc_addPerFrameHandler` that executes every X seconds.
    *   This PFH will quickly iterate over the `A3M_ActiveTasks` HashMap. If the task is "ASSIGNED" and the HVT is alive, it updates the `BIS_fnc_taskSetDestination`. If the HVT is dead or null, it handles cleanup and removes the entry from the HashMap.

3.  **Modernize the Kill Hook:**
    *   Instead of attaching an `addEventHandler ["Killed"]` directly to every spawned HVT inside the monolith, we will handle task completion inside the mission's central `arma3mercenaries_killHandler.sqf`.
    *   When a unit dies, the global kill handler checks if the victim is an active HVT in the `A3M_ActiveTasks` HashMap. If yes, it distributes the rewards and updates the Task State Machine to "SUCCEEDED".

---

## Phase 4: GitOps Deployment

1.  **Branching:** Create the isolated Git worktree: `git worktree add ../fix-issue-11.Altis -b fix/issue-11`.
2.  **Implementation:** Write the new functions, update `description.ext`, and delete the legacy `tasks/` and `interrogations/` files.
3.  **Compilation:** Run `/home/brian-vasquez/aim-a3m/scripts/pack_mission.sh`.
4.  **Verification:** Utilize the Operator Panel to cycle the server, run the engine, and verify the lack of `execVM` errors and the successful execution of the new unscheduled CBA handlers.