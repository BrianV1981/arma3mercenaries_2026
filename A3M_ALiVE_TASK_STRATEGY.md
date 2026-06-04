# ALiVE Task Reward Architecture Strategy

## 1. The Goal
The objective is to accurately reward human players with in-game currency (via `grad_moneymenu`) when they complete auto-generated ALiVE C2ISTAR tasks, without triggering rewards when Virtual AI units complete their own background objectives.

## 2. The Problem with Hijacking ALiVE
Initial attempts to tie rewards to ALiVE tasks resulted in two major roadblocks:

### A. The "Money Spigot" (Virtual AI Spam)
Hooking into the `ALIVE_eventLog` and listening for events like `TASK_SUCCEEDED` or `OPCOM_CAPTURE` successfully executed code. However, ALiVE's Operational Commander (OPCOM) continuously generates and completes thousands of virtual tasks across the map as AI factions fight each other in the background. Because the event log does not easily differentiate between "Human Task" and "Virtual AI Task," the script rewarded players every time an AI squad captured a random checkpoint 10 kilometers away, resulting in endless cash spam.

### B. The `compileFinal` Lockdown
Attempts to surgically overwrite or wrap ALiVE's internal reward generation functions (e.g., `ALIVE_fnc_taskCreateReward`) failed. The ALiVE framework aggressively protects its core architecture by passing its functions through Arma 3's `compileFinal` command during the server boot sequence. Once an Arma 3 function is marked as final, the engine strictly prohibits any other mission script from overwriting or wrapping it.

## 3. The Abandoned Alternative: Rebuilding from Scratch
Because ALiVE's internal task system is a locked black box, the natural progression was to abandon it entirely and rebuild every single task type (Assassination, CSAR, Destroy Vehicles, etc.) from scratch as custom scripts (as seen in the `tasks_1` and `tasks_2` backup folders). 

While effective, rebuilding a dynamic, map-aware task generation system that ALiVE already handles flawlessly is a massive reinvention of the wheel and creates unnecessary script bloat.

## 4. The Solution: The Native Diary Monitor (The "White Box" Approach)
Rather than fighting ALiVE's locked internal logic or rebuilding the entire task system from scratch, we can bypass the mod entirely and monitor the final output: the vanilla Arma 3 engine.

When ALiVE generates a mission specifically for a human player, it is forced to translate that mission into a native Arma 3 Diary Task so the player can see it on their map. Virtual AI squads do not have diaries.

### The Implementation Strategy:
1. **The Observer Loop:** We create a highly performant, unscheduled CBA Per-Frame Handler (`CBA_fnc_addPerFrameHandler`) that runs *locally* on each player's machine.
2. **The Polling:** Every 5-10 seconds, the loop queries the Arma 3 engine for the player's active tasks using `[player] call BIS_fnc_tasksUnit`.
3. **State Tracking:** The script caches the current state of those tasks (e.g., `"ASSIGNED"`).
4. **The Trigger:** On the next tick, if the engine reports that a tracked task has shifted its state to `"SUCCEEDED"`, the script knows the player has completed a mission.
5. **The Reward:** The script immediately fires the `grad_moneymenu` payout logic and removes the task from its tracking cache.

### Pros:
- **Zero AI Spam:** Virtual AI cannot trigger the reward because they do not possess Arma 3 Diary tasks.
- **ALiVE Independence:** The script does not interact with the ALiVE framework, making it completely immune to future ALiVE mod updates that might break internal hooks.
- **Resource Efficient:** Prevents the need to manually script dozens of custom dynamic missions.

### Cons & Edge Cases:
- **Collateral Success:** If a player is assigned an ALiVE task to "Destroy Vehicle" at a location, and a random Virtual AI jet bombs that vehicle before the player arrives, ALiVE will mark the player's task as "SUCCEEDED". Because the script only monitors the diary state, the player will be rewarded for a task they didn't physically complete. However, in a dynamic mercenary sandbox, receiving a payout because "the problem resolved itself" is an acceptable margin of error compared to the "money spigot" alternative.